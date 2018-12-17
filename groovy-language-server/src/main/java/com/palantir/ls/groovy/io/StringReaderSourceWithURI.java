package com.palantir.ls.groovy.io;

import java.net.URI;

import org.codehaus.groovy.control.CompilerConfiguration;
import org.codehaus.groovy.control.io.StringReaderSource;

public class StringReaderSourceWithURI extends StringReaderSource
{
	private URI uri;

	public StringReaderSourceWithURI( String string, URI uri, CompilerConfiguration configuration ) {
		super( string, configuration );
		this.uri = uri;
	}
	
    public URI getURI() {
		return uri;
	}
}