////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) STARTcloud, Inc. 2015-2022. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the Server Side Public License, version 1,
//  as published by MongoDB, Inc.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  Server Side Public License for more details.
//
//  You should have received a copy of the Server Side Public License
//  along with this program. If not, see
//
//  http://www.mongodb.com/licensing/server-side-public-license
//
//  As a special exception, the copyright holders give permission to link the
//  code of portions of this program with the OpenSSL library under certain
//  conditions as described in each individual source file and distribute
//  linked combinations including the program with the OpenSSL library. You
//  must comply with the Server Side Public License in all respects for
//  all of the code used other than as permitted herein. If you modify file(s)
//  with this exception, you may extend this exception to your version of the
//  file(s), but you are not obligated to do so. If you do not wish to do so,
//  delete this exception statement from your version. If you delete this
//  exception statement from all source files in the program, then also delete
//  it in the license file.
//
////////////////////////////////////////////////////////////////////////////////


package moonshine.plugin.problems.view;

import moonshine.theme.MoonshineTheme;
import openfl.events.Event;
import feathers.core.IOpenCloseToggle;
import actionScripts.factory.FileLocation;
import moonshine.plugin.problems.data.DiagnosticHierarchicalCollection.DiagnosticsByUri;
import moonshine.plugin.problems.vo.MoonshineDiagnostic;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.controls.Label;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.controls.ToggleButton;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;

class ProblemItemRenderer extends LayoutGroupItemRenderer implements IOpenCloseToggle {
	public function new() {
		super();
		mouseChildren = false;
	}

	private var disclosureToggle:ToggleButton;
	private var severityIcon:DiagnosticSeverityIcon;
	private var primaryLabel:Label;
	private var secondaryLabel:Label;

	private var _opened = false;

	@:flash.property
	public var opened(get, set):Bool;

	private function get_opened():Bool {
		return _opened;
	}

	private function set_opened(value:Bool):Bool {
		if (_opened == value) {
			return _opened;
		}
		_opened = value;
		setInvalid(DATA);
		dispatchEvent(new Event(Event.CHANGE));
		return _opened;
	}

	private var _padding = 4.0;
	private var _gap = 4.0;

	override private function initialize():Void {
		super.initialize();

		var viewLayout = new HorizontalLayout();
		viewLayout.verticalAlign = MIDDLE;
		viewLayout.gap = _gap;
		viewLayout.setPadding(_padding);
		layout = viewLayout;

		if (disclosureToggle == null) {
			disclosureToggle = new ToggleButton();
			disclosureToggle.variant = HierarchicalItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON;
			addChild(disclosureToggle);
		}

		if (severityIcon == null) {
			severityIcon = new DiagnosticSeverityIcon();
			addChild(severityIcon);
		}

		if (primaryLabel == null) {
			primaryLabel = new Label();
			primaryLabel.variant = MoonshineTheme.THEME_VARIANT_LIGHT_LABEL;
			addChild(primaryLabel);
		}

		if (secondaryLabel == null) {
			secondaryLabel = new Label();
			secondaryLabel.variant = MoonshineTheme.THEME_VARIANT_LIGHT_SECONDARY_LABEL;
			addChild(secondaryLabel);
		}
	}

	override private function update():Void {
		var dataInvalid = isInvalid(DATA);
		var sizeInvalid = isInvalid(SIZE);

		if (dataInvalid) {
			disclosureToggle.selected = _opened;

			if ((data is MoonshineDiagnostic)) {
				disclosureToggle.visible = false;
				var diagnostic = cast(data, MoonshineDiagnostic);
				severityIcon.severity = diagnostic.severity;
				severityIcon.includeInLayout = true;
				severityIcon.visible = true;
				primaryLabel.text = getMessagePrimaryLabel(diagnostic);
				secondaryLabel.text = getMessageSecondaryLabel(diagnostic);
				toolTip = diagnostic.message;
			} else if ((data is DiagnosticsByUri)) {
				disclosureToggle.visible = true;
				var diagnosticsByUri = cast(data, DiagnosticsByUri);
				severityIcon.includeInLayout = false;
				severityIcon.visible = false;
				primaryLabel.text = getLocationPrimaryLabel(diagnosticsByUri);
				secondaryLabel.text = getLocationSecondaryLabel(diagnosticsByUri);
				var file = new FileLocation(diagnosticsByUri.uri, true);
				toolTip = file.fileBridge.nativePath;
			} else {
				disclosureToggle.visible = false;
				severityIcon.includeInLayout = false;
				severityIcon.visible = false;
				primaryLabel.text = null;
				secondaryLabel.text = null;
				toolTip = null;
			}
		}

		refreshPrimaryLabelWidth();

		super.update();
	}

	private function refreshPrimaryLabelWidth():Void {
		var primaryLabelWidth = this.explicitWidth != null ? this.explicitWidth : 0.0;
		primaryLabelWidth -= (2.0 * _padding);
		if (secondaryLabel.text != null) {
			secondaryLabel.validateNow();
			primaryLabelWidth -= (secondaryLabel.width + _gap);
		}
		if (disclosureToggle.includeInLayout) {
			disclosureToggle.validateNow();
			primaryLabelWidth -= (disclosureToggle.width + _gap);
		}
		if (severityIcon.includeInLayout) {
			severityIcon.validateNow();
			primaryLabelWidth -= (severityIcon.width + _gap);
		}
		if (primaryLabelWidth < 0.0) {
			primaryLabelWidth = 0.0;
		}
		primaryLabel.maxWidth = primaryLabelWidth;
	}

	private inline function getLocationPrimaryLabel(diagnosticsByUri:DiagnosticsByUri):String {
		var uri = diagnosticsByUri.uri;
		var index = uri.lastIndexOf("/");
		while (index == (uri.length - 1)) {
			uri = uri.substr(0, uri.length - 1);
			index = uri.lastIndexOf("/");
		}
		var fileName = uri.substr(index + 1);
		if (fileName.length == 0 && diagnosticsByUri.project != null) {
			fileName = diagnosticsByUri.project.name;
		}
		return fileName;
	}

	private inline function getLocationSecondaryLabel(diagnosticsByUri:DiagnosticsByUri):String {
		if (diagnosticsByUri.project != null) {
			return diagnosticsByUri.project.name;
		}
		return null;
	}

	private inline function getMessagePrimaryLabel(diagnostic:MoonshineDiagnostic):String {
		return diagnostic.message;
	}

	private inline function getMessageSecondaryLabel(diagnostic:MoonshineDiagnostic):String {
		var hasCode = diagnostic.code != null && diagnostic.code.length > 0;
		var range = diagnostic.range;
		var start = range.start;
		var hasRangeStart = start != null;
		if (hasCode || hasRangeStart) {
			var result = "";
			if (hasCode) {
				result += "(" + diagnostic.code + ")";
			}
			if (hasRangeStart) {
				result += " [Ln " + (start.line + 1) + ", Col " + (start.character + 1) + "]";
			}
			return result;
		}
		return null;
	}
}
