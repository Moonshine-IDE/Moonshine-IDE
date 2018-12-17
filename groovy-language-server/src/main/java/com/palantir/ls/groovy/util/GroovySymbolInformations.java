/*
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

import java.net.URI;

import com.google.common.base.Optional;

import org.codehaus.groovy.ast.ClassNode;
import org.codehaus.groovy.ast.DynamicVariable;
import org.codehaus.groovy.ast.FieldNode;
import org.codehaus.groovy.ast.MethodNode;
import org.codehaus.groovy.ast.Parameter;
import org.codehaus.groovy.ast.PropertyNode;
import org.codehaus.groovy.ast.Variable;
import org.codehaus.groovy.ast.expr.VariableExpression;
import org.eclipse.lsp4j.Location;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.SymbolKind;

public class GroovySymbolInformations {
	
    // sourceUri should already have been converted to a workspace URI
    public static SymbolInformation createSymbolInformation(MethodNode method, URI sourceUri, Optional<String> parentName) {
		
        final SymbolKind kind = SymbolKind.Method;
		final Location location = GroovyLocations.createLocation(sourceUri, method);
        return new SymbolInformation(method.getName(), kind, location, parentName.orNull());
	}
	
    // sourceUri should already have been converted to a workspace URI
    public static SymbolInformation createSymbolInformation(ClassNode clazz, URI sourceUri, Optional<String> parentName) {
        final SymbolKind kind;
		if (clazz.isInterface()) {
			kind = SymbolKind.Interface;
		} else if (clazz.isEnum()) {
			kind = SymbolKind.Enum;
		} else {
			kind = SymbolKind.Class;
		}
        final Location location = GroovyLocations.createClassDefinitionLocation(sourceUri, clazz);
        return new SymbolInformation(clazz.getName(), kind, location, parentName.orNull());
	}

	// sourceUri should already have been converted to a workspace URI
    public static SymbolInformation createSymbolInformation(Variable variable, URI sourceUri, Optional<String> parentName) {
        final SymbolKind kind;
        final Location location;
        if (variable instanceof DynamicVariable) {
            kind = SymbolKind.Field;
            location = GroovyLocations.createLocation(sourceUri);
        } else if (variable instanceof FieldNode) {
            kind = SymbolKind.Field;
            location = GroovyLocations.createLocation(sourceUri, (FieldNode) variable);
        } else if (variable instanceof Parameter) {
            kind = SymbolKind.Variable;
            location = GroovyLocations.createLocation(sourceUri, (Parameter) variable);
        } else if (variable instanceof PropertyNode) {
            kind = SymbolKind.Field;
            location = GroovyLocations.createLocation(sourceUri, (PropertyNode) variable);
        } else if (variable instanceof VariableExpression) {
            kind = SymbolKind.Variable;
            location = GroovyLocations.createLocation(sourceUri, (VariableExpression) variable);
        } else {
            throw new IllegalArgumentException(String.format("Unknown type of variable: %s", variable));
        }
        return new SymbolInformation(variable.getName(), kind, location, parentName.orNull());
	}
}