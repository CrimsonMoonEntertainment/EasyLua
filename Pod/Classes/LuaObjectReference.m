//
//  LuaObjectReference.m
//  Pods
//
//  Created by David Holtkamp on 4/1/15.
//
//

#import "LuaObjectReference.h"

@implementation LuaObjectReference

@synthesize ref, L;

- (void)dealloc
{
    luaL_unref(self.L, LUA_REGISTRYINDEX, self.ref);
}
@end