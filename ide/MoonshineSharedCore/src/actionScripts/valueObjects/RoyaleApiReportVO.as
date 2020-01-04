package actionScripts.valueObjects
{
    public class RoyaleApiReportVO
    {
        public function RoyaleApiReportVO(royaleSdkPath:String, flexSdkPath:String, mainAppFile:String, reportOutputPath:String, workingDirectory:String)
        {
            _royaleSdkPath = royaleSdkPath;
            _flexSdkPath = flexSdkPath;
            _mainAppFile = mainAppFile;
            _reportOutputPath = reportOutputPath;
            _workingDirectory = workingDirectory;
        }

        private var _royaleSdkPath:String;
        public function get royaleSdkPath():String
        {
            return _royaleSdkPath;
        }

        private var _flexSdkPath:String;
        public function get flexSdkPath():String
        {
            return _flexSdkPath;
        }

        private var _mainAppFile:String;
        public function get mainAppFile():String
        {
            return _mainAppFile;
        }

        private var _reportOutputPath:String;
        public function get reportOutputPath():String
        {
            return _reportOutputPath;
        }

        private var _workingDirectory:String;
        public function get workingDirectory():String
        {
            return _workingDirectory;
        }
    }
}
