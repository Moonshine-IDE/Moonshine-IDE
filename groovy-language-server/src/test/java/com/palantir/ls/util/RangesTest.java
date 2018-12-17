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

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertThat;
import static org.junit.Assert.assertTrue;

import com.google.common.collect.Lists;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.Range;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

public class RangesTest {

    @Rule
    public ExpectedException expectedException = ExpectedException.none();

    @Test
    public void testIsValidRange() {
        assertFalse(Ranges.isValid(Ranges.createRange(-1, 6, 4, 4)));
        assertFalse(Ranges.isValid(Ranges.createRange(1, -6, 4, 4)));
        assertFalse(Ranges.isValid(Ranges.createRange(2, 6, -3, 4)));
        assertFalse(Ranges.isValid(Ranges.createRange(2, 6, 3, -4)));
        assertFalse(Ranges.isValid(Ranges.createRange(6, 6, 4, 4)));
        assertTrue(Ranges.isValid(Ranges.createRange(1, 2, 3, 4)));
        assertTrue(Ranges.isValid(Ranges.createRange(1, 1, 1, 1)));
    }

    @Test
    public void testIsValidPosition() {
        assertFalse(Ranges.isValid(position(-1, 1)));
        assertFalse(Ranges.isValid(position(1, -1)));
        assertFalse(Ranges.isValid(position(-1, -1)));
        assertTrue(Ranges.isValid(position(0, 0)));
        assertTrue(Ranges.isValid(position(1, 1)));
    }

    @Test
    public void testPositionComparator() {
        assertThat(Ranges.POSITION_COMPARATOR.compare(position(1, 1), position(1, 1)), is(0));
        assertThat(Ranges.POSITION_COMPARATOR.compare(position(1, 1), position(1, 2)), is(-1));
        assertThat(Ranges.POSITION_COMPARATOR.compare(position(1, 1), position(3, 2)), is(-2));
        assertThat(Ranges.POSITION_COMPARATOR.compare(position(1, 2), position(1, 1)), is(1));
        assertThat(Ranges.POSITION_COMPARATOR.compare(position(3, 2), position(1, 1)), is(2));
    }

    @Test
    public void testContains() {
        assertTrue(Ranges.contains(Ranges.createRange(4, 4, 4, 4), position(4, 4)));
        assertTrue(Ranges.contains(Ranges.createRange(4, 4, 6, 6), position(4, 4)));
        assertTrue(Ranges.contains(Ranges.createRange(4, 4, 6, 6), position(6, 6)));
        assertTrue(Ranges.contains(Ranges.createRange(4, 4, 6, 6), position(5, 5)));
        assertFalse(Ranges.contains(Ranges.createRange(4, 4, 6, 6), position(4, 3)));
        assertFalse(Ranges.contains(Ranges.createRange(4, 4, 6, 6), position(6, 7)));
    }

    @Test
    public void testContains_invalidRange() {
        Range range = Ranges.createRange(6, 6, 4, 4);
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage(String.format("range is not valid: %s", range.toString()));
        Ranges.contains(range, position(6, 7));
    }

    @Test
    public void testContains_invalidPosition() {
        Position position = position(-1, -1);
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage(String.format("position is not valid: %s", position.toString()));
        Ranges.contains(Ranges.createRange(4, 4, 4, 4), position);
    }

    @Test
    public void testCreateZeroBasedRange() {
        assertThat(Ranges.createZeroBasedRange(0, 0, 0, 0), is(Ranges.UNDEFINED_RANGE));
        assertThat(Ranges.createZeroBasedRange(-1, -1, -1, -1), is(Ranges.UNDEFINED_RANGE));
        assertThat(Ranges.createZeroBasedRange(-2, -2, -2, -2), is(Ranges.UNDEFINED_RANGE));
        assertThat(Ranges.createZeroBasedRange(1, 1, 1, 1), is(Ranges.createRange(0, 0, 0, 0)));
        assertThat(Ranges.createZeroBasedRange(2, 3, 4, 5), is(Ranges.createRange(1, 2, 3, 4)));
    }

