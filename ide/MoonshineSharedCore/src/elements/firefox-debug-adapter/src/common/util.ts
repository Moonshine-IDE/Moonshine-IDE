import * as os from 'os';

export function delay(timeout: number): Promise<void> {
	return new Promise<void>((resolve) => {
		setTimeout(resolve, timeout);
	});
}

export function isWindowsPlatform(): boolean {
	return (os.platform() === 'win32');
}
