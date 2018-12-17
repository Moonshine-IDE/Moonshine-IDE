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

import static org.hamcrest.Matchers.is;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertThat;
import static org.mockito.Matchers.any;
import static org.mockito.Matchers.eq;
import static org.mockito.Mockito.when;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableList;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.palantir.ls.DefaultLanguageServerState;
import com.palantir.ls.api.CompilerWrapper;
import com.palantir.ls.api.LanguageServerState;
import com.palantir.ls.util.Ranges;
import java.io.IOException;
import java.net.URI;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.function.Consumer;
import java.util.stream.Collectors;
import org.eclipse.lsp4j.CompletionItem;
import org.eclipse.lsp4j.CompletionItemKind;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.Diagnostic;
import org.eclipse.lsp4j.DiagnosticSeverity;
import org.eclipse.lsp4j.DidChangeTextDocumentParams;
import org.eclipse.lsp4j.DidCloseTextDocumentParams;
import org.eclipse.lsp4j.DidOpenTextDocumentParams;
import org.eclipse.lsp4j.DidSaveTextDocumentParams;
import org.eclipse.lsp4j.DocumentSymbolParams;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.ReferenceContext;
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.SymbolKind;
import org.eclipse.lsp4j.TextDocumentContentChangeEvent;
import org.eclipse.lsp4j.TextDocumentIdentifier;
import org.eclipse.lsp4j.TextDocumentItem;
import org.eclipse.lsp4j.TextDocumentPositionParams;
import org.eclipse.lsp4j.VersionedTextDocumentIdentifier;
import org.eclipse.lsp4j.jsonrpc.messages.Either;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.rules.TemporaryFolder;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

public class DefaultTextDocumentServiceTest {

    @Rule
    public TemporaryFolder workspace = new TemporaryFolder();

    @Rule
    public ExpectedException expectedException = ExpectedException.none();

    private DefaultTextDocumentService service;
    private Path filePath;
    private List<PublishDiagnosticsParams> publishedDiagnostics = Lists.newArrayList();
    private Set<PublishDiagnosticsParams> expectedDiagnostics;
    private Map<URI, Set<SymbolInformation>> symbolsMap = Maps.newHashMap();
    private CompletionList emptyCompletionList;
    private CompletionList expectedCompletionList;
    private Set<Location> expectedReferences = Sets.newHashSet();
    private Optional<Location> expectedDefinitionLocation;

    @Mock
    private CompilerWrapper compilerWrapper;

    @Before
    public void setup() throws IOException {
        MockitoAnnotations.initMocks(this);

        filePath = workspace.newFile("something.groovy").toPath();
        expectedDiagnostics = Sets.newHashSet(new PublishDiagnosticsParams("foo", ImmutableList.of(
                        createDiagnostic("Some message", DiagnosticSeverity.Error, filePath.toString()),
                        createDiagnostic("Some other message", DiagnosticSeverity.Warning, filePath.toString())
                )));

        SymbolInformation symbol1 = new SymbolInformation("ThisIsASymbol", SymbolKind.Field, new Location());
        SymbolInformation symbol2 = new SymbolInformation("methodA", SymbolKind.Method, new Location());
        symbolsMap.put(filePath.toUri(), Sets.newHashSet(symbol1, symbol2));

        emptyCompletionList = new CompletionList(false, Lists.newArrayList());
        CompletionItem thisIsASymbol = new CompletionItem("ThisIsASymbol");
        thisIsASymbol.setKind(CompletionItemKind.Field);
        CompletionItem methodA = new CompletionItem("methodA");
        methodA.setKind(CompletionItemKind.Method);
        expectedCompletionList = new CompletionList(false, Lists.newArrayList(thisIsASymbol, methodA));

        expectedReferences.add(new Location("uri", Ranges.createRange(1, 1, 9, 9)));
        expectedReferences.add(new Location("uri", Ranges.createRange(1, 1, 9, 9)));
        Set<Location> allReferencesReturned = Sets.newHashSet(expectedReferences);
        // The reference that will be filtered out
        allReferencesReturned.add(new Location("uri", Ranges.UNDEFINED_RANGE));
        expectedDefinitionLocation = Optional.of(new Location("foo", Ranges.createRange(0, 1, 0, 1)));
        when(compilerWrapper.getWorkspaceRoot()).thenReturn(workspace.getRoot().toPath().toUri());
        when(compilerWrapper.compile(any())).thenReturn(expectedDiagnostics);
        when(compilerWrapper.getFileSymbols()).thenReturn(symbolsMap);
        when(compilerWrapper.getCompletion(any(), any())).thenReturn(emptyCompletionList);
        when(compilerWrapper.getCompletion(filePath.toUri(), new Position(5, 5)))
                .thenReturn(expectedCompletionList);
        when(compilerWrapper.findReferences(any())).thenReturn(allReferencesReturned);
        when(compilerWrapper.gotoDefinition(any(), eq(new Position(5, 5)))).thenReturn(expectedDefinitionLocation);
        when(compilerWrapper.gotoDefinition(any(), eq(new Position(4, 4)))).thenReturn(Optional.absent());

        LanguageServerState state = new DefaultLanguageServerState();
        state.setCompilerWrapper(compilerWrapper);

        service = new DefaultTextDocumentService(state);

        Consumer<PublishDiagnosticsParams> callback = this::publishDiagnostics;

        service.getState().setPublishDiagnostics(callback);
    }

    private void publishDiagnostics(PublishDiagnosticsParams params) {
        publishedDiagnostics.add(params);
    }

