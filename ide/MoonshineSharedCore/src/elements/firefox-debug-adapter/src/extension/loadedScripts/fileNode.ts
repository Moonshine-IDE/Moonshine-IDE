import * as vscode from 'vscode';
import { NewSourceEventBody } from '../../common/customEvents';
import { TreeNode } from './treeNode';
import { NonLeafNode } from './nonLeafNode';

export class FileNode extends TreeNode {

	public constructor(
		filename: string,
		description: string | undefined,
		sourceInfo: NewSourceEventBody,
		parent: NonLeafNode,
		sessionId: string
	) {
		super((filename.length > 0) ? filename : '(index)', parent, description, vscode.TreeItemCollapsibleState.None);
		this.treeItem.contextValue = 'file';

		let pathOrUri: string;
		if (sourceInfo.path) {
			pathOrUri = sourceInfo.path;
		} else {
			pathOrUri = `debug:${encodeURIComponent(sourceInfo.url!)}?session=${encodeURIComponent(sessionId)}&ref=${sourceInfo.sourceId}`;
		}

		this.treeItem.command = {
			command: 'extension.firefox.openScript',
			arguments: [ pathOrUri ],
			title: ''
		}
	}

	public getChildren(): TreeNode[] {
		return [];
	}

	public getFullPath(): string {
		return this.parent!.getFullPath() + this.treeItem.label;
	}
}
