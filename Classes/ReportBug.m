//
//  ReportBug.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-15.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "ReportBug.h"
#import "Constants.h"

@implementation ReportBug

@synthesize receivedDataFromWeb, viewController;

- (void) reportQuestionId:(NSUInteger)questionId
{
	NSString *url = [NSString stringWithFormat:kReportQuestionURL, questionId];
	
	[self postDataToWeb:url];
}

- (void) postDataToWeb:(NSString *)url
{	
	// Create the request. 
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	// create the connection with the request 
	// and start loading the data 
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData to hold the received data. 
		// receivedData is an instance variable declared elsewhere. 
		self.receivedDataFromWeb = [[NSMutableData data] retain];
	} else { 
		// Inform the user that the connection failed.
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// This method is called when the server has determined that it 
	// has enough information to create the NSURLResponse.
	// It can be called multiple times, for example in the case of a 
	// redirect, so each time we reset the data.
	// receivedData is an instance variable declared elsewhere. 
	[self.receivedDataFromWeb setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	// Append the new data to receivedData. 
	// receivedData is an instance variable declared elsewhere. 
	[self.receivedDataFromWeb appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// release the connection, and the data object 
	[connection release]; 
	// receivedData is declared as a method instance elsewhere 
	[receivedDataFromWeb release];
	// inform the user
	NSLog(@"Connection failed! Error - %@ %@",
		  [error localizedDescription], 
		  [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// do something with the data 
	// receivedData is declared as a method instance elsewhere 
	
	//NSString *data = [[NSString alloc] initWithData:self.receivedDataFromWeb encoding:NSUTF8StringEncoding];
	//NSLog(@"Succeeded! Received data is: %@",data);
	NSLog(@"Succeeded! Received %d bytes of data",[receivedDataFromWeb length]);
	
	// release the connection, and the data object 
	[connection release]; 
	[receivedDataFromWeb release];
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
	NSCachedURLResponse *newCachedResponse = cachedResponse;
	if ([[[[cachedResponse response] URL] scheme] isEqual:@"https"]) {
		newCachedResponse = nil;
	}
	else {
		NSDictionary *newUserInfo; 
		newUserInfo = [NSDictionary dictionaryWithObject:[NSDate date] forKey:@"Cached Date"]; 
		newCachedResponse = [[[NSCachedURLResponse alloc]
							  initWithResponse:[cachedResponse response]
							  data:[cachedResponse data] 
							  userInfo:newUserInfo 
							  storagePolicy:[cachedResponse storagePolicy]]
							 autorelease];
	}
	return newCachedResponse;
}

#pragma mark -
#pragma mark Workaround
// 使用设备默认功能发送邮件
+ (void) launchMailAppOnDevice:(NSString *)subject mailBody:(NSString *)body
{
	NSString *recipients = [NSString stringWithFormat:@"mailto:%@&subject=%@", kReportEmail, subject];
	NSString *_body = [NSString stringWithFormat:@"&body=%@", body];
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, _body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

// 输出调试信息
+ (void) debug:(id)var
{
	if (kDEBUGMODE) {
		NSLog(@"%@",var);
	}
}

- (void)dealloc {
	[receivedDataFromWeb release];
	
	[super dealloc];
}
@end
