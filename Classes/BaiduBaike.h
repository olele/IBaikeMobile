//
//  BaiduBaike.h
//  IHomeWiki
//
//  Created by 李云天 on 10-8-23.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaiduBaike : NSObject {
    NSString *baiketitle;
    NSString *baikeurl;
	NSString *baikeid;

	// 内容
	NSString *question;
	// 简短介绍
	NSString *comment;
	// 是全文还是简述
	NSUInteger isBrief;
	// HTML源码
	NSString *pagesource;
	
	// 百科中的图片
	NSMutableArray *images;
	
	NSUInteger savedInDB;
}

@property (nonatomic, copy) NSString *baiketitle;
@property (nonatomic, copy) NSString *baikeurl;
@property (nonatomic, copy) NSString *baikeid;
@property (nonatomic, assign) NSUInteger isBrief;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *pagesource;
@property (nonatomic, retain) NSMutableArray *images;

// 将资料保存到数据库后，返回结果
// 1：保存成功
// 2：保存失败
// 9：已经保存过了
@property (nonatomic) NSUInteger savedInDB;
@end
