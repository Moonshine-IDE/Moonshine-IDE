import { DebugClient } from 'vscode-debugadapter-testsupport';
import { DebugProtocol } from 'vscode-debugprotocol';
import * as path from 'path';
import * as util from './util';
import * as assert from 'assert';

describe('Accessor properties: The debugger', function() {

	let dc: DebugClient;
	const TESTDATA_PATH = path.join(__dirname, '../../testdata');
	const SOURCE_PATH = path.join(TESTDATA_PATH, 'web/main.js');

	afterEach(async function() {
		await dc.stop();
	});

	it('should show accessor properties', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true);

		let properties = await startAndGetProperties(dc, 98, 'getterAndSetter()');

		assert.equal(util.findVariable(properties, 'getterProperty').value, 'Getter - expand to execute Getter');
		assert.equal(util.findVariable(properties, 'setterProperty').value, 'Setter');
		assert.equal(util.findVariable(properties, 'getterAndSetterProperty').value, 'Getter & Setter - expand to execute Getter');
	});

	it('should execute getters on demand', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true);

		let properties = await startAndGetProperties(dc, 98, 'getterAndSetter()');

		let getterProperty = util.findVariable(properties, 'getterProperty');
		let getterPropertyResponse = await dc.variablesRequest({ variablesReference: getterProperty.variablesReference });
		let getterValue = util.findVariable(getterPropertyResponse.body.variables, 'Value from Getter').value;
		assert.equal(getterValue, '17');

		let getterAndSetterProperty = util.findVariable(properties, 'getterAndSetterProperty');
		let getterAndSetterPropertyResponse = await dc.variablesRequest({ variablesReference: getterAndSetterProperty.variablesReference });
		let getterAndSetterValue = util.findVariable(getterAndSetterPropertyResponse.body.variables, 'Value from Getter').value;
		assert.equal(getterAndSetterValue, '23');
	});

	it('should execute nested getters', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true);

		let properties1 = await startAndGetProperties(dc, 98, 'getterAndSetter()');

		let getterProperty1 = util.findVariable(properties1, 'nested');
		let getterPropertyResponse1 = await dc.variablesRequest({ variablesReference: getterProperty1.variablesReference });
		let getterValue1 = util.findVariable(getterPropertyResponse1.body.variables, 'Value from Getter');

		let propertiesResponse2 = await dc.variablesRequest({ variablesReference: getterValue1.variablesReference });
		let properties2 = propertiesResponse2.body.variables;

		let getterProperty2 = util.findVariable(properties2, 'z');
		let getterPropertyResponse2 = await dc.variablesRequest({ variablesReference: getterProperty2.variablesReference });
		let getterValue2 = util.findVariable(getterPropertyResponse2.body.variables, 'Value from Getter').value;

		assert.equal(getterValue2, '"foo"');
	});

	it('should show and execute getters lifted from prototypes', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true, { liftAccessorsFromPrototypes: 2 });

		let properties1 = await startAndGetProperties(dc, 116, 'protoGetter()');

		let getterProperty1 = util.findVariable(properties1, 'y');
		let getterPropertyResponse1 = await dc.variablesRequest({ variablesReference: getterProperty1.variablesReference });
		let getterValue1 = util.findVariable(getterPropertyResponse1.body.variables, 'Value from Getter').value;
		assert.equal(getterValue1, '"foo"');

		let getterProperty2 = util.findVariable(properties1, 'z');
		let getterPropertyResponse2 = await dc.variablesRequest({ variablesReference: getterProperty2.variablesReference });
		let getterValue2 = util.findVariable(getterPropertyResponse2.body.variables, 'Value from Getter').value;
		assert.equal(getterValue2, '"bar"');
	});

	it('should only scan the configured number of prototypes for accessors to lift', async function() {

		dc = await util.initDebugClient(TESTDATA_PATH, true, { liftAccessorsFromPrototypes: 1 });

		let properties = await startAndGetProperties(dc, 116, 'protoGetter()');

		util.findVariable(properties, 'y');
		assert.throws(() => util.findVariable(properties, 'z'));
	});

	async function startAndGetProperties(dc: DebugClient, bpLine: number, trigger: string): Promise<DebugProtocol.Variable[]> {

		await util.setBreakpoints(dc, SOURCE_PATH, [ bpLine ]);
	
		util.evaluate(dc, trigger);
		let stoppedEvent = await util.receiveStoppedEvent(dc);
		let stackTrace = await dc.stackTraceRequest({ threadId: stoppedEvent.body.threadId! });
		let scopes = await dc.scopesRequest({ frameId: stackTrace.body.stackFrames[0].id });
	
		let variablesResponse = await dc.variablesRequest({ variablesReference: scopes.body.scopes[0].variablesReference });
		let variable = util.findVariable(variablesResponse.body.variables, 'x');
		let propertiesResponse = await dc.variablesRequest({ variablesReference: variable.variablesReference });
		return propertiesResponse.body.variables;
	}
});
