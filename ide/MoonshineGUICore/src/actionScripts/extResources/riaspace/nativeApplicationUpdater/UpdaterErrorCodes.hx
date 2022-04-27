/*
	Copyright 2022 Prominic.NET, Inc.

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License

	Author: Prominic.NET, Inc.
	No warranty of merchantability or fitness of any kind.
	Use this software at your own risk.
 */

package actionScripts.extResources.riaspace.nativeApplicationUpdater;

class UpdaterErrorCodes {
	/**
	 * Not supported os type.
	 */
	public static final ERROR_9000:Int = 9000;

	/**
	 * Update package is not defined for current installerType.
	 */
	public static final ERROR_9001:Int = 9001;

	/**
	 * Error downloading update descriptor file.
	 */
	public static final ERROR_9002:Int = 9002;

	/**
	 * IO Error downloading update descriptor file.
	 */
	public static final ERROR_9003:Int = 9003;

	/**
	 * Error downloading update file.
	 */
	public static final ERROR_9004:Int = 9004;

	/**
	 * Error downloading update file.
	 */
	public static final ERROR_9005:Int = 9005;

	/**
	 * Contents/MacOS folder should contain only 1 install file.
	 */
	public static final ERROR_9006:Int = 9006;

	/**
	 * Mounted volume should contain only 1 install file.
	 */
	public static final ERROR_9007:Int = 9007;

	/**
	 * Error attaching dmg file.
	 */
	public static final ERROR_9008:Int = 9008;
}