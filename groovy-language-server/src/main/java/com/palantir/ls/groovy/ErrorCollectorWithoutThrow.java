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

import org.codehaus.groovy.control.CompilationFailedException;
import org.codehaus.groovy.control.CompilerConfiguration;
import org.codehaus.groovy.control.ErrorCollector;

/**
 * An ErrorCollector that does not throw errors so that it works better with
 * code intelligence in IDEs.
 */
public class ErrorCollectorWithoutThrow extends ErrorCollector {

    public ErrorCollectorWithoutThrow(CompilerConfiguration configuration) {
        super(configuration);
	}

    @Override
    protected void failIfErrors() throws CompilationFailedException {
        //don't fail
    }
}
