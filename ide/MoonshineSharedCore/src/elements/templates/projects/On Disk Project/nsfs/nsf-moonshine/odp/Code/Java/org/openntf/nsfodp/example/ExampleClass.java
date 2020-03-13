package org.openntf.nsfodp.example;

//import org.apache.commons.lang3.SystemUtils;

/**
 * This is an example class.
 * 
 * @author Jesse Gallagher
 * @since 1.0
 */
public class ExampleClass {
	private String foo;
	private com.example.embedded.ExampleClass inner = new com.example.embedded.ExampleClass();
	//private boolean is8 = SystemUtils.IS_JAVA_1_8; // To see if Maven dependencies are used
	
	public String getFoo() {
		return foo;
	}
	
	public void setFoo(String foo) {
		this.foo = foo;
	}
}
