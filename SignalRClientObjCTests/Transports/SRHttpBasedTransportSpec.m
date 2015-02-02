//
//  SRHttpBasedTransportSpec.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 2/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import <Specta/Specta.h>

#define EXP_SHORTHAND

#import "Expecta.h"
#import "SRHttpBasedTransport.h"
#import "SignalRAFNetworking.h"
#import "Utilities.h"
#import "OCMock.h"
#import "SRConnection.h"

@interface MockCalls : NSObject
+ (void)successCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end

@implementation MockCalls
+ (void)successCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    success(nil, nil);
}
@end

SpecBegin(SRHttpBasedTransport)

        describe(@"ini:", ^{
            it(@"should initiate transport and default networking", ^{
                SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];

                expect([transport networking]).to.beKindOf([SignalRAFNetworking class]);
            });
        });

        describe(@"initWithTransports:", ^{
            it(@"should initiate transport and default networking", ^{
                TestNetworking *networking = [[TestNetworking alloc] init];
                SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] initWithNetworking:networking];

                expect([transport networking]).to.equal(networking);
            });
        });

        describe(@"negotiate:connectionData:completionHandler:", ^{
            it(@"successful operation", ^{
                NSString *baseUrl = @"http://base.url.com";
                void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, NSError *error) {
                };

                id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
                OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url){
                    expect([url absoluteString]).to.contain(baseUrl);
                    return YES;
                }]]).andReturn(mockUrlRequest);
                OCMExpect([mockUrlRequest setHTTPMethod:@"GET"]);
                OCMExpect([mockUrlRequest setTimeoutInterval:30]);

                id mockConnection = OCMClassMock([SRConnection class]);
                OCMStub([mockConnection url]).andReturn(baseUrl);
                OCMExpect([mockConnection prepareRequest:mockUrlRequest]);

                AFHTTPRequestOperation *mockNetworking = OCMClassMock([AFHTTPRequestOperation class]);
                OCMStub([(id) mockNetworking alloc]).andReturn(mockNetworking);
                OCMStub([mockNetworking initWithRequest:mockUrlRequest]).andReturn(mockNetworking);
                OCMExpect([mockNetworking setResponseSerializer:[OCMArg any]]);
                OCMExpect([mockNetworking setCompletionBlockWithSuccess:[OCMArg any]
                                                                failure:[OCMArg any]]).andCall([MockCalls class], @selector(successCompletionHandlerWithSuccess:failure:));
                OCMExpect([(AFHTTPRequestOperation *) mockNetworking start]);

                SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];

                [transport negotiate:mockConnection
                      connectionData:@"something" completionHandler:block];

                OCMVerify(mockUrlRequest);
                OCMVerify(mockConnection);
                OCMVerify(mockNetworking);
            });
        });

SpecEnd