import { VariablesProvider } from './variablesProvider';
import { VariableAdapter } from './variable';
import { FrameAdapter } from './frame';
import { ThreadAdapter } from './thread';
import { ObjectGripActorProxy } from '../firefox/actorProxy/objectGrip';

/**
 * Adapter class for a javascript object.
 */
export class ObjectGripAdapter implements VariablesProvider {

	public readonly variablesProviderId: number;
	public readonly actor: ObjectGripActorProxy;
	public get threadAdapter(): ThreadAdapter {
		return this.variableAdapter.threadAdapter;
	}
	/** a javascript expression for accessing the object represented by this adapter */
	public get referenceExpression(): string | undefined {
		return this.variableAdapter.referenceExpression;
	}
	/** the stackframe to use when executing the `referenceExpression` */
	public get referenceFrame(): FrameAdapter | undefined {
		return this.variableAdapter.referenceFrame;
	}

	public constructor(
		private readonly variableAdapter: VariableAdapter,
		objectGrip: FirefoxDebugProtocol.ObjectGrip,
		public threadLifetime: boolean,
		private readonly isPrototype: boolean
	) {
		this.actor = this.threadAdapter.debugSession.getOrCreateObjectGripActorProxy(objectGrip);
		this.actor.increaseRefCount();
		this.variablesProviderId = this.threadAdapter.debugSession.variablesProviders.register(this);
		this.threadAdapter.registerObjectGripAdapter(this);
	}

	/**
	 * get the referenced object's properties and its prototype as an array of Variables.
	 * This method can only be called when the thread is paused.
	 */
	public async getVariables(): Promise<VariableAdapter[]> {

		let prototypeAndProperties = await this.threadAdapter.coordinator.runOnPausedThread(
			() => this.actor.fetchPrototypeAndProperties());

		let variables: VariableAdapter[] = [];
		let symbolVariables: VariableAdapter[] = [];
		let safeGetterValues = prototypeAndProperties.safeGetterValues || {};
		let symbolProperties = prototypeAndProperties.ownSymbols || [];

		for (let varname in prototypeAndProperties.ownProperties) {
			if (!safeGetterValues[varname]) {
				variables.push(VariableAdapter.fromPropertyDescriptor(
					varname, this.referenceExpression, this.referenceFrame,
					prototypeAndProperties.ownProperties[varname],
					this.threadLifetime, this.threadAdapter));
			}
		}

		for (let varname in safeGetterValues) {
			variables.push(VariableAdapter.fromSafeGetterValueDescriptor(
				varname, this.referenceExpression, this.referenceFrame,
				safeGetterValues[varname],
				this.threadLifetime, this.threadAdapter));
		}

		for (let symbolProperty of symbolProperties) {
			symbolVariables.push(VariableAdapter.fromPropertyDescriptor(
				symbolProperty.name, undefined, undefined,
				symbolProperty.descriptor, this.threadLifetime, this.threadAdapter));
		}

		let prototypeVariable: VariableAdapter | undefined = undefined;
		let accessorsFromPrototypes: VariableAdapter[] = [];
		if (prototypeAndProperties.prototype.type !== 'null') {
			prototypeVariable = VariableAdapter.fromGrip(
				'__proto__', this.referenceExpression, this.referenceFrame,
				prototypeAndProperties.prototype,
				this.threadLifetime, this.threadAdapter
			);

			if (!this.isPrototype) {
				const prototypeLevels = this.threadAdapter.debugSession.config.liftAccessorsFromPrototypes;
				if (prototypeLevels > 0) {
					accessorsFromPrototypes = await this.fetchAccessorsFromPrototypes(prototypeVariable, prototypeLevels);
				}
			}
		}

		/** Array-Objects are already sorted, sorting them again as strings messes up the order */
		let isArray = (prototypeAndProperties.prototype.type == 'object' && prototypeAndProperties.prototype.class == 'Array');
		if (!isArray) {
			VariableAdapter.sortVariables(variables);
		}
		VariableAdapter.sortVariables(symbolVariables);
		VariableAdapter.sortVariables(accessorsFromPrototypes);
		variables.push(...symbolVariables);
		variables.push(...accessorsFromPrototypes);

		if (prototypeVariable) {
			variables.push(prototypeVariable);
		}

		return variables;
	}

	/**
	 * used to "lift" accessor properties from the prototype chain to an object if the
	 * `liftAccessorsFromPrototypes` configuration property is set.
	 * Have a look at the [`GetterValueAdapter`](./getterValue.ts) for more info.
	 */
	private async fetchAccessorsFromPrototypes(
		prototypeVariable: VariableAdapter,
		levels: number
	): Promise<VariableAdapter[]> {

		let objectGripAdapter: ObjectGripAdapter | undefined = <any>prototypeVariable.variablesProvider;
		let variables: VariableAdapter[] = [];
		let level = 0;
		while ((level < levels) && objectGripAdapter) {

			let prototypeAndProperties = await objectGripAdapter.actor.fetchPrototypeAndProperties();

			for (const varname in prototypeAndProperties.ownProperties) {

				const propertyDescriptor = prototypeAndProperties.ownProperties[varname];
				if ((varname !== '__proto__') && 
					(<FirefoxDebugProtocol.AccessorPropertyDescriptor>propertyDescriptor).get) {

					variables.push(VariableAdapter.fromPropertyDescriptor(
						varname, this.referenceExpression, this.referenceFrame,
						propertyDescriptor, this.threadLifetime, this.threadAdapter
					));
				}
			}

			prototypeVariable = VariableAdapter.fromGrip(
				'__proto__', this.referenceExpression, this.referenceFrame,
				prototypeAndProperties.prototype,
				this.threadLifetime, this.threadAdapter
			);
			objectGripAdapter = <any>prototypeVariable.variablesProvider;

			level++;
		}

		return variables;
	}

	public dispose(): void {
		this.actor.decreaseRefCount();
		this.threadAdapter.debugSession.variablesProviders.unregister(this.variablesProviderId);
	}
}
