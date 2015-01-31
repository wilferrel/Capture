//
//  FileListViewController.h
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "BaseViewController.h"
#import "GPUImage.h"
#import "PhotoFilterView.h"

typedef NS_ENUM(NSUInteger, DB_FileListMode) {
    DB_FileListMode_Photos = 0,
    DB_FileListMode_Text = 1,
};

@interface FileListViewController : BaseViewController<UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *filesCollectionView;
@property (strong, nonatomic) NSMutableArray *filesCollectionArray;
@property (weak, nonatomic) IBOutlet UIView *emptyStateView;
@property (assign, nonatomic) DB_FileListMode currentFileListMode;
@end
