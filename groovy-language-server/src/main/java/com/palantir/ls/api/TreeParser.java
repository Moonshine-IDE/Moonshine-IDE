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

import com.google.common.base.Optional;
import java.net.URI;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.SymbolInformation;

/**
 * Provides functionality to fulfill all symbol related Language Server requests.
 */
public interface TreeParser {

    /**
     * Parses all symbols.
     */
    void parseAllSymbols();

    /**
     * Returns a mapping from the URI of source file to symbols located within these source files.
     */
    Map<URI, Set<SymbolInformation>> getFileSymbols();

    /**
     * Returns a completion list for the given {@code uri} and {@code position}.
     */
    CompletionList getCompletion(URI uri, Position position);

    /**
     * Returns a mapping from the location of some referred class to a set of locations were they were referred.
     */
    Map<Location, Set<Location>> getReferences();

    /**
     * Returns the locations of the symbols that reference the symbol defined by the given params.
     * @param params the parameters used to filter down which symbol is referenced
     * @return the set of locations
     */
    Set<Location> findReferences(ReferenceParams params);

    /**
     * Returns the goto definition location of the given position if it exists.
     */
    Optional<Location> gotoDefinition(URI uri, Position position);

    /**
     * Returns a list of symbols filtered based on a wildcard query.
     *
     * The character * designates zero or more of any character. The character ? designates exactly one character.
     *
     * @param query the query
     * @return the set of symbols
     */
    Set<SymbolInformation> getFilteredSymbols(String query);

    default Pattern getQueryPattern(String query) {
        String escaped = Pattern.quote(query);
        String newQuery = escaped.replaceAll("\\*", "\\\\E.*\\\\Q").replaceAll("\\?", "\\\\E.\\\\Q");
        newQuery = "^" + newQuery;
        try {
            return Pattern.compile(newQuery);
        } catch (PatternSyntaxException e) {
            // sadness
        }
        return Pattern.compile("^" + escaped);
    }
}
