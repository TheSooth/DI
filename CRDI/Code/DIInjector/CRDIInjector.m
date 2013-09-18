//
//  CRDIInjector.m
//  CRDI
//
//  Created by TheSooth on 9/16/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIInjector.h"
#import "DIClassTemplate.h"
#import "CRDIClassInspector.h"
#import "DIClassTemplate.h"

static CRDIInjector *sDefaultInjector = nil;

@interface CRDIInjector ()

@property (nonatomic, weak) CRDIContainer *container;
@property (nonatomic, strong) NSMutableDictionary *classesCache;
@property (nonatomic, strong) CRDIClassInspector *classInspector;
@property (nonatomic, strong) NSMutableDictionary *ignoringClasses;

@end

@implementation CRDIInjector

+ (CRDIInjector *)defaultInjector
{
    return sDefaultInjector;
}

+ (void)setDefaultInjector:(CRDIInjector *)aDefaultInjector
{
    sDefaultInjector = aDefaultInjector;
}

- (id)init
{
    NSAssert(NO, @"Use initWithContainer: instead");
    return nil;
}

- (id)initWithContainer:(CRDIContainer *)aContainer
{
    NSParameterAssert(aContainer);
    self = [super init];
    
    if (self) {
        self.container = aContainer;
        self.classInspector = [CRDIClassInspector new];
        self.classesCache = [NSMutableDictionary new];
        self.ignoringClasses = [NSMutableDictionary new];
        
        [self setupDefaultIgnoredClass];
    }
    
    return self;
}

- (void)setupDefaultIgnoredClass
{
    [self disableInjectionForClass:[DIClassTemplate class]];
}

- (void)injectTo:(id)aInstance
{
    NSParameterAssert(aInstance);
    NSParameterAssert(self.classesCache);
    
    DIClassTemplate *cachedClassTemplate = [self classTemplateForClass:[aInstance class]];
    
    for (DIPropertyModel *propertyModel in cachedClassTemplate.properties) {
        id <CRDIDependencyBuilder> builder = [self.container builderForProtocol:propertyModel.protocol];
        
        id buildedObject = [builder build];
        
        [aInstance setValue:buildedObject forKey:propertyModel.name];
    }
}

- (DIClassTemplate *)classTemplateForClass:(Class)aClass
{
    NSString *className = NSStringFromClass(aClass);
    
    DIClassTemplate *cachedClassTeamplate = self.classesCache[className];
    
    if (!cachedClassTeamplate) {
        cachedClassTeamplate = [self.classInspector inspect:aClass];
        if (cachedClassTeamplate) {
            self.classesCache[className] = cachedClassTeamplate;
        }
    }
    return cachedClassTeamplate;
}

- (void)disableInjectionForClass:(Class)aClass
{
    [self.ignoringClasses setValue:@(YES) forKey:NSStringFromClass(aClass)];
}

- (BOOL)shouldIgnoreInjectionForClass:(Class)aClass
{
    NSString *classKey = NSStringFromClass(aClass);
    
    return [self.ignoringClasses[classKey] boolValue];
}

@end
