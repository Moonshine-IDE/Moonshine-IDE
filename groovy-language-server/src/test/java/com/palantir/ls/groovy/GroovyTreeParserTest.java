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

import static org.assertj.core.api.Assertions.assertThat;
import static org.junit.Assert.assertEquals;

import com.google.common.base.Optional;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Sets;
import com.palantir.ls.util.Ranges;
import com.palantir.ls.util.SimpleUriSupplier;
import com.palantir.ls.util.UriSupplier;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Collection;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.Position;
import org.eclipse.lsp4j.Range;
import org.eclipse.lsp4j.ReferenceContext;
import org.eclipse.lsp4j.ReferenceParams;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.SymbolKind;
import org.eclipse.lsp4j.TextDocumentIdentifier;
import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.junit.rules.TemporaryFolder;

public class GroovyTreeParserTest {

    private static final Set<SymbolInformation> NO_SYMBOLS = Sets.newHashSet();
    private static final Set<Location> NO_REFERENCES = Sets.newHashSet();

    @Rule
    public ExpectedException expectedException = ExpectedException.none();
    @Rule
    public TemporaryFolder tempFolder = new TemporaryFolder();

    private UriSupplier uriSupplier;

    private GroovyTreeParser parser;
    private File workspaceRoot;

    @Before
    public void setup() throws IOException {
        workspaceRoot = tempFolder.newFolder();
        Path target = tempFolder.newFolder().toPath();
        uriSupplier = new SimpleUriSupplier();
        parser = GroovyTreeParser.of(() -> {
            GroovyWorkspaceCompiler compiler =
                    GroovyWorkspaceCompiler.of(target, workspaceRoot.toPath());
            assertEquals(Sets.newHashSet(), compiler.compile(ImmutableSet.of()));
            return compiler.get();
        }, workspaceRoot.toPath(), uriSupplier);
    }

    @Test
    public void testWorkspaceRootNotFolder() throws IOException {
        expectedException.expect(IllegalArgumentException.class);
        expectedException.expectMessage("workspaceRoot must be a directory");
        GroovyTreeParser.of(() -> null, tempFolder.newFile().toPath(), uriSupplier);
    }

    @Test
    public void testNotParsedYet() throws IOException {
        assertEquals(NO_SYMBOLS,
                parser.getFileSymbols().values().stream().flatMap(Collection::stream).collect(Collectors.toSet()));
    }

