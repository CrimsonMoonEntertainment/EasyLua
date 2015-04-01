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
- (void)callVoidReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments;           // 0 Return Values
- (double)callNumberReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments;
- (bool)callBoolReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments;           // Returns 1 Bool
- (NSString *)callStringReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments;   // Returns 1 String
//- (id)callObjectReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments;           // Returns 1 NSObject


@end
