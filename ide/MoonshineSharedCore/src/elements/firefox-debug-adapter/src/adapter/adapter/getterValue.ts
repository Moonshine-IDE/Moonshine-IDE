import { VariablesProvider } from './variablesProvider';
import { ThreadAdapter } from './thread';
import { FrameAdapter } from './frame';
import { VariableAdapter } from './variable';

/**
 * Adapter class for an accessor property with a getter (i.e. a property defined using
 * [`Object.defineProperty()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/defineProperty)
 * with an accessor descriptor containing a `get` function or using the new ES6 syntax for defining
 * accessors).
 * The value of such a property can only be determined by executing the getter function, but that may
 * have side-effects. Therefore it is not executed and the corresponding [`VariableAdapter`](./variable.ts)
 * will show a text like "Getter & Setter - expand to execute Getter" to the user. When the user
 * clicks on this text, the getter will be executed by the `getVariables()` method and the value
 * will be displayed.
 * 
 * Note that if the accessor property is not defined on the object itself but on one of its
 * prototypes, the user would have to navigate to the prototype to find it and if he then executed
 * the getter, it would be executed with `this` set to the prototype, which is usually not the
 * desired behavior. Therefore it is possible to "lift" accessor properties to an object from its
 * prototype chain using the `liftAccessorsFromPrototypes` configuration property.
 */
export class GetterValueAdapter implements VariablesProvider {

	public readonly variablesProviderId: number;
	public get threadAdapter(): ThreadAdapter {
		return this.variableAdapter.threadAdapter;
	}
	/** a javascript expression that will execute the getter */
	public get referenceExpression(): string | undefined {
		return this.variableAdapter.referenceExpression;
	}
	/** the stackframe to use when executing the `referenceExpression` */
	public get referenceFrame(): FrameAdapter | undefined {
		return this.variableAdapter.referenceFrame;
	}

	public constructor(private readonly variableAdapter: VariableAdapter) {
		this.variablesProviderId = this.threadAdapter.debugSession.variablesProviders.register(this);
	}

	/** execute the getter and return a VariableAdapter for the value returned by the getter */
	public async getVariables(): Promise<VariableAdapter[]> {
		if (this.referenceExpression && this.referenceFrame) {

			const grip = await this.threadAdapter.coordinator.evaluate(
				this.referenceExpression, this.referenceFrame.frame.actor
			);

			const variableAdapter = VariableAdapter.fromGrip(
				'Value from Getter', this.referenceExpression, this.referenceFrame,
				grip, false, this.threadAdapter, true
			);

			return [ variableAdapter ];

		} else {
			return [];
		}
	}
}
