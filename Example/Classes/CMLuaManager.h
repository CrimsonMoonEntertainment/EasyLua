//
//  CMLuaManager.h
//  CrimsonWars
//
//  Created by David Holtkamp on 8/13/14.
//  Copyright (c) 2014 Crimson Moon Entertainment LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// Lua
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#include "LuaBridge.h"

@interface CMLuaManager : NSObject
{
    lua_State *L;
}

// -(void)resetState;   // We need to add support for this in the LuaBridge
-(bool)runLuaBundleFile:(NSString*)fileName;
-(bool)runFileAtPath:(NSString*)path;
-(bool)runLuaString:(NSString*)string;
-(lua_State*)getCurrentState;

+(CMLuaManager*)sharedCMLuaManager;
@end
