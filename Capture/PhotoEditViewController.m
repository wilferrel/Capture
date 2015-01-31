//
//  PhotoEditViewController.m
//  Capture
//
//  Created by Wil Ferrel on 1/31/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "PhotoEditViewController.h"
#import "DropboxManager.h"
#import "PhotoFilterView.h"
#import "CaptureSharing.h"

@interface PhotoEditViewController ()<UIAlertViewDelegate>

@end

@implementation PhotoEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}
-(void)setupView{
    _imageToEditImageView.image=_currentImage.originalImage;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[DropboxManager sharedInstance]removeFileFromPath:_currentImage.localPath];
}

- (IBAction)goBackTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteTouched:(id)sender {
    [self deletePopUp];
}
-(void)deletePopUp{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Do you want to delete this photo?"] delegate:self cancelButtonTitle:@"No" otherButtonTitles: @"Yes",nil];
    [alert show];
}
-(void)goBackAfterDelete{
    [SVProgressHUD showSuccessWithStatus:@"Deleted Image"];
    [self goBackTouched:nil];
}

- (IBAction)enhancedTouched:(id)sender {
    __weak typeof(self) weakSelf = self;
    PhotoFilterView *photoFilterV=[[PhotoFilterView alloc]init];
    [photoFilterV showWithImage:_currentImage.originalImage];
    [photoFilterV photoFilterViewHiddenWithSelectedImage:^(UIImage *selectImage) {
        [DropBoxImage updateFileWithName:weakSelf.currentImage.imageName andImage:selectImage andRev:weakSelf.currentImage.revNum];
        weakSelf.imageToEditImageView.image=selectImage;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[DropboxManager sharedInstance]getMetadataForImages];
        });
    }];
}

- (IBAction)shareTouched:(id)sender {
    [CaptureSharing shareToSocialWithImage:self.imageToEditImageView.image andText:@"Sharing via Capture for iOS" fromVC:self];
}
#pragma mark- UIAlertview delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==0) {
        //Cancel
    }else{
        //Delete
        [SVProgressHUD showWithStatus:@"Shredding..."];
        [[DropboxManager sharedInstance]deletePath:_currentImage.dbPath];
        [[DropboxManager sharedInstance]deletedPath:^(BOOL success, NSError *error) {
            if (success) {
                [[DropboxManager sharedInstance]getMetadataForImages];
                [self performSelector:@selector(goBackAfterDelete) withObject:nil afterDelay:2.0];
            }else{
                [SVProgressHUD dismiss];
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Ooops..." message:[NSString stringWithFormat:@"Unable to delete file. Error: %@",error.localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

@end
