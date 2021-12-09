import { Log } from '../util/log';
import { ScopeAdapter, ObjectScopeAdapter, LocalVariablesScopeAdapter, FunctionScopeAdapter } from './scope';
import { FrameAdapter } from './frame';

let log = Log.create('EnvironmentAdapter');

/**
 * Abstract adapter base class for a lexical environment.
 * Used to create [`ScopeAdapter`](./scope.ts)s which then create `Scope` objects for VS Code.
 */
export abstract class EnvironmentAdapter<T extends FirefoxDebugProtocol.Environment> {

	protected environment: T;
	protected parent?: EnvironmentAdapter<FirefoxDebugProtocol.Environment>;

	public constructor(environment: T) {
		this.environment = environment;
		if (environment.parent !== undefined) {
			this.parent = EnvironmentAdapter.from(environment.parent);
		}
	}

	/** factory function for creating an EnvironmentAdapter of the appropriate type */
	public static from(environment: FirefoxDebugProtocol.Environment): EnvironmentAdapter<FirefoxDebugProtocol.Environment> {
		switch (environment.type) {
			case 'object':
				return new ObjectEnvironmentAdapter(<FirefoxDebugProtocol.ObjectEnvironment>environment);
			case 'function':
				return new FunctionEnvironmentAdapter(<FirefoxDebugProtocol.FunctionEnvironment>environment);
			case 'with':
				return new WithEnvironmentAdapter(<FirefoxDebugProtocol.WithEnvironment>environment);
			case 'block':
				return new BlockEnvironmentAdapter(<FirefoxDebugProtocol.BlockEnvironment>environment);
			default:
				throw new Error(`Unknown environment type ${environment.type}`);
		}
	}

	public getScopeAdapters(frameAdapter: FrameAdapter): ScopeAdapter[] {

		let scopes = this.getAllScopeAdapters(frameAdapter);

		return scopes;
	}

	protected getAllScopeAdapters(frameAdapter: FrameAdapter): ScopeAdapter[] {

		let scopes: ScopeAdapter[];

		if (this.parent !== undefined) {
			scopes = this.parent.getAllScopeAdapters(frameAdapter);
		} else {
			scopes = [];
		}

		let ownScope = this.getOwnScopeAdapter(frameAdapter);
		scopes.unshift(ownScope);

		return scopes;
	}

	protected abstract getOwnScopeAdapter(frameAdapter: FrameAdapter): ScopeAdapter;
}

export class ObjectEnvironmentAdapter extends EnvironmentAdapter<FirefoxDebugProtocol.ObjectEnvironment> {

	public constructor(environment: FirefoxDebugProtocol.ObjectEnvironment) {
		super(environment);
	}

	protected getOwnScopeAdapter(frameAdapter: FrameAdapter): ScopeAdapter {

		let grip = this.environment.object;

		if ((typeof grip === 'boolean') || (typeof grip === 'number') || (typeof grip === 'string')) {

			throw new Error(`Object environment with unexpected grip of type ${typeof grip}`);

		} else if (grip.type !== 'object') {

			throw new Error(`Object environment with unexpected grip of type ${grip.type}`);

		} else {

			let objectGrip = <FirefoxDebugProtocol.ObjectGrip>grip;
			let name = `Object: ${objectGrip.class}`;
			return new ObjectScopeAdapter(name, objectGrip, frameAdapter);

		}
	}
}

export class FunctionEnvironmentAdapter extends EnvironmentAdapter<FirefoxDebugProtocol.FunctionEnvironment> {

	public constructor(environment: FirefoxDebugProtocol.FunctionEnvironment) {
		super(environment);
	}

	protected getOwnScopeAdapter(frameAdapter: FrameAdapter): ScopeAdapter {

		let funcName = this.environment.function.displayName;
		let scopeName: string;
		if (funcName) {
			scopeName = `Local: ${funcName}`;
		} else {
			log.error(`Unexpected function in function environment: ${JSON.stringify(this.environment.function)}`);
			scopeName = '[unknown]';
		}

		return new FunctionScopeAdapter(scopeName, this.environment.bindings, frameAdapter);
	}
}

export class WithEnvironmentAdapter extends EnvironmentAdapter<FirefoxDebugProtocol.WithEnvironment> {

	public constructor(environment: FirefoxDebugProtocol.WithEnvironment) {
		super(environment);
	}

	protected getOwnScopeAdapter(frameAdapter: FrameAdapter): ScopeAdapter {

		let grip = this.environment.object;

		if ((typeof grip === 'boolean') || (typeof grip === 'number') || (typeof grip === 'string')) {

			throw new Error(`"with" environment with unexpected grip of type ${typeof grip}`);

		} else if (grip.type !== 'object') {

			throw new Error(`"with" environment with unexpected grip of type ${grip.type}`);

		} else {

			let objectGrip = <FirefoxDebugProtocol.ObjectGrip>grip;
			let name = `With: ${objectGrip.class}`;
			return new ObjectScopeAdapter(name, objectGrip, frameAdapter);

		}
	}
}

export class BlockEnvironmentAdapter extends EnvironmentAdapter<FirefoxDebugProtocol.BlockEnvironment> {

	public constructor(environment: FirefoxDebugProtocol.BlockEnvironment) {
		super(environment);
	}

	protected getOwnScopeAdapter(frameAdapter: FrameAdapter): ScopeAdapter {

		return new LocalVariablesScopeAdapter('Block', this.environment.bindings.variables, frameAdapter);

	}
}
