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



@end
