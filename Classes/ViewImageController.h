//
//  ViewImageController.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-12-7.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FotoScrollView.h"

@interface ViewImageController : UIViewController
<UIScrollViewDelegate, TapDetectingImageViewDelegate>
{
	NSURL *imageUrl;
	UIScrollView *pagingScrollView;
	
	NSString *baikeid;
}
@property (nonatomic, retain) NSURL *imageUrl;
@property (nonatomic, copy) NSString *baikeid;
@property (nonatomic, retain) IBOutlet UIScrollView *pagingScrollView;

- (void) showImage;
// 隐藏状态栏，导航栏和工具栏
- (void)setFullScreen:(BOOL)hidden;
@end
