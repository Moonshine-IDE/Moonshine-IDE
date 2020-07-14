import { ThreadAdapter } from './thread';
import { FrameAdapter } from './frame';
import { VariableAdapter } from './variable';
import { Scope } from 'vscode-debugadapter';
import { VariablesProvider } from './variablesProvider';

/**
 * Abstract adapter base class for a javascript scope.
 */
export abstract class ScopeAdapter implements VariablesProvider {

	public readonly variablesProviderId: number;
	public readonly referenceExpression = '';
	public get threadAdapter(): ThreadAdapter {
		return this.referenceFrame.threadAdapter;
	}

	public thisVariable?: VariableAdapter;
	public returnVariable?: VariableAdapter;

	protected constructor(
		public readonly name: string,
		public readonly referenceFrame: FrameAdapter
	) {
		this.threadAdapter.registerScopeAdapter(this);
		this.variablesProviderId = this.threadAdapter.debugSession.variablesProviders.register(this);
	}

	public static fromGrip(name: string, grip: FirefoxDebugProtocol.Grip, referenceFrame: FrameAdapter): ScopeAdapter {
		if ((typeof grip === 'object') && (grip.type === 'object')) {
			return new ObjectScopeAdapter(name, <FirefoxDebugProtocol.ObjectGrip>grip, referenceFrame);
		} else {
			return new SingleValueScopeAdapter(name, grip, referenceFrame);
		}
	}

	public addThis(thisValue: FirefoxDebugProtocol.Grip) {
		this.thisVariable = VariableAdapter.fromGrip(
			'this', this.referenceExpression, this.referenceFrame, thisValue, false, this.threadAdapter);
	}

	public addReturnValue(returnValue: FirefoxDebugProtocol.Grip) {
		this.returnVariable = VariableAdapter.fromGrip(
			'Return value', undefined, this.referenceFrame, returnValue, false, this.threadAdapter);
	}

	public getScope(): Scope {
		return new Scope(this.name, this.variablesProviderId);
	}

	public async getVariables(): Promise<VariableAdapter[]> {

		// we make a (shallow) copy of the variables array because we're going to modify it
		let variables = [ ...await this.getVariablesInt() ];

		if (this.thisVariable) {
			variables.unshift(this.thisVariable);
		}

		if (this.returnVariable) {
			variables.unshift(this.returnVariable);
		}

		return variables;
	}

	protected abstract getVariablesInt(): Promise<VariableAdapter[]>;

	public dispose(): void {
		this.threadAdapter.debugSession.variablesProviders.unregister(this.variablesProviderId);
	}
}

export class SingleValueScopeAdapter extends ScopeAdapter {

	private variableAdapter: VariableAdapter;

	public constructor(name: string, grip: FirefoxDebugProtocol.Grip, referenceFrame: FrameAdapter) {
		super(name, referenceFrame);
		this.variableAdapter = VariableAdapter.fromGrip(
			'', this.referenceExpression, this.referenceFrame, grip, false, this.threadAdapter);
	}

	protected getVariablesInt(): Promise<VariableAdapter[]> {
		return Promise.resolve([this.variableAdapter]);
	}
}

export class ObjectScopeAdapter extends ScopeAdapter {

	private variableAdapter: VariableAdapter;

	public constructor(name: string, object: FirefoxDebugProtocol.ObjectGrip, referenceFrame: FrameAdapter) {
		super(name, referenceFrame);
		this.variableAdapter = VariableAdapter.fromGrip(
			'', this.referenceExpression, this.referenceFrame, object, false, this.threadAdapter);
	}

	protected getVariablesInt(): Promise<VariableAdapter[]> {
		return this.variableAdapter.variablesProvider!.getVariables();
	}
}

export class LocalVariablesScopeAdapter extends ScopeAdapter {

	public variables: VariableAdapter[] = [];

	public constructor(name: string, variableDescriptors: FirefoxDebugProtocol.PropertyDescriptors, referenceFrame: FrameAdapter) {
		super(name, referenceFrame);

		for (let varname in variableDescriptors) {
			this.variables.push(VariableAdapter.fromPropertyDescriptor(
				varname, this.referenceExpression, this.referenceFrame,
				variableDescriptors[varname], false, this.threadAdapter));
		}

		VariableAdapter.sortVariables(this.variables);
	}

	protected getVariablesInt(): Promise<VariableAdapter[]> {
		return Promise.resolve(this.variables);
	}
}

export class FunctionScopeAdapter extends ScopeAdapter {

	public variables: VariableAdapter[] = [];

	public constructor(name: string, bindings: FirefoxDebugProtocol.FunctionBindings, referenceFrame: FrameAdapter) {
		super(name, referenceFrame);

		bindings.arguments.forEach((arg) => {
			for (let varname in arg) {
				this.variables.push(VariableAdapter.fromPropertyDescriptor(
					varname, this.referenceExpression, this.referenceFrame,
					arg[varname], false, this.threadAdapter));
			}
		});

		for (let varname in bindings.variables) {
			this.variables.push(VariableAdapter.fromPropertyDescriptor(
				varname, this.referenceExpression, this.referenceFrame,
				bindings.variables[varname], false, this.threadAdapter));
		}

		VariableAdapter.sortVariables(this.variables);
	}

	protected getVariablesInt(): Promise<VariableAdapter[]> {
		return Promise.resolve(this.variables);
	}
}
