import * as fs from 'fs-extra';
import { LogConfiguration, LogLevel } from '../../common/configuration';

enum NumericLogLevel { Debug, Info, Warn, Error }

/**
 * The logger used throughout the debug adapter.
 * It is configured using the `log` property in the launch or attach configuration.
 */
export class Log {

	private static startTime = Date.now();
	
	private static config: LogConfiguration = {};
	
	private static logs = new Map<string, Log>();
	private static fileDescriptor?: number;

	public static async setConfig(newConfig: LogConfiguration) {
		if (Log.fileDescriptor !== undefined) {
			await fs.close(Log.fileDescriptor);
			Log.fileDescriptor = undefined;
		}

		Log.config = newConfig;
		if (Log.config.fileName) {
			try {
				Log.fileDescriptor = await fs.open(Log.config.fileName, 'w');
			} catch(e) {}
		}

		Log.logs.forEach((log) => log.configure());
	}
	
	public static consoleLog: (msg: string) => void = console.log;
	
	public static create(name: string): Log {
		return new Log(name);
	}

	private fileLevel?: NumericLogLevel;
	private consoleLevel?: NumericLogLevel;
	private minLevel?: NumericLogLevel;
	
	constructor(private name: string) {
		this.configure();
		Log.logs.set(name, this);
	}

	public debug(msg: string): void {
		this.log(msg, NumericLogLevel.Debug, 'DEBUG');
	}
	
	public info(msg: string): void {
		this.log(msg, NumericLogLevel.Info, 'INFO ');
	}
	
	public warn(msg: string): void {
		this.log(msg, NumericLogLevel.Warn, 'WARN ');
	}
	
	public error(msg: string): void {
		this.log(msg, NumericLogLevel.Error, 'ERROR');
	}

	public isDebugEnabled(): boolean {
		return (this.minLevel !== undefined) && (this.minLevel <= NumericLogLevel.Debug);
	}

	public isInfoEnabled(): boolean {
		return (this.minLevel !== undefined) && (this.minLevel <= NumericLogLevel.Info);
	}

	public isWarnEnabled(): boolean {
		return (this.minLevel !== undefined) && (this.minLevel <= NumericLogLevel.Warn);
	}

	public isErrorEnabled(): boolean {
		return (this.minLevel !== undefined) && (this.minLevel <= NumericLogLevel.Error);
	}

	private configure() {
		this.fileLevel = undefined;
		if (Log.config.fileName && Log.config.fileLevel) {
			this.fileLevel = this.convertLogLevel(Log.config.fileLevel[this.name]);
			if (this.fileLevel === undefined) {
				this.fileLevel = this.convertLogLevel(Log.config.fileLevel['default']);
			}
		}
		if (Log.config.consoleLevel) {
			this.consoleLevel = this.convertLogLevel(Log.config.consoleLevel[this.name]);
			if (this.consoleLevel === undefined) {
				this.consoleLevel = this.convertLogLevel(Log.config.consoleLevel['default']);
			}
		}

		this.minLevel = this.fileLevel;
		if ((this.consoleLevel !== undefined) && 
			((this.minLevel === undefined) || (this.consoleLevel < this.minLevel))) {
			this.minLevel = this.consoleLevel;
		}
	}

	private convertLogLevel(logLevel: LogLevel): NumericLogLevel | undefined {
		if (!logLevel) {
			return undefined;
		}

		switch (logLevel) {
			case 'Debug':
			return NumericLogLevel.Debug;

			case 'Info':
			return NumericLogLevel.Info;

			case 'Warn':
			return NumericLogLevel.Warn;

			case 'Error':
			return NumericLogLevel.Error;
		}
	}

	private log(msg: string, level: NumericLogLevel, displayLevel: string) {
		if ((this.minLevel !== undefined) && (level >= this.minLevel)) {
			
			let elapsedTime = (Date.now() - Log.startTime) / 1000;
			let elapsedTimeString = elapsedTime.toFixed(3);
			while (elapsedTimeString.length < 7) {
				elapsedTimeString = '0' + elapsedTimeString;
			}
			let logMsg = displayLevel + '|' + elapsedTimeString + '|' + this.name + ': ' + msg;
			
			if ((Log.fileDescriptor !== undefined) && 
				(this.fileLevel !== undefined) && (level >= this.fileLevel)) {
				fs.write(Log.fileDescriptor, logMsg + '\n', (err, written, str) => {});
			}
			if ((this.consoleLevel !== undefined) && (level >= this.consoleLevel)) {
				Log.consoleLog(logMsg);
			}
		}
	}
}
