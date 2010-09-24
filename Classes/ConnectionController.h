//
//  ConnectionController.h
//  EchoServer
//
//  Created by Sungwon Lee on 10. 9. 25..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"

@interface ConnectionController : NSObject {
	AsyncSocket* m_listenSocket;
	NSMutableArray* m_connectedSockets;
}

- (BOOL)start;
- (BOOL)stop;
- (BOOL)writeData:(NSData*)data;

@end
