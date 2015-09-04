//
//  CMBase.m
//  Pods
//
//  Created by David Holtkamp on 6/24/15.
//
//  Needed for Union Support
//

#import "CMBase.h"
#import <objc/runtime.h>


@implementation CMBase

#pragma mark - KVC Handlers
-(void)setValue:(nullable id)value forUndefinedKey:(nonnull NSString *)key
{
    Ivar v = class_getInstanceVariable( [ self class ], [ [ NSString stringWithFormat:@"_%@", key ] UTF8String ] ) ;
    if ( v )
    {
        char const * const encoding = ivar_getTypeEncoding( v ) ;
        if ( encoding[0] == '(' ) // unions only
        {
            size_t size = 0 ;
            NSGetSizeAndAlignment( encoding, &size, NULL ) ;
            
            uintptr_t ptr = (uintptr_t)self + ivar_getOffset( v ) ;
            [ (NSValue*)value getValue:(void*)ptr ] ;
            
            return ;
        }
    }
    
    objc_property_t prop = class_getProperty( [ self class ], [ key UTF8String ] ) ;
    if ( prop )
    {
        char const * const encoding = property_copyAttributeValue( prop, "T" ) ;
        if ( encoding[0] == '(' )   // unions only
        {
            objc_setAssociatedObject( self, NSSelectorFromString( key ), value, OBJC_ASSOCIATION_COPY ) ;
            return ;
        }
    }
    
    [ super setValue:value forUndefinedKey:key ] ;
}


-(nullable id)valueForUndefinedKey:(nonnull NSString *)key
{
    Ivar v = class_getInstanceVariable( [ self class ], [ [ NSString stringWithFormat:@"_%@", key ] UTF8String ] ) ;
    if ( v )
    {
        char const * const encoding = ivar_getTypeEncoding( v ) ;
        if ( encoding[0] == '(' )
        {
            NSUInteger size = 0 ;
            NSGetSizeAndAlignment( encoding, &size, NULL ) ;
            
            uintptr_t ptr = (uintptr_t)self + ivar_getOffset( v ) ;
            NSValue * result = [ NSValue valueWithBytes:(void*)ptr objCType:encoding ] ;
            return result ;
        }
    }
    
    objc_property_t prop = class_getProperty( [ self class ], [ key UTF8String ] ) ;
    if ( prop )
    {
        return objc_getAssociatedObject( self, NSSelectorFromString( key ) ) ;
    }
    
    return nil;
}


#pragma mark - Property Iteration



/*
- (id)valueForKeyPath:(NSMutableArray*)path
{
    id current_object = self;
    id current_parent = self;
    int count = 0;
    for (int i = 0; i < count; i++)
    {
        // Property (or the already corrected path)
        NSString* current_key = path[i];
        id return_value = [current_object valueForKey:current_key];
        if(return_value != nil)
        {
            current_parent = current_object;
            current_object = return_value;
            continue;
        }
        
        // property
        NSString *first_char = [[current_key substringToIndex: 1] lowercaseString];
        current_key = [first_char stringByAppendingString:[current_key substringFromIndex:1]];
        return_value = [current_object valueForKey:current_key];
        if(return_value != nil)
        {
            current_parent = current_object;
            current_object = return_value;
            path[i] = current_key;
            continue;
        }
        
        // _property
        current_key = [@"_" stringByAppendingString:current_key];
        return_value = [current_object valueForKey:current_key];
        if(return_value != nil)
        {
            current_parent = current_object;
            current_object = return_value;
            path[i] = current_key;
            continue;
        }
        
        CMAlertMessage(@"Animation failed to find specified property");
        return false;
        break;
    }

    return current_object;
}
*/


@end
