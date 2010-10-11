//
//  ConnectionController.m
//  EchoServer
//
//  Created by Sungwon Lee on 10. 9. 25..
//  Copyright 2010 Seoul National Univ. All rights reserved.
//

#import "ConnectionController.h"
#import "CCVPacketHeader.h"

@implementation ConnectionController

- (id)initWithDelegate:(id)delegate
{
	if( ( self = [super init] ) )
	{
		m_listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
		m_connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
		m_delegate = delegate;
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
	[m_listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
	
	int iPort = 4098;
	
	NSError* error = nil;
	if( ![m_listenSocket acceptOnPort:iPort error:&error] )
	{
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Connection error" message:@"Fail to listen socket" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
	
	return TRUE;
}

- (BOOL)stop
{
	[m_listenSocket disconnect];
	for( AsyncSocket* socket in m_connectedSockets )
	{
		[socket disconnect];
	}
	
	return TRUE;
}

- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
	[m_connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSString *welcomeMsg = @"ctrlcv. connected.\r\n";
	NSData *welcomeData = [welcomeMsg dataUsingEncoding:NSUTF8StringEncoding];
	
	[sock writeData:welcomeData withTimeout:-1 tag:1];
	
	// initial read
	[sock readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:0];
}

- (BOOL)writeDataToAll:(NSData*)data
{
	CCVPacketHeader header;
	header.iHeaderSize = sizeof( header );
	header.iVersion = 0x0100;
	header.iContentSize = [data length];
	
	NSMutableData* sendData = [NSMutableData dataWithBytes:&header length:sizeof( CCVPacketHeader )];
	[sendData appendData:data];
	
	for( AsyncSocket* socket in m_connectedSockets )
	{
		[socket writeData:sendData withTimeout:-1 tag:0];
	}
	
	return YES;
}

/*
- (BOOL)writeData:(NSData*)data
{
	if( ![m_listenSocket isConnected] )
	{
		return FALSE;
	}
	
	[m_listenSocket writeData:data withTimeout:-1 tag:1];
	
	return TRUE;
}*/

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	//[sock readDataToData:[AsyncSocket CRLFData] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
	NSData *strData = [data subdataWithRange:NSMakeRange(0, [data length] - 2)];
	NSString *msg = [[[NSString alloc] initWithData:strData encoding:NSUTF8StringEncoding] autorelease];
	if(msg)
	{
		NSLog( @"%@", msg );
	}
	else
	{
		NSLog( @"Error converting received data into UTF-8 String" );
	}
	
	// call delegate function
	[m_delegate onReadData:data];
	
	// do response
	// NSData* response = [@"ctrlcv. Add OK.\r\n" dataUsingEncoding:NSUTF8StringEncoding];
	// [sock writeData:response withTimeout:-1 tag:1];
	
	// read again
	[sock readDataToData:[AsyncSocket ZeroData] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket*)sock willDisconnectWithError:(NSError*)error
{
	if( error )
	{
		NSLog( @"Something went wrong while connecting" );
	}
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
	[m_connectedSockets removeObject:sock];
}



@end
