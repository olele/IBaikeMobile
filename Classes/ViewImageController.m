    //
//  ViewImageController.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-12-7.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "ViewImageController.h"
#import "StringHelper.h"
#import "Constants.h"
#import "MiscHelper.h"
#import "IBaikeMobileAppDelegate.h"

@interface ViewImageController (UtilityMethods)
- (CGRect)zoomRectForScale:(FotoScrollView *)aview zoomScale:(float)scale withCenter:(CGPoint)center;
@end

@implementation ViewImageController

@synthesize imageUrl, baikeid, pagingScrollView;

// 隐藏状态栏，导航栏和工具栏
- (void)setFullScreen:(BOOL)hidden
{
	[[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
	[self.navigationController setNavigationBarHidden:hidden animated:YES];
}

- (void) showImage
{
	[self setWantsFullScreenLayout:YES];
	[self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	FotoScrollView *page;
	NSArray *p = [pagingScrollView subviews];
	if ([p count] == 0) {
		page = [[[FotoScrollView alloc] init] autorelease];
		[page setTapDelegate:self];
	}
	else {
		page = [p objectAtIndex:0];
	}
	
    page.frame = pagingScrollView.bounds;
	
	UIImage *image;
	if ([self.baikeid isEqualToString:@""]) {
		NSData *imgdata = [NSData dataWithContentsOfURL:self.imageUrl];
		image = [UIImage imageWithData:imgdata];		
	}
	else {
		NSString *imagename = [[self.imageUrl absoluteString] stringByReplacingOccurrencesOfString:kBaiduBaikeImageURLPath withString:@""];
		NSString *imagepath = [NSString stringWithFormat:@"%@/%@/%@",[MiscHelper fetchSystemDir], self.baikeid, imagename];
		//NSLog(@"%@", imagepath);
		image = [UIImage imageWithContentsOfFile:imagepath];
	}
	[page displayImage:image];
	
	//NSLog(@"%g-%g-%g-%g", page.frame.origin.x, page.frame.origin.y, page.frame.size.width, page.frame.size.height);
	
	[pagingScrollView addSubview:page];
}

#pragma mark -
#pragma mark TapDetectingImageViewDelegate methods

- (void)fotoScrollView:(FotoScrollView *)aview gotSingleTapAtPoint:(CGPoint)tapPoint {	
    // Single tap shows or hides toolbar.
	[self setFullScreen:!self.navigationController.navigationBarHidden];
}

- (void)fotoScrollView:(FotoScrollView *)aview gotDoubleTapAtPoint:(CGPoint)tapPoint {    // double tap zooms in
	
	CGFloat xScale = aview.frame.size.width / aview.contentSize.width;
	CGFloat yScale = aview.frame.size.height / aview.contentSize.height;
	CGFloat newScale = MIN(xScale, yScale);
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"%g-%g-%g", xScale,yScale, newScale);
#endif
	// 如果图片长宽都小于屏幕，则不处理
	if (newScale > 1.0f) {
		return;
	}
	
    CGRect zoomRect = [self zoomRectForScale:aview zoomScale:newScale withCenter:tapPoint];
    [aview zoomToRect:zoomRect animated:YES];
}

- (void)fotoScrollView:(FotoScrollView *)aview gotTwoFingerTapAtPoint:(CGPoint)tapPoint {	
    // two-finger tap zooms out
}


#pragma mark -
#pragma mark Utility methods
- (CGRect)zoomRectForScale:(FotoScrollView *)aview zoomScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [aview frame].size.height / scale;
    zoomRect.size.width  = [aview frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
//*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		// Step 1: make the outer paging scroll view
		pagingScrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		pagingScrollView.backgroundColor = [UIColor blackColor];
		pagingScrollView.showsVerticalScrollIndicator = NO;
		pagingScrollView.showsHorizontalScrollIndicator = NO;
		pagingScrollView.contentSize = [[UIScreen mainScreen] bounds].size;
		pagingScrollView.delegate = self;
		[pagingScrollView setBouncesZoom:YES];

		[[self view] addSubview:pagingScrollView];
		//NSLog(@"%g-%g-%g-%g", pagingScrollView.frame.origin.x, pagingScrollView.frame.origin.y, pagingScrollView.frame.size.width, pagingScrollView.frame.size.height);
    }
    return self;
}
//*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
//*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

//*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// 设置tabbar自动隐藏
	[self setHidesBottomBarWhenPushed:YES];
	
	//UIImage *image = [UIImage imageWithContentsOfFile:[newDir stringByAppendingPathComponent:@"21e5582337f5791e9822edf4.jpg"]];
	//self.imgViewer.image = image;
}
//*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	imageUrl = nil;
	pagingScrollView = nil;
}


- (void)dealloc {
	[imageUrl release];
	[pagingScrollView release];
	
    [super dealloc];
}


@end
