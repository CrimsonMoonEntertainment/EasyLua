//
//  LuaBridgedFunctions.m
//  Pods
//
//  Created by David Holtkamp on 4/1/15.
//
//

#import "LuaBridgedFunctions.h"
#import "LuaObjectReference.h"
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIGeometry.h>
#import "LuaBridge.h"

static int gc_metatable_ref;




void luabridge_push_object(lua_State *L, id obj, bool dounwrap)
{
    if (obj == nil)
    {
        lua_pushnil(L);
    }
    else if ([obj isKindOfClass:[NSString class]])
    {
        lua_pushstring(L, [obj cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    else if ([obj isKindOfClass:[NSNumber class]])
    {
        if(strcmp([obj objCType], [@"c" UTF8String]) == 0)
        {
            lua_pushboolean(L, [obj intValue]);
        }
        else
        {
            lua_pushnumber(L, [obj doubleValue]);
        }
    }
    else if ([obj isKindOfClass:[NSNull class]])
    {
        lua_pushnil(L);
        //    } else if ([obj isKindOfClass:[PointerObject class]]) {
        //        lua_pushlightuserdata(L, [(PointerObject*)obj ptr]);
    }
    else if ([obj isKindOfClass:[LuaObjectReference class]])
    {
        int ref = ((LuaObjectReference *)obj).ref;
        lua_rawgeti(L, LUA_REGISTRYINDEX, ref);
    }
    else
    {
        // We need to wrap this value before pushing
        if(dounwrap)
        {
            lua_getglobal(L, "wrap");
            lua_pushlightuserdata(L, (__bridge void*)obj);
            if(lua_pcall(L, 1, 1, 0) != LUA_OK)
            {
                NSLog(@"Error running specified lua function wrap");
            }
            
            // We don't pop the data! We simply leave it there for the function to read as its param
        }
        
        else
        {
            lua_pushlightuserdata(L, (__bridge void*)obj);
        }
        
        
        
        //void *ud = lua_newuserdata(L, sizeof(void *));
        //void **udptr = (void **)ud;
        //*udptr = (__bridge_retained void *)(obj);
        // lua_rawgeti(L, LUA_REGISTRYINDEX, gc_metatable_ref);
        // lua_setmetatable(L, -2);
    }
}

int luafunc_newstack(lua_State *L)
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    
    lua_pushlightuserdata(L, (__bridge_retained void *)(arr));
    
    return 1;
}

int luafunc_getclass(lua_State *L)
{
    const char *classname = lua_tostring(L, -1);
    id cls = objc_getClass(classname);
    lua_pushlightuserdata(L, (__bridge void *)(cls));
    return 1;
}

int luafunc_push(lua_State *L)
{
    int top = lua_gettop(L);
    
    NSMutableArray *arr = (__bridge NSMutableArray *)lua_topointer(L, 1);
    //    NSLog(@"arr %@", arr);
    for (int i = 2; i <= top; i++)
    {
        int t = lua_type(L, i);
        switch (t)
        {
            case LUA_TNIL:
                [arr addObject:[NSNull null]];
                break;
            case LUA_TNUMBER:
                [arr addObject:[NSNumber numberWithDouble:lua_tonumber(L, i)]];
                break;
            case LUA_TBOOLEAN:
                [arr addObject:[NSNumber numberWithBool:lua_toboolean(L, i)]];
                break;
            case LUA_TSTRING:
                [arr addObject:[NSString stringWithCString:lua_tostring(L, i) encoding:NSUTF8StringEncoding]];
                break;
            case LUA_TLIGHTUSERDATA:
                [arr addObject:(__bridge id)lua_topointer(L, i)];
                break;
            case LUA_TUSERDATA:
            {
                void *p = lua_touserdata(L, i);
                void **ptr = (void **)p;
                [arr addObject:(__bridge id)*ptr];
            }
                break;
            case LUA_TTABLE:
            case LUA_TFUNCTION:
            case LUA_TTHREAD:
            {
                LuaObjectReference *ref = [LuaObjectReference new];
                ref.ref = luaL_ref(L, LUA_REGISTRYINDEX);
                ref.L = L;
                [arr addObject:ref];
            }
                break;
            case LUA_TNONE:
            default:
            {
                NSString *errmsg = [NSString stringWithFormat:@"Value type not supported. type = %d", t];
                lua_pushstring(L, [errmsg UTF8String]);
                lua_error(L);
            }
                break;
        }
    }
    
    return 0;
}

int luafunc_operate(lua_State *L)
{
    NSMutableArray *arr = (__bridge NSMutableArray *)lua_topointer(L, 1);
    NSString *opname = [NSString stringWithCString:lua_tostring(L, 2) encoding:NSUTF8StringEncoding];
    
    [[LuaBridge instance] operate:opname onStack:arr];
    return 0;
}

int luafunc_pop(lua_State *L)
{
    NSMutableArray *arr = (__bridge NSMutableArray *)lua_topointer(L, 1);
    id obj = [arr lastObject];
    [arr removeLastObject];
    
    luabridge_push_object(L, obj, false);
    
    return 1;
}

int luafunc_clear(lua_State *L)
{
    NSMutableArray *arr = (__bridge NSMutableArray *)lua_topointer(L, 1);
    [arr removeAllObjects];
    
    return 0;
}

int luafunc_hoge(lua_State *L)
{
    NSString *str = @"Hoge Fuga";
    SEL sel = sel_getUid("characterAtIndex:");
    NSMethodSignature *sig = [str methodSignatureForSelector:sel];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    NSUInteger numarg = [sig numberOfArguments];
    NSLog(@"Number of arguments = %lu", (unsigned long)numarg);
    
    for (int i = 0; i < numarg; i++)
    {
        const char *t = [sig getArgumentTypeAtIndex:i];
        NSLog(@"arg %d: %s", i, t);
    }
    
    [inv setTarget:str];
    [inv setSelector:sel];
    NSUInteger arg1 = 5;
    [inv setArgument:&arg1 atIndex:2];
    [inv invoke];
    
    NSUInteger len = [[inv methodSignature] methodReturnLength];
    const char *rettype = [sig methodReturnType];
    NSLog(@"ret type = %s", rettype);
    void *buffer = malloc(len);
    [inv getReturnValue:buffer];
    NSLog(@"ret = %c", *(unichar *)buffer);
    
    lua_pushinteger(L, *(unichar *)buffer);
    
    return 1;
}

int luafunc_extract(lua_State *L)
{
    NSMutableArray *arr = (__bridge NSMutableArray *)lua_topointer(L, 1);
    NSString *type = [NSString stringWithUTF8String:lua_tostring(L, 2)];
    NSValue *val = [arr lastObject];
    [arr removeLastObject];
    
    int retnum = 0;
    
    if ([type compare:@"CGSize"] == NSOrderedSame)
    {
        CGSize size = [val CGSizeValue];
        lua_pushnumber(L, size.width);
        lua_pushnumber(L, size.height);
        retnum = 2;
    }
    else if ([type compare:@"CGPoint"] == NSOrderedSame)
    {
        CGPoint p = [val CGPointValue];
        lua_pushnumber(L, p.x);
        lua_pushnumber(L, p.y);
        retnum = 2;
    }
    else if ([type compare:@"CGRect"] == NSOrderedSame)
    {
        CGRect r = [val CGRectValue];
        lua_pushnumber(L, r.origin.x);
        lua_pushnumber(L, r.origin.y);
        lua_pushnumber(L, r.size.width);
        lua_pushnumber(L, r.size.height);
        retnum = 4;
    }
    else if ([type compare:@"CGAffineTransform"] == NSOrderedSame)
    {
        CGAffineTransform t = [val CGAffineTransformValue];
        lua_pushnumber(L, t.a);
        lua_pushnumber(L, t.b);
        lua_pushnumber(L, t.c);
        lua_pushnumber(L, t.d);
        lua_pushnumber(L, t.tx);
        lua_pushnumber(L, t.ty);
        retnum = 6;
    }
    
    return retnum;
}



