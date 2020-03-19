"use strict";
/**
 * Module dependencies.
 */
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const assert_1 = __importDefault(require("assert"));
const src_1 = __importDefault(require("../src"));
describe('data-uri-to-buffer', function () {
    it('should decode bare-bones Data URIs', function () {
        var uri = 'data:,Hello%2C%20World!';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('text/plain;charset=US-ASCII', buf.typeFull);
        assert_1.default.equal('US-ASCII', buf.charset);
        assert_1.default.equal('Hello, World!', buf.toString());
    });
    it('should decode bare-bones "base64" Data URIs', function () {
        var uri = 'data:text/plain;base64,SGVsbG8sIFdvcmxkIQ%3D%3D';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('Hello, World!', buf.toString());
    });
    it('should decode plain-text Data URIs', function () {
        var html = '<!DOCTYPE html>' +
            '<html lang="en">' +
            '<head><title>Embedded Window</title></head>' +
            '<body><h1>42</h1></body>' +
            '</html>';
        // Escape the HTML for URL formatting
        var uri = 'data:text/html;charset=utf-8,' + encodeURIComponent(html);
        var buf = src_1.default(uri);
        assert_1.default.equal('text/html', buf.type);
        assert_1.default.equal('utf-8', buf.charset);
        assert_1.default.equal(html, buf.toString());
    });
    // the next 4 tests are from:
    // https://bug161965.bugzilla.mozilla.org/attachment.cgi?id=94670&action=view
    it('should decode "ISO-8859-8 in Base64" URIs', function () {
        var uri = 'data:text/plain;charset=iso-8859-8-i;base64,+ezl7Q==';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('iso-8859-8-i', buf.charset);
        assert_1.default.equal(4, buf.length);
        assert_1.default.equal(0xf9, buf[0]);
        assert_1.default.equal(0xec, buf[1]);
        assert_1.default.equal(0xe5, buf[2]);
        assert_1.default.equal(0xed, buf[3]);
    });
    it('should decode "ISO-8859-8 in URL-encoding" URIs', function () {
        var uri = 'data:text/plain;charset=iso-8859-8-i,%f9%ec%e5%ed';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('iso-8859-8-i', buf.charset);
        assert_1.default.equal(4, buf.length);
        assert_1.default.equal(0xf9, buf[0]);
        assert_1.default.equal(0xec, buf[1]);
        assert_1.default.equal(0xe5, buf[2]);
        assert_1.default.equal(0xed, buf[3]);
    });
    it('should decode "UTF-8 in Base64" URIs', function () {
        var uri = 'data:text/plain;charset=UTF-8;base64,16nXnNeV150=';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('UTF-8', buf.charset);
        assert_1.default.equal(8, buf.length);
        assert_1.default.equal('שלום', buf.toString('utf8'));
    });
    it('should decode "UTF-8 in URL-encoding" URIs', function () {
        var uri = 'data:text/plain;charset=UTF-8,%d7%a9%d7%9c%d7%95%d7%9d';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('UTF-8', buf.charset);
        assert_1.default.equal(8, buf.length);
        assert_1.default.equal('שלום', buf.toString('utf8'));
    });
    // this next one is from Wikipedia IIRC
    it('should decode "base64" Data URIs with newlines', function () {
        var uri = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA\n' +
            'AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO\n' +
            '9TXL0Y4OHwAAAABJRU5ErkJggg==';
        var buf = src_1.default(uri);
        assert_1.default.equal('image/png', buf.type);
        assert_1.default.equal('iVBORw0KGgoAAAANSUhEUgAAAAUA' +
            'AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO' +
            '9TXL0Y4OHwAAAABJRU5ErkJggg==', buf.toString('base64'));
    });
    it('should decode a plain-text URI with a space character in it', function () {
        var uri = 'data:,foo bar';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('foo bar', buf.toString());
    });
    it('should decode data with a "," comma char', function () {
        var uri = 'data:,a,b';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('a,b', buf.toString());
    });
    it('should decode data with traditionally reserved characters like ";"', function () {
        var uri = 'data:,;test';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal(';test', buf.toString());
    });
    it('should not default to US-ASCII if main type is provided', function () {
        var uri = 'data:text/plain,abc';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('text/plain', buf.typeFull);
        assert_1.default.equal('', buf.charset);
        assert_1.default.equal('abc', buf.toString());
    });
    it('should default to text/plain if main type is not provided', function () {
        var uri = 'data:;charset=UTF-8,abc';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('text/plain;charset=UTF-8', buf.typeFull);
        assert_1.default.equal('UTF-8', buf.charset);
        assert_1.default.equal('abc', buf.toString());
    });
    it('should not allow charset without a leading ;', function () {
        var uri = 'data:charset=UTF-8,abc';
        var buf = src_1.default(uri);
        assert_1.default.equal('charset=UTF-8', buf.type);
        assert_1.default.equal('charset=UTF-8', buf.typeFull);
        assert_1.default.equal('', buf.charset);
        assert_1.default.equal('abc', buf.toString());
    });
    it('should allow custom media type parameters', function () {
        var uri = 'data:application/javascript;version=1.8;charset=UTF-8,abc';
        var buf = src_1.default(uri);
        assert_1.default.equal('application/javascript', buf.type);
        assert_1.default.equal('application/javascript;version=1.8;charset=UTF-8', buf.typeFull);
        assert_1.default.equal('UTF-8', buf.charset);
        assert_1.default.equal('abc', buf.toString());
    });
    it('should allow base64 annotation anywhere', function () {
        var uri = 'data:text/plain;base64;charset=UTF-8,YWJj';
        var buf = src_1.default(uri);
        assert_1.default.equal('text/plain', buf.type);
        assert_1.default.equal('text/plain;charset=UTF-8', buf.typeFull);
        assert_1.default.equal('UTF-8', buf.charset);
        assert_1.default.equal('abc', buf.toString());
    });
});
//# sourceMappingURL=test.js.map