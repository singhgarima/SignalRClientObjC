//
//  SRConnectionTestHelper.m
//  SignalRClientObjC
//
//  Created by Garima Singh on 11/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import "SRConnectionTestHelper.h"
#import "SRNegotiationResponse.h"
#import "SRConnectionInterface.h"

@implementation SRConnectionTestHelper
@synthesize successfulNegotiationResponse;

- (void)successfulNegotiate:(id <SRConnectionInterface>)connection
             connectionData:(NSString *)connectionData
          completionHandler:(void (^)(SRNegotiationResponse *response, NSError *error))block {
    block(successfulNegotiationResponse, nil);
}

- (void)successfulStart:(id <SRConnectionInterface>)connection
             connectionData:(NSString *)connectionData
          completionHandler:(void (^)(id *response, NSError *error))block {
    block(nil, nil);
}

@end
