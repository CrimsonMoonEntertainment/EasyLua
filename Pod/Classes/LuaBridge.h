//
//  LuaBridge.h
//  Lua-Objective-C Bridge
//
//  Created by Toru Hisai on 12/04/13.
//  Copyright (c) 2012年 Kronecker's Delta Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

#import "lua.h"

#ifdef __cplusplus
}
#endif


@interface LuaBridge : NSObject

#pragma mark - Initialization
+ (LuaBridge *)instance;

#pragma mark - Fetching State
- (lua_State*)getLuaState;

#pragma mark - Operation Stack (Lua Method Calling)
- (void)operate:(NSString *)opname onStack:(NSMutableArray *)stack;
- (void)op_call:(NSMutableArray *)stack;
- (void)op_cgrectmake:(NSMutableArray *)stack;

@end


