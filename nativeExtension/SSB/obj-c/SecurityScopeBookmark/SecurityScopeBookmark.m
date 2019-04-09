//
//  SecurityScopeBookmark.m
//  SecurityScopeBookmark
//
//  Created by Santanu Karar on 06/04/16.
//  Copyright © 2016 Santanu Karar. All rights reserved.
//

#import "SecurityScopeBookmark.h"
#import <AppKit/AppKit.h>

#include "Adobe AIR.framework/Versions/1.0/Headers/Adobe AIR.h"
#include <Foundation/Foundation.h>


uint32_t isSupportedInOS = 1;
NSMutableArray *bookmarkedURLs;

FREObject restoreAccessedPaths(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    bookmarkedURLs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MoonshineBookmarks"] mutableCopy];
    FREObject result = NULL;
    
    if (bookmarkedURLs != NULL)
    {
        NSString *openedPaths = @"";
        for (int i = 0; i < bookmarkedURLs.count; i++)
        {
            NSObject *anyObject = getURLByData([bookmarkedURLs objectAtIndex:i]);
            if ([anyObject isKindOfClass:[NSURL class]])
            {
                // valid NSURL
                [(NSURL *)anyObject startAccessingSecurityScopedResource];
                openedPaths = [openedPaths stringByAppendingString:@","];
                openedPaths = [openedPaths stringByAppendingString:[(NSURL *)anyObject path]];
            }
            else
            {
                // probablity - the resource has been deleted
                [bookmarkedURLs removeObjectAtIndex:i];
                i--;
            }
        }
        
        result = getMessageByObject(openedPaths);
    }
    else
    {
        bookmarkedURLs = [[NSMutableArray alloc] init];
        //[[NSUserDefaults standardUserDefaults] setObject:bookmarkedURLs forKey:@"MoonshineBookmarks"];
        result = getMessageByObject(@"INITIALIZED");
    }
    
    return result;
}

FREObject disposeKeys(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    FREObject result = NULL;
    bookmarkedURLs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MoonshineBookmarks"] mutableCopy];
    
    if (bookmarkedURLs != NULL)
    {
        NSString *closedPaths = @"";
        for (int i = 0; i < bookmarkedURLs.count; i++)
        {
            NSObject *anyObject = getURLByData([bookmarkedURLs objectAtIndex:i]);
            if ([anyObject isKindOfClass:[NSURL class]])
            {
                // valid NSURL
                [(NSURL *)anyObject stopAccessingSecurityScopedResource];
                
                closedPaths = [closedPaths stringByAppendingString:[(NSURL *)anyObject path]];
                result = getMessageByObject(closedPaths);
            }
            
            [bookmarkedURLs removeObjectAtIndex:i];
            i--;
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:bookmarkedURLs forKey:@"MoonshineBookmarks"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MoonshineBookmarks"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
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
            if ([[(NSURL *)anyObject path] isEqualToString:pathValue])
            {
                [(NSURL *)anyObject stopAccessingSecurityScopedResource];
                [bookmarkedURLs removeObjectAtIndex:i];
                
                [[NSUserDefaults standardUserDefaults] setObject:[bookmarkedURLs copy] forKey:@"MoonshineBookmarks"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                return getMessageByObject(@"Path deleted!");
                break;
            }
        }
    }
    
    return NULL;
}

FREObject closeAllPaths(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    //FREObject result = NULL;
    //NSString *closeResult = @"";
    for (int i = 0; i < bookmarkedURLs.count; i++)
    {
        NSObject *anyObject = getURLByData([bookmarkedURLs objectAtIndex:i]);
        if ([anyObject isKindOfClass:[NSURL class]])
        {
            // valid NSURL
            [(NSURL *)anyObject stopAccessingSecurityScopedResource];
            //closeResult = [closeResult stringByAppendingString:[(NSURL *)anyObject path]];
            //result = getMessageByObject(closeResult);
        }
        /*else
        {
            // something went wrong
            result = getMessageByObject((NSString *)anyObject);
        }*/
    }
    
    return getMessageByObject(@"Closed Scoped Paths.");
}

FREObject addNewPath(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    FREObject result;
    
    uint32_t urlLength;
    const uint8_t *pathvalue;
    const uint8_t *isdirectory;
    const uint8_t *filetypes;
    FREGetObjectAsUTF8(argv[0], &urlLength, &pathvalue);
    FREGetObjectAsUTF8(argv[1], &urlLength, &isdirectory);
    FREGetObjectAsUTF8(argv[2], &urlLength, &filetypes);
    NSString *pathValue = [NSString stringWithUTF8String:(char*)pathvalue];
    NSString *isDirectory = [NSString stringWithUTF8String:(char*)isdirectory];
    NSString *fileTypes = [NSString stringWithUTF8String:(char*)filetypes];
    
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles: ([isDirectory isEqualToString:@"true"]) ? NO : YES];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setCanChooseDirectories: ([isDirectory isEqualToString:@"true"]) ? YES : NO];
    [openDlg showsHiddenFiles];
    
    if (!openDlg.canChooseDirectories && ![fileTypes isEqualToString:@""])
    {
        NSMutableArray *fileRestrictionTypes = [[NSMutableArray alloc] init];
        NSArray *splitsTypes = [fileTypes componentsSeparatedByString:@","];
        for (NSString *object in splitsTypes)
        {
            [fileRestrictionTypes addObject:object];
        }
        fileRestrictionTypes = [fileRestrictionTypes copy];
        [openDlg setAllowedFileTypes:fileRestrictionTypes];
    }
    
    if (![pathValue isEqualToString:@""])
    {
        [openDlg setDirectoryURL:[NSURL URLWithString:pathValue]];
    }
    
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
            return getMessageByObject([url path]);
        }
        
        NSData *bookmark = nil;
        NSError *error = nil;
        bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationWithSecurityScope
                 includingResourceValuesForKeys:nil
                                  relativeToURL:nil // Make it app-scoped
                                          error:&error];
        if (error)
        {
            result = getMessageByObject(error.description);
            NSLog(@"Error creating bookmark for URL (%@): %@", url, error.description);
        }
        else
        {
            [bookmarkedURLs addObject:bookmark];
            [[NSUserDefaults standardUserDefaults] setObject:bookmarkedURLs forKey:@"MoonshineBookmarks"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            result = getMessageByObject([url path]);
        }
    }
    
    return result;
}

