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

public class DefaultWorkspaceService extends AbstractWorkspaceService {
    private final LanguageServerState state;

    public DefaultWorkspaceService(LanguageServerState state) {
        this.state = state;
    }

    @Override
    protected LanguageServerState getState() {
        return state;
    }
}
