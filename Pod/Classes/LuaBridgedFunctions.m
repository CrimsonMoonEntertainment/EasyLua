//
//  LuaBridgedFunctions.m
//  Pods
//
//  Created by David Holtkamp on 4/1/15.
//
//

#import "LuaBridgedFunctions.h"
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIGeometry.h>

#define CNVBUF(type) type x = *(type*)buffer



#pragma mark - Helper Functions

bool to_lua(lua_State *L, id obj, bool dowrap)
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
    }
    else
    {
        // We need to wrap this value before pushing
        if(dowrap)
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
    }

	return true;
}


id from_lua(lua_State *L, int i)
{
    int t = lua_type(L, i);
    switch (t)
    {
        case LUA_TNIL:
            return [NSNull null];
            break;
        case LUA_TNUMBER:
            return [NSNumber numberWithDouble:lua_tonumber(L, i)];
            break;
        case LUA_TBOOLEAN:
            return [NSNumber numberWithBool:lua_toboolean(L, i)];
            break;
        case LUA_TSTRING:
            return [NSString stringWithCString:lua_tostring(L, i) encoding:NSUTF8StringEncoding];
            break;
        case LUA_TLIGHTUSERDATA:
            return (__bridge id)lua_topointer(L, i);
            break;
        case LUA_TUSERDATA:
        {
            void *p = lua_touserdata(L, i);
            void **ptr = (void **)p;
            return (__bridge id)*ptr;
        }
            break;
        case LUA_TTABLE:
            

            lua_pushvalue(L, i);
            lua_pushnil(L);
            
            bool is_dictionary = false;
            while (lua_next(L, -2))
            {
                if(lua_type(L, -2) != LUA_TNUMBER)
                {
                    is_dictionary = true;
                    lua_pop(L, 2);
                    break;
                }
                else
                {
                    lua_pop(L, 1);
                }
            }
            
            if (is_dictionary == true)
            {
                NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                lua_pushnil(L);
                
                while (lua_next(L, -2))
                {
                    id key = from_lua(L, -2);
                    id val = from_lua(L, -1);
                    lua_pop(L, 1);
                    
                    if (key == nil)
                    {
                        continue;
                    }
                    if (val == nil)
                    {
                        val = [NSNull null];
                    }
                    
                    dict[key] = val;
                }
                lua_pop(L, 1);
                return dict;
            }
            else
            {
                // must be an array
                NSMutableArray* array = [NSMutableArray array];
                lua_pushnil(L);
                
                while (lua_next(L, -2))
                {
                    int current_index = lua_tonumber(L, -2) - 1;
                    id val = from_lua(L, -1);
                    lua_pop(L, 1);
                    
                    if (val == nil)
                    {
                        val = [NSNull null];
                    }
                    
                    array[current_index] = val;
                }
                lua_pop(L, 1);
                return array;
            }
            
            
            
        case LUA_TFUNCTION:
        case LUA_TTHREAD:
        case LUA_TNONE:
        default:
           return nil;
        
        break;
    }
}

#pragma mark - Lua Registerd Functions


int luafunc_getclass(lua_State *L)
{
    const char *classname = lua_tostring(L, -1);
    id cls = objc_getClass(classname);
    lua_pushlightuserdata(L, (__bridge void *)(cls));
    return 1;
}


