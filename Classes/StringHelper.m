//
//  StringHelper.m
//  IHomeWiki
//
//  Created by 李云天 on 10-8-24.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "StringHelper.h"

@implementation StringHelper

// 将汉字转为为GBK编码，比如科学家 => %BF%C6%D1%A7%BC%D2
+ (NSString *) encodeChineseCharacter2GBK:(NSString *)cc
{
	NSStringEncoding gbkenc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
	NSString *encoded = [cc stringByAddingPercentEscapesUsingEncoding:gbkenc];
	
	return encoded;
}

// 获取某个字符串中，2个指定串之间内容
// 比如：<sytle>*{margin:0;}</style>，获取<sytle>和</style>之间的内容，则返回：*{margin:0;}
+ (NSString *) fetchStrBetweenTwoStr:(NSString *)str firstString:(NSString *)str1 secondString:(NSString *)str2
{
	NSString *gotten = @"";
	
    NSScanner *theScanner = [NSScanner scannerWithString:str];
	// find start of tag
	[theScanner scanUpToString:str1 intoString:NULL] ; 
	if ([theScanner isAtEnd] == NO) {
		[theScanner scanString:str1 intoString: NULL];
		// find end of tag
		[theScanner scanUpToString:str2 intoString:&gotten] ;
	}
	
	//NSLog(@"gotten = %@", gotten);
	return gotten;
}

// 清除网页中的HTML标记
+ (NSString *) stripHtmlTags:(NSString *)html {
    NSScanner *theScanner;
    NSString *text = nil;
	
    theScanner = [NSScanner scannerWithString:html];

	while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<style" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@"</style>" intoString:&text] ;
		
		if (nil == text) {
			break;
		}
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[NSString stringWithFormat:@"%@</style>", text]
											   withString:@""];
    } // while //

	[theScanner setScanLocation:0];
	while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<script" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@"</script>" intoString:&text] ;
		
		if (nil == text) {
			break;
		}
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[NSString stringWithFormat:@"%@</script>", text]
											   withString:@""];
    } // while //
	
	[theScanner setScanLocation:0];
	while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<head" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@"</head>" intoString:&text] ;
		
		if (nil == text) {
			break;
		}
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[NSString stringWithFormat:@"%@</head>", text]
											   withString:@""];
    } // while //
	
	[theScanner setScanLocation:0];
    while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text] ;
		
		if (nil == text) {
			break;
		}
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:
				[NSString stringWithFormat:@"%@>", text]
											   withString:@""];
    } // while //
    
    return html;
} 

// 将指定目录下的文件载入为一个字符串
+ (NSString *) loadFileToString:(NSString *)filename filepath:(NSString *)resourcePath
{
	if (nil == resourcePath) {
		resourcePath = [[NSBundle mainBundle] resourcePath];
	}
	
	NSString *filePath = [resourcePath stringByAppendingPathComponent:filename];
	
	NSString *htmlstring=[[NSString alloc] initWithContentsOfFile:filePath  encoding:NSUTF8StringEncoding error:nil];
	
	return htmlstring;
}

@end
