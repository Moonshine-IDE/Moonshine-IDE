////////////////////////////////////////////////////////////////////////////////
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
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
////////////////////////////////////////////////////////////////////////////////

package actionScripts.plugin.actionscript.as3project.importer
{
	import actionScripts.plugin.actionscript.as3project.vo.AS3ProjectVO;
	import actionScripts.plugin.core.importer.FlashDevelopImporterBase;
	import actionScripts.utils.UtilsCore;
	import actionScripts.valueObjects.ConstantsCoreVO;
	
	public class FlashDevelopImporter extends FlashDevelopImporterBase
	{
		public static function parse(p:AS3ProjectVO):AS3ProjectVO
		{
			var data:XML = ConstantsCoreVO.AS3PROJ_CONFIG_SOURCE;
			
			// Parse XML file
			if (p)
			{
				p.classpaths.length = 0;
				p.resourcePaths.length = 0;
				p.targets.length = 0;
				
				p.swfOutput.parse(data.output, p);
				
				parsePaths(data.classpaths["class"], p.classpaths, p);
				parsePaths(data.moonshineResourcePaths["class"], p.resourcePaths, p);
				
				p.buildOptions.parse(data.build);
				
				parsePaths(data.includeLibraries.element, p.includeLibraries, p);
				parsePaths(data.libraryPaths.element, p.libraries, p);
				parsePaths(data.externalLibraryPaths.element, p.externalLibraries, p);
				parsePaths(data.rslPaths.element, p.runtimeSharedLibraries, p);
				
				p.assetLibrary = data.library;
				parsePaths(data.compileTargets.compile, p.targets, p);
				parsePaths(data.hiddenPaths.hidden, p.hiddenPaths, p);
				
				p.prebuildCommands = UtilsCore.deserializeString(data.preBuildCommand);
				p.postbuildCommands = UtilsCore.deserializeString(data.postBuildCommand);
				p.postbuildAlways = UtilsCore.deserializeBoolean(data.postBuildCommand.@alwaysRun);
				
				p.showHiddenPaths = UtilsCore.deserializeBoolean(data.options.option.@showHiddenPaths);
				
				p.testMovie = data.options.option.@testMovie;
				
				if (p.testMovie == AS3ProjectVO.TEST_MOVIE_CUSTOM || p.testMovie == AS3ProjectVO.TEST_MOVIE_OPEN_DOCUMENT)
				{
					p.testMovieCommand = data.options.option.@testMovieCommand;
				}
			}
			
			return p;
		}
	}
}