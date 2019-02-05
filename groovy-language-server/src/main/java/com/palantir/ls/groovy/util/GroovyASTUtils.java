package com.palantir.ls.groovy.util;

import java.util.Comparator;
import java.util.List;

import com.palantir.ls.groovy.ASTNodeVisitor;

import org.codehaus.groovy.ast.ASTNode;
import org.codehaus.groovy.ast.ClassNode;
import org.codehaus.groovy.ast.MethodNode;
import org.codehaus.groovy.ast.Parameter;
import org.codehaus.groovy.ast.PropertyNode;
import org.codehaus.groovy.ast.expr.ArgumentListExpression;
import org.codehaus.groovy.ast.expr.ClassExpression;
import org.codehaus.groovy.ast.expr.ConstructorCallExpression;
import org.codehaus.groovy.ast.expr.MethodCallExpression;
import org.codehaus.groovy.ast.expr.PropertyExpression;
import org.codehaus.groovy.ast.expr.VariableExpression;

public class GroovyASTUtils
{
	public static ClassNode getEnclosingClass(ASTNode node, ASTNodeVisitor astVisitor)
	{
		ASTNode current = node;
		while(current != null)
		{
			if(current instanceof ClassNode)
			{
				return (ClassNode) current;
			}
			current = astVisitor.getParent(current);
		}
		return null;
	}

	public static PropertyNode getPropertyFromExpression(PropertyExpression node, ASTNodeVisitor astVisitor)
	{
        PropertyNode result = null;
        if (node.getObjectExpression() instanceof ClassExpression) {
            ClassExpression expression = (ClassExpression) node.getObjectExpression();
            // This means it's an expression like this: SomeClass.someMethod
            result = expression.getType().getProperty(node.getProperty().getText());
        } else if (node.getObjectExpression() instanceof ConstructorCallExpression) {
            ConstructorCallExpression expression = (ConstructorCallExpression) node.getObjectExpression();
            // Local function, no class used (or technically this used).
            result = expression.getType().getProperty(node.getProperty().getText());
        } else if (node.getObjectExpression() instanceof VariableExpression) {
            // function called on instance of some class
			VariableExpression var = (VariableExpression) node.getObjectExpression();
            if (var.getName().equals("this")) {
				ClassNode enclosingClass = getEnclosingClass(node, astVisitor);
				if(enclosingClass != null)
				{
					result = enclosingClass.getProperty(node.getProperty().getText());
				}
            }
            else if (var.getOriginType() != null) {
				result = var.getOriginType().getProperty(node.getProperty().getText());
            }
		}
		return result;
	}

	public static MethodNode getMethodFromCallExpression(MethodCallExpression node, ASTNodeVisitor astVisitor)
	{
        List<MethodNode> possibleMethods = null;
        if (node.getObjectExpression() instanceof ClassExpression) {
            ClassExpression expression = (ClassExpression) node.getObjectExpression();
            // This means it's an expression like this: SomeClass.someMethod
            possibleMethods = expression.getType().getMethods(node.getMethod().getText());
        } else if (node.getObjectExpression() instanceof ConstructorCallExpression) {
            ConstructorCallExpression expression = (ConstructorCallExpression) node.getObjectExpression();
            // Local function, no class used (or technically this used).
            possibleMethods = expression.getType().getMethods(node.getMethod().getText());
        } else if (node.getObjectExpression() instanceof VariableExpression) {
            // function called on instance of some class
			VariableExpression var = (VariableExpression) node.getObjectExpression();
            if (var.getName().equals("this")) {
				ClassNode enclosingClass = getEnclosingClass(node, astVisitor);
				if(enclosingClass != null)
				{
					possibleMethods = enclosingClass.getMethods(node.getMethod().getText());
				}
            }
            else if (var.getOriginType() != null) {
				possibleMethods = var.getOriginType().getMethods(node.getMethod().getText());
            }
		}

        if (possibleMethods != null && !possibleMethods.isEmpty()
                //&& classes.containsKey(parentClass.getName())
                && node.getArguments() instanceof ArgumentListExpression) {
            ArgumentListExpression actualArguments = (ArgumentListExpression) node.getArguments();
            MethodNode foundMethod = possibleMethods.stream().max(new Comparator<MethodNode>() {
                public int compare(MethodNode m1, MethodNode m2) {
                    int m1Value = calculateArgumentsScore(m1.getParameters(), actualArguments);
                    int m2Value = calculateArgumentsScore(m2.getParameters(), actualArguments);
                    if(m1Value > m2Value)
                    {
                        return 1;
                    }
                    else if(m1Value < m2Value)
                    {
                        return -1;
                    }
                    return 0;
                }
            }).orElse(null);
            return foundMethod;
		}
		return null;
	}

    private static int calculateArgumentsScore(Parameter[] parameters, ArgumentListExpression arguments) {
        int score = 0;
        if(parameters.length == arguments.getExpressions().size()) {
            score += 100;
            for (int i = 0; i < parameters.length; i++) {
                // If they aren't the same type, return false
                ClassNode argType = arguments.getExpression(i).getType();
                ClassNode paramType = parameters[i].getType();
                if (argType.equals(paramType)) {
                    // equal types are preferred
                    score += 10;
                }
                else if (argType.isDerivedFrom(paramType)) {
                    // subtypes are nice, but less important
                    score++;
                }
                else {
                    //if a type doesn't match at all, stop checking the rest
                    break;
                }
            }
        }
        return score;
    }
}