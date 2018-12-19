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

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkNotNull;

import com.google.common.base.Optional;
import com.google.common.base.Supplier;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.palantir.ls.api.TreeParser;
import com.palantir.ls.groovy.util.GroovyConstants;
import com.palantir.ls.groovy.util.GroovyLocations;
import com.palantir.ls.groovy.util.GroovySymbolInformations;
import com.palantir.ls.util.CompletionUtils;
import com.palantir.ls.util.Ranges;
import com.palantir.ls.util.UriSupplier;
import com.palantir.ls.util.Uris;
import edu.umd.cs.findbugs.annotations.SuppressFBWarnings;

import java.net.URI;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.codehaus.groovy.ast.ASTNode;
import org.codehaus.groovy.ast.ClassNode;
import org.codehaus.groovy.ast.FieldNode;
import org.codehaus.groovy.ast.MethodNode;
import org.codehaus.groovy.ast.Parameter;
import org.codehaus.groovy.ast.Variable;
import org.codehaus.groovy.ast.stmt.BlockStatement;
import org.codehaus.groovy.control.CompilationUnit;
import org.eclipse.lsp4j.CompletionList;
import org.eclipse.lsp4j.Hover;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.MarkedString;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.jsonrpc.messages.Either;

/**
 * Groovy implementation of the TreeParser. Depends on a supplier of a Groovy CompilationUnit.
 */
public final class GroovyTreeParser implements TreeParser {

    private static final String GROOVY_DEFAULT_INTERFACE = "groovy.lang.GroovyObject";

    private final Supplier<CompilationUnit> unitSupplier;
    private final Path workspaceRoot;
    private final UriSupplier uriSupplier;

    private Indexer indexer = new Indexer();

    private GroovyTreeParser(Supplier<CompilationUnit> unitSupplier, Path workspaceRoot,
            UriSupplier uriSupplier) {
        this.unitSupplier = unitSupplier;
        this.workspaceRoot = workspaceRoot;
        this.uriSupplier = uriSupplier;
    }

    /**
     * Creates a new instance of GroovyTreeParser.
     *
     * @param unitSupplier
     *        the supplier of compilation unit to be parsed
     * @param workspaceRoot
     *        the directory to compile
     * @param uriSupplier
     *        the provider use to resolve uris
     * @return the newly created GroovyTreeParser
     */
    @SuppressFBWarnings("PT_FINAL_TYPE_RETURN")
    public static GroovyTreeParser of(Supplier<CompilationUnit> unitSupplier, Path workspaceRoot,
            UriSupplier uriSupplier) {
        checkNotNull(unitSupplier, "unitSupplier must not be null");
        checkNotNull(workspaceRoot, "workspaceRoot must not be null");
        checkNotNull(uriSupplier, "uriSupplier must not be null");
        checkArgument(workspaceRoot.toFile().isDirectory(), "workspaceRoot must be a directory");

        return new GroovyTreeParser(unitSupplier, workspaceRoot, uriSupplier);
    }

