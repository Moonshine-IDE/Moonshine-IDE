Simple library providing Java like wait and notify functionality for async/await syntax.

Works in Node (or browser via Browserify or Webpack) when Promise and async/await syntax are enabled.

Install
=======

    npm install --save await-notify

Usage
=====

    const { Subject } = require('await-notify');
    const event = new Subject();

    (async () => {
      while (true) {
        await event.wait();
        console.log('Event occured');
      }
    })();

    setTimeout(() => {
      event.notify();
    }, 1000);

API reference
=============

Subject
-------

A class representing subjects that could be waited for and notfied on.

#### Subject.prototype.wait([timeout = Infinity])

Returns a promise that will be resolved either when the subject is been notfied or when timeout occurs.

`timeout` parameter is in milliseconds, and no timeout will occur if not set to an finite number greater than 0.

The promise resolves `false` if timeout occurs, resolves `true` otherwise.

    const subject = new Subject();

    (async () => {
      const notTimeout = await subject.wait();
      ...
    })();

#### Subject.prototype.notify()

Resolve ***one*** waiting session. Does nothing if no one is waiting on this subject.

Return nothing and thus should not be used with `await`.

    subject.notify();

#### Subject.prototype.notifyAll()

Similar to `notify` but notifies ***all*** waiting session.

Tips
====

Pass data to the waiter when calling notify
-------------------------------------------

There's no fancy way to do this, but a Subject instance is just another plain JavaScript object which you
can freely assign parameters to. So you may just do this:

    const { Subject } = require('await-notify');
    const event = new Subject();

    (async () => {
      while (true) {
        await event.wait();
        console.log('Event occured with message:'. event.message);
      }
    })();

    setTimeout(() => {
      event.message = 'Hello there';
      event.notify();
    }, 1000);

Use without async/await
-----------------------

Under the hood, async/await are just sugar syntax for using Promise. So using promise directly is fine.


    const { Subject } = require('await-notify');
    const event = new Subject();

    function listen() {
      event.wait().then(() => {
        console.log('Event occured');
        listen();
      });
    }
    listen();

    setTimeout(() => {
      event.message = 'Hello there';
      event.notify();
    }, 1000);
