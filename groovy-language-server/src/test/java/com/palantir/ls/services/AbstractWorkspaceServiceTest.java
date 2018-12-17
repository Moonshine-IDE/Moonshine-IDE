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
import static org.junit.Assert.assertThat;
import static org.mockito.Matchers.any;
import static org.mockito.Mockito.when;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.Sets;
import com.palantir.ls.api.CompilerWrapper;
import com.palantir.ls.api.LanguageServerState;
import com.palantir.ls.util.Ranges;
import java.io.IOException;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import org.eclipse.lsp4j.Diagnostic;
import org.eclipse.lsp4j.DiagnosticSeverity;
import org.eclipse.lsp4j.DidChangeConfigurationParams;
import org.eclipse.lsp4j.DidChangeWatchedFilesParams;
import org.eclipse.lsp4j.FileChangeType;
import org.eclipse.lsp4j.FileEvent;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.SymbolKind;
import org.eclipse.lsp4j.WorkspaceSymbolParams;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;

public class AbstractWorkspaceServiceTest {

    private static class TestWorkspaceService extends AbstractWorkspaceService {
        private final LanguageServerState state;

        TestWorkspaceService(LanguageServerState state) {
            this.state = state;
        }

        @Override
        protected LanguageServerState getState() {
            return state;
        }

        @Override
        public void didChangeConfiguration(DidChangeConfigurationParams didChangeConfigurationParams) {
            throw new UnsupportedOperationException();
        }
    }

    @Rule
    public TemporaryFolder workspace = new TemporaryFolder();

    private AbstractWorkspaceService service;
    private Set<PublishDiagnosticsParams> expectedDiagnostics = Sets.newHashSet();
    private Set<SymbolInformation> expectedReferences = Sets.newHashSet();

    @Mock
    private CompilerWrapper compilerWrapper;
    @Mock
    private LanguageServerState state;

    @Before
    public void setup() throws IOException {
        MockitoAnnotations.initMocks(this);

        Diagnostic d1 = new Diagnostic();
        d1.setMessage("Some message");
        d1.setSeverity(DiagnosticSeverity.Error);
        Diagnostic d2 = new Diagnostic();
        d2.setMessage("Some other message");
        d2.setSeverity(DiagnosticSeverity.Warning);
        expectedDiagnostics =
                Sets.newHashSet(new PublishDiagnosticsParams("uri", ImmutableList.of(d1, d2)));

        expectedReferences.add(new SymbolInformation(
                "MyClassName", SymbolKind.Class, new Location("uri", Ranges.createRange(1, 1, 9, 9)), "Something"));
        expectedReferences.add(new SymbolInformation(
                "MyClassName2",
                SymbolKind.Class,
                new Location("uri", Ranges.createRange(1, 1, 9, 9)),
                "SomethingElse"));
        Set<SymbolInformation> allReferencesReturned = Sets.newHashSet(expectedReferences);
        // The reference that will be filtered out
        allReferencesReturned.add(new SymbolInformation(
                "MyClassName3", SymbolKind.Class, new Location("uri", Ranges.UNDEFINED_RANGE), "SomethingElse"));

        when(compilerWrapper.getWorkspaceRoot()).thenReturn(workspace.getRoot().toPath().toUri());
        when(compilerWrapper.compile(any())).thenReturn(expectedDiagnostics);
        when(compilerWrapper.getFilteredSymbols(any())).thenReturn(allReferencesReturned);

        when(state.getCompilerWrapper()).thenReturn(compilerWrapper);

        service = new TestWorkspaceService(state);
    }

    @Test
    public void testSymbol() throws InterruptedException, ExecutionException {
        CompletableFuture<List<? extends SymbolInformation>> response =
                service.symbol(new WorkspaceSymbolParams("myQuery"));
        assertThat(response.get().stream().collect(Collectors.toSet()), is(expectedReferences));
    }

    @Test
    public void testDidChangeWatchedFiles() throws InterruptedException, ExecutionException {
        service.didChangeWatchedFiles(new DidChangeWatchedFilesParams(ImmutableList.of(
                new FileEvent("uri", FileChangeType.Deleted),
                new FileEvent("uri", FileChangeType.Created),
                new FileEvent("uri", FileChangeType.Changed))));
        // assert diagnostics were published
        Mockito.verify(state, Mockito.times(1)).publishDiagnostics(expectedDiagnostics);
    }

}
