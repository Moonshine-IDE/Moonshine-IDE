import { Log } from '../util/log';
import { EventEmitter } from 'events';
import { ExceptionBreakpoints, IThreadActorProxy } from '../firefox/actorProxy/thread';
import { ConsoleActorProxy } from '../firefox/actorProxy/console';
import { ThreadPauseCoordinator, PauseType } from './threadPause';
import { DelayedTask } from '../util/delayedTask';
import { PendingRequest } from '../util/pendingRequests';

let log = Log.create('ThreadCoordinator');

type ThreadState = 'paused' | 'resuming' | 'running' | 'interrupting' | 'evaluating';

type ThreadTarget = 'paused' | 'running' | 'stepOver' | 'stepIn' | 'stepOut';

/**
 * This class manages the state of one 
 * ["thread"](https://github.com/mozilla/gecko-dev/blob/master/devtools/docs/backend/protocol.md#interacting-with-thread-like-actors)
 * and coordinates all tasks that depend on or change the thread's state.
 * 
 * Some tasks (adding and removing breakpoints, fetching stackframes and the values of javascript
 * variables) can only be run when the thread is paused. These actions can (and are) run in parallel,
 * but the thread must not be resumed until all of them are finished. If such a task is requested
 * while the thread is running, it is paused temporarily and resumed automatically when the task
 * is finished.
 * 
 * The evaluation of watch expressions is also coordinated using this class: the evaluation tasks
 * for the watch expressions are queued, then the thread is paused, then the evaluation tasks are
 * run one after another and then the thread is resumed.
 * The reason for this is that we want to skip all breakpoints when evaluating watch expressions,
 * to do this we need to know if a breakpoint was hit due to a watch expression or not. By running
 * the evaluation of watch expressions through this coordinator, we ensure that no other javascript
 * code can be running while doing the evaluation.
 */
export class ThreadCoordinator extends EventEmitter {

	/**
	 * whether we should break on uncaught or all exceptions, this setting is sent to Firefox
	 * with the next request to resume the thread
	 */
	private exceptionBreakpoints: ExceptionBreakpoints | undefined;

	/** the current state of the thread */
	private threadState: ThreadState = 'paused';

	/**
	 * the desired state of the thread, the thread will be put into this state when no more actions
	 * are queued or running
	 */
	private _threadTarget: ThreadTarget = 'paused';
	public get threadTarget(): ThreadTarget {
		return this._threadTarget;
	}

	/** if the thread is paused, this will contain the reason for the pause */
	private _threadPausedReason?: FirefoxDebugProtocol.ThreadPausedReason;
	public get threadPausedReason(): FirefoxDebugProtocol.ThreadPausedReason | undefined {
		return this._threadPausedReason;
	}

	/**
	 * if the thread is interrupting (i.e. we sent an interrupt request, but didn't receive
	 * an answer yet), this will contain a Promise that will be resolved when the thread reached
	 * the paused state
	 */
	private interruptPromise?: Promise<void>;
	/** the resolve/reject functions for the `interruptPromise` */
	private pendingInterruptRequest?: PendingRequest<void>;

	/**
	 * if the thread is resuming (i.e. we sent a resume request, but didn't receive
	 * an answer yet), this will contain a Promise that will be resolved when the thread reached
	 * the running state
	 */
	private resumePromise?: Promise<void>;
	/** the resolve/reject functions for the `resumePromise` */
	private pendingResumeRequest?: PendingRequest<void>;

	private queuedTasksToRunOnPausedThread: DelayedTask<any>[] = [];
	private tasksRunningOnPausedThread = 0;

	private queuedEvaluateTasks: DelayedTask<FirefoxDebugProtocol.Grip>[] = [];

	constructor(
		private threadId: number,
		private threadName: string,
		isPaused: boolean,
		private threadActor: IThreadActorProxy,
		private consoleActor: ConsoleActorProxy,
		private pauseCoordinator: ThreadPauseCoordinator,
		private prepareResume: () => Promise<void>
	) {
		super();

		const state = isPaused ? 'paused' : 'running';
		this.threadState = state;
		this._threadTarget = state;

		threadActor.onPaused((event) => {

			if (this.threadState === 'evaluating') {

				// we hit a breakpoint while evaluating a watch, so we skip it by resuming immediately
				threadActor.resume(this.exceptionBreakpoints);

			} else if ((event.why.type === 'exception') && 
						(this.exceptionBreakpoints === ExceptionBreakpoints.None)) {

				// the thread was paused because it hit an exception, but we want to skip that
				// (this can happen when the user changed the setting for exception breakpoints
				// but we couldn't send the changed setting to Firefox yet)
				threadActor.resume(this.exceptionBreakpoints);

			} else {

				this._threadTarget = 'paused';
				this._threadPausedReason = event.why;
				this.threadPaused('user');
				this.emit('paused', event);

			}
		});

		threadActor.onResumed(() => {

			this._threadTarget = 'running';
			this._threadPausedReason = undefined;
			this.threadResumed();

			if (this.tasksRunningOnPausedThread > 0) {
				log.warn('Thread resumed unexpectedly while tasks that need the thread to be paused were running');
			}
		});
	}

