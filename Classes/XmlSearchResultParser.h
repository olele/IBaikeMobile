//
//  XmlSearchResultParser.h
//  IHomeWiki
//
//  Created by 李云天 on 10-8-23.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@class XmlSearchResultParser, BaiduBaike;

// Protocol for the parser to communicate with its delegate.
@protocol XmlSearchResultParserDelegate <NSObject>

@optional
// Called by the parser when parsing is finished.
- (void)parserDidEndParsingData:(XmlSearchResultParser *)parser;
// Called by the parser in the case of an error.
- (void)parser:(XmlSearchResultParser *)parser didFailWithError:(NSError *)error;
// Called by the parser when one or more results have been parsed. This method may be called multiple times.
- (void)parser:(XmlSearchResultParser *)parser didParseResults:(NSArray *)results;

@end


@interface XmlSearchResultParser : NSObject {
    id <XmlSearchResultParserDelegate> delegate;
    NSMutableArray *parsedResults;

	DownloadAndParseSource downloadAndParseSource;
}
@property (nonatomic, assign) id <XmlSearchResultParserDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *parsedResults;
@property (nonatomic, assign) DownloadAndParseSource downloadAndParseSource;

+ (NSString *)parserName;

- (void)start:(NSString *)searchUrl;

// Subclasses must implement this method. It will be invoked on a secondary thread to keep the application responsive.
// Although NSURLConnection is inherently asynchronous, the parsing can be quite CPU intensive on the device, so
// the user interface can be kept responsive by moving that work off the main thread. This does create additional
// complexity, as any code which interacts with the UI must then do so in a thread-safe manner.
- (void)downloadAndParse:(NSURL *)url;

// Subclasses should invoke these methods and let the superclass manage communication with the delegate.
// Each of these methods must be invoked on the main thread.
- (void)downloadStarted;
- (void)downloadEnded;
- (void)parseEnded;
- (void)parsedSearchResult:(BaiduBaike *)result;
- (void)parseError:(NSError *)error;


@end
