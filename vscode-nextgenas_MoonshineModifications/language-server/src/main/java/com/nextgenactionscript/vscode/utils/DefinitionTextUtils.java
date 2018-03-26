/*
Copyright 2016-2017 Bowler Hat LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package com.nextgenactionscript.vscode.utils;

import java.util.Collection;

import org.apache.royale.compiler.constants.IASKeywordConstants;
import org.apache.royale.compiler.constants.IASLanguageConstants;
import org.apache.royale.compiler.constants.IMetaAttributeConstants;
import org.apache.royale.compiler.definitions.IAccessorDefinition;
import org.apache.royale.compiler.definitions.IClassDefinition;
import org.apache.royale.compiler.definitions.IConstantDefinition;
import org.apache.royale.compiler.definitions.IDefinition;
import org.apache.royale.compiler.definitions.IEventDefinition;
import org.apache.royale.compiler.definitions.IFunctionDefinition;
import org.apache.royale.compiler.definitions.IGetterDefinition;
import org.apache.royale.compiler.definitions.IInterfaceDefinition;
import org.apache.royale.compiler.definitions.INamespaceDefinition;
import org.apache.royale.compiler.definitions.IParameterDefinition;
import org.apache.royale.compiler.definitions.ISetterDefinition;
import org.apache.royale.compiler.definitions.IStyleDefinition;
import org.apache.royale.compiler.definitions.ITypeDefinition;
import org.apache.royale.compiler.definitions.IVariableDefinition;
import org.apache.royale.compiler.projects.ICompilerProject;

public class DefinitionTextUtils
{
    private static final String UNDERSCORE_UNDERSCORE_AS3_PACKAGE = "__AS3__.";
    private static final String NAMESPACE_URI_AS3 = "http://adobe.com/AS3/2006/builtin";
    private static final String NAMESPACE_MX_INTERNAL = "http://www.adobe.com/2006/flex/mx/internal";
    private static final String NEW_LINE = "\n";
    private static final String INDENT = "\t";
    private static final String FILE_EXTENSION_AS = ".as";
    private static final String PATH_PREFIX_GENERATED = "generated/";

    public static class DefinitionAsText
	{
		public int startLine = 0;
		public int startColumn = 0;
		public int endLine = 0;
		public int endColumn = 0;
        public String text;
        public String path;
	}

    public static DefinitionAsText definitionToTextDocument(IDefinition definition, ICompilerProject currentProject)
	{
		if (definition instanceof IClassDefinition)
		{
            IClassDefinition classDefinition = (IClassDefinition) definition;
            return classDefinitionToTextDocument(classDefinition, currentProject, definition);
		}
		if (definition instanceof IInterfaceDefinition)
		{
            IInterfaceDefinition interfaceDefinition = (IInterfaceDefinition) definition;
            return interfaceDefinitionToTextDocument(interfaceDefinition, currentProject, definition);
		}
		if (definition instanceof IFunctionDefinition)
		{
            IFunctionDefinition functionDefinition = (IFunctionDefinition) definition;
            IDefinition parentDefinition = functionDefinition.getParent();
            if(parentDefinition instanceof ITypeDefinition)
            {
                if (parentDefinition instanceof IClassDefinition)
                {
                    IClassDefinition classDefinition = (IClassDefinition) parentDefinition;
                    return classDefinitionToTextDocument(classDefinition, currentProject, definition);
                }
                else if (parentDefinition instanceof IInterfaceDefinition)
                {
                    IInterfaceDefinition interfaceDefinition = (IInterfaceDefinition) parentDefinition;
                    return interfaceDefinitionToTextDocument(interfaceDefinition, currentProject, definition);
                }
            }
            else
            {
                return functionDefinitionToTextDocument(functionDefinition, currentProject, definition);
            }
		}
		if (definition instanceof IVariableDefinition)
		{
            IVariableDefinition variableDefinition = (IVariableDefinition) definition;
            IDefinition parentDefinition = variableDefinition.getParent();
            if(parentDefinition instanceof ITypeDefinition)
            {
                if (parentDefinition instanceof IClassDefinition)
                {
                    IClassDefinition classDefinition = (IClassDefinition) parentDefinition;
                    return classDefinitionToTextDocument(classDefinition, currentProject, definition);
                }
                else if (parentDefinition instanceof IInterfaceDefinition)
                {
                    IInterfaceDefinition interfaceDefinition = (IInterfaceDefinition) parentDefinition;
                    return interfaceDefinitionToTextDocument(interfaceDefinition, currentProject, definition);
                }
            }
            else
            {
                return variableDefinitionToTextDocument(variableDefinition, currentProject, definition);
            }
		}
		return null;
    }

    private static DefinitionAsText classDefinitionToTextDocument(IClassDefinition classDefinition, ICompilerProject currentProject, IDefinition definitionToFind)
	{
        DefinitionAsText result = new DefinitionAsText();
        result.path = definitionToGeneratedPath(classDefinition);
        String indent = "";
        StringBuilder textDocumentBuilder = new StringBuilder();
        insertHeaderCommentIntoTextDocument(classDefinition, textDocumentBuilder);
        textDocumentBuilder.append(IASKeywordConstants.PACKAGE);
        String packageName = classDefinition.getPackageName();
        if(packageName != null && packageName.length() > 0)
        {
            textDocumentBuilder.append(" ");
            textDocumentBuilder.append(packageName);
        }
        textDocumentBuilder.append(NEW_LINE);
        textDocumentBuilder.append("{");
        textDocumentBuilder.append(NEW_LINE);
        indent = increaseIndent(indent);
        textDocumentBuilder.append(indent);
        if (classDefinition.isPublic())
        {
            textDocumentBuilder.append(IASKeywordConstants.PUBLIC);
            textDocumentBuilder.append(" ");
        }
        else if (classDefinition.isInternal())
        {
            textDocumentBuilder.append(IASKeywordConstants.INTERNAL);
            textDocumentBuilder.append(" ");
        }
        if (classDefinition.isFinal())
        {
            textDocumentBuilder.append(IASKeywordConstants.FINAL);
            textDocumentBuilder.append(" ");
        }
        if (classDefinition.isDynamic())
        {
            textDocumentBuilder.append(IASKeywordConstants.DYNAMIC);
            textDocumentBuilder.append(" ");
        }
        textDocumentBuilder.append(IASKeywordConstants.CLASS);
        textDocumentBuilder.append(" ");
        appendDefinitionName(classDefinition, textDocumentBuilder, definitionToFind, result);
        String baseClassName = classDefinition.getBaseClassAsDisplayString();
        if (baseClassName != null && !baseClassName.equals(IASLanguageConstants.Object))
        {
            textDocumentBuilder.append(" ");
            textDocumentBuilder.append(IASKeywordConstants.EXTENDS);
            textDocumentBuilder.append(" ");
            textDocumentBuilder.append(baseClassName);
        }
        String[] interfaceNames = classDefinition.getImplementedInterfacesAsDisplayStrings();
        if (interfaceNames.length > 0)
        {
            textDocumentBuilder.append(" ");
            textDocumentBuilder.append(IASKeywordConstants.IMPLEMENTS);
            textDocumentBuilder.append(" ");
            appendInterfaceNamesToDetail(textDocumentBuilder, interfaceNames);
        }
        textDocumentBuilder.append(NEW_LINE);
        textDocumentBuilder.append(indent);
        textDocumentBuilder.append("{");
        textDocumentBuilder.append(NEW_LINE);
        indent = increaseIndent(indent);
        Collection<IDefinition> definitionSet = classDefinition.getContainedScope().getAllLocalDefinitions();
        for (IDefinition childDefinition : definitionSet)
        {
            if (childDefinition.isOverride() || childDefinition.isPrivate())
            {
                //skip overrides and private
                continue;
            }
            if(childDefinition instanceof IAccessorDefinition)
            {
                IAccessorDefinition functionDefinition = (IAccessorDefinition) childDefinition;
                textDocumentBuilder.append(indent);
                insertFunctionDefinitionIntoTextDocument(functionDefinition, textDocumentBuilder, currentProject, result, definitionToFind);
            }
            else if (childDefinition instanceof IFunctionDefinition)
            {
                IFunctionDefinition functionDefinition = (IFunctionDefinition) childDefinition;
                textDocumentBuilder.append(indent);
                insertFunctionDefinitionIntoTextDocument(functionDefinition, textDocumentBuilder, currentProject, result, definitionToFind);
            }
            else if (childDefinition instanceof IVariableDefinition)
            {
                IVariableDefinition variableDefinition = (IVariableDefinition) childDefinition;
                textDocumentBuilder.append(indent);
                insertVariableDefinitionIntoTextDocument(variableDefinition, textDocumentBuilder, currentProject, result, definitionToFind);
            }
        }
        indent = decreaseIndent(indent);
        textDocumentBuilder.append(indent);
        textDocumentBuilder.append("}");
        textDocumentBuilder.append(NEW_LINE);
        indent = decreaseIndent(indent);
        textDocumentBuilder.append("}");
        result.text = textDocumentBuilder.toString();
        return result;
    }

    private static DefinitionAsText interfaceDefinitionToTextDocument(IInterfaceDefinition interfaceDefinition, ICompilerProject currentProject, IDefinition definitionToFind)
	{
        DefinitionAsText result = new DefinitionAsText();
        result.path = definitionToGeneratedPath(interfaceDefinition);
        String indent = "";
        StringBuilder textDocumentBuilder = new StringBuilder();
        insertHeaderCommentIntoTextDocument(interfaceDefinition, textDocumentBuilder);
        textDocumentBuilder.append(IASKeywordConstants.PACKAGE);
        String packageName = interfaceDefinition.getPackageName();
        if(packageName != null && packageName.length() > 0)
        {
            textDocumentBuilder.append(" ");
            textDocumentBuilder.append(packageName);
        }
        textDocumentBuilder.append(NEW_LINE);
        textDocumentBuilder.append("{");
        textDocumentBuilder.append(NEW_LINE);
        indent = increaseIndent(indent);
        textDocumentBuilder.append(indent);
        if (interfaceDefinition.isPublic())
        {
            textDocumentBuilder.append(IASKeywordConstants.PUBLIC);
            textDocumentBuilder.append(" ");
        }
        else if (interfaceDefinition.isInternal())
        {
            textDocumentBuilder.append(IASKeywordConstants.INTERNAL);
            textDocumentBuilder.append(" ");
        }
        textDocumentBuilder.append(IASKeywordConstants.INTERFACE);
        textDocumentBuilder.append(" ");
        appendDefinitionName(interfaceDefinition, textDocumentBuilder, definitionToFind, result);
        String[] interfaceNames = interfaceDefinition.getExtendedInterfacesAsDisplayStrings();
        if (interfaceNames.length > 0)
        {
            textDocumentBuilder.append(" ");
            textDocumentBuilder.append(IASKeywordConstants.EXTENDS);
            textDocumentBuilder.append(" ");
            appendInterfaceNamesToDetail(textDocumentBuilder, interfaceNames);
        }
        textDocumentBuilder.append(NEW_LINE);
        textDocumentBuilder.append(indent);
        textDocumentBuilder.append("{");
        textDocumentBuilder.append(NEW_LINE);
        indent = increaseIndent(indent);
        Collection<IDefinition> definitionSet = interfaceDefinition.getContainedScope().getAllLocalDefinitions();
        for (IDefinition childDefinition : definitionSet)
        {
            if (childDefinition.isOverride() || childDefinition.isPrivate() || childDefinition.isInternal())
            {
                //skip overrides, private, and internal
                continue;
            }
            if(childDefinition instanceof IAccessorDefinition)
            {
                IAccessorDefinition functionDefinition = (IAccessorDefinition) childDefinition;
                textDocumentBuilder.append(indent);
                insertFunctionDefinitionIntoTextDocument(functionDefinition, textDocumentBuilder, currentProject, result, definitionToFind);
            }
            else if (childDefinition instanceof IFunctionDefinition)
            {
                IFunctionDefinition functionDefinition = (IFunctionDefinition) childDefinition;
                textDocumentBuilder.append(indent);
                insertFunctionDefinitionIntoTextDocument(functionDefinition, textDocumentBuilder, currentProject, result, definitionToFind);
            }
        }
        indent = decreaseIndent(indent);
        textDocumentBuilder.append(indent);
        textDocumentBuilder.append("}");
        textDocumentBuilder.append(NEW_LINE);
        indent = decreaseIndent(indent);
        textDocumentBuilder.append("}");
        result.text = textDocumentBuilder.toString();
        return result;
    }

    private static DefinitionAsText functionDefinitionToTextDocument(IFunctionDefinition functionDefinition, ICompilerProject currentProject, IDefinition definitionToFind)
	{
        DefinitionAsText result = new DefinitionAsText();
        result.path = definitionToGeneratedPath(functionDefinition);
        String indent = "";
        StringBuilder textDocumentBuilder = new StringBuilder();
        insertHeaderCommentIntoTextDocument(functionDefinition, textDocumentBuilder);
        textDocumentBuilder.append(IASKeywordConstants.PACKAGE);
        String packageName = functionDefinition.getPackageName();
        if(packageName != null && packageName.length() > 0)
        {
            textDocumentBuilder.append(" ");
            textDocumentBuilder.append(packageName);
        }
        textDocumentBuilder.append(NEW_LINE);
        textDocumentBuilder.append("{");
        textDocumentBuilder.append(NEW_LINE);
        indent = increaseIndent(indent);
        textDocumentBuilder.append(indent);
        insertFunctionDefinitionIntoTextDocument(functionDefinition, textDocumentBuilder, currentProject, result, definitionToFind);
        indent = decreaseIndent(indent);
        textDocumentBuilder.append("}");
        result.text = textDocumentBuilder.toString();
        return result;
    }

    private static DefinitionAsText variableDefinitionToTextDocument(IVariableDefinition variableDefinition, ICompilerProject currentProject, IDefinition definitionToFind)
	{
        DefinitionAsText result = new DefinitionAsText();
        result.path = definitionToGeneratedPath(variableDefinition);
        String indent = "";
        StringBuilder textDocumentBuilder = new StringBuilder();
        insertHeaderCommentIntoTextDocument(variableDefinition, textDocumentBuilder);
        textDocumentBuilder.append(IASKeywordConstants.PACKAGE);
        String packageName = variableDefinition.getPackageName();
        if(packageName != null && packageName.length() > 0)
        {
            textDocumentBuilder.append(" ");
            textDocumentBuilder.append(packageName);
        }
        textDocumentBuilder.append(NEW_LINE);
        textDocumentBuilder.append("{");
        textDocumentBuilder.append(NEW_LINE);
        indent = increaseIndent(indent);
        textDocumentBuilder.append(indent);
        insertVariableDefinitionIntoTextDocument(variableDefinition, textDocumentBuilder, currentProject, result, definitionToFind);
        indent = decreaseIndent(indent);
        textDocumentBuilder.append("}");
        result.text = textDocumentBuilder.toString();
        return result;
    }

    private static void insertFunctionDefinitionIntoTextDocument(IFunctionDefinition functionDefinition, StringBuilder textDocumentBuilder, ICompilerProject currentProject, DefinitionAsText result, IDefinition definitionToFind)
    {
        if (functionDefinition.isOverride())
        {
            textDocumentBuilder.append(IASKeywordConstants.OVERRIDE);
            textDocumentBuilder.append(" ");
        }
        if (functionDefinition.isPublic() || functionDefinition.isConstructor())
        {
            textDocumentBuilder.append(IASKeywordConstants.PUBLIC);
            textDocumentBuilder.append(" ");
        }
        else if (functionDefinition.isInternal())
        {
            textDocumentBuilder.append(IASKeywordConstants.INTERNAL);
            textDocumentBuilder.append(" ");
        }
        else if (functionDefinition.isPrivate())
        {
            textDocumentBuilder.append(IASKeywordConstants.PRIVATE);
            textDocumentBuilder.append(" ");
        }
        else if (functionDefinition.isProtected())
        {
            textDocumentBuilder.append(IASKeywordConstants.PROTECTED);
            textDocumentBuilder.append(" ");
        }
        else
        {
            INamespaceDefinition ns = functionDefinition.resolveNamespace(currentProject);
            if (ns != null)
            {
                appendNamespace(ns, textDocumentBuilder);
            }
        }
        if (functionDefinition.isStatic())
        {
            textDocumentBuilder.append(IASKeywordConstants.STATIC);
            textDocumentBuilder.append(" ");
        }
        if (functionDefinition.isFinal())
        {
            textDocumentBuilder.append(IASKeywordConstants.FINAL);
            textDocumentBuilder.append(" ");
        }
        if(!(functionDefinition.getParent() instanceof IInterfaceDefinition))
        {
            textDocumentBuilder.append(IASKeywordConstants.NATIVE);
        }
        textDocumentBuilder.append(" ");
        textDocumentBuilder.append(IASKeywordConstants.FUNCTION);
        textDocumentBuilder.append(" ");
        if (functionDefinition instanceof IGetterDefinition)
        {
            textDocumentBuilder.append(IASKeywordConstants.GET);
            textDocumentBuilder.append(" ");
        }
        else if (functionDefinition instanceof ISetterDefinition)
        {
            textDocumentBuilder.append(IASKeywordConstants.SET);
            textDocumentBuilder.append(" ");
        }
        appendDefinitionName(functionDefinition, textDocumentBuilder, definitionToFind, result);
        textDocumentBuilder.append(functionDefinitionToParametersAndReturnValue(functionDefinition, currentProject));
        textDocumentBuilder.append(";");
        textDocumentBuilder.append(NEW_LINE);
    }

    private static void insertVariableDefinitionIntoTextDocument(IVariableDefinition variableDefinition, StringBuilder textDocumentBuilder, ICompilerProject currentProject, DefinitionAsText result, IDefinition definitionToFind)
	{
        if (variableDefinition.isPublic())
        {
            textDocumentBuilder.append(IASKeywordConstants.PUBLIC);
            textDocumentBuilder.append(" ");
        }
        else if (variableDefinition.isInternal())
        {
            textDocumentBuilder.append(IASKeywordConstants.INTERNAL);
            textDocumentBuilder.append(" ");
        }
        else if (variableDefinition.isPrivate())
        {
            textDocumentBuilder.append(IASKeywordConstants.PRIVATE);
            textDocumentBuilder.append(" ");
        }
        else if (variableDefinition.isProtected())
        {
            textDocumentBuilder.append(IASKeywordConstants.PROTECTED);
            textDocumentBuilder.append(" ");
        }
        else
        {
            INamespaceDefinition ns = variableDefinition.resolveNamespace(currentProject);
            if (ns != null)
            {
                appendNamespace(ns, textDocumentBuilder);
            }
        }
        if (variableDefinition.isStatic())
        {
            textDocumentBuilder.append(IASKeywordConstants.STATIC);
            textDocumentBuilder.append(" ");
        }
        if(variableDefinition instanceof IConstantDefinition)
        {
            textDocumentBuilder.append(IASKeywordConstants.CONST);
        }
        else
        {
            textDocumentBuilder.append(IASKeywordConstants.VAR);
        }
        textDocumentBuilder.append(" ");
        appendDefinitionName(variableDefinition, textDocumentBuilder, definitionToFind, result);
        textDocumentBuilder.append(":");
        textDocumentBuilder.append(variableDefinition.getTypeAsDisplayString());
        textDocumentBuilder.append(";");
        textDocumentBuilder.append(NEW_LINE);
    }

    private static void appendInterfaceNamesToDetail(StringBuilder detailBuilder, String[] interfaceNames)
    {
        for (int i = 0, count = interfaceNames.length; i < count; i++)
        {
            if (i > 0)
            {
                detailBuilder.append(", ");
            }
            detailBuilder.append(interfaceNames[i]);
        }
    }

    public static String definitionToDetail(IDefinition definition, ICompilerProject currentProject)
    {
        StringBuilder detailBuilder = new StringBuilder();
        if (definition instanceof IClassDefinition)
        {
            IClassDefinition classDefinition = (IClassDefinition) definition;
            if (classDefinition.isDynamic())
            {
                detailBuilder.append(IASKeywordConstants.DYNAMIC);
                detailBuilder.append(" ");
            }
            detailBuilder.append(IASKeywordConstants.CLASS);
            detailBuilder.append(" ");
            if (classDefinition.getPackageName().startsWith(UNDERSCORE_UNDERSCORE_AS3_PACKAGE))
            {
                //classes like __AS3__.vec.Vector should not include the
                //package name
                detailBuilder.append(classDefinition.getBaseName());
            }
            else
            {
                detailBuilder.append(classDefinition.getQualifiedName());
            }
            String baseClassName = classDefinition.getBaseClassAsDisplayString();
            if (baseClassName != null && !baseClassName.equals(IASLanguageConstants.Object))
            {
                detailBuilder.append(" ");
                detailBuilder.append(IASKeywordConstants.EXTENDS);
                detailBuilder.append(" ");
                detailBuilder.append(baseClassName);
            }
            String[] interfaceNames = classDefinition.getImplementedInterfacesAsDisplayStrings();
            if (interfaceNames.length > 0)
            {
                detailBuilder.append(" ");
                detailBuilder.append(IASKeywordConstants.IMPLEMENTS);
                detailBuilder.append(" ");
                appendInterfaceNamesToDetail(detailBuilder, interfaceNames);
            }
        }
        else if (definition instanceof IInterfaceDefinition)
        {
            IInterfaceDefinition interfaceDefinition = (IInterfaceDefinition) definition;
            detailBuilder.append(IASKeywordConstants.INTERFACE);
            detailBuilder.append(" ");
            detailBuilder.append(interfaceDefinition.getQualifiedName());
            String[] interfaceNames = interfaceDefinition.getExtendedInterfacesAsDisplayStrings();
            if (interfaceNames.length > 0)
            {
                detailBuilder.append(" ");
                detailBuilder.append(IASKeywordConstants.EXTENDS);
                detailBuilder.append(" ");
                DefinitionTextUtils.appendInterfaceNamesToDetail(detailBuilder, interfaceNames);
            }
        }
        else if (definition instanceof IVariableDefinition)
        {
            IVariableDefinition variableDefinition = (IVariableDefinition) definition;
            IDefinition parentDefinition = variableDefinition.getParent();
            if (parentDefinition instanceof ITypeDefinition)
            {
                //an IAccessorDefinition actually extends both
                //IVariableDefinition and IFunctionDefinition 
                if (variableDefinition instanceof IAccessorDefinition)
                {
                    detailBuilder.append("(property) ");
                }
                else if (variableDefinition instanceof IConstantDefinition)
                {
                    detailBuilder.append("(const) ");
                }
                else
                {
                    detailBuilder.append("(variable) ");
                }
                detailBuilder.append(parentDefinition.getQualifiedName());
                detailBuilder.append(".");
            }
            else if (parentDefinition instanceof IFunctionDefinition)
            {
                if (variableDefinition instanceof IParameterDefinition)
                {
                    detailBuilder.append("(parameter) ");
                }
                else
                {
                    detailBuilder.append("(local ");
                    if (variableDefinition instanceof IConstantDefinition)
                    {
                        detailBuilder.append("const) ");
                    }
                    else
                    {
                        detailBuilder.append("var) ");
                    }
                }
            }
            else
            {
                if (variableDefinition instanceof IConstantDefinition)
                {
                    detailBuilder.append(IASKeywordConstants.CONST);
                }
                else
                {
                    detailBuilder.append(IASKeywordConstants.VAR);
                }
                detailBuilder.append(" ");
            }
            detailBuilder.append(variableDefinition.getQualifiedName());
            detailBuilder.append(":");
            detailBuilder.append(variableDefinition.getTypeAsDisplayString());
        }
        else if (definition instanceof IFunctionDefinition)
        {
            IFunctionDefinition functionDefinition = (IFunctionDefinition) definition;
            IDefinition parentDefinition = functionDefinition.getParent();
            if (parentDefinition instanceof ITypeDefinition)
            {
                if (functionDefinition.isConstructor())
                {
                    detailBuilder.append("(constructor) ");
                }
                else
                {
                    detailBuilder.append("(method) ");
                }
                detailBuilder.append(parentDefinition.getBaseName());
                detailBuilder.append(".");
            }
            else if (parentDefinition instanceof IFunctionDefinition)
            {
                detailBuilder.append("(local function) ");
            }
            else
            {
                detailBuilder.append(IASKeywordConstants.FUNCTION);
                detailBuilder.append(" ");
            }
            detailBuilder.append(functionDefinitionToSignature(functionDefinition, currentProject));
        }
        else if (definition instanceof IEventDefinition)
        {
            IEventDefinition eventDefinition = (IEventDefinition) definition;
            detailBuilder.append("(event) ");
            detailBuilder.append("[");
            detailBuilder.append(IMetaAttributeConstants.ATTRIBUTE_EVENT);
            detailBuilder.append("(");
            detailBuilder.append(IMetaAttributeConstants.NAME_EVENT_NAME);
            detailBuilder.append("=");
            detailBuilder.append("\"");
            detailBuilder.append(eventDefinition.getBaseName());
            detailBuilder.append("\"");
            detailBuilder.append(",");
            detailBuilder.append(IMetaAttributeConstants.NAME_EVENT_TYPE);
            detailBuilder.append("=");
            detailBuilder.append("\"");
            detailBuilder.append(eventDefinition.getTypeAsDisplayString());
            detailBuilder.append("\"");
            detailBuilder.append(")");
            detailBuilder.append("]");
        }
        else if (definition instanceof IStyleDefinition)
        {
            IStyleDefinition styleDefinition = (IStyleDefinition) definition;
            detailBuilder.append("(style) ");
            detailBuilder.append("[");
            detailBuilder.append(IMetaAttributeConstants.ATTRIBUTE_STYLE);
            detailBuilder.append("(");
            detailBuilder.append(IMetaAttributeConstants.NAME_STYLE_NAME);
            detailBuilder.append("=");
            detailBuilder.append("\"");
            detailBuilder.append(styleDefinition.getBaseName());
            detailBuilder.append("\"");
            detailBuilder.append(",");
            detailBuilder.append(IMetaAttributeConstants.NAME_STYLE_TYPE);
            detailBuilder.append("=");
            detailBuilder.append("\"");
            detailBuilder.append(styleDefinition.getTypeAsDisplayString());
            detailBuilder.append("\"");
            detailBuilder.append(")");
            detailBuilder.append("]");
        }
        return detailBuilder.toString();
    }

    public static String functionDefinitionToSignature(IFunctionDefinition functionDefinition, ICompilerProject currentProject)
    {
        StringBuilder labelBuilder = new StringBuilder();
        labelBuilder.append(functionDefinition.getBaseName());
        String parametersAndReturnValue = functionDefinitionToParametersAndReturnValue(functionDefinition, currentProject);
        labelBuilder.append(parametersAndReturnValue);
        return labelBuilder.toString();
    }

    private static String functionDefinitionToParametersAndReturnValue(IFunctionDefinition functionDefinition, ICompilerProject currentProject)
    {
        StringBuilder labelBuilder = new StringBuilder();
        labelBuilder.append("(");
        IParameterDefinition[] parameters = functionDefinition.getParameters();
        for (int i = 0, count = parameters.length; i < count; i++)
        {
            if (i > 0)
            {
                labelBuilder.append(", ");
            }
            IParameterDefinition parameterDefinition = parameters[i];
            if (parameterDefinition.isRest())
            {
                labelBuilder.append(IASLanguageConstants.REST);
            }
            String baseName = parameterDefinition.getBaseName();
            if (parameterDefinition.isRest() && (baseName == null || baseName.length() == 0))
            {
                labelBuilder.append(IASLanguageConstants.REST_IDENTIFIER);
            }
            else
            {
                labelBuilder.append(parameterDefinition.getBaseName());
            }
            labelBuilder.append(":");
            labelBuilder.append(parameterDefinition.getTypeAsDisplayString());
            if (parameterDefinition.hasDefaultValue())
            {
                labelBuilder.append(" = ");
                Object defaultValue = parameterDefinition.resolveDefaultValue(currentProject);
                if (defaultValue instanceof String)
                {
                    labelBuilder.append("\"");
                    labelBuilder.append(defaultValue);
                    labelBuilder.append("\"");
                }
                else if (defaultValue != null)
                {
                    if (defaultValue.getClass() == Object.class)
                    {
                        //for some reason, null is some strange random object
                        labelBuilder.append(IASLanguageConstants.NULL);
                    }
                    else
                    {
                        //numeric values and everything else should be okay
                        labelBuilder.append(defaultValue);
                    }
                }
                else
                {
                    //I don't know how this might happen, but this is probably
                    //a safe fallback value
                    labelBuilder.append(IASLanguageConstants.NULL);
                }
            }
        }
        labelBuilder.append(")");
        if (!functionDefinition.isConstructor())
        {
            labelBuilder.append(":");
            labelBuilder.append(functionDefinition.getReturnTypeAsDisplayString());
        }
        return labelBuilder.toString();
    }

    private static void insertHeaderCommentIntoTextDocument(IDefinition definition, StringBuilder builder)
    {
        builder.append("//Generated from: " + definition.getContainingFilePath() + "\n");
    }

    private static void appendDefinitionName(IDefinition definition, StringBuilder textDocumentBuilder, IDefinition definitionToFind, DefinitionAsText result)
    {
        String name = definition.getBaseName();
        if(definition.equals(definitionToFind))
        {
            String[] lines = textDocumentBuilder.toString().split(NEW_LINE);
            result.startLine = lines.length - 1;
            result.startColumn = lines[lines.length - 1].length();
            result.endLine = result.startLine;
            result.endColumn = result.startColumn + name.length();
        }
        textDocumentBuilder.append(name);
    }

    private static void appendNamespace(INamespaceDefinition ns, StringBuilder textDocumentBuilder)
    {
        if (ns.getURI().equals(NAMESPACE_URI_AS3))
        {
            textDocumentBuilder.append("AS3 ");
        }
        else if (ns.getURI().equals(NAMESPACE_MX_INTERNAL))
        {
            textDocumentBuilder.append("mx_internal ");
        }
        else
        {
            //not ideal, but I can't figure out how to find the name
            textDocumentBuilder.append(ns.getURI());
            textDocumentBuilder.append(" ");
        }
    }

    private static String definitionToGeneratedPath(IDefinition definition)
    {
        //we add a fake directory as a prefix here because VSCode won't display
        //the file name if it isn't in a directory
        return PATH_PREFIX_GENERATED + definition.getQualifiedName().replaceAll("\\.", "/") + FILE_EXTENSION_AS;
    }
    
    private static String increaseIndent(String indent)
    {
        return indent + INDENT;
    }
    
    private static String decreaseIndent(String indent)
    {
        if(indent.length() == 0)
        {
            return indent;
        }
        return indent.substring(1);
    }
}