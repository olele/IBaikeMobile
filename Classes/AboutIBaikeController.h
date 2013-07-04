//
//  AboutIBaikeController.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-15.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutIBaikeController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
	UITableView *aboutTable;
	
	NSMutableDictionary *aboutInfo;
	NSMutableArray *aboutKeys;
	
	NSString *tempUrl;
}

@property(nonatomic,retain) IBOutlet UITableView *aboutTable;

@property(nonatomic,retain) NSMutableDictionary *aboutInfo;
@property(nonatomic,retain) NSMutableArray *aboutKeys;
@property(nonatomic,assign) NSString *tempUrl;

@end
