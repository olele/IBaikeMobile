//
//  DownloadBaike.m
//  IHomeWiki
//
//  Created by 李云天 on 10-8-23.
//  Copyright 2010 iHomeWiki. All rights reserved.
//countOfParsedSearchResults

#import "DownloadAndParseWebPage.h"
#import "IBaikeMobileAppDelegate.h"
#import "BaiduBaike.h"
#import "Constants.h"
#import "BaiduBaikeHelper.h"

@implementation DownloadAndParseWebPage

@synthesize currentString, xmlData, urlConnection;
@synthesize tempResultHref, downloadAndParsePool, currentResult;

#pragma mark -
#pragma mark Parsing support methods
static const NSUInteger kAutoreleasePoolPurgeFrequency = 30;

- (void)finishedCurrentResult: (BaiduBaike *)baike {
	[self performSelectorOnMainThread:@selector(parsedSearchResult:) withObject:baike waitUntilDone:NO];
	baike = nil;
	
	// performSelectorOnMainThread: will retain the object until the selector has been performed
    // setting the local reference to nil ensures that the local reference will be released
    //self.currentResult = nil;
	
    countOfParsedSearchResults++;
    // Periodically purge the autorelease pool. The frequency of this action may need to be tuned according to the 
    // size of the objects being parsed. The goal is to keep the autorelease pool from growing too large, but 
    // taking this action too frequently would be wasteful and reduce performance.
    if (countOfParsedSearchResults == kAutoreleasePoolPurgeFrequency) {
        [downloadAndParsePool release];
        self.downloadAndParsePool = [[NSAutoreleasePool alloc] init];
        countOfParsedSearchResults = 0;
    }
}

- (void)downloadAndParse:(NSURL *)url {
    self.downloadAndParsePool = [[NSAutoreleasePool alloc] init];
    done = NO;
	
    self.xmlData = [NSMutableData data];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url];
    // create the connection with the request and start loading the data
    urlConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    [self performSelectorOnMainThread:@selector(downloadStarted) withObject:nil waitUntilDone:NO];
    if (urlConnection != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (!done);
    }
	
	self.currentResult = nil;
    self.urlConnection = nil;
    [downloadAndParsePool release];
    self.downloadAndParsePool = nil;
}

#pragma mark -
#pragma mark NSURLConnection Delegate methods
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    NSCachedURLResponse *newCachedResponse = cachedResponse;
	
	if (YES)
	{
		return nil;
	}
	
    if ([[[[cachedResponse response] URL] scheme] isEqual:@"https"])
	{
        newCachedResponse = nil;
    }
	else
	{
        NSDictionary *newUserInfo;
		
        newUserInfo = [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"Cached Date"];
		
        newCachedResponse = [[[NSCachedURLResponse alloc] initWithResponse:[cachedResponse response]	
																	  data:[cachedResponse data]
																  userInfo:newUserInfo
															 storagePolicy:[cachedResponse storagePolicy]]
							 autorelease];
    }
	
    return newCachedResponse;
}

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    done = YES;
    [self performSelectorOnMainThread:@selector(parseError:) withObject:error waitUntilDone:NO];
}

// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the downloaded chunk of data.
    [xmlData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self performSelectorOnMainThread:@selector(downloadEnded) withObject:nil waitUntilDone:NO];
	
	if (BaikeSearchResult == [self downloadAndParseSource]) {
		// 处理并显示搜索结果列表
		//NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
		NSString *pageSource = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];

		IBaikeMobileAppDelegate *d = [[UIApplication sharedApplication] delegate];
		NSMutableArray *baikes = [BaiduBaikeHelper fetchBaiduBaikeFromNoAnswer:pageSource useDatabase:d.database];
		[pageSource release];
		
		for (BaiduBaike *baike in baikes) {
			[self finishedCurrentResult:baike];
		}
		
		[self performSelectorOnMainThread:@selector(parseEnded) withObject:nil waitUntilDone:NO];
	}
	else
	{
		//NSData *newXMLData = [pageSource dataUsingEncoding:NSUTF8StringEncoding];
		NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
		parser.delegate = self;
		self.currentString = [NSMutableString string];
		[parser parse];
		
		BaiduBaike *baike = [[[BaiduBaike alloc] init] autorelease];
		baike.question = self.currentString;
		[self.parsedResults addObject:baike];
		[self performSelectorOnMainThread:@selector(parseEnded) withObject:nil waitUntilDone:NO];
		[parser release];		
	}
	
    self.currentString = nil;
    self.xmlData = nil;
    // Set the condition which ends the run loop.
    done = YES; 
}

#pragma mark -
#pragma mark NSXMLParser Parsing Callbacks
// Constants for the XML element names that will be considered during the parse. 
// Declaring these as static constants reduces the number of objects created during the run
// and is less prone to programmer error.
static NSString *kElementNameItem = @"item";
static NSString *kElementNameSubItem = @"subitem";
static NSString *kElementNameTitle = @"title";
static NSString *kElementNameText = @"text";

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *) qualifiedName attributes:(NSDictionary *)attributeDict {
	NSString *idx = [attributeDict objectForKey:@"idx"];
	if (nil == idx)
	{
		idx = @"";
	}
	
	if ([elementName isEqualToString:kElementNameItem]) {	
		storingCharacters = YES;
		
		[currentString appendString:@"<div class=\"b-c-h2\">"];
    }
	
	if ([elementName isEqualToString:kElementNameTitle]) {	
		storingCharacters = YES;
		foundTitle = YES;
		
		if (inSubitem) {
			[currentString appendString:[NSString stringWithFormat:@"<h3 class=\"b-h3-1 b-slvr-bdr2\"><a name=\"l-%@\"></a>", idx]];
		}
		else
		{
			[currentString appendString:[NSString stringWithFormat:@"<h2 class=\"b-h2-1 b-h2-bdr\"><a name=\"l%@\"></a>", idx]];
		}
    }
	
	if ([elementName isEqualToString:kElementNameSubItem]) {	
		storingCharacters = YES;
		
		if (foundTitle)
		{
			inSubitem = YES;
			[currentString appendString:@"<div class=\"b-cc-h2\"><div class=\"b-c-h3\">"];
		}
		else
		{
			// 表示在title之前有个subitem，比如18810.html
		}
    }
	
	if ([elementName isEqualToString:kElementNameText]) {	
		storingCharacters = YES;
		
		if (inSubitem) {
			[currentString appendString:@"<div class=\"b-cc-h3\">"];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if  ([elementName isEqualToString:kElementNameItem]) {
		[currentString appendString:@"</div>"];
		foundTitle = NO;
		inSubitem = NO;
    }
	
	if ([elementName isEqualToString:kElementNameTitle]) {
		if (inSubitem) {
			[currentString appendString:@"</h3>"];
		}
		else
		{
			[currentString appendString:@"</h2>"];
		}
	}
	
	if ([elementName isEqualToString:kElementNameSubItem]) {	
		if (foundTitle)
		{
			inSubitem = NO;
			[currentString appendString:@"</div></div>"];
		}
	}
	
	if ([elementName isEqualToString:kElementNameText]) {	
		if (inSubitem) {
			[currentString appendString:@"</div>"];
		}
	}
	
	storingCharacters = NO;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (storingCharacters) {
		[currentString appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    // Handle errors as appropriate for your application.
	
    //done = YES;
    //[self performSelectorOnMainThread:@selector(parseError:) withObject:parseError waitUntilDone:NO];
}


@end
