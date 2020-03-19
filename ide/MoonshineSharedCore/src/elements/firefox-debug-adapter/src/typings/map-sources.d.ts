declare module "@gulp-sourcemaps/map-sources" {
	function mapSources(mapFn: (sourcePath: string, file: any) => string): NodeJS.ReadWriteStream;
	namespace mapSources {}
	export = mapSources;
}
