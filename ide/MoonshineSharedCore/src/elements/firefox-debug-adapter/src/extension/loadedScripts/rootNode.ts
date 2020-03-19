import * as vscode from 'vscode';
import { ThreadStartedEventBody, NewSourceEventBody } from '../../common/customEvents';
import { TreeNode } from './treeNode';
import { SessionNode } from './sessionNode';

export class RootNode extends TreeNode {

	private children: SessionNode[] = [];
	private showSessions = false;

	public constructor() {
		super('');
		this.treeItem.contextValue = 'root';
	}

	public addSession(session: vscode.DebugSession): TreeNode | undefined {

		if (!this.children.some((child) => (child.id === session.id))) {

			let index = this.children.findIndex((child) => (child.treeItem.label! > session.name));
			if (index < 0) index = this.children.length;

			this.children.splice(index, 0, new SessionNode(session, this));

			return this;

		} else {
			return undefined;
		}
	}

	public removeSession(sessionId: string): TreeNode | undefined {

		this.children = this.children.filter((child) => (child.id !== sessionId));
		return this;

	}

	public addThread(
		threadInfo: ThreadStartedEventBody,
		sessionId: string
	): TreeNode | undefined {

		let sessionItem = this.children.find((child) => (child.id === sessionId));
		return sessionItem ? this.fixChangedItem(sessionItem.addThread(threadInfo)) : undefined;

	}

	public removeThread(
		threadId: number,
		sessionId: string
	): TreeNode | undefined {

		let sessionItem = this.children.find((child) => (child.id === sessionId));
		return sessionItem ? this.fixChangedItem(sessionItem.removeThread(threadId)) : undefined;

	}

	public addSource(
		sourceInfo: NewSourceEventBody,
		sessionId: string
	): TreeNode | undefined {

		let sessionItem = this.children.find((child) => (child.id === sessionId));
		return sessionItem ? this.fixChangedItem(sessionItem.addSource(sourceInfo)) : undefined;

	}

	public removeSources(threadId: number, sessionId: string): TreeNode | undefined {

		let sessionItem = this.children.find((child) => (child.id === sessionId));
		return sessionItem ? this.fixChangedItem(sessionItem.removeSources(threadId)) : undefined;

	}

	public getSourceUrls(sessionId: string): string[] | undefined {

		const sessionNode = this.children.find(child => (child.id === sessionId));
		return sessionNode ? sessionNode.getSourceUrls() : undefined;

	}

	public getChildren(): TreeNode[] {

		this.treeItem.collapsibleState = vscode.TreeItemCollapsibleState.Expanded;

		if (this.showSessions || (this.children.length > 1)) {

			this.showSessions = true;
			return this.children;

		} else if (this.children.length == 1) {

			return this.children[0].getChildren();

		} else {
			return [];
		}
	}

	private fixChangedItem(changedItem: TreeNode | undefined): TreeNode | undefined {

		if (!changedItem) return undefined;

		if (!this.showSessions && (changedItem instanceof SessionNode)) {
			return this;
		} else {
			return changedItem;
		}
	}
}
