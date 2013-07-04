//
//  RecommendedQuestionController.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-10-12.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduBaikeRecommend.h"

@class IBaikeController;

@interface RecommendedQuestionController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
	IBaikeController *iBaikeController;
	
	UISearchBar *searchForm;
	UITableView *results;
	
	// 今日推荐
	BaiduBaikeRecommend *baiduBaikeRecommend;
	
	// 是否有网络链接
	BOOL hasInternetConnection;
}
@property (nonatomic, retain) IBOutlet IBaikeController *iBaikeController;

@property(nonatomic,retain) IBOutlet UISearchBar *searchForm;
@property (nonatomic, retain) IBOutlet UITableView *results;

@property (nonatomic, retain) BaiduBaikeRecommend *baiduBaikeRecommend;

@property (nonatomic, assign) BOOL hasInternetConnection;

- (void) showBaiduBaikePage:(UITableView *)tableView tableViewIndexPath:(NSIndexPath *)indexPath;
@end
