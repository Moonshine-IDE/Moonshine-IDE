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

import java.util.Set;
import java.util.function.Consumer;
import org.eclipse.lsp4j.MessageParams;
import org.eclipse.lsp4j.PublishDiagnosticsParams;
import org.eclipse.lsp4j.ShowMessageRequestParams;

/**
 * Used to share compilation state and message callbacks between Language Server services.
 */
public interface LanguageServerState {

    CompilerWrapper getCompilerWrapper();

    void setCompilerWrapper(CompilerWrapper compilerWrapper);

    Consumer<MessageParams> getShowMessage();

    void setShowMessage(Consumer<MessageParams> callback);

    Consumer<ShowMessageRequestParams> getShowMessageRequest();

    void setShowMessageRequest(Consumer<ShowMessageRequestParams> callback);

    Consumer<MessageParams> getLogMessage();

    void setLogMessage(Consumer<MessageParams> callback);

    Consumer<Object> getTelemetryEvent();

    void setTelemetryEvent(Consumer<Object> callback);

    void setPublishDiagnostics(Consumer<PublishDiagnosticsParams> callback);

    void publishDiagnostics(Set<PublishDiagnosticsParams> diagnostics);

}
