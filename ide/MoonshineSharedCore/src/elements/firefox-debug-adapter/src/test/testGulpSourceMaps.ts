import * as os from 'os';
import * as fs from 'fs-extra';
import * as path from 'path';
import * as uuid from 'uuid';
import * as util from './util';
import * as sourceMapUtil from './sourceMapUtil';
import gulp from 'gulp';
import nop from 'gulp-nop';
import sourcemaps from 'gulp-sourcemaps';
import uglify from 'gulp-uglify';
import rename from 'gulp-rename';
import concat from 'gulp-concat';
import mapSources from '@gulp-sourcemaps/map-sources';
import { DebugClient } from 'vscode-debugadapter-testsupport';

const TESTDATA_PATH = path.join(__dirname, '../../testdata/web/sourceMaps/scripts');

describe('Gulp sourcemaps: The debugger', function() {

	let dc: DebugClient | undefined;
	let targetDir: string | undefined;

	afterEach(async function() {
		if (dc) {
			await dc.stop();
			dc = undefined;
		}
		if (targetDir) {
			await fs.remove(targetDir);
			targetDir = undefined;
		}
	});

	for (let minifyScripts of [false, true]) {
	for (let bundleScripts of [false, true]) {
	for (let embedSourceMap of [false, true]) {
	for (let separateBuildDir of [false, true]) {

		// we need to apply at least one transformation, otherwise no sourcemap will be generated
		if (!minifyScripts && !bundleScripts) continue;

		const transformations: string[] = [];
		if (minifyScripts) transformations.push('minified');
		if (bundleScripts) transformations.push('bundled');
		let descr = 
			`should map ${transformations.join(', ')} scripts ` +
			`to their original sources in ${separateBuildDir ? 'a different' : 'the same'} directory ` +
			`using an ${embedSourceMap ? 'embedded' : 'external'} source-map`;

		it(descr, async function() {

			const targetPaths = await prepareTargetDir(bundleScripts, separateBuildDir);
			targetDir = targetPaths.targetDir;

			await build(targetPaths.buildDir, minifyScripts, bundleScripts, embedSourceMap, separateBuildDir);

			dc = await util.initDebugClient('', true, {
				file: path.join(targetPaths.buildDir, 'index.html')
			});

			await sourceMapUtil.testSourcemaps(dc, targetPaths.srcDir);
		});
	}}}}
});

interface TargetPaths {
	targetDir: string;
	srcDir: string;
	buildDir: string;
}

async function prepareTargetDir(
	bundle: boolean,
	separateBuildDir: boolean
): Promise<TargetPaths> {

	let targetDir = path.join(os.tmpdir(), `vscode-firefox-debug-test-${uuid.v4()}`);
	await fs.mkdir(targetDir);
	let scriptTags = bundle ? ['bundle.js'] : ['f.min.js', 'g.min.js'];

	if (!separateBuildDir) {

		await sourceMapUtil.copyFiles(TESTDATA_PATH, targetDir, ['index.html', 'f.js', 'g.js']);
		await sourceMapUtil.injectScriptTags(targetDir, scriptTags);

		return { targetDir, srcDir: targetDir, buildDir: targetDir };

	} else {

		let srcDir = path.join(targetDir, 'src');
		await fs.mkdir(srcDir);
		let buildDir = path.join(targetDir, 'build');
		await fs.mkdir(buildDir);

		await sourceMapUtil.copyFiles(TESTDATA_PATH, srcDir, ['f.js', 'g.js']);
		await sourceMapUtil.copyFiles(TESTDATA_PATH, buildDir, ['index.html']);
		await sourceMapUtil.injectScriptTags(buildDir, scriptTags);

		return { targetDir, srcDir, buildDir };
	}
}

function build(
	buildDir: string,
	minifyScripts: boolean,
	bundleScripts: boolean,
	embedSourceMap: boolean,
	separateBuildDir: boolean
): Promise<void> {

	return sourceMapUtil.waitForStreamEnd(
		gulp.src(path.join(buildDir, separateBuildDir ? '../src/*.js' : '*.js'))
		.pipe(sourcemaps.init())
		.pipe(minifyScripts ? uglify({ mangle: false, compress: { sequences: false } }) : nop())
		.pipe(bundleScripts ? concat('bundle.js') : rename((path) => { path.basename += '.min'; }))
		.pipe(mapSources((srcPath) => separateBuildDir ? '../src/' + srcPath : srcPath))
		.pipe(sourcemaps.write(embedSourceMap ? undefined : '.', { includeContent: false }))
		.pipe(gulp.dest(buildDir)));
}
