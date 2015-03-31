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
        EasyLua* get_instance = [EasyLua sharedEasyLua];
        expect(get_instance).notTo.equal(nil);
    });
    
    
    it(@"can run string", ^{
        expect(1).beLessThan(23);
    });
    
    it(@"can read", ^{
        expect(@"team").toNot.contain(@"I");
    });
    
});

SpecEnd
