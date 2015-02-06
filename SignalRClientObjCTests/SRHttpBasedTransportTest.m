//
//  SRHttpBasedTransportTest.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 5/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <OCMock/OCMock.h>
#import "SRNegotiationResponse.h"
#import "SRConnection.h"
#import "SRHttpBasedTransport.h"
#import "Utilities.h"

@interface SRHttpBasedTransportTest : XCTestCase

@end

@implementation SRHttpBasedTransportTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark : negotiate:connectionData:completionHandler:

- (void)testNegotiateConnectionDataCompletionHandlerWithSuccessfulNegotiations {
    NSString *baseUrl = @"http://base.url.com";
    NSDictionary *successResponse = @{@"a" : @"b"};
    void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, NSError *error) {
    };

    id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
    OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
        XCTAssertTrue([[url absoluteString] containsString:baseUrl]);
        return YES;
    }]]).andReturn(mockUrlRequest);
    OCMExpect([mockUrlRequest setHTTPMethod:@"GET"]);
    OCMExpect([mockUrlRequest setTimeoutInterval:30]);

    id mockConnection = OCMClassMock([SRConnection class]);
    OCMStub([mockConnection url]).andReturn(baseUrl);
    OCMExpect([mockConnection prepareRequest:mockUrlRequest]);

    AFHTTPRequestOperation *mockNetworking = [self expectSuccessfulResponseForUrlRequest:mockUrlRequest withSuccessResponse:successResponse];

    id mockResponse = OCMClassMock([SRNegotiationResponse class]);
    OCMExpect([mockResponse alloc]).andReturn(mockResponse);
    OCMExpect([mockResponse initWithDictionary:successResponse]).andReturn(mockResponse);

    SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];

    [transport negotiate:mockConnection
          connectionData:@"something" completionHandler:block];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerify(mockNetworking);
    OCMVerifyAll(mockResponse);
}


- (void)testNegotiateConnectionDataCompletionHandlerWithFailedNegotiations {
    NSString *baseUrl = @"http://base.url.com";
    NSError *errorResponse = [[NSError alloc] init];
    void (^block)(SRNegotiationResponse *, NSError *) = ^(SRNegotiationResponse *response, id error) {
        XCTAssertEqual(error, errorResponse);
//        return YES;
    };

    id mockUrlRequest = OCMClassMock([NSMutableURLRequest class]);
    OCMExpect([mockUrlRequest requestWithURL:[OCMArg checkWithBlock:^BOOL(NSURL *url) {
        XCTAssertTrue([[url absoluteString] containsString:baseUrl]);
        return YES;
    }]]).andReturn(mockUrlRequest);
    OCMExpect([mockUrlRequest setHTTPMethod:@"GET"]);
    OCMExpect([mockUrlRequest setTimeoutInterval:30]);

    id mockConnection = OCMClassMock([SRConnection class]);
    OCMStub([mockConnection url]).andReturn(baseUrl);
    OCMExpect([mockConnection prepareRequest:mockUrlRequest]);

    id mockNetworking = [self expectFailedResponseForUrlRequest:mockUrlRequest withError:errorResponse];

    SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];

    [transport negotiate:mockConnection
          connectionData:@"something" completionHandler:block];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerifyAll(mockNetworking);
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
    OCMStub([mockConnection url]).andReturn(baseUrl);
    OCMExpect([mockConnection prepareRequest:mockUrlRequest]);
    OCMExpect([mockConnection didReceiveData:successResponse]);

    AFHTTPRequestOperation *mockNetworking = [self expectSuccessfulResponseForUrlRequest:mockUrlRequest withSuccessResponse:successResponse];

    SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];
    [transport send:mockConnection data:@"blah" connectionData:@"something" completionHandler:block];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerify(mockNetworking);
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
    OCMStub([mockConnection url]).andReturn(baseUrl);
    OCMExpect([mockConnection prepareRequest:mockUrlRequest]);
    OCMExpect([mockConnection didReceiveError:errorResponse]);

    AFHTTPRequestOperation *mockNetworking = [self expectFailedResponseForUrlRequest:mockUrlRequest withError:errorResponse];

    SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];
    [transport send:mockConnection data:@"blah" connectionData:@"something" completionHandler:block];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerify(mockNetworking);
};

#pragma mark - abort:timeout:connectionData:

- (void)testAbortTimeoutConnectionDataSuccess {
//    _startedAbort = YES;
//
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
//    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//    }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        SRLogHTTPTransport(@"Clean disconnect failed. %@", error);
//        [self completeAbort];
//    }];
//    [operation start];
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
    OCMStub([mockConnection url]).andReturn(baseUrl);
    OCMExpect([mockConnection prepareRequest:mockUrlRequest]);

    AFHTTPRequestOperation *mockNetworking = [self expectSuccessfulResponseForUrlRequest:mockUrlRequest
                                                                     withSuccessResponse:nil];

    SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];
    [transport abort:mockConnection timeout:@1 connectionData:@"something"];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerify(mockNetworking);
}

- (void)pendingAbortTimeoutConnectionDataFailure {
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
    OCMStub([mockConnection url]).andReturn(baseUrl);
    OCMExpect([mockConnection prepareRequest:mockUrlRequest]);

    NSError *errorResponse = [[NSError alloc] init];
    AFHTTPRequestOperation *mockNetworking = [self expectFailedResponseForUrlRequest:mockUrlRequest withError:errorResponse];

    SRHttpBasedTransport *transport = [[SRHttpBasedTransport alloc] init];
    [transport abort:mockConnection timeout:@1 connectionData:@"something"];

    OCMVerifyAll(mockUrlRequest);
    OCMVerifyAll(mockConnection);
    OCMVerify(mockNetworking);
}

#pragma mark - Test helpers

- (id)expectFailedResponseForUrlRequest:(id)mockUrlRequest withError:(NSError *)errorResponse {
    MockCalls *mockCall = [[MockCalls alloc] init];
    [mockCall setError:errorResponse];
    AFHTTPRequestOperation *mockNetworking = OCMClassMock([AFHTTPRequestOperation class]);
    OCMStub([(id) mockNetworking alloc]).andReturn(mockNetworking);
    OCMStub([mockNetworking initWithRequest:mockUrlRequest]).andReturn(mockNetworking);
    OCMExpect([mockNetworking setResponseSerializer:[OCMArg any]]);
    OCMExpect([mockNetworking setCompletionBlockWithSuccess:[OCMArg any]
                                                    failure:[OCMArg any]]).andCall(mockCall, @selector(failedCompletionHandlerWithSuccess:failure:));
    OCMExpect([(AFHTTPRequestOperation *) mockNetworking start]);
    return mockNetworking;
}

- (id)expectSuccessfulResponseForUrlRequest:(id)mockUrlRequest withSuccessResponse:(NSDictionary *)successResponse {
    MockCalls *mockCall = [[MockCalls alloc] init];
    [mockCall setSuccessResponse:successResponse];
    AFHTTPRequestOperation *mockNetworking = OCMClassMock([AFHTTPRequestOperation class]);
    OCMStub([(id) mockNetworking alloc]).andReturn(mockNetworking);
    OCMStub([mockNetworking initWithRequest:mockUrlRequest]).andReturn(mockNetworking);
    OCMExpect([mockNetworking setResponseSerializer:[OCMArg any]]);

    OCMExpect([mockNetworking setCompletionBlockWithSuccess:[OCMArg any]
                                                    failure:[OCMArg any]]).andCall(mockCall, @selector(successCompletionHandlerWithSuccess:failure:));
    OCMExpect([(AFHTTPRequestOperation *) mockNetworking start]);
    return mockNetworking;
};
@end