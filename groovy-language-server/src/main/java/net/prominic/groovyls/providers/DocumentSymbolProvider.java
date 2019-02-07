////////////////////////////////////////////////////////////////////////////////
// Copyright 2019 Prominic.NET, Inc.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// Author: Prominic.NET, Inc.
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////
package net.prominic.groovyls.providers;

import java.net.URI;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

import com.google.common.base.Optional;
import com.palantir.ls.groovy.util.GroovySymbolInformations;

import org.codehaus.groovy.ast.ASTNode;
import org.codehaus.groovy.ast.ClassNode;
import org.codehaus.groovy.ast.FieldNode;
import org.codehaus.groovy.ast.MethodNode;
import org.codehaus.groovy.ast.PropertyNode;
import org.eclipse.lsp4j.SymbolInformation;
import org.eclipse.lsp4j.TextDocumentIdentifier;

import net.prominic.groovyls.compiler.ast.ASTNodeVisitor;
import net.prominic.groovyls.compiler.util.GroovyASTUtils;

public class DocumentSymbolProvider {
	private ASTNodeVisitor ast;

	public DocumentSymbolProvider(ASTNodeVisitor ast) {
		this.ast = ast;
	}

	public CompletableFuture<List<? extends SymbolInformation>> provideDocumentSymbols(
			TextDocumentIdentifier textDocument) {
		URI uri = URI.create(textDocument.getUri());
		List<ASTNode> nodes = ast.getNodes(uri);
		List<SymbolInformation> symbols = nodes.stream().filter(node -> {
			return node instanceof ClassNode || node instanceof MethodNode || node instanceof FieldNode
					|| node instanceof PropertyNode;
		}).map(node -> {
			if (node instanceof ClassNode) {
				ClassNode classNode = (ClassNode) node;
				return GroovySymbolInformations.createSymbolInformation(classNode, uri, Optional.absent());
			}
			ClassNode classNode = GroovyASTUtils.getEnclosingClass(node, ast);
			if (node instanceof MethodNode) {
				MethodNode methodNode = (MethodNode) node;
				return GroovySymbolInformations.createSymbolInformation(methodNode, uri,
						Optional.fromNullable(classNode.getName()));
			}
			if (node instanceof PropertyNode) {
				PropertyNode propNode = (PropertyNode) node;
				return GroovySymbolInformations.createSymbolInformation(propNode, uri,
						Optional.fromNullable(classNode.getName()));
			}
			if (node instanceof FieldNode) {
				FieldNode fieldNode = (FieldNode) node;
				return GroovySymbolInformations.createSymbolInformation(fieldNode, uri,
						Optional.fromNullable(classNode.getName()));
			}
			// this should never happen
			return null;
		}).collect(Collectors.toList());
		return CompletableFuture.completedFuture(symbols);
	}
}