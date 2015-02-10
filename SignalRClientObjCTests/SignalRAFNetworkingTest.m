//
//  SignalRAFNetworkingTest.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 6/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "TestHelpers.h"
#import "SignalRAFNetworking.h"

@interface SignalRAFNetworkingTest : XCTestCase
@property id successResponse;
@property id error;
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
    self.error = errorResponse;
    AFHTTPRequestOperation *mockNetworking = OCMClassMock([AFHTTPRequestOperation class]);
    OCMStub([(id) mockNetworking alloc]).andReturn(mockNetworking);
    OCMStub([mockNetworking initWithRequest:mockUrlRequest]).andReturn(mockNetworking);
    OCMExpect([mockNetworking setResponseSerializer:[OCMArg any]]);
    OCMExpect([mockNetworking setCompletionBlockWithSuccess:[OCMArg any]
                                                    failure:[OCMArg any]]).
            andCall(self, @selector(failedCompletionHandlerWithSuccess:failure:));
    return mockNetworking;
}

- (id)expectSuccessfulResponseForUrlRequest:(id)mockUrlRequest withSuccessResponse:(NSDictionary *)successResponse {
    self.successResponse = successResponse;
    AFHTTPRequestOperation *mockNetworking = OCMClassMock([AFHTTPRequestOperation class]);
    OCMStub([(id) mockNetworking alloc]).andReturn(mockNetworking);
    OCMStub([mockNetworking initWithRequest:mockUrlRequest]).andReturn(mockNetworking);
    OCMExpect([mockNetworking setResponseSerializer:[OCMArg any]]);

    OCMExpect([mockNetworking setCompletionBlockWithSuccess:[OCMArg any]
                                                    failure:[OCMArg any]]).
            andCall(self, @selector(successCompletionHandlerWithSuccess:failure:));
    return mockNetworking;
};

- (void)successCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    success(nil, self.successResponse);
}

- (void)failedCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    failure(nil, self.error);
}

@end
