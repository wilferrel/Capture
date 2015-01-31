//
//  BaseViewController.h
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "FancyTabBar.h"
#import "SVProgressHUD.h"

#define FANCYBAR_HIDDEN     CGRectMake(_fancyTabBar.frame.origin.x, _fancyTabBar.frame.origin.y+100, _fancyTabBar.frame.size.width, _fancyTabBar.frame.size.height)
#define FANCYBAR_SHOWN    CGRectMake(self.fancyTabBar.frame.origin.x, self.fancyTabBar.frame.origin.y-100, self.fancyTabBar.frame.size.width, self.fancyTabBar.frame.size.height)

typedef NS_ENUM(NSUInteger, FANCY_MENU_BUTTONS) {
    FANCY_CAMERA = 0,
    FANCY_MAP = 1,
    FANCY_CAMERA_ROLL=2
};
@interface BaseViewController : UIViewController<DBSessionDelegate>
-(void)logUserOut;
//Blocks
-(void)fancyMenuTapped:(void(^)(FANCY_MENU_BUTTONS buttonPressed))fancyMenuTappedCallback;
@property (nonatomic, copy) void(^fancyMenuTapped)(FANCY_MENU_BUTTONS buttonPressed);
@property(nonatomic,strong) FancyTabBar *fancyTabBar;

@end
