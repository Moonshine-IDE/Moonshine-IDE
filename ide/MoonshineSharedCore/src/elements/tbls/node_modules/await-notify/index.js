function Subject() {
  this.waiters = [];
}

Subject.prototype.wait = function (timeout) {
  var self = this;
  var waiter = {};
  this.waiters.push(waiter);
  var promise = new Promise(function (resolve) {
    var resolved = false;
    waiter.resolve = function (noRemove) {
      if (resolved) {
        return;
      }
      resolved = true;
      if (waiter.timeout) {
        clearTimeout(waiter.timeout);
        waiter.timeout = null;
      }
      if (!noRemove) {
        var pos = self.waiters.indexOf(waiter);
        if (pos > -1) {
          self.waiters.splice(pos, 1);
        }
      }
      resolve();
    };
  });
  if (timeout > 0 && isFinite(timeout)) {
    waiter.timeout = setTimeout(function () {
      waiter.timeout = null;
      waiter.resolve();
    }, timeout);
  }
  return promise;
};

Subject.prototype.notify = function () {
  if (this.waiters.length > 0) {
    this.waiters.pop().resolve(true);
  }
};

Subject.prototype.notifyAll = function () {
  for (var i = this.waiters.length - 1; i >= 0; i--) {
    this.waiters[i].resolve(true);
  }
  this.waiters = [];
}

exports.Subject = Subject;
