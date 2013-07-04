//
//  BaiduBaike.m
//  IHomeWiki
//
//  Created by 李云天 on 10-8-23.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "BaiduBaike.h"


@implementation BaiduBaike

@synthesize baiketitle, baikeurl, baikeid, isBrief, images, savedInDB;

@synthesize question, comment, pagesource;

- (NSString *)description
{
	return [NSString stringWithFormat:@"title is: %@, url is %@, id is %@, content is %@, comment is %@, saved is %d", baiketitle,baikeurl, baikeid, question, comment, savedInDB];
}

- (void)dealloc {
    [baiketitle release];
    [baikeurl release];
	[baikeid release];
	
	[question release];
	[comment release];
	[pagesource release];
	
	[images release];
	
    [super dealloc];
}

@end
