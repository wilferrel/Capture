//
//  PhotoFilterView.m
//  Capture
//
//  Created by Wil Ferrel on 1/30/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "PhotoFilterView.h"
#import "PhotoFilterCollectionViewCell.h"
@implementation PhotoFilterView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self)
    {
        return nil;
    }
    return self;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self baseInit];
}
- (void)baseInit
{
    self.isVisible = NO;
    self.originalImage = nil;
    self.filterArray = [[NSMutableArray alloc] initWithArray:@[
        [NSNumber numberWithInt:FILTER_None],
        [NSNumber numberWithInt:FILTER_Greyscale],
        [NSNumber numberWithInt:FILTER_Sepia],
        [NSNumber numberWithInt:FILTER_Sketch],
        [NSNumber numberWithInt:FILTER_Pixellate],
        [NSNumber numberWithInt:FILTER_ColorInvert],
        [NSNumber numberWithInt:FILTER_Toon],
        [NSNumber numberWithInt:FILTER_PinchDistort]
    ]];
    self.parentV = [UIApplication sharedApplication].keyWindow;
    self.frame = self.parentV.frame;
    self.alpha = 0;
    [self setupCollectionView];
    self.selectedFilter = FILTER_None;
}
- (void)setupCollectionView
{
    UINib *cellNib = [UINib nibWithNibName:@"PhotoFilterCollectionViewCell" bundle:nil];
    [self.filterCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"PhotoFilterCollectionViewCell"];

    _currentCVLayout = [[UICollectionViewFlowLayout alloc] init];
    [_currentCVLayout setMinimumInteritemSpacing:0.0f];
    [_currentCVLayout setMinimumLineSpacing:0.0f];
    [_currentCVLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.filterCollectionView setPagingEnabled:YES];
    [self.filterCollectionView setCollectionViewLayout:_currentCVLayout];
}
- (void)showWithImage:(UIImage *)imageForFilter
{
    self.originalImage = imageForFilter;
    [_filterCollectionView reloadData];
    [_parentV addSubview:self];
    _previewImageView.image = _originalImage;
    [UIView animateWithDuration:0.4
        animations:^{
          self.alpha = 1.0f;
          [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

        }
        completion:^(BOOL finished) {
          UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self);
          self.isVisible = YES;
          self.accessibilityViewIsModal = YES;
          if (_photoFilterViewShown)
          {
              _photoFilterViewShown();
          }
        }];
}
- (void)hide
{
    [UIView animateWithDuration:0.5
        animations:^{
          self.alpha = 0.0f;
        }
        completion:^(BOOL finished) {
          UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
          [self removeFromSuperview];
          self.isVisible = NO;
          if (_photoFilterViewHidden)
          {
              _photoFilterViewHidden();
          }
        }];
}

- (IBAction)saveTouched:(id)sender
{
    if (_photoFilterViewHiddenWithSelectedImage)
    {
        if (_editedImage)
        {
            _photoFilterViewHiddenWithSelectedImage(_editedImage);
        }
        else
        {
            _photoFilterViewHiddenWithSelectedImage(_originalImage);
        }
    }
    [self hide];
}

- (IBAction)cancelTouched:(id)sender
{
    [self hide];
}
#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    return [_filterArray count];
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.filterCollectionView.bounds.size.height, self.filterCollectionView.bounds.size.height);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoFilterCollectionViewCell" forIndexPath:indexPath];
    Photo_Filter currentFilter = (Photo_Filter)[[self.filterArray objectAtIndex:indexPath.row] integerValue];
    NSString *nameOfFilter = [[self nameOfFilter:currentFilter] uppercaseString];
    NSString *firstLetter = [nameOfFilter substringToIndex:1];
    cell.oneLetterNameOfFilterLbl.text = firstLetter;
    cell.nameOfFilterLbl.text = nameOfFilter;
    if (currentFilter == self.selectedFilter)
    {
        cell.oneLetterNameOfFilterLbl.alpha = 0.4;
        cell.nameOfFilterLbl.alpha = 0.4;
    }
    else
    {
        cell.oneLetterNameOfFilterLbl.alpha = 1.0;
        cell.nameOfFilterLbl.alpha = 1.0;
    }
    return cell;
}
#pragma mark - UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Photo_Filter currentFilter = (Photo_Filter)[[self.filterArray objectAtIndex:indexPath.row] integerValue];
    self.selectedFilter = currentFilter;
    [self.filterCollectionView reloadData];
    UIImage *image = [self addFilter:currentFilter];
    self.editedImage = image;
    self.previewImageView.image = self.editedImage;
}
- (UIImage *)addFilter:(Photo_Filter)photoFilter
{
    GPUImageFilter *selectedFilter;
    switch (photoFilter)
    {
        case FILTER_None:
            return _originalImage;
            break;
        case FILTER_Greyscale:
            selectedFilter = [[GPUImageGrayscaleFilter alloc] init];
            break;
        case FILTER_Sepia:
            selectedFilter = [[GPUImageSepiaFilter alloc] init];
            break;
        case FILTER_Sketch:
            selectedFilter = [[GPUImageSketchFilter alloc] init];
            break;
        case FILTER_Pixellate:
            selectedFilter = [[GPUImagePixellateFilter alloc] init];
            break;
        case FILTER_ColorInvert:
            selectedFilter = [[GPUImageColorInvertFilter alloc] init];
            break;
        case FILTER_Toon:
            selectedFilter = [[GPUImageToonFilter alloc] init];
            break;
        case FILTER_PinchDistort:
            selectedFilter = [[GPUImagePinchDistortionFilter alloc] init];
            break;

        default:
            break;
    }
    UIImage *filteredImage = [selectedFilter imageByFilteringImage:self.originalImage];
    return filteredImage;
}
- (NSString *)nameOfFilter:(Photo_Filter)photoFilter
{
    switch (photoFilter)
    {
        case FILTER_None:
            return @"None";
            break;
        case FILTER_Greyscale:
            return @"Grayscale";
            break;
        case FILTER_Sepia:
            return @"Sepia";
            break;
        case FILTER_Sketch:
            return @"Sketch";
            break;
        case FILTER_Pixellate:
            return @"Pixellate";
            break;
        case FILTER_ColorInvert:
            return @"Color Invert";
            break;
        case FILTER_Toon:
            return @"Toon";
            break;
        case FILTER_PinchDistort:
            return @"Pinch Distort";
            break;

        default:
            break;
    }
}

#pragma mark - Blocks
- (void)photoFilterViewShown:(void (^)())callBackBlock
{
    self.photoFilterViewShown = callBackBlock;
}
- (void)photoFilterViewHidden:(void (^)())callBackBlock
{
    self.photoFilterViewHidden = callBackBlock;
}
- (void)photoFilterViewHiddenWithSelectedImage:(void (^)(UIImage *selectImage))callBackBlock
{
    self.photoFilterViewHiddenWithSelectedImage = callBackBlock;
}

@end
