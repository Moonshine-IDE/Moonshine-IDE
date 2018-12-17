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

import com.google.common.base.Preconditions;
import com.google.common.base.Throwables;
import com.palantir.ls.api.ContentsManager;
import edu.umd.cs.findbugs.annotations.SuppressFBWarnings;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.stream.Collectors;
import org.apache.commons.io.FileUtils;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.TextDocumentContentChangeEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Writes incremental changes to files.
 */
public final class FileBackedContentsManager implements ContentsManager {

    private static final Logger logger = LoggerFactory.getLogger(FileBackedContentsManager.class);

    private final Path source;
    private final Path destination;

    private FileBackedContentsManager(Path source, Path destination) {
        this.source = source;
        this.destination = destination;
    }

    /**
     * Creates a FileBackedContentsManager which creates a copy of source at destination.
     */
    @SuppressFBWarnings("PT_FINAL_TYPE_RETURN")
    public static FileBackedContentsManager of(Path source, Path destination) throws IOException {
        FileBackedContentsManager writer = new FileBackedContentsManager(source, destination);
        writer.initialize();
        return writer;
    }

    public Path getDestination() {
        return destination;
    }

    /**
     * Applies the given changes to the destination file. Does not handle intersecting ranges in the changes.
     */
    @Override
    public synchronized void applyChanges(List<TextDocumentContentChangeEvent> contentChanges) {
        // Check if any of the ranges are null
        for (TextDocumentContentChangeEvent change : contentChanges) {
            if (change.getRange() == null) {
                checkArgument(contentChanges.size() == 1,
                        String.format("Cannot handle more than one change when a null range exists: %s",
                                change.toString()));
                handleFullReplacement(change);
                return;
            }
        }

        // From earliest start of range to latest
        List<TextDocumentContentChangeEvent> sortedChanges = contentChanges.stream()
                .sorted((c1, c2) -> Ranges.POSITION_COMPARATOR
                        .compare(
                                c1.getRange().getStart(),
                                c2.getRange().getStart()))
                .collect(Collectors.toList());

        // Check if any of the ranges intersect
        checkArgument(
                !Ranges.checkSortedRangesIntersect(
                        sortedChanges.stream().map(change -> change.getRange()).collect(Collectors.toList())),
                String.format("Cannot apply changes with intersecting ranges in changes: %s",
                        contentChanges.toString()));

        try {
            handleChanges(sortedChanges);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public synchronized String getContents() {
        try {
            return new String(Files.readAllBytes(destination), StandardCharsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public synchronized void reload() {
        checkSourceFileExists();
        try {
            FileUtils.copyFile(source.toFile(), destination.toFile());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public synchronized void saveChanges() {
        checkSourceFileExists();
        try {
            FileUtils.copyFile(destination.toFile(), source.toFile());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private synchronized void handleFullReplacement(TextDocumentContentChangeEvent change) {
        File file = new File(destination.toAbsolutePath().toString());
        try {
            FileUtils.writeStringToFile(file, change.getText());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private synchronized void handleChanges(List<TextDocumentContentChangeEvent> sortedChanges) throws IOException {
        BufferedReader file =
                new BufferedReader(new InputStreamReader(new FileInputStream(destination.toAbsolutePath().toString()),
                        StandardCharsets.UTF_8.toString()));
        File tempFile = File.createTempFile("tempdestination", ".tmp");
        BufferedWriter output =
                new BufferedWriter(new OutputStreamWriter(new FileOutputStream(tempFile.getAbsolutePath(), false),
                        StandardCharsets.UTF_8));

        int changeIdx = 0;
        boolean endOfFile = false;
        String line = file.readLine();
        int lineNum = 0;
        if (line == null) {
            endOfFile = true;
        }
        int lastColumn = 0;

        for (; !endOfFile && changeIdx < sortedChanges.size(); changeIdx++) {
            Position start = sortedChanges.get(changeIdx).getRange().getStart();
            Position end = sortedChanges.get(changeIdx).getRange().getEnd();

            // Find the line where this change starts.
            while (start.getLine() != lineNum) {
                // Append this line which is not affected by a range.
                output.write(line.substring(Math.min(lastColumn, line.length())));
                output.newLine();
                lastColumn = 0;
                line = file.readLine();
                ++lineNum;
                if (line == null) {
                    endOfFile = true;
                    break;
                }
            }

            if (endOfFile) {
                break;
            }

            // Handle this change
            // Add everything before this range starting at the last column.
            output.write(
                    line.substring(Math.min(lastColumn, line.length()), Math.min(start.getCharacter(), line.length())));
            output.write(sortedChanges.get(changeIdx).getText());

            // Advance the file line buffer to where the range ends, ignoring all those lines.
            while (end.getLine() != lineNum) {
                line = file.readLine();
                ++lineNum;
                if (line == null) {
                    endOfFile = true;
                    break;
                }
            }

            // Set the where the next line should start, which is where the range ends since it is exclusive.
            lastColumn = end.getCharacter();
        }

        // Add the remaining file lines that are not affected by ranges
        if (line != null) {
            appendRemainingFile(file, line, output, lastColumn);
        }

        file.close();

        // Add the remaining changes that are out of range of this file
        appendRemainingRanges(sortedChanges, changeIdx, output);

        output.close();
        FileUtils.copyFile(tempFile, destination.toFile());
    }

    private synchronized void appendRemainingFile(
            BufferedReader file, String currentLine, BufferedWriter output, int lastColumn)
            throws IOException {
        output.write(currentLine.substring(Math.min(lastColumn, currentLine.length())));
        output.newLine();
        String line;
        while ((line = file.readLine()) != null) {
            output.write(line.substring(0, line.length()));
            output.newLine();
        }
    }

    private synchronized void appendRemainingRanges(List<TextDocumentContentChangeEvent> sortedChanges, int changeIdx,
            BufferedWriter output) throws IOException {
        sortedChanges.listIterator(changeIdx).forEachRemaining(change -> {
            try {
                output.write(change.getText());
            } catch (IOException e) {
                Throwables.propagate(e);
            }
        });
        if (changeIdx < sortedChanges.size()) {
            output.newLine();
        }
    }

    private synchronized void initialize() throws IOException {
        checkSourceFileExists();
        if (!destination.toFile().exists() && destination.toFile().isDirectory()) {
            if (!destination.toFile().mkdirs()) {
                logger.error("Could not recreate destination file '{}'", destination.toString());
                throw new RuntimeException("Could not recreate destination directories. "
                        + "User may not have permission to modify directory.");
            }
        }
        FileUtils.copyFile(source.toFile(), destination.toFile());
    }

    private void checkSourceFileExists() {
        Preconditions.checkState(source.toFile().exists(), "Source file %s does not exist", source.toAbsolutePath());
    }

}
