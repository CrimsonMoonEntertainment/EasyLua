//
//  ObjC-Test.m
//  EasyLua
//
//  Created by David Holtkamp on 3/31/15.
//  Copyright (c) 2015 David Holtkamp. All rights reserved.
//

#import "ObjCTest.h"

static bool LastTestState = false;

@implementation ObjCTest

+ (bool)getLastTestState
{
    return LastTestState;
}

+ (void)setLastTestState:(bool)testState
{
    LastTestState = testState;
}

- (void)instanceSetLastTestState:(bool)testState
{
    LastTestState = testState;
}

+ (bool)returnBoolValue:(bool)valueIn
{
    return valueIn;
}

+ (NSNumber *)returnBoolValueAsNSNumber:(bool)valueIn
{
    return [NSNumber numberWithBool:valueIn];
}


+ (NSString *)returnStringValue:(NSString *)stringIn
{
    return stringIn;
}

+ (bool)returnTrue:(NSString*)junk_string
{
    return true;
}

+ (bool)returnFalse:(NSString*)junk_string
{
    return false;
}

+ (void)printMyString:(NSString*)stringIn
{
    NSLog(@"My String: %@", stringIn);
}

-(id)init
{
    if(self = [super init])
    {
        self.Vector4 = GLKVector4Make(1.0, 2.0, 3.0, 4.0);
        self.Vector3 = GLKVector3Make(5.0, 6.0, 7.0);
    }
    
    return self;
}

- (NSNumber*)memberMethodWithNumber:(NSNumber*)number
{
    int val = [number intValue];
    NSLog(@"Number is: %i", val);
    return @(val);
}

- (int)memberMethodWithInt:(int)number
{
    NSLog(@"Number is: %i", number);
    return number;
}

- (ObjCTest*)memberMethodWithPointer:(ObjCTest*)testPointer
{
    [testPointer memberMethodWithInt:43];
    return testPointer;
}

+ (int)multiValueTest:(int)value1In value2:(int)value2In
{
    return value1In * 2 + value2In;
}

@end
