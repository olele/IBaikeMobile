//
//  BaiduBaikeCategory.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-29.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BaiduBaikeCategory : NSObject {
	NSUInteger categoryId;
	NSString *title;
	// 父分类
	NSUInteger parentId;
	// 次级分类的数量
	NSUInteger amount;
	// 下级分类(以“,”分隔)：xx,dd
	NSString *children;
}

@property (nonatomic, assign) NSUInteger categoryId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSUInteger parentId;
@property (nonatomic, assign) NSUInteger amount;
@property (nonatomic, copy) NSString *children;

@end
