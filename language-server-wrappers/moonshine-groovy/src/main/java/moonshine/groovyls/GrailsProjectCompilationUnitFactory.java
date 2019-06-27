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
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.codehaus.groovy.control.CompilerConfiguration;
import org.codehaus.groovy.control.SourceUnit;
import org.w3c.dom.Document;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

import net.prominic.groovyls.compiler.control.GroovyLSCompilationUnit;
import net.prominic.groovyls.compiler.control.io.StringReaderSourceWithURI;
import net.prominic.groovyls.config.ICompilationUnitFactory;
import net.prominic.groovyls.util.FileContentsTracker;

public class GrailsProjectCompilationUnitFactory implements ICompilationUnitFactory {
	private static final String FILE_EXTENSION_GROOVY = ".groovy";
	private static final String FILE_EXTENSION_JAVA = ".java";
	private static final String FILE_ECLIPSE_CLASSPATH = ".classpath";

	private Path storagePath;
	private GroovyLSCompilationUnit compilationUnit;

	public GrailsProjectCompilationUnitFactory() {
	}

	public void invalidateCompilationUnit() {
		compilationUnit = null;
	}

	public GroovyLSCompilationUnit create(Path workspaceRoot, FileContentsTracker fileContentsTracker) {
		Path projectFilePath = getGrailsConfigurationPath(workspaceRoot);
//		Path projectFilePath = workspaceRoot.resolve(workspaceRoot.getFileName().toString() + ".grailsproj");
		Document projectDocument = loadXMLDocument(projectFilePath);
		if (projectDocument == null) {
			return null;
		}

		Path classpathFilePath = workspaceRoot.resolve(FILE_ECLIPSE_CLASSPATH);
		Document classpathDocument = null;
		if (Files.exists(classpathFilePath)) {
			classpathDocument = loadXMLDocument(classpathFilePath);
		}
		if (classpathDocument == null) {
			return null;
		}

		Set<URI> changedUris = fileContentsTracker.getChangedURIs();
		if (compilationUnit == null) {
			CompilerConfiguration config = createConfig(workspaceRoot, classpathDocument);
			compilationUnit = new GroovyLSCompilationUnit(config);
			changedUris = null;
		} else {
			final Set<URI> urisToSkip = changedUris;
			List<SourceUnit> sourcesToRemove = new ArrayList<>();
			compilationUnit.iterator().forEachRemaining(sourceUnit -> {
				URI uri = sourceUnit.getSource().getURI();
				if (urisToSkip.contains(uri)) {
					sourcesToRemove.add(sourceUnit);
				}
			});
			compilationUnit.removeSources(sourcesToRemove);
		}

		if (classpathDocument != null) {
			Set<Path> sourceFolders = parseSrcClasspaths(classpathDocument, workspaceRoot);
			for (Path sourceFolderPath : sourceFolders) {
				addDirectoryToCompilationUnit(sourceFolderPath, compilationUnit, fileContentsTracker, changedUris);
			}
		}

		return compilationUnit;
	}

	protected CompilerConfiguration createConfig(Path workspaceRoot, Document classpathDocument) {
		Path workspaceStoragePath = getStoragePath(workspaceRoot);
		if (workspaceStoragePath == null) {
			System.err.println("Failed to create temporary directory for Groovy language server.");
			return null;
		}

		CompilerConfiguration config = new CompilerConfiguration();

		Path targetDirPath = workspaceStoragePath.resolve("build/libs");
		if (Files.exists(targetDirPath)) {
			try {
				Files.walk(targetDirPath).sorted(Comparator.reverseOrder()).map(Path::toFile).forEach(File::delete);
			} catch (IOException e) {
				System.err.println("Failed to delete workspace storage because an I/O exception occurred.");
			}
		}
		config.setTargetDirectory(targetDirPath.toFile());

		if (classpathDocument != null) {
			List<String> libraries = parseLibClasspaths(classpathDocument, workspaceRoot);
			config.setClasspathList(libraries);
		}

		return config;
	}

