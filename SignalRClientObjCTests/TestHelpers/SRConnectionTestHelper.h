//
//  SRConnectionTestHelper.h
//  SignalRClientObjC
//
//  Created by Garima Singh on 11/2/15.
//  Copyright (c) 2015 SignalR. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SRNegotiationResponse;
@protocol SRConnectionInterface;

@interface SRConnectionTestHelper : NSObject

@property(strong, nonatomic, readwrite) SRNegotiationResponse *successfulNegotiationResponse;

- (void)successfulNegotiate:(id <SRConnectionInterface>)connection
             connectionData:(NSString *)connectionData
          completionHandler:(void (^)(SRNegotiationResponse *response, NSError *error))block;

- (void)successfulStart:(id <SRConnectionInterface>)connection connectionData:(NSString *)connectionData completionHandler:(void (^)(id *response, NSError *error))block;
@end
