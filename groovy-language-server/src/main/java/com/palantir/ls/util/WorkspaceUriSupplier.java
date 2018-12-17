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

package com.palantir.ls.util;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;

import java.net.URI;
import java.nio.file.Path;
import java.nio.file.Paths;

public class WorkspaceUriSupplier implements UriSupplier {

    private final Path workspaceRoot;
    private final Path other;

    public WorkspaceUriSupplier(Path workspaceRoot, Path other) {
        checkNotNull(workspaceRoot, "workspaceRoot must not be null");
        checkNotNull(other, "other must not be null");
        checkArgument(workspaceRoot.toFile().isDirectory(), "workspaceRoot must be a directory");
        checkArgument(other.toFile().isDirectory(), "other must be a directory");
        this.workspaceRoot = workspaceRoot;
        this.other = other;
    }

    @Override
    public URI get(URI uri) {
        // In the case that it's already relative to the workspace, we still convert it into a Path
        // and then back into a URI to normalize the URI. Otherwise the URI could start with either
        // 'file:///' or 'file:/'. Now it will always start with 'file:///'.
        if (uri.getPath().startsWith(workspaceRoot.toString())) {
            return Paths.get(uri).toUri();
        }
        return workspaceRoot.resolve(other.relativize(Paths.get(uri))).toUri();
    }

}
