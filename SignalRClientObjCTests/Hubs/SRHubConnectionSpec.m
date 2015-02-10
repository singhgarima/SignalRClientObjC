//
//  SRHubConnectionSpec.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 10/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#define EXP_SHORTHAND

#import <Expecta/Expecta.h>
#import <Specta/Specta.h>
#import "SRHubConnection.h"
#import "SRVersion.h"

SpecBegin(SRHubConnection)
    describe(@"initWithURLString", ^{
        it(@"should initiatize hub connection", ^{
            NSString *baseUrl = @"http://baseurl.yo/";
            SRHubConnection *connection = [[SRHubConnection alloc] initWithURLString:baseUrl];

            expect(connection.url).to.equal([NSString stringWithFormat:@"%@%@", baseUrl, @"signalr/"]);
            expect(connection.queryString).to.equal(@"");
            expect(connection.items).to.beKindOf([NSMutableDictionary class]);
            expect(connection.headers).to.beKindOf([NSMutableDictionary class]);
            expect(connection.state).to.equal(disconnected);
            expect(connection.transportConnectTimeout).to.equal(@0);
            expect([connection.protocol isEqual:[[SRVersion alloc] initWithMajor:1 minor:3]]).to.beTruthy();

            expect([connection valueForKey:@"hubs"]).to.beKindOf([NSMutableDictionary class]);
            expect([connection valueForKey:@"callbacks"]).to.beKindOf([NSMutableDictionary class]);
        });
    });

    describe(@"initWithURLString:query:useDefault:", ^{
        it(@"should initiatize hub connection", ^{
            NSString *baseUrl = @"http://baseurl.yo/";
            NSDictionary *queryString = @{@"abc": @"def"};
            SRHubConnection *connection = [[SRHubConnection alloc] initWithURLString:baseUrl query:queryString useDefault:NO];

            expect(connection.url).to.equal(baseUrl);
            expect(connection.queryString).to.equal(@"abc=def");
            expect(connection.items).to.beKindOf([NSMutableDictionary class]);
            expect(connection.headers).to.beKindOf([NSMutableDictionary class]);
            expect(connection.state).to.equal(disconnected);
            expect(connection.transportConnectTimeout).to.equal(@0);
            expect([connection.protocol isEqual:[[SRVersion alloc] initWithMajor:1 minor:3]]).to.beTruthy();

            expect([connection valueForKey:@"hubs"]).to.beKindOf([NSMutableDictionary class]);
            expect([connection valueForKey:@"callbacks"]).to.beKindOf([NSMutableDictionary class]);
        });
    });
SpecEnd