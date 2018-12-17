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

package com.palantir.ls.api;

import com.google.common.base.Optional;
import java.net.URI;
import java.util.List;
import java.util.Set;
import org.eclipse.lsp4j.FileEvent;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.TextDocumentContentChangeEvent;

/**
 * Provides wrapper methods for compiling a workspace, handles incremental changes, and returns Language Server Protocol
 * diagnostics.
 */
public interface WorkspaceCompiler {

    /**
     * Returns the root of the compiled workspace.
     */
    URI getWorkspaceRoot();

    /**
     * Compiles all relevant files in the workspace given input file uris.
     * @return the compilation warnings and errors by file
     */
    Set<PublishDiagnosticsParams> compile(Set<URI> files);

    /**
     * Handle opening a file.
     */
    void handleFileOpened(URI file, String contents);

    /**
     * Handle adding incremental changes to open files.
     */
    void handleFileChanged(URI originalFile, List<TextDocumentContentChangeEvent> contentChanges);

    /**
     * Handle closing {@code originalFile}.
     * @param originalFile the URI of the original file
     */
    void handleFileClosed(URI originalFile);

    /**
     * Handle changes saved to {@code originalFile} with optional contents of the file.
     * @param originalFile the URI of the original file
     */
    void handleFileSaved(URI originalFile, Optional<String> contents);

    /**
     * Handles reconfiguring the compiled files in the event some files were created, changed or deleted outside of the
     * language server.
     */
    void handleChangeWatchedFiles(List<? extends FileEvent> changes);

}
