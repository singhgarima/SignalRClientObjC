#define EXP_SHORTHAND

#import <Expecta/Expecta.h>
#import <Specta/Specta.h>
#import <OCMock/OCMock.h>
#import "TestNetworking.h"
#import "SRHttpBasedTransport.h"
#import "SRConnection.h"
#import "SignalRAFNetworking.h"
#import "SRVersion.h"
#import "SRNegotiationResponse.h"
#import "SRLongPollingTransport.h"


@interface SRHttpBasedTransportTestHelper : NSObject
@property NSDictionary *successResponse;
@property NSError *errorResponse;

- (id)mockSRNegotiationResponseWithDictionary:(NSDictionary *)dictionary;

- (void)expectFailedResponseForNetworking:(id)mockNetworking forUrlRequest:(id)mockUrlRequest withError:(NSError *)errorResponse;

- (void)expectSuccessfulResponseForNetworking:(id)mockNetworking forUrlRequest:(id)mockUrlRequest withSuccessResponse:(NSDictionary *)successResponse;
@end

SpecBegin(SRHttpBasedTransport)

    __block NSString *baseUrl = @"http://www.blahblahsignalR.com/";
    __block SRHttpBasedTransportTestHelper *helper;

    beforeEach(^{
        helper = [[SRHttpBasedTransportTestHelper alloc] init];
    });

    describe(@"initWithNetworking", ^{
        it(@"should initiate transport and default networking", ^{
            TestNetworking *networking = [[TestNetworking alloc] init];
            SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] initWithNetworking:networking];

            expect(transport.networking).to.equal(networking);
        });
    });

    describe(@"negotiate:connectionData:completionHandler:", ^{
        __block SRHttpBasedTransport *transport;
        __block id mockConnection;
        __block id mockUrlRequest;
        __block id mockNetworking;
        __block SRVersion *clientProtocol;

        beforeEach(^{
            clientProtocol = [[SRVersion alloc] initWithMajor:1 minor:2];

            mockConnection = OCMClassMock([SRConnection class]);
            [[[mockConnection stub] andReturn:baseUrl] url];
            [(SRConnection *)[[mockConnection stub] andReturn:clientProtocol] protocol];

            mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
            [[[mockUrlRequest expect] andReturn:mockUrlRequest] requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
                NSString *expectedUrl = [NSString stringWithFormat:@"%@%@", baseUrl, @"negotiate?clientProtocol=1.2.0.0&connectionData=something"];
                expect([url absoluteString]).to.contain(expectedUrl);
                return YES;
            }]];
            [[mockUrlRequest expect] setHTTPMethod:@"GET"];
            [[mockUrlRequest expect] setTimeoutInterval:30];

            mockNetworking = OCMClassMock([SignalRAFNetworking class]);
            [[[[mockNetworking stub] classMethod] andReturn:mockNetworking] alloc];
            [[[mockNetworking stub] andReturn:mockNetworking] init];

            transport = [[SRHttpBasedTransport alloc] init];
        });

        afterEach(^{
            [mockNetworking stopMocking];
            [mockConnection stopMocking];
        });

        it(@"successful negotiation", ^{
            NSDictionary *successResponse = @{@"a" : @"b"};
            __block SRNegotiationResponse *actualResponse;
            void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, NSError *error) {
                actualResponse = response;
            };

            [[mockConnection expect] prepareRequest:mockUrlRequest];

            [helper expectSuccessfulResponseForNetworking:mockNetworking forUrlRequest:mockUrlRequest withSuccessResponse:successResponse];

            id mockSRNegotiationResponse = [helper mockSRNegotiationResponseWithDictionary:successResponse];

            [transport negotiate:mockConnection connectionData:@"something" completionHandler:block];

            OCMVerifyAll(mockUrlRequest);
            OCMVerifyAll(mockConnection);
            OCMVerifyAll(mockNetworking);
            expect(actualResponse).to.equal(mockSRNegotiationResponse);
        });

        it(@"failed negotiation", ^{
            NSError *errorResponse = [[NSError alloc] init];
            __block NSError *actualErrorResponse;
            void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, id error) {
                actualErrorResponse = error;
            };

            [[mockConnection expect] prepareRequest:mockUrlRequest];
            [helper expectFailedResponseForNetworking:mockNetworking forUrlRequest:mockUrlRequest withError:errorResponse];

            [transport negotiate:mockConnection connectionData:@"something" completionHandler:block];

            OCMVerifyAll(mockUrlRequest);
            OCMVerifyAll(mockConnection);
            OCMVerifyAll(mockNetworking);
            expect(actualErrorResponse).to.equal(errorResponse);
        });
    });

    describe(@"send:data:connectionData:completionHandler:", ^{
        __block SRHttpBasedTransport *transport;
        __block id mockConnection;
        __block id mockUrlRequest;
        __block id mockNetworking;

        beforeEach(^{
            mockConnection = OCMClassMock([SRConnection class]);
            [[[mockConnection stub] andReturn:baseUrl] url];
            [(SRConnection *)[[mockConnection stub] andReturn:@"token"] connectionToken];

            mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
            [[[mockUrlRequest expect] andReturn:mockUrlRequest] requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
                NSString *expectedUrl = [NSString stringWithFormat:@"%@%@", baseUrl, @"send?transport=&connectionData=something&connectionToken=token"];
                expect([url absoluteString]).to.contain(expectedUrl);
                return YES;
            }]];
            OCMExpect([mockUrlRequest setHTTPMethod:@"POST"]);
            OCMExpect([mockUrlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]);
            OCMExpect([mockUrlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]);
            OCMExpect([mockUrlRequest setValue:@"9" forHTTPHeaderField:@"Content-Length"]);
            OCMExpect([mockUrlRequest setHTTPBody:[OCMArg checkWithBlock:^BOOL(NSData *requestData) {
                NSString *resultString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
                XCTAssertTrue([resultString isEqualToString:@"data=blah"]);
                return YES;
            }]]);

            mockNetworking = OCMClassMock([SignalRAFNetworking class]);
            [[[[mockNetworking stub] classMethod] andReturn:mockNetworking] alloc];
            [[[mockNetworking stub] andReturn:mockNetworking] init];

            transport = [[SRHttpBasedTransport alloc] init];
        });

        afterEach(^{
            [mockNetworking stopMocking];
            [mockConnection stopMocking];
        });

        it(@"successful send", ^{
            NSDictionary *successResponse = @{@"a" : @"b"};
            __block SRNegotiationResponse *actualResponse;
            void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, NSError *error) {
                actualResponse = response;
            };

            [[mockConnection expect] prepareRequest:mockUrlRequest];
            [[mockConnection expect] didReceiveData:successResponse];

            [helper expectSuccessfulResponseForNetworking:mockNetworking forUrlRequest:mockUrlRequest withSuccessResponse:successResponse];

            [transport send:mockConnection data:@"blah" connectionData:@"something" completionHandler:block];

            OCMVerifyAll(mockUrlRequest);
            OCMVerifyAll(mockConnection);
            OCMVerifyAll(mockNetworking);
            expect(actualResponse).to.equal(successResponse);
        });

        it(@"failed send", ^{
            NSError *errorResponse = [[NSError alloc] init];
            __block NSError *actualErrorResponse;
            void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, id error) {
                actualErrorResponse = error;
            };

            [[mockConnection expect] prepareRequest:mockUrlRequest];
            [[mockConnection expect] didReceiveError:errorResponse];

            [helper expectFailedResponseForNetworking:mockNetworking forUrlRequest:mockUrlRequest withError:errorResponse];

            [transport send:mockConnection data:@"blah" connectionData:@"something" completionHandler:block];

            OCMVerifyAll(mockUrlRequest);
            OCMVerifyAll(mockConnection);
            OCMVerifyAll(mockNetworking);
            expect(actualErrorResponse).to.equal(errorResponse);
        });
    });

    describe(@"abort:timeout:connectionData:", ^{
        __block SRHttpBasedTransport *transport;
        __block id mockConnection;
        __block id mockUrlRequest;
        __block id mockNetworking;
        __block SRVersion *clientProtocol;

        beforeEach(^{
            mockConnection = OCMClassMock([SRConnection class]);
            [[[mockConnection stub] andReturn:baseUrl] url];
            [(SRConnection *)[[mockConnection stub] andReturn:clientProtocol] protocol];
            [(SRConnection *)[[mockConnection stub] andReturn:@"token"] connectionToken];

            mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
            [[[mockUrlRequest expect] andReturn:mockUrlRequest] requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
                NSString *expectedUrl = [NSString stringWithFormat:@"%@%@", baseUrl, @"abort?transport=&connectionData=something&connectionToken=token"];
                expect([url absoluteString]).to.contain(expectedUrl);
                return YES;
            }]];
            OCMExpect([mockUrlRequest setHTTPMethod:@"POST"]);
            OCMExpect([mockUrlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]);

            mockNetworking = OCMClassMock([SignalRAFNetworking class]);
            [[[[mockNetworking stub] classMethod] andReturn:mockNetworking] alloc];
            [[[mockNetworking stub] andReturn:mockNetworking] init];

            transport = [[SRHttpBasedTransport alloc] init];
        });

        afterEach(^{
            [mockNetworking stopMocking];
            [mockConnection stopMocking];
        });

        it(@"successful abort", ^{
            [[mockConnection expect] prepareRequest:mockUrlRequest];
            [helper expectSuccessfulResponseForNetworking:mockNetworking forUrlRequest:mockUrlRequest withSuccessResponse:nil];

            [transport abort:mockConnection timeout:@1 connectionData:@"something"];

            OCMVerifyAll(mockUrlRequest);
            OCMVerifyAll(mockConnection);
            OCMVerifyAll(mockNetworking);
        });

        it(@"failed send", ^{
            NSError *errorResponse = [NSError errorWithDomain:@"blah" code:200 userInfo:nil];
            [[mockConnection expect] prepareRequest:mockUrlRequest];
            [helper expectFailedResponseForNetworking:mockNetworking forUrlRequest:mockUrlRequest withError:errorResponse];

            [transport abort:mockConnection timeout:@1 connectionData:@"something"];

            OCMVerifyAll(mockUrlRequest);
            OCMVerifyAll(mockConnection);
            OCMVerifyAll(mockNetworking);
            expect([transport valueForKey:@"startedAbort"]).to.beTruthy;
        });
    });
