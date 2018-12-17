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

package com.palantir.ls.groovy;

import com.google.common.collect.ImmutableList;
import com.google.common.io.Files;
import com.palantir.ls.DefaultCompilerWrapper;
import com.palantir.ls.DefaultLanguageServerState;
import com.palantir.ls.StreamLanguageServerLauncher;
import com.palantir.ls.api.LanguageServerState;
import com.palantir.ls.api.TreeParser;
import com.palantir.ls.services.DefaultTextDocumentService;
import com.palantir.ls.services.DefaultWorkspaceService;
import com.palantir.ls.util.SimpleUriSupplier;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import org.apache.commons.io.FileUtils;
import org.eclipse.lsp4j.CompletionOptions;
import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.InitializeResult;
import org.eclipse.lsp4j.ServerCapabilities;
import org.eclipse.lsp4j.TextDocumentSyncKind;
import org.eclipse.lsp4j.services.LanguageClient;
import org.eclipse.lsp4j.services.LanguageClientAware;
import org.eclipse.lsp4j.services.LanguageServer;
import org.eclipse.lsp4j.services.TextDocumentService;
import org.eclipse.lsp4j.services.WorkspaceService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GroovyLanguageServer implements LanguageServer, LanguageClientAware {

    private static final Logger logger = LoggerFactory.getLogger(GroovyLanguageServer.class);

    private final LanguageServerState state;
    private final TextDocumentService textDocumentService;
    private final WorkspaceService workspaceService;

    private Path workspaceRoot;
    private Path targetDirectory;

    public GroovyLanguageServer(
            LanguageServerState state, TextDocumentService textDocumentService, WorkspaceService workspaceService) {
        this.state = state;
        this.textDocumentService = textDocumentService;
        this.workspaceService = workspaceService;
    }

    @Override
    public CompletableFuture<InitializeResult> initialize(InitializeParams params) {
        logger.debug("Initializing Groovy Language Server");
        workspaceRoot = Paths.get(Optional.ofNullable(params.getRootUri())
                .map(URI::create)
                .map(URI::normalize)
                .orElseGet(() -> Optional.ofNullable(params.getRootPath())
                        .map(Paths::get)
                        .map(Path::toAbsolutePath)
                        .map(Path::normalize)
                        .orElseThrow(() ->
                                new IllegalArgumentException("Either rootUri or rootPath must be set")).toUri()));
        logger.debug("Resolved workspace root: {}", workspaceRoot);

        CompletionOptions completionOptions = new CompletionOptions(false, ImmutableList.of("."));
        ServerCapabilities serverCapabilities = new ServerCapabilities();
        serverCapabilities.setCompletionProvider(completionOptions);
        serverCapabilities.setTextDocumentSync(TextDocumentSyncKind.Incremental);
        serverCapabilities.setDocumentSymbolProvider(true);
        serverCapabilities.setWorkspaceSymbolProvider(true);
        serverCapabilities.setDocumentSymbolProvider(true);
        serverCapabilities.setReferencesProvider(true);
        serverCapabilities.setDefinitionProvider(true);
        InitializeResult initializeResult = new InitializeResult(serverCapabilities);

        targetDirectory = Files.createTempDir().toPath();

        GroovyWorkspaceCompiler compiler =
                GroovyWorkspaceCompiler.of(targetDirectory, workspaceRoot);
        TreeParser parser =
                GroovyTreeParser.of(compiler, workspaceRoot,
                        new SimpleUriSupplier());
        DefaultCompilerWrapper groovycWrapper = new DefaultCompilerWrapper(compiler, parser);
        state.setCompilerWrapper(groovycWrapper);

        return CompletableFuture.completedFuture(initializeResult);
    }

    @Override
    public CompletableFuture<Object> shutdown() {
        deleteDirectory(targetDirectory.toFile());
        return CompletableFuture.completedFuture(new Object());
    }

    private static void deleteDirectory(File directory) {
        try {
            FileUtils.deleteDirectory(directory);
        } catch (IOException e) {
            logger.error("Could not delete directory '" + directory.toString() + "'", e);
        }
    }

    @Override
    public void exit() {
        System.exit(0);
    }

    @Override
    public TextDocumentService getTextDocumentService() {
        return textDocumentService;
    }

    @Override
    public WorkspaceService getWorkspaceService() {
        return workspaceService;
    }

    public Path getWorkspaceRoot() {
        return workspaceRoot;
    }

    public static void main(String[] args) {
        LanguageServerState state = new DefaultLanguageServerState();
        LanguageServer server =
                new GroovyLanguageServer(
                        state, new DefaultTextDocumentService(state), new DefaultWorkspaceService(state));


        StreamLanguageServerLauncher launcher = new StreamLanguageServerLauncher(server, System.in, System.out);
        launcher.launch();
    }

    @Override
    public void connect(LanguageClient client) {
        state.setPublishDiagnostics(client::publishDiagnostics);
        state.setTelemetryEvent(client::telemetryEvent);
        state.setShowMessage(client::showMessage);
        state.setShowMessageRequest(client::showMessageRequest);
        state.setLogMessage(client::logMessage);
    }
}