	public setExceptionBreakpoints(exceptionBreakpoints: ExceptionBreakpoints) {

		this.exceptionBreakpoints = exceptionBreakpoints;

		if ((this.threadState === 'resuming') || (this.threadState === 'running')) {
			// We can only send the changed setting for exception breakpoints to Firefox when sending
			// a resume request. By requesting to run a dummy action on the paused thread, we ensure
			// that a resume request will be sent to Firefox (after the dummy action is finished).
			this.runOnPausedThread(async () => undefined);
		}
	}

	public interrupt(): Promise<void> {

		if (this.threadState === 'paused') {

			return Promise.resolve();

		} else if (this.interruptPromise !== undefined) {

			return this.interruptPromise;

		} else {

			this._threadTarget = 'paused';
			this._threadPausedReason = undefined;
			this.interruptPromise = new Promise<void>((resolve, reject) => {
				this.pendingInterruptRequest = { resolve, reject };
			});
			this.doNext();
			return this.interruptPromise;

		}
	}

	public resume(): Promise<void> {
		return this.resumeTo('running');
	}

	public stepOver(): Promise<void> {
		return this.resumeTo('stepOver');
	}

	public stepIn(): Promise<void> {
		return this.resumeTo('stepIn');
	}

	public stepOut(): Promise<void> {
		return this.resumeTo('stepOut');
	}

	private resumeTo(target: 'running' | 'stepOver' | 'stepIn' | 'stepOut'): Promise<void> {

		if (this.threadState === 'running') {

			if (target !== 'running') {
				log.warn(`Can't ${target} because the thread is already running`);
			}

			return Promise.resolve();

		} else if (this.resumePromise !== undefined) {

			if (target !== 'running') {
				log.warn(`Can't ${target} because the thread is already resuming`);
			}

			return this.resumePromise;

		} else {

			this._threadTarget = target;
			this._threadPausedReason = undefined;
			this.resumePromise = new Promise<void>((resolve, reject) => {
				this.pendingResumeRequest = { resolve, reject };
			});
			this.doNext();
			return this.resumePromise;

		}
	}

	public runOnPausedThread<T>(task: () => Promise<T>): Promise<T> {

		let delayedTask = new DelayedTask(task);
		this.queuedTasksToRunOnPausedThread.push(delayedTask);
		this.doNext();
		return delayedTask.promise;
	}

	public evaluate(
		expr: string,
		frameActorName: string | undefined
	): Promise<FirefoxDebugProtocol.Grip> {

		let delayedTask = new DelayedTask(() => this.consoleActor.evaluate(expr, frameActorName));

		this.queuedEvaluateTasks.push(delayedTask);
		this.doNext();

		return delayedTask.promise;
	}

	public onPaused(cb: (event: FirefoxDebugProtocol.ThreadPausedResponse) => void) {
		this.on('paused', cb);
	}

	/** 
	 * This method is called whenever an action was queued or finished running or the desired thread
	 * state changed. It will decide what should be done next (if anything) and will do it by
	 * calling one of the `execute` functions below.
	 */
	private doNext(): void {

		if (log.isDebugEnabled()) {
			log.debug(`state: ${this.threadState}, target: ${this.threadTarget}, tasks: ${this.tasksRunningOnPausedThread}/${this.queuedTasksToRunOnPausedThread.length}, eval: ${this.queuedEvaluateTasks.length}`)
		}

		if ((this.threadState === 'interrupting') ||
			(this.threadState === 'resuming') ||
			(this.threadState === 'evaluating')) {
			return;
		}

		if (this.threadState === 'running') {

			if ((this.queuedTasksToRunOnPausedThread.length > 0) || (this.queuedEvaluateTasks.length > 0)) {
				this.executeInterrupt('auto');
				return;
			}
 
			if (this.threadTarget === 'paused') {
				this.executeInterrupt('user');
				return;
			}

		} else { // this.threadState === 'paused'

			if (this.queuedTasksToRunOnPausedThread.length > 0) {

				for (let task of this.queuedTasksToRunOnPausedThread) {
					this.executeOnPausedThread(task);
				}
				this.queuedTasksToRunOnPausedThread = [];

				return;
			}

			if (this.tasksRunningOnPausedThread > 0) {
				return;
			}

			if (this.queuedEvaluateTasks.length > 0) {

				let task = this.queuedEvaluateTasks.shift()!;
				this.executeEvaluateTask(task);

				return;
			}
		}

		if ((this.threadState === 'paused') && (this.threadTarget !== 'paused')) {
			this.executeResume();
			return;
		}
	}

