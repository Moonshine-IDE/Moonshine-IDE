import * as vscode from 'vscode';

export class PopupAutohideManager {

	private button: vscode.StatusBarItem | undefined;

	constructor(
		private readonly sendCustomRequest: (command: string, args?: any) => Promise<any>
	) {}

	public async setPopupAutohide(popupAutohide: boolean): Promise<void> {
		await this.sendCustomRequest('setPopupAutohide', popupAutohide.toString());
		this.setButtonText(popupAutohide);
	}

	public async togglePopupAutohide(): Promise<void> {
		const popupAutohide = await this.sendCustomRequest('togglePopupAutohide');
		this.setButtonText(popupAutohide);
	}

	public enableButton(popupAutohide: boolean): void {

		if (!this.button) {
			this.button = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left);
			this.button.command = 'extension.firefox.togglePopupAutohide';
			this.button.text = '';
			this.button.show();
		}

		this.setButtonText(popupAutohide);
	}

	public disableButton(): void {
		if (this.button) {
			this.button.dispose();
			this.button = undefined;
		}
	}

	private setButtonText(popupAutohide: boolean): void {
		if (this.button) {
			this.button.text = `Popup auto-hide ${popupAutohide ? 'enabled' : 'disabled'}`;
		}
	}
}
