//
//  SRLongPollingTransportSpec.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 2/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import <Specta/Specta.h>

#define EXP_SHORTHAND

#import "Expecta.h"
#import "SignalRAFNetworking.h"
#import "TestNetworking.h"
#import "SRLongPollingTransport.h"

SpecBegin(SRLongPollingTransport)

        describe(@"ini:", ^{
            it(@"should initiate transport and default networking", ^{
                SRLongPollingTransport *transport = [[SRLongPollingTransport alloc] init];

                expect([transport networking]).to.beKindOf([SignalRAFNetworking class]);
                expect([transport valueForKey:@"pollingOperationQueue"]).to.beKindOf([NSOperationQueue class]);
                expect([[transport valueForKey:@"pollingOperationQueue"] maxConcurrentOperationCount]).to.equal(1);
                expect([[transport valueForKey:@"reconnectDelay"] intValue]).to.equal(5);
                expect([[transport valueForKey:@"errorDelay"] intValue]).to.equal(2);
            });
        });

        describe(@"initWithTransports:", ^{
            it(@"should initiate transport and default networking", ^{
                TestNetworking *networking = [[TestNetworking alloc] init];
                SRLongPollingTransport *transport = [[SRLongPollingTransport alloc] initWithNetworking:networking];

                expect([transport networking]).to.equal(networking);
                expect([transport valueForKey:@"pollingOperationQueue"]).to.beKindOf([NSOperationQueue class]);
                expect([[transport valueForKey:@"pollingOperationQueue"] maxConcurrentOperationCount]).to.equal(1);
                expect([[transport valueForKey:@"reconnectDelay"] intValue]).to.equal(5);
                expect([[transport valueForKey:@"errorDelay"] intValue]).to.equal(2);
            });
        });

SpecEnd