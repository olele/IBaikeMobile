//
//  BaiduBaikeCategory.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-29.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "BaiduBaikeCategory.h"


@implementation BaiduBaikeCategory

@synthesize categoryId, title, parentId, amount, children;

- (void)dealloc {
    [title release];
	[children release];
	
    [super dealloc];
}

@end
