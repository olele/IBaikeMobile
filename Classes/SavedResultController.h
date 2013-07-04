//
//  SavedResultController.h
//  //  IBaikeMobile
//
//  Created by 李云天 on 10-9-9.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IBaikeController;

@interface SavedResultController : UIViewController
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
	IBaikeController *iBaikeController;
	
	NSMutableArray *savedResults;
	
	UISearchBar *searchForm;
	UITableView *results;
}
@property (nonatomic, retain) IBOutlet IBaikeController *iBaikeController;

@property(nonatomic,retain) NSMutableArray *savedResults;

@property(nonatomic,retain) IBOutlet UISearchBar *searchForm;
@property (nonatomic, retain) IBOutlet UITableView *results;

- (void) showBaiduBaikePage:(UITableView *)tableView tableViewIndexPath:(NSIndexPath *)indexPath;
- (void) fetchSavedResults;
@end
