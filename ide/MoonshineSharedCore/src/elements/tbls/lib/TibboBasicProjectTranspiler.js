"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TibboBasicProjectTranspiler = void 0;
const path = require("path");
const TibboBasicTranspiler_1 = require("./TibboBasicTranspiler");
const antlr4 = require('antlr4');
const TibboBasicLexer = require('../language/TibboBasic/lib/TibboBasicLexer').TibboBasicLexer;
const TibboBasicParser = require('../language/TibboBasic/lib/TibboBasicParser').TibboBasicParser;
const TibboBasicParserListener = require('../language/TibboBasic/lib/TibboBasicParserListener').TibboBasicParserListener;
const syscalls = require('../language/TibboBasic/syscalls.json');
const events = require('../language/TibboBasic/events.json');
const OBJ_NAMESPACES = {
    'sys': 'syst',
    'fd': 'flashdisk',
    'pat': 'pattern',
    'romfile': 'romFile',
    'ser': 'serial',
    'stor': 'storage',
};
class TibboBasicProjectTranspiler {
    constructor() {
        this.output = '';
        this.lines = [];
        this.currentLine = '';
        this.functions = [];
        this.variables = [];
        this.lineMappings = [];
        this.constants = {};
        this.types = {};
        this.objects = {};
        this.events = {};
        this.syscalls = {};
    }
    transpile(files) {
        const transpiler = new TibboBasicTranspiler_1.TibboBasicTranspiler();
        const output = [];
        const sourceFiles = [];
        for (let i = 0; i < files.length; i++) {
            let filePath = files[i].name;
            let outputExtension = '.cpp';
            const originalExt = path.extname(filePath);
            if (path.extname(filePath) == '.tbh') {
                outputExtension = '.h';
            }
            filePath = filePath.substr(0, filePath.length - path.extname(filePath).length) + outputExtension;
            if (outputExtension === '.cpp' && ['.tbs', 'tbh'].includes(originalExt)) {
                sourceFiles.push(`\${CMAKE_CURRENT_SOURCE_DIR}/${filePath}`);
            }
            let contents = transpiler.parseFile(files[i].contents);
            const supportedFileTypes = ['.tbs', '.tbh', '.xtxt'];
            if (!supportedFileTypes.includes(originalExt)) {
                continue;
            }
            if (filePath === 'global.h') {
                contents =
                    `
#include "base/ntios_includes.h"
                
${contents}
`;
            }
            output.push({
                name: filePath,
                contents: contents,
            });
            if (files[i].name.indexOf('.xtxt') > -1) {
                const lines = files[i].contents.split('\r\n');
                for (let j = 0; j < lines.length; j++) {
                    lines[j] = lines[j] + `\\r\\n`;
                }
            }
        }
        const objectsToSkip = ['fd'];
        Object.keys(transpiler.objects).forEach((key) => {
            const object = transpiler.objects[key];
            const name = object.name;
            const namespace = OBJ_NAMESPACES[name] === undefined ? name : OBJ_NAMESPACES[name];
            if (objectsToSkip.includes(name)) {
                return;
            }
            let hOutput = `                
/*Copyright 2021 Tibbo Technology Inc.*/
#ifndef NTIOS_XPAT_${name.toUpperCase()}_NTIOS_${name.toUpperCase()}_H_
#define NTIOS_XPAT_${name.toUpperCase()}_NTIOS_${name.toUpperCase()}_H_

#include <cmath>
#include <string>

#include "base/ntios_types.h"
#include "base/ntios_base.h"
#include "base/ntios_config.h"
#include "base/ntios_property.h"
#include "io/ntios_io_map.h"

/* NAMESPACES */
namespace ntios {
namespace ${namespace} {
`;
            let cppOutput = `
#include <emscripten.h>
#include "${name}/ntios_${name}.h"



namespace ntios {
namespace ${namespace} {
`;
            let hPrivate = '';
            let hDefinitions = '';
            for (let i = 0; i < object.properties.length; i++) {
                // skip
                const property = object.properties[i];
                hPrivate += `
${property.dataType} m${property.name};
${property.dataType ? property.dataType : 'void'} ${property.name}Getter() const;
`;
                cppOutput +=
                    `
${property.dataType} ${name.toUpperCase()}::${property.name}Getter() const {
    return m${property.name};
}`;
                if (property.set !== undefined) {
                    hDefinitions += `
Property<${property.dataType}, ${name.toUpperCase()}> ${property.name}{this, &${name.toUpperCase()}::${property.name}Setter, &${name.toUpperCase()}::${property.name}Getter,
    PropertyPermissions::ReadWrite};
`;
                    cppOutput += `
void ${name.toUpperCase()}::${property.name}Setter(${property.dataType} ${property.name}) {
    m${property.name} = ${property.name};
}
`;
                    hPrivate += `
void ${property.name}Setter(${property.dataType} ${property.name});
`;
                }
                else {
                    hDefinitions += `
Property<${property.dataType}, ${name.toUpperCase()}> ${property.name}{this, nullptr, &${name.toUpperCase()}::${property.name}Getter,
    PropertyPermissions::Read};
`;
                }
            }
            for (let i = 0; i < object.functions.length; i++) {
                const func = object.functions[i];
                hDefinitions += `
${func.dataType ? func.dataType : 'void'} ${func.name}(${func.parameters.map((param) => `${param.dataType} ${param.name}`).join(', ')});
                `;
                cppOutput += `
${func.dataType ? func.dataType : 'void'} ${func.name}(${func.parameters.map((param) => `${param.dataType} ${param.name}`).join(', ')}) {
    ${func.dataType !== '' ? `${func.dataType} result;` : ''}
    ${func.dataType !== '' ? `return result;` : ''}
}
                `;
            }
            cppOutput += `
}  // namespace ${name}
}  // namespace ntios
`;
            hOutput +=
                `
class ${name.toUpperCase()} {
public:
    ${name.toUpperCase()}();
    ~${name.toUpperCase()}();
${hDefinitions}
private:
${hPrivate}
};
}  // namespace ${name}
} /* namespace ntios */
#endif
`;
            output.push({
                name: `${name}/ntios_${name}.h`,
                contents: hOutput,
            });
            output.push({
                name: `${name}/ntios_${name}.cpp`,
                contents: cppOutput,
            });
            const cmakeContents = `
cmake_minimum_required(VERSION 3.0.0)
project(ntios_${name} VERSION 0.1.0)

message("---------------CMake: Configure ${name} START---------------")

include_directories(\${CMAKE_SOURCE_DIR}/ 
                    \${CMAKE_SOURCE_DIR}/ntios/webasm/
                    \${CMAKE_SOURCE_DIR}/ntios/xpat/)

add_library(ntios_${name} SHARED
    \${CMAKE_CURRENT_SOURCE_DIR}/ntios_${name}.cpp
)

# target_link_libraries(ntios_${name})

set_target_properties(
    ntios_${name}
    PROPERTIES 
        SUFFIX ".bc"
)

file(GLOB BASE_LIB_HEADERS \${CMAKE_CURRENT_SOURCE_DIR}/*.h)


message("---------------CMake: Configure END---------------")                
`;
            output.push({
                name: `${name}/CMakeLists.txt`,
                contents: cmakeContents,
            });
        });
        const cmakeOut = `
cmake_minimum_required(VERSION 3.0.0)
project(ntios_app VERSION 0.1.0)

message("---------------Configuring ntios app start---------------")


include_directories(
                    \${CMAKE_SOURCE_DIR}/ntios/webasm/app/
                    \${CMAKE_SOURCE_DIR}/ntios/webasm/
                    \${CMAKE_SOURCE_DIR}/ntios/xpat/)


add_executable(ntios_app  
${sourceFiles.join('\n')}
)

set_target_properties(
    ntios_app
    PROPERTIES 
        SUFFIX ".html"
)
              
# copy file index.html to build directory
file(COPY \${CMAKE_CURRENT_SOURCE_DIR}/index.html DESTINATION \${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(ntios_app ntios_base ntios_threads ${Object.keys(transpiler.objects).map((key) => `ntios_${key}`).join('\n')})

message("---------------Configuring ntios app end---------------")

`;
        output.push({
            name: 'CMakeLists.txt',
            contents: cmakeOut,
        });
        return output;
    }
}
exports.TibboBasicProjectTranspiler = TibboBasicProjectTranspiler;
//# sourceMappingURL=TibboBasicProjectTranspiler.js.map