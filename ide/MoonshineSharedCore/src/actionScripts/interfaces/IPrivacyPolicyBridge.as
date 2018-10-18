package actionScripts.interfaces
{
    import mx.core.IFlexDisplayObject;

    public interface IPrivacyPolicyBridge
    {
        function getNewPrivacyPolicyScreen(closeListener:Function):IFlexDisplayObject;
    }
}
