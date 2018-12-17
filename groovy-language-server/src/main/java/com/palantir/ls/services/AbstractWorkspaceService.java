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

package com.palantir.ls.services;

import com.palantir.ls.api.LanguageServerState;
import com.palantir.ls.util.Ranges;
import java.net.URI;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;
import org.eclipse.lsp4j.DidChangeConfigurationParams;
import org.eclipse.lsp4j.DidChangeWatchedFilesParams;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.WorkspaceSymbolParams;
import org.eclipse.lsp4j.services.WorkspaceService;

public abstract class AbstractWorkspaceService implements WorkspaceService {

    protected abstract LanguageServerState getState();

    @Override
    public final CompletableFuture<List<? extends SymbolInformation>> symbol(WorkspaceSymbolParams params) {
        return CompletableFuture.completedFuture(getState().getCompilerWrapper().getFilteredSymbols(params.getQuery())
                .stream()
                .filter(symbol -> Ranges.isValid(symbol.getLocation().getRange()))
                .collect(Collectors.toList()));
    }

    @Override
    public final void didChangeWatchedFiles(DidChangeWatchedFilesParams params) {
        getState().getCompilerWrapper().handleChangeWatchedFiles(params.getChanges());
        Set<URI> relevantFiles = params.getChanges()
                .stream()
                .map(fileEvent -> URI.create(fileEvent.getUri()))
                .collect(Collectors.toSet());
        getState().publishDiagnostics(getState().getCompilerWrapper().compile(relevantFiles));
    }

    @Override
    public void didChangeConfiguration(DidChangeConfigurationParams didChangeConfigurationParams) {
        // default to do nothing
    }
}
