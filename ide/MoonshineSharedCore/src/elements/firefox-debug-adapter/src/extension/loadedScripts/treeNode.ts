import * as vscode from 'vscode';

export abstract class TreeNode {

	public readonly treeItem: vscode.TreeItem;

	public constructor(
		label: string,
		public parent?: TreeNode,
		description?: string,
		collapsibleState: vscode.TreeItemCollapsibleState = vscode.TreeItemCollapsibleState.Collapsed
	) {
		this.treeItem = new vscode.TreeItem(label, collapsibleState);
		this.treeItem.description = description;
	}

	public getFullPath(): string {
		return '';
	}

	public abstract getChildren(): TreeNode[];
}
