package actionScripts.valueObjects
{
	/**
	 * Implementation of SignatureHelp interface from Language Server Protocol
	 * 
	 * <p><strong>DO NOT</strong> add new properties or methods to this class
	 * that are specific to Moonshine IDE or to a particular language. Create a
	 * subclass for new properties or create a utility function for methods.</p>
	 * 
	 * @see https://microsoft.github.io/language-server-protocol/specification#textDocument_signatureHelp
	 */
	public class SignatureHelp
	{
		public var activeSignature:int;
		public var activeParameter:int;
		public var signatures:Vector.<SignatureInformation>;
	}
}