    @Override
    public void parseAllSymbols() {
        Indexer newIndexer = new Indexer();
        CompilationUnit unit = unitSupplier.get();

        Map<String, Location> classes = Maps.newHashMap();
        unit.iterator().forEachRemaining(sourceUnit -> {
            sourceUnit.getAST().getClasses().forEach(clazz -> {
                classes.put(clazz.getName(), GroovyLocations.createClassDefinitionLocation(
                        uriSupplier.get(sourceUnit.getSource().getURI()), clazz));
            });
        });

        unit.iterator().forEachRemaining(sourceUnit -> {
            URI sourceUri = uriSupplier.get(sourceUnit.getSource().getURI());
            // This will iterate through all classes, interfaces and enums, including inner ones.
            sourceUnit.getAST().getClasses().forEach(clazz -> {
                if (!clazz.isScript()) {
                    // Add class symbol
                    SymbolInformation classSymbol = GroovySymbolInformations.createSymbolInformation(
                            clazz, sourceUri, 
                            Optional.fromNullable(clazz.getOuterClass()).transform(ClassNode::getName));
                    newIndexer.addSymbol(sourceUri, classSymbol, clazz);

                    // Add implemented interfaces reference
                    Stream.of(clazz.getInterfaces())
                            .filter(node -> !node.getName().equals(GROOVY_DEFAULT_INTERFACE)
                                    && classes.containsKey(node.getName()))
                            .forEach(node -> newIndexer.addReference(classes.get(node.getName()),
                                    GroovyLocations.createLocation(sourceUri, node)));
                    // Add extended class reference
                    if (clazz.getSuperClass() != null
                            && !clazz.getSuperClass().getName().equals(GroovyConstants.JAVA_DEFAULT_OBJECT)
                            && classes.containsKey(clazz.getSuperClass().getName())) {
                        newIndexer.addReference(classes.get(clazz.getSuperClass().getName()),
                                classSymbol.getLocation());
                    }
                }

                Map<String, FieldNode> classFields = Maps.newHashMap();
                // Add all the class's field symbols
                clazz.getFields().forEach(field -> {
                    SymbolInformation symbol = GroovySymbolInformations.createSymbolInformation(field, sourceUri, Optional.of(clazz.getName()));
                    newIndexer.addSymbol(sourceUri, symbol, field);
                    if (classes.containsKey(field.getType().getName())) {
                        newIndexer.addReference(classes.get(field.getType().getName()),
                                GroovyLocations.createLocation(sourceUri, field.getType()));
                        classFields.put(field.getName(), field);
                    }
                });

                // Add all method symbols
                clazz.getAllDeclaredMethods()
                        .forEach(method -> parseMethod(newIndexer, sourceUri, clazz, classes, classFields, method));
            });

            // Add symbols declared within the statement block variable scope which includes script
            // defined variables.
            ClassNode scriptClass = sourceUnit.getAST().getScriptClassDummy();
            if (scriptClass != null) {
                sourceUnit.getAST().getStatementBlock().getVariableScope().getDeclaredVariables().values().forEach(
                        variable -> {
                            SymbolInformation symbol =
                                GroovySymbolInformations.createSymbolInformation(variable, sourceUri, Optional.of(scriptClass.getName()));
                            newIndexer.addSymbol(sourceUnit.getSource().getURI(), symbol, (ASTNode) variable);
                            if (classes.containsKey(variable.getType().getName())) {
                                newIndexer.addReference(classes.get(variable.getType().getName()),
                                        GroovyLocations.createLocation(sourceUri, variable.getType()));
                            }
                        });
                sourceUnit.getAST().getStatementBlock()
                        .visit(new MethodVisitor(newIndexer, sourceUri, sourceUnit.getAST().getScriptClassDummy(),
                                classes, Maps.newHashMap(), Optional.absent(), uriSupplier));
            }
        });
        // Set the new indexer
        indexer = newIndexer;
    }

    @Override
    public Map<URI, Set<SymbolInformation>> getFileSymbols() {
        return indexer.getFileSymbols();
    }

    @Override
    public CompletionList getCompletion(URI uri, Position position) {
        return CompletionUtils.createCompletionListFromSymbols(getFileSymbols().get(uri));
    }

    @Override
    public Map<Location, Set<Location>> getReferences() {
        return indexer.getReferences();
    }

    @Override
    public Set<Location> findReferences(ReferenceParams params) {
        URI paramsUri = Uris.resolveToRoot(workspaceRoot, params.getTextDocument().getUri());
        Set<SymbolInformation> symbols = indexer.getFileSymbols().get(paramsUri);
        if (symbols == null) {
            return ImmutableSet.of();
        }
        List<ReferenceLocation> foundReferencedLocations = symbols.stream()
                .map(symbol -> symbol.getLocation())
                .filter(loc -> Ranges.isValid(loc.getRange())
                        && Ranges.contains(loc.getRange(), params.getPosition()))
                .map(loc -> new ReferenceLocation(loc, false))
                .collect(Collectors.toList());

        // It might be a location on top of a reference instead of a definition.
        // Ex: Test test; - clicking on Test
        Set<ReferenceLocation> locations =
                indexer.getGotoReferenced().keySet().stream()
                        .filter(loc -> paramsUri.toString().equals(loc.getUri())
                                && Ranges.isValid(loc.getRange())
                                && Ranges.contains(loc.getRange(), params.getPosition())
                                && indexer.gotoReferenced(loc).isPresent())
                        .map(loc -> new ReferenceLocation(loc, true))
                        .collect(Collectors.toSet());
        foundReferencedLocations.addAll(locations);

        if (foundReferencedLocations.isEmpty()) {
            return ImmutableSet.of();
        }

        foundReferencedLocations = foundReferencedLocations.stream()
                // If there is more than one result, we want the symbol whose range starts the latest, with a secondary
                // sort of earliest end range.
                .sorted((l1, l2) -> Ranges.POSITION_COMPARATOR.compare(l1.getLocation().getRange().getEnd(),
                        l2.getLocation().getRange().getEnd()))
                .sorted((l1, l2) -> Ranges.POSITION_COMPARATOR.reversed()
                        .compare(l1.getLocation().getRange().getStart(), l2.getLocation().getRange().getStart()))
                .collect(Collectors.toList());

        ReferenceLocation foundReferencedLocation = foundReferencedLocations.get(0);
        Set<Location> foundReferences;
        Location referredLocation = foundReferencedLocation.getLocation();
        if (foundReferencedLocation.getIsReferencedLocation()) {
            referredLocation = indexer.gotoReferenced(foundReferencedLocation.getLocation()).get();
            foundReferences =  indexer.findReferences(referredLocation).or(Sets.newHashSet());
        } else {
            foundReferences = indexer.findReferences(foundReferencedLocation.getLocation()).or(Sets.newHashSet());
        }

        if (params.getContext().isIncludeDeclaration()) {
            foundReferences.add(referredLocation);
        } else {
            foundReferences.remove(referredLocation);
        }

        return foundReferences;
    }

