//
//  TestNetworking.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 10/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import "TestNetworking.h"

@implementation TestNetworking
- (NSOperation *)operationForUrlRequest:(NSMutableURLRequest *)urlRequest
                     withSuccessHandler:(void (^)(id response))successHandler
                     withFailureHandler:(void (^)(NSError *error))failureHandler {
    return nil;
}
@end