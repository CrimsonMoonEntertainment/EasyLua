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
#include "LuaBridge.h"


@interface EasyLua : NSObject

+ (EasyLua *)sharedEasyLua;

#pragma mark - Load and Run Lua Code
- (bool)runLuaBundleFile:(NSString *)fileName;
- (bool)runLuaFileAtPath:(NSString *)path;
- (bool)runLuaString:(NSString *)string;

#pragma mark - Call Loaded Function
- (void)callLuaFunctionReturningVoid:(NSString *)functionName withArguments:(NSArray *)arguments;
- (double)callLuaFunctionReturningNumber:(NSString *)functionName withArguments:(NSArray *)arguments;
- (NSString *)callLuaFunctionReturningString:(NSString *)functionName withArguments:(NSArray *)arguments;
- (bool)callLuaFunctionReturningBool:(NSString *)functionName withArguments:(NSArray *)arguments;
- (id)callLuaFunctionReturningObject:(NSString *)functionName withArguments:(NSArray *)arguments;

#pragma mark - Lua Access
- (lua_State *)getLuaState;

@end
