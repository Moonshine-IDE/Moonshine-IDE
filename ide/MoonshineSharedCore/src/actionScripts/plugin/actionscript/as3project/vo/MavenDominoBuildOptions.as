
/********************************
 * Date: Jan,16th 2020
 * Domino maven plugin build options 
 */
package actionScripts.plugin.actionscript.as3project.vo
{
    import actionScripts.plugin.build.vo.BuildActionVO;
    import actionScripts.utils.SerializeUtil;

    public class MavenDominoBuildOptions 
    {
        protected var _dominoNotesProgram:String;
        protected var _dominoNotesPlatform:String;

        public function set dominoNotesProgram(value:String):void
        {
            _dominoNotesProgram = value;
        }

        public function get dominoNotesProgram():String
        {
            return _dominoNotesProgram;
        }

        public function set dominoNotesPlatform(value:String):void
        {
            _dominoNotesPlatform = value;
        }

        public function get dominoNotesPlatform():String { 
            return _dominoNotesPlatform ;
        }
        
        public function MavenDominoBuildOptions()
        {
           // super(defaultMavenBuildPath);
        }
    }
}
