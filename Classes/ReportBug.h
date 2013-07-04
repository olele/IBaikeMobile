//
//  ReportBug.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-15.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportBug : NSObject
{
	NSMutableData *receivedDataFromWeb;
	
	// 用于发送邮件
	UIViewController *viewController;
}

@property (nonatomic, retain) NSMutableData *receivedDataFromWeb;
@property (nonatomic, retain) UIViewController *viewController;

- (void) reportQuestionId:(NSUInteger)questionId;
- (void) postDataToWeb:(NSString *)url;

// 使用设备默认功能发送邮件
+ (void) launchMailAppOnDevice:(NSString *)subject mailBody:(NSString *)body;

// 输出调试信息
+ (void) debug:(id)var;
@end
