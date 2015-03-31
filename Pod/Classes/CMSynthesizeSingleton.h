//
//  SingletonGCD.h
// From Github From 2010 WWDC video

#import <Foundation/Foundation.h>

#ifndef SYNTHESIZE_SINGLETON_FOR_CLASS
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname)                        \
\
__strong static classname * shared##classname = nil;    \
+ (classname *)shared##classname {                      \
\
static dispatch_once_t pred;                            \
dispatch_once( &pred, ^{                                \
shared##classname = [[self alloc] init]; });            \
return shared##classname;                               \
}
#endif
