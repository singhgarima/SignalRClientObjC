//
//  SRConnectionSpec.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 10/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#define EXP_SHORTHAND

#import <Expecta/Expecta.h>
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
#import "SRConnection.h"
#import "SRVersion.h"
#import "SignalRAFNetworking.h"
#import "TestNetworking.h"
#import "SRHttpBasedTransport.h"
#import "SRConnectionTestHelper.h"
#import "SRAutoTransport.h"

SpecBegin(SRConnection)
    __block NSString *baseUrl = @"http://baseurl.yo/";
    __block SRConnectionTestHelper *helper;

    beforeEach(^{
       helper = [[SRConnectionTestHelper alloc] init];
    });

    describe(@"initWithURLString:", ^{
        it(@"should initialize object with url and other options", ^{
            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl];

            expect(connection.url).to.equal(baseUrl);
            expect(connection.queryString).to.equal(@"");
            expect(connection.items).to.beKindOf([NSMutableDictionary class]);
            expect(connection.headers).to.beKindOf([NSMutableDictionary class]);
            expect(connection.networking).to.beKindOf([SignalRAFNetworking class]);
            expect(connection.state).to.equal(disconnected);
            expect(connection.transportConnectTimeout).to.equal(@0);
            expect([connection.protocol isEqual:[[SRVersion alloc] initWithMajor:1 minor:3]]).to.beTruthy();
        });
    });

    describe(@"initWithURLString:query:", ^{
        it(@"should initialize object with url and other options", ^{
            NSDictionary *query = @{@"transport" : @"blah"};
            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl query:query];

            expect(connection.url).to.equal(baseUrl);
            expect(connection.queryString).to.equal(@"transport=blah");
            expect(connection.items).to.beKindOf([NSMutableDictionary class]);
            expect(connection.headers).to.beKindOf([NSMutableDictionary class]);
            expect(connection.networking).to.beKindOf([SignalRAFNetworking class]);
            expect(connection.state).to.equal(disconnected);
            expect(connection.transportConnectTimeout).to.equal(@0);
            expect([connection.protocol isEqual:[[SRVersion alloc] initWithMajor:1 minor:3]]).to.beTruthy();
        });
    });

    describe(@"initWithURLString:query:andNetworking:", ^{
        it(@"should initialize object with url and other options", ^{
            NSDictionary *query = @{@"transport" : @"blah"};
            TestNetworking *testNetworking = [[TestNetworking alloc] init];
            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl query:query andNetworking:testNetworking];

            expect(connection.url).to.equal(baseUrl);
            expect(connection.queryString).to.equal(@"transport=blah");
            expect(connection.items).to.beKindOf([NSMutableDictionary class]);
            expect(connection.headers).to.beKindOf([NSMutableDictionary class]);
            expect(connection.networking).to.beKindOf([TestNetworking class]);
            expect(connection.state).to.equal(disconnected);
            expect(connection.transportConnectTimeout).to.equal(@0);
            expect([connection.protocol isEqual:[[SRVersion alloc] initWithMajor:1 minor:3]]).to.beTruthy();
        });
    });

    describe(@"start", ^{
        it(@"should start with auto transport and specific networking", ^{
            TestNetworking *testNetworking = OCMClassMock([TestNetworking class]);

            id mockAutoTransport = OCMClassMock([SRAutoTransport class]);
            [[[mockAutoTransport stub] andReturn:mockAutoTransport] alloc];
            [[[mockAutoTransport expect] andReturn:mockAutoTransport] initWithNetworking:testNetworking];

            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl query:@{} andNetworking:testNetworking];

            [connection start];

            OCMVerifyAll(mockAutoTransport);
        });
    });

    describe(@"start:", ^{
        it(@"should change state from disconnected to connecting", ^{
            id mockSRHttpBasedTransport = OCMClassMock([SRHttpBasedTransport class]);

            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl];
            id mockConnection = [OCMockObject partialMockForObject:connection];
            OCMExpect([mockConnection changeState:disconnected toState:connecting]);

            [mockConnection start:mockSRHttpBasedTransport];

            OCMVerifyAll(mockConnection);
        });

        it(@"should perform negotiation & start", ^{
            id mockSRHttpBasedTransport = OCMClassMock([SRHttpBasedTransport class]);

            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl];

            OCMExpect([mockSRHttpBasedTransport negotiate:connection connectionData:nil completionHandler:[OCMArg any]]);

            [connection start:mockSRHttpBasedTransport];

            OCMVerifyAll(mockSRHttpBasedTransport);
            expect([connection transport]).to.equal(mockSRHttpBasedTransport);
        });

        it(@"on successful negotiation", ^{
            id mockSRHttpBasedTransport = OCMClassMock([SRHttpBasedTransport class]);
            id mockNegotiationResponse = OCMClassMock([SRNegotiationResponse class]);
            OCMStub([mockNegotiationResponse connectionId]).andReturn(@"ID");
            OCMStub([mockNegotiationResponse connectionToken]).andReturn(@"token");
            OCMStub([mockNegotiationResponse disconnectTimeout]).andReturn(@1);
            OCMStub([mockNegotiationResponse transportConnectTimeout]).andReturn(@2);
            OCMStub([mockNegotiationResponse protocolVersion]).andReturn(@"1.3.0.0");
            helper.successfulNegotiationResponse = mockNegotiationResponse;

            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl];

            OCMStub([mockSRHttpBasedTransport negotiate:connection connectionData:nil completionHandler:[OCMArg any]]).
                    andCall(helper, @selector(successfulNegotiate:connectionData:completionHandler:));
            OCMExpect([mockSRHttpBasedTransport start:connection connectionData:[OCMArg any] completionHandler:[OCMArg any]]);

            [connection start:mockSRHttpBasedTransport];

            OCMVerifyAll(mockSRHttpBasedTransport);
            expect([connection transport]).to.equal(mockSRHttpBasedTransport);
        });
    });
SpecEnd
