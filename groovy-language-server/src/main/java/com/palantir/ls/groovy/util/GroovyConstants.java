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

package com.palantir.ls.groovy.util;

import com.google.common.collect.Sets;
import java.util.Collections;
import java.util.Set;

public final class GroovyConstants {

    private GroovyConstants() {
        // constant class
    }

    public static final String GROOVY_COMPILER = "groovyc";
    public static final String GROOVY_LANGUAGE_NAME = "groovy";
    public static final String GROOVY_LANGUAGE_EXTENSION = "groovy";
    public static final String JAVA_LANGUAGE_EXTENSION = "java";
    public static final String JAVA_DEFAULT_OBJECT = "java.lang.Object";
    public static final Set<String> GROOVY_ALLOWED_EXTENSIONS =
            Collections.unmodifiableSet(Sets.newHashSet(GROOVY_LANGUAGE_EXTENSION, JAVA_LANGUAGE_EXTENSION));

}
