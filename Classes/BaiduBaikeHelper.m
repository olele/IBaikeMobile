//
//  BaiduBaikeHelper.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-8.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "BaiduBaikeHelper.h"
#import "TFHpple.h"
#import "BaiduBaike.h"
#import "BaiduBaikeCategory.h"
#import "BaiduBaikeRecommend.h"
#import "MiscHelper.h"
#import "Constants.h"
#import "ReportBug.h"
#import "StringHelper.h"

@implementation BaiduBaikeHelper

// http://xx.com?x=%d  =>  http://xx.com?x=1
+ (NSString *)processSearchTermForURL:(NSUInteger)st searchTerm:(NSString *)search
{
	search = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																 NULL,
																 (CFStringRef)search,
																 NULL,
																 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																 kCFStringEncodingUTF8 );
	
	NSString *searchUrl = [NSString stringWithFormat:kBaiduBaikeSearchURL, st, search];
	[search release];
	
	return searchUrl;
}

+ (NSString *) processSearchTermForResultURL:(NSUInteger)st resultsInPage:(NSUInteger)pn searchTerm:(NSString *) search
{
	search = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																 NULL,
																 (CFStringRef)search,
																 NULL,
																 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																 kCFStringEncodingUTF8 );
	
	NSString *searchUrl = [NSString stringWithFormat:kBaiduBaikeSearchResultURL, st, search, pn];
	[search release];
	
	return searchUrl;
}

// 生成分类下的百科链接
+ (NSString *)processCategoryQuestionsURL:(NSString *)categoryTitle resultsInPage:(NSUInteger)pn
{
	NSString *url = [NSString stringWithFormat:kBaiduBaikeCategoryQuestionsURL, [StringHelper encodeChineseCharacter2GBK:categoryTitle], pn];
	
	return url;
}

// 获取分类下的百科链接
+ (NSMutableArray *) fetchCategoryQuestionsURLs:(NSString *)categoryTitle resultsInPage:(NSUInteger)pn
{
	NSMutableArray *links = [NSMutableArray array];
	NSString *url = [BaiduBaikeHelper processCategoryQuestionsURL:categoryTitle resultsInPage:pn];
#if TARGET_IPHONE_SIMULATOR	
	NSLog(@"%@", url);
#endif
	// baike.baidu.com的页面编码是gb2312
	NSStringEncoding gbkenc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
	NSString *pageSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:gbkenc error:nil];
	//NSLog(@"%@", pageSource);
	@try {
		if (pageSource != nil && ![pageSource isEqualToString:@""]) {
			NSString *str1 = @"<a href=\"/view/";
			NSString *str2 = @"</a>";
			NSString *text = nil;
			
			NSScanner *theScanner = [NSScanner scannerWithString:pageSource];
			
			while (NO == [theScanner isAtEnd]) {
				
				// find start of tag
				[theScanner scanUpToString:str1 intoString:NULL] ; 
				
				// find end of tag
				[theScanner scanUpToString:str2 intoString:&text] ;
				
				// replace the found tag with a space
				//(you can filter multi-spaces out later if you wish)
				/*
				 html = [html stringByReplacingOccurrencesOfString:
				 [ NSString stringWithFormat:@"%@</style>", text]
				 withString:@""];
				 */
				
				if (nil != text && ![text isEqualToString:@""]) {
					text = [text stringByReplacingOccurrencesOfString:str1 withString:@""];
					text = [text stringByReplacingOccurrencesOfString:@".html?fromTaglist\" target=\"_blank\">" withString:@","];
					
					NSArray *l = [text componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
					
					BaiduBaike *_bk = [[BaiduBaike alloc] init];
					_bk.baikeid = [l objectAtIndex:0];
					_bk.baikeurl = [NSString stringWithFormat:kBaiduBaikeViewURL, _bk.baikeid, kBaiduBaikeSTParam];
					_bk.baiketitle = [l objectAtIndex:1];
					
					[links addObject:_bk];
				}
			} // while //
			
			//NSLog(@"%@", links);
			
			
			if ([links count] > 0) {
				[links removeLastObject];
			}
		}
	}
	@catch (NSException * e) {

	}
	

	return links;
}

