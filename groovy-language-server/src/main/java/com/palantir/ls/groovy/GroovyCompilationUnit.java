package com.palantir.ls.groovy;

import org.codehaus.groovy.control.CompilationUnit;
import org.codehaus.groovy.control.CompilerConfiguration;
import org.codehaus.groovy.control.ErrorCollector;

public class GroovyCompilationUnit extends CompilationUnit
{
	public GroovyCompilationUnit(CompilerConfiguration config)
	{
		super(config);
	}

	public GroovyCompilationUnit(CompilerConfiguration config, ErrorCollector errorCollector)
	{
		super(config);
		this.errorCollector = errorCollector;
	}

	public void setErrorCollector(ErrorCollector errorCollector)
	{
		this.errorCollector = errorCollector;
	}
}