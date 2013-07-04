//
//  DownloadAndParseWebPage.h
//  IHomeWiki
//
//  Created by 李云天 on 10-8-23.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlSearchResultParser.h"

@class BaiduBaike;

@interface DownloadAndParseWebPage : XmlSearchResultParser
<NSXMLParserDelegate>
{
    NSMutableString *currentString;
    BOOL storingCharacters;
	BOOL foundTitle;
	BOOL inSubitem;
	
    NSMutableData *xmlData;
    BOOL done;
    NSURLConnection *urlConnection;
    // The number of parsed songs is tracked so that the autorelease pool for the parsing thread can be periodically
    // emptied to keep the memory footprint under control. 
    NSUInteger countOfParsedSearchResults;
    NSAutoreleasePool *downloadAndParsePool;
	
	NSString *tempResultHref;
	
	BaiduBaike *currentResult;
}

@property (nonatomic, retain) NSMutableString *currentString;
@property (nonatomic, retain) NSMutableData *xmlData;
@property (nonatomic, retain) NSURLConnection *urlConnection;

@property (nonatomic, retain) BaiduBaike *currentResult;
@property (nonatomic, retain) NSString *tempResultHref;

// The autorelease pool property is assign because autorelease pools cannot be retained.
@property (nonatomic, assign) NSAutoreleasePool *downloadAndParsePool;

// 下载并解析
- (void)downloadAndParse:(NSURL *)url;
@end
