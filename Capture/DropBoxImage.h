//
//  DropBoxImage.h
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@import CoreLocation;

@interface DropBoxImage : NSObject
@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) NSString *localPath;
@property (strong, nonatomic) NSString *dbPath;
@property (strong, nonatomic) CLLocation *imageLocation;
@property (strong, nonatomic) NSDate *uploadDate;
@property (strong, nonatomic) UIImage *squaredImage;
@property (strong, nonatomic) UIImage *originalImage;
@property (strong, nonatomic) NSString *revNum;

- (void)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize;
+(void)saveImageToDropbox:(UIImage*)imageToSave withImageName:(NSString*)nameOfImage;
+(void)saveimageToDropbox:(NSString*)imagePath withName:(NSString*)name;
+(void)saveImageToPhotoRoll:(UIImage*)imageToSave;
+(void)updateFileWithName:(NSString*)nameOfImage andImage:(UIImage*)imageToUpdate andRev:(NSString*)revNum;

@end
