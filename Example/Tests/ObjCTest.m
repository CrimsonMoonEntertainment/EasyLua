//
//  ObjC-Test.m
//  EasyLua
//
//  Created by David Holtkamp on 3/31/15.
//  Copyright (c) 2015 David Holtkamp. All rights reserved.
//

#import "ObjCTest.h"

@implementation ObjCTest

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


@end
