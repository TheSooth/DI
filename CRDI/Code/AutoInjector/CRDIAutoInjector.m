//
//  CRDIAutoInjector.m
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDIAutoInjector.h"


@interface CRDIAutoInjector ()

@property (nonatomic, strong) id <CRDIInstanceInjector> injector;

@end

@implementation CRDIAutoInjector

- (id)initWithInjector:(id <CRDIInstanceInjector>)anInjector
{
    NSParameterAssert(anInjector);
    self = [super init];
    if (self) {
        self.injector = anInjector;
    }
    return self;
}

- (void)attachToClass:(Class)classToAttach
{
    [classToAttach setInjector:self.injector];
}

@end
