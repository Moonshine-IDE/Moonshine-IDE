const tiosLib = require('./tios_node.js');
// var factory = require('./ntios_app.js');
var factory = require('./main.js');
factory().then((instance) => {
    // instance._sayHi(); // direct calling works
    // instance.ccall("sayHi"); // using ccall etc. also work
    // console.log(instance._daysInWeek()); // values can be returned, etc.
});
//# sourceMappingURL=app.js.map