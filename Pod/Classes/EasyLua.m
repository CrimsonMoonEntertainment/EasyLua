//
//  CMLuaManager.m
//  CrimsonWars
//
//  Created by David Holtkamp on 8/13/14.
//  Copyright (c) 2014 Crimson Moon Entertainment LLC. All rights reserved.
//
#import "CMSynthesizeSingleton.h"
#import "LuaBridgedFunctions.h"
#import "EasyLua.h"

#define ADDMETHOD(name) \
(lua_pushstring(L, #name), \
lua_pushcfunction(L, luafunc_ ## name), \
lua_settable(L, -3))


@implementation EasyLua
{
    lua_State *L;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(EasyLua)

#pragma mark - NSObject

- (id)init
{
	if (self = [super init])
	{
        L = luaL_newstate();
        luaL_openlibs(L);
        lua_newtable(L);
        
        ADDMETHOD(call);
        ADDMETHOD(getclass);
        
        lua_setglobal(L, "objc");
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        NSString *path = [bundle pathForResource:@"LuaBridge" ofType:@"lua"];
        if (luaL_dofile(L, [path UTF8String]))
        {
            const char *err = lua_tostring(L, -1);
            NSLog(@"error while loading utils: %s", err);
        }
        
        lua_settop(L, 0);
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
- (id)callLuaFunction:(NSString *)functionName withArguments:(NSArray *)arguments
{
    lua_getglobal(L, "unwrap"); // We are unwrapping right after this next funciton, so I'm placing it here
                                // so it will be in the right place in the stack
    lua_getglobal(L, [functionName UTF8String]);
    
    if(lua_type(L, -1) != LUA_TFUNCTION)
    {
        NSLog(@"Attempted to call non-existing lua function %@", functionName);
        lua_pop(L, 2);
        return nil;
    }
    
    
    for(id item in arguments)
    {
	    to_lua(L, item, true);
    }
    
    if(lua_pcall(L, (int)[arguments count], LUA_MULTRET, 0) != LUA_OK)
    {
	    NSLog(@"Error running specified lua function %@", functionName);
    }

	int top = lua_gettop(L);

    if(top == 2)
    {
        if(lua_pcall(L, 1, 1, 0) != LUA_OK) // Call unwrap on what we had above
        {
            NSLog(@"Error unwarpping return value");
        }
        id object = from_lua(L, 1);
        lua_pop(L, 1);
        return object;
    }
    else
    {
        lua_pop(L, 1); // pop unused unwrap
        return nil;
    }
}

#pragma mark - Get and Set Global Variables
- (id)getLuaGlobalForKey:(NSString*)key
{
    lua_getglobal(L, [key UTF8String]);
    id value = from_lua(L, -1);
    lua_pop(L, 1);
    return value;
}


- (void)setLuaGlobalValue:(id)value forKey:(NSString*)key
{
    if(to_lua(L, value, true) == true)
    {
        lua_setglobal(L, [key UTF8String]);
    }
}


#pragma mark - Lua Access
- (lua_State *)getLuaState
{
    return L;
}





@end
