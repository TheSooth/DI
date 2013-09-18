//
//  CRDIClassInspector.m
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIClassInspector.h"
#import <MAObjCRuntime/MARTNSObject.h>
#import <MAObjCRuntime/RTProperty.h>
#import "CRDIDefaultPropertyNameMatcher.h"

@interface CRDIClassInspector ()

@property (nonatomic, strong) id<CRDIPropertyNameMatcher> propertyNameMatcher;

@end

@implementation CRDIClassInspector

- (id)initWithPropertyMatcher:(id<CRDIPropertyNameMatcher>)aMatcher
{
    NSParameterAssert(aMatcher);
    self = [super init];
    if (self) {
        self.propertyNameMatcher = aMatcher;
    }
    return self;
}

- (id)init
{
    return [self initWithPropertyMatcher:[CRDIDefaultPropertyNameMatcher new]];
}

- (DIClassTemplate*)inspect:(Class)instanceClass
{
    NSArray *properties = [self parsePropertiesFromClass:instanceClass];
    DIClassTemplate *template = nil;
    
    if (properties.count > 0) {
        template = [DIClassTemplate new];
        template.templateClass = instanceClass;
        
        template.properties = properties;
    }
    
    return template;
}

- (NSArray*)parsePropertiesFromClass:(Class)instanceClass
{
    NSMutableArray *array = [NSMutableArray new];
    
    NSArray *properties = [instanceClass rt_properties];
    
    while (instanceClass) {
        for (RTProperty *p in properties) {
            if ([self.propertyNameMatcher shouldInject:p.name]) {
                DIPropertyModel *m = [self modelForProperty:p];
                [array addObject:m];
            }
        }
        
        instanceClass = [instanceClass superclass];
        properties = [instanceClass rt_properties];
    }
    
    return array;
}

- (DIPropertyModel *)modelForProperty:(RTProperty *)property
{
    DIPropertyModel *m = [DIPropertyModel new];
    
    m.protocol = [self extractProtocolFromPropertyEncoding:property.typeEncoding];
    m.name = property.name;
    
    return m;
}

- (Protocol*)extractProtocolFromPropertyEncoding:(NSString*)typeEncoding
{
    NSInteger firstPosition = [typeEncoding rangeOfString:@"<"].location + 1;
    NSInteger length = [typeEncoding rangeOfString:@">"].location - firstPosition;
    
    NSRange protocolNameRange = NSMakeRange(firstPosition, length);
    
    NSString *protocolName = [typeEncoding substringWithRange:protocolNameRange];
    
    return NSProtocolFromString(protocolName);
}

@end