FREObject confirmHandshaking(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    //NSURL *documentsPath = [NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0]];
    return getMessageByObject(@"Handshaking confirmed");
}

FREObject isSupported(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    return Nil;
}

FREObject getHomeDirectory(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[])
{
    return getMessageByObject(NSHomeDirectory());
}

BOOL checkIfURLExists(NSURL *url)
{
    for (int i = 0; i < bookmarkedURLs.count; i++)
    {
        NSObject *anyObject = getURLByData([bookmarkedURLs objectAtIndex:i]);
        if ([anyObject isKindOfClass:[NSURL class]])
        {
            // valid NSURL
            if ([[(NSURL *)anyObject path] compare:[url path]] == NSOrderedSame)
            {
                return TRUE;
            }
        }
    }
    
    return FALSE;
}

FREObject getMessageByObject(NSString *value)
{
    FREObject result;
    
    const char *str = [value UTF8String];
    FRENewObjectFromUTF8((uint32_t)strlen(str)+1, (const uint8_t *)str, &result);
    
    return result;
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
    *numFunctions = 8;
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctions));
    
    func[0].name = (const uint8_t*) "isSupported";
    func[0].functionData = NULL;
    func[0].function = &isSupported;
    
    func[1].name = (const uint8_t*) "confirmHandshaking";
    func[1].functionData = NULL;
    func[1].function = &confirmHandshaking;
    
    func[2].name = (const uint8_t*) "addNewPath";
    func[2].functionData = NULL;
    func[2].function = &addNewPath;
    
    func[3].name = (const uint8_t*) "restoreAccessedPaths";
    func[3].functionData = NULL;
    func[3].function = &restoreAccessedPaths;
    
    func[4].name = (const uint8_t*) "closeAccessedPath";
    func[4].functionData = NULL;
    func[4].function = &closeAccessedPath;
    
    func[5].name = (const uint8_t*) "closeAllPaths";
    func[5].functionData = NULL;
    func[5].function = &closeAllPaths;
    
    func[6].name = (const uint8_t*) "disposeKeys";
    func[6].functionData = NULL;
    func[6].function = &disposeKeys;
    
    func[7].name = (const uint8_t*) "getHomeDirectory";
    func[7].functionData = NULL;
    func[7].function = &getHomeDirectory;
    
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
