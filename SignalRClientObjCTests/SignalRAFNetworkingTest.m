//
//  SignalRAFNetworkingTest.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 6/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "Utilities.h"
#import "SignalRAFNetworking.h"

@interface SignalRAFNetworkingTest : XCTestCase

@end

@implementation SignalRAFNetworkingTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - operationForUrlRequest:withSuccessHandler:withFailureHandler:

- (void)testOperationForUrlRequestWithSuccessHandlerWithFailureHandlerOnSuccess {
    NSDictionary *successResponse = @{@"success": @"response"};
    void (^successHandler)(id) = ^(id response) {
        XCTAssertEqual(response, successResponse);
    };
    void (^failureHandler)(NSError *) = ^(NSError *error) {
        XCTAssertTrue(NO, @"should not be called");
    };
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];

    id mockAFNetworking = [self expectSuccessfulResponseForUrlRequest:urlRequest withSuccessResponse:successResponse];

    SignalRAFNetworking *networking = [[SignalRAFNetworking alloc] init];
    [networking operationForUrlRequest:urlRequest withSuccessHandler:successHandler withFailureHandler:failureHandler];

    OCMVerifyAll(mockAFNetworking);
}

- (void)testOperationForUrlRequestWithSuccessHandlerWithFailureHandlerOnFailure {
    NSError *errorResponse = [[NSError alloc] init];
    void (^successHandler)(id) = ^(id response) {
        XCTAssertTrue(NO, @"should not be called");
    };
    void (^failureHandler)(NSError *) = ^(NSError *error) {
        XCTAssertEqual(error, errorResponse);
    };
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] init];

    id mockAFNetworking = [self expectFailedResponseForUrlRequest:urlRequest withError:errorResponse];

    SignalRAFNetworking *networking = [[SignalRAFNetworking alloc] init];
    [networking operationForUrlRequest:urlRequest withSuccessHandler:successHandler withFailureHandler:failureHandler];

    OCMVerifyAll(mockAFNetworking);
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
    return mockNetworking;
};

@end