    @Test
    public void testComputeAllSymbols_class() throws InterruptedException, ExecutionException, IOException {
        File file = addFileToFolder(workspaceRoot, "someFolder", "Coordinates.groovy",
                "class Coordinates {\n"
                        + "   double latitude\n"
                        + "   double longitude\n"
                        + "   def name = \"Natacha\"\n"
                        + "   double getAt(int idx1, int idx2) {\n"
                        + "      def someString = \"Also in symbols\"\n"
                        + "      println someString\n"
                        + "      if (idx1 == 0) latitude\n"
                        + "      else if (idx1 == 1) longitude\n"
                        + "      else throw new Exception(\"Wrong coordinate index, use 0 or 1 \")\n"
                        + "   }\n"
                        + "}\n");
        parser.parseAllSymbols();

        Map<URI, Set<SymbolInformation>> symbols = parser.getFileSymbols();

        // Assert that the format of the URI doesn't change the result (i.e whether it starts with file:/ or file:///)
        assertEquals(parser.getFileSymbols().get(file.toURI()), parser.getFileSymbols().get(file.toPath().toUri()));

        // The symbols will contain a lot of inherited fields and methods, so we just check to make sure it contains our
        // custom fields and methods.
        assertThat(mapHasSymbol(symbols, Optional.absent(), "Coordinates", SymbolKind.Class)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "getAt", SymbolKind.Method)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "latitude", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "longitude", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "name", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("getAt"), "idx1", SymbolKind.Variable)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("getAt"), "idx2", SymbolKind.Variable)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("getAt"), "someString", SymbolKind.Variable)).isTrue();
    }

    @Test
    public void testComputeAllSymbols_interface() throws InterruptedException, ExecutionException, IOException {
        addFileToFolder(workspaceRoot, "my/folder", "ICoordinates.groovy",
                "interface ICoordinates {\n"
                        + "   abstract double getAt(int idx);\n"
                        + "}\n");
        parser.parseAllSymbols();

        Map<URI, Set<SymbolInformation>> symbols = parser.getFileSymbols();
        // The symbols will contain a lot of inherited and default fields and methods, so we just check to make sure it
        // contains our custom fields and methods.
        assertThat(mapHasSymbol(symbols, Optional.absent(), "ICoordinates", SymbolKind.Interface)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("ICoordinates"), "getAt", SymbolKind.Method)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("getAt"), "idx", SymbolKind.Variable)).isTrue();
    }

    @Test
    public void testComputeAllSymbols_enum() throws InterruptedException, ExecutionException, IOException {
        addFileToFolder(workspaceRoot, "Type.groovy",
                "enum Type {\n"
                        + "   ONE, TWO, THREE\n"
                        + "}\n");
        parser.parseAllSymbols();

        Map<URI, Set<SymbolInformation>> symbols = parser.getFileSymbols();
        // The symbols will contain a lot of inherited and default fields and methods, so we just check to make sure it
        // contains our custom fields and methods.
        assertThat(mapHasSymbol(symbols, Optional.absent(), "Type", SymbolKind.Enum)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Type"), "ONE", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Type"), "TWO", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Type"), "THREE", SymbolKind.Field)).isTrue();
    }

    @Test
    public void testComputeAllSymbols_innerClassInterfaceEnum()
            throws InterruptedException, ExecutionException, IOException {
        addFileToFolder(workspaceRoot, "foo", "Coordinates.groovy",
                "class Coordinates {\n"
                        + "   double latitude\n"
                        + "   double longitude\n"
                        + "   def name = \"Natacha\"\n"
                        + "   double getAt(int idx) {\n"
                        + "      def someString = \"Also in symbols\"\n"
                        + "      if (idx == 0) latitude\n"
                        + "      else if (idx == 1) longitude\n"
                        + "      else throw new Exception(\"Wrong coordinate index, use 0 or 1 \")\n"
                        + "   }\n"
                        + "   class MyInnerClass {}\n"
                        + "   interface MyInnerInterface{}\n"
                        + "   enum MyInnerEnum{\n"
                        + "      ONE, TWO\n"
                        + "   }\n"
                        + "}\n");
        parser.parseAllSymbols();

        Map<URI, Set<SymbolInformation>> symbols = parser.getFileSymbols();
        // The symbols will contain a lot of inherited fields and methods, so we just check to make sure it contains our
        // custom fields and methods.
        assertThat(mapHasSymbol(symbols, Optional.absent(), "Coordinates", SymbolKind.Class)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "getAt", SymbolKind.Method)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "latitude", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "longitude", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "name", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "Coordinates$MyInnerClass", SymbolKind.Class))
                .isTrue();
        assertThat(
                mapHasSymbol(symbols, Optional.of("Coordinates"), "Coordinates$MyInnerInterface", SymbolKind.Interface))
                .isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates"), "Coordinates$MyInnerEnum", SymbolKind.Enum))
                .isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates$MyInnerEnum"), "ONE", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("Coordinates$MyInnerEnum"), "TWO", SymbolKind.Field)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("getAt"), "idx", SymbolKind.Variable)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("getAt"), "someString", SymbolKind.Variable)).isTrue();
    }

    @Test
    public void testComputeAllSymbols_script()
            throws InterruptedException, ExecutionException, IOException {
        addFileToFolder(workspaceRoot, "test.groovy",
                "def name = \"Natacha\"\n"
                        + "def myMethod() {\n"
                        + "   def someString = \"Also in symbols\"\n"
                        + "   println \"Hello World\"\n"
                        + "}\n"
                        + "println name\n"
                        + "myMethod()\n");
        parser.parseAllSymbols();

        Map<URI, Set<SymbolInformation>> symbols = parser.getFileSymbols();
        assertThat(mapHasSymbol(symbols, Optional.of("test"), "myMethod", SymbolKind.Method)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("test"), "name", SymbolKind.Variable)).isTrue();
        assertThat(mapHasSymbol(symbols, Optional.of("myMethod"), "someString", SymbolKind.Variable)).isTrue();
    }

    @Test
    public void testGetFilteredSymbols() throws InterruptedException, ExecutionException, IOException {
        File coordinatesFiles = addFileToFolder(workspaceRoot, "Coordinates.groovy",
                "class Coordinates implements ICoordinates {\n"
                        + "   double latitude\n"
                        + "   double longitude\n"
                        + "   double longitude2\n"
                        + "   private double CoordinatesVar\n"
                        + "   double getAt(int idx) {\n"
                        + "      def someString = \"Also in symbols\"\n"
                        + "      if (idx == 0) latitude\n"
                        + "      else if (idx == 1) longitude\n"
                        + "      else throw new Exception(\"Wrong coordinate index, use 0 or 1 \")\n"
                        + "   }\n"
                        + "}\n");
        File icoordinatesFiles = addFileToFolder(workspaceRoot, "foo/folder", "ICoordinates.groovy",
                "interface ICoordinates {\n"
                        + "   abstract double getAt(int idx);\n"
                        + "}\n");
        parser.parseAllSymbols();

        Set<SymbolInformation> filteredSymbols = parser.getFilteredSymbols("Coordinates");
        assertEquals(Sets.newHashSet(new SymbolInformation(
                        "Coordinates",
                        SymbolKind.Class,
                        createLocation(coordinatesFiles.toPath(), Ranges.createRange(0, 0, 1, 0)))),
                filteredSymbols);

        filteredSymbols = parser.getFilteredSymbols("Coordinates*");
        assertEquals(Sets.newHashSet(
                new SymbolInformation(
                        "Coordinates",
                        SymbolKind.Class,
                        createLocation(coordinatesFiles.toPath(), Ranges.createRange(0, 0, 1, 0))),
                new SymbolInformation(
                        "CoordinatesVar",
                        SymbolKind.Field,
                        createLocation(coordinatesFiles.toPath(), Ranges.createRange(4, 3, 4, 32)),
                        "Coordinates")),
                filteredSymbols);

        filteredSymbols = parser.getFilteredSymbols("Coordinates?");
        assertEquals(NO_SYMBOLS, filteredSymbols);

        filteredSymbols = parser.getFilteredSymbols("*Coordinates*");
        assertThat(filteredSymbols).containsExactlyInAnyOrder(
                new SymbolInformation(
                        "Coordinates",
                        SymbolKind.Class,
                        createLocation(coordinatesFiles.toPath(), Ranges.createRange(0, 0, 1, 0))),
                new SymbolInformation(
                        "ICoordinates",
                        SymbolKind.Interface,
                        createLocation(icoordinatesFiles.toPath(), Ranges.createRange(0, 0, 1, 0))),
                new SymbolInformation(
                        "CoordinatesVar",
                        SymbolKind.Field,
                        createLocation(coordinatesFiles.toPath(), Ranges.createRange(4, 3, 4, 32)),
                        "Coordinates"));

        filteredSymbols = parser.getFilteredSymbols("Coordinates???");
        assertEquals(Sets.newHashSet(
                new SymbolInformation(
                        "CoordinatesVar",
                        SymbolKind.Field,
                        createLocation(coordinatesFiles.toPath(), Ranges.createRange(4, 3, 4, 32)),
                        "Coordinates")),
                filteredSymbols);
        filteredSymbols = parser.getFilteredSymbols("Coordinates...");
        assertEquals(NO_SYMBOLS, filteredSymbols);
        filteredSymbols = parser.getFilteredSymbols("*Coordinates...*");
        assertEquals(NO_SYMBOLS, filteredSymbols);
        filteredSymbols = parser.getFilteredSymbols("*Coordinates.??*");
        assertEquals(NO_SYMBOLS, filteredSymbols);
    }

    @Test
    public void testReferences_typeInnerClass() throws IOException {
        // edge cases, intersecting ranges
        File file = addFileToFolder(workspaceRoot, "foo", "Dog.groovy",
                "class Dog {\n"
                        + "   Cat friend1;\n"
                        + "   Cat2 friend2;\n"
                        + "   Cat bark(Cat enemy) {\n"
                        + "      println \"Bark! \" + enemy.name\n"
                        + "      return friend1\n"
                        + "   }\n"
                        + "}\n"
                        + "class Cat {\n"
                        + "   public String name = \"Bobby\"\n"
                        + "}\n"
                        + "class Cat2 {\n"
                        + "   InnerCat2 myFriend;\n"
                        + "   class InnerCat2 {\n"
                        + "   }\n"
                        + "}\n");
        parser.parseAllSymbols();

        // Right before "Cat", therefore should not find any symbol
        assertEquals(NO_REFERENCES, parser.findReferences(createReferenceParams(file.toURI(), 7, 0, false)));
        // Right after "Cat", therefore should not find any symbol
        assertEquals(NO_REFERENCES, parser.findReferences(createReferenceParams(file.toURI(), 10, 2, false)));

        // InnerCat2 references - testing finding more specific symbols that are contained inside another symbol's
        // range.
        Set<Location> expectedResult =
                Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(12, 3, 12, 12)));
        assertEquals(expectedResult, parser.findReferences(createReferenceParams(file.toURI(), 13, 9, false)));
    }

    @Test
    public void testReferences_typeEnumOneLine() throws IOException {
        // edge case on one line
        File enumFile = addFileToFolder(workspaceRoot, "MyEnum.groovy",
                "enum MyEnum {ONE,TWO}\n");
        File scriptFile = addFileToFolder(workspaceRoot, "MyScript.groovy",
                "MyEnum a\n\n");
        parser.parseAllSymbols();

        // Find one line enum correctly
        Set<Location> myEnumExpectedResult = Sets.newHashSet(
                        createLocation(scriptFile.toPath(), Ranges.createRange(0, 0, 0, 6)));
        assertEquals(myEnumExpectedResult,
                parser.findReferences(createReferenceParams(enumFile.toURI(), 0, 6, false)));
    }

    @Test
    public void testReferences_typeInnerClassOneLine() throws IOException {
        // edge case on one line
        File innerClass = addFileToFolder(workspaceRoot, "AandB.groovy",
                "public class A {public static class B {}\n"
                        + "A a\n"
                        + "B b\n"
                        + "}\n");
        parser.parseAllSymbols();

        // Identify type A correctly
        Set<Location> typeAExpectedResult = Sets.newHashSet(
                        createLocation(innerClass.toPath(), Ranges.createRange(1, 0, 1, 1)));
        assertEquals(typeAExpectedResult,
                parser.findReferences(createReferenceParams(innerClass.toURI(), 0, 6, false)));
        // Identify type B correctly
        Set<Location> typeBExpectedResult = Sets.newHashSet(
                        createLocation(innerClass.toPath(), Ranges.createRange(2, 0, 2, 1)));
        assertEquals(typeBExpectedResult,
                parser.findReferences(createReferenceParams(innerClass.toURI(), 0, 17, false)));
    }

    @Test
    public void testReferences_typeClassesAndInterfaces() throws InterruptedException, ExecutionException, IOException {
        File extendedcoordinatesFile = addFileToFolder(workspaceRoot, "ExtendedCoordinates.groovy",
                "class ExtendedCoordinates extends Coordinates{\n"
                        + "   void somethingElse() {\n"
                        + "      println \"Hi again!\"\n"
                        + "   }\n"
                        + "}\n");
        File extendedCoordinates2File = addFileToFolder(workspaceRoot, "ExtendedCoordinates2.groovy",
                "class ExtendedCoordinates2 extends Coordinates{\n"
                        + "   void somethingElse() {\n"
                        + "      println \"Hi again!\"\n"
                        + "   }\n"
                        + "}\n");
        File coordinatesFile = addFileToFolder(workspaceRoot, "Coordinates.groovy",
                "class Coordinates extends AbstractCoordinates implements ICoordinates {\n"
                        + "   double latitude\n"
                        + "   double longitude\n"
                        + "   double longitude2\n"
                        + "   private double CoordinatesVar\n"
                        + "   double getAt(int idx) {\n"
                        + "      def someString = \"Also in symbols\"\n"
                        + "      if (idx == 0) latitude\n"
                        + "      else if (idx == 1) longitude\n"
                        + "      else throw new Exception(\"Wrong coordinate index, use 0 or 1 \")\n"
                        + "   }\n"
                        + "   void superInterfaceMethod() {\n"
                        + "      Coordinates myCoordinate\n"
                        + "      println \"Hi!\"\n"
                        + "   }\n"
                        + "   void something() {\n"
                        + "      println \"Hi!\"\n"
                        + "   }\n"
                        + "}\n");
        File icoordinatesFile = addFileToFolder(workspaceRoot, "foo1", "ICoordinates.groovy",
                "interface ICoordinates extends ICoordinatesSuper{\n"
                        + "   abstract double getAt(int idx);\n"
                        + "}\n");
        File icoordinatesSuperFile = addFileToFolder(workspaceRoot, "foo2", "ICoordinatesSuper.groovy",
                "interface ICoordinatesSuper {\n"
                        + "   abstract void superInterfaceMethod()\n"
                        + "}\n");
        File abstractcoordinatesFile = addFileToFolder(workspaceRoot, "foo3", "AbstractCoordinates.groovy",
                "abstract class AbstractCoordinates {\n"
                        + "   abstract void something();\n"
                        + "}\n");
        parser.parseAllSymbols();

        // ExtendedCoordinates should have no references
        assertEquals(NO_REFERENCES,
                parser.findReferences(createReferenceParams(extendedcoordinatesFile.toURI(), 0, 7, false)));
        // ExtendedCoordinates2 should have no references
        assertEquals(NO_REFERENCES,
                parser.findReferences(createReferenceParams(extendedCoordinates2File.toURI(), 0, 7, false)));

        // Coordinates is only referenced in ExtendedCoordinates and ExtendedCoordinates2
        Set<Location> coordinatesExpectedResult = Sets.newHashSet(
                createLocation(extendedcoordinatesFile.toPath(), Ranges.createRange(0, 0, 1, 0)),
                createLocation(extendedCoordinates2File.toPath(), Ranges.createRange(0, 0, 1, 0)),
                createLocation(coordinatesFile.toPath(), Ranges.createRange(12, 6, 12, 17)),
                createLocation(extendedcoordinatesFile.toPath(), Ranges.createRange(12, 6, 12, 17)),
                createLocation(extendedCoordinates2File.toPath(), Ranges.createRange(12, 6, 12, 17)));
        assertEquals(coordinatesExpectedResult,
                parser.findReferences(createReferenceParams(coordinatesFile.toURI(), 0, 9, false)));

        // ICoordinates is only referenced in Coordinates
        Set<Location> icoordinatesExpectedResult = Sets.newHashSet(
                createLocation(coordinatesFile.toPath(), Ranges.createRange(0, 57, 0, 69)));
        assertEquals(icoordinatesExpectedResult,
                parser.findReferences(createReferenceParams(icoordinatesFile.toURI(), 0, 14, false)));

        // AbstractCoordinates is only referenced in Coordinates
        Set<Location> abstractCoordinatesExpectedResult = Sets.newHashSet(
                        createLocation(coordinatesFile.toPath(), Ranges.createRange(0, 0, 1, 0)));
        assertEquals(abstractCoordinatesExpectedResult,
                parser.findReferences(createReferenceParams(abstractcoordinatesFile.toURI(), 0, 19, false)));

        // ICoordinatesSuper is only referenced in ICoordinates
        Set<Location> icoordinatesSuperExpectedResult = Sets.newHashSet(
                        createLocation(icoordinatesFile.toPath(), Ranges.createRange(0, 31, 0, 48)));
        assertEquals(icoordinatesSuperExpectedResult,
                parser.findReferences(createReferenceParams(icoordinatesSuperFile.toURI(), 0, 13, false)));
    }

    @Test
    public void testReferences_typeFields() throws IOException {
        File dogFile = addFileToFolder(workspaceRoot, "Dog.groovy",
                "class Dog {\n"
                        + "   Cat friend1;\n"
                        + "   Cat friend2;\n"
                        + "   Cat bark(Cat enemy) {\n"
                        + "      Cat myCat\n"
                        + "      println \"Bark! \" + enemy.name\n"
                        + "      return friend1\n"
                        + "   }\n"
                        + "}\n");

        File catFile = addFileToFolder(workspaceRoot, "Cat.groovy",
                "class Cat {\n"
                        + "   public String name = \"Bobby\"\n"
                        + "}\n");
        parser.parseAllSymbols();

        // Dog should have no references
        assertEquals(NO_REFERENCES, parser.findReferences(createReferenceParams(dogFile.toURI(), 0, 7, false)));

        Set<Location> expectedResult = Sets.newHashSet(
                createLocation(dogFile.toPath(), Ranges.createRange(1, 3, 1, 6)),
                createLocation(dogFile.toPath(), Ranges.createRange(2, 3, 2, 6)),
                createLocation(dogFile.toPath(), Ranges.createRange(3, 3, 3, 6)),
                createLocation(dogFile.toPath(), Ranges.createRange(3, 12, 3, 15)),
                createLocation(dogFile.toPath(), Ranges.createRange(4, 6, 4, 9)));
        assertEquals(expectedResult,
                parser.findReferences(createReferenceParams(catFile.toURI(), 0, 7, false)));
    }

    @Test
    public void testReferences_typeEnum() throws IOException {
        File scriptFile = addFileToFolder(workspaceRoot, "MyScript.groovy",
                "Animal friend = Animal.CAT;\n"
                        + "pet(friend1)\n"
                        + "Animal pet(Animal animal) {\n"
                        + "   Animal myAnimal\n"
                        + "   println \"Pet the \" + animal\n"
                        + "   return animal\n"
                        + "}\n"
                        + "\n");
        File animalFile = addFileToFolder(workspaceRoot, "Animal.groovy",
                "enum Animal {\n"
                        + "CAT, DOG, BUNNY\n"
                        + "}\n");
        parser.parseAllSymbols();

        Set<Location> expectedResult = Sets.newHashSet(
                createLocation(scriptFile.toPath(), Ranges.createRange(0, 0, 0, 6)),
                createLocation(scriptFile.toPath(), Ranges.createRange(0, 16, 0, 22)),
                createLocation(scriptFile.toPath(), Ranges.createRange(2, 0, 2, 6)),
                createLocation(scriptFile.toPath(), Ranges.createRange(2, 11, 2, 17)),
                createLocation(scriptFile.toPath(), Ranges.createRange(3, 3, 3, 9)));

        assertEquals(expectedResult, parser.findReferences(createReferenceParams(animalFile.toURI(), 0, 5, false)));
    }

    @Test
    public void testReferences_script() throws IOException {
        File scriptFile = addFileToFolder(workspaceRoot, "MyScript.groovy",
                "Cat friend1;\n"
                        + "bark(friend1)\n"
                        + "Cat bark(Cat enemy) {\n"
                        + "   Cat myCat\n"
                        + "   println \"Bark! \"\n"
                        + "   return enemy\n"
                        + "}\n"
                        + "\n");
        File catFile = addFileToFolder(workspaceRoot, "Cat.groovy",
                "class Cat {\n"
                        + "}\n");
        parser.parseAllSymbols();

        Set<Location> expectedReferences = Sets.newHashSet(
                createLocation(scriptFile.toPath(), Ranges.createRange(0, 0, 0, 3)),
                createLocation(scriptFile.toPath(), Ranges.createRange(2, 0, 2, 3)),
                createLocation(scriptFile.toPath(), Ranges.createRange(2, 9, 2, 12)),
                createLocation(scriptFile.toPath(), Ranges.createRange(3, 3, 3, 6)));
        // Get references to object Cat, when clicking on its definition
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(catFile.toURI(), 0, 6, false)));
        // Get references to object Cat, when clicking on its usage
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 0, 2, false)));
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 2, 2, false)));
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 2, 10, false)));
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 3, 4, false)));

        expectedReferences = Sets.newHashSet(
                createLocation(scriptFile.toPath(), Ranges.createRange(1, 5, 1, 12)));
        // Get references to friend1, when clicking on its definition
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 0, 9, false)));
        // Get references to friend1, when clicking on its usage
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 1, 9, false)));

        // Find reference to enemy
        expectedReferences = Sets.newHashSet(
                createLocation(scriptFile.toPath(), Ranges.createRange(2, 9, 2, 12)),
                createLocation(scriptFile.toPath(), Ranges.createRange(2, 0, 2, 3)),
                createLocation(scriptFile.toPath(), Ranges.createRange(3, 3, 3, 6)),
                createLocation(scriptFile.toPath(), Ranges.createRange(0, 0, 0, 3)));
        // Get references to object Cat, when clicking on its definition
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(catFile.toURI(), 0, 5, false)));
        // Get references to object Cat, when clicking on its usage
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 2, 2, false)));
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 2, 10, false)));
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 3, 5, false)));
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 0, 2, false)));
    }

    @Test
    public void testReferences_includeDeclaration() throws IOException {
        File scriptFile = addFileToFolder(workspaceRoot, "MyScript.groovy",
                "Cat friend1;\n"
                        + "bark(friend1)\n"
                        + "Cat bark(Cat enemy) {\n"
                        + "   Cat myCat\n"
                        + "   println \"Bark! \"\n"
                        + "   return enemy\n"
                        + "}\n"
                        + "\n");
        File catFile = addFileToFolder(workspaceRoot, "Cat.groovy",
                "public class Cat {\n"
                + "   public static int foo = 10"
                        + "}\n");
        parser.parseAllSymbols();

        Set<Location> expectedReferences = Sets.newHashSet(
                createLocation(scriptFile.toPath(), Ranges.createRange(0, 0, 0, 3)),
                createLocation(scriptFile.toPath(), Ranges.createRange(2, 0, 2, 3)),
                createLocation(scriptFile.toPath(), Ranges.createRange(2, 9, 2, 12)),
                createLocation(scriptFile.toPath(), Ranges.createRange(3, 3, 3, 6)),
                createLocation(catFile.toPath(), Ranges.createRange(0, 0, 1, 0)));
        // Get references to object Cat, when clicking on its definition
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(catFile.toURI(), 0, 6, true)));
         // Get references to object Cat, when clicking on its usage
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 0, 2, true)));

        expectedReferences = Sets.newHashSet(
                createLocation(scriptFile.toPath(), Ranges.createRange(1, 5, 1, 12)),
                createLocation(scriptFile.toPath(), Ranges.createRange(0, 4, 0, 11)));
        // Get references to variable friend1
        assertEquals(expectedReferences,
                parser.findReferences(createReferenceParams(scriptFile.toURI(), 0, 9, true)));
    }

    @Test
    public void testReferences_staticMethod() throws IOException {
        File file = addFileToFolder(workspaceRoot, "OuterClass.groovy",
                "class OuterClass {\n"
                        + "   static InnerClass someStaticField\n"
                        + "   static class InnerClass {\n"
                        + "      void myICNonStaticMethod() {}\n"
                        + "      static void myICStaticMethod() {}\n"
                        + "   }\n"
                        + "   static int test2() {\n"
                        + "      return 0\n"
                        + "   }\n"
                        + "   static int test3() {\n" // Calling methods from a static context
                        + "      InnerClass localField = new InnerClass()\n"
                        + "      someStaticField.myICNonStaticMethod()\n"
                        + "      new InnerClass().myICNonStaticMethod()\n"
                        + "      localField.myICNonStaticMethod()\n"
                        + "      InnerClass.myICStaticMethod()\n"
                        + "      return 1 + test2()\n"
                        + "   }\n"
                        + "}\n");
        parser.parseAllSymbols();

        // TYPE references
        Set<Location> expectedReferences = Sets.newHashSet(
                createLocation(file.toPath(), Ranges.createRange(1, 10, 1, 20)),
                createLocation(file.toPath(), Ranges.createRange(10, 6, 10, 16)),
                createLocation(file.toPath(), Ranges.createRange(10, 30, 10, 46)),
                createLocation(file.toPath(), Ranges.createRange(12, 6, 12, 22)),
                createLocation(file.toPath(), Ranges.createRange(14, 6, 14, 16)));
        // Get references to object InnerClass, when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 2, 10, false)));
        // Get references when giving position of instance of Inner Class
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 1, 15, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 10, 10, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 10, 31, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 12, 12, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 14, 11, false)));

        // FIELD references
        expectedReferences = Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(11, 6, 11, 21)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 1, 27, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 11, 15, false)));

        // LOCAL variable references
        expectedReferences = Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(13, 6, 13, 16)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 10, 20, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 13, 10, false)));

        // METHOD (non static) references
        expectedReferences = Sets.newHashSet(
                // TODO(#124): figure out how to make these more precise
                createLocation(file.toPath(), Ranges.createRange(11, 6, 11, 43)),
                createLocation(file.toPath(), Ranges.createRange(12, 6, 12, 44)),
                createLocation(file.toPath(), Ranges.createRange(13, 6, 13, 38)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 3, 7, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 11, 23, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 12, 23, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 13, 23, false)));

        // METHOD (static) references
        expectedReferences = Sets.newHashSet(
                // TODO(#124): figure out how to make these more precise
                createLocation(file.toPath(), Ranges.createRange(14, 6, 14, 35)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 4, 15, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 14, 20, false)));

        // test2 references
        expectedReferences = Sets.newHashSet(
                // TODO(#124): figure out how to make these more precise
                createLocation(file.toPath(), Ranges.createRange(15, 17, 15, 24)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 6, 15, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 15, 20, false)));
    }

    @Test
    public void testReferences_catchStatement() throws IOException {
        File file = addFileToFolder(workspaceRoot, "Coordinates.groovy",
                "class Foo extends Throwable{}\n"
                        + "try {\n"
                        + "   println \"Hello\""
                        + "}\n catch (Foo e1) {\n"
                        + "   println e1\n"
                        + "}\n");
        parser.parseAllSymbols();
        // Class Foo
        Set<Location> expectedReferences =
                Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(3, 8, 3, 11)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 0, 6, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences,  parser.findReferences(createReferenceParams(file.toURI(), 3, 9, false)));
        // TODO(#125): add a symbol for the exception variables and test here.
    }

    @Test
    public void testReferences_ifStatementForLoop() throws IOException {
        File file = addFileToFolder(workspaceRoot, "MyClass.groovy",
                "class MyClass {\n"
                        + "   def fieldName = \"Natacha\"\n"
                        + "   int myMethod(int idx1, int idx2) {\n"
                        + "      def myLocalVar = \"Also in symbols\" + fieldName\n"
                        + "      for (int i = 0; i < idx2; i++) {\n"
                        + "      println fieldName + i\n"
                        + "      }\n"
                        + "      if (idx1 + idx2 == 3) {\n"
                        + "          int ifStatementLocalVar = 0\n"
                        + "          return ifStatementLocalVar + idx1 + myLocalVar.length()\n"
                        + "      }\n"
                        + "      return -1\n"
                        + "   }\n"
                        + "}\n");
        parser.parseAllSymbols();

        // Parameter: idx1
        Set<Location> expectedReferences =
                Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(7, 10, 7, 14)),
                        createLocation(file.toPath(), Ranges.createRange(9, 39, 9, 43)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 2, 21, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 7, 12, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 9, 41, false)));

        // Parameter: idx2
        expectedReferences =
                Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(4, 26, 4, 30)),
                        createLocation(file.toPath(), Ranges.createRange(7, 17, 7, 21)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 2, 30, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 4, 29, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 7, 18, false)));

        // Field: fieldName
        expectedReferences = Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(3, 43, 3, 52)),
                createLocation(file.toPath(), Ranges.createRange(5, 14, 5, 23)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 1, 9, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 3, 47, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 5, 20, false)));

        // Variable: myLocalVar
        expectedReferences = Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(9, 46, 9, 56)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 3, 10, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 9, 50, false)));

        // Variable: ifStatementLocalVar
        expectedReferences = Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(9, 17, 9, 36)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 8, 18, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 9, 25, false)));

        // Variable: i
        expectedReferences = Sets.newHashSet(createLocation(file.toPath(), Ranges.createRange(4, 22, 4, 23)),
                createLocation(file.toPath(), Ranges.createRange(4, 32, 4, 33)),
                createLocation(file.toPath(), Ranges.createRange(5, 26, 5, 27)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 4, 15, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 4, 22, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 4, 32, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(file.toURI(), 5, 26, false)));
    }

    @Test
    public void testReferences_overloadedMethods() throws InterruptedException, ExecutionException, IOException {
        File test = addFileToFolder(workspaceRoot, "Test.groovy",
                "class Test {\n"
                        + "    static int myStaticField = 10\n"
                        + "    int myNonStaticField = 10\n"
                        + "    public static int myStaticMethod() {\n"
                        + "        return 0 + myStaticField\n"
                        + "    }\n"
                        + "    public static int myStaticMethod(int a) {\n"
                        + "        return a\n"
                        + "    }\n"
                        + "    public static int myStaticMethod(int a, int b) {\n"
                        + "        return a + b\n"
                        + "    }\n"
                        + "    public int nonStaticMethod() {\n"
                        + "        return 0 + myNonStaticField\n"
                        + "    }\n"
                        + "    public int nonStaticMethod(int a) {\n"
                        + "        return a\n"
                        + "    }\n"
                        + "    public int nonStaticMethod(int a, int b) {\n"
                        + "        return a + b\n"
                        + "    }\n"
                        + "}\n");
        File script = addFileToFolder(workspaceRoot, "MyScript.groovy",
                "Test test1\n"
                        + "Test test2 = new Test()\n"
                        + "test1 = new Test()\n"
                        + "test1.myNonStaticField\n"
                        + "Test.myStaticField\n"
                        + "test1.nonStaticMethod()\n"
                        + "test1.nonStaticMethod(0)\n"
                        + "test1.nonStaticMethod(0, 1)\n"
                        + "Test.myStaticMethod()\n"
                        + "Test.myStaticMethod(0)\n"
                        + "Test.myStaticMethod(0, 1)\n");
        parser.parseAllSymbols();

        // Type: Test
        Set<Location> expectedReferences = Sets.newHashSet(
                createLocation(script.toPath(), Ranges.createRange(0, 0, 0, 4)),
                createLocation(script.toPath(), Ranges.createRange(1, 0, 1, 4)),
                createLocation(script.toPath(), Ranges.createRange(1, 13, 1, 23)),
                createLocation(script.toPath(), Ranges.createRange(2, 8, 2, 18)),
                createLocation(script.toPath(), Ranges.createRange(4, 0, 4, 4)),
                createLocation(script.toPath(), Ranges.createRange(8, 0, 8, 4)),
                createLocation(script.toPath(), Ranges.createRange(9, 0, 9, 4)),
                createLocation(script.toPath(), Ranges.createRange(10, 0, 10, 4)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 0, 7, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 0, 2, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 1, 2, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 1, 18, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 2, 13, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 4, 2, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 8, 2, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 9, 2, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 10, 2, false)));

        // Field: myNonStaticField
        expectedReferences = Sets.newHashSet(
                createLocation(script.toPath(), Ranges.createRange(3, 6, 3, 22)),
                createLocation(test.toPath(), Ranges.createRange(13, 19, 13, 35)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 2, 13, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 3, 13, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 13, 25, false)));

        // Field: myStaticField
        expectedReferences = Sets.newHashSet(
                createLocation(test.toPath(), Ranges.createRange(4, 19, 4, 32)),
                createLocation(script.toPath(), Ranges.createRange(4, 5, 4, 18)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 1, 18, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 4, 25, false)));
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 4, 15, false)));

        // Method: myStaticMethod()
        expectedReferences = Sets.newHashSet(createLocation(script.toPath(), Ranges.createRange(8, 0, 8, 21)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 3, 30, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 8, 10, false)));

        // Method: myStaticMethod(int a)
        expectedReferences = Sets.newHashSet(createLocation(script.toPath(), Ranges.createRange(9, 0, 9, 22)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 6, 30, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 9, 10, false)));

        // Method: myStaticMethod(int a, int b)
        expectedReferences = Sets.newHashSet(createLocation(script.toPath(), Ranges.createRange(10, 0, 10, 25)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 9, 30, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 10, 10, false)));

        // Method: nonStaticMethod()
        expectedReferences = Sets.newHashSet(createLocation(script.toPath(), Ranges.createRange(5, 0, 5, 23)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 12, 20, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 5, 10, false)));

        // Method: nonStaticMethod(int a)
        expectedReferences = Sets.newHashSet(createLocation(script.toPath(), Ranges.createRange(6, 0, 6, 24)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 15, 30, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 6, 12, false)));

        // Method: nonStaticMethod(int a, int b)
        expectedReferences = Sets.newHashSet(createLocation(script.toPath(), Ranges.createRange(7, 0, 7, 27)));
        // Get references when providing definition position
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(test.toURI(), 18, 30, false)));
        // Get references when providing position of usage
        assertEquals(expectedReferences, parser.findReferences(createReferenceParams(script.toURI(), 7, 15, false)));
    }

    @Test
    public void testGotoDefinition() throws IOException {
        File file = addFileToFolder(workspaceRoot, "OuterClass.groovy",
                "class OuterClass {\n"
                        + "   static InnerClass someStaticField\n"
                        + "   static class InnerClass {\n"
                        + "      void myICNonStaticMethod() {}\n"
                        + "      static void myICStaticMethod() {}\n"
                        + "   }\n"
                        + "   static int test2() {\n"
                        + "      return 0\n"
                        + "   }\n"
                        + "   static int test3() {\n" // Calling methods from a static context
                        + "      InnerClass localField = new InnerClass()\n"
                        + "      someStaticField.myICNonStaticMethod()\n"
                        + "      new InnerClass().myICNonStaticMethod()\n"
                        + "      localField.myICNonStaticMethod()\n"
                        + "      InnerClass.myICStaticMethod()\n"
                        + "      return 1 + test2()\n"
                        + "   }\n"
                        + "}\n");
        parser.parseAllSymbols();

        // InnerClass
        Location expectedLocation = new Location(file.toPath().toUri().toString(), Ranges.createRange(2, 3, 3, 0));
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(1, 15)).get());
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(10, 10)).get());
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(10, 31)).get());
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(12, 12)).get());
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(14, 11)).get());

        // someStaticField
        // TODO(#124): figure out how to make these more precise
        expectedLocation = new Location(file.toPath().toUri().toString(), Ranges.createRange(1, 3, 1, 36));
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(11, 15)).get());

        // localField
        expectedLocation = new Location(file.toPath().toUri().toString(), Ranges.createRange(10, 17, 10, 27));
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(13, 10)).get());

        // myICNonStaticMethod
        expectedLocation = new Location(file.toPath().toUri().toString(), Ranges.createRange(3, 6, 3, 35));
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(11, 23)).get());
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(12, 23)).get());
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(13, 23)).get());

        // myICStaticMethod
        // TODO(#124): figure out how to make these more precise
        expectedLocation = new Location(file.toPath().toUri().toString(), Ranges.createRange(4, 6, 4, 39));
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(14, 20)).get());

        // test2
        // TODO(#124): figure out how to make these more precise
        expectedLocation = new Location(file.toPath().toUri().toString(), Ranges.createRange(6, 3, 8, 4));
        assertEquals(expectedLocation, parser.gotoDefinition(file.toURI(), new Position(15, 20)).get());
    }

    @Test
    public void testGotoDefinition_multipleFiles() throws IOException {
        File dog = addFileToFolder(workspaceRoot, "mydogfolder", "Dog.groovy",
                "public class Dog {}\n");
        File cat = addFileToFolder(workspaceRoot, "mycatfolder", "Cat.groovy",
                "public class Cat {\n"
                        + "   public static Dog dog = new Dog()\n"
                        + "   public static Dog foo() {\n"
                        + "       Dog newDog = new Dog()\n"
                        + "       foo()\n"
                        + "       return newDog\n"
                        + "   }\n"
                        + "}\n");
        parser.parseAllSymbols();

        // Dog class
        Location expectedLocation = new Location(dog.toPath().toUri().toString(), Ranges.createRange(0, 0, 0, 19));
        assertEquals(Optional.of(expectedLocation), parser.gotoDefinition(cat.toURI(), new Position(1, 18)));
        assertEquals(Optional.of(expectedLocation), parser.gotoDefinition(cat.toURI(), new Position(2, 18)));
        assertEquals(Optional.of(expectedLocation), parser.gotoDefinition(cat.toURI(), new Position(3, 8)));
        assertEquals(Optional.of(expectedLocation), parser.gotoDefinition(cat.toURI(), new Position(3, 25)));

        // newDog local variable
        expectedLocation = new Location(cat.toPath().toUri().toString(), Ranges.createRange(3, 11, 3, 17));
        assertEquals(Optional.of(expectedLocation), parser.gotoDefinition(cat.toURI(), new Position(5, 18)));

        // foo method
        // TODO(#124): make this more accurate
        expectedLocation = new Location(cat.toPath().toUri().toString(), Ranges.createRange(2, 3, 6, 4));
        assertEquals(Optional.of(expectedLocation), parser.gotoDefinition(cat.toURI(), new Position(4, 10)));
    }

    private boolean mapHasSymbol(Map<URI, Set<SymbolInformation>> map, Optional<String> container, String fieldName,
            SymbolKind kind) {
        return map.values().stream().flatMap(Collection::stream)
                .anyMatch(symbol -> symbol.getKind() == kind
                        && container.transform(c -> c.equals(symbol.getContainerName())).or(true)
                        && symbol.getName().equals(fieldName));
    }

    private static File addFileToFolder(File root, String filename, String contents) throws IOException {
        File file = Files.createFile(root.toPath().resolve(filename)).toFile();
        PrintWriter writer = new PrintWriter(file, StandardCharsets.UTF_8.toString());
        writer.print(contents);
        writer.close();
        return file;
    }

    private static File addFileToFolder(File root, String parent, String filename, String contents) throws IOException {
        Path parentPath = root.toPath().resolve(parent);
        Files.createDirectories(parentPath);
        return addFileToFolder(parentPath.toFile(), filename, contents);
    }

    private static Location createLocation(Path path, Range range) {
        return new Location(path.toUri().toString(), range);
    }

    private static ReferenceParams createReferenceParams(URI uri, int line, int col, boolean includeDeclaration) {
        ReferenceParams referenceParams = new ReferenceParams(new ReferenceContext(includeDeclaration));
        referenceParams.setTextDocument(new TextDocumentIdentifier(uri.toString()));
        referenceParams.setPosition(new Position(line, col));
        return referenceParams;
    }

}
