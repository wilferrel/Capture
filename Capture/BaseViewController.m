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


@interface BaseViewController ()<FancyTabBarDelegate>
//Fancy Toolbar
@property (nonatomic,strong) UIImageView *backgroundView;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [DBSession sharedSession].delegate=self;
    [self setUpFancyToolbar];
    // Do any additional setup after loading the view.
}
-(void)setUpFancyToolbar{
    _fancyTabBar = [[FancyTabBar alloc]initWithFrame:self.view.bounds];
    [_fancyTabBar setUpChoices:self choices:@[@"camera",@"gallery"] withMainButtonImage:[UIImage imageNamed:@"open"]];
    _fancyTabBar.delegate = self;
    _fancyTabBar.alpha=0;
    [self.view addSubview:_fancyTabBar];
    //Set out of view
    _fancyTabBar.frame=FANCYBAR_HIDDEN;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    if (![[DBSession sharedSession] isLinked]) {
        NSLog(@"User not authenticated");
        NSLog(@"Will attempt to re-authenticated");
        //User is not authenticated
        [[DBSession sharedSession] linkFromController:self];
    }else{
        //User authenticated.
        NSLog(@"User authenticated");
    }
}
-(void)logUserOut{
    [[DBSession sharedSession]unlinkAll];
}
#pragma mark- Dropbox Session Delegate
- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId{
    
}
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
#pragma mark - FancyTabBarDelegate
- (void) didCollapse{
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished) {
            [_backgroundView removeFromSuperview];
            _backgroundView = nil;
        }
    }];
}


- (void) didExpand{
    if(!_backgroundView){
        _backgroundView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        _backgroundView.alpha = 0;
        [self.view addSubview:_backgroundView];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
    [self.view bringSubviewToFront:_fancyTabBar];
    UIImage *backgroundImage = [self.view convertViewToImage];
    UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    UIImage *image = [backgroundImage applyBlurWithRadius:10 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
    _backgroundView.image = image;
}

- (void)optionsButton:(UIButton*)optionButton didSelectItem:(int)index{
    switch (index) {
        case 1:
            //Camera
            if (_fancyMenuTapped) {
                _fancyMenuTapped(FANCY_CAMERA);
            }
            break;
        case 2:
            //Camera Roll
            if (_fancyMenuTapped) {
                _fancyMenuTapped(FANCY_CAMERA_ROLL);
            }
            break;
        case 3:
            //Map
            if (_fancyMenuTapped) {
                _fancyMenuTapped(FANCY_MAP);
            }
            break;
        default:
            break;
    }
    NSLog(@"Hello index %d tapped !", index);
}
-(void)fancyMenuTapped:(void(^)(FANCY_MENU_BUTTONS buttonPressed))fancyMenuTappedCallback{
    _fancyMenuTapped=fancyMenuTappedCallback;
}

@end
