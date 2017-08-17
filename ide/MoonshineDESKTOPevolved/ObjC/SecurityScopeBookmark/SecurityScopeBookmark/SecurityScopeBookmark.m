//
//  SecurityScopeBookmark.m
//  SecurityScopeBookmark
//
//  Created by Santanu Karar on 06/04/16.
//  Copyright © 2016 Santanu Karar. All rights reserved.
//

#import "SecurityScopeBookmark.h"
#import <AppKit/AppKit.h>

#include <Adobe AIR/Adobe AIR.h>
#include <Foundation/Foundation.h>


uint32_t isSupportedInOS = 1;
NSMutableArray *bookmarkedURLs;

FREObject restoreAccessedPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    bookmarkedURLs = [[NSUserDefaults standardUserDefaults] valueForKey:@"SavedBookmark"];
    
    FREObject result;
    for (int i = 0; i < bookmarkedURLs.count; i++)
    {
        NSObject *anyObject = getURLByData([bookmarkedURLs objectAtIndex:i]);
        if ([anyObject isKindOfClass:[NSURL class]])
        {
            // valid NSURL
            [(NSURL *)anyObject startAccessingSecurityScopedResource];
        }
        else
        {
            // something went wrong
            const char *str = [(NSString *)anyObject UTF8String];
            FRENewObjectFromUTF8((uint32_t)strlen(str)+1, (const uint8_t *)str, &result);
            NSLog(@"Error retreiving bookmark: %@", (NSString *)anyObject);
        }
    }
    
    const char *str2 = "I retrieved it!";
    FRENewObjectFromUTF8((uint32_t)strlen(str2)+1, (const uint8_t *)str2, &result);
    return result;
}

FREObject closeAccessedPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    uint32_t urlLength;
    const uint8_t *pathvalue;
    FREGetObjectAsUTF8(argv[0], &urlLength, &pathvalue);
    NSString *pathValue = [NSString stringWithUTF8String:(char*)pathvalue];
    
    for (int i = 0; i < bookmarkedURLs.count; i++)
    {
        NSObject *anyObject = getURLByData([bookmarkedURLs objectAtIndex:i]);
        if ([anyObject isKindOfClass:[NSURL class]])
        {
            // valid NSURL
            NSLog(@"Path value in ObjC is: %@", [(NSURL *)anyObject path]);
            if ([(NSURL *)anyObject path] == pathValue)
            {
                [(NSURL *)anyObject stopAccessingSecurityScopedResource];
                
            }
        }
    }
    
    return NULL;
}

FREObject closeAllPaths(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    FREObject result;
    for (int i = 0; i < bookmarkedURLs.count; i++)
    {
        NSObject *anyObject = getURLByData([bookmarkedURLs objectAtIndex:i]);
        if ([anyObject isKindOfClass:[NSURL class]])
        {
            // valid NSURL
            [(NSURL *)anyObject stopAccessingSecurityScopedResource];
        }
        else
        {
            // something went wrong
            const char *str = [(NSString *)anyObject UTF8String];
            FRENewObjectFromUTF8((uint32_t)strlen(str)+1, (const uint8_t *)str, &result);
            NSLog(@"Error retreiving bookmark: %@", (NSString *)anyObject);
        }
    }
    
    const char *str2 = "I Closed it!";
    FRENewObjectFromUTF8((uint32_t)strlen(str2)+1, (const uint8_t *)str2, &result);
    return result;
}

FREObject addNewPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    uint32_t urlLength;
    const uint8_t *pathValue;
    FREGetObjectAsUTF8(argv[0], &urlLength, &pathValue);
    FREObject result;
    
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories:YES];
    
    NSInteger resultInt = [openDlg runModal];
    
    if (resultInt == NSFileHandlingPanelCancelButton)
    {
        return NULL;
    }
    
    NSArray *urls = [openDlg URLs];
    
    if (urls != nil && [urls count] == 1)
    {
        NSURL *url = [urls objectAtIndex:0];
        
        // do not add if already exists
        if (checkIfURLExists(url))
        {
            return NULL;
        }
        
        NSData *bookmark = nil;
        NSError *error = nil;
        bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                 includingResourceValuesForKeys:nil
                                  relativeToURL:nil // Make it app-scoped
                                          error:&error];
        if (error)
        {
            const char *str = [error.description UTF8String];
            FRENewObjectFromUTF8((uint32_t)strlen(str)+1, (const uint8_t *)str, &result);
            NSLog(@"Error creating bookmark for URL (%@): %@", url, error.description);
        }
        else
        {
            [bookmarkedURLs addObject:bookmark];
            [[NSUserDefaults standardUserDefaults] setObject:bookmarkedURLs forKey:@"SavedBookmark"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            const char *str2 = [url.path UTF8String];
            FRENewObjectFromUTF8((uint32_t)strlen(str2)+1, (const uint8_t *)str2, &result);
        }
    }
    
    return result;
}

FREObject getHelloWorld(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    FREObject result;

    const char *str = "Hello World!!  This is your DLL talking!";
    FRENewObjectFromUTF8((uint32_t)strlen(str)+1, (const uint8_t *)str, &result);
    return result;
}

FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    FREObject result;
    FRENewObjectFromBool( isSupportedInOS, &result);
    return result;
}

bool checkIfURLExists(NSURL *url)
{
    for (int i = 0; i < bookmarkedURLs.count; i++)
    {
        NSObject *anyObject = getURLByData([bookmarkedURLs objectAtIndex:i]);
        if ([anyObject isKindOfClass:[NSURL class]])
        {
            // valid NSURL
            if ([(NSURL *)anyObject path] == url.path)
            {
                return TRUE;
            }
        }
    }
    
    return FALSE;
}

NSObject* getURLByData(NSData *value)
{
    NSError *error = nil;
    BOOL bookmarkDataIsStale;
    NSURL *bookmarkFileURL = [NSURL
                       URLByResolvingBookmarkData:value
                       options:NSURLBookmarkResolutionWithSecurityScope
                       relativeToURL:nil
                       bookmarkDataIsStale:&bookmarkDataIsStale
                       error:&error];
    if (error)
    {
        return error.description;
    }
    
    return bookmarkFileURL;
}

void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctions, const FRENamedFunction** functions)
{
    *numFunctions = 6;
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctions));
    
    func[0].name = (const uint8_t*) "isSupported";
    func[0].functionData = NULL;
    func[0].function = &isSupported;
    
    func[1].name = (const uint8_t*) "getHelloWorld";
    func[1].functionData = NULL;
    func[1].function = &getHelloWorld;
    
    func[2].name = (const uint8_t*) "addNewPath";
    func[2].functionData = NULL;
    func[2].function = &addNewPath;
    
    func[3].name = (const uint8_t*) "restoreAccessedPath";
    func[3].functionData = NULL;
    func[3].function = &restoreAccessedPath;
    
    func[4].name = (const uint8_t*) "closeAccessedPath";
    func[4].functionData = NULL;
    func[4].function = &closeAccessedPath;
    
    func[5].name = (const uint8_t*) "closeAllPaths";
    func[5].functionData = NULL;
    func[5].function = &closeAllPaths;
    
    *functions = func;
}

void contextFinalizer(FREContext ctx)
{
    return;
}

void initializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
{
    *ctxInitializer = &contextInitializer;
    *ctxFinalizer = &contextFinalizer;
}

void finalizer(void* extData)
{
    return;
}
