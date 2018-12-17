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

import java.net.URI;
import java.nio.file.Path;
import java.nio.file.Paths;

public final class Uris {

    private Uris() {}

    /**
     * Returns whether the given URI is a valid file URI.
     */
    public static boolean isFileUri(String uri) {
        try {
            Paths.get(URI.create(uri));
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Returns the absolute path of the given URI.
     */
    public static Path getAbsolutePath(String uri) {
        try {
            return Paths.get(URI.create(uri)).toAbsolutePath().normalize();
        } catch (Exception e) {
            return Paths.get(uri).toAbsolutePath().normalize();
        }
    }

    /**
     * Normalizes the given URI and resolves it on the given absoluteRootPath if it is not already an absolute path.
     * @throws IllegalArgumentException if absoluteRootPath is not an absolute path
     */
    public static URI resolveToRoot(Path absoluteRootPath, String uri) {
        checkArgument(absoluteRootPath.isAbsolute(), "absoluteRootPath must be absolute");
        if (isFileUri(uri)) {
            return getAbsolutePath(uri).toUri();
        } else {
            Path path = Paths.get(uri).normalize();
            return path.isAbsolute() ? path.toUri() : absoluteRootPath.resolve(path).toAbsolutePath().toUri();
        }
    }

}
