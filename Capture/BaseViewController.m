//
//  BaseViewController.m
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "BaseViewController.h"
#import "UIView+Screenshot.h"
#import "UIImage+ImageEffects.h"
#import "AppState.h"
#import "DropboxManager.h"

@interface BaseViewController () <FancyTabBarDelegate>
// Fancy Toolbar
@property (nonatomic, strong) UIImageView *backgroundView;

@end

@implementation BaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [DBSession sharedSession].delegate = self;
    [self setUpFancyToolbar];
    // Do any additional setup after loading the view.
}
- (void)setUpFancyToolbar
{
    _fancyTabBar = [[FancyTabBar alloc] initWithFrame:self.view.bounds];
    [_fancyTabBar setUpChoices:self choices:@[ @"camera", @"gallery" ] withMainButtonImage:[UIImage imageNamed:@"open"]];
    self.fancyTabBar.delegate = self;
    self.fancyTabBar.alpha = 0;
    [self.view addSubview:self.fancyTabBar];
    // Set out of view
    self.fancyTabBar.frame = FANCYBAR_HIDDEN;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![[DBSession sharedSession] isLinked])
    {
        if (![AppState sharedInstance].authenticated)
        {
            // First time User authenticated after not being authorized refresh images
            [[DropboxManager sharedInstance] getAllMetadata];
            [[DropboxManager sharedInstance] getMetadataForImages];
        }
        NSLog(@"User not authenticated");
        NSLog(@"Will attempt to re-authenticated");
        // User is not authenticated
        [[DBSession sharedSession] linkFromController:self];
    }
    else
    {
        // User authenticated.
        NSLog(@"User authenticated");
        [AppState sharedInstance].authenticated = NO;
    }
}
- (void)logUserOut
{
    [[DBSession sharedSession] unlinkAll];
}
#pragma mark - Dropbox Session Delegate
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    NSLog(@"Auth Error from Dropbox");
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - FancyTabBarDelegate
- (void)didCollapse
{
    [UIView animateWithDuration:0.3
        animations:^{
          self.backgroundView.alpha = 0;
        }
        completion:^(BOOL finished) {
          if (finished)
          {
              [self.backgroundView removeFromSuperview];
              self.backgroundView = nil;
          }
        }];
}

- (void)didExpand
{
    if (!self.backgroundView)
    {
        self.backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        self.backgroundView.alpha = 0;
        [self.view addSubview:self.backgroundView];
    }

    [UIView animateWithDuration:0.3
        animations:^{
          self.backgroundView.alpha = 1;
        }
        completion:^(BOOL finished){
        }];

    [self.view bringSubviewToFront:self.fancyTabBar];
    UIImage *backgroundImage = [self.view convertViewToImage];
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    UIImage *image = [backgroundImage applyBlurWithRadius:10 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
    self.backgroundView.image = image;
}

- (void)optionsButton:(UIButton *)optionButton didSelectItem:(int)index
{
    switch (index)
    {
        case 1:
            // Camera
            if (self.fancyMenuTapped)
            {
                self.fancyMenuTapped(FANCY_CAMERA);
            }
            break;
        case 2:
            // Camera Roll
            if (self.fancyMenuTapped)
            {
                self.fancyMenuTapped(FANCY_CAMERA_ROLL);
            }
            break;
        case 3:
            // Map
            if (self.fancyMenuTapped)
            {
                self.fancyMenuTapped(FANCY_MAP);
            }
            break;
        default:
            break;
    }
}
- (void)fancyMenuTapped:(void (^)(FANCY_MENU_BUTTONS buttonPressed))fancyMenuTappedCallback
{
    self.fancyMenuTapped = fancyMenuTappedCallback;
}

@end
