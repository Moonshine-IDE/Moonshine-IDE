"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
/** Remove the whitespaces from the start of each line and any comments we find at the end */
function trimWhitespaceAndComments(printedTestInput) {
    return printedTestInput.replace(/^\s+/gm, '').replace(/ ?\/\/.*$/gm, ''); // Remove the white space we put at the start of the lines to make the printed test input align with the code
}
exports.trimWhitespaceAndComments = trimWhitespaceAndComments;

//# sourceMappingURL=printedTestInputl.js.map
