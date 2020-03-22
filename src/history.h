/*
 * Marvin - an UCI/XBoard compatible chess engine
 * Copyright (C) 2015 Martin Danielsson
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#ifndef HISTORY_H
#define HISTORY_H

#include <stdbool.h>

#include "chess.h"

/*
 * Clear history tables.
 *
 * @param worker The worker to clear the history tables for.
 */
void history_clear_tables(struct search_worker *worker);

/*
 * Update the history tables with a new move.
 *
 * @param worker The worker.
 * @param list List of quiet moves tried for this position. The last move
 *             in the list is the move tha caused the beta cutoff.
 * @param depth The depth to which the move was searched.
 */
void history_update_tables(struct search_worker *worker, struct movelist *list,
                           int depth);

/*
 * Get a combined history score for a move.
 *
 * @param worker The worker.
 * @param move The move.
 * @return The combined history score.
 */
int history_get_score(struct search_worker *worker, uint32_t move);

/*
 * Clear the killer move table.
 *
 * @param worker The worker to clear the killer table for.
 */
void killer_clear_table(struct search_worker *worker);

/*
 * Add a move to the killer move table.
 *
 * @param worker The worker.
 * @param move The move to add.
 */ 
void killer_add_move(struct search_worker *worker, uint32_t move);

/*
 * Clear the counter move table.
 *
 * @param worker The worker to clear the counter move table for.
 */
void counter_clear_table(struct search_worker *worker);

/*
 * Add a move to the counter move table.
 *
 * @param worker The worker.
 * @param move The move to add.
 */
void counter_add_move(struct search_worker *worker, uint32_t move);

#endif
