/*
 *  CCVPacketHeader.h
 *  ControlCV
 *
 *  Created by Sungwon Lee on 10. 10. 5..
 *  Copyright 2010 Seoul National Univ. All rights reserved.
 *
 */

#ifndef _CCVPACKETHEADER_H_
#define _CCVPACKETHEADER_H_

typedef struct _CCVPacketHeader
{
	short int iHeaderSize;
	short int iVersion;
	int iContentSize;
} CCVPacketHeader;

#endif