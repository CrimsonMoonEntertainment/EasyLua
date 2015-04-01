//
//  CMLuaManager.m
//  CrimsonWars
//
//  Created by David Holtkamp on 8/13/14.
//  Copyright (c) 2014 Crimson Moon Entertainment LLC. All rights reserved.
//
#import "CMSynthesizeSingleton.h"
#import "EasyLua.h"

@implementation EasyLua
{
    lua_State *L;
    LuaBridge *Bridge;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(EasyLua)

#pragma mark - NSObject

- (id)init
{
	if (self = [super init])
	{
		[self resetState];
	}

	return self;
}

#pragma mark - Run Lua Code


- (bool)runLuaBundleFile:(NSString *)fileName
{
	fileName = [fileName stringByReplacingOccurrencesOfString:@".lua" withString:@""];
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:fileName ofType:@"lua"];
	return [self runLuaFileAtPath:path];
}

- (bool)runLuaFileAtPath:(NSString *)path
{
	if (luaL_dofile(L, [path UTF8String]))
	{
		const char *err = lua_tostring(L, -1);
		NSLog(@"error while loading file %@: %s", path, err);
		return false;
	}

	return true;
}

- (bool)runLuaString:(NSString *)string
{
	if (luaL_loadstring(L, [string UTF8String]))
	{
		const char *err = lua_tostring(L, -1);
		NSLog(@"error while loading string %@: %s", string, err);
		return false;
	}

	if (lua_pcall(L, 0, 0, 0))
	{
		const char *err = lua_tostring(L, -1);
		NSLog(@"error while running string %@: %s", string, err);
		return false;
	}

	return true;
}


#pragma mark - Call Loaded Function
- (void)callVoidReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments
{
    lua_getglobal(L, [functionName UTF8String]);
    for(id item in arguments)
    {
        [self pushValueToLua:item];
    }
    
    if(lua_pcall(L, (int)[arguments count], 0, 0) != LUA_OK)
    {
        NSLog(@"Error running specified lua function %@", functionName);
    }
}


- (double)callNumberReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments
{
    lua_getglobal(L, [functionName UTF8String]);
    for(id item in arguments)
    {
        [self pushValueToLua:item];
    }
    
    if(lua_pcall(L, (int)[arguments count], 1, 0) != LUA_OK)
    {
        NSLog(@"Error running specified lua function %@", functionName);
    }
    int is_num;
    double ret_value = lua_tonumberx(L, -1, &is_num);
    
    if(is_num == false)
    {
        NSLog(@"Function %@ called was not returning a number", functionName);
    }
    
    lua_pop(L, 1);
    return ret_value;
    
}

- (bool)callBoolReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments
{
    lua_getglobal(L, [functionName UTF8String]);
    for(id item in arguments)
    {
        [self pushValueToLua:item];
    }
    
    if(lua_pcall(L, (int)[arguments count], 1, 0) != LUA_OK)
    {
        NSLog(@"Error running specified lua function %@", functionName);
    }

    bool ret_value = lua_toboolean(L, -1);
    lua_pop(L, 1);
    return ret_value;
}

- (NSString *)callStringReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments
{
    lua_getglobal(L, [functionName UTF8String]);
    for(id item in arguments)
    {
        [self pushValueToLua:item];
    }
    
    if(lua_pcall(L, (int)[arguments count], 1, 0) != LUA_OK)
    {
        NSLog(@"Error running specified lua function %@", functionName);
    }
    
    NSString* string = [NSString stringWithUTF8String:lua_tostring(L, -1)];
    lua_pop(L, 1);
    return string;
}

//- (id)callObjectReturningLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments


#pragma mark - Private

- (void)pushValueToLua:(id)value
{
    if([value isKindOfClass:[NSString class]])
    {
        lua_pushstring(L, [value UTF8String]);
    }
    else if([value isKindOfClass:[NSNumber class]])
    {
        if(strcmp([value objCType], [@"c" UTF8String]) == 0)
        {
            lua_pushboolean(L, [value intValue]);
        }
        else
        {
            lua_pushnumber(L, [value doubleValue]);
        }
    }
    else
    {
        NSLog(@"Put an unsupported type in the argment array for a lua function call");
    }
}


- (void)resetState
{
    Bridge = [LuaBridge instance];
	L = [Bridge getLuaState];
}


@end
