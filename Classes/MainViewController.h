//
//  MainViewController.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-10-12.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SavedResultController.h"
#import "SearchHistoryController.h"
#import "SearchCategoryController.h"
#import "RecommendedQuestionController.h"
#import "AboutIBaikeController.h"

@interface MainViewController : UIViewController
<UITabBarControllerDelegate>
{
	UITabBarController *tbc;
	SavedResultController *savedResultController;	
	SearchHistoryController *searchHistoryController;
	SearchCategoryController *searchCategoryController;
	RecommendedQuestionController *recommendedQuestionController;
	AboutIBaikeController *aboutIBaikeController;
	
	// 记录当前点击的TAB
	NSUInteger currentTab;
	
}
@property (nonatomic, retain) IBOutlet UITabBarController *tbc;
@property (nonatomic, retain) IBOutlet SavedResultController *savedResultController;	
@property (nonatomic, retain) IBOutlet SearchHistoryController *searchHistoryController;
@property (nonatomic, retain) IBOutlet SearchCategoryController *searchCategoryController;
@property (nonatomic, retain) IBOutlet RecommendedQuestionController *recommendedQuestionController;
@property (nonatomic, retain) IBOutlet AboutIBaikeController *aboutIBaikeController;

@property (nonatomic, assign) NSUInteger currentTab;

@end
