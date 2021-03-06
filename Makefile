# Default options
popcnt = no
sse = no
sse3 = no
ssse3 = no
sse41 = no
arch = x86-64-modern
trace = no
variant = release

# Update options based on the arch argument
.PHONY : arch
ifeq ($(arch), x86-64)
    sse = yes
    APP_ARCH = \"x86-64\"
else
ifeq ($(arch), x86-64-modern)
    popcnt = yes
    sse = yes
    sse3 = yes
    ssse3 = yes
    sse41 = yes
    APP_ARCH = \"x86-64-modern\"
endif
endif

# Common flags
ARCH += -m64
CPPFLAGS += -DAPP_ARCH=$(APP_ARCH)
CFLAGS += -m64 -DIS_64BIT -DUSE_SSE2
CXXFLAGS += -m64 -DIS_64BIT -DUSE_SSE2
LDFLAGS += -m64 -DIS_64BIT -lm

# Update flags based on options
.PHONY : popcnt
ifeq ($(popcnt), yes)
    CPPFLAGS += -DUSE_POPCNT
    CFLAGS += -msse3 -mpopcnt
    CXXFLAGS += -msse3 -mpopcnt -DUSE_POPCNT
else
    CPPFLAGS += -DTB_NO_HW_POP_COUNT
endif
.PHONY : sse
ifeq ($(sse), yes)
    CFLAGS += -msse
    CXXFLAGS += -msse
endif
.PHONY : sse3
ifeq ($(sse3), yes)
    CFLAGS += -msse3 -DUSE_SSE3
    CXXFLAGS += -msse3 -DUSE_SSE3
endif
.PHONY : ssse3
ifeq ($(ssse3), yes)
    CFLAGS += -mssse3 -DUSE_SSSE3
    CXXFLAGS += -mssse3 -DUSE_SSSE3
endif
.PHONY : sse41
ifeq ($(sse41), yes)
    CFLAGS += -msse4.1 -DUSE_SSE41
    CXXFLAGS += -msse4.1 -DUSE_SSE41
endif
.PHONY : trace
ifeq ($(trace), yes)
    CPPFLAGS += -DTRACE
endif

# Update flags based on build variant
.PHONY : variant
ifeq ($(variant), release)
    CPPFLAGS += -DNDEBUG
    CFLAGS += -O3 -funroll-loops -fomit-frame-pointer $(EXTRACFLAGS)
    CXXFLAGS += -O3 -funroll-loops -fomit-frame-pointer $(EXTRACXXFLAGS)
    LDFLAGS += $(EXTRALDFLAGS)
else
ifeq ($(variant), debug)
    CFLAGS += -g
    CXXFLAGS += -g
else
ifeq ($(variant), profile)
    CPPFLAGS += -DNDEBUG
    CFLAGS += -g -pg -O2 -funroll-loops
    CXXFLAGS += -g -pg -O2 -funroll-loops
    LDFLAGS += -pg
endif
endif
endif

# Set special flags needed for different operating systems
ifeq ($(OS), Windows_NT)
CFLAGS += -DWINDOWS
LDFLAGS += -static
else
CFLAGS += -flto
CXXFLAGS += -flto
LDFLAGS += -lpthread -flto
endif

# Configure warnings
CFLAGS += -W -Wall -Werror -Wno-array-bounds -Wno-pointer-to-int-cast -Wno-int-to-pointer-cast

# Extra include directories
CFLAGS += -Iimport/fathom -Isrc

# Extra include directories for nnue
CXXFLAGS += -Isrc
CXXFLAGS += -Iimport/nnue
CXXFLAGS += -Iimport/nnue/architectures
CXXFLAGS += -Iimport/nnue/features
CXXFLAGS += -Iimport/nnue/layers
CXXFLAGS += --std=c++17

# Enable evaluation tracing for tuner
ifeq ($(MAKECMDGOALS), tuner)
CFLAGS += -DTRACE
endif

# Compiler
CC = gcc
CXX = g++

