//
//  LuaObjectReference.h
//  Pods
//
//  Created by David Holtkamp on 4/1/15.
//
//

#import <Foundation/Foundation.h>
#import "lauxlib.h"

@interface LuaObjectReference : NSObject

@property int ref;
@property lua_State *L;

@end