//
//  DropBoxImage.m
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "DropBoxImage.h"
#import "DropboxManager.h"

@implementation DropBoxImage
- (id)init {
    if (self = [super init]) {
        [self reset];
    }
    return self;
}
-(void)reset{
    self.imageName=@"";
    self.localPath=@"";
    self.dbPath=@"";
    self.imageLocation=[[CLLocation alloc]init];
    self.uploadDate=nil;
    self.originalImage=nil;
    self.squaredImage=nil;
    self.revNum=@"";
}
- (void)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    self.squaredImage=image;
}
+(void)saveImageToDropbox:(UIImage*)imageToSave withImageName:(NSString*)nameOfImage{
    //Save to App Directory
    NSData *pngData = UIImageJPEGRepresentation(imageToSave,0.70);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *imageName=[NSString stringWithFormat:@"%@.jpg",nameOfImage];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName];
    [pngData writeToFile:filePath atomically:YES];
    //Send to Dropbox
    [[DropboxManager sharedInstance]uploadImageToDropboxWithName:imageName imageRev:nil andImagePath:filePath];
    [[DropboxManager sharedInstance]uploadedFileToDropbox:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Uploaded Image to Dropbox");
        }else{
            NSLog(@"Error Uploading Image: %@",error.localizedDescription);
        }
        //Delete from Directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *errorForDelete;
        BOOL successDeleting = [fileManager removeItemAtPath:filePath error:&error];
        if (successDeleting) {
            NSLog(@"Removed Temp File");
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[errorForDelete localizedDescription]);
        }
    }];
    
}
+(void)updateFileWithName:(NSString*)nameOfImage andImage:(UIImage*)imageToUpdate andRev:(NSString*)revNum{
    //Save to App Directory
    NSData *pngData = UIImageJPEGRepresentation(imageToUpdate,0.70);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *imageName=[NSString stringWithFormat:@"%@",nameOfImage];
    NSString *filePath = [documentsPath stringByAppendingPathComponent:imageName];
    [pngData writeToFile:filePath atomically:YES];
    //Send to Dropbox
    [[DropboxManager sharedInstance]uploadImageToDropboxWithName:imageName imageRev:revNum andImagePath:filePath];
    [[DropboxManager sharedInstance]uploadedFileToDropbox:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"Uploaded Image to Dropbox");
        }else{
            NSLog(@"Error Uploading Image: %@",error.localizedDescription);
        }
        //Delete from Directory
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *errorForDelete;
        BOOL successDeleting = [fileManager removeItemAtPath:filePath error:&error];
        if (successDeleting) {
            NSLog(@"Removed Temp File");
        }
        else
        {
            NSLog(@"Could not delete file -:%@ ",[errorForDelete localizedDescription]);
        }
    }];

}
+(void)saveimageToDropbox:(NSString*)imagePath withName:(NSString*)name{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"M_dd_yyyy_hh-mm-ss"];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    [[DropboxManager sharedInstance]uploadImageToDropboxWithName:dateString imageRev:nil andImagePath:imagePath];
}
+(void)saveImageToPhotoRoll:(UIImage*)imageToSave{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"M_dd_yyyy_hh-mm-ss"];
    
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    [DropBoxImage saveImageToDropbox:imageToSave withImageName:dateString];
    
}
@end
