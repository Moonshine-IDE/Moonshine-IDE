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

import com.palantir.ls.util.Ranges;
import java.net.URI;
import org.codehaus.groovy.ast.ASTNode;
import org.codehaus.groovy.ast.ClassNode;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.Range;

public final class GroovyLocations {

    private GroovyLocations() {}

    /**
     * Creates a location from the given URI with an undefined range.
     */
    public static Location createLocation(URI uri) {
        return new Location(uri.toString(), Ranges.UNDEFINED_RANGE);
    }

    /**
     * Creates a location from the given URI and node's start and end positions.
     */
    public static Location createLocation(URI uri, ASTNode node) {
        return new Location(
                uri.toString(),
                Ranges.createZeroBasedRange(
                        node.getLineNumber(),
                        node.getColumnNumber(),
                        node.getLastLineNumber(),
                        node.getLastColumnNumber()));
    }

    /**
     * Creates a location which goes from the given node's starting position to at most one line after.
     */
    public static Location createClassDefinitionLocation(URI uri, ClassNode node) {
        Range range;
        // This takes care of the edge case where the class is defined on one line.
        if (node.getLineNumber() == node.getLastLineNumber()) {
            range = Ranges.createZeroBasedRange(node.getLineNumber(), node.getColumnNumber(), node.getLastLineNumber(),
                    node.getLastColumnNumber());
        } else {
            range = Ranges.createZeroBasedRange(node.getLineNumber(), node.getColumnNumber(),
                    Math.min(node.getLineNumber() + 1, node.getLastLineNumber()),
                    Math.min(1, node.getLastColumnNumber()));
        }
        return new Location(uri.toString(), range);
    }

}
