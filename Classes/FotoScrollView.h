//
//  FotoViewController.h
//  HotGirl
//
//  Created by 李云天 on 10-10-18.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TapDetectingImageViewDelegate;

@interface FotoScrollView : UIScrollView <UIScrollViewDelegate> {
    UIView        *imageView;
    NSUInteger     index;
	NSString	  *imageName;
	
    id <TapDetectingImageViewDelegate> tapDelegate;
    
    // Touch detection
    CGPoint tapLocation;         // Needed to record location of single tap, which will only be registered after delayed perform.
    BOOL multipleTouches;        // YES if a touch event contains more than one touch; reset when all fingers are lifted.
    BOOL twoFingerTapIsPossible; // Set to NO when 2-finger tap can be ruled out (e.g. 3rd finger down, fingers touch down too far apart, etc).	
}
@property (assign) NSUInteger index;
@property (nonatomic, retain) NSString *imageName;

@property (nonatomic, assign) id <TapDetectingImageViewDelegate> tapDelegate;

- (void)displayImage:(UIImage *)image;
- (void)setMaxMinZoomScalesForCurrentBounds;

- (CGPoint)pointToCenterAfterRotation;
- (CGFloat)scaleToRestoreAfterRotation;
- (void)restoreCenterPoint:(CGPoint)oldCenter scale:(CGFloat)oldScale;
@end


/*
 Protocol for the tap-detecting image view's delegate.
 */
@protocol TapDetectingImageViewDelegate <NSObject>

@optional
- (void)fotoScrollView:(FotoScrollView *)view gotSingleTapAtPoint:(CGPoint)tapPoint;
- (void)fotoScrollView:(FotoScrollView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint;
- (void)fotoScrollView:(FotoScrollView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint;

@end
