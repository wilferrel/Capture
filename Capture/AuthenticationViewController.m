//
//  AuthenticationViewController.m
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "DropboxManager.h"
#import "FileListViewController.h"

#define LOGIN_HIDDEN    -90
#define LOGIN_SHOWN     0
@interface AuthenticationViewController ()
@property (assign, nonatomic) BOOL fadeOut;
@property (strong, nonatomic) NSTimer *labelAnimationTimer;

@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _loginButtonBottomConstraint.constant=LOGIN_HIDDEN;
    _loadingLbl.alpha=0;
    _fadeOut=NO;
    [self addAuthenticationObserver];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (![[DBSession sharedSession] isLinked]) {
        [self performSelector:@selector(showLoginButton) withObject:nil afterDelay:1.5];
    }else{
        [self setupTimer];
        [self downloadAllMetadata];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [self cancelTimer];
}
-(void)addAuthenticationObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadAllMetadata)
                                                 name:@"DropBoxUserAuthenticated_AGA"
                                               object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- UI Manipulation
-(void)animateLoadingLbl{
    if (_fadeOut) {
        [UIView animateWithDuration:0.7 animations:^{
            _loadingLbl.alpha=0;
        }completion:^(BOOL finished) {
            _fadeOut=NO;
        }];
    }else{
        [UIView animateWithDuration:0.7 animations:^{
            _loadingLbl.alpha=1;
        }completion:^(BOOL finished) {
            _fadeOut=YES;
        }];
    }
}
-(void)showLoginButton{
    _loginDropboxButton.alpha=1;
    [UIView animateWithDuration:0.7 animations:^{
        _loginButtonBottomConstraint.constant=LOGIN_SHOWN;
        _loadingLbl.alpha=0;
        [self.view layoutIfNeeded];
    }];
}
-(void)setupTimer{
   _labelAnimationTimer=[NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(animateLoadingLbl)
                                   userInfo:nil
                                    repeats:YES];
    
}
-(void)cancelTimer{
    [_labelAnimationTimer invalidate];
    _labelAnimationTimer = nil;
}
#pragma mark- Dropbox Calls
-(void)downloadAllMetadata{
    [[DropboxManager sharedInstance]getAllMetadata];
    [[DropboxManager sharedInstance]receivedMetadataFromDropbox:^(BOOL success, NSArray *metadataContentsArray) {
        if (success) {
            if (_shownAsModal) {
                self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"Authenticated and received info from Dropbox");
                }];
            }else{
                CATransition* transition = [CATransition animation];
                
                transition.duration = 0.3;
                transition.type = kCATransitionFade;
                [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
                FileListViewController *vc=[mainStoryboard instantiateViewControllerWithIdentifier:@"FileListViewController"];
                vc.currentFileListMode=DB_FileListMode_Photos;
                [self.navigationController pushViewController:vc animated:NO];

            }
        }
    }];
}
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
#pragma mark- User Actions
- (IBAction)dropBoxLoginTouched:(id)sender {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }else{
        NSLog(@"User is already logged in");
        [self downloadAllMetadata];
    }
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelTimer];
}

@end
