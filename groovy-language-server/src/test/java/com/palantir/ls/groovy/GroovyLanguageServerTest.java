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

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatExceptionOfType;

import com.palantir.ls.api.LanguageServerState;
import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import org.eclipse.lsp4j.ClientCapabilities;
import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.InitializeResult;
import org.eclipse.lsp4j.TextDocumentSyncKind;
import org.eclipse.lsp4j.services.TextDocumentService;
import org.eclipse.lsp4j.services.WorkspaceService;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.mockito.Mockito;

public class GroovyLanguageServerTest {

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    private GroovyLanguageServer server;

    @Before
    public void before() {
        server = new GroovyLanguageServer(Mockito.mock(LanguageServerState.class),
                Mockito.mock(TextDocumentService.class), Mockito.mock(WorkspaceService.class));
    }

    @Test
    public void testInitialize_absoluteWorkspacePath() throws InterruptedException, ExecutionException {
        InitializeParams initializeParams = getInitializeParams(Optional.empty());

        InitializeResult result = server.initialize(initializeParams).get();
        assertInitializeResultIsCorrect(folder.getRoot().toPath().toAbsolutePath().normalize(), result);

        // Test normalization
        initializeParams = getInitializeParams(Optional.of(
                folder.getRoot().toPath().toAbsolutePath().toString() + "/somethingelse/.."));
        result = server.initialize(initializeParams).get();
        assertInitializeResultIsCorrect(folder.getRoot().toPath().toAbsolutePath().normalize(), result);
    }

    private InitializeParams getInitializeParams(Optional<String> root) {
        InitializeParams initializeParams = new InitializeParams();
        initializeParams.setProcessId(1);
        initializeParams.setCapabilities(new ClientCapabilities());
        initializeParams.setRootUri(root.map(Paths::get).orElse(folder.getRoot().toPath()).toUri().toString());
        return initializeParams;
    }

    @Test
    public void testInitialize_rootPathRootUri() throws Exception {
        InitializeParams rootPathParams = new InitializeParams();
        rootPathParams.setRootPath(folder.getRoot().toPath().toString());

        InitializeParams rootUriParams = new InitializeParams();
        rootUriParams.setRootUri(folder.getRoot().toURI().toString());

        GroovyLanguageServer pathServer = new GroovyLanguageServer(Mockito.mock(LanguageServerState.class),
                Mockito.mock(TextDocumentService.class), Mockito.mock(WorkspaceService.class));
        pathServer.initialize(rootPathParams);

        GroovyLanguageServer uriServer = new GroovyLanguageServer(Mockito.mock(LanguageServerState.class),
                Mockito.mock(TextDocumentService.class), Mockito.mock(WorkspaceService.class));
        uriServer.initialize(rootUriParams);

        assertThat(pathServer.getWorkspaceRoot()).isEqualTo(uriServer.getWorkspaceRoot());
    }

    @Test
    public void testInitialize_noRootPathOrRootUri() throws Exception {
        InitializeParams params = new InitializeParams();
        assertThatExceptionOfType(IllegalArgumentException.class).isThrownBy(() -> server.initialize(params));
    }

    @Test
    public void testInitialize_uriWorkspacePath() throws InterruptedException, ExecutionException {
        InitializeParams params = getInitializeParams(Optional.empty());
        InitializeResult result = server.initialize(params).get();
        assertInitializeResultIsCorrect(folder.getRoot().toPath().toAbsolutePath().normalize(), result);

        // Test normalization
        params = getInitializeParams(Optional.of(
                folder.getRoot().toPath().toAbsolutePath().toString() + "/somethingelse/.."));
        result = server.initialize(params).get();
        assertInitializeResultIsCorrect(folder.getRoot().toPath().toAbsolutePath().normalize(), result);
    }

    @Test
    public void testInitialize_relativeWorkspacePath() throws InterruptedException, ExecutionException, IOException {
        File workspaceRoot = Paths.get("").toAbsolutePath().resolve("test-directory-to-be-deleted").toFile();
        // Create a directory in our working directory
        // If this fails, make sure ./groovy-language-server/test-directory-to-be-deleted doesn't exist.
        assertThat(workspaceRoot.mkdir()).isTrue();

        InitializeParams params = getInitializeParams(Optional.of("test-directory-to-be-deleted"));
        InitializeResult result = server.initialize(params).get();
        assertInitializeResultIsCorrect(workspaceRoot.toPath(), result);

        // Test normalization
        params = getInitializeParams(Optional.of("./test-directory-to-be-deleted"));
        result = server.initialize(params).get();
        assertInitializeResultIsCorrect(workspaceRoot.toPath(), result);

        params = getInitializeParams(Optional.of("somethingelse/../something/../test-directory-to-be-deleted"));
        result = server.initialize(params).get();
        assertInitializeResultIsCorrect(workspaceRoot.toPath(), result);

        // Delete the directory we created in our working directory
        assertThat(workspaceRoot.delete()).isTrue();
    }

    private void assertInitializeResultIsCorrect(Path expectedWorkspaceRoot, InitializeResult result) {
        assertThat(server.getWorkspaceRoot()).isEqualTo(expectedWorkspaceRoot);
        assertThat(result.getCapabilities().getTextDocumentSync().getLeft())
                .isEqualTo(TextDocumentSyncKind.Incremental);
        assertThat(result.getCapabilities().getDocumentSymbolProvider()).isTrue();
        assertThat(result.getCapabilities().getWorkspaceSymbolProvider()).isTrue();
    }

}
