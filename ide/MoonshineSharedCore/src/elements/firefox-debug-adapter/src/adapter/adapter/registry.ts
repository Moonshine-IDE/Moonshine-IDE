/**
 * A generic collection of objects identified by a numerical ID.
 * The ID is generated and returned when an object is added to the collection using `register()`.
 */
export class Registry<T> implements Iterable<[number, T]> {

	private objectsById = new Map<number, T>();
	private nextId = 1;

	/**
	 * add an object to the registry and return the ID generated for it
	 */
	public register(obj: T): number {
		let id = this.nextId++;
		this.objectsById.set(id, obj);
		return id;
	}

	public unregister(id: number): boolean {
		return this.objectsById.delete(id);
	}

	public has(id: number): boolean {
		return this.objectsById.has(id);
	}

	public find(id: number): T | undefined {
		return this.objectsById.get(id);
	}

	public get count() {
		return this.objectsById.size;
	}

	public [Symbol.iterator](): Iterator<[number, T]> {
		return this.objectsById[Symbol.iterator]();
	}

	public map<S>(f: (obj: T) => S): S[] {
		let result: S[] = [];
		for (let [, obj] of this.objectsById) {
			result.push(f(obj));
		}
		return result;
	}
}