	/**
	 * interrupts the thread, the `pauseType` argument specifies if this is due to a breakpoint or
	 * the user requesting the thread to be paused (so it won't be resumed by this class until the
	 * user requests it to be resumed) or if it is an automatic pause in order to run some actions
	 * on the paused thread (so it *will* be resumed automatically when all actions are finished)
	 */
	private async executeInterrupt(pauseType: PauseType): Promise<void> {

		this.threadState = 'interrupting';

		try {

			await this.pauseCoordinator.requestInterrupt(this.threadId, this.threadName, pauseType);
			await this.threadActor.interrupt(pauseType === 'auto');
			this.threadPaused(pauseType);

		} catch(e) {
			log.error(`interrupt failed: ${e}`);
			this.threadState = 'running';
			this.pauseCoordinator.notifyInterruptFailed(this.threadId, this.threadName);
		}

		this.interruptPromise = undefined;

		this.doNext();
	}

	private async executeResume(): Promise<void> {

		try {

			await this.pauseCoordinator.requestResume(this.threadId, this.threadName);

		} catch(e) {

			log.error(`resume denied: ${e}`);

			if (this.pendingResumeRequest !== undefined) {
				this.pendingResumeRequest.reject(e);
				this.pendingResumeRequest = undefined;
			}
			this.resumePromise = undefined;
		}

		let resumeLimit = this.getResumeLimit();
		this.threadState = 'resuming';

		try {

			await this.prepareResume();
			await this.threadActor.resume(this.exceptionBreakpoints, resumeLimit);
			this.threadResumed();

		} catch(e) {
			log.error(`resume failed: ${e}`);
			this.threadState = 'paused';
			this.pauseCoordinator.notifyResumeFailed(this.threadId, this.threadName);
		}

		this.doNext();
	}

	private async executeOnPausedThread(task: DelayedTask<any>): Promise<void> {

		if (this.threadState !== 'paused') {
			log.error(`executeOnPausedThread called but threadState is ${this.threadState}`);
			return;
		}

		this.tasksRunningOnPausedThread++;
		try {
			await task.execute();
		} catch(e) {
			log.warn(`task running on paused thread failed: ${e}`);
		}
		this.tasksRunningOnPausedThread--;

		if (this.tasksRunningOnPausedThread === 0) {
			this.doNext();
		}
	}

	private async executeEvaluateTask(task: DelayedTask<FirefoxDebugProtocol.Grip>): Promise<void> {

		if (this.threadState !== 'paused') {
			log.error(`executeEvaluateTask called but threadState is ${this.threadState}`);
			return;
		}
		if (this.tasksRunningOnPausedThread > 0) {
			log.error(`executeEvaluateTask called but tasksRunningOnPausedThread is ${this.tasksRunningOnPausedThread}`);
			return;
		}

		this.threadState = 'evaluating';
		try {
			await task.execute();
		} catch(e) {
		}
		this.threadState = 'paused';

		this.doNext();
	}

	private threadPaused(pauseType: PauseType): void {

		this.threadState = 'paused';

		if (this.pendingInterruptRequest !== undefined) {
			this.pendingInterruptRequest.resolve(undefined);
			this.pendingInterruptRequest = undefined;
		}
		this.interruptPromise = undefined;

		if (this.threadTarget === 'paused') {
			if (this.pendingResumeRequest !== undefined) {
				this.pendingResumeRequest.reject(undefined);
				this.pendingResumeRequest = undefined;
			}
			this.resumePromise = undefined;
		}

		this.pauseCoordinator.notifyInterrupted(this.threadId, this.threadName, pauseType);
	}

	private threadResumed(): void {

		this.threadState = 'running';

		if (this.pendingResumeRequest !== undefined) {
			this.pendingResumeRequest.resolve(undefined);
			this.pendingResumeRequest = undefined;
		}
		this.resumePromise = undefined;

		if (this.threadTarget !== 'paused') {
			if (this.pendingInterruptRequest !== undefined) {
				this.pendingInterruptRequest.reject(undefined);
				this.pendingInterruptRequest = undefined;
			}
			this.interruptPromise = undefined;
		}

		this.pauseCoordinator.notifyResumed(this.threadId, this.threadName);
	}

	private getResumeLimit(): 'next' | 'step' | 'finish' | undefined {
		switch (this.threadTarget) {
			case 'stepOver':
				return 'next';
			case 'stepIn':
				return 'step';
			case 'stepOut':
				return 'finish';
			default:
				return undefined;
		}
	}
}
