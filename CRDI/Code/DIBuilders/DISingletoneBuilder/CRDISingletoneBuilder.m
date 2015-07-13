//
//  CRDISingletoneBuilder.m
//  CRDI
//
//  Created by Vladimir Shevchenko on 16.09.13.
//  Copyright (c) 2013 CriolloKit. All rights reserved.
//

#import "CRDISingletoneBuilder.h"
#import "CRDIException.h"

@interface CRDISingletoneBuilder ()

@property (nonatomic, strong) id sharedInstance;

@property (nonatomic, strong) id <CRDIDependencyBuilder> instanceBuilder;

@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation CRDISingletoneBuilder

- (id)initWithBuilder:(id <CRDIDependencyBuilder>)aBuilder
{
    NSParameterAssert(aBuilder);
    
    if (![aBuilder conformsToProtocol:@protocol(CRDIDependencyBuilder)]) {
        @throw [CRDIException exceptionWithReason:[NSString stringWithFormat:@"%@ not implemet CRDIDependencyBuilder protocol",
                                                   NSStringFromClass([aBuilder class])]];
    }
    
    self = [super init];
    
    if (self) {
        self.queue = dispatch_queue_create("CRDISingletoneBuilder", 0);
        self.instanceBuilder = aBuilder;
    }
    
    return self;
}

- (id)build
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_sync(self.queue, ^{
        if (!weakSelf.sharedInstance) {
            weakSelf.sharedInstance = [weakSelf.instanceBuilder build];
        }
    });
    
    return self.sharedInstance;
}

@end
