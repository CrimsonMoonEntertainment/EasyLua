//
//  ObjC-Test.h
//  EasyLua
//
//  Created by David Holtkamp on 3/31/15.
//  Copyright (c) 2015 David Holtkamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "CMBase.h"

@interface ObjCTest : CMBase

@property GLKVector3 Vector3;
@property GLKVector4 Vector4;

+ (bool)getLastTestState;
+ (void)setLastTestState:(bool)testState;
- (void)instanceSetLastTestState:(bool)testState;

@end
