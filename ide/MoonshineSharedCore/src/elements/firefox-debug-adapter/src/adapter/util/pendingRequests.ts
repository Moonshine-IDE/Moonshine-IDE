import { Log } from './log';

let log = Log.create('PendingRequests');

export interface PendingRequest<T> {
	resolve: (t: T) => void;
	reject: (err: any) => void;
}

export class PendingRequests<T> {
	
	private pendingRequests: PendingRequest<T>[] = [];
	
	public enqueue(req: PendingRequest<T>) {
		this.pendingRequests.push(req);
	}
	
	public resolveOne(t: T) {
		if (this.pendingRequests.length > 0) {
			let request = this.pendingRequests.shift()!;
			request.resolve(t);
		} else {
			log.error("Received response without corresponding request!?");
		}
	}
	
	public rejectOne(err: any) {
		if (this.pendingRequests.length > 0) {
			let request = this.pendingRequests.shift()!;
			request.reject(err);
		} else {
			log.error("Received error response without corresponding request!?");
		}
	}
	
	public isEmpty(): boolean {
		return (this.pendingRequests.length === 0);
	}

	public resolveAll(t: T) {
		this.pendingRequests.forEach((req) => req.resolve(t));
		this.pendingRequests = [];
	}
	
	public rejectAll(err: any) {
		this.pendingRequests.forEach((req) => req.reject(err));
		this.pendingRequests = [];
	}
}
