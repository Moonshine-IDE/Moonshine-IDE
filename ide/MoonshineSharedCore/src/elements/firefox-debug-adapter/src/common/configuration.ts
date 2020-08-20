import { DebugProtocol } from 'vscode-debugprotocol';

/**
 * A launch configuration, as provided by VS Code
 */
export interface LaunchConfiguration extends CommonConfiguration, DebugProtocol.LaunchRequestArguments {
	request: 'launch';
	file?: string;
	tmpDir?: string;
	profile?: string;
	keepProfileChanges?: boolean;
	preferences?: { [key: string]: boolean | number | string | null };
	port?: number;
	firefoxArgs?: string[];
	timeout?: number;
	reAttach?: boolean;
}

/**
 * An attach configuration, as provided by VS Code
 */
export interface AttachConfiguration extends CommonConfiguration, DebugProtocol.AttachRequestArguments {
	request: 'attach';
	port?: number;
	host?: string;
}

/**
 * Common properties of launch and attach configurations
 */
export interface CommonConfiguration {
	request: 'launch' | 'attach';
	url?: string;
	webRoot?: string;
	firefoxExecutable?: string;
	profileDir?: string;
	reloadOnAttach?: boolean;
	reloadOnChange?: ReloadConfiguration;
	tabFilter?: TabFilterConfiguration;
	clearConsoleOnReload?: boolean;
	pathMappings?: { url: string, path: string | null }[];
	skipFiles?: string[];
	showConsoleCallLocation?: boolean;
	log?: LogConfiguration;
	addonPath?: string;
	popupAutohideButton?: boolean;
	liftAccessorsFromPrototypes?: number;
	suggestPathMappingWizard?: boolean;
}

export type ReloadConfiguration = string | string[] | DetailedReloadConfiguration;

export interface DetailedReloadConfiguration {
	watch: string | string[];
	ignore?: string | string[];
	debounce?: number | boolean;
}

export type TabFilterConfiguration = string | string[] | DetailedTabFilterConfiguration;

export interface DetailedTabFilterConfiguration {
	include?: string | string[];
	exclude?: string | string[];
}

export declare type LogLevel = 'Debug' | 'Info' | 'Warn' | 'Error';

export interface LogConfiguration {
	fileName?: string;
	fileLevel?: { [logName: string]: LogLevel };
	consoleLevel?: { [logName: string]: LogLevel };
}