# Sources
SOURCES = src/bitboard.c \
          src/board.c \
          src/chess.c \
          src/debug.c \
          src/engine.c \
          src/eval.c \
          src/evalparams.c \
          src/fen.c \
          src/hash.c \
          src/history.c \
          src/key.c \
          src/main.c \
          src/movegen.c \
          src/moveselect.c \
          src/polybook.c \
          src/search.c \
          src/see.c \
          src/smp.c \
          src/test.c \
          src/thread.c \
          src/timectl.c \
          src/uci.c \
          src/utils.c \
          src/validation.c \
          src/xboard.c \
          import/fathom/tbprobe.c
NNUE_SOURCES = import/nnue/evaluate_nnue.cpp \
               import/nnue/features/half_kp.cpp \
               src/nnue.cpp
TUNER_SOURCES = src/bitboard.c \
                src/board.c \
                src/chess.c \
                src/debug.c \
                src/engine.c \
                src/eval.c \
                src/evalparams.c \
                src/fen.c \
                src/hash.c \
                src/history.c \
                src/key.c \
                src/movegen.c \
                src/moveselect.c \
                src/polybook.c \
                src/search.c \
                src/see.c \
                src/smp.c \
                src/test.c \
                src/thread.c \
                src/timectl.c \
                src/trace.c \
                src/tuner.c \
                src/tuningparam.c \
                src/uci.c \
                src/utils.c \
                src/validation.c \
                src/xboard.c \
                import/fathom/tbprobe.c
.PHONY : trace
ifeq ($(trace), yes)
    SOURCES += src/trace.c src/tuningparam.c
endif

# Intermediate files
OBJECTS = $(SOURCES:%.c=%.o)
DEPS = $(SOURCES:%.c=%.d)
TUNER_OBJECTS = $(TUNER_SOURCES:%.c=%.o)
TUNER_DEPS = $(TUNER_SOURCES:%.c=%.d)
NNUE_OBJECTS = $(NNUE_SOURCES:%.cpp=%.o)
INTERMEDIATES = $(OBJECTS) $(DEPS)
TUNER_INTERMEDIATES = $(TUNER_OBJECTS) $(TUNER_DEPS)
NNUE_INTERMEDIATES = $(NNUE_OBJECTS)

# Include depencies
-include $(SOURCES:.c=.d)
-include $(TUNER_SOURCES:.c=.d)

# Targets
.DEFAULT_GOAL = marvin

%.o : %.c
	$(COMPILE.c) -MD -o $@ $<
%.o : %.cpp
	$(COMPILE.cpp) -MD -o $@ $<

clean :
	rm -f marvin marvin.exe tuner $(INTERMEDIATES) $(TUNER_INTERMEDIATES) $(NNUE_INTERMEDIATES)
.PHONY : clean

help :
	@echo "make <target> <option>=<value>"
	@echo ""
	@echo "Supported targets:"
	@echo "  marvin: Build the engine."
	@echo "  pgo: Build the engine using profile guided optimization."
	@echo "  tuner: Build the tuner program."
	@echo "  help: Display this message."
	@echo "  clean: Remove all intermediate files."
	@echo ""
	@echo "Supported options:"
	@echo "  arch=[x86-64|x86-64-modern]: The architecture to build for."
	@echo "  trace=[yes|no]: Include support for tracing the evaluation (default no)."
	@echo "  variant=[release|debug|profile]: The variant to build."
.PHONY : help

marvin : $(OBJECTS) $(NNUE_OBJECTS)
	$(CXX) $(OBJECTS) $(NNUE_OBJECTS) $(LDFLAGS) -o marvin

tuner : $(TUNER_OBJECTS) $(NNUE_OBJECTS)
	$(CXX) $(TUNER_OBJECTS) $(NNUE_OBJECTS) $(LDFLAGS) -o tuner

pgo-generate:
	$(MAKE) EXTRACFLAGS='-fprofile-generate' EXTRALDFLAGS='-fprofile-generate -lgcov'

pgo-use:
	$(MAKE) EXTRACFLAGS='-fprofile-use' EXTRALDFLAGS='-fprofile-use -lgcov'

pgo:
	$(MAKE) clean
	$(MAKE) pgo-generate
	rm -f src/*.gcda import/fathom/*.gcda
	./marvin -b
	$(MAKE) clean
	$(MAKE) pgo-use
	rm -f src/*.gcda import/fathom/*.gcda
