import * as url from 'url';
import * as fs from 'fs-extra';
import * as net from 'net';
import * as http from 'http';
import * as https from 'https';
import fileUriToPath from 'file-uri-to-path';
import dataUriToBuffer from 'data-uri-to-buffer';
import { Log } from './log';
import { delay } from '../../common/util';

let log = Log.create('net');

/**
 * connect to a TCP port
 */
export function connect(port: number, host?: string): Promise<net.Socket> {
	return new Promise<net.Socket>((resolve, reject) => {
		let socket = net.connect(port, host || 'localhost');
		socket.on('connect', () => resolve(socket));
		socket.on('error', reject);
	});
}

/**
 * Try to connect to a TCP port and keep retrying for the number of seconds given by `timeout`
 * if the connection is rejected initially.
 * Used to connect to Firefox after launching it.
 */
export async function waitForSocket(port: number, timeout: number): Promise<net.Socket> {
	const maxIterations = timeout * 5;
	let lastError: any;
	for (var i = 0; i < maxIterations; i++) {
		try {
			return await connect(port);
		} catch(err) {
			lastError = err;
			await delay(200);
		}
	}
	throw lastError;
}

export function urlBasename(url: string): string {
	let lastSepIndex = url.lastIndexOf('/');
	if (lastSepIndex < 0) {
		return url;
	} else {
		return url.substring(lastSepIndex + 1);
	}
}

export function urlDirname(url: string): string {
	let lastSepIndex = url.lastIndexOf('/');
	if (lastSepIndex < 0) {
		return url;
	} else {
		return url.substring(0, lastSepIndex + 1);
	}
}

/**
 * fetch the document from a URI, with support for the http(s), file and data schemes
 */
export async function getUri(uri: string): Promise<string> {

	if (uri.startsWith('data:')) {
		return dataUriToBuffer(uri).toString();
	}

	if (uri.startsWith('file:')) {
		return await fs.readFile(fileUriToPath(uri), 'utf8');
	}

	if (!uri.startsWith('http:') && !uri.startsWith('https:')) {
		throw new Error(`Fetching ${uri} not supported`);
	}

	return await new Promise<string>((resolve, reject) => {
		const parsedUrl = url.parse(uri);
		const get = (parsedUrl.protocol === 'https:') ? https.get : http.get;
		const options = Object.assign({ rejectUnauthorized: false }, parsedUrl) as https.RequestOptions;

		get(options, response => {
			let responseData = '';
			response.on('data', chunk => responseData += chunk);
			response.on('end', () => {
				if (response.statusCode === 200) {
					resolve(responseData);
				} else {
					log.error(`HTTP GET failed with: ${response.statusCode} ${response.statusMessage}`);
					reject(new Error(responseData.trim()));
				}
			});
		}).on('error', e => {
			log.error(`HTTP GET failed: ${e}`);
			reject(e);
		});
	});
}
