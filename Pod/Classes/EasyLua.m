//
//  CMLuaManager.m
//  CrimsonWars
//
//  Created by David Holtkamp on 8/13/14.
//  Copyright (c) 2014 Crimson Moon Entertainment LLC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "CMSynthesizeSingleton.h"
#import "EasyLua.h"
#import "CMSynthesizeSingleton.h"

@implementation EasyLua

SYNTHESIZE_SINGLETON_FOR_CLASS(EasyLua)

#pragma mark - NSObject

-(id)init
{
    if(self = [super init])
    {
        [self resetState];
    }
    
    return self;
}

#pragma mark - Public

-(void)resetState
{
/*  This no longer happens
    if(L != NULL)
    {
        lua_close(L);
    }  
*/
    L = [[LuaBridge instance] L];
    luaL_openlibs(L); // load all the basic libraries into the interpreter
    lua_settop(L, 0);
    [self addBundlePathToLuaState];
    [self runLuaBundleFile:@"objc-init"];
}


-(bool)runLuaBundleFile:(NSString*)fileName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"lua"];
    return [self runFileAtPath:path];
}

-(bool)runFileAtPath:(NSString*)path
{
    if (luaL_dofile(L, [path UTF8String]))
    {
        const char *err = lua_tostring(L, -1);
        NSLog(@"error while loading file %@: %s",path,  err);
        return false;
    }
    
    return true;
}

-(bool)runLuaString:(NSString*)string
{
    if (luaL_loadstring(L, [string UTF8String]))
    {
        const char *err = lua_tostring(L, -1);
        NSLog(@"error while loading string %@: %s",string, err);
        return false;
    }

    if (lua_pcall(L, 0, 0, 0)) {
        const char *err = lua_tostring(L, -1);
        NSLog(@"error while running string %@: %s",string, err);
        return false;
    }
    
    return true;
}


-(lua_State*)getCurrentState
{
    return L;
}

#pragma mark - Private

-(void)addBundlePathToLuaState
{
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "path"); // get field "path" from table at top of stack (-1)
    
    const char* current_path_const = lua_tostring(L, -1); // grab path string from top of stack
    NSString* current_path = [NSString stringWithFormat:@"%s;%@/?.lua", current_path_const, [[NSBundle mainBundle]resourcePath]];
    
    lua_pop(L, 1); // get rid of the string on the stack we just pushed on line 5
    lua_pushstring(L, [current_path UTF8String]); // push the new one
    lua_setfield(L, -2, "path"); // set the field "path" in table at -2 with value at top of stack
    lua_pop(L, 1); // get rid of package table from top of stack
}




@end
