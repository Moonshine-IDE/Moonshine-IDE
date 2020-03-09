import * as vscode from 'vscode';
import { NewSourceEventBody, ThreadStartedEventBody } from '../../common/customEvents';
import { TreeNode } from './treeNode';
import { FileNode } from './fileNode';
import { SessionNode } from './sessionNode';

export abstract class NonLeafNode extends TreeNode {

	protected children: (DirectoryNode | FileNode)[] = [];

	public constructor(label: string, parent: TreeNode) {
		super(label, parent);
	}

	public addSource(
		filename: string,
		path: string[],
		description: string | undefined,
		sourceInfo: NewSourceEventBody,
		sessionId: string
	): TreeNode | undefined {

		if (path.length === 0) {

			// add the source file to this directory (not a subdirectory)
			this.addChild(new FileNode(filename, description, sourceInfo, this, sessionId));
			return this;

		}

		// find the index (if it exists) of the child directory item whose path starts
		// with the same directory name as the path to be added
		let itemIndex = this.children.findIndex(
			(item) => ((item instanceof DirectoryNode) && (item.path[0] === path[0]))
		);

		if (itemIndex < 0) {

			// there is no subdirectory that shares an initial path segment with the path to be added,
			// so we create a SourceDirectoryTreeItem for the path and add the source file to it
			let directoryItem = new DirectoryNode(path, this);
			directoryItem.addSource(filename, [], description, sourceInfo, sessionId);
			this.addChild(directoryItem);
			return this;

		}

		// the subdirectory item that shares an initial path segment with the path to be added
		let item = <DirectoryNode>this.children[itemIndex];

		// the length of the initial path segment that is equal
		let pathMatchLength = path.findIndex(
			(pathElement, index) => ((index >= item.path.length) || (item.path[index] !== pathElement))
		);
		if (pathMatchLength < 0) pathMatchLength = path.length;

		// the unmatched end segment of the path
		let pathRest = path.slice(pathMatchLength);

		if (pathMatchLength === item.path.length) {

			// the entire path of the subdirectory item is contained in the path of the file to be
			// added, so we add the file with the pathRest to the subdirectory item
			return item.addSource(filename, pathRest, description, sourceInfo, sessionId);

		}

		// only a part of the path of the subdirectory item is contained in the path of the file to
		// be added, so we split the subdirectory item into two and add the file to the first item
		item.split(pathMatchLength);
		item.addSource(filename, pathRest, description, sourceInfo, sessionId);
		return item;

	}

	public getChildren(): TreeNode[] {
		this.treeItem.collapsibleState = vscode.TreeItemCollapsibleState.Expanded;
		return this.children;
	}

	/**
	 * add a child item, respecting the sort order
	 */
	private addChild(newChild: DirectoryNode | FileNode): void {

		let index: number;

		if (newChild instanceof DirectoryNode) {
			index = this.children.findIndex(
				(child) => !((child instanceof DirectoryNode) && 
							 (child.treeItem.label! < newChild.treeItem.label!))
			);
		} else {
			index = this.children.findIndex(
				(child) => ((child instanceof FileNode) &&
							(child.treeItem.label! >= newChild.treeItem.label!))
			);
		}

		if (index >= 0) {

			if (this.children[index].treeItem.label !== newChild.treeItem.label) {
				this.children.splice(index, 0, newChild);
			}

		} else {

			this.children.push(newChild);

		}
	}
}

export class ThreadNode extends NonLeafNode {

	public readonly id: number;

	public constructor(threadInfo: ThreadStartedEventBody, parent: SessionNode) {
		super(threadInfo.name, parent);
		this.id = threadInfo.id;
		this.treeItem.contextValue = 'thread';
	}

	public removeSources(): TreeNode | undefined {
		this.children = [];
		return this;
	}
}

export class DirectoryNode extends NonLeafNode {

	public constructor(public path: string[], parent: TreeNode) {
		super(path.join('/'), parent);
		this.treeItem.contextValue = 'directory';
	}

	/**
	 * split this item into two items with this item representing the initial path segment of length
	 * `atIndex` and the new child item representing the rest of the path
	 */
	public split(atIndex: number): void {

		let newChild = new DirectoryNode(this.path.slice(atIndex), this);
		newChild.children = this.children;
		newChild.children.map(grandChild => grandChild.parent = newChild);

		this.path.splice(atIndex);
		this.children = [ newChild ];
		this.treeItem.label = this.path.join('/');
	}

	public getFullPath(): string {
		return this.parent!.getFullPath() + this.treeItem.label + '/';
	}
}
