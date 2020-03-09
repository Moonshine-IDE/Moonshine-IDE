import { Log } from '../util/log';
import { ThreadAdapter } from './thread';
import { ObjectGripAdapter } from './objectGrip';
import { FrameAdapter } from './frame';
import { Variable } from 'vscode-debugadapter';
import { DebugProtocol } from 'vscode-debugprotocol';
import { accessorExpression } from '../util/misc';
import { renderPreview } from './preview';
import { VariablesProvider } from './variablesProvider';
import { GetterValueAdapter } from './getterValue';

let log = Log.create('VariableAdapter');

/**
 * Adapter class for anything that will be sent to VS Code as a Variable.
 * At the very least a Variable needs a name and a string representation of its value.
 * If the VariableAdapter represents anything that can have child variables, it also needs a
 * [`VariablesProvider`](./variablesProvider.ts) that will be used to fetch the child variables when
 * requested by VS Code.
 */
export class VariableAdapter {

	private _variablesProvider: VariablesProvider | undefined;

	public get variablesProvider(): VariablesProvider | undefined {
		return this._variablesProvider;
	}

	public constructor(
		public readonly varname: string,
		public readonly referenceExpression: string | undefined,
		public readonly referenceFrame: FrameAdapter | undefined,
		public readonly displayValue: string,
		public readonly threadAdapter: ThreadAdapter
	) {}

	public getVariable(): Variable {

		let variable = new Variable(this.varname, this.displayValue,
			this.variablesProvider ? this.variablesProvider.variablesProviderId : undefined);

		(<DebugProtocol.Variable>variable).evaluateName = this.referenceExpression;

		return variable;
	}

	/**
	 * factory function for creating a VariableAdapter from an
	 * [object grip](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#objects)
	 */
	public static fromGrip(
		varname: string,
		parentReferenceExpression: string | undefined,
		referenceFrame: FrameAdapter | undefined,
		grip: FirefoxDebugProtocol.Grip,
		threadLifetime: boolean,
		threadAdapter: ThreadAdapter,
		useParentReferenceExpression?: boolean
	): VariableAdapter {

		let referenceExpression =
			useParentReferenceExpression ?
			parentReferenceExpression :
			accessorExpression(parentReferenceExpression, varname);

		if ((typeof grip === 'boolean') || (typeof grip === 'number')) {

			return new VariableAdapter(varname, referenceExpression, referenceFrame, grip.toString(), threadAdapter);

		} else if (typeof grip === 'string') {

			return new VariableAdapter(varname, referenceExpression, referenceFrame, `"${grip}"`, threadAdapter);

		} else {

			switch (grip.type) {

				case 'null':
				case 'undefined':
				case 'Infinity':
				case '-Infinity':
				case 'NaN':
				case '-0':

					return new VariableAdapter(
						varname, referenceExpression, referenceFrame, grip.type, threadAdapter);

				case 'BigInt':

					return new VariableAdapter(
						varname, referenceExpression, referenceFrame,
						`${(<FirefoxDebugProtocol.BigIntGrip>grip).text}n`, threadAdapter);

				case 'longString':

					return new VariableAdapter(
						varname, referenceExpression, referenceFrame,
						(<FirefoxDebugProtocol.LongStringGrip>grip).initial, threadAdapter);

				case 'symbol':

					let symbolName = (<FirefoxDebugProtocol.SymbolGrip>grip).name;
					return new VariableAdapter(
						varname, referenceExpression, referenceFrame,
						`Symbol(${symbolName})`, threadAdapter);

				case 'object':

					let objectGrip = <FirefoxDebugProtocol.ObjectGrip>grip;
					let displayValue = renderPreview(objectGrip);
					let variableAdapter = new VariableAdapter(
						varname, referenceExpression, referenceFrame, displayValue, threadAdapter);
					variableAdapter._variablesProvider = new ObjectGripAdapter(
						variableAdapter, objectGrip, threadLifetime, (varname === '__proto__'));
					return variableAdapter;

				default:

					log.warn(`Unexpected object grip of type ${grip.type}: ${JSON.stringify(grip)}`);
					return new VariableAdapter(
						varname, referenceExpression, referenceFrame, grip.type, threadAdapter);

			}
		}
	}

	/**
	 * factory function for creating a VariableAdapter from a
	 * [property descriptor](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#property-descriptors)
	 */
	public static fromPropertyDescriptor(
		varname: string,
		parentReferenceExpression: string | undefined,
		referenceFrame: FrameAdapter | undefined,
		propertyDescriptor: FirefoxDebugProtocol.PropertyDescriptor,
		threadLifetime: boolean,
		threadAdapter: ThreadAdapter
	): VariableAdapter {

		if ((<FirefoxDebugProtocol.DataPropertyDescriptor>propertyDescriptor).value !== undefined) {

			return VariableAdapter.fromGrip(
				varname, parentReferenceExpression, referenceFrame,
				(<FirefoxDebugProtocol.DataPropertyDescriptor>propertyDescriptor).value,
				threadLifetime, threadAdapter);

		} else {

			let referenceExpression = accessorExpression(parentReferenceExpression, varname);

			let accessorPropertyDescriptor = <FirefoxDebugProtocol.AccessorPropertyDescriptor>propertyDescriptor;
			let hasGetter = VariableAdapter.isFunctionGrip(accessorPropertyDescriptor.get);
			let hasSetter = VariableAdapter.isFunctionGrip(accessorPropertyDescriptor.set);
			let displayValue: string;
			if (hasGetter) {
				displayValue = 'Getter';
				if (hasSetter) {
					displayValue += ' & Setter';
				}
				displayValue += ' - expand to execute Getter';
			} else if (hasSetter) {
				displayValue = 'Setter';
			} else {
				log.error(`${referenceExpression} is neither a data property nor does it have a getter or setter`);
				displayValue = 'Error';
			}

			let variableAdapter = new VariableAdapter(
				varname, referenceExpression, referenceFrame, displayValue, threadAdapter);

			if (hasGetter) {
				variableAdapter._variablesProvider = new GetterValueAdapter(variableAdapter);
			}

			return variableAdapter;

		}
	}

	/**
	 * factory function for creating a VariableAdapter from a
	 * [safe getter value descriptor](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#property-descriptors)
	 */
	public static fromSafeGetterValueDescriptor(
		varname: string,
		parentReferenceExpression: string | undefined,
		referenceFrame: FrameAdapter | undefined,
		safeGetterValueDescriptor: FirefoxDebugProtocol.SafeGetterValueDescriptor,
		threadLifetime: boolean,
		threadAdapter: ThreadAdapter
	): VariableAdapter {

		return VariableAdapter.fromGrip(
			varname, parentReferenceExpression, referenceFrame,
			safeGetterValueDescriptor.getterValue, threadLifetime, threadAdapter);
	}

	public static sortVariables(variables: VariableAdapter[]): void {
		variables.sort((var1, var2) => VariableAdapter.compareStrings(var1.varname, var2.varname));
	}

	private static compareStrings(s1: string, s2: string): number {
		if (s1 < s2) {
			return -1;
		} else if (s1 === s2) {
			return 0;
		} else {
			return 1;
		}
	}

	private static isFunctionGrip(grip: FirefoxDebugProtocol.Grip) {
		return (
			(typeof grip === 'object') &&
			(grip.type === 'object') &&
			((<FirefoxDebugProtocol.ObjectGrip>grip).class === 'Function')
		);
	}
}