    @Override
    public Optional<Location> gotoDefinition(URI uri, Position position) {
        List<Location> possibleLocations = indexer.getGotoReferenced().keySet().stream()
                .filter(loc -> uri.equals(URI.create(loc.getUri())) && Ranges.contains(loc.getRange(), position))
                // If there is more than one result, we want the symbol whose range starts the latest, with a secondary
                // sort of earliest end range.
                .sorted((l1, l2) -> Ranges.POSITION_COMPARATOR.compare(l1.getRange().getEnd(), l2.getRange().getEnd()))
                .sorted((l1, l2) -> Ranges.POSITION_COMPARATOR.reversed().compare(l1.getRange().getStart(),
                        l2.getRange().getStart()))
                .collect(Collectors.toList());
        if (possibleLocations.isEmpty()) {
            return Optional.absent();
        }

        return indexer.gotoReferenced(possibleLocations.get(0));
    }

    @Override
    public Hover getHover(URI uri, Position position) {
        Hover hover = new Hover();

        List<Location> possibleLocations = indexer.getGotoReferenced().keySet().stream()
                .filter(loc -> uri.equals(URI.create(loc.getUri())) && Ranges.contains(loc.getRange(), position))
                // If there is more than one result, we want the symbol whose range starts the latest, with a secondary
                // sort of earliest end range.
                .sorted((l1, l2) -> Ranges.POSITION_COMPARATOR.compare(l1.getRange().getEnd(), l2.getRange().getEnd()))
                .sorted((l1, l2) -> Ranges.POSITION_COMPARATOR.reversed().compare(l1.getRange().getStart(),
                        l2.getRange().getStart()))
                .collect(Collectors.toList());
        if (possibleLocations.isEmpty()) {
            return hover;
        }

        Optional<ASTNode> optionalNode = indexer.gotoReferencedNode(possibleLocations.get(0));
        if(!optionalNode.isPresent()) {
            return hover;
        }

        List<Either<String, MarkedString>> contents = new ArrayList<>();
        hover.setContents(contents);
        ASTNode node = optionalNode.get();
        if(node instanceof ClassNode)
        {
            ClassNode classNode = (ClassNode) node;
            StringBuilder builder = new StringBuilder();
            if(!classNode.isSyntheticPublic())
            {
                builder.append("public ");
            }
            if(classNode.isAbstract())
            {
                builder.append("abstract ");
            }
            if(classNode.isInterface())
            {
                builder.append("interface ");
            }
            else if(classNode.isEnum())
            {
                builder.append("enum ");
            }
            else
            {
                builder.append("class ");
            }
            builder.append(classNode.getName());

            ClassNode superClass = classNode.getSuperClass();
            if(!superClass.getName().equals(GroovyConstants.JAVA_DEFAULT_OBJECT))
            {
                builder.append("extends ");
                builder.append(superClass.getNameWithoutPackage());
            }

            contents.add(Either.forLeft(builder.toString()));
        }
        else if(node instanceof MethodNode)
        {
            MethodNode methodNode = (MethodNode) node;
            StringBuilder builder = new StringBuilder();
            if(methodNode.isPublic())
            {
                if(!methodNode.isSyntheticPublic())
                {
                    builder.append("public ");
                }
            }
            else if(methodNode.isProtected())
            {
                builder.append("protected ");
            }
            else if(methodNode.isPrivate())
            {
                builder.append("private ");
            }

            if(methodNode.isStatic())
            {
                builder.append("static ");
            }
            
            if(methodNode.isFinal())
            {
                builder.append("final ");
            }
            ClassNode returnType = methodNode.getReturnType();
            builder.append(returnType.getNameWithoutPackage());
            builder.append(" ");
            builder.append(methodNode.getName());
            builder.append("(");
            Parameter[] params = methodNode.getParameters();
            for(int i = 0; i < params.length; i++)
            {
                if(i > 0)
                {
                    builder.append(", ");
                }
                Parameter paramNode = params[i];
                ClassNode paramType = paramNode.getType();
                builder.append(paramType.getNameWithoutPackage());
                builder.append(" ");
                builder.append(paramNode.getName());
            }
            builder.append(")");
            contents.add(Either.forLeft(builder.toString()));
        }
        else if(node instanceof Variable)
        {
            Variable varNode = (Variable) node;
            StringBuilder builder = new StringBuilder();
            if(varNode instanceof FieldNode)
            {
                FieldNode fieldNode = (FieldNode) node;
                if(fieldNode.isPublic())
                {
                    builder.append("public ");
                }
                if(fieldNode.isProtected())
                {
                    builder.append("protected ");
                }
                if(fieldNode.isPrivate())
                {
                    builder.append("private ");
                }

                if(fieldNode.isFinal())
                {
                    builder.append("final ");
                }

                if(fieldNode.isStatic())
                {
                    builder.append("static ");
                }
            }
            ClassNode varType = varNode.getType();
            builder.append(varType.getNameWithoutPackage());
            builder.append(" ");
            builder.append(varNode.getName());
            contents.add(Either.forLeft(builder.toString()));
        }
        else
        {
            System.err.println("*** " + node);
        }
        return hover;
    }