SpecEnd

@implementation SRHttpBasedTransportTestHelper

- (id)mockSRNegotiationResponseWithDictionary:(NSDictionary *)dictionary {
    id mockSRNegotiationResponse = OCMClassMock([SRNegotiationResponse class]);
    [[[[mockSRNegotiationResponse stub] classMethod] andReturn:mockSRNegotiationResponse] alloc];
    [[[mockSRNegotiationResponse stub] andReturn:mockSRNegotiationResponse] initWithDictionary:dictionary];
    return mockSRNegotiationResponse;
}

- (void)expectFailedResponseForNetworking:(id)mockNetworking forUrlRequest:(id)mockUrlRequest withError:(NSError *)errorResponse {
    id mockOperation = OCMClassMock([NSOperation class]);
    self.errorResponse = errorResponse;
    OCMExpect([mockNetworking operationForUrlRequest:mockUrlRequest
                                  withSuccessHandler:[OCMArg any]
                                  withFailureHandler:[OCMArg any]]).
            andCall(self, @selector(failedCompletionHandlerForUrlRequest:success:failure:)).
            andReturn(mockOperation);
    OCMStub([(NSOperation *) mockOperation start]);
}

- (void)expectSuccessfulResponseForNetworking:(id)mockNetworking forUrlRequest:(id)mockUrlRequest withSuccessResponse:(NSDictionary *)successResponse {
    id mockOperation = OCMClassMock([NSOperation class]);
    self.successResponse = successResponse;
    OCMExpect([mockNetworking operationForUrlRequest:mockUrlRequest
                                  withSuccessHandler:[OCMArg any]
                                  withFailureHandler:[OCMArg any]]).
            andCall(self, @selector(successCompletionHandlerForUrlRequest:success:failure:)).
            andReturn(mockOperation);

    OCMStub([(NSOperation *) mockOperation start]);
};

- (void)successCompletionHandlerForUrlRequest:(NSURLRequest *)urlRequest success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    success(self.successResponse);
}

- (void)failedCompletionHandlerForUrlRequest:(NSURLRequest *)urlRequest
                                     success:(void (^)(id responseObject))success
                                     failure:(void (^)(NSError *error))failure {
    failure(self.errorResponse);
}
@end