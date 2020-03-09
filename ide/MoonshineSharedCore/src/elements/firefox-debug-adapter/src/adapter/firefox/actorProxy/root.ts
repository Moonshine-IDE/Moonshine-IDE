import { Log } from '../../util/log';
import { EventEmitter } from 'events';
import { PendingRequests } from '../../util/pendingRequests';
import { PathMapper } from '../../util/pathMapper';
import { ActorProxy } from './interface';
import { TabActorProxy } from './tab';
import { ConsoleActorProxy } from './console';
import { PreferenceActorProxy } from './preference';
import { AddonsActorProxy } from './addons';
import { DebugConnection } from '../connection';

let log = Log.create('RootActorProxy');

export type FetchTabsResult = {
	tabs: Map<string, [TabActorProxy, ConsoleActorProxy]>,
	preference: PreferenceActorProxy,
	addons: AddonsActorProxy | undefined
};

/**
 * Proxy class for a root actor
 * ([docs](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#the-root-actor),
 * [spec](https://github.com/mozilla/gecko-dev/blob/master/devtools/shared/specs/root.js))
 */
export class RootActorProxy extends EventEmitter implements ActorProxy {

	private tabs = new Map<string, [TabActorProxy, ConsoleActorProxy]>();
	private pendingProcessRequests = new PendingRequests<[TabActorProxy, ConsoleActorProxy]>();
	private pendingTabsRequests = new PendingRequests<FetchTabsResult>();
	private pendingAddonsRequests = new PendingRequests<FirefoxDebugProtocol.Addon[]>();

	constructor(
		private readonly pathMapper: PathMapper,
		private readonly connection: DebugConnection
	) {
		super();
		this.connection.register(this);
	}

	public get name() {
		return 'root';
	}

	public fetchProcess(): Promise<[TabActorProxy, ConsoleActorProxy]> {

		log.debug('Fetching process');

		return new Promise<[TabActorProxy, ConsoleActorProxy]>((resolve, reject) => {
			this.pendingProcessRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ to: this.name, type: 'getProcess' });
		})
	}

	public fetchTabs(): Promise<FetchTabsResult> {

		log.debug('Fetching tabs');

		return new Promise<FetchTabsResult>((resolve, reject) => {
			this.pendingTabsRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ to: this.name, type: 'listTabs' });
		})
	}

	public fetchAddons(): Promise<FirefoxDebugProtocol.Addon[]> {

		log.debug('Fetching addons');

		return new Promise<FirefoxDebugProtocol.Addon[]>((resolve, reject) => {
			this.pendingAddonsRequests.enqueue({ resolve, reject });
			this.connection.sendRequest({ to: this.name, type: 'listAddons' });
		})
	}

	public receiveResponse(response: FirefoxDebugProtocol.Response): void {

		if (response['applicationType']) {

			this.emit('init', response);

		} else if (response['tabs']) {

			let tabsResponse = <FirefoxDebugProtocol.TabsResponse>response;
			let currentTabs = new Map<string, [TabActorProxy, ConsoleActorProxy]>();

			// sometimes Firefox returns 0 tabs if the listTabs request was sent 
			// shortly after launching it
			if (tabsResponse.tabs.length === 0) {
				log.info('Received 0 tabs - will retry in 100ms');

				setTimeout(() => {
					this.connection.sendRequest({ to: this.name, type: 'listTabs' });
				}, 100);

				return;
			}

			log.debug(`Received ${tabsResponse.tabs.length} tabs`);

			// convert the Tab array into a map of TabActorProxies, re-using already 
			// existing proxies and emitting tabOpened events for new ones
			tabsResponse.tabs.forEach((tab) => {

				let actorsForTab: [TabActorProxy, ConsoleActorProxy];
				if (this.tabs.has(tab.actor)) {

					actorsForTab = this.tabs.get(tab.actor)!;

				} else {

					log.debug(`Tab ${tab.actor} opened`);

					actorsForTab = [
						new TabActorProxy(
							tab.actor, tab.title, tab.url, this.pathMapper, this.connection),
						new ConsoleActorProxy(tab.consoleActor, this.connection)
					];
					this.emit('tabOpened', actorsForTab);

				}
				currentTabs.set(tab.actor, actorsForTab);
			});

			// emit tabClosed events for tabs that have disappeared
			this.tabs.forEach((actorsForTab) => {
				if (!currentTabs.has(actorsForTab[0].name)) {
					log.debug(`Tab ${actorsForTab[0].name} closed`);
					this.emit('tabClosed', actorsForTab);
				}
			});					

			this.tabs = currentTabs;

			let preferenceActor = this.connection.getOrCreate(tabsResponse.preferenceActor,
				() => new PreferenceActorProxy(tabsResponse.preferenceActor, this.connection));

			let addonsActor: AddonsActorProxy | undefined;
			const addonsActorName = tabsResponse.addonsActor;
			if (addonsActorName) {
				addonsActor = this.connection.getOrCreate(addonsActorName,
					() => new AddonsActorProxy(addonsActorName, this.connection));
			}
	
			this.pendingTabsRequests.resolveOne({
				tabs: currentTabs, 
				preference: preferenceActor, 
				addons: addonsActor
			});

		} else if (response['type'] === 'tabListChanged') {

			log.debug('Received tabListChanged event');
			
			this.emit('tabListChanged');

		} else if (response['addons']) {

			let addonsResponse = <FirefoxDebugProtocol.AddonsResponse>response;
			log.debug(`Received ${addonsResponse.addons.length} addons`);
			this.pendingAddonsRequests.resolveOne(addonsResponse.addons);

		} else if (response['type'] === 'addonListChanged') {

			log.debug('Received addonListChanged event');
			
			this.emit('addonListChanged');

		} else if (response['form']) {

			let processResponse = <FirefoxDebugProtocol.ProcessResponse>response;
			log.debug('Received getProcess response');
			this.pendingProcessRequests.resolveOne([
				new TabActorProxy(
					processResponse.form.actor, 'Browser', processResponse.form.url,
					this.pathMapper, this.connection),
				new ConsoleActorProxy(processResponse.form.consoleActor, this.connection)
			]);

		} else {

			if (response['type'] === 'forwardingCancelled') {
				log.debug(`Received forwardingCancelled event from ${this.name} (ignoring)`);
			} else {
				log.warn("Unknown message from RootActor: " + JSON.stringify(response));
			}

		}
	}

	public onInit(cb: (response: FirefoxDebugProtocol.InitialResponse) => void) {
		this.on('init', cb);
	}

	public onTabOpened(cb: (actorsForTab: [TabActorProxy, ConsoleActorProxy]) => void) {
		this.on('tabOpened', cb);
	}

	public onTabClosed(cb: (actorsForTab: [TabActorProxy, ConsoleActorProxy]) => void) {
		this.on('tabClosed', cb);
	}

	public onTabListChanged(cb: () => void) {
		this.on('tabListChanged', cb);
	}

	public onAddonListChanged(cb: () => void) {
		this.on('addonListChanged', cb);
	}
}
