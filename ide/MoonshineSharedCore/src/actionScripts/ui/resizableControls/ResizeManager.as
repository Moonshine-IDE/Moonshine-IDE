package actionScripts.ui.resizableControls {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.ResizeEvent;
	import mx.managers.CursorManager;

	import spark.primitives.Rect;

	/**
	 * This is the style direction that can be set on the resize component.
	 * Defaults to "both" which means the component can be resized horizontally and vertically.
	 */
	[Style(name="resizeDirection", type="String", enumeration="both,vertical,horizontal", inherit="no")]

	/**
	 * Utility class for allowing containers to be resized by a resize handle.
	 * The resize handle will cause the UIComponent to be resized when the user drags the handle.
	 * It also supports showing a custom cursor while the resizing is occurring.
	 * The resize component can also be restricted to only allow resizing in the horizontal
	 * or vertical direction.
	 *
	 * @author Chris Callendar
	 * @date March 17th, 2009
	 */
	public class ResizeManager extends EventDispatcher {

		public static const RESIZE_START:String = "resizeStart";

		public static const RESIZE_END:String = "resizeEnd";

		public static const RESIZING:String = "resizing";

		public static const STYLE_RESIZE_DIRECTION:String = "resizeDirection";

		public static const DIRECTION_BOTH:String = "both";

		public static const DIRECTION_HORIZONTAL:String = "horizontal";

		public static const DIRECTION_VERTICAL:String = "vertical";

		private static const resizeDirections:Dictionary = new Dictionary(true);

		private const RESIZE_HANDLE_SIZE:int = 16;

		private var resizeInitX:Number = 0;

		private var resizeInitY:Number = 0;

		private var _resizeHandle:UIComponent;

		private var _enabled:Boolean;

		private var _bringToFrontOnResize:Boolean;

		private var _resizeDirection:String;

		private var _resizeComponent:UIComponent;

		private var _constrainToParentBounds:Boolean;

		private var isResizing:Boolean;

		private var startWidth:Number;

		private var startHeight:Number;

		[Embed(source="/elements/images/cursor_resize.gif")]
		public var resizeCursorIcon:Class;

		private var resizeCursorID:int;


		public function ResizeManager(resizeComponent:UIComponent = null, resizeHandle:UIComponent = null, resizeDirection:String = "both") {
			this._enabled = true;
			this.resizeComponent = resizeComponent;
			this.resizeHandle = resizeHandle;
			this._bringToFrontOnResize = false;
			this._resizeDirection = resizeDirection;
			resizeCursorID = 0;
		}

		[Bindable("enabledChanged")]
		public function get enabled():Boolean {
			return _enabled && (resizeComponent != null) && resizeComponent.enabled;
		}

		public function set enabled(en:Boolean):void {
			if (en != _enabled) {
				_enabled = en;
				dispatchEvent(new Event("enabledChanged"));
			}
		}

		[Bindable("resizeComponentChanged")]
		public function get resizeComponent():UIComponent {
			return _resizeComponent;
		}

		public function set resizeComponent(value:UIComponent):void {
			if (value != _resizeComponent) {
				_resizeComponent = value;
				dispatchEvent(new Event("resizeComponentChanged"));
			}
		}

		[Bindable("bringToFrontOnResizeChanged")]
		public function get bringToFrontOnResize():Boolean {
			return _bringToFrontOnResize;
		}

		public function set bringToFrontOnResize(value:Boolean):void {
			if (value != _bringToFrontOnResize) {
				_bringToFrontOnResize = value;
				dispatchEvent(new Event("bringToFrontOnResizeChanged"));
			}
		}

		[Bindable("resizeDirectionChanged")]
		/**
		 * Sets the resize direction.
		 * Defaults to both, meaning that the component can be resized in the horizontal
		 * and the vertical directions.
		 * If the direction is set to "horizontal", then the component can only be resized
		 * in the horizontal direction.
		 * Similarily when the direction is "vertical" only vertical resizing is allowed.
		 */
		public function get resizeDirection():String {
			var direction:String = DIRECTION_BOTH;
			if (_resizeDirection == DIRECTION_BOTH) {
				// first check if a style was set on the resize component
				var style:Object = resizeComponent.getStyle(STYLE_RESIZE_DIRECTION);
				if (style != null) {
					direction = String(style);
				} else {
					direction = resizeDirections[resizeComponent];
				}
				if ((direction != DIRECTION_HORIZONTAL) && (direction != DIRECTION_VERTICAL)) {
					direction = DIRECTION_BOTH;
				}
			}
			return direction;
		}

		public function set resizeDirection(value:String):void {
			if (value != _resizeDirection) {
				_resizeDirection = value;
				dispatchEvent(new Event("resizeDirectionChanged"));
			}
		}

		/**
		 * Returns the resizeHandle UIComponent.
		 */
		[Bindable("resizeHandleChanged")]
		public function get resizeHandle():UIComponent {
			return _resizeHandle;
		}

		public function set resizeHandle(value:UIComponent):void {
			if (value != _resizeHandle) {
				if (_resizeHandle) {
					_resizeHandle.removeEventListener(MouseEvent.MOUSE_DOWN, resizeHandler);
					_resizeHandle.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverResizeHandler);
					_resizeHandle.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutResizeHandler);
				}
				this._resizeHandle = value;
				if (_resizeHandle) {
					_resizeHandle.addEventListener(MouseEvent.MOUSE_DOWN, resizeHandler, false, 0, true);
					_resizeHandle.addEventListener(MouseEvent.MOUSE_OVER, mouseOverResizeHandler, false, 0, true);
					_resizeHandle.addEventListener(MouseEvent.MOUSE_OUT, mouseOutResizeHandler, false, 0, true);
					if (!_resizeHandle.toolTip) {
						_resizeHandle.toolTip = "Drag this handle to resize the component";
					}
				}
				dispatchEvent(new Event("resizeHandleChanged"));
			}
		}

		/**
		 * Returns true if the resizing should be constrained to keep the resizeComponent from going outside the parent bounds.
		 */
		public function get constrainToParentBounds():Boolean {
			return _constrainToParentBounds;
		}

		/**
		 * Set to true to constrain the resizing to keep the resize component inside the parent bounds.
		 */
		public function set constrainToParentBounds(value:Boolean):void {
			_constrainToParentBounds = value;
		}


		// Resize event handler
		private function resizeHandler(event:MouseEvent):void {
			if (enabled) {
				event.stopImmediatePropagation();
				startResize(event.stageX, event.stageY);
			}
		}

		private function startResize(globalX:Number, globalY:Number):void {
			// dispatch a resizeStart event - can be cancelled!
			var event:ResizeEvent = new ResizeEvent(RESIZE_START, false, true, resizeComponent.width, resizeComponent.height);
			var okay:Boolean = resizeComponent.dispatchEvent(event);
			if (okay) {
				isResizing = true;

				// move above all others
				if (bringToFrontOnResize && resizeComponent.parent) {
					var index:int = resizeComponent.parent.getChildIndex(resizeComponent);
					var last:int = resizeComponent.parent.numChildren - 1;
					if (index != last) {
						resizeComponent.parent.setChildIndex(resizeComponent, last);
					}
				}

				resizeInitX = globalX;
				resizeInitY = globalY;
				startWidth = resizeComponent.width;
				startHeight = resizeComponent.height;
				// Add event handlers so that the SystemManager handles the mouseMove and mouseUp events. 
				// Set useCapure flag to true to handle these events 
				// during the capture phase so no other component tries to handle them.
				resizeComponent.systemManager.addEventListener(MouseEvent.MOUSE_MOVE, resizeMouseMoveHandler, true, 0, true);
				resizeComponent.systemManager.addEventListener(MouseEvent.MOUSE_UP, resizeMouseUpHandler, true, 0, true);
			}
		}

		/**
		 * Resizes this panel as the user moves the mouse with the mouse button down.
		 * Also restricts the width and height based on the resizeComponent's minWidth, maxWidth, minHeight, and
		 * maxHeight properties.
		 */
		private function resizeMouseMoveHandler(event:MouseEvent):void {
			event.stopImmediatePropagation();

			var oldWidth:Number = resizeComponent.width;
			var oldHeight:Number = resizeComponent.height;
			var newWidth:Number = oldWidth + event.stageX - resizeInitX;
			var newHeight:Number = oldHeight + event.stageY - resizeInitY;
			//trace("Changing size from " + oldWidth + "x" + oldHeight + " to " + newWidth + "x" + newHeight);

			var resizeH:Boolean = (resizeDirection != DIRECTION_VERTICAL);
			var resizeV:Boolean = (resizeDirection != DIRECTION_HORIZONTAL);

			// constrain the size to keep the resize component inside the parent bounds
			if (constrainToParentBounds && resizeComponent.parent) {
				var parentWidth:Number = resizeComponent.parent.width;
				var parentHeight:Number = resizeComponent.parent.height;
				if ((resizeComponent.x + newWidth) > parentWidth) {
					newWidth = parentWidth - resizeComponent.x;
				}
				if ((resizeComponent.y + newHeight) > parentHeight) {
					newHeight = parentHeight - resizeComponent.y;
				}
			}
			// restrict the width/height
			if ((newWidth >= resizeComponent.minWidth) && (newWidth <= resizeComponent.maxWidth) && resizeH) {
				resizeComponent.width = newWidth;
			}
			if ((newHeight >= resizeComponent.minHeight) && (newHeight <= resizeComponent.maxHeight) && resizeV) {
				resizeComponent.height = newHeight;
			}


			resizeInitX = event.stageX;
			resizeInitY = event.stageY;

			// Update the scrollRect property (this is used by the PopUpManager)
			// will usually be null
			if (resizeComponent.scrollRect) {
				var rect:Rectangle = resizeComponent.scrollRect;
				rect.width = resizeComponent.width;
				rect.height = resizeComponent.height;
				resizeComponent.scrollRect = rect;
			}

			resizeComponent.dispatchEvent(new ResizeEvent(RESIZING, false, false, oldWidth, oldHeight));
		}

		/**
		 * Removes the event handlers from the SystemManager.
		 */
		private function resizeMouseUpHandler(event:MouseEvent):void {
			event.stopImmediatePropagation();
			resizeComponent.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, resizeMouseMoveHandler, true);
			resizeComponent.systemManager.removeEventListener(MouseEvent.MOUSE_UP, resizeMouseUpHandler, true);
			if (isResizing) {
				isResizing = false;
				resizeComponent.dispatchEvent(new ResizeEvent(RESIZE_END, false, false, startWidth, startHeight));
			}

			// check if the mouse is outside the resize handle
			var pt:Point = resizeHandle.globalToLocal(new Point(event.stageX, event.stageY));
			var bounds:Rectangle = new Rectangle(0, 0, resizeHandle.width, resizeHandle.height);
			var isOver:Boolean = bounds.containsPoint(pt);
			if (!isOver) {
				removeResizeCursor();
			}
		}

		private function mouseOverResizeHandler(event:MouseEvent):void {
			setResizeCursor();
			FlexGlobals.topLevelApplication.systemManager.addEventListener(MouseEvent.MOUSE_OUT, mouseOutResizeHandler, true, 0, true);
		}

		private function mouseOutResizeHandler(event:MouseEvent):void {
			if (!isResizing) {
				removeResizeCursor();
				FlexGlobals.topLevelApplication.systemManager.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutResizeHandler, true);
			}
		}

		private function setResizeCursor():void {
			if ((resizeCursorID == 0) && (resizeCursorIcon != null)) {
				resizeCursorID = CursorManager.setCursor(resizeCursorIcon);
			}
		}

		private function removeResizeCursor():void {
			if (resizeCursorID != 0) {
				CursorManager.removeCursor(resizeCursorID);
				resizeCursorID = 0;
			}
		}

		/**
		 * Sets which direction the component can be resized - "horizontal", "vertical", or "both" (default).
		 */
		public static function setResizeDirection(resizeComponent:UIComponent, direction:String = "both"):void {
			if (resizeComponent != null) {
				if ((direction == DIRECTION_HORIZONTAL) || (direction == DIRECTION_VERTICAL)) {
					resizeDirections[resizeComponent] = direction;
				} else if (resizeDirections[resizeComponent] != null) {
					delete resizeDirections[resizeComponent];
				}
			}
		}

	}
}