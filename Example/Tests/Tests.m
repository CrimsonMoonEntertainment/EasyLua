//
//  EasyLuaTests.m
//  EasyLuaTests
//
//  Created by David Holtkamp on 03/30/2015.
//  Copyright (c) 2014 David Holtkamp. All rights reserved.
//

#import "EasyLua.h"
#import "ObjCTest.h"

SpecBegin(EasyLua)


describe(@"EasyLua Tests", ^{
    
    beforeAll(^
    {
        EasyLua* instance = [EasyLua sharedEasyLua];
        expect(instance).notTo.equal(nil);
        [instance runLuaBundleFile:@"LuaTest"];
    });
    
    
    it(@"can run string", ^{
        [ObjCTest setLastTestState:false];
        [[EasyLua sharedEasyLua] runLuaString:@"SetTestValue(true)"];
        expect([ObjCTest getLastTestState]).equal(true);
        [[EasyLua sharedEasyLua] runLuaString:@"SetTestValue(false)"];
        expect([ObjCTest getLastTestState]).equal(false);
    });
    
    it(@"lua can pass multiple values", ^{
        [ObjCTest setLastTestState:false];
        [[EasyLua sharedEasyLua] runLuaString:@"TestMultiValueCalls()"];
        expect([ObjCTest getLastTestState]).equal(true);
    });
    
    it(@"lua can get and set globals", ^{
        [ObjCTest setLastTestState:false];
        
        [[EasyLua sharedEasyLua] setLuaGlobalValue:@"Global String" forKey:@"new_global"];
        [[EasyLua sharedEasyLua] runLuaString:@"TestGlobals()"];
        expect([ObjCTest getLastTestState]).equal(true);
        NSString* val = [[EasyLua sharedEasyLua] getLuaGlobalForKey:@"lua_new_global"];
        expect([val isEqualToString:@"lua_global_string"]).equal(true);
    });
    
    
    it(@"can handle strings", ^{
        [ObjCTest setLastTestState:false];
        [[EasyLua sharedEasyLua] runLuaString:@"TestStrings()"];
        expect([ObjCTest getLastTestState]).equal(true);
    });
    
    it(@"can handle bools", ^{
        [ObjCTest setLastTestState:false];
        [[EasyLua sharedEasyLua] runLuaString:@"TestGettingBool()"];
        expect([ObjCTest getLastTestState]).equal(true);
    });
    
    it(@"can interpret bool types", ^{
        [ObjCTest setLastTestState:false];
        [[EasyLua sharedEasyLua] runLuaString:@"TestBoolTypes()"];
        expect([ObjCTest getLastTestState]).equal(true);
    });
    
    it(@"can pass, return, and call Obj-C objects", ^{
        [ObjCTest setLastTestState:false];
        ObjCTest *my_instance = [[ObjCTest alloc] init];

        id instance = [[EasyLua sharedEasyLua] callLuaFunction:@"TestObjects" withArguments:@[my_instance]];
        expect([ObjCTest getLastTestState]).equal(true);
        [ObjCTest setLastTestState:false];
        [((ObjCTest *)instance) instanceSetLastTestState:true];
        expect([ObjCTest getLastTestState]).equal(true);
    });
    it(@"can handle NSDicitonary", ^{
        [ObjCTest setLastTestState:false];
        NSDictionary* data_in = @{@"TestKey":@"TestValue"};
        NSDictionary* data = [[EasyLua sharedEasyLua] callLuaFunction:@"TestNSDictionay" withArguments:@[data_in]];
        expect([ObjCTest getLastTestState]).equal(true);

        expect([data[@"ReturnKey"] isEqualToString:@"ReturnValue"]).equal(true);
    });
    
    it(@"We can call into Lua", ^{

        id v_val = [[EasyLua sharedEasyLua] callLuaFunction:@"TestVoidFunction" withArguments:@[@"TestString", @124.2, [NSNumber numberWithBool:true]]];
        id b_val = [[EasyLua sharedEasyLua] callLuaFunction:@"TestBoolFunction" withArguments:@[@"TestString", @124.2, [NSNumber numberWithBool:true]]];
        id d_val = [[EasyLua sharedEasyLua] callLuaFunction:@"TestNumberFunction" withArguments:@[@"TestString", @124.2, [NSNumber numberWithBool:true]]];
        id s_val = [[EasyLua sharedEasyLua] callLuaFunction:@"TestStringFunction" withArguments:@[@"TestString", @124.2, [NSNumber numberWithBool:true]]];
        
        expect(v_val).equal(nil);
        expect([d_val doubleValue]).to.equal(124.2);
        expect([b_val boolValue]).to.equal(true);
        expect([s_val isEqualToString:@"TestString"]).equal(true);
    });
    
});

SpecEnd
