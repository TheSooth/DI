//
//  CRDIAutoInjectorSpec.m
//  CRDI
//
//  Created by Sergey Zenchenko on 9/18/13.
//  Copyright 2013 CriolloKit. All rights reserved.
//

#import <Kiwi.h>
#import "CRDIAutoInjector.h"
#import "CRDIInjectedClass.h"
#import "CRDIInjectedClassChild.h"
#import "CRDISampleClass.h"
#import "CRDIDependencyBuilder.h"
#import "CRDIContainer.h"
#import "CRDIInjector.h"

SPEC_BEGIN(CRDIAutoInjectorSpec)

describe(@"Attach to class", ^{
    __block CRDIAutoInjector *_autoInjector;
    __block CRDISampleClass *_sampleObject1;
    __block CRDISampleClass *_sampleObject2;
    
    beforeEach(^{
        _sampleObject1 = [CRDISampleClass new];
        _sampleObject2 = [CRDISampleClass new];
        
        id builderMock1 = [KWMock mockForProtocol:@protocol(CRDIDependencyBuilder)];
        [builderMock1 stub:@selector(build) andReturn:_sampleObject1];
        
        id builderMock2 = [KWMock mockForProtocol:@protocol(CRDIDependencyBuilder)];
        [builderMock2 stub:@selector(build) andReturn:_sampleObject2];
        
        id containerMock =[KWMock mockForClass:[CRDIContainer class]];
        [containerMock stub:@selector(builderForProtocol:) withBlock:^id(NSArray *params) {
            Protocol *p = params[0];
            
            if (p == @protocol(CRDISampleProtocol)) {
                return builderMock1;
            }
            
            if (p == @protocol(CRDIAnotherSampleProtocol)) {
                return builderMock2;
            }
            
            return nil;
        }];
        
        CRDIInjector *injector = [[CRDIInjector alloc] initWithContainer:containerMock];
        
        _autoInjector = [[CRDIAutoInjector alloc] initWithInjector:injector];
    });
    
    it(@"Should attach and auto inject dependencies", ^{
        [_autoInjector attachToClass:[CRDIInjectedClass class]];
        
        CRDIInjectedClass *objc = [[CRDIInjectedClass alloc] init];
        
        [[objc.ioc_injected shouldNot] beNil];
        [[objc.ioc_injected should] equal:_sampleObject1];
        
        [[objc.ioc_testField shouldNot] beNil];
        [[objc.ioc_testField should] equal:_sampleObject2];
        
        [[objc.stringTest should] beNil];
    });
    
    it(@"Should attach and auto inject dependencies into child classes", ^{
        [_autoInjector attachToClass:[NSObject class]];
        
        CRDIInjectedClassChild *objc = [[CRDIInjectedClassChild alloc] init];
        
        [[objc.ioc_injected shouldNot] beNil];
        [[objc.ioc_injected should] equal:_sampleObject1];
        
        [[objc.ioc_testField shouldNot] beNil];
        [[objc.ioc_testField should] equal:_sampleObject2];
        
        [[objc.stringTest should] beNil];
        
        [[objc.ioc_child shouldNot] beNil];
        [[objc.ioc_child should] equal:_sampleObject1];
        
    });
    
});

SPEC_END
