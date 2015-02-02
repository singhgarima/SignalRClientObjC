//
//  SRAutoTransportSpec.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 27/1/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>

#define EXP_SHORTHAND

#import "Expecta.h"
#import "SRAutoTransport.h"
#import "SignalRAFNetworking.h"
#import "SRLongPollingTransport.h"
#import "Utilities.h"

SpecBegin(SRAutoTransport)

        describe(@"init:", ^{
            //TODO: fix it
            pending(@"should initiate transport and default networking", ^{
                id longPollingTransport = OCMClassMock([SRLongPollingTransport class]);
                OCMStub([longPollingTransport alloc]).andReturn(longPollingTransport);
                OCMStub([longPollingTransport init]).andReturn(longPollingTransport);

                SRAutoTransport *transport = [[SRAutoTransport alloc] init];

                expect([transport valueForKey:@"transports"][0]).to.equal(longPollingTransport);
                expect([transport valueForKey:@"startIndex"]).to.equal(0);
                expect([transport networking]).to.beKindOf([SignalRAFNetworking class]);
                OCMVerifyAll(longPollingTransport);
            });
        });

        describe(@"initWithTransports:", ^{
            it(@"should initiate transport and default networking", ^{
                NSMutableArray *transports = [@[@"transport1"] mutableCopy];
                SRAutoTransport *transport = [[SRAutoTransport alloc] initWithTransports:transports];

                expect([transport valueForKey:@"transports"]).to.equal(transports);
                expect([transport valueForKey:@"startIndex"]).to.equal(0);
                expect([transport networking]).to.beKindOf([SignalRAFNetworking class]);
            });
        });

        describe(@"initWithTransports:andNetworking:", ^{
            it(@"should initiate transport and specified networking", ^{
                NSMutableArray *transports = [@[@"transport1"] mutableCopy];
                TestNetworking *networking = [[TestNetworking alloc] init];
                SRAutoTransport *transport = [[SRAutoTransport alloc] initWithTransports:transports andNetworking:networking];

                expect([transport valueForKey:@"transports"]).to.equal(transports);
                expect([transport valueForKey:@"startIndex"]).to.equal(0);
                expect([transport networking]).to.equal(networking);
            });
        });

SpecEnd