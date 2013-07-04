//
//  SearchCategoryController.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-28.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBaikeController;
@class QuestionListController;

@interface SearchCategoryController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UISearchBarDelegate>
{
	IBaikeController *iBaikeController;
	QuestionListController *questionListController;
	
	// 当前分类列表的父分类ID
	NSMutableArray *parentIdQueue;
	NSMutableArray *parentTitleQueue;
	
	// 分类
	NSMutableArray *categories;
	
	// 百科
	NSMutableArray *questions;
	
	UISearchBar *searchForm;
	NSString *searchText;
	UITableView *results;
	
	// 当前显示的是分类列表还是百科列表
	BOOL isCategoryTableView;
}
@property (nonatomic, retain) IBOutlet IBaikeController *iBaikeController;
@property (nonatomic, retain) QuestionListController *questionListController;

@property (nonatomic, retain) NSMutableArray *parentIdQueue;
@property (nonatomic, retain) NSMutableArray *parentTitleQueue;
@property (nonatomic, retain) NSMutableArray *categories;
@property (nonatomic, retain) NSMutableArray *questions;

@property (nonatomic, retain) NSString *searchText;
@property (nonatomic, retain) IBOutlet UISearchBar *searchForm;
@property (nonatomic, retain) IBOutlet UITableView *results;

@property (nonatomic, assign) BOOL isCategoryTableView;

// 返回上一级分类
- (IBAction) viewUpCategoryAction;
// 查看下级分类时，添加返回上级的按钮
- (void) addViewUpCategoryButton;
// 移除返回上级按钮
- (void) removeViewUpCategoryButton;
// 列出某个父分类下的所有分类
- (void)fetchCategories:(NSUInteger)parentId;
@end
