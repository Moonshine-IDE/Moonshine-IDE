package moonshine.plugin.workflows.views;

import openfl.events.Event;
import feathers.controls.Check;
import moonshine.plugin.workflows.vo.WorkflowVO;
import feathers.core.InvalidationFlag;
import feathers.controls.dataRenderers.IDataRenderer;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;

class WorkflowTreeItemRenderer extends HierarchicalItemRenderer implements IDataRenderer
{
    public static final EVENT_WORKFLOW_SELECTION_CHANGE = "event-workflow-selection-change";

    private var cbSelect:Check;

    public function new() 
    {
        super();
    }    

    override private function update():Void 
    {
        var dataInvalid = this.isInvalid(InvalidationFlag.DATA);
        if (dataInvalid) 
        {
            if ((this.data != null) && (this.data is WorkflowVO) && (cast(this.data, WorkflowVO).children == null))
            { 
                if (this.cbSelect == null)
                {
                    this.cbSelect = new Check();
                    this.icon = this.cbSelect;
                }
                
                this.cbSelect.removeEventListener(Event.CHANGE, onSelectionChange);
                this.cbSelect.selected = cast(this.data, WorkflowVO).isSelected;
                this.cbSelect.addEventListener(Event.CHANGE, onSelectionChange, false, 0, true);   
            }
        }

        super.update();
    }

    private function onSelectionChange(event:Event):Void
    {
        this.dispatchEvent(new Event(EVENT_WORKFLOW_SELECTION_CHANGE));
    }
}