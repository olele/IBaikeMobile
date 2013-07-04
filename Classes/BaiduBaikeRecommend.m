//
//  BaiduBaikeRecommend.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-10-8.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "BaiduBaikeRecommend.h"

@implementation BaiduBaikeRecommend

@synthesize recommendId, questions;

- (id)init {
    if (self = [super init]) {
		self.questions = [NSMutableArray array];
    }
    return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"recommendId is: %@, questions is %@", recommendId,questions];
}

- (void)dealloc {
	[recommendId release];
	[questions release];
	
    [super dealloc];
}
@end