// 处理余下全文的链接
// <a class="a" href="/question/44088374.html?......">余下全文>></a>
+ (NSString *)stripQuestionMore:(NSString *)html getUrls:(NSMutableArray *)moreUrls
{
	NSString *start = @"<a class=\"a\" href=\"/question/";
	
	NSString *rtn = [html retain];
	
	NSString *text = nil;
	NSString *key = nil;
    NSScanner *theScanner = [NSScanner scannerWithString:rtn];
	
	NSUInteger i = 0;
	while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:start intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@"</a>" intoString:&text] ;
		
		if (nil == text) {
			break;
		}
		
		key = [text stringByReplacingOccurrencesOfString:start withString:[NSString stringWithFormat:@"%@/question/", kBaiduBaikeDomain]];
		key = [key stringByReplacingOccurrencesOfString:@"\">余下全文>>" withString:@""];
		if (![moreUrls containsObject:key]) {
			[moreUrls addObject:key];
		}
		
		// replace the found tag with a space
		rtn = [rtn stringByReplacingOccurrencesOfString:
			   [NSString stringWithFormat:@"%@</a>", text]
											 withString:[NSString stringWithFormat:@"[_余_下_全_文_%d]", i]];
		i++;
    } // while //
	
	return rtn;
}

// 将html的image链接静态化
+ (NSString *)cleanImageTag:(NSString *)html images:(NSMutableArray *)img
{
	html = [html stringByReplacingOccurrencesOfString:@" onload=\"this.parentNode.parentNode.style.width=this.offsetWidth+'px'\"" withString:@""];
	html = [html stringByReplacingOccurrencesOfString:@" onload=\"this.parentNode.parentNode.style.width=this.offsetWidth+&#34;px&#34;\"" withString:@""];

	NSString *str1 = @"<a class=\"b-figr-pic\" href=\"/image/";
	NSString *str2 = @"</a>";
    NSMutableArray *images = [NSMutableArray array];
	
	NSString *text = nil;
	
    NSScanner *theScanner = [NSScanner scannerWithString:html];
	
	while (NO == [theScanner isAtEnd]) {
		
        // find start of tag
        [theScanner scanUpToString:str1 intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:str2 intoString:&text] ;
		
        // replace the found tag with a space
        //(you can filter multi-spaces out later if you wish)
		/*
		 html = [html stringByReplacingOccurrencesOfString:
		 [ NSString stringWithFormat:@"%@</style>", text]
		 withString:@""];
		 */
		
		if (nil != text && ![text isEqualToString:@""]) {
			[images addObject:text];
		}
    } // while //
	
	for(NSString *imageHref in images)
	{
		NSString *image = [StringHelper fetchStrBetweenTwoStr:imageHref firstString:kBaiduBaikeImageURLPath secondString:@"\""];
		[img addObject:image];
		
		image = [kBaiduBaikeImageURLPath stringByAppendingString:image];
		
		NSString *imagename = [StringHelper fetchStrBetweenTwoStr:imageHref firstString:str1 secondString:@"?"];
		NSString *href = [StringHelper fetchStrBetweenTwoStr:imageHref firstString:str1 secondString:@"\""];
		
		if ([image rangeOfString:imagename].location != NSNotFound) {
			html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/image/%@", href] withString:image];
		}
	}

	return html;
}

// 清除搜索结果的描红
// <em>北京银行</em> -> 北京银行
+ (NSString *)stripHighlightRedTag:(NSString *)html
{
	NSString *start = @"<em>";
	//NSString *rtn = [html retain];
	
	NSString *text = nil;
	NSString *key = @"";
    NSScanner *theScanner = [NSScanner scannerWithString:html];
	while (NO == [theScanner isAtEnd]) {
		
        // find start of tag
        [theScanner scanUpToString:start intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:@"</em>" intoString:&text] ;
		
		// text : <em>北京银行
		if (nil == text) {
			break;
		}
		
		key = [text stringByReplacingOccurrencesOfString:start withString:@""];
		// replace the found tag with a space
		html = [html stringByReplacingOccurrencesOfString:
			   [NSString stringWithFormat:@"%@</em>", text]
											 withString:key];		
    } // while //
	
	return html;
}

// 从URL中获取百度百科的百科ID
+ (NSString *)getBaiduBaikeId:(NSString *)url
{
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"%@", url);
#endif
	// http://wapbaike.baidu.com/view/4639735.htm?uid=bd_1284427767_400&amp;st=3&amp;bd_page_type=1&amp;bk_fr=bk_idx_top
	
	return [StringHelper fetchStrBetweenTwoStr:url firstString:@"/view/" secondString:@".htm"];
}

