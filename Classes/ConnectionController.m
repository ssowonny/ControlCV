//
//  ConnectionController.m
//  EchoServer
//
//  Created by Sungwon Lee on 10. 9. 25..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import "ConnectionController.h"


@implementation ConnectionController

- (id)init
{
	if( ( self = [super init] ) )
	{
		m_listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
		m_connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
	}
	
	return self;
}

- (void)dealloc
{
	[m_listenSocket release];
	[m_connectedSockets release];
	
	[super dealloc];
}

- (BOOL)start
{
	NSError* error = [[[NSError alloc] init] autorelease];
	if( ![m_listenSocket connectToHost:@"127.0.0.1" onPort:4098 error:&error] )
	{
		NSLog( @"Fail to connect." );
		return FALSE;
	}
	
	return TRUE;
}

- (BOOL)stop
{
	return TRUE;
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	//NSData* data = [@"Hello world" dataUsingEncoding:NSUTF8StringEncoding];
	//[sock writeData:data withTimeout:-1 tag:1];
	//[sock disconnect];
	[sock readDataWithTimeout:-1 tag:1];
}

- (BOOL)writeData:(NSData*)data
{
	if( ![m_listenSocket isConnected] )
	{
		return FALSE;
	}
	
	[m_listenSocket writeData:data withTimeout:-1 tag:1];
	
	return TRUE;
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		//[self logMessage:msg];
		NSLog( msg );
	}
	else
	{
		NSLog( @"Error converting received data into UTF-8 String" );
		//[self logError:@"Error converting received data into UTF-8 String"];
	}
	
	// Even if we were unable to write the incoming data to the log,
	// we're still going to echo it back to the client.
	NSString *welcomeMsg = @"Welcome to the AsyncSocket Echo Server\r\n";
	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
	
	[sock writeData:welcomeData withTimeout:-1 tag:1];
}

- (void)onSocket:(AsyncSocket*)sock willDisconnectWithError:(NSError*)error
{
	if( error )
	{
		NSLog( @"Something went wrong while connecting" );
		
	}
}


@end
