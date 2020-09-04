import { Log } from '../util/log';

const log = Log.create('Preview');

const maxProperties = 5;
const maxArrayItems = 5;
const maxStringChars = 20;
const maxAttributes = 5;
const maxParameters = 5;

/** generates the preview string for an object shown in the debugger's Variables view */
export function renderPreview(objectGrip: FirefoxDebugProtocol.ObjectGrip): string {
	try {

		if ((objectGrip.class === 'Function') || 
			(objectGrip as FirefoxDebugProtocol.FunctionGrip).parameterNames) {

			if (objectGrip.class !== 'Function') {
				log.warn(`Looks like a FunctionGrip but has a different class: ${JSON.stringify(objectGrip)}`);
			}
			return renderFunctionGrip(<FirefoxDebugProtocol.FunctionGrip>objectGrip);
		}

		const preview = objectGrip.preview;
		if (!preview) {
			return objectGrip.class;
		}

		if (preview.kind === 'Object') {

			return renderObjectPreview(preview, objectGrip.class);

		} else if (preview.kind === 'ArrayLike') {

			return renderArrayLikePreview(preview, objectGrip.class);

		} else if ((objectGrip.class === 'Date') && (preview.kind === undefined)) {

			const date = new Date(preview.timestamp);
			return date.toString();

		} else if (preview.kind === 'ObjectWithURL') {

			return `${objectGrip.class} ${preview.url}`;

		} else if ((preview.kind === 'DOMNode') && (preview.nodeType === 1)) {

			return renderDOMElementPreview(preview);

		} else if (preview.kind === 'Error') {

			return `${objectGrip.class}: ${preview.message}`;

		} else {

			return objectGrip.class;

		}

	} catch (e) {
		log.error(`renderPreview failed for ${JSON.stringify(objectGrip)}: ${e}`);
		return '';
	}
}

function renderObjectPreview(preview: FirefoxDebugProtocol.ObjectPreview, className: string): string {

	const renderedProperties: string[] = [];
	let i = 0;
	for (const property in preview.ownProperties) {

		var valueGrip = preview.ownProperties[property].value;
		if (!valueGrip) {
			continue;
		}

		const renderedValue = renderGrip(valueGrip);
		renderedProperties.push(`${property}: ${renderedValue}`);

		if (++i >= maxProperties) {
			renderedProperties.push('\u2026');
			break;
		}
	}

	if (i < maxProperties) {
		for (const symbolProperty of preview.ownSymbols) {

			const renderedValue = renderGrip(symbolProperty.descriptor.value);
			renderedProperties.push(`Symbol(${symbolProperty.name}): ${renderedValue}`);

			if (++i >= maxProperties) {
				renderedProperties.push('\u2026');
				break;
			}
		}
	}

	const renderedObject = `{${renderedProperties.join(', ')}}`;

	if (className === 'Object') {
		return renderedObject;
	} else {
		return `${className} ${renderedObject}`;
	}
}

function renderDOMElementPreview(preview: FirefoxDebugProtocol.DOMNodePreview): string {

	if (!preview.attributes) {
		return `<${preview.nodeName}>`;
	}

	const renderedAttributes: string[] = [];
	let i = 0;
	for (const attribute in preview.attributes) {

		const renderedValue = renderGrip(preview.attributes[attribute]);
		renderedAttributes.push(`${attribute}=${renderedValue}`);

		if (++i >= maxAttributes) {
			renderedAttributes.push('\u2026');
			break;
		}
	}

	if (renderedAttributes.length === 0) {
		return `<${preview.nodeName}>`;
	} else {
		return `<${preview.nodeName} ${renderedAttributes.join(' ')}>`;
	}
}

function renderArrayLikePreview(preview: FirefoxDebugProtocol.ArrayLikePreview, className: string): string {

	let result = `${className}(${preview.length})`;

	if (preview.items && preview.items.length > 0) {

		const renderCount = Math.min(preview.items.length, maxArrayItems);
		const itemsToRender = preview.items.slice(0, renderCount);
		const renderedItems = itemsToRender.map(item => renderGripOrNull(item));

		if (renderCount < preview.items.length) {
			renderedItems.push('\u2026');
		}

		result += ` [${renderedItems.join(', ')}]`;

	}

	return result;
}

function renderFunctionGrip(functionGrip: FirefoxDebugProtocol.FunctionGrip): string {

	let parameters = '';

	if (functionGrip.parameterNames &&
		functionGrip.parameterNames.every(parameterName => typeof parameterName === 'string')) {

		let parameterNames = functionGrip.parameterNames;
		if (parameterNames.length > maxParameters) {
			parameterNames = parameterNames.slice(0, maxParameters);
			parameterNames.push('\u2026');
		}

		parameters = parameterNames.join(', ');
	}

	const functionName = functionGrip.displayName || functionGrip.name || 'function';
	return `${functionName}(${parameters}) {\u2026}`;
}

function renderGripOrNull(gripOrNull: FirefoxDebugProtocol.Grip | null): string {
	if (gripOrNull === null) {
		return "_";
	} else {
		return renderGrip(gripOrNull);
	}
}

function renderGrip(grip: FirefoxDebugProtocol.Grip): string {

	if ((typeof grip === 'boolean') || (typeof grip === 'number')) {

		return grip.toString();

	} else if (typeof grip === 'string') {

		if (grip.length > maxStringChars) {
			return `"${grip.substr(0, maxStringChars)}\u2026"`;
		} else {
			return `"${grip}"`;
		}

	} else {

		switch (grip.type) {

			case 'null':
			case 'undefined':
			case 'Infinity':
			case '-Infinity':
			case 'NaN':
			case '-0':

				return grip.type;

			case 'BigInt':

				return `${(<FirefoxDebugProtocol.BigIntGrip>grip).text}n`;

			case 'longString':

				const initial = (<FirefoxDebugProtocol.LongStringGrip>grip).initial;
				if (initial.length > maxStringChars) {
					return `${initial.substr(0, maxStringChars)}\u2026`;
				} else {
					return initial;
				}
		
			case 'symbol':

				let symbolName = (<FirefoxDebugProtocol.SymbolGrip>grip).name;
				return `Symbol(${symbolName})`;

			case 'object':

				let objectGrip = <FirefoxDebugProtocol.ObjectGrip>grip;
				return renderPreview(objectGrip);

			default:

				log.warn(`Unexpected object grip of type ${grip.type}: ${JSON.stringify(grip)}`);
				return '';

		}
	}
}
