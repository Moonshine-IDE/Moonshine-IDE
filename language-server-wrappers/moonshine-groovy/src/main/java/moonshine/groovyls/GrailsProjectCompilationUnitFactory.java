////////////////////////////////////////////////////////////////////////////////
// Copyright 2022 Prominic.NET, Inc.
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
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
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

import groovy.lang.GroovyClassLoader;
import net.prominic.groovyls.compiler.control.GroovyLSCompilationUnit;
import net.prominic.groovyls.compiler.control.io.StringReaderSourceWithURI;
import net.prominic.groovyls.config.ICompilationUnitFactory;
import net.prominic.groovyls.util.FileContentsTracker;

public class GrailsProjectCompilationUnitFactory implements ICompilationUnitFactory {
	private static final String FILE_EXTENSION_GROOVY = ".groovy";
	private static final String FILE_EXTENSION_JAVA = ".java";
	private static final String FILE_EXTENSION_GRAILSPROJ = ".grailsproj";
	private static final String FILE_ECLIPSE_CLASSPATH = ".classpath";

	private Path storagePath;
	private GroovyLSCompilationUnit compilationUnit;
	private CompilerConfiguration config;
	private GroovyClassLoader classLoader;
	private Path prevClasspathFilePath;
	private long prevClasspathFileLastModified;
	private Path prevProjectFilePath;
	private long prevProjectFileLastModified;

	public GrailsProjectCompilationUnitFactory() {
	}

	public List<String> getAdditionalClasspathList() {
		return null;
	}

	public void setAdditionalClasspathList(List<String> additionalClasspathList) {
		if (additionalClasspathList != null && additionalClasspathList.size() > 0) {
			throw new RuntimeException("Additional classpaths not supported");
		}
	}

	public void invalidateCompilationUnit() {
		compilationUnit = null;
		config = null;
		classLoader = null;
	}

	public GroovyLSCompilationUnit create(Path workspaceRoot, FileContentsTracker fileContentsTracker) {
		Path projectFilePath = getGrailsSettingsPath(workspaceRoot);
		if (projectFilePath == null || !projectFilePath.equals(prevProjectFilePath)) {
			prevProjectFilePath = projectFilePath;
			prevProjectFileLastModified = 0L;
			invalidateCompilationUnit();
		}
		if (projectFilePath == null) {
			System.err.println("Failed to find Groovy settings file.");
			return null;
		}
		Document projectDocument = loadXMLDocument(projectFilePath);
		if (projectDocument == null) {
			return null;
		}
		long projectFileLastModified = projectFilePath.toFile().lastModified();
		if (prevProjectFileLastModified != projectFileLastModified) {
			prevProjectFileLastModified = projectFileLastModified;
			invalidateCompilationUnit();
		}

		Path classpathFilePath = workspaceRoot.resolve(FILE_ECLIPSE_CLASSPATH);
		if (classpathFilePath == null || !classpathFilePath.equals(prevClasspathFilePath)) {
			prevClasspathFilePath = classpathFilePath;
			prevClasspathFileLastModified = 0L;
			invalidateCompilationUnit();
		}
		Document classpathDocument = null;
		if (Files.exists(classpathFilePath)) {
			classpathDocument = loadXMLDocument(classpathFilePath);
		}
		if (classpathDocument == null) {
			return null;
		}
		long classpathFileLastModified = classpathFilePath.toFile().lastModified();
		if (prevClasspathFileLastModified != classpathFileLastModified) {
			prevClasspathFileLastModified = classpathFileLastModified;
			invalidateCompilationUnit();
		}

		if (config == null) {
			config = createConfig(workspaceRoot, classpathDocument);
		}
		if (classLoader == null) {
			classLoader = new GroovyClassLoader(ClassLoader.getSystemClassLoader().getParent(), config,
				true);
		}

		Set<URI> changedUris = fileContentsTracker.getChangedURIs();
		if (compilationUnit == null) {
			compilationUnit = new GroovyLSCompilationUnit(config, null, classLoader);
			//we don't care about changed URIs if there's no compilation unit yet
			changedUris = null;
		} else {
			compilationUnit.setClassLoader(classLoader);
			final Set<URI> urisToRemove = changedUris;
			List<SourceUnit> sourcesToRemove = new ArrayList<>();
			compilationUnit.iterator().forEachRemaining(sourceUnit -> {
				URI uri = sourceUnit.getSource().getURI();
				if (urisToRemove.contains(uri)) {
					sourcesToRemove.add(sourceUnit);
				}
			});
			//if an URI has changed, we remove it from the compilation unit so
			//that a new version can be built from the updated source file
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

		Map<String, Boolean> optimizationOptions = new HashMap<>();
		optimizationOptions.put(CompilerConfiguration.GROOVYDOC, true);
		config.setOptimizationOptions(optimizationOptions);

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

	protected Path getGrailsSettingsPath(Path workspaceRoot) {
		File folder = workspaceRoot.toFile();
		for (File file : folder.listFiles()) {
			if (file.isDirectory()) {
				continue;
			}
			if (file.getName().endsWith(FILE_EXTENSION_GRAILSPROJ)) {
				return file.toPath();
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
			addOpenFileToCompilationUnit(uri, contents, compilationUnit);
		});
	}

	protected void addOpenFileToCompilationUnit(URI uri, String contents, GroovyLSCompilationUnit compilationUnit) {
		Path filePath = Paths.get(uri);
		SourceUnit sourceUnit = new SourceUnit(filePath.toString(),
				new StringReaderSourceWithURI(contents, uri, compilationUnit.getConfiguration()),
				compilationUnit.getConfiguration(), compilationUnit.getClassLoader(),
				compilationUnit.getErrorCollector());
		compilationUnit.addSource(sourceUnit);
	}
}