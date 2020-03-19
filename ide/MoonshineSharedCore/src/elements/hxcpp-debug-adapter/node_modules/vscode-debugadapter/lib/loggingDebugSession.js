"use strict";
/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/
Object.defineProperty(exports, "__esModule", { value: true });
const Logger = require("./logger");
const logger = Logger.logger;
const debugSession_1 = require("./debugSession");
class LoggingDebugSession extends debugSession_1.DebugSession {
    constructor(obsolete_logFilePath, obsolete_debuggerLinesAndColumnsStartAt1, obsolete_isServer) {
        super(obsolete_debuggerLinesAndColumnsStartAt1, obsolete_isServer);
        this.obsolete_logFilePath = obsolete_logFilePath;
        this.on('error', (event) => {
            logger.error(event.body);
        });
    }
    start(inStream, outStream) {
        super.start(inStream, outStream);
        logger.init(e => this.sendEvent(e), this.obsolete_logFilePath, this._isServer);
    }
    /**
     * Overload sendEvent to log
     */
    sendEvent(event) {
        if (!(event instanceof Logger.LogOutputEvent)) {
            // Don't create an infinite loop...
            logger.verbose(`To client: ${JSON.stringify(event)}`);
        }
        super.sendEvent(event);
    }
    /**
     * Overload sendRequest to log
     */
    sendRequest(command, args, timeout, cb) {
        logger.verbose(`To client: ${JSON.stringify(command)}(${JSON.stringify(args)}), timeout: ${timeout}`);
        super.sendRequest(command, args, timeout, cb);
    }
    /**
     * Overload sendResponse to log
     */
    sendResponse(response) {
        logger.verbose(`To client: ${JSON.stringify(response)}`);
        super.sendResponse(response);
    }
    dispatchRequest(request) {
        logger.verbose(`From client: ${request.command}(${JSON.stringify(request.arguments)})`);
        super.dispatchRequest(request);
    }
}
exports.LoggingDebugSession = LoggingDebugSession;
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoibG9nZ2luZ0RlYnVnU2Vzc2lvbi5qcyIsInNvdXJjZVJvb3QiOiIiLCJzb3VyY2VzIjpbIi4uL3NyYy9sb2dnaW5nRGVidWdTZXNzaW9uLnRzIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiI7QUFBQTs7O2dHQUdnRzs7QUFJaEcsbUNBQW1DO0FBQ25DLE1BQU0sTUFBTSxHQUFHLE1BQU0sQ0FBQyxNQUFNLENBQUM7QUFDN0IsaURBQTRDO0FBRTVDLE1BQWEsbUJBQW9CLFNBQVEsMkJBQVk7SUFDcEQsWUFBMkIsb0JBQTZCLEVBQUUsd0NBQWtELEVBQUUsaUJBQTJCO1FBQ3hJLEtBQUssQ0FBQyx3Q0FBd0MsRUFBRSxpQkFBaUIsQ0FBQyxDQUFDO1FBRHpDLHlCQUFvQixHQUFwQixvQkFBb0IsQ0FBUztRQUd2RCxJQUFJLENBQUMsRUFBRSxDQUFDLE9BQU8sRUFBRSxDQUFDLEtBQTBCLEVBQUUsRUFBRTtZQUMvQyxNQUFNLENBQUMsS0FBSyxDQUFDLEtBQUssQ0FBQyxJQUFJLENBQUMsQ0FBQztRQUMxQixDQUFDLENBQUMsQ0FBQztJQUNKLENBQUM7SUFFTSxLQUFLLENBQUMsUUFBK0IsRUFBRSxTQUFnQztRQUM3RSxLQUFLLENBQUMsS0FBSyxDQUFDLFFBQVEsRUFBRSxTQUFTLENBQUMsQ0FBQztRQUNqQyxNQUFNLENBQUMsSUFBSSxDQUFDLENBQUMsQ0FBQyxFQUFFLENBQUMsSUFBSSxDQUFDLFNBQVMsQ0FBQyxDQUFDLENBQUMsRUFBRSxJQUFJLENBQUMsb0JBQW9CLEVBQUUsSUFBSSxDQUFDLFNBQVMsQ0FBQyxDQUFDO0lBQ2hGLENBQUM7SUFFRDs7T0FFRztJQUNJLFNBQVMsQ0FBQyxLQUEwQjtRQUMxQyxJQUFJLENBQUMsQ0FBQyxLQUFLLFlBQVksTUFBTSxDQUFDLGNBQWMsQ0FBQyxFQUFFO1lBQzlDLG1DQUFtQztZQUNuQyxNQUFNLENBQUMsT0FBTyxDQUFDLGNBQWMsSUFBSSxDQUFDLFNBQVMsQ0FBQyxLQUFLLENBQUMsRUFBRSxDQUFDLENBQUM7U0FDdEQ7UUFFRCxLQUFLLENBQUMsU0FBUyxDQUFDLEtBQUssQ0FBQyxDQUFDO0lBQ3hCLENBQUM7SUFFRDs7T0FFRztJQUNJLFdBQVcsQ0FBQyxPQUFlLEVBQUUsSUFBUyxFQUFFLE9BQWUsRUFBRSxFQUE4QztRQUM3RyxNQUFNLENBQUMsT0FBTyxDQUFDLGNBQWMsSUFBSSxDQUFDLFNBQVMsQ0FBQyxPQUFPLENBQUMsSUFBSSxJQUFJLENBQUMsU0FBUyxDQUFDLElBQUksQ0FBQyxlQUFlLE9BQU8sRUFBRSxDQUFDLENBQUM7UUFDdEcsS0FBSyxDQUFDLFdBQVcsQ0FBQyxPQUFPLEVBQUUsSUFBSSxFQUFFLE9BQU8sRUFBRSxFQUFFLENBQUMsQ0FBQztJQUMvQyxDQUFDO0lBRUQ7O09BRUc7SUFDSSxZQUFZLENBQUMsUUFBZ0M7UUFDbkQsTUFBTSxDQUFDLE9BQU8sQ0FBQyxjQUFjLElBQUksQ0FBQyxTQUFTLENBQUMsUUFBUSxDQUFDLEVBQUUsQ0FBQyxDQUFDO1FBQ3pELEtBQUssQ0FBQyxZQUFZLENBQUMsUUFBUSxDQUFDLENBQUM7SUFDOUIsQ0FBQztJQUVTLGVBQWUsQ0FBQyxPQUE4QjtRQUN2RCxNQUFNLENBQUMsT0FBTyxDQUFDLGdCQUFnQixPQUFPLENBQUMsT0FBTyxJQUFJLElBQUksQ0FBQyxTQUFTLENBQUMsT0FBTyxDQUFDLFNBQVMsQ0FBRSxHQUFHLENBQUMsQ0FBQztRQUN6RixLQUFLLENBQUMsZUFBZSxDQUFDLE9BQU8sQ0FBQyxDQUFDO0lBQ2hDLENBQUM7Q0FDRDtBQTlDRCxrREE4Q0MiLCJzb3VyY2VzQ29udGVudCI6WyIvKi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLVxuICogIENvcHlyaWdodCAoYykgTWljcm9zb2Z0IENvcnBvcmF0aW9uLiBBbGwgcmlnaHRzIHJlc2VydmVkLlxuICogIExpY2Vuc2VkIHVuZGVyIHRoZSBNSVQgTGljZW5zZS4gU2VlIExpY2Vuc2UudHh0IGluIHRoZSBwcm9qZWN0IHJvb3QgZm9yIGxpY2Vuc2UgaW5mb3JtYXRpb24uXG4gKi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tKi9cblxuaW1wb3J0IHtEZWJ1Z1Byb3RvY29sfSBmcm9tICd2c2NvZGUtZGVidWdwcm90b2NvbCc7XG5cbmltcG9ydCAqIGFzIExvZ2dlciBmcm9tICcuL2xvZ2dlcic7XG5jb25zdCBsb2dnZXIgPSBMb2dnZXIubG9nZ2VyO1xuaW1wb3J0IHtEZWJ1Z1Nlc3Npb259IGZyb20gJy4vZGVidWdTZXNzaW9uJztcblxuZXhwb3J0IGNsYXNzIExvZ2dpbmdEZWJ1Z1Nlc3Npb24gZXh0ZW5kcyBEZWJ1Z1Nlc3Npb24ge1xuXHRwdWJsaWMgY29uc3RydWN0b3IocHJpdmF0ZSBvYnNvbGV0ZV9sb2dGaWxlUGF0aD86IHN0cmluZywgb2Jzb2xldGVfZGVidWdnZXJMaW5lc0FuZENvbHVtbnNTdGFydEF0MT86IGJvb2xlYW4sIG9ic29sZXRlX2lzU2VydmVyPzogYm9vbGVhbikge1xuXHRcdHN1cGVyKG9ic29sZXRlX2RlYnVnZ2VyTGluZXNBbmRDb2x1bW5zU3RhcnRBdDEsIG9ic29sZXRlX2lzU2VydmVyKTtcblxuXHRcdHRoaXMub24oJ2Vycm9yJywgKGV2ZW50OiBEZWJ1Z1Byb3RvY29sLkV2ZW50KSA9PiB7XG5cdFx0XHRsb2dnZXIuZXJyb3IoZXZlbnQuYm9keSk7XG5cdFx0fSk7XG5cdH1cblxuXHRwdWJsaWMgc3RhcnQoaW5TdHJlYW06IE5vZGVKUy5SZWFkYWJsZVN0cmVhbSwgb3V0U3RyZWFtOiBOb2RlSlMuV3JpdGFibGVTdHJlYW0pOiB2b2lkIHtcblx0XHRzdXBlci5zdGFydChpblN0cmVhbSwgb3V0U3RyZWFtKTtcblx0XHRsb2dnZXIuaW5pdChlID0+IHRoaXMuc2VuZEV2ZW50KGUpLCB0aGlzLm9ic29sZXRlX2xvZ0ZpbGVQYXRoLCB0aGlzLl9pc1NlcnZlcik7XG5cdH1cblxuXHQvKipcblx0ICogT3ZlcmxvYWQgc2VuZEV2ZW50IHRvIGxvZ1xuXHQgKi9cblx0cHVibGljIHNlbmRFdmVudChldmVudDogRGVidWdQcm90b2NvbC5FdmVudCk6IHZvaWQge1xuXHRcdGlmICghKGV2ZW50IGluc3RhbmNlb2YgTG9nZ2VyLkxvZ091dHB1dEV2ZW50KSkge1xuXHRcdFx0Ly8gRG9uJ3QgY3JlYXRlIGFuIGluZmluaXRlIGxvb3AuLi5cblx0XHRcdGxvZ2dlci52ZXJib3NlKGBUbyBjbGllbnQ6ICR7SlNPTi5zdHJpbmdpZnkoZXZlbnQpfWApO1xuXHRcdH1cblxuXHRcdHN1cGVyLnNlbmRFdmVudChldmVudCk7XG5cdH1cblxuXHQvKipcblx0ICogT3ZlcmxvYWQgc2VuZFJlcXVlc3QgdG8gbG9nXG5cdCAqL1xuXHRwdWJsaWMgc2VuZFJlcXVlc3QoY29tbWFuZDogc3RyaW5nLCBhcmdzOiBhbnksIHRpbWVvdXQ6IG51bWJlciwgY2I6IChyZXNwb25zZTogRGVidWdQcm90b2NvbC5SZXNwb25zZSkgPT4gdm9pZCk6IHZvaWQge1xuXHRcdGxvZ2dlci52ZXJib3NlKGBUbyBjbGllbnQ6ICR7SlNPTi5zdHJpbmdpZnkoY29tbWFuZCl9KCR7SlNPTi5zdHJpbmdpZnkoYXJncyl9KSwgdGltZW91dDogJHt0aW1lb3V0fWApO1xuXHRcdHN1cGVyLnNlbmRSZXF1ZXN0KGNvbW1hbmQsIGFyZ3MsIHRpbWVvdXQsIGNiKTtcblx0fVxuXG5cdC8qKlxuXHQgKiBPdmVybG9hZCBzZW5kUmVzcG9uc2UgdG8gbG9nXG5cdCAqL1xuXHRwdWJsaWMgc2VuZFJlc3BvbnNlKHJlc3BvbnNlOiBEZWJ1Z1Byb3RvY29sLlJlc3BvbnNlKTogdm9pZCB7XG5cdFx0bG9nZ2VyLnZlcmJvc2UoYFRvIGNsaWVudDogJHtKU09OLnN0cmluZ2lmeShyZXNwb25zZSl9YCk7XG5cdFx0c3VwZXIuc2VuZFJlc3BvbnNlKHJlc3BvbnNlKTtcblx0fVxuXG5cdHByb3RlY3RlZCBkaXNwYXRjaFJlcXVlc3QocmVxdWVzdDogRGVidWdQcm90b2NvbC5SZXF1ZXN0KTogdm9pZCB7XG5cdFx0bG9nZ2VyLnZlcmJvc2UoYEZyb20gY2xpZW50OiAke3JlcXVlc3QuY29tbWFuZH0oJHtKU09OLnN0cmluZ2lmeShyZXF1ZXN0LmFyZ3VtZW50cykgfSlgKTtcblx0XHRzdXBlci5kaXNwYXRjaFJlcXVlc3QocmVxdWVzdCk7XG5cdH1cbn1cbiJdfQ==