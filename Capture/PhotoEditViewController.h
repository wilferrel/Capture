//
//  PhotoEditViewController.h
//  Capture
//
//  Created by Wil Ferrel on 1/31/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "BaseViewController.h"
#import "DropBoxImage.h"

@interface PhotoEditViewController : BaseViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageToEditImageView;
@property (strong, nonatomic) DropBoxImage *currentImage;

- (IBAction)goBackTouched:(id)sender;
- (IBAction)deleteTouched:(id)sender;
- (IBAction)enhancedTouched:(id)sender;
- (IBAction)shareTouched:(id)sender;

@end