    @Test
    public void testMax() {
        assertThat(Ranges.max(position(1, 2), position(2, 2)), is(position(2, 2)));
        assertThat(Ranges.max(position(2, 2), position(1, 2)), is(position(2, 2)));
        assertThat(Ranges.max(position(1, 2), position(1, 3)), is(position(1, 3)));
        assertThat(Ranges.max(position(1, 3), position(1, 2)), is(position(1, 3)));
        assertThat(Ranges.max(position(-1, -1), position(0, 0)), is(position(0, 0)));
        assertThat(Ranges.max(position(0, 0), position(-1, -1)), is(position(0, 0)));
        assertThat(Ranges.max(position(0, 0), position(0, 0)), is(position(0, 0)));
    }

    @Test
    public void testMin() {
        assertThat(Ranges.min(position(1, 2), position(2, 2)), is(position(1, 2)));
        assertThat(Ranges.min(position(2, 2), position(1, 2)), is(position(1, 2)));
        assertThat(Ranges.min(position(1, 2), position(1, 3)), is(position(1, 2)));
        assertThat(Ranges.min(position(1, 3), position(1, 2)), is(position(1, 2)));
        assertThat(Ranges.min(position(-1, -1), position(0, 0)), is(position(-1, -1)));
        assertThat(Ranges.min(position(0, 0), position(-1, -1)), is(position(-1, -1)));
        assertThat(Ranges.min(position(0, 0), position(0, 0)), is(position(0, 0)));
    }

    @Test
    public void testIntersects() {
        assertTrue(Ranges.intersects(Ranges.createRange(1, 1, 2, 2), Ranges.createRange(2, 1, 3, 1)));
        assertTrue(Ranges.intersects(Ranges.createRange(2, 1, 3, 1), Ranges.createRange(1, 1, 2, 2)));
        assertFalse(Ranges.intersects(Ranges.createRange(1, 1, 2, 1), Ranges.createRange(2, 1, 3, 1)));
        assertFalse(Ranges.intersects(Ranges.createRange(2, 1, 3, 1), Ranges.createRange(1, 1, 2, 1)));
        // Since for intersection ranges are considered inclusive on their start and exclusive on their end, ranges
        // where the start is exactly equal to end are not considered to intersect anything.
        assertFalse(Ranges.intersects(Ranges.createRange(1, 1, 1, 1), Ranges.createRange(1, 1, 1, 1)));
        assertFalse(Ranges.intersects(Ranges.createRange(2, 1, 4, 1), Ranges.createRange(3, 1, 3, 1)));
    }

    @Test
    public void testIntersects_invalidRange1() {
        Range range1 = Ranges.UNDEFINED_RANGE;
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage(String.format("range1 is not valid: %s", range1.toString()));
        assertFalse(Ranges.intersects(range1, Ranges.createRange(1, 2, 1, 2)));
    }

    @Test
    public void testIntersects_invalidRange2() {
        Range range2 = Ranges.UNDEFINED_RANGE;
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage(String.format("range2 is not valid: %s", range2.toString()));
        assertFalse(Ranges.intersects(Ranges.createRange(1, 2, 1, 2), range2));
    }

    @Test
    public void testSortedRangesIntersect() {
        assertTrue(Ranges.checkSortedRangesIntersect(Lists.newArrayList(Ranges.createRange(0, 0, 1, 0),
                Ranges.createRange(1, 1, 2, 2), Ranges.createRange(2, 1, 3, 1))));
        assertTrue(Ranges.checkSortedRangesIntersect(Lists.newArrayList(Ranges.createRange(0, 0, 1, 2),
                Ranges.createRange(1, 1, 2, 2), Ranges.createRange(2, 2, 3, 1))));
        assertFalse(Ranges.checkSortedRangesIntersect(Lists.newArrayList(Ranges.createRange(0, 0, 1, 0),
                Ranges.createRange(1, 1, 2, 1), Ranges.createRange(2, 1, 3, 1))));

        // Since for intersection ranges are considered inclusive on their start and exclusive on their end, ranges
        // where the start is exactly equal to end are not considered to intersect anything.
        assertFalse(Ranges.checkSortedRangesIntersect(Lists.newArrayList(Ranges.createRange(1, 1, 1, 1),
                Ranges.createRange(1, 1, 1, 1), Ranges.createRange(1, 1, 1, 1))));
        assertFalse(Ranges.checkSortedRangesIntersect(Lists.newArrayList(Ranges.createRange(2, 1, 4, 1),
                Ranges.createRange(3, 1, 3, 1), Ranges.createRange(3, 2, 3, 2))));
    }

    private static Position position(int line, int character) {
        return new Position(line, character);
    }

}
