/*
 * Copyright 2017 Palantir Technologies, Inc. All rights reserved.
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

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.Assert.assertEquals;

import com.google.common.base.Stopwatch;
import com.google.common.collect.Lists;
import com.google.common.io.Files;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.concurrent.TimeUnit;
import org.eclipse.lsp4j.Range;
import org.eclipse.lsp4j.TextDocumentContentChangeEvent;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.rules.TemporaryFolder;

public class InMemoryContentsManagerTest {

    @Rule
    public ExpectedException expectedException = ExpectedException.none();
    @Rule
    public TemporaryFolder sourceFolder = new TemporaryFolder();
    @Rule
    public TemporaryFolder destinationFolder = new TemporaryFolder();

    private Path defaultSourcePath;

    @Before
    public void before() {
        defaultSourcePath = new File(sourceFolder.getRoot(), "myfile.txt").toPath();
    }

    @Test
    public void testInitialize_noNewLine() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(defaultSourcePath, "my file contents");
        assertEquals("my file contents", manager.getContents());
    }

    @Test
    public void testDidChanges_noChanges() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(defaultSourcePath, "first line\nsecond line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        manager.applyChanges(changes);
        assertEquals("first line\nsecond line\n", manager.getContents());
    }

    @Test
    public void testDidChanges_nullRangeChange() throws IOException {
        InMemoryContentsManager writer = new InMemoryContentsManager(defaultSourcePath, "first line\nsecond line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent("foo"));
        writer.applyChanges(changes);
        assertEquals("foo", writer.getContents());
    }


    @Test
    public void testDidChanges_nullRangeWithMultipleChanges() throws IOException {
        InMemoryContentsManager writer = new InMemoryContentsManager(defaultSourcePath, "first line\nsecond line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent("foo"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(1, 0, 1, 0), 1, "notfoo"));
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage(String.format("Cannot handle more than one change when a null range exists: %s",
                changes.get(0).toString()));
        writer.applyChanges(changes);
    }

    @Test
    public void testDidChanges_insertionBeginningOfLine() throws IOException {
        InMemoryContentsManager writer = new InMemoryContentsManager(defaultSourcePath, "first line\necond line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(1, 0, 1, 0), 1, "s"));
        writer.applyChanges(changes);
        assertEquals("first line\nsecond line\n", writer.getContents());
    }

    @Test
    public void testDidChanges_insertionEndOfLine() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(defaultSourcePath, "first line\nsecond line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(1, 20, 1, 20), 13, "small change\n"));
        manager.applyChanges(changes);
        // Two new lines expected, one from the original contents and one from the change
        assertEquals("first line\nsecond linesmall change\n\n", manager.getContents());
    }

    @Test
    public void testDidChanges_insertionEndOfFile() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(defaultSourcePath, "first line\nsecond line");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(2, 0, 2, 0), 13, "small change"));
        manager.applyChanges(changes);
        assertEquals("first line\nsecond line\nsmall change\n", manager.getContents());
    }

    @Test
    public void testDidChanges_insertionEndOfFileExtraWhiteLines() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(defaultSourcePath, "first line\nsecond line");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(3, 0, 3, 0), 13, "small change"));
        manager.applyChanges(changes);
        assertEquals("first line\nsecond line\nsmall change\n", manager.getContents());
    }

    @Test
    public void testDidChanges_oneLineRange() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(defaultSourcePath, "first line\nsecond line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 6, 0, 10), 12, "small change"));
        manager.applyChanges(changes);
        assertEquals("first small change\nsecond line\n", manager.getContents());
    }

    @Ignore("Purely for very naive perf testing")
    @Test
    public void testDidChanges_multiLineRange_new() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(
                defaultSourcePath, "first line\nsecond line\nthird line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 6, 1, 6), 12, "small change"));
        Stopwatch started = Stopwatch.createStarted();
        for (int i = 0; i < 10000; i++) {
            manager.applyChanges(changes);
        }
        Stopwatch stop = started.stop();
        System.out.println(stop.elapsed(TimeUnit.MILLISECONDS));
    }

    @Test
    public void testDidChanges_multipleRangesWholeLines() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(
                defaultSourcePath, "first line\nsecond line\nthird line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 0, 0, 20), 16, "new line number 1"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(1, 0, 1, 20), 16, "new line number 2"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(2, 0, 2, 20), 16, "new line number 3"));
        manager.applyChanges(changes);
        assertEquals("new line number 1\nnew line number 2\nnew line number 3\n", manager.getContents());
    }

    @Test
    public void testDidChanges_multipleRangesSpecific() throws IOException {
        InMemoryContentsManager manager = new InMemoryContentsManager(
                defaultSourcePath, "first line\nsecond line\nthird line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 1, 0, 9), 16, "new line number 1"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(1, 1, 1, 10), 16, "new line number 2"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(2, 1, 2, 9), 16, "new line number 3"));
        manager.applyChanges(changes);
        assertEquals("fnew line number 1e\nsnew line number 2e\ntnew line number 3e\n", manager.getContents());
    }

    @Test
    public void testDidChanges_beforeFile() throws IOException {
        // Should be appended to the start of the file
        InMemoryContentsManager writer = new InMemoryContentsManager(
                defaultSourcePath, "first line\nsecond line\nthird line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 0, 0, 0), 7, "change\n"));
        writer.applyChanges(changes);
        assertEquals("change\nfirst line\nsecond line\nthird line\n", writer.getContents());
    }

    @Test
    public void testDidChanges_afterFile() throws IOException {
        // Should be appended to the end of the file
        InMemoryContentsManager writer = new InMemoryContentsManager(
                defaultSourcePath, "first line\nsecond line\nthird line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(30, 1, 30, 1), 6, "first "));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(31, 1, 31, 1), 6, "second"));
        writer.applyChanges(changes);
        assertEquals("first line\nsecond line\nthird line\nfirst second\n", writer.getContents());
    }

    @Test
    public void testDidChanges_invalidRanges() throws IOException {
        // Should be appended to the end of the file
        InMemoryContentsManager writer = new InMemoryContentsManager(
                defaultSourcePath, "first line\nsecond line\nthird line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(-1, 0, 0, 0), 3, "one"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 0, 0, 0), 3, "two"));
        expectedException.expect(IllegalArgumentException.class);
        expectedException
                .expectMessage(String.format("range1 is not valid: %s", Ranges.createRange(-1, 0, 0, 0).toString()));
        writer.applyChanges(changes);
    }

    @Test
    public void testDidChanges_intersectingRanges() throws IOException {
        // Should be appended to the end of the file
        InMemoryContentsManager writer = new InMemoryContentsManager(
                defaultSourcePath, "first line\nsecond line\nthird line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        Range range = Ranges.createRange(0, 0, 0, 1);
        changes.add(new TextDocumentContentChangeEvent(range, 3, "one"));
        changes.add(new TextDocumentContentChangeEvent(range, 3, "two"));
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage(
                String.format("Cannot apply changes with intersecting ranges in changes: %s", changes));
        writer.applyChanges(changes);
    }

    @Test
    public void testDidChanges_rangesStartAndEndOnSameLine() throws IOException {
        // Should be appended to the end of the file
        InMemoryContentsManager writer = new InMemoryContentsManager(
                defaultSourcePath, "0123456789\n0123456789\n0123456789\n0123456789\n0123456789\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 0, 0, 1), 1, "a"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 2, 0, 3), 1, "b"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 5, 0, 7), 1, "c"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 8, 1, 2), 1, "d"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(1, 4, 2, 2), 1, "e"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(2, 4, 2, 6), 1, "f"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(2, 9, 2, 9), 1, "g"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(4, 2, 4, 3), 1, "h"));
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(4, 3, 4, 4), 1, "i"));
        writer.applyChanges(changes);
        assertThat(writer.getContents()).isEqualTo("a1b34c7d23e23f678g9\n0123456789\n01hi456789\n");
    }

    @Test
    public void testSaveChanges() throws IOException {
        String originalContents = "first line\n";
        // Tests replacing the whole lines
        Path source = addFileToFolder(sourceFolder.getRoot(), "myfile.txt", originalContents);
        InMemoryContentsManager manager = new InMemoryContentsManager(defaultSourcePath, "first line\n");
        List<TextDocumentContentChangeEvent> changes = Lists.newArrayList();
        changes.add(new TextDocumentContentChangeEvent(Ranges.createRange(0, 1, 0, 9), 16, "new line number 1"));
        manager.applyChanges(changes);
        String newContents = "fnew line number 1e\n";
        assertEquals(newContents, manager.getContents());
        assertEquals(originalContents, Files.toString(source.toFile(), StandardCharsets.UTF_8));

        manager.saveChanges();
        assertEquals(newContents, Files.toString(source.toFile(), StandardCharsets.UTF_8));
    }

    private Path addFileToFolder(File parent, String filename, String contents) throws IOException {
        File file = Paths.get(parent.getAbsolutePath(), filename).toFile();
        Files.write(contents, file, StandardCharsets.UTF_8);
        return file.toPath();
    }

}
