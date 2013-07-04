//
//  StringHelper.h
//  IHomeWiki
//
//  Created by 李云天 on 10-8-24.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringHelper : NSObject {
}
// 将汉字转为为GBK编码，比如科学家 => %BF%C6%D1%A7%BC%D2
+ (NSString *) encodeChineseCharacter2GBK:(NSString *)cc;

// 获取某个字符串中，2个指定串之间内容
// 比如：<sytle>*{margin:0;}</style>，获取<sytle>和</style>之间的内容，则返回：*{margin:0;}
+ (NSString *) fetchStrBetweenTwoStr:(NSString *)str firstString:(NSString *)str1 secondString:(NSString *)str2;

// 清除网页中的HTML标记
+ (NSString *) stripHtmlTags:(NSString *)html;

// 将指定目录下的文件载入为一个字符串
+ (NSString *) loadFileToString:(NSString *)filename filepath:(NSString *)resourcePath;

@end
