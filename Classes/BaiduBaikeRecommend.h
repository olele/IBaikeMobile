//
//  BaiduBaikeRecommend.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-10-8.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaiduBaikeRecommend : NSObject {
	NSString *recommendId;
	NSMutableArray *questions;
}
@property (nonatomic, copy) NSString *recommendId;
@property (nonatomic, retain) NSMutableArray *questions;

@end
