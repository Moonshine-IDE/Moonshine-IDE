////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2016-present Prominic.NET, Inc.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////
package actionScripts.utils
{
    import actionScripts.factory.FileLocation;

    public class MavenPomUtil
    {
        public static function getProjectId(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);

            return String(pomXML.xsiNamespace::artifactId);
        }

        public static function getProjectVersion(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);

            return String(pomXML.xsiNamespace::version);
        }

        public static function getProjectSourceDirectory(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);
            var buildName:QName = new QName(xsiNamespace, "build");

            if (pomXML.hasOwnProperty(buildName))
            {
                var build:XML = new XML(pomXML.xsiNamespace::build);
                var sourceDirectory:QName = new QName(xsiNamespace, "sourceDirectory");
                if (build.hasOwnProperty(sourceDirectory))
                {
                    return String(build.xsiNamespace::sourceDirectory);
                }
            }

            return "";
        }

        public static function getMainClassName(pomLocation:FileLocation):String
        {
            var fileContent:Object = pomLocation.fileBridge.read();
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var pomXML:XML = new XML(fileContent);
            var buildName:QName = new QName(xsiNamespace, "build");

            if (pomXML.hasOwnProperty(buildName))
            {
                var build:XML = new XML(pomXML.xsiNamespace::build);
                if (build.xsiNamespace.plugins.length() == 0) return "";

                var plugins:XML = new XML(build.xsiNamespace::plugins);
                var plugin:XMLList = plugins.xsiNamespace::plugin;

                for each (var p:XML in plugin)
                {
                    var artifactId:String = String(p.xsiNamespace::artifactId);
                    if (artifactId == "maven-jar-plugin")
                    {
                        var manifest:XMLList = p.xsiNamespace::configuration.xsiNamespace::archive.xsiNamespace::manifest;
                        if (manifest.length() == 0)
                        {
                            break;
                        }

                        return String(manifest.xsiNamespace::mainClass);
                    }
                }
            }

            return "";
        }

        public static function getPomWithProjectSourceDirectory(pomXML:XML, sourceDirectory:String):XML
        {
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var build:XML = null;
            var buildName:QName = new QName(xsiNamespace, "build");

            if (!pomXML.hasOwnProperty(buildName))
            {
                pomXML.xsiNamespace::build.sourceDirectory = new XML("<sourceDirectory>" + sourceDirectory + "</sourceDirectory>");
            }
            else
            {
                var sourceDirectoryQName:QName = new QName(xsiNamespace, "sourceDirectory");
                build = XML(pomXML.xsiNamespace::build);

                if (!build.hasOwnProperty(sourceDirectoryQName))
                {
                    pomXML.xsiNamespace::build.sourceDirectory = sourceDirectory;
                }
                else
                {
                    var currentSourceFolder:String = String(build.xsiNamespace::sourceDirectory);
                    if(sourceDirectory != currentSourceFolder)
                    {
                        build.xsiNamespace::sourceDirectory = sourceDirectory;
                    }
                }
            }

            return pomXML;
        }

        public static function getPomWithMainClass(pomXML:XML, mainClassName:String):XML
        {
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");

            var buildName:QName = new QName(xsiNamespace, "build");
            var pluginsXML:XML = null;

            if (!pomXML.hasOwnProperty(buildName))
            {
                pluginsXML = new XML("<plugins></plugins>");
                addPluginMainClassToPlugins(pluginsXML, mainClassName);
                pomXML.xsiNamespace::build.plugins = plugins;
            }
            else
            {
                var build:XML = XML(pomXML.xsiNamespace::build);
                var plugins:XMLList = build.xsiNamespace::plugins;

                if (plugins.length() == 0)
                {
                    pluginsXML = new XML("<plugins></plugins>");
                    addPluginMainClassToPlugins(pluginsXML, mainClassName);
                    pomXML.xsiNamespace::build.plugins = pluginsXML;
                }
                else
                {
                    var xmlManifest:XML = null;
                    pluginsXML = XML(build.xsiNamespace::plugins);
                    plugins = pluginsXML.xsiNamespace::plugin;
                    for each (var p:XML in plugins)
                    {
                        var artifactId:String = String(p.xsiNamespace::artifactId);
                        if (artifactId == "maven-jar-plugin")
                        {
                            var manifest:XMLList = p.xsiNamespace::configuration.xsiNamespace::archive.xsiNamespace::manifest;
                            if (manifest.length() > 0)
                            {
                                xmlManifest = XML(p.xsiNamespace::configuration.xsiNamespace::archive.xsiNamespace::manifest);
                                break;
                            }
                        }
                    }

                    if (!xmlManifest)
                    {
                        addPluginMainClassToPlugins(pluginsXML, mainClassName);
                    }
                    else
                    {
                        var currentMainClass:String = String(xmlManifest.xsiNamespace::mainClass);
                        if (mainClassName != currentMainClass)
                        {
                            xmlManifest.xsiNamespace::mainClass = new XML("<mainClass>" + mainClassName + "</mainClass>");
                        }
                    }
                }
            }

            return pomXML;
        }

        private static function addPluginMainClassToPlugins(plugins:XML, mainClassName:String):void
        {
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            plugins.addNamespace(xsiNamespace);
            plugins.setNamespace(xsiNamespace);

            var plugin:XML = addPluginJarToPlugins(plugins);

            var conf:XML = new XML("<configuration>\n" +
                    "                    <archive>\n" +
                    "                      <manifest>\n" +
                    "                        <mainClass>" + mainClassName + "</mainClass>\n" +
                    "                      </manifest>\n" +
                    "                    </archive>\n" +
                    "                  </configuration>");
            conf.addNamespace(xsiNamespace);
            conf.setNamespace(xsiNamespace);

            plugin.appendChild(conf);
            plugins.appendChild(plugin);
        }

        private static function addPluginJarToPlugins(plugins:XML):XML
        {
            var xsiNamespace:Namespace = new Namespace("", "http://maven.apache.org/POM/4.0.0");
            var plugin:XML = new XML("<plugin>\n" +
                    "                  <groupId>org.apache.maven.plugins</groupId>\n" +
                    "                  <artifactId>maven-jar-plugin</artifactId>\n" +
                    "            </plugin>");
            plugin.addNamespace(xsiNamespace);
            plugin.setNamespace(xsiNamespace);

            plugins.appendChild(plugin);

            return plugin;
        }
    }
}
