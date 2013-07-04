//
//  MsgBoxHelper.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-13.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "MsgBoxHelper.h"


@implementation MsgBoxHelper


+ (void) showMsgBoxOK:(NSString *)msg fromDeleate:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"百度百科"
						  message:msg								
						  delegate:delegate
						  cancelButtonTitle:@"确定"
						  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+ (void) showMsgBoxOKCancel:(NSString *)msg fromDeleate:(id)delegate
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"百度百科"
						  message:msg								
						  delegate:delegate
						  cancelButtonTitle:@"取消"
						  otherButtonTitles:@"确定", nil];
	[alert show];
	[alert release];
}

@end
