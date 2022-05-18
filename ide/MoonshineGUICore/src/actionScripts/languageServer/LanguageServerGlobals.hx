package actionScripts.languageServer;

import feathers.data.ArrayCollection;
import moonshine.plugin.lsmonitor.vo.LanguageServerInstanceVO;

class LanguageServerGlobals {
    
    public static final languageServerInstances:ArrayCollection<LanguageServerInstanceVO> = new ArrayCollection<LanguageServerInstanceVO>();

}
