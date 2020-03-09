import { Log } from '../util/log';
import { ThreadAdapter } from './thread';
import { EnvironmentAdapter } from './environment';
import { ScopeAdapter } from './scope';
import { StackFrame } from 'vscode-debugadapter';
import { Registry } from './registry';
import { FrameActorProxy } from '../firefox/actorProxy/frame';

let log = Log.create('FrameAdapter');

/**
 * Adapter class for a stackframe.
 */
export class FrameAdapter {

	public readonly id: number;
	private _scopeAdapters?: ScopeAdapter[];

	public constructor(
		private readonly frameRegistry: Registry<FrameAdapter>,
		public readonly frame: FirefoxDebugProtocol.Frame,
		public readonly threadAdapter: ThreadAdapter
	) {
		this.id = frameRegistry.register(this);
	}

	public async getStackframe(): Promise<StackFrame> {

		let sourceActorName = this.frame.where.actor;
		let sourceAdapter = await this.threadAdapter.findSourceAdapterForActorName(sourceActorName);

		let name: string;
		switch (this.frame.type) {

			case 'call':
				const callFrame = this.frame as FirefoxDebugProtocol.CallFrame;
				name = callFrame.displayName || '[anonymous function]';
				break;

			case 'global':
				name = '[Global]';
				break;

			case 'eval':
			case 'clientEvaluate':
				name = '[eval]';
				break;

			case 'wasmcall':
				name = '[wasm]';
				break;

			default:
				name = `[${this.frame.type}]`;
				log.error(`Unexpected frame type ${this.frame.type}`);
				break;
		}

		return new StackFrame(this.id, name, sourceAdapter.source,
			this.frame.where.line, (this.frame.where.column || 0) + 1);
	}

	public async getScopeAdapters(): Promise<ScopeAdapter[]> {

		if (!this._scopeAdapters) {

			const frameActor = new FrameActorProxy(this.frame, this.threadAdapter.debugSession.firefoxDebugConnection);
			const environment = await frameActor.getEnvironment();
			frameActor.dispose();

			const environmentAdapter = EnvironmentAdapter.from(environment);
			this._scopeAdapters = environmentAdapter.getScopeAdapters(this);
			if (this.frame.this !== undefined) {
				this._scopeAdapters[0].addThis(this.frame.this);
			}
		}

		return this._scopeAdapters;
	}

	public dispose(): void {
		this.frameRegistry.unregister(this.id);
	}
}
