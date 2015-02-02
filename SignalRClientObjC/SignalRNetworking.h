//
//  SignalRNetworking.h
//  SignalRClientObjC
//
//  Created by Garima Singh on 2/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import "SRNegotiationResponse.h"

@protocol SignalRNetworking <NSObject>
- (NSOperation *)operationForUrlRequest:(NSMutableURLRequest *)urlRequest
                     withSuccessHandler:(void (^)(id response))successHandler
                     withFailureHandler:(void (^)(NSError *error))failureHandler;
@end