//
//  SRHttpBasedTransportTest.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 5/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "SRNegotiationResponse.h"
#import "SRConnection.h"
#import "SRHttpBasedTransport.h"
#import "Utilities.h"
#import "SignalRAFNetworking.h"

@interface SRHttpBasedTransportTest : XCTestCase {
    id mockNetworking;
    SRHttpBasedTransport *transport;

}
@property id successResponse;
@property id error;
@end

@implementation SRHttpBasedTransportTest

- (void)setUp {
    [super setUp];
    mockNetworking = OCMClassMock([SignalRAFNetworking class]);
    [[[[mockNetworking stub] classMethod] andReturn:mockNetworking] alloc];
    [[[mockNetworking stub] andReturn:mockNetworking] init];

    transport = [[SRHttpBasedTransport alloc] init];
}

- (void)tearDown {
    [mockNetworking stopMocking];
    [super tearDown];
}

#pragma mark : negotiate:connectionData:completionHandler:

- (void)testNegotiateConnectionDataCompletionHandlerWithSuccessfulNegotiations {
    NSString *baseUrl = @"http://base.url.com";
    NSDictionary *successResponse = @{@"a" : @"b"};
    void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, NSError *error) {
    };

    id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
    [[[mockUrlRequest expect] andReturn:mockUrlRequest] requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
        XCTAssertTrue([[url absoluteString] containsString:baseUrl]);
        return YES;
    }]];
    [[mockUrlRequest expect] setHTTPMethod:@"GET"];
    [[mockUrlRequest expect] setTimeoutInterval:30];


    id mockConnection = OCMClassMock([SRConnection class]);
    [[[mockConnection stub] andReturn:baseUrl] url];
    [[mockConnection expect] prepareRequest:mockUrlRequest];

    [self expectSuccessfulResponseForUrlRequest:mockUrlRequest withSuccessResponse:successResponse];

    id mockResponse = OCMClassMock([SRNegotiationResponse class]);
    [[[[mockResponse stub] classMethod] andReturn:mockResponse] alloc];
    [[[mockResponse expect] andReturn:mockResponse] initWithDictionary:successResponse];

    [transport negotiate:mockConnection connectionData:@"something" completionHandler:block];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerifyAll(mockNetworking);
    OCMVerifyAll(mockResponse);
}


- (void)testNegotiateConnectionDataCompletionHandlerWithFailedNegotiations {
    NSString *baseUrl = @"http://base.url.com";
    NSError *errorResponse = [[NSError alloc] init];
    void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, id error) {
        XCTAssertEqual(error, errorResponse);
    };

    id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
    [[[mockUrlRequest expect] andReturn:mockUrlRequest] requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
        XCTAssertTrue([[url absoluteString] containsString:baseUrl]);
        return YES;
    }]];
    [[mockUrlRequest expect] setHTTPMethod:@"GET"];
    [[mockUrlRequest expect] setTimeoutInterval:30];

    id mockConnection = OCMClassMock([SRConnection class]);
    [[[mockConnection stub] andReturn:baseUrl] url];
    [[mockConnection expect] prepareRequest:mockUrlRequest];

    [self expectFailedResponseForUrlRequest:mockUrlRequest withError:errorResponse];

    [transport negotiate:mockConnection
          connectionData:@"something" completionHandler:block];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    [mockNetworking verify];
    [mockUrlRequest stopMocking];
    [mockConnection stopMocking];
};

#pragma mark - send:data:connectionData:completionHandler:

- (void)testSendDataConnectionDataCompletionHandlerWithSuccessfulResponse {
    NSString *baseUrl = @"http://base.url.com/";
    NSString *sendUrl = [NSString stringWithFormat:@"%@%@?transport=", baseUrl, @"send"];
    NSDictionary *successResponse = @{@"successResponse":@"blah"};
    void (^block)(SRNegotiationResponse *, NSError *) = ^(id response, id error) {
        XCTAssertEqual((NSDictionary *)response, successResponse);
        XCTAssertNil(error);
    };

    id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
    OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
        XCTAssertTrue([[url absoluteString] containsString:baseUrl]);
        XCTAssertTrue([[url absoluteString] containsString:sendUrl]);
        return YES;
    }]]).andReturn(mockUrlRequest);
    OCMExpect([mockUrlRequest setHTTPMethod:@"POST"]);
    OCMExpect([mockUrlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]);
    OCMExpect([mockUrlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]);
    OCMExpect([mockUrlRequest setValue:@"9" forHTTPHeaderField:@"Content-Length"]);
    OCMExpect([mockUrlRequest setHTTPBody:[OCMArg checkWithBlock:^BOOL(NSData *requestData){
        NSString *resultString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
        XCTAssertTrue([resultString isEqualToString:@"data=blah"]);
        return YES;
    }]]);

    id mockConnection = OCMClassMock([SRConnection class]);
    [[[mockConnection stub] andReturn:baseUrl] url];
    [[mockConnection expect] prepareRequest:mockUrlRequest];
    [[mockConnection expect] didReceiveData:successResponse];

    [self expectSuccessfulResponseForUrlRequest:mockUrlRequest withSuccessResponse:successResponse];

    [transport send:mockConnection data:@"blah" connectionData:@"something" completionHandler:block];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerifyAll(mockNetworking);
    [mockUrlRequest stopMocking];
    [mockConnection stopMocking];
};