    @Override
    public Set<SymbolInformation> getFilteredSymbols(String query) {
        checkNotNull(query, "query must not be null");
        Pattern pattern = getQueryPattern(query);
        return indexer.getFileSymbols().values().stream().flatMap(Collection::stream)
                .filter(symbol -> pattern.matcher(symbol.getName()).matches())
                .collect(Collectors.toSet());
    }

    // sourceUri should already have been converted to a workspace URI
    private void parseMethod(Indexer newIndexer, URI sourceUri, ClassNode parent, Map<String, Location> classes,
            Map<String, FieldNode> classFields, MethodNode method) {
        SymbolInformation methodSymbol = GroovySymbolInformations.createSymbolInformation(
                method, sourceUri, Optional.of(parent.getName()));
        newIndexer.addSymbol(sourceUri, methodSymbol, method);
        newIndexer.addReference(GroovyLocations.createLocation(sourceUri, method),
                GroovyLocations.createLocation(sourceUri, method));

        // Method parameters
        method.getVariableScope().getDeclaredVariables().values().forEach(variable -> {
            SymbolInformation variableSymbol = GroovySymbolInformations.createSymbolInformation(variable, sourceUri, Optional.of(method.getName()));
            newIndexer.addSymbol(sourceUri, variableSymbol, (ASTNode) variable);
            newIndexer.addReference(GroovyLocations.createLocation(sourceUri, (ASTNode) variable),
                    GroovyLocations.createLocation(sourceUri, (ASTNode) variable));
            if (classes.containsKey(variable.getType().getName())) {
                newIndexer.addReference(classes.get(variable.getType().getName()),
                        GroovyLocations.createLocation(sourceUri, variable.getType()));
            }
        });

        // Return type
        if (classes.containsKey(method.getReturnType().getName())) {
            newIndexer.addReference(classes.get(method.getReturnType().getName()),
                    GroovyLocations.createLocation(sourceUri, method.getReturnType()));
        }

        // We only want to visit the method if its not generated
        if (Ranges.isValid(methodSymbol.getLocation().getRange())) {
            // Visit the method
            if (method.getCode() instanceof BlockStatement) {
                BlockStatement blockStatement = (BlockStatement) method.getCode();
                blockStatement.visit(new MethodVisitor(newIndexer, sourceUri, parent, classes, classFields,
                        Optional.of(method), uriSupplier));
            }
        }
    }

    private static class ReferenceLocation {

        private final Location location;
        private final boolean isReferencedLocation;

        ReferenceLocation(Location location, boolean isReferencedLocation) {
            this.location = location;
            this.isReferencedLocation = isReferencedLocation;
        }

        Location getLocation() {
            return location;
        }

        boolean getIsReferencedLocation() {
            return isReferencedLocation;
        }

    }

}
