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
package moonshine.groovyls;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.codehaus.groovy.control.CompilerConfiguration;
import org.codehaus.groovy.control.SourceUnit;
import org.codehaus.groovy.tools.FileSystemCompiler;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import groovyjarjarpicocli.CommandLine;
import net.prominic.groovyls.compiler.control.GroovyLSCompilationUnit;
import net.prominic.groovyls.compiler.control.io.StringReaderSourceWithURI;
import net.prominic.groovyls.config.ICompilationUnitFactory;
import net.prominic.groovyls.util.FileContentsTracker;

public class GvyProjCompilationUnitFactory implements ICompilationUnitFactory {
	private static final String FILE_EXTENSION_GROOVY = ".groovy";

	private Path storagePath;

	public GvyProjCompilationUnitFactory() {
	}

	public GroovyLSCompilationUnit create(Path workspaceRoot, FileContentsTracker fileContentsTracker) {
		Path workspaceStoragePath = getStoragePath(workspaceRoot);
		if (workspaceStoragePath == null) {
			System.err.println("Failed to create temporary directory for Groovy language server.");
			return null;
		}

		DocumentBuilder xmlBuilder = null;
		try {
			xmlBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
		} catch (ParserConfigurationException e) {
			e.printStackTrace(System.err);
			return null;
		}

		Path projectFilePath = workspaceRoot.resolve(workspaceRoot.getFileName().toString() + ".gvyproj");

		Document document = null;
		try {
			document = xmlBuilder.parse(projectFilePath.toFile());
		} catch (IOException e) {
			System.err.println("Error reading Groovy project file: " + projectFilePath);
			e.printStackTrace(System.err);
			return null;
		} catch (SAXException e) {
			System.err.println("Error parsing Groovy project file: " + projectFilePath);
			e.printStackTrace(System.err);
			return null;
		}

		CompilerConfiguration config = parseBuildOptions(document, workspaceRoot);
		if (config == null) {
			System.err.println("Failed to parse Groovy compiler options.");
			return null;
		}

		Path targetDirPath = workspaceStoragePath.resolve("build/libs");
		if (Files.exists(targetDirPath)) {
			try {
				Files.walk(targetDirPath).sorted(Comparator.reverseOrder()).map(Path::toFile).forEach(File::delete);
			} catch (IOException e) {
				System.err.println("Failed to delete workspace storage because an I/O exception occurred.");
			}
		}
		config.setTargetDirectory(targetDirPath.toFile());
		Set<Path> sourceFolders = parseClasspaths(document, workspaceRoot);

		GroovyLSCompilationUnit compilationUnit = new GroovyLSCompilationUnit(config);
		for (Path sourceFolderPath : sourceFolders) {
			addDirectoryToCompilationUnit(sourceFolderPath, compilationUnit, fileContentsTracker);
		}

		return compilationUnit;
	}

	protected Path getStoragePath(Path workspaceRoot) {
		if (storagePath == null) {
			try {
				storagePath = Files.createTempDirectory("moonshine-groovyls");
			} catch (IOException e) {
				return null;
			}
		}
		try {
			MessageDigest digest = MessageDigest.getInstance("SHA-256");
			byte[] hash = digest.digest(workspaceRoot.toString().getBytes(StandardCharsets.UTF_8));
			StringBuilder hexBuilder = new StringBuilder();
			for (int i = 0; i < hash.length; i++) {
				byte current = hash[i];
				String hex = Integer.toHexString(0xff & current);
				if (hex.length() == 1) {
					hexBuilder.append("0");
				}
				hexBuilder.append(hex);
			}
			return storagePath.resolve(hexBuilder.toString());
		} catch (NoSuchAlgorithmException e) {
			return null;
		}
	}

