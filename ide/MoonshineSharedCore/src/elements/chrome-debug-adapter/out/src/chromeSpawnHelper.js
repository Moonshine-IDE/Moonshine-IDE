"use strict";
/*---------------------------------------------------------
 * Copyright (C) Microsoft Corporation. All rights reserved.
 *--------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const cp = require("child_process");
const chromePath = process.argv[2];
const chromeArgs = process.argv.slice(3);
console.log(`spawn('${chromePath}', ${JSON.stringify(chromeArgs)})`);
const chromeProc = cp.spawn(chromePath, chromeArgs, {
    stdio: 'ignore',
    detached: true
});
chromeProc.unref();
process.send(chromeProc.pid);

//# sourceMappingURL=chromeSpawnHelper.js.map
