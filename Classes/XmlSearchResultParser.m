//
//  XmlSearchResultParser.m
//  IHomeWiki
//
//  Created by 李云天 on 10-8-23.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "XmlSearchResultParser.h"
#import "BaiduBaike.h"

static NSUInteger kCountForNotification = 10;

@implementation XmlSearchResultParser

@synthesize delegate, parsedResults, downloadAndParseSource;

+ (NSString *)parserName {
    NSAssert((self != [XmlSearchResultParser class]), @"Class method parserName not valid for abstract base class XmlSearchResultParser");
    return @"Base Class";
}

- (void)start:(NSString *)searchUrl {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    self.parsedResults = [NSMutableArray array];
		
    NSURL *url = [NSURL URLWithString:searchUrl];
	//NSLog(@"%@", url);

	[NSThread detachNewThreadSelector:@selector(downloadAndParse:) toTarget:self withObject:url];
}

- (void)dealloc {
    [parsedResults release];
    [super dealloc];
}

- (void)downloadAndParse:(NSURL *)url {
    NSAssert([self isMemberOfClass:[XmlSearchResultParser class]] == NO, @"Object is of abstract base class XmlSearchResultParser");
}

- (void)downloadStarted {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)downloadEnded {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)parseEnded {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseResults:)] && [parsedResults count] > 0) {
        [self.delegate parser:self didParseResults:self.parsedResults];
    }
    [self.parsedResults removeAllObjects];
	
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parserDidEndParsingData:)]) {
        [self.delegate parserDidEndParsingData:self];
    }
}

- (void)parsedSearchResult:(BaiduBaike *)result {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
    [self.parsedResults addObject:result];
    if (self.parsedResults.count > kCountForNotification) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didParseResults:)]) {
			[self.delegate parser:self didParseResults:self.parsedResults];
        }
        [self.parsedResults removeAllObjects];
    }
}

- (void)parseError:(NSError *)error {
    NSAssert2([NSThread isMainThread], @"%s at line %d called on secondary thread", __FUNCTION__, __LINE__);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [self.delegate parser:self didFailWithError:error];
    }
}

@end