// 下载知道页面并解析
+ (void)doGetQA:(BaiduBaike *)baiduBaike
{
	// 缺省
	baiduBaike.question = @"";
	baiduBaike.comment = @"";
	baiduBaike.isBrief = 1;

	NSString *pageSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:baiduBaike.baikeurl] encoding:NSUTF8StringEncoding error:nil];
	//NSLog(@"%@", baiduBaike.baikeurl);
	
	@try {
		if (pageSource != nil && ![pageSource isEqualToString:@""]) {
			NSMutableArray *images = [NSMutableArray array];
			
			pageSource = [StringHelper fetchStrBetweenTwoStr:pageSource firstString:@"<div class=\"b-cc-h2\">" secondString:@"</div>"];
			baiduBaike.question = [BaiduBaikeHelper cleanImageTag:pageSource images:images];
			baiduBaike.images = images;
			//[images release];
		}
	}
	@catch (NSException * e) {
		// 提交错误的百科id到服务器
		@try {
			ReportBug *bugger = [[[ReportBug alloc] init] autorelease];
			[bugger reportQuestionId:(int) baiduBaike.baikeid];
		}
		@catch (NSException * e) {
			// do nothing
		}
	}
	@finally {
		// do nothing
	}
}

// 保存百科时，处理图片链接，同时将图片保存到系统目录
+ (void)processContentForSavingBaike:(BaiduBaike *) baiduBaike
{
	// 保存图片
	NSMutableArray *images = [NSMutableArray array];
	for (NSString *img in baiduBaike.images) {
		if (![images containsObject:img]) {
			[images addObject:img];
		}
	}
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *imageDir = [[MiscHelper fetchSystemDir] stringByAppendingPathComponent:baiduBaike.baikeid];
	BOOL dirMade = [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:NULL];
	
	if (dirMade) {
		for (NSString *img in images) {		
			NSData *imgdata = [NSData dataWithContentsOfURL:[NSURL URLWithString:[kBaiduBaikeImageURLPath stringByAppendingPathComponent:img]]];
			
			[fileManager createFileAtPath:[imageDir stringByAppendingPathComponent:img] contents:imgdata attributes:nil];
		}
	}
	
	// 将图片URL替换为本地路径
	// http://mt1.baidu.com/timg?wapbaike&amp;quality=60&amp;size=w160&amp;sec=1291788925&amp;di=8987b9a152c28c33f6f493e91bc8ccec&amp;src=http://imgsrc.baidu.com/baike/pic/item/d089b986982c2a7f67096ed9.jpg
	
	NSString *text = nil;
	//NSString *content = baiduBaike.question;
	
    NSScanner *theScanner = [NSScanner scannerWithString:baiduBaike.question];
	
	while ([theScanner isAtEnd] == NO) {
		
        // find start of tag
        [theScanner scanUpToString:@"http://mt1.baidu.com/timg" intoString:NULL] ; 
		
        // find end of tag
        [theScanner scanUpToString:kBaiduBaikeImageURLPath intoString:&text] ;
		
		if (nil == text) {
			break;
		}
		
		NSString *gotten = [NSString stringWithFormat:@"%@%@", text, kBaiduBaikeImageURLPath];
		baiduBaike.question = [baiduBaike.question stringByReplacingOccurrencesOfString:gotten withString:@""];
    } // while //	
	
	// 将内容保存为文件
	NSString *content;
	if (baiduBaike.isBrief == 1) {
		content = [BaiduBaikeHelper makeBaikeWebPage:baiduBaike withFileName:@"baike.html"];
	}
	else {
		content = [BaiduBaikeHelper makeBaikeWebPage:baiduBaike withFileName:@"baikeall.html"];
	}
	content = [content stringByReplacingOccurrencesOfString:@"style.css" withString:@"../style.css"];
	content = [content stringByReplacingOccurrencesOfString:@"<img" withString:@"<img width=\"160\""];

	[fileManager createFileAtPath:[imageDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", baiduBaike.baikeid]] contents:[content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

// 生成HTML页面
+ (NSString *) makeBaikeWebPage:(BaiduBaike *) baiduBaike withFileName:(NSString *)filename
{
	NSString *htmlstring = [StringHelper loadFileToString:filename filepath:[MiscHelper fetchSystemDir]];
	
	NSString *page1 = [htmlstring stringByReplacingOccurrencesOfString:@"{qTitle}" withString:baiduBaike.baiketitle];
	NSString *webpage = [page1 stringByReplacingOccurrencesOfString:@"{qContent}" withString:baiduBaike.question];
	
	return webpage;
}

// 生成HTML页面
+ (NSString *) makeBaikeAllWebPage:(BaiduBaike *) baiduBaike withFileName:(NSString *)filename
{
	NSMutableArray *images = [NSMutableArray array];
	baiduBaike.question = [BaiduBaikeHelper cleanImageTag:baiduBaike.question images:images];
	baiduBaike.images = images;
	//[images release];
	
	NSString *webpage = [BaiduBaikeHelper makeBaikeWebPage:baiduBaike withFileName:filename];
	
	return webpage;
}

// 获取未找到确切答案时返回的的百科列表
+ (NSMutableArray *) fetchBaiduBaikeFromNoAnswer:(NSString *)pageSource useDatabase:(sqlite3 *)db
{	
	NSMutableArray *list = [NSMutableArray array];
	
	@try {
		if (pageSource != nil && ![pageSource isEqualToString:@""]) {
			// <em>北京银行</em> -> 北京银行
			pageSource = [BaiduBaikeHelper stripHighlightRedTag:pageSource];
			
			NSData *data=[pageSource dataUsingEncoding:NSUTF8StringEncoding];
			TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];
			
			
			NSArray *comments = [doc search:@"//div[@id='container']//li//p"];
			NSMutableArray *c = [NSMutableArray array];
			for (TFHppleElement *r in comments) {
				[c addObject:[r content]];
			}

			NSArray * uu = [doc search:@"//div[@id='container']//li//a"];
			NSUInteger i = 0;
			for (TFHppleElement *r in uu) {
				BaiduBaike *_bk = [[BaiduBaike alloc] init];
				_bk.baikeid = [BaiduBaikeHelper getBaiduBaikeId:[r objectForKey:@"href"]];
				_bk.baikeurl = [NSString stringWithFormat:kBaiduBaikeViewURL, _bk.baikeid, kBaiduBaikeSTParam];
				_bk.baiketitle = [r content];
				_bk.comment = [c objectAtIndex:i];
				i++;
				
				[list addObject:_bk];
			}
		}
	}
	@catch (NSException * e) {
		// do nothing
	}
	
	return list;
}

// 获取精彩推荐
+ (BaiduBaikeRecommend *) fetchRecommendBaike:(sqlite3 *)db
{	
	// 先检查是否保存在数据库中
	NSString *recommendId = [MiscHelper getFormatDate:@"yyyyMMdd"];
	
	BaiduBaikeRecommend *recommend = [BaiduBaikeHelper fetchRecommend:recommendId useDatabase:db];
	
	if (nil != recommend.recommendId) {
		return recommend;
	}
	
	NSString *url = [NSString stringWithFormat:@"%@%@%d", kBaiduBaikeDomain, @"/?st=", kBaiduBaikeSTParam];
	NSString *pageSource = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
	@try {
		if (pageSource != nil && ![pageSource isEqualToString:@""]) {
			
			NSData *data=[pageSource dataUsingEncoding:NSUTF8StringEncoding];
			TFHpple *doc = [[TFHpple alloc] initWithHTMLData:data];

			// 推荐标题
			NSMutableArray *t = [NSMutableArray array];
			NSArray * tt = [doc search:@"//div[@id='container']//a//strong"];
			for (TFHppleElement *r in tt) {
				[t addObject:[r content]];
			}
			// 简短介绍
			NSMutableArray *c = [NSMutableArray array];
			NSArray * cc = [doc search:@"//div[@id='container']//a//span"];
			for (TFHppleElement *r in cc) {
				[c addObject:[r content]];
			}
			
			// ID
			NSMutableArray *u = [NSMutableArray array];
			NSArray * uu = [doc search:@"//div[@id='container']//a[@class='entity']"];
			for (TFHppleElement *r in uu) {
				NSString *_u = [r objectForKey:@"href"];
				[u addObject:[BaiduBaikeHelper getBaiduBaikeId:_u]];
			}			
			
			for(NSUInteger i = 0; i < [t count];i++)
			{
				// 有时ID为空。真是ft
				if ([[u objectAtIndex:i] isEqualToString:@""]) {
					continue;
				}
				
				BaiduBaike *_bk = [[BaiduBaike alloc] init];

				_bk.baikeurl = [NSString stringWithFormat:kBaiduBaikeViewURL, [u objectAtIndex:i], kBaiduBaikeSTParam];
				_bk.baikeid = [u objectAtIndex:i];
				_bk.baiketitle = [t objectAtIndex:i];
				_bk.comment = [c objectAtIndex:i];

				[recommend.questions addObject:_bk];
			}

			//[cc release];
			//[tt release];
			//[uu release];
			//[t release];
			//[c release];
			//[u release];
			
			//NSLog(@"%@", recommend.questions);
			
			recommend.recommendId = recommendId;
			//NSLog(@"%@", recommend);
			if ([recommend.questions count] > 0) {		
				// 保存
				[BaiduBaikeHelper saveRecommend:recommend useDatabase:db];
			}	
		}
	}
	@catch (NSException * e) {
		// do nothing
	}
	
	return recommend;
}


// Static variables for compiled SQL queries. This implementation choice is to be able to share a one time
// compilation of each query across all instances of the class. Each time a query is used, variables may be bound
// to it, it will be "stepped", and then reset for the next usage. When the application begins to terminate,
// a class method will be invoked to "finalize" (delete) the compiled queries - this must happen before the database
// can be closed.
static sqlite3_stmt *fetch_statement = nil;
static sqlite3_stmt *fetch_oas_statement = nil;
static sqlite3_stmt *fetch_rqs_statement = nil;
static sqlite3_stmt *fetch_zdl_statement = nil;
static sqlite3_stmt *insert_statement = nil;
static sqlite3_stmt *insert_oas_statement = nil;
static sqlite3_stmt *insert_rqs_statement = nil;
static sqlite3_stmt *insert_history_statement = nil;
static sqlite3_stmt *delete_statement = nil;

// Finalize (delete) all of the SQLite compiled queries.
+ (void)finalizeStatements
{
	if (fetch_statement) sqlite3_finalize(fetch_statement);
	if (fetch_oas_statement) sqlite3_finalize(fetch_oas_statement);
	if (fetch_rqs_statement) sqlite3_finalize(fetch_rqs_statement);
	if (fetch_zdl_statement) sqlite3_finalize(fetch_zdl_statement);
    if (insert_statement) sqlite3_finalize(insert_statement);
	if (insert_oas_statement) sqlite3_finalize(insert_oas_statement);
	if (insert_rqs_statement) sqlite3_finalize(insert_rqs_statement);
	if (insert_oas_statement) sqlite3_finalize(insert_oas_statement);
	if (insert_history_statement) sqlite3_finalize(insert_history_statement);
    if (delete_statement) sqlite3_finalize(delete_statement);
}


// 获取所有保存的知道信息
+ (NSMutableArray *)fetchBaikeList:(sqlite3 *)db
{
	NSMutableArray *baikelist = [NSMutableArray array];
	
	// Compile the query for retrieving BaiduBaike data.
	if (fetch_zdl_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT baikeId, title, comment FROM baidubaike_question ORDER BY dateline DESC";
		if (sqlite3_prepare_v2(db, sql, -1, &fetch_zdl_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
	}
	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	//sqlite3_bind_int(fetch_zdl_statement, 1, [baikeId intValue]);
	
	while (sqlite3_step(fetch_zdl_statement) == SQLITE_ROW)
	{
		NSString *baikeid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_zdl_statement, 0)];
		NSString *title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_zdl_statement, 1)];
		NSString *comment = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_zdl_statement, 2)];

		BaiduBaike *bk = [[BaiduBaike alloc] init];
		bk.baikeid =  baikeid;
		bk.baiketitle = title;
		bk.comment = comment;
		[baikelist addObject:bk];
	}
	
	// Reset the statement for future reuse.
	sqlite3_reset(fetch_zdl_statement);
	
	return baikelist;
}

