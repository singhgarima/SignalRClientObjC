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

SpecBegin(SRConnection)
    describe(@"initWithURLString:query:useDefault:", ^{
        it(@"should initialize object with url and other options", ^{
            NSString *baseUrl = @"http://baseurl.yo/";
            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl];

            expect(connection.url).to.equal(baseUrl);
            expect(connection.queryString).to.equal(@"");
            expect(connection.items).to.beKindOf([NSMutableDictionary class]);
            expect(connection.headers).to.beKindOf([NSMutableDictionary class]);
            expect(connection.state).to.equal(disconnected);
            expect(connection.transportConnectTimeout).to.equal(@0);
            expect([connection.protocol isEqual:[[SRVersion alloc] initWithMajor:1 minor:3]]).to.beTruthy();
        });
    });

    describe(@"initWithURLString:query:useDefault:", ^{
        it(@"should initialize object with url and other options", ^{
            NSDictionary *query = @{@"transport": @"blah"};
            NSString *baseUrl = @"http://baseurl.yo/";
            SRConnection *connection = [[SRConnection alloc] initWithURLString:baseUrl query:query];
            
            expect(connection.url).to.equal(baseUrl);
            expect(connection.queryString).to.equal(@"transport=blah");
            expect(connection.items).to.beKindOf([NSMutableDictionary class]);
            expect(connection.headers).to.beKindOf([NSMutableDictionary class]);
            expect(connection.state).to.equal(disconnected);
            expect(connection.transportConnectTimeout).to.equal(@0);
            expect([connection.protocol isEqual:[[SRVersion alloc] initWithMajor:1 minor:3]]).to.beTruthy();
        });
    });
SpecEnd
