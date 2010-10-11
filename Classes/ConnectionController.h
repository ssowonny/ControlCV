//
//  ConnectionController.h
//  EchoServer
//
//  Created by Sungwon Lee on 10. 9. 25..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@protocol ConnectionDelegate

@required
- (void)onReadData:(NSData*)data;

@end

@interface ConnectionController : NSObject {
	AsyncSocket* m_listenSocket;
	NSMutableArray* m_connectedSockets;
	id m_delegate;
}

- (BOOL)start;
- (BOOL)stop;
- (BOOL)writeDataToAll:(NSData*)data;
//- (BOOL)writeData:(NSData*)data;

@end
