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
import static org.junit.Assert.assertEquals;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Sets;
import com.palantir.ls.DefaultLanguageServerState;
import com.palantir.ls.api.LanguageServerState;
import com.palantir.ls.groovy.util.GroovyConstants;
import com.palantir.ls.services.DefaultTextDocumentService;
import com.palantir.ls.services.DefaultWorkspaceService;
import com.palantir.ls.util.Ranges;
import edu.umd.cs.findbugs.annotations.SuppressFBWarnings;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PipedInputStream;
import java.io.PipedOutputStream;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;
import java.util.stream.Collectors;
import org.eclipse.lsp4j.CompletionOptions;
import org.eclipse.lsp4j.Diagnostic;
import org.eclipse.lsp4j.DiagnosticSeverity;
import org.eclipse.lsp4j.DidOpenTextDocumentParams;
import org.eclipse.lsp4j.DocumentSymbolParams;
import org.eclipse.lsp4j.InitializeParams;
import org.eclipse.lsp4j.InitializeResult;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.MessageActionItem;
import org.eclipse.lsp4j.MessageParams;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.ServerCapabilities;
import org.eclipse.lsp4j.ShowMessageRequestParams;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.SymbolKind;
import org.eclipse.lsp4j.TextDocumentIdentifier;
import org.eclipse.lsp4j.TextDocumentItem;
import org.eclipse.lsp4j.TextDocumentSyncKind;
import org.eclipse.lsp4j.jsonrpc.Launcher;
import org.eclipse.lsp4j.launch.LSPLauncher;
import org.eclipse.lsp4j.services.LanguageClient;
import org.eclipse.lsp4j.services.LanguageClientAware;
import org.eclipse.lsp4j.services.LanguageServer;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GroovyLanguageServerIntegrationTest {

    private static final Logger logger = LoggerFactory.getLogger(GroovyLanguageServerIntegrationTest.class);

    @Rule
    public TemporaryFolder workspaceRoot = new TemporaryFolder();

    private List<MyPublishDiagnosticParams> publishedDiagnostics = Lists.newArrayList();
    private static LanguageServer actualServer;
    private LanguageServer server;

    @SuppressFBWarnings("DM_DEFAULT_ENCODING")
    @Before
    public void before() throws IOException, InterruptedException {
        PipedOutputStream clientOutputStream = new PipedOutputStream();
        PipedOutputStream serverOutputStream = new PipedOutputStream();
        PipedInputStream clientInputStream = new PipedInputStream(serverOutputStream);
        PipedInputStream serverInputStream = new PipedInputStream(clientOutputStream);

        // Start Groovy language server
        createAndLaunchLanguageServer(serverInputStream, serverOutputStream);
        int counter = 0;
        while (server != null && counter++ < 20) {
            Thread.sleep(50);
        }
        LanguageClient client = getClient();
        Launcher<LanguageServer> clientLauncher = LSPLauncher.createClientLauncher(
                client,
                clientInputStream,
                clientOutputStream,
                false,
                new PrintWriter(System.out));
        clientLauncher.startListening();
        server = clientLauncher.getRemoteProxy();
        ((LanguageClientAware) actualServer).connect(client);
    }

    private void createAndLaunchLanguageServer(final InputStream in, final OutputStream out) {
        new Thread(() -> {
            LanguageServerState state = new DefaultLanguageServerState();
            actualServer = new GroovyLanguageServer(
                    state, new DefaultTextDocumentService(state), new DefaultWorkspaceService(state));
            Launcher<LanguageClient> launcher = LSPLauncher.createServerLauncher(
                    actualServer, in, out, false, new PrintWriter(System.out));
            launcher.startListening();
        }).start();
    }

    private LanguageClient getClient() {
        return new LanguageClient() {
            @Override
            public void telemetryEvent(Object object) {
                logger.info("TELEMETRY");
            }

            @Override
            public void publishDiagnostics(PublishDiagnosticsParams diagnostics) {
                publishedDiagnostics.add(
                        new MyPublishDiagnosticParams(
                                diagnostics.getUri(),
                                diagnostics.getDiagnostics().stream().collect(Collectors.toSet())));
            }

            @Override
            public void showMessage(MessageParams messageParams) {
                logger.info("MESSAGE");
            }

            @Override
            public CompletableFuture<MessageActionItem> showMessageRequest(ShowMessageRequestParams requestParams) {
                logger.info("message");
                return CompletableFuture.completedFuture(new MessageActionItem());
            }

            @Override
            public void logMessage(MessageParams message) {
                logger.info("LOG!");
            }
        };
    }

    @Test
    public void testInitialize() throws InterruptedException, ExecutionException, TimeoutException {
        InitializeParams params = getInitializeParams();

        CompletableFuture<InitializeResult> completableResult = server.initialize(params);
        InitializeResult result = completableResult.get(60, TimeUnit.SECONDS);
        assertCorrectInitializeResult(result);
    }

    private InitializeParams getInitializeParams() {
        InitializeParams params = new InitializeParams();
        params.setProcessId(0);
        params.setClientName("natacha");
        params.setRootUri(workspaceRoot.getRoot().toPath().toUri().toString());
        return params;
    }

    @Test
    public void testSymbols() throws InterruptedException, ExecutionException, TimeoutException, IOException {
        File newFolder1 = workspaceRoot.newFolder();
        File file = addFileToFolder(newFolder1, "Coordinates.groovy",
                "class Coordinates {\n"
                        + "   double latitude\n"
                        + "   double longitude\n"
                        + "   def name = \"Natacha\"\n"
                        + "   double getAt(int idx1, int idx2) {\n"
                        + "      def someString = \"Also in symbols\"\n"
                        + "      println someString\n"
                        + "      if (idx1 == 0) latitude\n"
                        + "      else if (idx1 == 1) longitude\n"
                        + "      else throw new Exception(\"Wrong coordinate index, use 0 or 1 \")\n"
                        + "   }\n"
                        + "}\n");

        CompletableFuture<InitializeResult> completableResult = server.initialize(getInitializeParams());
        InitializeResult result = completableResult.get(60, TimeUnit.SECONDS);
        assertCorrectInitializeResult(result);

        // Send a didOpen request to trigger a compilation
        sendDidOpen(file);

        // Give it some time to compile
        Thread.sleep(2000);

        // Assert no diagnostics were published because compilation was successful
        assertEquals(Sets.newHashSet(), publishedDiagnostics.stream().collect(Collectors.toSet()));

        CompletableFuture<List<? extends SymbolInformation>> documentSymbolResult = server.getTextDocumentService()
                .documentSymbol(new DocumentSymbolParams(new TextDocumentIdentifier(file.toURI().toString())));
        Set<SymbolInformation> actualSymbols = Sets.newHashSet(documentSymbolResult.get(60, TimeUnit.SECONDS));
        // Remove generated symbols for a saner comparison
        actualSymbols = actualSymbols.stream()
                        .filter(symbol -> Ranges.isValid(symbol.getLocation().getRange())).collect(Collectors.toSet());

        String fileUri = file.toPath().toUri().toString();
        Set<SymbolInformation> expectedResults = Sets.newHashSet(
                new SymbolInformation(
                        "Coordinates", SymbolKind.Class, new Location(fileUri, Ranges.createRange(0, 0, 1, 0))),
                new SymbolInformation(
                        "getAt",
                        SymbolKind.Method,
                        new Location(fileUri, Ranges.createRange(4, 3, 10, 4)),
                        "Coordinates"),
                new SymbolInformation(
                        "latitude",
                        SymbolKind.Field,
                        new Location(fileUri, Ranges.createRange(1, 3, 1, 18)),
                        "Coordinates"),
                new SymbolInformation(
                        "longitude",
                        SymbolKind.Field,
                        new Location(fileUri, Ranges.createRange(2, 3, 2, 19)),
                        "Coordinates"),
                new SymbolInformation(
                        "name",
                        SymbolKind.Field,
                        new Location(fileUri, Ranges.createRange(3, 3, 3, 23)),
                        "Coordinates"),
                new SymbolInformation(
                        "idx1",
                        SymbolKind.Variable,
                        new Location(fileUri, Ranges.createRange(4, 16, 4, 24)),
                        "getAt"),
                new SymbolInformation(
                        "idx2",
                        SymbolKind.Variable,
                        new Location(fileUri, Ranges.createRange(4, 26, 4, 34)),
                        "getAt"),
                new SymbolInformation(
                        "someString",
                        SymbolKind.Variable,
                        new Location(fileUri, Ranges.createRange(5, 10, 5, 20)),
                        "getAt"));
        assertThat(actualSymbols).containsOnlyElementsOf(expectedResults);
    }

    @Test
    public void testDiagnosticNotification()
            throws InterruptedException, ExecutionException, TimeoutException, IOException {
        File newFolder1 = workspaceRoot.newFolder();
        File newFolder2 = workspaceRoot.newFolder();
        File test1 = addFileToFolder(newFolder1, "test1.groovy",
                "class Coordinates {\n"
                        + "   double latitude\n"
                        + "   double longitude\n"
                        + "   double getAt(int idx) {\n"
                        + "      if (idx == 0) latitude\n"
                        + "      else if (idx == 1) longitude\n"
                        + "      else throw new ExceptionNew1(\"Wrong coordinate index, use 0 or 1\")\n"
                        + "   }\n"
                        + "}\n");
        File test2 = addFileToFolder(newFolder2, "test2.groovy",
                "class Coordinates2 {\n"
                        + "   double latitude\n"
                        + "   double longitude\n"
                        + "   double getAt(int idx) {\n"
                        + "      if (idx == 0) latitude\n"
                        + "      else if (idx == 1) longitude\n"
                        + "      else throw new ExceptionNew222(\"Wrong coordinate index, use 0 or 1\")\n"
                        + "   }\n"
                        + "}\n");
        addFileToFolder(newFolder2, "test3.groovy",
                "class Coordinates3 {\n"
                        + "   double latitude\n"
                        + "   double longitude\n"
                        + "   double getAt(int idx) {\n"
                        + "      if (idx == 0) latitude\n"
                        + "      else if (idx == 1) longitude\n"
                        + "      else throw new ExceptionNew(\"Wrong coordinate index, use 0 or 1\")\n"
                        + "   }\n"
                        + "}\n");
        addFileToFolder(workspaceRoot.getRoot(), "test4.groovy", "class ExceptionNew {}\n");

        CompletableFuture<InitializeResult> completableResult = server.initialize(getInitializeParams());
        InitializeResult result = completableResult.get(60, TimeUnit.SECONDS);
        assertCorrectInitializeResult(result);

        // Send a didOpen request to trigger a compilation
        sendDidOpen(test1);

        // Give it some time to publish
        Thread.sleep(5000);

        Set<MyPublishDiagnosticParams> expectedDiagnosticsResult =
                Sets.newHashSet(
                        new MyPublishDiagnosticParams(test1.toPath().toUri().toString(),
                                Sets.newHashSet(new Diagnostic(
                                        Ranges.createRange(6, 17, 6, 72),
                                        "unable to resolve class ExceptionNew1 \n @ line 7, column 18.",
                                        DiagnosticSeverity.Error,
                                        GroovyConstants.GROOVY_COMPILER))),
                        new MyPublishDiagnosticParams(test2.toPath().toUri().toString(),
                                Sets.newHashSet(new Diagnostic(
                                        Ranges.createRange(6, 17, 6, 74),
                                        "unable to resolve class ExceptionNew222 \n @ line 7, column 18.",
                                        DiagnosticSeverity.Error,
                                                GroovyConstants.GROOVY_COMPILER))));
        assertEquals(expectedDiagnosticsResult, publishedDiagnostics.stream().collect(Collectors.toSet()));
        assertEquals(2, publishedDiagnostics.size());
    }

    private void sendDidOpen(File file) {
        server.getTextDocumentService()
                .didOpen(new DidOpenTextDocumentParams(
                        new TextDocumentItem(file.toURI().toString(), "groovy", 0, "foo")));
    }

    private void assertCorrectInitializeResult(InitializeResult result) {
        CompletionOptions comp = new CompletionOptions(false, ImmutableList.of("."));
        ServerCapabilities capabilities = new ServerCapabilities();
        capabilities.setDocumentSymbolProvider(true);
        capabilities.setWorkspaceSymbolProvider(true);
        capabilities.setReferencesProvider(true);
        capabilities.setCompletionProvider(comp);
        capabilities.setDefinitionProvider(true);
        capabilities.setTextDocumentSync(TextDocumentSyncKind.Incremental);

        assertThat(capabilities).isEqualToIgnoringGivenFields(result.getCapabilities(), "textDocumentSync");
    }

    private static File addFileToFolder(File parent, String filename, String contents) throws IOException {
        File file = Files.createFile(Paths.get(parent.toURI().toString(), filename)).toFile();
        PrintWriter writer = new PrintWriter(file, StandardCharsets.UTF_8.toString());
        writer.println(contents);
        writer.close();
        return file;
    }

    // This is needed because the original PublishDiagnosticParams has a list of diagnostics, and order can't be
    // predicted so we need to compare them as sets, but neither can be assume the order of the published diagnostics.
    // So instead we compare Sets of Sets.
    private static final class MyPublishDiagnosticParams {
        private final String uri;
        private final Set<Diagnostic> diagnostics;

        MyPublishDiagnosticParams(String uri, Set<Diagnostic> diagnostics) {
            this.uri = uri;
            this.diagnostics = diagnostics;
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result + ((diagnostics == null) ? 0 : diagnostics.hashCode());
            result = prime * result + ((uri == null) ? 0 : uri.hashCode());
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null) {
                return false;
            }
            if (getClass() != obj.getClass()) {
                return false;
            }
            MyPublishDiagnosticParams other = (MyPublishDiagnosticParams) obj;
            if (diagnostics == null) {
                if (other.diagnostics != null) {
                    return false;
                }
            } else if (!diagnostics.equals(other.diagnostics)) {
                return false;
            }
            if (uri == null) {
                if (other.uri != null) {
                    return false;
                }
            } else if (!uri.equals(other.uri)) {
                return false;
            }
            return true;
        }

    }

}
