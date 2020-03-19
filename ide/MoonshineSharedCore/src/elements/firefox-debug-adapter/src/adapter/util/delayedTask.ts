import { Log } from './log';

let log = Log.create('DelayedTask');

export class DelayedTask<T> {

	private state: 'waiting' | 'running' | 'finished';
	private resolve!: (result: T) => void;
	private reject!: (reason?: any) => void;

	public readonly promise: Promise<T>;

	public constructor(
		private task: () => Promise<T>,
	) {

		this.promise = new Promise<T>((resolve, reject) => {
			this.resolve = resolve;
			this.reject = reject;
		});

		this.state = 'waiting';
	}

	public async execute(): Promise<void> {

		if (this.state !== 'waiting') {
			log.error(`Tried to execute DelayedTask, but it is ${this.state}`);
			return;
		}

		let result: T;
		try {
			this.state = 'running';
			result = await this.task();
			this.resolve(result);
		} catch (err) {
			this.reject(err);
			throw err;
		}

		this.state = 'finished';
	}

	public cancel(reason?: any): void {

		if (this.state !== 'waiting') {
			log.error(`Tried to cancel DelayedTask, but it is ${this.state}`);
			return;
		}

		this.reject(reason);
		this.state = 'finished';
	}
}
