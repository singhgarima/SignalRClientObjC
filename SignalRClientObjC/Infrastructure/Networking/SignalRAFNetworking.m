//
//  SignalRAFNetworking.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 2/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import "SignalRAFNetworking.h"

@implementation SignalRAFNetworking : NSObject

- (NSOperation *)operationForUrlRequest:(NSMutableURLRequest *)urlRequest
                     withSuccessHandler:(void (^)(id response))successHandler
                     withFailureHandler:(void (^)(NSError *error))failureHandler {
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(successHandler) {
            successHandler(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(failureHandler) {
            failureHandler(error);
        }
    }];
    return operation;
}

@end