//
//  SecurityBookmark.h
//  SecurityScopeBookmark
//
//  Created by Santanu Karar on 06/04/16.
//  Copyright © 2016 Santanu Karar. All rights reserved.
//

#ifndef SecurityBookmark_SecurityBookmark_h
#define SecurityBookmark_SecurityBookmark_h

#define EXPORT __attribute__((visibility("default")))

#include <Adobe AIR/Adobe AIR.h>
#include <Foundation/Foundation.h>

FREObject getHelloWorld(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject addNewPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject restoreAccessedPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject closeAccessedPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject closeAllPaths(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);

void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions);
void contextFinalizer(FREContext ctx);
bool checkIfURLExists(NSURL *url);
NSObject* getURLByData(NSData *value);


EXPORT
void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);

EXPORT
void finalizer(void* extData);

#endif