    @Test
    public void testDidOpen() {
        TextDocumentItem textDocument = new TextDocumentItem(
                filePath.toAbsolutePath().toString(), "groovy", 1, "something");
        service.didOpen(new DidOpenTextDocumentParams(textDocument));
        // assert diagnostics were published
        assertEquals(1, publishedDiagnostics.size());
        assertEquals(expectedDiagnostics, Sets.newHashSet(publishedDiagnostics.get(0)));
    }

    @Test
    public void testDidChange() {
        VersionedTextDocumentIdentifier ident = new VersionedTextDocumentIdentifier(0);
        ident.setUri(filePath.toAbsolutePath().toString());
        service.didChange(new DidChangeTextDocumentParams(ident,
                ImmutableList.of(new TextDocumentContentChangeEvent(Ranges.createRange(0, 0, 1, 1), 3, "Hello"))));
        // assert diagnostics were published
        assertEquals(1, publishedDiagnostics.size());
        assertEquals(expectedDiagnostics, Sets.newHashSet(publishedDiagnostics.get(0)));
    }

    @Test
    public void testDidChange_noChanges() {
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage(
                String.format("Calling didChange with no changes on uri '%s'", filePath.toUri()));
        VersionedTextDocumentIdentifier ident = new VersionedTextDocumentIdentifier(0);
        ident.setUri(filePath.toAbsolutePath().toString());
        service.didChange(new DidChangeTextDocumentParams(ident, ImmutableList.of()));
    }

    @Test
    public void testDidClose() {
        service.didClose(new DidCloseTextDocumentParams(
                new TextDocumentIdentifier(filePath.toAbsolutePath().toString())));
        // assert diagnostics were published
        assertEquals(1, publishedDiagnostics.size());
        assertEquals(expectedDiagnostics, Sets.newHashSet(publishedDiagnostics.get(0)));
    }

    @Test
    public void testDidSave() {
        service.didSave(new DidSaveTextDocumentParams(
                new TextDocumentIdentifier(filePath.toAbsolutePath().toString())));
        // assert diagnostics were published
        assertEquals(1, publishedDiagnostics.size());
        assertEquals(expectedDiagnostics, Sets.newHashSet(publishedDiagnostics.get(0)));
    }

    @Test
    public void testDocumentSymbols_absolutePath() throws InterruptedException, ExecutionException {
        CompletableFuture<List<? extends SymbolInformation>> response = service.documentSymbol(
                new DocumentSymbolParams(
                        new TextDocumentIdentifier(filePath.toAbsolutePath().toString())));
        assertThat(response.get().stream().collect(Collectors.toSet()),
                is(symbolsMap.get(filePath.toUri())));
    }

    @Test
    public void testDocumentSymbols_relativePath() throws InterruptedException, ExecutionException {
        CompletableFuture<List<? extends SymbolInformation>> response =
                service.documentSymbol(new DocumentSymbolParams(new TextDocumentIdentifier("something.groovy")));
        assertThat(response.get().stream().collect(Collectors.toSet()),
                is(symbolsMap.get(filePath.toUri())));
    }

    @Test
    public void testReferences() throws InterruptedException, ExecutionException {
        ReferenceParams params = new ReferenceParams(new ReferenceContext(false));
        params.setPosition(new Position(5, 5));
        params.setTextDocument(new TextDocumentIdentifier("uri"));
        params.setUri("uri");
        CompletableFuture<List<? extends Location>> response = service.references(params);
        assertThat(response.get().stream().collect(Collectors.toSet()), is(expectedReferences));
    }

    @Test
    public void testCompletion() throws InterruptedException, ExecutionException {
        String uri = filePath.toAbsolutePath().toString();
        TextDocumentPositionParams params =
                new TextDocumentPositionParams(new TextDocumentIdentifier(uri), uri, new Position(5, 5));
        CompletableFuture<Either<List<CompletionItem>, CompletionList>> response = service.completion(params);
        assertThat(response.get().getRight().isIncomplete(), is(expectedCompletionList.isIncomplete()));
        assertThat(Sets.newHashSet(response.get().getRight().getItems()),
                is(Sets.newHashSet(expectedCompletionList.getItems())));
    }

    @Test
    public void testCompletion_noSymbols() throws InterruptedException, ExecutionException {
        String uri = workspace.getRoot().toPath().resolve("somethingthatdoesntexist.groovy").toString();
        TextDocumentPositionParams params =
                new TextDocumentPositionParams(new TextDocumentIdentifier(uri), uri, new Position(5, 5));
        CompletableFuture<Either<List<CompletionItem>, CompletionList>> response = service.completion(params);
        assertThat(response.get().getRight().isIncomplete(), is(false));
        assertThat(response.get().getRight().getItems(), is(Lists.newArrayList()));
    }

    @Test
    public void testDefinition() throws InterruptedException, ExecutionException {
        String uri = filePath.toAbsolutePath().toString();
        TextDocumentPositionParams params =
                new TextDocumentPositionParams(new TextDocumentIdentifier(uri), uri, new Position(5, 5));
        CompletableFuture<List<? extends Location>> response = service.definition(params);
        assertThat(response.get(), is(Lists.newArrayList(expectedDefinitionLocation.get())));
    }

    @Test
    public void testDefinition_NoDefinition() throws InterruptedException, ExecutionException {
        String uri = filePath.toAbsolutePath().toString();
        TextDocumentPositionParams params =
                new TextDocumentPositionParams(new TextDocumentIdentifier(uri), uri, new Position(4, 4));
        CompletableFuture<List<? extends Location>> response = service.definition(params);
        assertThat(response.get(), is(Lists.newArrayList()));
    }

    private Diagnostic createDiagnostic(String message, DiagnosticSeverity severity, String source) {
        return new Diagnostic(Ranges.UNDEFINED_RANGE, message, severity, source);
    }

}
