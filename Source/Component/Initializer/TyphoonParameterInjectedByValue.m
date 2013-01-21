////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 - 2013 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import <objc/runtime.h>
#import "TyphoonParameterInjectedByValue.h"
#import "TyphoonInitializer.h"
#import "TyphoonTypeDescriptor.h"
#import "TyphoonIntrospectionUtils.h"


@implementation TyphoonParameterInjectedByValue

/* ============================================================ Initializers ============================================================ */
- (id)initWithIndex:(NSUInteger)index value:(NSString*)value classOrProtocol:(id)classOrProtocol
{
    self = [super init];
    if (self)
    {
        _index = index;
        _value = value;
        _classOrProtocol = classOrProtocol;
    }
    return self;
}

/* ========================================================== Interface Methods ========================================================= */
- (TyphoonTypeDescriptor*)resolveTypeWith:(id)classOrInstance
{
    if (_classOrProtocol)
    {
        [NSException raise:NSInvalidArgumentException format:@"Can't resolve type descriptor - classOrProtocol is already explicitly set"];
    }
    BOOL isClass = class_isMetaClass(object_getClass(classOrInstance));
    Class clazz;
    if (isClass)
    {
        clazz = classOrInstance;
    }
    else
    {
        clazz = [classOrInstance class];
    }
    NSArray* typeCodes = [TyphoonIntrospectionUtils typeCodesForSelector:_initializer.selector ofClass:clazz isClassMethod:isClass];

    if ([[typeCodes objectAtIndex:_index] isEqualToString:@"@"])
    {
        [NSException raise:NSInvalidArgumentException
                    format:@"Unless the type is primitive (int, BOOL, etc), initializer injection requires the required class to be specified. Eg: <argument parameterName=\"string\" value=\"http://dev.foobar.com/service/\" required-class=\"NSString\" />"];
    }
    return [TyphoonTypeDescriptor descriptorWithTypeCode:[typeCodes objectAtIndex:_index]];

}


/* =========================================================== Protocol Methods ========================================================= */
- (TyphoonParameterInjectionType)type
{
    return TyphoonParameterInjectedByValueType;
}

- (void)setInitializer:(TyphoonInitializer*)initializer
{
    _initializer = initializer;
}

/* ============================================================ Utility Methods ========================================================= */
- (NSString*)description
{
    NSMutableString* description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"self.index=%lu", self.index];
    [description appendFormat:@", self.value=%@", self.value];
    [description appendFormat:@", self.classOrProtocol=%@", self.classOrProtocol];
    [description appendString:@">"];
    return description;
}


@end