	protected Document loadXMLDocument(Path documentPath) {

		DocumentBuilder xmlBuilder = null;
		try {
			xmlBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
		} catch (ParserConfigurationException e) {
			e.printStackTrace(System.err);
			return null;
		}

		Document result = null;
		try {
			result = xmlBuilder.parse(documentPath.toFile());
		} catch (IOException e) {
			System.err.println("Error reading XML file: " + documentPath);
			e.printStackTrace(System.err);
			return null;
		} catch (SAXException e) {
			System.err.println("Error parsing XML file: " + documentPath);
			e.printStackTrace(System.err);
			return null;
		}
		return result;
	}

	protected Path getGrailsConfigurationPath(Path workspaceRoot)
	{
		File folder = workspaceRoot.toFile();
		File[] fileNames = folder.listFiles();
        for(File file : fileNames){
             // if not a directory
             if(!file.isDirectory()){
                String extension = "";
				int i = file.getName().lastIndexOf('.');
				if (i > 0) {
					extension = file.getName().substring(i+1);
				}
				if (extension == "grailsproj")
				{
					return file.toPath();
				}
             }
         }

		 return null;
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

	protected Set<Path> parseSrcClasspaths(Document document, Path workspaceRoot) {
		Set<Path> classpaths = new HashSet<>();

		NodeList classpathentryElements = document.getElementsByTagName("classpathentry");
		if (classpathentryElements.getLength() == 0) {
			return classpaths;
		}
		for (int i = 0; i < classpathentryElements.getLength(); i++) {
			Node classpathentryNode = classpathentryElements.item(i);
			NamedNodeMap attributes = classpathentryNode.getAttributes();
			Node kindNode = attributes.getNamedItem("kind");
			if (kindNode == null || !kindNode.getTextContent().equals("src")) {
				continue;
			}
			Node pathNode = attributes.getNamedItem("path");
			if (pathNode == null) {
				continue;
			}
			String classpathentryPath = pathNode.getTextContent();
			classpaths.add(workspaceRoot.resolve(classpathentryPath));
		}
		return classpaths;
	}

	protected List<String> parseLibClasspaths(Document document, Path workspaceRoot) {
		List<String> classpaths = new ArrayList<>();

		NodeList classpathentryElements = document.getElementsByTagName("classpathentry");
		if (classpathentryElements.getLength() == 0) {
			return classpaths;
		}
		for (int i = 0; i < classpathentryElements.getLength(); i++) {
			Node classpathentryNode = classpathentryElements.item(i);
			NamedNodeMap attributes = classpathentryNode.getAttributes();
			Node kindNode = attributes.getNamedItem("kind");
			if (kindNode == null || !kindNode.getTextContent().equals("lib")) {
				continue;
			}
			Node pathNode = attributes.getNamedItem("path");
			if (pathNode == null) {
				continue;
			}
			String classpathentryPath = pathNode.getTextContent();
			classpaths.add(workspaceRoot.resolve(classpathentryPath).toString());
		}
		return classpaths;
	}

	protected void addDirectoryToCompilationUnit(Path dirPath, GroovyLSCompilationUnit compilationUnit,
			FileContentsTracker fileContentsTracker, Set<URI> changedUris) {
		try {
			if (Files.exists(dirPath)) {
				Files.walk(dirPath).forEach((filePath) -> {
					if (!filePath.toString().endsWith(FILE_EXTENSION_GROOVY)
							&& !filePath.toString().endsWith(FILE_EXTENSION_JAVA)) {
						return;
					}
					URI fileURI = filePath.toUri();
					if (!fileContentsTracker.isOpen(fileURI)) {
						File file = filePath.toFile();
						if (file.isFile()) {
							if (changedUris == null || changedUris.contains(fileURI)) {
								compilationUnit.addSource(file);
							}
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
			if (changedUris != null && !changedUris.contains(uri)) {
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