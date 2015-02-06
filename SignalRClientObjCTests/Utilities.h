//
//  Utilities.h
//  SignalRClientObjC
//
//  Created by Garima Singh on 2/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import "SignalRNetworking.h"
#import "AFHTTPRequestOperation.h"

@interface TestNetworking : NSObject <SignalRNetworking>

@end

@interface MockCalls : NSObject
@property(strong, nonatomic) NSDictionary *successResponse;
@property(strong, nonatomic) NSError *error;

- (void)successCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)failedCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end

@interface Utilities : NSObject

@end