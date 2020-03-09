import * as vscode from 'vscode';
import { TreeNode } from './treeNode';
import { RootNode } from './rootNode';
import { ThreadNode } from './nonLeafNode';
import { ThreadStartedEventBody, NewSourceEventBody } from '../../common/customEvents';

export class SessionNode extends TreeNode {

	protected children: ThreadNode[] = [];
	private showThreads = false;
	private sourceUrls: string[] = [];

	public get id() {
		return this.session.id;
	}

	public constructor(private session: vscode.DebugSession, parent: RootNode) {
		super(session.name, parent);
		this.treeItem.contextValue = 'session';
	}

	public addThread(threadInfo: ThreadStartedEventBody): TreeNode | undefined {

		if (!this.children.some((child) => (child.id === threadInfo.id))) {

			let index = this.children.findIndex((child) => (child.treeItem.label! > threadInfo.name));
			if (index < 0) index = this.children.length;

			this.children.splice(index, 0, new ThreadNode(threadInfo, this));

			return this;

		} else {
			return undefined;
		}
	}

	public removeThread(threadId: number): TreeNode | undefined {

		this.children = this.children.filter((child) => (child.id !== threadId));

		return this;
	}

	public addSource(sourceInfo: NewSourceEventBody): TreeNode | undefined {

		if (!sourceInfo.url) return undefined;

		this.sourceUrls.push(sourceInfo.url);

		let threadItem = this.children.find((child) => (child.id === sourceInfo.threadId));

		if (threadItem) {

			let path = splitURL(sourceInfo.url);
			let filename = path.pop()!;

			let description: string | undefined;
			if (sourceInfo.path) {

				description = sourceInfo.path;

				if (this.session.workspaceFolder) {
					const workspaceUri = this.session.workspaceFolder.uri;
					let workspacePath = (workspaceUri.scheme === 'file') ? workspaceUri.fsPath : workspaceUri.toString();
					workspacePath += '/';
					if (description.startsWith(workspacePath)) {
						description = description.substring(workspacePath.length);
					}
				}

				description = ` → ${description}`;
			}

			return this.fixChangedItem(threadItem.addSource(filename, path, description, sourceInfo, this.id));

		} else {
			return undefined;
		}
	}

	public removeSources(threadId: number): TreeNode | undefined {

		this.sourceUrls = [];

		let threadItem = this.children.find((child) => (child.id === threadId));
		return threadItem ? threadItem.removeSources() : undefined;

	}

	public getSourceUrls(): string[] {
		return this.sourceUrls;
	}

	public getChildren(): TreeNode[] {

		this.treeItem.collapsibleState = vscode.TreeItemCollapsibleState.Expanded;

		if (this.showThreads || (this.children.length > 1)) {

			this.showThreads = true;
			return this.children;

		} else if (this.children.length == 1) {

			return this.children[0].getChildren();

		} else {
			return [];
		}
	}

	private fixChangedItem(changedItem: TreeNode | undefined): TreeNode | undefined {

		if (!changedItem) return undefined;

		if (!this.showThreads && (changedItem instanceof ThreadNode)) {
			return this;
		} else {
			return changedItem;
		}
	}
}

/**
 * Split a URL with '/' as the separator, without splitting the origin or the search portion
 */
function splitURL(urlString: string): string[] {

	let originLength: number;
	let i = urlString.indexOf(':');
	if (i >= 0) {
		i++;
		if (urlString[i] === '/') i++;
		if (urlString[i] === '/') i++;
		originLength = urlString.indexOf('/', i);
	} else {
		originLength = 0;
	}

	let searchStartIndex = urlString.indexOf('?', originLength);
	if (searchStartIndex < 0) {
		searchStartIndex = urlString.length;
	}

	let origin = urlString.substr(0, originLength);
	let search = urlString.substr(searchStartIndex);
	let path = urlString.substring(originLength, searchStartIndex);

	let result = path.split('/');
	result[0] = origin + result[0];
	result[result.length - 1] += search;

	return result;
}
