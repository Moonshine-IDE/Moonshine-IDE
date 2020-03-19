import { Log } from '../util/log';
import { VariablesProvider } from './variablesProvider';
import { Registry } from './registry';
import { DebugProtocol } from 'vscode-debugprotocol';
import { ObjectGripAdapter } from './objectGrip';

const log = Log.create('DataBreakpointsManager');

export class DataBreakpointsManager {

	private dataBreakpoints = new Set<string>();

	constructor(
		private readonly variablesProviders: Registry<VariablesProvider>
	) {}

	public static encodeDataId(variablesProviderId: number, property: string): string {
		return `${variablesProviderId}.${property}`;
	}

	public static decodeDataId(dataId: string): { variablesProviderId: number, property: string } {

		const separatorIndex = dataId.indexOf('.');

		return {
			variablesProviderId: +dataId.substring(0, separatorIndex),
			property: dataId.substring(separatorIndex + 1)
		};
	}

	public async setDataBreakpoints(newDataBreakpoints: DebugProtocol.DataBreakpoint[]): Promise<void> {

		log.debug(`Setting ${newDataBreakpoints.length} data breakpoints`);

		const oldDataBreakpoints = new Set<string>(this.dataBreakpoints);

		for (const dataBreakpoint of newDataBreakpoints) {
			if (!oldDataBreakpoints.has(dataBreakpoint.dataId)) {

				const type = (dataBreakpoint.accessType === 'read') ? 'get' : 'set';
				await this.addDataBreakpoint(dataBreakpoint.dataId, type);

			} else {
				oldDataBreakpoints.delete(dataBreakpoint.dataId);
			}
		}

		for (const dataBreakpoint of oldDataBreakpoints) {
			await this.removeDataBreakpoint(dataBreakpoint);
		}

		this.dataBreakpoints = new Set<string>(newDataBreakpoints.map(dataBreakpoint => dataBreakpoint.dataId));
	}

	private async addDataBreakpoint(dataId: string, type: 'get' | 'set'): Promise<void> {

		const { variablesProviderId, property } = DataBreakpointsManager.decodeDataId(dataId);
		const variablesProvider = this.variablesProviders.find(variablesProviderId);

		if (variablesProvider instanceof ObjectGripAdapter) {

			log.debug(`Adding data breakpoint for property ${property} of object #${variablesProviderId}`);

			await variablesProvider.actor.addWatchpoint(property, dataId, type);

		} else {
			log.warn(`Couldn't find object #${variablesProviderId}`);
		}
	}

	private async removeDataBreakpoint(dataId: string): Promise<void> {

		const { variablesProviderId, property } = DataBreakpointsManager.decodeDataId(dataId);
		const variablesProvider = this.variablesProviders.find(variablesProviderId);

		if (variablesProvider instanceof ObjectGripAdapter) {

			log.debug(`Removing data breakpoint for property ${property} of object #${variablesProviderId}`);

			await variablesProvider.actor.removeWatchpoint(property);

		} else {
			log.warn(`Couldn't find object #${variablesProviderId}`);
		}
	}
}
