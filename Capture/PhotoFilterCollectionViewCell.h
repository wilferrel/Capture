//
//  PhotoFilterCollectionViewCell.h
//  Capture
//
//  Created by Wil Ferrel on 1/30/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface PhotoFilterCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *oneLetterNameOfFilterLbl;
@property (weak, nonatomic) IBOutlet UILabel *nameOfFilterLbl;
@property (assign, nonatomic) BOOL cellSelected;

@end
