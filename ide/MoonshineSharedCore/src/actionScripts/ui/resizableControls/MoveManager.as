package actionScripts.ui.resizableControls {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import mx.controls.Button;
	import mx.core.Container;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;
	import mx.managers.CursorManager;

	/**
	 * Similar to the ResizeManager, this class adds support for moving a component by dragging it
	 * with the mouse. It also supports showing a custom cursor while dragging.
	 *
	 * @author Chris Callendar
	 * @date March 17th, 2009
	 */
	public class MoveManager {

		public static const DRAG_START:String = "dragStart";

		public static const DRAGGING:String = "dragging";

		public static const DRAG_END:String = "dragEnd";

		// the component that is being moved
		private var moveComponent:UIComponent;

		// the component that when dragged causes the above component to move
		private var dragComponent:UIComponent;

		private var dragging:Boolean;

		private var _enabled:Boolean;

		private var _bringToFrontOnMove:Boolean;

		private var _constrainToParentBounds:Boolean;

		private var _constrainToBounds:Rectangle;

		[Embed(source="/elements/images/cursor_move.gif")]
		public var moveIcon:Class;

		private var moveCursorID:int;

		public function MoveManager(moveComponent:UIComponent = null, dragComponent:UIComponent = null) {
			dragging = false;
			_enabled = true;
			_bringToFrontOnMove = false;
			_constrainToParentBounds = false;
			_constrainToBounds = null;
			moveCursorID = 0;
			addMoveSupport(moveComponent, dragComponent);
		}

		public function get enabled():Boolean {
			return _enabled;
		}

		public function set enabled(en:Boolean):void {
			if (en != _enabled) {
				_enabled = en;
			}
		}

		public function get bringToFrontOnMove():Boolean {
			return _bringToFrontOnMove;
		}

		public function set bringToFrontOnMove(value:Boolean):void {
			_bringToFrontOnMove = value;
		}

		/**
		 * Returns true if the component's movement is constrained to within
		 * the parent's bounds.
		 */
		public function get constrainToParentBounds():Boolean {
			return _constrainToParentBounds;
		}

		/**
		 * Set to true if the component's movement is to be constrained to within
		 * the parent's bounds.
		 */
		public function set constrainToParentBounds(value:Boolean):void {
			_constrainToParentBounds = value;
		}

		/**
		 * Returns the bounds used to constrain the component's movement.
		 */
		public function get constrainToBounds():Rectangle {
			return _constrainToBounds;
		}

		/**
		 * Sets the bounds used to constrain the component's movement.
		 */
		public function set constrainToBounds(value:Rectangle):void {
			_constrainToBounds = value;
		}

		/**
		 * Adds support for moving a component.
		 * @param moveComponent the component that will have its x and y values changed
		 * @param dragComponent the component that will have a mouse_down listener added to listen
		 *  for when the user drags it.  If null then the moveComponent is used instead.
		 */
		public function addMoveSupport(moveComponent:UIComponent, dragComponent:UIComponent = null):void {
			this.moveComponent = moveComponent;
			this.dragComponent = dragComponent;
			if (dragComponent) {
				dragComponent.addEventListener(MouseEvent.MOUSE_DOWN, dragComponentMouseDown);
			} else if (moveComponent) {
				moveComponent.addEventListener(MouseEvent.MOUSE_DOWN, dragComponentMouseDown);
			}
		}

		/**
		 * Removes move support, removes the mouse listener and the move handle.
		 */
		public function removeMoveSupport():void {
			if (dragComponent) {
				dragComponent.removeEventListener(MouseEvent.MOUSE_DOWN, dragComponentMouseDown);
			} else if (moveComponent) {
				moveComponent.removeEventListener(MouseEvent.MOUSE_DOWN, dragComponentMouseDown);
			}
		}

		/**
		 * This function gets called when the user presses down the mouse button on the
		 * dragComponent (or if not specified then the moveComponent).
		 * It starts the drag process.
		 */
		private function dragComponentMouseDown(event:MouseEvent):void {
			if (!enabled) {
				return;
			}

			// move above all others
			if (bringToFrontOnMove && moveComponent.parent) {
				var index:int = moveComponent.parent.getChildIndex(moveComponent);
				var last:int = moveComponent.parent.numChildren - 1;
				if (index != last) {
					moveComponent.parent.setChildIndex(moveComponent, last);
				}
			}

			// Constain the movement by the parent's bounds?
			var bounds:Rectangle = null;
			if (constrainToBounds != null) {
				bounds = constrainToBounds;
			} else if (constrainToParentBounds && moveComponent.parent) {
				bounds = new Rectangle(0, 0, moveComponent.parent.width, moveComponent.parent.height);
				// need to reduce the size by the component's width/height
				bounds.width = Math.max(0, bounds.width - moveComponent.width);
				bounds.height = Math.max(0, bounds.height - moveComponent.height);
			}
			moveComponent.startDrag(false, bounds);
			setMoveCursor();
			moveComponent.systemManager.addEventListener(MouseEvent.MOUSE_MOVE, dragComponentMove);
			moveComponent.systemManager.addEventListener(MouseEvent.MOUSE_UP, dragComponentMouseUp);
			moveComponent.systemManager.stage.addEventListener(Event.MOUSE_LEAVE, dragComponentMouseUp);
		}

		private function dragComponentMove(event:MouseEvent):void {
			if (!dragging) {
				dragging = true;
				moveComponent.clearStyle("top");
				moveComponent.clearStyle("right");
				moveComponent.clearStyle("bottom");
				moveComponent.clearStyle("left");
				moveComponent.dispatchEvent(new Event(DRAG_START));
			}
			moveComponent.dispatchEvent(new Event(DRAGGING));
		}

		private function dragComponentMouseUp(event:Event):void {
			moveComponent.stopDrag();
			removeMoveCursor();
			if (dragging) {
				dragging = false;
				moveComponent.dispatchEvent(new Event(DRAG_END));
			}
			moveComponent.systemManager.removeEventListener(MouseEvent.MOUSE_MOVE, dragComponentMove);
			moveComponent.systemManager.removeEventListener(MouseEvent.MOUSE_UP, dragComponentMouseUp);
			moveComponent.systemManager.stage.removeEventListener(Event.MOUSE_LEAVE, dragComponentMouseUp);
		}

		private function setMoveCursor():void {
			if ((moveCursorID == 0) && (moveIcon != null)) {
				moveCursorID = CursorManager.setCursor(moveIcon, 2, -12, -10);
			}
		}

		private function removeMoveCursor():void {
			if (moveCursorID != 0) {
				CursorManager.removeCursor(moveCursorID);
				moveCursorID = 0;
			}
		}

	}
}