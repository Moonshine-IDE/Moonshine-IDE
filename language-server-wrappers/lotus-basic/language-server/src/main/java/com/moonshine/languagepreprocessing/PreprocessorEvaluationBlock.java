package com.moonshine.languagepreprocessing;

import java.util.ArrayList;
import java.util.List;

public class PreprocessorEvaluationBlock {

	PreprocessorEvaluationBlock parentBlock;
	boolean shouldEvaluate;
	int blockStart;
	List<Boolean> evaluationResults=new ArrayList<>();
	public PreprocessorEvaluationBlock(PreprocessorEvaluationBlock parentBlock, boolean shouldEvaluate, int blockStart,
			List<Boolean> evaluationResults) {
		super();
		this.parentBlock = parentBlock;
		this.shouldEvaluate = shouldEvaluate;
		this.blockStart = blockStart;
		this.evaluationResults = evaluationResults;
	}
	public PreprocessorEvaluationBlock getParentBlock() {
		return parentBlock;
	}
	public void setParentBlock(PreprocessorEvaluationBlock parentBlock) {
		this.parentBlock = parentBlock;
	}
	public boolean isShouldEvaluate() {
		return shouldEvaluate;
	}
	public void setShouldEvaluate(boolean shouldEvaluate) {
		this.shouldEvaluate = shouldEvaluate;
	}
	public int getBlockStart() {
		return blockStart;
	}
	public void setBlockStart(int blockStart) {
		this.blockStart = blockStart;
	}
	public List<Boolean> getEvaluationResults() {
		return evaluationResults;
	}
	public void setEvaluationResults(List<Boolean> evaluationResults) {
		this.evaluationResults = evaluationResults;
	}
	
	

}
