//
//  PhotoFilterView.h
//  Capture
//
//  Created by Wil Ferrel on 1/30/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"
typedef NS_ENUM(NSUInteger, Photo_Filter)
{
    FILTER_None = 0,
    FILTER_Greyscale = 1,
    FILTER_Sepia = 2,
    FILTER_Sketch = 3,
    FILTER_Pixellate = 4,
    FILTER_ColorInvert = 5,
    FILTER_Toon = 6,
    FILTER_PinchDistort = 7
};

@interface PhotoFilterView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
@property (assign, nonatomic) BOOL isVisible;
@property (strong, nonatomic) IBOutlet UICollectionView *filterCollectionView;
@property (strong, nonatomic) NSMutableArray *filterArray;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) UIImage *editedImage;

@property (strong, nonatomic) UIView *parentV;
@property (strong, nonatomic) UICollectionViewFlowLayout *currentCVLayout;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (assign, nonatomic) Photo_Filter selectedFilter;

- (void)showWithImage:(UIImage *)imageForFilter;
- (void)hide;
- (IBAction)saveTouched:(id)sender;
- (IBAction)cancelTouched:(id)sender;

// Blocks
@property (nonatomic, copy) void (^photoFilterViewShown)();
- (void)photoFilterViewShown:(void (^)())callBackBlock;
@property (nonatomic, copy) void (^photoFilterViewHidden)();
- (void)photoFilterViewHidden:(void (^)())callBackBlock;
@property (nonatomic, copy) void (^photoFilterViewHiddenWithSelectedImage)(UIImage *selectImage);
- (void)photoFilterViewHiddenWithSelectedImage:(void (^)(UIImage *selectImage))callBackBlock;
@end
