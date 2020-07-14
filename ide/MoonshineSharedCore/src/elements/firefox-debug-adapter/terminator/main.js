browser.windows.getAll().then((windows) => {
	for (const window of windows) {
		browser.windows.remove(window.id);
	}
});
