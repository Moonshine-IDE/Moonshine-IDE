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

import com.google.common.base.Optional;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.palantir.ls.util.Ranges;
import java.net.URI;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.codehaus.groovy.ast.ASTNode;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.Range;
import org.eclipse.lsp4j.SymbolInformation;

public class Indexer {

    private final Map<Location, Set<Location>> references = Maps.newHashMap();
    private final Map<Location, Location> gotoReferenced = Maps.newHashMap();
    // Maps from source file path -> set of symbols in that file
    private final Map<URI, Set<SymbolInformation>> fileSymbols = Maps.newHashMap();
    private final Map<SymbolInformation, ASTNode> fileASTNodes = Maps.newHashMap();

    public void addSymbol(URI uri, SymbolInformation symbol, ASTNode node) {
        fileSymbols.computeIfAbsent(uri, k -> Sets.newHashSet()).add(symbol);
        fileASTNodes.put(symbol, node);
    }

    public void addReference(Location referenced, Location node) {
        if (Ranges.isValid(referenced.getRange()) && Ranges.isValid(node.getRange())) {
            references.computeIfAbsent(referenced, k -> Sets.newHashSet()).add(node);
            gotoReferenced.put(node, referenced);
        }
    }

    public Optional<Set<Location>> findReferences(Location location) {
        return Optional.fromNullable(references.get(location));
    }

    public Optional<Location> gotoReferenced(Location location) {
        return Optional.fromNullable(gotoReferenced.get(location));
    }

    public Optional<ASTNode> gotoReferencedNode(Location location) {
        Optional<Location> optionalLocation = gotoReferenced(location);
        if(!optionalLocation.isPresent())
        {
            return Optional.absent();
        }
        Location referencedLocation = optionalLocation.get();
        URI uri = URI.create(referencedLocation.getUri());
        return getASTNode(uri, referencedLocation.getRange().getStart());
    }

    public Optional<SymbolInformation> getSymbol(URI uri, Position position) {
        if(!fileSymbols.containsKey(uri)) {
            return Optional.absent();
        }
        Set<SymbolInformation> symbols = fileSymbols.get(uri);
        if(symbols.isEmpty()) {
            return Optional.absent();
        }
        List<SymbolInformation> filteredSymbols = symbols.stream().filter(symbol -> {
            Range range = symbol.getLocation().getRange();
            if(!Ranges.isValid(range)) {
                return false;
            }
            return Ranges.contains(symbol.getLocation().getRange(), position);
        })
        // If there is more than one result, we want the symbol whose range starts the latest, with a secondary
        // sort of earliest end range.
        .sorted((s1, s2) -> Ranges.POSITION_COMPARATOR.compare(
                s1.getLocation().getRange().getEnd(),
                s2.getLocation().getRange().getEnd()))
        .sorted((s1, s2) -> Ranges.POSITION_COMPARATOR.reversed().compare(
                s1.getLocation().getRange().getStart(),
                s2.getLocation().getRange().getStart()))
        .collect(Collectors.toList());
        if(filteredSymbols.isEmpty()) {
            return Optional.absent();
        }
        return Optional.of(filteredSymbols.iterator().next());
    }

    public Optional<ASTNode> getASTNode(URI uri, Position position) {
        Optional<SymbolInformation> optionalSymbol = getSymbol(uri, position);
        if(!optionalSymbol.isPresent()) {
            return Optional.absent();
        }
        SymbolInformation symbol = optionalSymbol.get();
        if(!fileASTNodes.containsKey(symbol)) {
            return Optional.absent();
        }
        ASTNode node = fileASTNodes.get(symbol);
        return Optional.of(node);
    }

    public Map<URI, Set<SymbolInformation>> getFileSymbols() {
        return fileSymbols;
    }

    public Map<Location, Set<Location>> getReferences() {
        return references;
    }

    public Map<Location, Location> getGotoReferenced() {
        return gotoReferenced;
    }

}
