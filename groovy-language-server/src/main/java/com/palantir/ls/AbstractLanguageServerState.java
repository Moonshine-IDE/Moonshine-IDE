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

package com.palantir.ls;

import com.palantir.ls.api.CompilerWrapper;
import com.palantir.ls.api.LanguageServerState;
import java.util.Set;
import java.util.function.Consumer;
import org.eclipse.lsp4j.MessageParams;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.ShowMessageRequestParams;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractLanguageServerState implements LanguageServerState {

    private static final Logger LOG = LoggerFactory.getLogger(AbstractLanguageServerState.class);

    private CompilerWrapper compilerWrapper = null;
    private Consumer<MessageParams> showMessage = m -> { };
    private Consumer<ShowMessageRequestParams> showMessageRequest = m -> { };
    private Consumer<MessageParams> logMessage = m -> { };
    private Consumer<Object> telemetryEvent = e -> { };
    private Consumer<PublishDiagnosticsParams> publishDiagnostics = p -> { };

    @Override
    public CompilerWrapper getCompilerWrapper() {
        return compilerWrapper;
    }

    @Override
    public void setCompilerWrapper(CompilerWrapper compilerWrapper) {
        this.compilerWrapper = compilerWrapper;
    }

    @Override
    public Consumer<MessageParams> getShowMessage() {
        return showMessage;
    }

    @Override
    public void setShowMessage(Consumer<MessageParams> callback) {
        this.showMessage = callback;
    }

    @Override
    public Consumer<ShowMessageRequestParams> getShowMessageRequest() {
        return showMessageRequest;
    }

    @Override
    public void setShowMessageRequest(Consumer<ShowMessageRequestParams> callback) {
        this.showMessageRequest = callback;
    }

    @Override
    public Consumer<MessageParams> getLogMessage() {
        return logMessage;
    }

    @Override
    public void setLogMessage(Consumer<MessageParams> callback) {
        this.logMessage = callback;
    }

    @Override
    public Consumer<Object> getTelemetryEvent() {
        return telemetryEvent;
    }

    @Override
    public void setTelemetryEvent(Consumer<Object> telemetryEvent) {
        this.telemetryEvent = telemetryEvent;
    }

    @Override
    public void setPublishDiagnostics(Consumer<PublishDiagnosticsParams> callback) {
        this.publishDiagnostics = callback;
    }

    @Override
    public void publishDiagnostics(Set<PublishDiagnosticsParams> diagnostics) {
        if (diagnostics.isEmpty()) {
            LOG.debug("No diagnostics to publish.");
            return;
        }
        LOG.debug("Publishing diagnostics:\n{}", diagnostics);
        diagnostics.stream().forEach(publishDiagnostics::accept);
    }

}
