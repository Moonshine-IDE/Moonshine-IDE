"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/* eslint-disable @typescript-eslint/no-var-requires */
const path = require("path");
const TibboBasicTranspiler_1 = require("./TibboBasicTranspiler");
const fs = require("fs");
const { resolve } = require('path');
const { readdir } = require('fs').promises;
const files = [
    path.join(__dirname, '..', 'tests', 'global.tbh'),
    path.join(__dirname, '..', 'tests', 'main.tbs'),
    path.join(__dirname, '..', 'tests', 'device.tbs'),
    path.join(__dirname, '..', 'tests', 'boot.tbs'),
    path.join(__dirname, '..', 'tests', 'super_spi.tbs'),
    path.join(__dirname, '..', 'tests', 'tbt42.tbs'),
    path.join(__dirname, '..', 'tests', 'super_i2c.tbs'),
];
async function getFiles(dir) {
    const dirents = await readdir(dir, { withFileTypes: true });
    const files = await Promise.all(dirents.map((dirent) => {
        const res = resolve(dir, dirent.name);
        return dirent.isDirectory() ? getFiles(res) : res;
    }));
    return Array.prototype.concat(...files);
}
(async function start() {
    const tmpFiles = await getFiles(path.join(__dirname, '..', 'tests', 'Platforms'));
    for (let i = 0; i < tmpFiles.length; i++) {
        const filePath = tmpFiles[i];
        const extension = path.extname(filePath);
        if (extension == '.tbs' || extension == '.tbh') {
            files.push(filePath);
        }
    }
    const transpiler = new TibboBasicTranspiler_1.TibboBasicTranspiler();
    for (let i = 0; i < files.length; i++) {
        try {
            const filePath = files[i];
            console.log('parsing ' + filePath);
            const contents = fs.readFileSync(filePath, 'utf-8');
            const output = transpiler.parseFile(contents);
            let outputExtension = '.tc';
            if (path.extname(filePath) == '.tbh') {
                outputExtension = '.th';
            }
            const newFileName = filePath.substr(0, filePath.length - 4) + outputExtension;
            fs.writeFileSync(newFileName, output);
        }
        catch (ex) {
            console.log(ex);
        }
    }
    console.log('transpile ended');
})();
//# sourceMappingURL=testTranspiler.js.map