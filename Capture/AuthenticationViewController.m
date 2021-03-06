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

#define LOGIN_HIDDEN -90
#define LOGIN_SHOWN 0
@interface AuthenticationViewController ()
@property (assign, nonatomic) BOOL fadeOut;
@property (strong, nonatomic) NSTimer *labelAnimationTimer;

@end

@implementation AuthenticationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.loginButtonBottomConstraint.constant = LOGIN_HIDDEN;
    self.loadingLbl.alpha = 0;
    self.fadeOut = NO;
    [self addAuthenticationObserver];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (![[DBSession sharedSession] isLinked])
    {
        [self performSelector:@selector(showLoginButton) withObject:nil afterDelay:1.5];
    }
    else
    {
        [self setupTimer];
        [self downloadAllMetadata];
    }
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self cancelTimer];
}
- (void)addAuthenticationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAllMetadata) name:@"DropBoxUserAuthenticated_AGA" object:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UI Manipulation
- (void)animateLoadingLbl
{
    if (self.fadeOut)
    {
        [UIView animateWithDuration:0.7
            animations:^{
              self.loadingLbl.alpha = 0;
            }
            completion:^(BOOL finished) {
              self.fadeOut = NO;
            }];
    }
    else
    {
        [UIView animateWithDuration:0.7
            animations:^{
              self.loadingLbl.alpha = 1;
            }
            completion:^(BOOL finished) {
              self.fadeOut = YES;
            }];
    }
}
- (void)showLoginButton
{
    self.loginDropboxButton.alpha = 1;
    [UIView animateWithDuration:0.7
                     animations:^{
                       self.loginButtonBottomConstraint.constant = LOGIN_SHOWN;
                       self.loadingLbl.alpha = 0;
                       [self.view layoutIfNeeded];
                     }];
}
- (void)setupTimer
{
    self.labelAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animateLoadingLbl) userInfo:nil repeats:YES];
}
- (void)cancelTimer
{
    [self.labelAnimationTimer invalidate];
    self.labelAnimationTimer = nil;
}
#pragma mark - Dropbox Calls
- (void)downloadAllMetadata
{
    [[DropboxManager sharedInstance] getAllMetadata];
    [[DropboxManager sharedInstance] receivedMetadataFromDropbox:^(BOOL success, NSArray *metadataContentsArray) {
      if (success)
      {
          if (self.shownAsModal)
          {
              self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
              [self dismissViewControllerAnimated:YES
                                       completion:^{
                                         NSLog(@"Authenticated and received info from Dropbox");
                                       }];
          }
          else
          {
              CATransition *transition = [CATransition animation];

              transition.duration = 0.3;
              transition.type = kCATransitionFade;
              [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
              UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
              FileListViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"FileListViewController"];
              vc.currentFileListMode = DB_FileListMode_Photos;
              [self.navigationController pushViewController:vc animated:NO];
          }
      }
    }];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - User Actions
- (IBAction)dropBoxLoginTouched:(id)sender
{
    if (![[DBSession sharedSession] isLinked])
    {
        [[DBSession sharedSession] linkFromController:self];
    }
    else
    {
        NSLog(@"User is already logged in");
        [self downloadAllMetadata];
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self cancelTimer];
}

@end
