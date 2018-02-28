package org.robotlegs.base
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import mx.core.IWindow;
	import mx.events.FlexEvent;
	
	import org.robotlegs.core.IInjector;
	import org.robotlegs.core.IMediator;
	import org.robotlegs.core.IReflector;
	
	public class MultiWindowFlexMediatorMap extends MediatorMap
	{
		public function MultiWindowFlexMediatorMap(contextView:DisplayObjectContainer, injector:IInjector, reflector:IReflector)
		{
			super(contextView, injector, reflector);
		}
		
		private var _windows:Vector.<IWindow>;
		
		override public function set enabled(value:Boolean):void
		{
			if (value != _enabled)
			{
				for each(var window:IWindow in this._windows)
				{
					this.removeWindowListeners(window);
				}
				super.enabled = value;
				for each(window in this._windows)
				{
					this.addWindowListeners(window);
				}
			}
		}
		
		override protected function addListeners():void
		{
			super.addListeners();
			for each(var window:IWindow in this._windows)
			{
				this.addWindowListeners(window);
			}
		}
		
		override public function createMediator(viewComponent:Object):IMediator
		{
			if(viewComponent is IWindow && viewComponent != this.contextView)
			{
				var window:IWindow = IWindow(viewComponent);
				if(!this._windows)
				{
					this._windows = new Vector.<IWindow>;
				}
				var index:int = this._windows.indexOf(window);
				if(index < 0)
				{
					this.addWindowListeners(window);
					this._windows.push(window);
				}
			}
			return super.createMediator(viewComponent);
		}
		
		override public function removeMediator(mediator:IMediator):IMediator
		{
			if(mediator)
			{
				var viewComponent:Object = mediator.getViewComponent();
				if(viewComponent is IWindow)
				{
					var window:IWindow = IWindow(viewComponent);
					var index:int = this._windows.indexOf(window);
					if(index >= 0)
					{
						this._windows.splice(index, 1);
					}
					this.removeWindowListeners(window);
					for(var view:Object in this.mediatorByView)
					{
						if(view != window && DisplayObjectContainer(window).contains(DisplayObject(view)))
						{
							this.removeMediatorByView(view);
						}
					}
				}
			}
			return super.removeMediator(mediator);
		}
		
		protected function addWindowListeners(window:IWindow):void
		{
			if (enabled)
			{
				if(!window.nativeWindow)
				{
					IEventDispatcher(window).addEventListener(FlexEvent.PREINITIALIZE, window_preinitializeHandler, false, 0, true);
					return;
				}
				var stage:Stage = window.nativeWindow.stage;
				stage.addEventListener(Event.ADDED_TO_STAGE, onViewAdded, useCapture, 0, true);
				stage.addEventListener(Event.REMOVED_FROM_STAGE, onViewRemoved, useCapture, 0, true);
			}
		}
		
		protected function removeWindowListeners(window:IWindow):void
		{
			if(window.nativeWindow && enabled)
			{
				var stage:Stage = window.nativeWindow.stage;
				stage.removeEventListener(Event.ADDED_TO_STAGE, onViewAdded, useCapture);
				stage.removeEventListener(Event.REMOVED_FROM_STAGE, onViewRemoved, useCapture);
			}
		}
		
		protected function window_preinitializeHandler(event:FlexEvent):void
		{
			var window:IWindow = IWindow(event.currentTarget);
			IEventDispatcher(window).removeEventListener(FlexEvent.PREINITIALIZE, window_preinitializeHandler);
			this.addWindowListeners(window);
		}
	}
}