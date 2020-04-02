declare module "gulp-nop" {
	function nop(): NodeJS.ReadWriteStream;
	namespace nop {}
	export = nop;
}
	