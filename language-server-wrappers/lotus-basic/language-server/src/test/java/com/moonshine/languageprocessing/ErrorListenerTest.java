package com.moonshine.languageprocessing;

import static org.junit.Assert.assertNotEquals;

import java.util.List;

import org.junit.Test;

public class ErrorListenerTest {
	@Test
	public void testErrorProcessing() {
		List<LotusSyntaxError> fileParsingErrors = LotusBasicErrorListener.getFileParsingErrors("ssss");
		assertNotEquals(0, fileParsingErrors.size());
	}
}
