//
//  EasyLuaTests.m
//  EasyLuaTests
//
//  Created by David Holtkamp on 03/30/2015.
//  Copyright (c) 2014 David Holtkamp. All rights reserved.
//

#import "EasyLua.h"

SpecBegin(EasyLua)


describe(@"EasyLua Tests", ^{
    
    beforeAll(^
    {
        EasyLua* instance = [EasyLua sharedEasyLua];
        expect(instance).notTo.equal(nil);
       
        [instance runLuaBundleFile:@"LuaTest"];
    });
    
    
    it(@"can run string", ^{
        
    });
    
    it(@"We can call into Lua", ^{
        
        [[EasyLua sharedEasyLua] callVoidReturningLuaFunction:@"TestVoidFunction" withArguments:@[@"TestString", @124.2, [NSNumber numberWithBool:true]]];
        bool b_val = [[EasyLua sharedEasyLua] callBoolReturningLuaFunction:@"TestBoolFunction" withArguments:@[@"TestString", @124.2, [NSNumber numberWithBool:true]]];
        double d_val = [[EasyLua sharedEasyLua] callNumberReturningLuaFunction:@"TestNumberFunction" withArguments:@[@"TestString", @124.2, [NSNumber numberWithBool:true]]];
        NSString* s_val = [[EasyLua sharedEasyLua] callStringReturningLuaFunction:@"TestStringFunction" withArguments:@[@"TestString", @124.2, [NSNumber numberWithBool:true]]];
        
        expect(d_val).to.equal(124.2);
        expect(b_val).to.equal(true);
        expect([s_val isEqualToString:@"TestString"]).equal(true);
        
        expect(@"team").toNot.contain(@"I");
    });
    
});

SpecEnd
