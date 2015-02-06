//
//  Utilities.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 2/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utilities.h"

@implementation TestNetworking
- (NSOperation *)operationForUrlRequest:(NSMutableURLRequest *)urlRequest
                     withSuccessHandler:(void (^)(SRNegotiationResponse *response))successHandler
                     withFailureHandler:(void (^)(NSError *error))failureHandler {
    return nil;
}

@end


@implementation MockCalls

- (void)successCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    success(nil, _successResponse);
}

- (void)failedCompletionHandlerWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    failure(nil, _error);
}
@end

@implementation Utilities


@end