// 获取知道信息
+ (BaiduBaike *)fetchBaike:(NSString *)baikeId useDatabase:(sqlite3 *)db
{
	BaiduBaike *baiduBaike = [[BaiduBaike alloc] init];
	
	// Compile the query for retrieving BaiduBaike data.
	if (fetch_statement == nil) {
		// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
		// This is a great way to optimize because frequently used queries can be compiled once, then with each
		// use new variable values can be bound to placeholders.
		const char *sql = "SELECT baikeId,baikeUrl,title, question, comment, isBrief FROM baidubaike_question WHERE baikeId = ?";
		if (sqlite3_prepare_v2(db, sql, -1, &fetch_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
	}
	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	sqlite3_bind_int(fetch_statement, 1, [baikeId intValue]);
	
	if (sqlite3_step(fetch_statement) == SQLITE_ROW)
	{
		baiduBaike.baikeid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_statement, 0)];
		baiduBaike.baikeurl = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_statement, 1)];
		baiduBaike.baiketitle = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_statement, 2)];
		baiduBaike.question = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_statement, 3)];
		baiduBaike.comment = [NSString stringWithUTF8String:(char *)sqlite3_column_text(fetch_statement, 4)];
		baiduBaike.isBrief = sqlite3_column_int(fetch_statement, 5);
	}
	else
	{
		baiduBaike.baikeid = @"";
		baiduBaike.baikeurl = @"";
		baiduBaike.baiketitle = @"";
		baiduBaike.question = @"";
		baiduBaike.comment = @"";
		baiduBaike.isBrief = 9;
	}
	// Reset the statement for future reuse.
	sqlite3_reset(fetch_statement);
	
	return baiduBaike;
}

