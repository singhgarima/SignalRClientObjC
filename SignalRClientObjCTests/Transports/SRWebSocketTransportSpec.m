#import <Specta/Specta.h>
#import <OCMock/OCMock.h>

#define EXP_SHORTHAND
#import "Expecta.h"

#import "SRWebSocket.h"
#import "SRWebSocketTransport.h"
#import "SRConnection.h"
#import "SRWebSocketConnectionInfo.h"

SpecBegin(SRWebSocketTransport)

    describe(@"send:data:(connectionData:completionHandler:", ^{
        it(@"should send data using websocket", ^{
            id mockWebSocket = OCMClassMock([SRWebSocket class]);
            OCMExpect([mockWebSocket send:@"someData"]);

            SRWebSocketTransport *transport = [[SRWebSocketTransport alloc] init];
            [transport setValue:mockWebSocket forKey:@"webSocket"];
            [transport send:nil data:@"someData" connectionData:nil completionHandler:nil];

            OCMVerifyAll(mockWebSocket);
        });
    });
    
    describe(@"name", ^{
        it(@"should return name as webSockets", ^{
            SRWebSocketTransport *transport = [[SRWebSocketTransport alloc] init];
            
            expect([transport name]).to.equal(@"webSockets");
        });
    });
    
    describe(@"supportsKeepAlive", ^{
        it(@"should support keep alive", ^{
            SRWebSocketTransport *transport = [[SRWebSocketTransport alloc] init];
            
            expect([transport supportsKeepAlive]).to.equal(YES);
        });
    });
    
    describe(@"start:connectionData:completionHandler:", ^{
        it(@"should ", ^{
            NSString *connectionData = @"something";
            NSString *baseURL = @"https://www.mySignalRServerURL.com/";
            NSURL *connectURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", baseURL, @"connect"]];
            id mockConnection = OCMClassMock([SRConnection class]);
            id mockConnectionInfo = OCMClassMock([SRWebSocketConnectionInfo class]);
            id mockConnectURLRequest = OCMClassMock([NSMutableURLRequest class]);
            id mockWebSocket = OCMClassMock([SRWebSocket class]);
            
            OCMStub([mockConnectURLRequest requestWithURL:[OCMArg checkWithBlock:^(NSURL *url){
                expect([url absoluteString]).to.equal([NSString stringWithFormat:@"%@%@", baseURL, @"connect?transport=webSockets&connectionToken=token&connectionData=something"]);
                return YES;
            }]]).andReturn(mockConnectURLRequest); // url with connect
            OCMStub([mockConnectURLRequest URL]).andReturn(connectURL);
            OCMStub([mockWebSocket alloc]).andReturn(mockWebSocket);
            OCMStub([mockWebSocket initWithURLRequest:[OCMArg any]]).andReturn(mockWebSocket);
            OCMStub([mockConnection url]).andReturn(baseURL);
            OCMStub([mockConnection connectionToken]).andReturn(@"token");
            OCMStub([mockConnectionInfo connection]).andReturn(mockConnection);
            OCMExpect([mockWebSocket setDelegate:[OCMArg any]]);
            OCMExpect([mockWebSocket open]);
            OCMStub([mockConnectionInfo initConnection:mockConnection data:connectionData]).andReturn(mockConnectionInfo);
            OCMExpect([mockConnection prepareRequest:mockConnectURLRequest]);

            SRWebSocketTransport *transport = [[SRWebSocketTransport alloc] init];
            [transport start:mockConnection connectionData:connectionData completionHandler:nil];
            
            OCMVerifyAll(mockConnection);
            OCMVerifyAll(mockConnectionInfo);
            OCMVerifyAll(mockWebSocket);
            
        });
    });

SpecEnd