//
//  AuthenticationViewController.h
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "BaseViewController.h"

@interface AuthenticationViewController : UIViewController
//User Actions
- (IBAction)dropBoxLoginTouched:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *loginDropboxButton;
@property (weak, nonatomic) IBOutlet UILabel *loadingLbl;
@property (assign, nonatomic) BOOL shownAsModal;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginButtonBottomConstraint;

@end
