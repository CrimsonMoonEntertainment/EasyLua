//
//  CMLuaManager.h
//
//  Created by David Holtkamp on 8/13/14.
//  Copyright (c) 2014 Crimson Moon Entertainment LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// Lua
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"


@interface EasyLua : NSObject

+ (EasyLua *)sharedEasyLua;

#pragma mark - Load and Run Lua Code
- (bool)runLuaBundleFile:(NSString *)fileName;
- (bool)runLuaFileAtPath:(NSString *)path;
- (bool)runLuaString:(NSString *)string;

#pragma mark - Call Loaded Function
- (id)callLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments;

#pragma mark - Get and Set Global Variables
- (id)getLuaGlobalForKey:(NSString*)key;
- (void)setLuaGlobalValue:(id)value forKey:(NSString*)key;

#pragma mark - Lua Access
- (lua_State *)getLuaState;

@end
