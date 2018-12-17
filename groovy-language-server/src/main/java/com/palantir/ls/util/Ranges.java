/*
 * Copyright 2016 Palantir Technologies, Inc. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.palantir.ls.util;

import static com.google.common.base.Preconditions.checkArgument;

import java.util.Comparator;
import java.util.List;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.Range;

public final class Ranges {

    /**
     * Compares position1 to position2. If they are the same, returns 0. If position1 is before position2, returns a
     * negative number. If position1 is after position2, returns a positive number.
     */
    public static final Comparator<Position> POSITION_COMPARATOR = (p1, p2) ->
            p1.getLine() != p2.getLine() ? p1.getLine() - p2.getLine() : p1.getCharacter() - p2.getCharacter();

    /**
     * The default range to use when no range is specified. Is an invalid range in a comparison.
     */
    public static final Range UNDEFINED_RANGE = createRange(-1, -1, -1, -1);

    private Ranges() {}

    /**
     * Returns a newly created range.
     */
    public static Range createRange(int startLine, int startColumn, int endLine, int endColumn) {
        return new Range(new Position(startLine, startColumn), new Position(endLine, endColumn));
    }

    /**
     * Returns a newly created zero-indexed range from one-indexed lines and columns.
     */
    public static Range createZeroBasedRange(int startLine, int startColumn, int endLine, int endColumn) {
        Range range = Ranges.createRange(startLine - 1, startColumn - 1,
                endLine - 1, endColumn - 1);
        return Ranges.isValid(range) ? range : Ranges.UNDEFINED_RANGE;
    }

    /**
     * Checks whether the given range is valid, i.e its start is before or equal to its end.
     */
    public static boolean isValid(Range range) {
        return isValid(range.getStart()) && isValid(range.getEnd())
                && POSITION_COMPARATOR.compare(range.getStart(), range.getEnd()) <= 0;
    }

    /**
     * Checks whether the given position is valid, i.e. it has non-negative line and character values.
     */
    public static boolean isValid(Position position) {
        return position.getLine() >= 0 && position.getCharacter() >= 0;
    }

    /**
     * Returns whether the given range contains the given position, inclusively.
     */
    public static boolean contains(Range range, Position position) {
        checkArgument(isValid(range), String.format("range is not valid: %s", range.toString()));
        checkArgument(isValid(position), String.format("position is not valid: %s", position.toString()));

        return POSITION_COMPARATOR.compare(range.getStart(), position) <= 0
                && POSITION_COMPARATOR.compare(range.getEnd(), position) >= 0;
    }

    /**
     * Returns the maximum position.
     */
    public static Position max(Position position1, Position position2) {
        return POSITION_COMPARATOR.compare(position1, position2) >= 0 ? position1 : position2;
    }

    /**
     * Returns the minimum position.
     */
    public static Position min(Position position1, Position position2) {
        return POSITION_COMPARATOR.compare(position1, position2) < 0 ? position1 : position2;
    }

    /**
     * Returns whether range1 and range2 intersect. Assumes that a range is inclusive on its start and exclusive on its
     * end, which means that if range1 ends on the same position as range2 starts, this is not considered intersecting.
     */
    public static boolean intersects(Range range1, Range range2) {
        checkArgument(isValid(range1), String.format("range1 is not valid: %s", range1.toString()));
        checkArgument(isValid(range2), String.format("range2 is not valid: %s", range2.toString()));

        Position maxStart = max(range1.getStart(), range2.getStart());
        Position minEnd = min(range1.getEnd(), range2.getEnd());
        return POSITION_COMPARATOR.compare(maxStart, minEnd) < 0;
    }

    /**
     * Returns whether any of the given sorted ranges intersect. The ranges need to be sorted from first occurrence to
     * last occurrence.
     */
    public static boolean checkSortedRangesIntersect(List<Range> sortedRanges) {
        for (int i = 0; i < sortedRanges.size() - 1; i++) {
            Range range1 = sortedRanges.get(i);
            Range range2 = sortedRanges.get(i + 1);
            if (Ranges.intersects(range1, range2)) {
                return true;
            }
        }
        return false;
    }

}
