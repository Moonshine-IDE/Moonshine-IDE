import isAbsoluteUrl from 'is-absolute-url';
import { Log } from '../util/log';
import { isWindowsPlatform as detectWindowsPlatform } from '../../common/util';
import { ThreadAdapter } from './thread';
import { Registry } from './registry';

let log = Log.create('SkipFilesManager');

/**
 * This class determines which files should be skipped (aka blackboxed). Files to be skipped are
 * configured using the `skipFiles` configuration property or by using the context menu on a
 * stackframe in VS Code.
 */
export class SkipFilesManager {

	private readonly isWindowsPlatform = detectWindowsPlatform();

	/**
	 * Files that were configured to (not) be skipped by using the context menu on a
	 * stackframe in VS Code. This overrides the `skipFiles` configuration property.
	 */
	private readonly dynamicFiles = new Map<string, boolean>();

	public constructor(
		private readonly configuredFilesToSkip: RegExp[],
		private readonly threads: Registry<ThreadAdapter>
	) {}

	public shouldSkip(pathOrUrl: string): boolean {

		if (this.dynamicFiles.has(pathOrUrl)) {

			let result = this.dynamicFiles.get(pathOrUrl)!;

			if (log.isDebugEnabled()) {
				log.debug(`skipFile is set dynamically to ${result} for ${pathOrUrl}`);
			}

			return result;
		}

		let testee = pathOrUrl.replace('/./', '/');
		if (this.isWindowsPlatform && !isAbsoluteUrl(pathOrUrl)) {
			testee = testee.replace(/\\/g, '/');
		}
		for (let regExp of this.configuredFilesToSkip) {

			if (regExp.test(testee)) {

				if (log.isDebugEnabled()) {
					log.debug(`skipFile is set per configuration to true for ${pathOrUrl}`);
				}

				return true;
			}
		}

		if (log.isDebugEnabled()) {
			log.debug(`skipFile is not set for ${pathOrUrl}`);
		}

		return false;
	}

	public async toggleSkipping(pathOrUrl: string): Promise<void> {
		
		const skipFile = !this.shouldSkip(pathOrUrl);
		this.dynamicFiles.set(pathOrUrl, skipFile);

		log.info(`Setting skipFile to ${skipFile} for ${pathOrUrl}`);

		let promises: Promise<void>[] = [];

		for (const [, thread] of this.threads) {

			let sourceAdapters = thread.findSourceAdaptersForPathOrUrl(pathOrUrl);

			for (const sourceAdapter of sourceAdapters) {
				if (sourceAdapter.actor.source.isBlackBoxed !== skipFile) {
					promises.push(sourceAdapter.actor.setBlackbox(skipFile));
				}
			}

			thread.triggerStackframeRefresh();
		}

		await Promise.all(promises);
	}
}
