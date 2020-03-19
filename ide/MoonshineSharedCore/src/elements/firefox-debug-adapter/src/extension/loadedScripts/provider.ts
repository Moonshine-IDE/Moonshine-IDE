import * as vscode from 'vscode';
import { ThreadStartedEventBody, NewSourceEventBody } from '../../common/customEvents';
import { TreeNode } from './treeNode';
import { RootNode } from './rootNode';

export class LoadedScriptsProvider implements vscode.TreeDataProvider<TreeNode> {

	private readonly root = new RootNode();

	private readonly treeDataChanged = new vscode.EventEmitter<TreeNode>();
	public readonly onDidChangeTreeData: vscode.Event<TreeNode>;

	public constructor() {
		this.onDidChangeTreeData = this.treeDataChanged.event;
	}

	public getTreeItem(node: TreeNode): vscode.TreeItem {
		return node.treeItem;
	}

	public getChildren(node?: TreeNode): vscode.ProviderResult<TreeNode[]> {
		let parent = (node || this.root);
		return parent.getChildren();
	}

	public addSession(session: vscode.DebugSession) {
		let changedItem = this.root.addSession(session);
		this.sendTreeDataChangedEvent(changedItem);
	}

	public removeSession(sessionId: string) {
		let changedItem = this.root.removeSession(sessionId);
		this.sendTreeDataChangedEvent(changedItem);
	}

	public addThread(threadInfo: ThreadStartedEventBody, sessionId: string) {
		let changedItem = this.root.addThread(threadInfo, sessionId);
		this.sendTreeDataChangedEvent(changedItem);
	}

	public removeThread(threadId: number, sessionId: string) {
		let changedItem = this.root.removeThread(threadId, sessionId);
		this.sendTreeDataChangedEvent(changedItem);
	}

	public addSource(sourceInfo: NewSourceEventBody, sessionId: string) {
		let changedItem = this.root.addSource(sourceInfo, sessionId);
		this.sendTreeDataChangedEvent(changedItem);
	}

	public removeSources(threadId: number, sessionId: string) {
		let changedItem = this.root.removeSources(threadId, sessionId);		
		this.sendTreeDataChangedEvent(changedItem);
	}

	public getSourceUrls(sessionId: string): string[] | undefined {
		return this.root.getSourceUrls(sessionId);
	}

	private sendTreeDataChangedEvent(changedItem: TreeNode | undefined) {
		if (changedItem) {
			if (changedItem === this.root) {
				this.treeDataChanged.fire();
			} else {
				this.treeDataChanged.fire(changedItem);
			}
		}
	}
}