// 保存的知道数量
+ (NSUInteger)fetchBaikeAmount:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	
	const char *sql = "SELECT COUNT(*) AS amount FROM baidubaike_question";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	NSUInteger amount = 0;	
	if (sqlite3_step(statement) == SQLITE_ROW)
	{
		amount = sqlite3_column_int(statement, 0);
	}
	
	sqlite3_finalize(statement);
	
	return amount;
}

// 保存百度百科内容，用于离线查看
+ (void) saveBaike:(BaiduBaike *)baiduBaike useDatabase:(sqlite3 *)db
{
	// 先检查以前是否保存过
	// 保存的是概述，则可以保存全文；反之依然。
	// 保存的是概述，则不能再保存概述了。全文同之
	BaiduBaike *bk = [BaiduBaikeHelper fetchBaike:baiduBaike.baikeid useDatabase:db];
	if (![bk.baikeid isEqualToString:@""] && bk.isBrief == baiduBaike.isBrief) {
		baiduBaike.savedInDB = kSavedBaikeResultInDB;
		return;
	}
	
	// 删除原来保存的
	[BaiduBaikeHelper deleteBaike:bk.baikeid useDatabase:db];
	
	if (insert_statement == nil) {
		static char *sql = "INSERT INTO baidubaike_question(baikeId,baikeUrl,title, question, comment, dateline, isBrief) VALUES(?, ?, ?, ?, ?, ?, ?)";
		if (sqlite3_prepare_v2(db, sql, -1, &insert_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
	}
	
	[BaiduBaikeHelper processContentForSavingBaike:baiduBaike];
	int len = [baiduBaike.question length];
	if (len > 30) {
		len = 30;
	}
	baiduBaike.comment = [[StringHelper stripHtmlTags:baiduBaike.question] substringToIndex:len];
	baiduBaike.comment = [baiduBaike.comment stringByReplacingOccurrencesOfString:@"百科名片" withString:@""];
	
    sqlite3_bind_text(insert_statement, 1, [baiduBaike.baikeid UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 2, [baiduBaike.baikeurl UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 3, [baiduBaike.baiketitle UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 4, [baiduBaike.question UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(insert_statement, 5, [baiduBaike.comment UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(insert_statement, 6, [MiscHelper getUnixTimestamp]);
	sqlite3_bind_int(insert_statement, 7, baiduBaike.isBrief);
	
	int success = sqlite3_step(insert_statement);
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(insert_statement);
    if (success == SQLITE_ERROR) {
		baiduBaike.savedInDB = kSavedBaikeResultNO;
        NSAssert1(0, @"Error: failed to insert into the database with message '%s'.", sqlite3_errmsg(db));
    } else {
        // SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
        // in the database. To access this functionality, the table should have a column declared of type 
        // "INTEGER PRIMARY KEY"
        //primaryKey = sqlite3_last_insert_rowid(db);
		baiduBaike.savedInDB = kSavedBaikeResultYES;
    }
}

//  删除某条知道
+ (void)deleteBaike:(NSString *)baikeId useDatabase:(sqlite3 *)db
{
	if (nil == baikeId || [baikeId isEqualToString:@""]) {
		return;
	}
	
    // Compile the delete statement if needed.
	if (delete_statement == nil) {
		const char *sql = "DELETE FROM baidubaike_question WHERE baikeId=?";
		if (sqlite3_prepare_v2(db, sql, -1, &delete_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
	}
	
    // Bind the primary key variable.
	sqlite3_bind_text(delete_statement, 1, [baikeId UTF8String], -1, SQLITE_TRANSIENT);
    //sqlite3_bind_int(statement, 1, primaryKey);
    // Execute the query.
    int success = sqlite3_step(delete_statement);
    // Reset the statement for future use.
    sqlite3_reset(delete_statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to deleteBaike with message '%s'.", sqlite3_errmsg(db));
    }
}

// 清空搜索历史
+ (void)clearSearchHistory:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	
	const char *sql = "DELETE FROM baidubaike_searchhistory";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
    // Execute the query.
    int success = sqlite3_step(statement);
    // Finalize the statement.
    sqlite3_finalize(statement);
    // Handle errors.
    if (success != SQLITE_DONE) {
        NSAssert1(0, @"Error: failed to delete from database with message '%s'.", sqlite3_errmsg(db));
    }
}

// 保存或者更新搜索历史
+ (void)saveOrUpdateSearchHistory:(NSString *)searchText useDatabase:(sqlite3 *)db
{	
	@try {
		NSUInteger historyId = [BaiduBaikeHelper isExistSearchHistory:searchText useDatabase:db];
		
		if (0 == historyId) {
			[BaiduBaikeHelper saveSearchHistory:searchText useDatabase:db];
		}
		else
		{
			[BaiduBaikeHelper updateSearchHistory:historyId useDatabase:db];
		}
	}
	@catch (NSException * e) {
		NSLog(@"%@", [e description]);
	}
}

// 保存搜索历史
+ (void)saveSearchHistory:(NSString *)searchText useDatabase:(sqlite3 *)db
{	
	if ([searchText length] == 0) {
		return;
	}
	
	if (insert_history_statement == nil) {
		static char *sql = "INSERT INTO baidubaike_searchhistory(historyId,searchText,dateline, searchDay) VALUES(NULL, ?, ?, ?)";
		if (sqlite3_prepare_v2(db, sql, -1, &insert_history_statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(insert_history_statement, 1, [searchText UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_int(insert_history_statement, 2, [MiscHelper getUnixTimestamp]);
	sqlite3_bind_text(insert_history_statement, 3, [[MiscHelper getFormatDate:@"yyyy-MM-dd"] UTF8String], -1, SQLITE_TRANSIENT);	
	
	int success = sqlite3_step(insert_history_statement);
	sqlite3_reset(insert_history_statement);
	
	if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to saveSearchHistory with message '%s'.", sqlite3_errmsg(db));
	}
}

// 搜索历史数量
+ (NSUInteger)fetchSearchHistoryAmount:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	
	const char *sql = "SELECT COUNT(*) AS amount FROM baidubaike_searchhistory";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	NSUInteger amount = 0;	
	if (sqlite3_step(statement) == SQLITE_ROW)
	{
		amount = sqlite3_column_int(statement, 0);
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	return amount;
}

// 获取搜索历史
+ (NSMutableArray *)fetchSearchHistoryList:(sqlite3 *)db
{
	NSMutableArray *history = [NSMutableArray array];
	
	sqlite3_stmt *statement;
	
	// Compile the query for retrieving BaiduBaike data.
	// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
	// This is a great way to optimize because frequently used queries can be compiled once, then with each
	// use new variable values can be bound to placeholders.
	const char *sql = "SELECT historyId, searchText, searchDay FROM baidubaike_searchhistory ORDER BY dateline DESC";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	//sqlite3_bind_int(statement, 1, [baikeId intValue]);
	
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		NSString *historyId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		NSString *searchText = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
		NSString *searchDay = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
		
		NSArray *_h = [NSArray arrayWithObjects:historyId, searchText, searchDay, nil];
		
		[history addObject:_h];
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	return history;
}

// 当前搜索是否有历史？
// 主要用于搜索历史保存，有的话，则将远搜索日期改变为当前搜索日期
+ (NSUInteger)isExistSearchHistory:(NSString *)searchText useDatabase:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	
	// Compile the query for retrieving BaiduBaike data.
	// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
	// This is a great way to optimize because frequently used queries can be compiled once, then with each
	// use new variable values can be bound to placeholders.
	const char *sql = "SELECT historyId FROM baidubaike_searchhistory WHERE searchText = ?";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	sqlite3_bind_text(statement, 1, [searchText UTF8String], -1, SQLITE_TRANSIENT);	
	
	NSUInteger historyId = 0;	
	if (sqlite3_step(statement) == SQLITE_ROW)
	{
		//historyId = (int) [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		historyId = sqlite3_column_int(statement, 0);
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	return historyId;
}

// 更新搜索历史
+ (void)updateSearchHistory:(NSUInteger)historyId useDatabase:(sqlite3 *)db
{
	if (0 == historyId) {
		return;
	}
	
	sqlite3_stmt *statement;
	
	static char *sql = "UPDATE baidubaike_searchhistory SET dateline=?, searchDay=? WHERE historyId=?";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	sqlite3_bind_int(statement, 1, [MiscHelper getUnixTimestamp]);
	sqlite3_bind_text(statement, 2, [[MiscHelper getFormatDate:@"yyyy-MM-dd"] UTF8String], -1, SQLITE_TRANSIENT);	
	sqlite3_bind_int(statement, 3, historyId);	
	
	int success = sqlite3_step(statement);
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to updateSearchHistory with message '%s'.", sqlite3_errmsg(db));
	}
}

// 获取分类信息
+ (BaiduBaikeCategory *)fetchCategory:(NSUInteger)categoryId useDatabase:(sqlite3 *)db
{
	BaiduBaikeCategory *category = [[BaiduBaikeCategory alloc] init];
	
	sqlite3_stmt *statement;
	
	// Compile the query for retrieving BaiduBaike data.
	// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
	// This is a great way to optimize because frequently used queries can be compiled once, then with each
	// use new variable values can be bound to placeholders.
	const char *sql = "SELECT * FROM baidubaike_category WHERE categoryId = ?";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	sqlite3_bind_int(statement, 1, categoryId);
	
	while (sqlite3_step(statement) == SQLITE_ROW)
	{		
		category.categoryId = sqlite3_column_int(statement, 0);
		category.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
		category.parentId = sqlite3_column_int(statement, 2);
		category.amount = sqlite3_column_int(statement, 3);
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	return category;
}

+ (NSMutableArray *)fetchCategories:(NSUInteger)parentId useDatabase:(sqlite3 *)db
{
	NSMutableArray *categories = [NSMutableArray array];
	
	sqlite3_stmt *statement;
	
	// Compile the query for retrieving BaiduBaike data.
	// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
	// This is a great way to optimize because frequently used queries can be compiled once, then with each
	// use new variable values can be bound to placeholders.
	const char *sql = "SELECT * FROM baidubaike_category WHERE parentId = ?";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	sqlite3_bind_int(statement, 1, parentId);
	
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		BaiduBaikeCategory *category = [[BaiduBaikeCategory alloc] init];
		
		category.categoryId = sqlite3_column_int(statement, 0);
		category.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
		category.parentId = sqlite3_column_int(statement, 2);
		int amount = sqlite3_column_int(statement, 3);
		category.amount = amount;
		//NSLog(@"%@ => %i", category.title, amount);
		
		if (amount != 0)
		{
			NSMutableArray *titles = [BaiduBaikeHelper fetchCategoryTitles:category.categoryId useDatabase:db];
			category.children = [titles componentsJoinedByString:@", "];		}
		
		[categories addObject:category];
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	return categories;
}

+ (NSMutableArray *)fetchCategoryTitles:(NSUInteger)parentId useDatabase:(sqlite3 *)db
{
	NSMutableArray *titles = [NSMutableArray array];
	
	sqlite3_stmt *statement;
	
	// Compile the query for retrieving BaiduBaike data.
	// Note the '?' at the end of the query. This is a parameter which can be replaced by a bound variable.
	// This is a great way to optimize because frequently used queries can be compiled once, then with each
	// use new variable values can be bound to placeholders.
	const char *sql = "SELECT title FROM baidubaike_category WHERE parentId = ?";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}
	
	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	sqlite3_bind_int(statement, 1, parentId);
	
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		[titles addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)]];
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	return titles;
}


// 保存精彩推荐
+ (void )saveRecommend:(BaiduBaikeRecommend *)recommend useDatabase:(sqlite3 *)db
{
	sqlite3_stmt *statement;
	static char *sql = "INSERT INTO baidubaike_recommend(recommendId, baikeId, title, comment) VALUES(?,?,?,?)";
	
	for (BaiduBaike *_bk in recommend.questions) {

		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
		}
		
		sqlite3_bind_text(statement, 1, [recommend.recommendId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 2, [_bk.baikeid UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 3, [_bk.baiketitle UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 4, [_bk.comment UTF8String], -1, SQLITE_TRANSIENT);
		
		int success = sqlite3_step(statement);
		// Finalize the statement.
		sqlite3_reset(statement);
		
		if (success == SQLITE_ERROR) {
			NSAssert1(0, @"Error: failed to updateSearchHistory with message '%s'.", sqlite3_errmsg(db));
		}
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
}

// 精彩推荐
+ (BaiduBaikeRecommend *) fetchRecommend:(NSString *)recommendId useDatabase:(sqlite3 *)db
{
	BaiduBaikeRecommend *recommend = [[BaiduBaikeRecommend alloc] init];
	
	sqlite3_stmt *statement;

	const char *sql = "SELECT baikeId, title, comment FROM baidubaike_recommend WHERE recommendId = ?";
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(db));
	}

	// For this query, we bind the primary key to the first (and only) placeholder in the statement.
	// Note that the parameters are numbered from 1, not from 0.
	sqlite3_bind_text(statement, 1, [recommendId UTF8String], -1, SQLITE_TRANSIENT);
	
	while (sqlite3_step(statement) == SQLITE_ROW)
	{
		recommend.recommendId = recommendId;
			
		NSString *baikeId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
		NSString *title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
		NSString *comment = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
		
		BaiduBaike *_bk = [[BaiduBaike alloc] init];

		_bk.baikeid = baikeId;
		_bk.baikeurl = [NSString stringWithFormat:kBaiduBaikeViewURL, baikeId, kBaiduBaikeSTParam];
		_bk.baiketitle = title;
		_bk.comment = comment;
		
		[recommend.questions addObject:_bk];
	}
	
	// Finalize the statement.
	sqlite3_finalize(statement);
	
	//[recommend release];
	return recommend;
}

@end
