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

//@interface MockCalls : NSObject
//@property (strong, nonatomic) NSDictionary *successResponse;
//@property (strong, nonatomic) NSError *error;
//- (void)successCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//- (void)failedCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
//@end
//
//@implementation MockCalls
//
//- (void)successCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
//    success(nil, _successResponse);
//}
//
//- (void)failedCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
//    failure(nil, _error);
//}
//@end

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

//        describe(@"negotiate:connectionData:completionHandler:", ^{
//            it(@"successful operation", ^{
//                NSString *baseUrl = @"http://base.url.com";
//                MockCalls *mockCall = [[MockCalls alloc] init];
//                NSDictionary *successResponse = @{@"a": @"b"};
//                [mockCall setSuccessResponse:successResponse];
//                void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, NSError *error) {
//                };
//
//                id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
//                OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url){
//                    expect([url absoluteString]).to.contain(baseUrl);
//                    return YES;
//                }]]).andReturn(mockUrlRequest);
//                OCMExpect([mockUrlRequest setHTTPMethod:@"GET"]);
//                OCMExpect([mockUrlRequest setTimeoutInterval:30]);
//
//                id mockConnection = OCMClassMock([SRConnection class]);
//                OCMStub([mockConnection url]).andReturn(baseUrl);
//                OCMExpect([mockConnection prepareRequest:mockUrlRequest]);
//
//                AFHTTPRequestOperation *mockNetworking = OCMClassMock([AFHTTPRequestOperation class]);
//                OCMStub([(id) mockNetworking alloc]).andReturn(mockNetworking);
//                OCMStub([mockNetworking initWithRequest:mockUrlRequest]).andReturn(mockNetworking);
//                OCMExpect([mockNetworking setResponseSerializer:[OCMArg any]]);
//
//                OCMExpect([mockNetworking setCompletionBlockWithSuccess:[OCMArg any]
//                                                                failure:[OCMArg any]]).andCall(mockCall, @selector(successCompletionHandlerWithSuccess:failure:));
//                OCMExpect([(AFHTTPRequestOperation *) mockNetworking start]);
//
//                id mockResponse = OCMClassMock([SRNegotiationResponse class]);
//                OCMExpect([mockResponse alloc]).andReturn(mockResponse);
//                OCMExpect([mockResponse initWithDictionary:successResponse]).andReturn(mockResponse);
//
//                SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];
//
//                [transport negotiate:mockConnection
//                      connectionData:@"something" completionHandler:block];
//
//                OCMVerify(mockUrlRequest);
//                OCMVerify(mockConnection);
//                OCMVerify(mockNetworking);
//                OCMVerify(mockResponse);
//            });
//
//            it(@"failed operation", ^{
//                NSString *baseUrl = @"http://base.url.com";
//                NSError *errorResponse = [[NSError alloc] init];
//                MockCalls *mockCall = [[MockCalls alloc] init];
//                [mockCall setError:errorResponse];
//                void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, NSError *error) {
//                    expect(error).to.equal(errorResponse);
//                };
//
//                id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
//                OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url){
//                    expect([url absoluteString]).to.contain(baseUrl);
//                    return YES;
//                }]]).andReturn(mockUrlRequest);
//                OCMExpect([mockUrlRequest setHTTPMethod:@"GET"]);
//                OCMExpect([mockUrlRequest setTimeoutInterval:30]);
//
//                id mockConnection = OCMClassMock([SRConnection class]);
//                OCMStub([mockConnection url]).andReturn(baseUrl);
//                OCMExpect([mockConnection prepareRequest:mockUrlRequest]);
//
//                AFHTTPRequestOperation *mockNetworking = OCMClassMock([AFHTTPRequestOperation class]);
//                OCMStub([(id) mockNetworking alloc]).andReturn(mockNetworking);
//                OCMStub([mockNetworking initWithRequest:mockUrlRequest]).andReturn(mockNetworking);
//                OCMExpect([mockNetworking setResponseSerializer:[OCMArg any]]);
//                OCMExpect([mockNetworking setCompletionBlockWithSuccess:[OCMArg any]
//                                                                failure:[OCMArg any]]).andCall(mockCall, @selector(failedCompletionHandlerWithSuccess:failure:));
//                OCMExpect([(AFHTTPRequestOperation *) mockNetworking start]);
//
//                SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];
//
//                [transport negotiate:mockConnection
//                      connectionData:@"something" completionHandler:block];
//
//                OCMVerify(mockUrlRequest);
//                OCMVerify(mockConnection);
//                OCMVerify(mockNetworking);
//            });
//        });

SpecEnd