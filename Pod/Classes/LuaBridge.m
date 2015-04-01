//
//  LuaState.m
//  Lua-Objective-C Bridge
//
//  Created by Toru Hisai on 12/04/13.
//  Copyright (c) 2012年 Kronecker's Delta Studio. All rights reserved.
//

#import <objc/runtime.h>

#import "LuaBridge.h"
#import "lualib.h"
#import "lauxlib.h"
#import "LuaObjectReference.h"
#import "LuaBridgedFunctions.h"


#define ADDMETHOD(name) \
(lua_pushstring(L, #name), \
lua_pushcfunction(L, luafunc_ ## name), \
lua_settable(L, -3))

#define CNVBUF(type) type x = *(type*)buffer

static int gc_metatable_ref;


#pragma mark - Bridged C Functions






@implementation LuaBridge
{
    lua_State *L;
}

#pragma mark - Initalization

- (id)init
{
	self = [super init];
	if (self)
	{
		L = luaL_newstate();
		luaL_openlibs(L);
		lua_newtable(L);

		ADDMETHOD(hoge);
		ADDMETHOD(newstack);
		ADDMETHOD(push);
		ADDMETHOD(pop);
		ADDMETHOD(clear);
		ADDMETHOD(operate);
		ADDMETHOD(getclass);
		ADDMETHOD(extract);

		lua_setglobal(L, "objc");

		NSBundle *bundle = [NSBundle bundleForClass:[self class]];
		NSString *path = [bundle pathForResource:@"LuaBridge" ofType:@"lua"];
		if (luaL_dofile(L, [path UTF8String]))
		{
			const char *err = lua_tostring(L, -1);
			NSLog(@"error while loading utils: %s", err);
		}
	}
	return self;
}

+ (LuaBridge *)instance
{
	static LuaBridge *stat = nil;
	if (!stat)
	{
		stat = [[LuaBridge alloc] init];

		lua_State *L = [stat getLuaState];

		lua_newtable(L);
		gc_metatable_ref = luaL_ref(L, LUA_REGISTRYINDEX);
        luaL_openlibs(L); // load all the basic libraries into the interpreter
        lua_settop(L, 0);
	}
	return stat;
}

- (lua_State*) getLuaState
{
    return L;
}



#pragma mark - Operations (Lua to Method Calls)
// This method gets called via the C function operate, not directly
- (void)operate:(NSString *)opname onStack:(NSMutableArray *)stack
{
	orig_exception_handler = NSGetUncaughtExceptionHandler();
	exception_handler_stack = stack;
	exception_handler_opname = opname;

	NSSetUncaughtExceptionHandler(lua_exception_handler);

	NSString *method = [NSString stringWithFormat:@"op_%@:", opname];

	SEL sel = sel_getUid([method cStringUsingEncoding:NSUTF8StringEncoding]);
	[self performSelector:sel withObject:stack];

	NSSetUncaughtExceptionHandler(orig_exception_handler);
	
    orig_exception_handler = NULL;
	exception_handler_stack = NULL;
	exception_handler_opname = NULL;
}

- (void)op_call:(NSMutableArray *)stack
{
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
				int x = [(NSNumber *)arg boolValue];
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
#undef CNVBUF

	free(buffer);
}


- (void)op_cgrectmake:(NSMutableArray *)stack
{
	double x = [[stack lastObject] doubleValue];
    [stack removeLastObject];
	double y = [[stack lastObject] doubleValue];
    [stack removeLastObject];
	double w = [[stack lastObject] doubleValue];
    [stack removeLastObject];
	double h = [[stack lastObject] doubleValue];
    [stack removeLastObject];

	CGRect rect = CGRectMake(x, y, w, h);
	[stack addObject:[NSValue valueWithCGRect:rect]];
}

#pragma mark - Exception Handling
static NSUncaughtExceptionHandler *orig_exception_handler = NULL;
static NSString *exception_handler_opname = NULL;
static NSMutableArray *exception_handler_stack = NULL;

static void lua_exception_handler(NSException *exception)
{
    NSLog(@"Lua exception: opname = %@: stack = %@", exception_handler_opname, exception_handler_stack);
    if (orig_exception_handler)
    {
        orig_exception_handler(exception);
    }
}


@end







