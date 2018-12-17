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

import static com.google.common.base.Preconditions.checkArgument;

import com.palantir.ls.api.ContentsManager;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.List;
import java.util.stream.Collectors;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.Range;
import org.eclipse.lsp4j.TextDocumentContentChangeEvent;

public final class InMemoryContentsManager implements ContentsManager {

    private final StringBuilder contents = new StringBuilder();
    private final Path path;
    private final String initialContents;
    private static final String NEWLINE = System.lineSeparator();

    public InMemoryContentsManager(Path path, String initialContents) throws IOException {
        this.path = path;
        this.initialContents = initialContents;
        reload();
    }

    public Path getPath() {
        return path;
    }

    @Override
    public String getContents() {
        return contents.toString();
    }

    @Override
    public void reload() {
        contents.setLength(0);
        contents.append(initialContents);
    }

    @Override
    public synchronized void applyChanges(List<TextDocumentContentChangeEvent> contentChanges) {
        // Check if any of the ranges are null
        for (TextDocumentContentChangeEvent change : contentChanges) {
            if (change.getRange() == null) {
                checkArgument(contentChanges.size() == 1,
                        "Cannot handle more than one change when a null range exists: %s",
                        change);
                try {
                    handleFullReplacement(change);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
                return;
            }
        }

        // From earliest start of range to latest
        List<TextDocumentContentChangeEvent> sortedChanges = contentChanges.stream()
                .parallel()
                .sorted((c1, c2) -> Ranges.POSITION_COMPARATOR.compare(
                        c1.getRange().getStart(),
                        c2.getRange().getStart()))
                .collect(Collectors.toList());

        // Check if any of the ranges intersect
        checkArgument(!Ranges.checkSortedRangesIntersect(sortedChanges.stream()
                        .parallel()
                        .map(TextDocumentContentChangeEvent::getRange)
                        .collect(Collectors.toList())),
                "Cannot apply changes with intersecting ranges in changes: %s",
                contentChanges);

        try {
            handleChanges(sortedChanges);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public synchronized void saveChanges() {
        try {
            Files.write(
                    path, contents.toString().getBytes(StandardCharsets.UTF_8), StandardOpenOption.WRITE);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private synchronized void handleFullReplacement(TextDocumentContentChangeEvent change) throws IOException {
        contents.setLength(0);
        contents.append(change.getText());
    }

    private synchronized void handleChanges(List<TextDocumentContentChangeEvent> sortedChanges) throws IOException {
        String[] currentContents = contents.toString().split(NEWLINE);
        contents.setLength(0);

        boolean endOfFile = false;
        int lastColumn = 0;
        int changeIndex = 0;
        int lineNum = 0;
        int currentContentsLineCount = currentContents.length;
        for (; changeIndex < sortedChanges.size(); changeIndex++) {
            Range range = sortedChanges.get(changeIndex).getRange();
            Position start = range.getStart();
            Position end = range.getEnd();

            // copy over current contents leading up to the change
            while (start.getLine() > lineNum) {
                String currentLine = currentContents[lineNum];
                contents.append(currentLine.substring(Math.min(lastColumn, currentLine.length())))
                        .append(NEWLINE); // aint no windows
                lastColumn = 0;
                lineNum++;
                if (lineNum >= currentContentsLineCount) {
                    // this is a weird place to get into
                    endOfFile = true;
                    break;
                }
            }

            if (endOfFile) {
                // this is a weird place to get into
                break;
            }

            // handle the change under consideration
            String currentLine = currentContents[lineNum];
            contents.append(currentLine.substring(lastColumn, Math.min(start.getCharacter(), currentLine.length())))
                    .append(sortedChanges.get(changeIndex).getText());

            if (end.getLine() > currentContentsLineCount) {
                break;
            }
            lineNum = end.getLine();
            // Set the where the next line should start, which is where the range ends since it is exclusive.
            lastColumn = end.getCharacter();
        }

        // any remaining content from the old contents
        if (lineNum < currentContentsLineCount) {
            contents.append(currentContents[lineNum].substring(Math.min(lastColumn, currentContents[lineNum].length())))
                    .append(NEWLINE);
            lineNum++;
            while (lineNum < currentContentsLineCount) {
                contents.append(currentContents[lineNum])
                        .append(NEWLINE);
                lineNum++;
            }
        }

        List<TextDocumentContentChangeEvent> leftoverChanges = sortedChanges.subList(changeIndex, sortedChanges.size());
        leftoverChanges.forEach(change -> contents.append(change.getText()));
        if (!leftoverChanges.isEmpty()) {
            // Add a NEWLINE at the very end of the file to make it a valid file under most conventions
            contents.append(NEWLINE);
        }
    }

}
