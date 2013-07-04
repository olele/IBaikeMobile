//
//  SearchHistoryController.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-9.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBaikeController;
@class QuestionListController;

@interface SearchHistoryController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UISearchBarDelegate, UINavigationControllerDelegate>
{
	IBaikeController *iBaikeController;
	QuestionListController *questionListController;

	NSMutableDictionary *searchHistory;
	NSArray *searchHistoryKeys;
	
	UISearchBar *searchForm;
	NSString *searchText;
	UITableView *results;
}
@property (nonatomic, retain) IBOutlet IBaikeController *iBaikeController;
@property (nonatomic, retain) QuestionListController *questionListController;

@property (nonatomic, retain) NSMutableDictionary *searchHistory;
@property (nonatomic, retain) NSArray *searchHistoryKeys;

@property (nonatomic, retain) IBOutlet UISearchBar *searchForm;
@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) IBOutlet UITableView *results;

// 历史
- (void) fetchSearchHistory;
// 搜索
- (void) doSearchTerm:(NSString *)searchTerm;
@end
