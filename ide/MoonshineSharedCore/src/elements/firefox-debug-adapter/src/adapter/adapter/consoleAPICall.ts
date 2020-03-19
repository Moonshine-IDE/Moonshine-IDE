import { VariablesProvider } from './variablesProvider';
import { VariableAdapter } from './variable';
import { ThreadAdapter } from './thread';

/**
 * Adapter class for representing a `consoleAPICall` event from Firefox.
 */
export class ConsoleAPICallAdapter implements VariablesProvider {

	public readonly variablesProviderId: number;
	public readonly referenceExpression = undefined;
	public readonly referenceFrame = undefined;

	public constructor(
		private readonly variables: VariableAdapter[],
		public readonly threadAdapter: ThreadAdapter
	) {
		this.variablesProviderId = threadAdapter.debugSession.variablesProviders.register(this);
	}

	public getVariables(): Promise<VariableAdapter[]> {
		return Promise.resolve(this.variables);
	}
}