- (void)testSendDataConnectionDataCompletionHandlerWithFailedResponse {
    NSString *baseUrl = @"http://base.url.com/";
    NSString *sendUrl = [NSString stringWithFormat:@"%@%@?transport=", baseUrl, @"send"];
    NSError *errorResponse = [[NSError alloc] init];
    void (^block)(SRNegotiationResponse *, NSError *) = ^(id response, id error) {
        XCTAssertEqual(error, errorResponse);
        XCTAssertNil(response);
    };

    id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
    OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
        XCTAssertTrue([[url absoluteString] containsString:baseUrl]);
        XCTAssertTrue([[url absoluteString] containsString:sendUrl]);
        return YES;
    }]]).andReturn(mockUrlRequest);
    OCMExpect([mockUrlRequest setHTTPMethod:@"POST"]);
    OCMExpect([mockUrlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]);
    OCMExpect([mockUrlRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]);
    OCMExpect([mockUrlRequest setValue:@"9" forHTTPHeaderField:@"Content-Length"]);
    OCMExpect([mockUrlRequest setHTTPBody:[OCMArg checkWithBlock:^BOOL(NSData *requestData){
        NSString *resultString = [[NSString alloc] initWithData:requestData encoding:NSUTF8StringEncoding];
        XCTAssertTrue([resultString isEqualToString:@"data=blah"]);
        return YES;
    }]]);

    id mockConnection = OCMClassMock([SRConnection class]);
    [[[mockConnection stub] andReturn:baseUrl] url];
    [[mockConnection expect] prepareRequest:mockUrlRequest];
    [[mockConnection expect] didReceiveError:errorResponse];

    [self expectFailedResponseForUrlRequest:mockUrlRequest withError:errorResponse];

    [transport send:mockConnection data:@"blah" connectionData:@"something" completionHandler:block];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerifyAll(mockNetworking);
    [mockUrlRequest stopMocking];
    [mockConnection stopMocking];
};

#pragma mark - abort:timeout:connectionData:

- (void)testAbortTimeoutConnectionDataSuccess {
    NSString *baseUrl = @"http://base.url.com/";
    NSString *abortUrl = [NSString stringWithFormat:@"%@%@?transport=", baseUrl, @"abort"];

    id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
    OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
        XCTAssertTrue([[url absoluteString] containsString:baseUrl]);
        XCTAssertTrue([[url absoluteString] containsString:abortUrl]);
        return YES;
    }]]).andReturn(mockUrlRequest);
    OCMExpect([mockUrlRequest setHTTPMethod:@"POST"]);
    OCMExpect([mockUrlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]);

    id mockConnection = OCMClassMock([SRConnection class]);
    [[[mockConnection stub] andReturn:baseUrl] url];
    [[mockConnection expect] prepareRequest:mockUrlRequest];

    [self expectSuccessfulResponseForUrlRequest:mockUrlRequest withSuccessResponse:nil];

    [transport abort:mockConnection timeout:@1 connectionData:@"something"];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    [mockNetworking verify];
    [mockUrlRequest stopMocking];
    [mockConnection stopMocking];
}

- (void)testAbortTimeoutConnectionDataFailure {
    NSString *baseUrl = @"http://base.url.com/";
    NSString *abortUrl = [NSString stringWithFormat:@"%@%@?transport=", baseUrl, @"abort"];

    id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
    OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
        XCTAssertTrue([[url absoluteString] containsString:baseUrl]);
        XCTAssertTrue([[url absoluteString] containsString:abortUrl]);
        return YES;
    }]]).andReturn(mockUrlRequest);
    OCMExpect([mockUrlRequest setHTTPMethod:@"POST"]);
    OCMExpect([mockUrlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"]);

    id mockConnection = OCMClassMock([SRConnection class]);
    [[[mockConnection stub] andReturn:baseUrl] url];
    [[mockConnection expect] prepareRequest:mockUrlRequest];

    NSError *errorResponse = [NSError errorWithDomain:@"blah" code:200 userInfo:nil];
    [self expectFailedResponseForUrlRequest:mockUrlRequest withError:errorResponse];

    [transport abort:mockConnection timeout:@1 connectionData:@"something"];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerify(mockNetworking);
}

#pragma mark - Test helpers

- (void)expectFailedResponseForUrlRequest:(id)mockUrlRequest withError:(NSError *)errorResponse {
    id mockOperation = OCMClassMock([NSOperation class]);
    self.error = errorResponse;
    OCMExpect([mockNetworking operationForUrlRequest:mockUrlRequest
                                  withSuccessHandler:[OCMArg any]
                                  withFailureHandler:[OCMArg any]]).
            andCall(self, @selector(failedCompletionHandlerForUrlRequest:success:failure:)).
            andReturn(mockOperation);
    OCMStub([(NSOperation *) mockOperation start]);
}

- (void)expectSuccessfulResponseForUrlRequest:(id)mockUrlRequest withSuccessResponse:(NSDictionary *)successResponse {
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
    failure(self.error);
}
@end