//
//  ObjC-Test.h
//  EasyLua
//
//  Created by David Holtkamp on 3/31/15.
//  Copyright (c) 2015 David Holtkamp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjCTest : NSObject

+ (bool)getLastTestState;
+ (void)setLastTestState:(bool)testState;
- (void)instanceSetLastTestState:(bool)testState;

@end