int luafunc_call(lua_State *L)
{
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    
    lua_pushnil(L);
    while(lua_next(L, -2))
    {
        int index = lua_tonumber(L, -2) - 1;
        id object = from_lua(L, -1);
        if(object == nil)
        {
            object = [NSNull null];
        }
        stack[index] = object;
        lua_pop(L, 1);
    }
    lua_pop(L, 1);
    
    
    NSString *message = (NSString *)[stack lastObject];
    [stack removeLastObject];
    id target = [stack lastObject];
    [stack removeLastObject];
    
    SEL sel = sel_getUid([message cStringUsingEncoding:NSUTF8StringEncoding]);
    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
    [inv retainArguments];
    NSUInteger numarg = [sig numberOfArguments];
    //    NSLog(@"Number of arguments = %d", numarg);
    
    for (int i = 2; i < numarg; i++)
    {
        const char *t = [sig getArgumentTypeAtIndex:i];
        //        NSLog(@"arg %d: %s", i, t);
        id arg = [stack lastObject];
        [stack removeLastObject];
        
        switch (t[0])
        {
            case 'c': // A char
            {
                char x = [(NSNumber *)arg charValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'i': // An int
            {
                int x = [(NSNumber *)arg intValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 's': // A short
            {
                short x = [(NSNumber *)arg shortValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'l': // A long l is treated as a 32-bit quantity on 64-bit programs.
            {
                long x = [(NSNumber *)arg longValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'q': // A long long
            {
                long long x = [(NSNumber *)arg longLongValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'C': // An unsigned char
            {
                unsigned char x = [(NSNumber *)arg unsignedCharValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'I': // An unsigned int
            {
                unsigned int x = [(NSNumber *)arg unsignedIntValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'S': // An unsigned short
            {
                unsigned short x = [(NSNumber *)arg unsignedShortValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'L': // An unsigned long
            {
                unsigned long x = [(NSNumber *)arg unsignedLongValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'Q': // An unsigned long long
            {
                unsigned long long x = [(NSNumber *)arg unsignedLongLongValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'f': // A float
            {
                float x = [(NSNumber *)arg floatValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'd': // A double
            {
                double x = [(NSNumber *)arg doubleValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case 'B': // A C++ bool or a C99 _Bool
            {
                bool x = [(NSNumber *)arg boolValue];
                [inv setArgument:&x atIndex:i];
            }
                break;
                
            case '*': // A character string (char *)
            {
                const char *x = [(NSString *)arg cStringUsingEncoding:NSUTF8StringEncoding];
                [inv setArgument:&x atIndex:i];
            }
                break;
            case '@': // An object (whether statically typed or typed id)
                [inv setArgument:&arg atIndex:i];
                break;
                
            case '^': // pointer
                if ([arg isKindOfClass:[NSValue class]])
                {
                    void *ptr = [(NSValue *)arg pointerValue];
                    [inv setArgument:&ptr atIndex:i];
                }
                else
                {
                    //[inv setArgument:&arg atIndex:i];
                    [NSError errorWithDomain:@"Passing wild pointer" code:1 userInfo:nil];
                }
                break;
                
            case '{': // {name=type...} A structure
            {
                NSString *t_str = [NSString stringWithUTF8String:t];
                if ([t_str hasPrefix:@"{CGRect"])
                {
                    CGRect rect = [(NSValue *)arg CGRectValue];
                    [inv setArgument:&rect atIndex:i];
                }
                else if ([t_str hasPrefix:@"{CGSize"])
                {
                    CGSize size = [(NSValue *)arg CGSizeValue];
                    [inv setArgument:&size atIndex:i];
                }
                else if ([t_str hasPrefix:@"{CGPoint"])
                {
                    CGPoint point = [(NSValue *)arg CGPointValue];
                    [inv setArgument:&point atIndex:i];
                }
                else if ([t_str hasPrefix:@"{CGAffineTransform"])
                {
                    CGAffineTransform tran = [(NSValue *)arg CGAffineTransformValue];
                    [inv setArgument:&tran atIndex:i];
                }
            }
                break;
                
            case 'v': // A void
            case '#': // A class object (Class)
            case ':': // A method selector (SEL)
            default:
                NSLog(@"%s: Not implemented", t);
                break;
        }
    }
    
    [inv setTarget:target];
    [inv setSelector:sel];
    [inv invoke];
    
    const char *rettype = [sig methodReturnType];
    //    NSLog(@"[%@ %@] ret type = %s", target, message, rettype);
    void *buffer = NULL;
    if (rettype[0] != 'v')
    { // don't get return value from void function
        NSUInteger len = [[inv methodSignature] methodReturnLength];
        buffer = malloc(len);
        [inv getReturnValue:buffer];
        //        NSLog(@"ret = %c", *(unichar*)buffer);
    }
    
    
    switch (rettype[0])
    {
        case 'c': // A char
        {
            CNVBUF(char);
            [stack addObject:[NSNumber numberWithChar:x]];
        }
            break;
        case 'i': // An int
        {
            CNVBUF(int);
            [stack addObject:[NSNumber numberWithInt:x]];
        }
            break;
        case 's': // A short
        {
            CNVBUF(short);
            [stack addObject:[NSNumber numberWithShort:x]];
        }
            break;
        case 'l': // A long l is treated as a 32-bit quantity on 64-bit programs.
        {
            CNVBUF(long);
            [stack addObject:[NSNumber numberWithLong:x]];
        }
            break;
        case 'q': // A long long
        {
            CNVBUF(long long);
            [stack addObject:[NSNumber numberWithLong:x]];
        }
            break;
        case 'C': // An unsigned char
        {
            CNVBUF(unsigned char);
            [stack addObject:[NSNumber numberWithUnsignedChar:x]];
        }
            break;
        case 'I': // An unsigned int
        {
            CNVBUF(unsigned int);
            [stack addObject:[NSNumber numberWithUnsignedInt:x]];
        }
            break;
        case 'S': // An unsigned short
        {
            CNVBUF(unsigned short);
            [stack addObject:[NSNumber numberWithUnsignedShort:x]];
        }
            break;
        case 'L': // An unsigned long
        {
            CNVBUF(unsigned long);
            [stack addObject:[NSNumber numberWithUnsignedLong:x]];
        }
            break;
        case 'Q': // An unsigned long long
        {
            CNVBUF(unsigned long long);
            [stack addObject:[NSNumber numberWithUnsignedLongLong:x]];
        }
            break;
        case 'f': // A float
        {
            CNVBUF(float);
            [stack addObject:[NSNumber numberWithFloat:x]];
        }
            break;
        case 'd': // A double
        {
            CNVBUF(double);
            [stack addObject:[NSNumber numberWithDouble:x]];
        }
            break;
        case 'B': // A C++ bool or a C99 _Bool
        {
            CNVBUF(bool);
            [stack addObject:[NSNumber numberWithBool:x]];
        }
            break;
            
        case '*': // A character string (char *)
        {
            NSString *x = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
            [stack addObject:x];
        }
            break;
        case '@': // An object (whether statically typed or typed id)
        {
            id x = (__bridge id)*((void **)buffer);
            //            NSLog(@"stack %@", stack);
            if (x)
            {
                //                NSLog(@"x %@", x);
                [stack addObject:x];
            }
            else
            {
                [stack addObject:[NSNull null]];
            }
        }
            break;
            
        case '^':
        {
            void *x = *(void **)buffer;
            //            [stack addObject:[PointerObject pointerWithVoidPtr:x]];
            [stack addObject:[NSValue valueWithPointer:x]];
        }
            break;
        case 'v': // A void
            [stack addObject:[NSNull null]];
            break;
            
        case '{': // {name=type...} A structure
        {
            NSString *t = [NSString stringWithUTF8String:rettype];
            
            if ([t hasPrefix:@"{CGRect"])
            {
                CGRect *rect = (CGRect *)buffer;
                [stack addObject:[NSValue valueWithCGRect:*rect]];
            }
            else if ([t hasPrefix:@"{CGSize"])
            {
                CGSize *size = (CGSize *)buffer;
                [stack addObject:[NSValue valueWithCGSize:*size]];
            }
            else if ([t hasPrefix:@"{CGPoint"])
            {
                CGPoint *size = (CGPoint *)buffer;
                [stack addObject:[NSValue valueWithCGPoint:*size]];
            }
            else if ([t hasPrefix:@"{CGAffineTransform"])
            {
                CGAffineTransform *tran = (CGAffineTransform *)buffer;
                [stack addObject:[NSValue valueWithCGAffineTransform:*tran]];
            }
        }
            break;
            
        case '#': // A class object (Class)
        case ':': // A method selector (SEL)
        default:
            NSLog(@"%s: Not implemented", rettype);
            [stack addObject:[NSNull null]];
            break;
    }
    
    free(buffer);
    
    id obj = [stack lastObject];
    to_lua(L, obj, false);
    
    return 1;
}




