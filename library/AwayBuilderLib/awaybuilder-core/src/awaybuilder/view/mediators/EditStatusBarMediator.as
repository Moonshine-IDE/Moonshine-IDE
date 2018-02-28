package awaybuilder.view.mediators
{
	import awaybuilder.view.components.events.StatusBarEvent;
	import awaybuilder.controller.scene.events.SceneEvent;
	import awaybuilder.model.DocumentModel;
	import awaybuilder.utils.scene.CameraManager;
	import awaybuilder.view.components.EditStatusBar;
	import awaybuilder.view.components.events.ToolBarZoomEvent;
	import awaybuilder.view.scene.events.Scene3DManagerEvent;
	
	import org.robotlegs.mvcs.Mediator;
	
	public class EditStatusBarMediator extends Mediator
	{
		[Inject]
		public var view:EditStatusBar;
		
		[Inject]
		public var document:DocumentModel;
		
		[Inject]
		public var statusBar:EditStatusBar;
		
		override public function onRegister():void
		{	
			this.eventMap.mapListener(this.statusBar, ToolBarZoomEvent.ZOOM_IN, statusBar_zoomInHandler);
			this.eventMap.mapListener(this.statusBar, ToolBarZoomEvent.ZOOM_OUT, statusBar_zoomOutHandler);
			this.eventMap.mapListener(this.statusBar, ToolBarZoomEvent.ZOOM_TO, statusBar_zoomToHandler);
			
			addContextListener( Scene3DManagerEvent.ZOOM_DISTANCE_DELTA, eventDispatcher_zoomChangeHandler);
			addContextListener( Scene3DManagerEvent.ZOOM_TO_DISTANCE, eventDispatcher_zoomSetHandler);

			addContextListener( SceneEvent.UPDATE_BREADCRUMBS, eventDispatcher_updateBreadcrumbs);
			
			addViewListener( StatusBarEvent.CONTAINER_CLICKED, view_containerClickedHandler );
		}
		
		private function eventDispatcher_zoomChangeHandler(event:Scene3DManagerEvent):void
		{
			statusBar.zoom += event.currentValue.x*CameraManager.ZOOM_MULTIPLIER;
			CameraManager.radius = CameraManager.zoomFunction(statusBar.zoom);
		}

		private function eventDispatcher_zoomSetHandler(event:Scene3DManagerEvent):void
		{
			statusBar.zoom = CameraManager.distanceFunction(event.currentValue.x);
			CameraManager.radius = CameraManager.zoomFunction(statusBar.zoom);
		}
		
		private function eventDispatcher_updateBreadcrumbs(event:SceneEvent):void
		{
			statusBar.updateBreadCrumb(event.options as Array);
		}
		
		private function statusBar_zoomToHandler(event:ToolBarZoomEvent):void
		{
			CameraManager.radius = CameraManager.zoomFunction(statusBar.zoom);
		}
		
		private function statusBar_zoomInHandler(event:ToolBarZoomEvent):void
		{
			statusBar.zoom += CameraManager.ZOOM_DELTA_VALUE;
			CameraManager.radius = CameraManager.zoomFunction(statusBar.zoom);
		}
		
		private function statusBar_zoomOutHandler(event:ToolBarZoomEvent):void
		{
			statusBar.zoom -= CameraManager.ZOOM_DELTA_VALUE;
			CameraManager.radius = CameraManager.zoomFunction(statusBar.zoom);
		}
		
		private function view_containerClickedHandler(event:StatusBarEvent):void 
		{
			var sE:SceneEvent = new SceneEvent(SceneEvent.CONTAINER_CLICKED);
			sE.options = event.item;
			dispatch(sE);
		}
	}
}