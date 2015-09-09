//
//  FileListViewController.m
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "FileListViewController.h"
#import "PhotosCollectionViewCell.h"
#import "DropboxManager.h"
#import "AssetsLibrary/AssetsLibrary.h"
#import "DropBoxImage.h"
#import "PhotoEditViewController.h"

@interface FileListViewController ()
@property (assign, nonatomic) CGFloat cellWidth;
@property (strong, nonatomic) NSString *lastImageSavedPath;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation FileListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCallBacks];
    [self setupCollectionView];
    self.filesCollectionArray = [[NSMutableArray alloc] init];
    [self.navigationItem setHidesBackButton:YES];
    [self setupCallBacks];
    [[DropboxManager sharedInstance] getMetadataForImages];
    [self.navigationController.view.layer removeAllAnimations];
}
- (void)initialSetup
{
    self.cellWidth = [[UIScreen mainScreen] bounds].size.width / 2;
}

- (void)setupCollectionView
{
    UINib *cellNib = [UINib nibWithNibName:@"PhotosCollectionViewCell" bundle:nil];
    [self.filesCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"PhotosCollectionViewCell"];
    UICollectionViewFlowLayout *currentCVLayout = [[UICollectionViewFlowLayout alloc] init];
    [currentCVLayout setMinimumInteritemSpacing:0.0f];
    [currentCVLayout setMinimumLineSpacing:0.0f];
    [currentCVLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.filesCollectionView setPagingEnabled:NO];
    [self.filesCollectionView setCollectionViewLayout:currentCVLayout];
    // Add Pull to Refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshDropboxList) forControlEvents:UIControlEventValueChanged];
    [self.filesCollectionView addSubview:self.refreshControl];
    self.filesCollectionView.alwaysBounceVertical = YES;
}
- (void)refreshDropboxList
{
    [[DropboxManager sharedInstance] getMetadataForImages];
}
- (void)reloadTableWithArray:(NSArray *)arrayOfItems
{
    if ([self.filesCollectionArray count] > 0)
    {
        [self.filesCollectionArray removeAllObjects];
    }
    self.filesCollectionArray = [NSMutableArray arrayWithArray:arrayOfItems];
    [self.filesCollectionView reloadData];
}
- (void)fadeOutEmptyStateView
{
    [UIView animateWithDuration:0.5
        animations:^{
          self.emptyStateView.alpha = 0;
        }
        completion:^(BOOL finished) {
          if (finished)
          {
              [self showFancyBar];
          }
        }];
}
- (void)showFancyBar
{
    if (self.fancyTabBar.alpha == 0)
    {
        self.fancyTabBar.alpha = 1;
        [UIView animateWithDuration:1.0
            delay:0
            usingSpringWithDamping:0.99
            initialSpringVelocity:15.0
            options:0
            animations:^{
              self.fancyTabBar.frame = FANCYBAR_SHOWN;
            }
            completion:^(BOOL finished){
            }];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Photos
- (void)takePictureWithCamera
{
#if TARGET_IPHONE_SIMULATOR
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DOH!"
                                                    message:@"Camera is not available on iPhone Simulator"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
#else
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];

    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:photoPicker animated:YES completion:NULL];
#endif
}
- (void)openCameraRoll
{
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;

    if (!error)
    {
        alertTitle = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)determineEmptyViewNeedsToBeHidden
{
    if ([self.filesCollectionArray count] > 0)
    {
        if (self.emptyStateView.alpha == 1)
        {
            [self performSelector:@selector(fadeOutEmptyStateView) withObject:nil afterDelay:2];
        }
    }
    else
    {
        [self showFancyBar];
    }
    // Just in case stop refreshing
    [self.refreshControl endRefreshing];
}
#pragma mark - UIImagePicker Delegate
- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *selectedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (photoPicker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // From Camera
        [DropBoxImage saveImageToPhotoRoll:selectedImage];
    }
    else
    {
        // From Camera Roll
    }
    PhotoFilterView *photoFilterV = [[[NSBundle mainBundle] loadNibNamed:@"PhotoFilterView" owner:self options:nil] objectAtIndex:0];
    [photoFilterV showWithImage:selectedImage];
    [photoFilterV photoFilterViewHiddenWithSelectedImage:^(UIImage *selectImage) {
      [DropBoxImage saveImageToPhotoRoll:selectImage];
    }];
    [photoPicker dismissViewControllerAnimated:NO
                                    completion:^{

                                    }];
}
#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return [self.filesCollectionArray count];
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                             layout:(UICollectionViewLayout *)collectionViewLayout
    referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{

    UICollectionReusableView *sectionHeader = nil;
    if (kind == UICollectionElementKindSectionHeader)
    {
        sectionHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"EventSectionHeader" forIndexPath:indexPath];
        sectionHeader.layer.borderWidth = .5f;
        sectionHeader.layer.borderColor = [UIColor colorWithRed:221.0 / 255.0 green:223.0 / 255.0 blue:220.0 / 255.0 alpha:1.0].CGColor;
        sectionHeader.hidden = YES;
    }

    return sectionHeader;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width / 2 - 1), ([UIScreen mainScreen].bounds.size.width / 2 - 1));
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotosCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotosCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row < [self.filesCollectionArray count])
    {
        DropBoxImage *tempImage = [self.filesCollectionArray objectAtIndex:indexPath.row];
        cell.imageNameLbl.text = [NSString stringWithFormat:@"%@", tempImage.imageName];
        NSString *imagePath = [NSString stringWithFormat:@"%@", [[DropboxManager sharedInstance] thumbnailPath:tempImage.imageName]];
        UIImage *imageThumb = [UIImage imageWithContentsOfFile:imagePath];
        cell.photoImageView.image = [UIImage imageNamed:@"thumbnail"];
        if (imageThumb)
        {
            if (tempImage.squaredImage)
            {
                cell.photoImageView.image = tempImage.squaredImage;
            }
            else
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                  [tempImage squareImageFromImage:imageThumb scaledToSize:300];
                  dispatch_async(dispatch_get_main_queue(), ^(void) {
                    [collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
                  });
                });
            }
        }
    }
    return cell;
}
#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [SVProgressHUD show];
    DropBoxImage *tempImage = [self.filesCollectionArray objectAtIndex:indexPath.row];
    [[DropboxManager sharedInstance] downloadPictureFromDropBoxPath:tempImage.dbPath withImageName:tempImage.imageName];
}
- (void)setupCallBacks
{
    __weak typeof(self) weakSelf = self;
    [[DropboxManager sharedInstance] receivedMetadataFromDropboxPictures:^(BOOL success, NSArray *metadataContentsArray) {
      if (success)
      {
          [self reloadTableWithArray:metadataContentsArray];
      }
      [self determineEmptyViewNeedsToBeHidden];
    }];
    [[DropboxManager sharedInstance] receivedMetadataFromDropbox:^(BOOL success, NSArray *metadataContentsArray) {
      if (success)
      {
          [self reloadTableWithArray:metadataContentsArray];
      }
      [self determineEmptyViewNeedsToBeHidden];
    }];
    [[DropboxManager sharedInstance] loadedThumbnailImage:^(BOOL success, NSError *error) {
      [weakSelf.filesCollectionView reloadData];
    }];
    [self fancyMenuTapped:^(FANCY_MENU_BUTTONS buttonPressed) {
      switch (buttonPressed)
      {
          case FANCY_CAMERA:
              [self takePictureWithCamera];
              break;
          case FANCY_MAP:

              break;
          case FANCY_CAMERA_ROLL:
              [self openCameraRoll];
              break;
          default:
              break;
      }
    }];
    [[DropboxManager sharedInstance] downloadedFileToDropbox:^(BOOL success, NSError *error, DropBoxImage *imageObject) {
      if (success)
      {
          [SVProgressHUD dismiss];
          [self moveToPhotoEditWithImage:imageObject];
      }
      else
      {
          // Print Error.
      }
    }];
}
- (void)moveToPhotoEditWithImage:(DropBoxImage *)dbImage
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhotoEditViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"PhotoEditViewController"];
    vc.currentImage = dbImage;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
