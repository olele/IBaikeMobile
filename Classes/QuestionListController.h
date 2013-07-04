//
//  QuestionListController.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-29.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XmlSearchResultParser.h"

@class IBaikeController;

@interface QuestionListController : UITableViewController
<XmlSearchResultParserDelegate>
{
	// 页面解析器
	XmlSearchResultParser *parser;

	IBaikeController *iBaikeController;
	
	NSMutableArray *searchResults;
	NSUInteger pageNumber;
	
	NSUInteger currentCategoryId;
	
	// 搜索结果(SearchResult)会生成一个表
	// 搜索分类(SearchCategory)也会生成一个表
	NSString *questionsSource;
	
	// 用于保存搜索历史
	NSString *searchText;
}
@property (nonatomic, retain) XmlSearchResultParser *parser;
@property (nonatomic, retain) IBOutlet IBaikeController *iBaikeController;

@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic, assign) NSUInteger pageNumber;

@property (nonatomic, assign) NSUInteger currentCategoryId;
@property (nonatomic, retain) NSString *questionsSource;

@property (nonatomic, retain) NSString *searchText;

- (void) doParse:(NSString *)url;

// 获取某个分类下的百科
- (void) fetchCategoryQuestions:(NSString *)categoryTitle resultsInPage:(NSUInteger)pn;

- (void) showBaiduBaikePage:(UITableView *)tableView tableViewIndexPath:(NSIndexPath *)indexPath;
- (void) reloadTableData;

// 搜索的结果数组中添加“下一页”、“上一页”
// 搜索结果和搜索分类生成的问题列表时，上一页，下一页的链接不一样
- (void) addNextPreviousItem;
@end