	protected Set<Path> parseClasspaths(Document document, Path workspaceRoot) {
		NodeList classpathsElements = document.getElementsByTagName("classpaths");
		Set<Path> sourceFolders = new HashSet<>();
		for (int i = 0; i < classpathsElements.getLength(); i++) {
			Node classpathNode = classpathsElements.item(i);
			Node childNode = classpathNode.getFirstChild();
			while (childNode != null) {
				if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName().equals("class")) {
					Node pathAttribute = childNode.getAttributes().getNamedItem("path");
					if (pathAttribute != null) {
						String sourceFolder = pathAttribute.getTextContent();
						Path sourceFolderPath = workspaceRoot.resolve(sourceFolder);
						sourceFolders.add(sourceFolderPath);
					}
				}
				childNode = childNode.getNextSibling();
			}
		}
		return sourceFolders;
	}

	protected CompilerConfiguration parseBuildOptions(Document document, Path workspaceRoot) {
		NodeList buildElements = document.getElementsByTagName("build");
		if (buildElements.getLength() == 0) {
			//nothing to parse. use default options.
			return new CompilerConfiguration();
		}
		List<String> args = new ArrayList<>();
		Node buildNode = buildElements.item(0);
		Node childNode = buildNode.getFirstChild();
		while (childNode != null) {
			if (childNode.getNodeType() == Node.ELEMENT_NODE && childNode.getNodeName().equals("option")) {
				NamedNodeMap attributes = childNode.getAttributes();
				for (int i = 0; i < attributes.getLength(); i++) {
					Node attributeNode = attributes.item(i);
					switch (attributeNode.getNodeName()) {
					case "additional": {
						String textContent = attributeNode.getTextContent();
						if (textContent.length() > 0) {
							args.addAll(Arrays.asList(textContent.split(" ")));
						}
						break;
					}
					case "configscript": {
						String textContent = attributeNode.getTextContent();
						if (textContent.length() > 0) {
							args.add("--configscript");
							args.add(textContent);
						}
						break;
					}
					case "destdir": {
						String textContent = attributeNode.getTextContent();
						if (textContent.length() > 0) {
							args.add("-d");
							args.add(textContent);
						}
						break;
					}
					case "encoding": {
						String textContent = attributeNode.getTextContent();
						if (textContent.length() > 0) {
							args.add("--encoding");
							args.add(textContent);
						}
						break;
					}
					case "exception": {
						String textContent = attributeNode.getTextContent();
						if (textContent.equals("True")) {
							args.add("--exception");
						}
						break;
					}
					case "jointCompilation": {
						String textContent = attributeNode.getTextContent();
						if (textContent.equals("True")) {
							args.add("--jointCompilation");
						}
						break;
					}
					case "indy": {
						String textContent = attributeNode.getTextContent();
						if (textContent.equals("True")) {
							args.add("--indy");
						}
						break;
					}
					case "parameters": {
						String textContent = attributeNode.getTextContent();
						if (textContent.equals("True")) {
							args.add("--parameters");
						}
						break;
					}
					case "scriptBaseClass": {
						String textContent = attributeNode.getTextContent();
						if (textContent.length() > 0) {
							args.add("--basescript");
							args.add(textContent);
						}
						break;
					}
					case "targetBytecode": {
						String textContent = attributeNode.getTextContent();
						if (textContent.length() > 0) {
							args.add("-Dgroovy.target.bytecode=" + textContent);
						}
						break;
					}
					case "temp": {
						String textContent = attributeNode.getTextContent();
						if (textContent.length() > 0) {
							args.add("--temp");
							args.add(textContent);
						}
					}
					case "verbose": {
						if (attributeNode.getTextContent().equals("True")) {
							args.add("-Dgroovy.output.verbose");
						}
						break;
					}
					}
				}
			}
			childNode = childNode.getNextSibling();
		}

		FileSystemCompiler.CompilationOptions options = new FileSystemCompiler.CompilationOptions();
		CommandLine parser = FileSystemCompiler.configureParser(options);
		parser.parseArgs(args.toArray(new String[args.size()]));
		try {
			return options.toCompilerConfiguration();
		} catch (IOException e) {
			return null;
		}
	}

	protected void addDirectoryToCompilationUnit(Path dirPath, GroovyLSCompilationUnit compilationUnit,
			FileContentsTracker fileContentsTracker) {
		try {
			if (Files.exists(dirPath)) {
				Files.walk(dirPath).forEach((filePath) -> {
					if (!filePath.toString().endsWith(FILE_EXTENSION_GROOVY)) {
						return;
					}
					URI fileURI = filePath.toUri();
					if (!fileContentsTracker.isOpen(fileURI)) {
						File file = filePath.toFile();
						if (file.isFile()) {
							compilationUnit.addSource(file);
						}
					}
				});
			}

		} catch (IOException e) {
			System.err.println("Failed to walk directory for source files: " + dirPath);
		}
		fileContentsTracker.getOpenURIs().forEach(uri -> {
			Path openPath = Paths.get(uri);
			if (!openPath.normalize().startsWith(dirPath.normalize())) {
				return;
			}
			String contents = fileContentsTracker.getContents(uri);
			SourceUnit sourceUnit = new SourceUnit(openPath.toString(),
					new StringReaderSourceWithURI(contents, uri, compilationUnit.getConfiguration()),
					compilationUnit.getConfiguration(), compilationUnit.getClassLoader(),
					compilationUnit.getErrorCollector());
			compilationUnit.addSource(sourceUnit);
		});
	}
}