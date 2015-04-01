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


@interface EasyLua : NSObject
{
	lua_State *L;
}

- (bool)runLuaBundleFile:(NSString *)fileName;
- (bool)runLuaFileAtPath:(NSString *)path;
- (bool)runLuaString:(NSString *)string;

+ (EasyLua *)sharedEasyLua;

@end
