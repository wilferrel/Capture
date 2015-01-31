//
//  DropboxManager.h
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import "DropBoxImage.h"

@interface DropboxManager : NSObject<DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@property (strong, nonatomic) NSMutableArray *photoMetadataContentsArray;

+ (DropboxManager*)sharedInstance;

/**
 *  Will Upload an to Dropbox image with the given path. Revision will be used to overwrite file.
 *
 *  @param fileName       Name of Image
 *  @param parentImageRev Parent Revision Number
 *  @param imagePath      Path Image is located in
 */
-(void)uploadImageToDropboxWithName:(NSString*)fileName imageRev:(NSString*)parentImageRev andImagePath:(NSString*)imagePath;
/**
 *  Get All Metadata for Images Directory
 */
-(void)getMetadataForImages;
/**
 *  Get App root directory metadata in order to create initial folder structure
 */
-(void)getAllMetadata;
/**
 *  Download image for Dropbox bucket to App Document directory
 *
 *  @param dropboxPath Dropbox file path
 *  @param imageName   Name of image
 */
- (void)downloadPictureFromDropBoxPath:(NSString*)dropboxPath withImageName:(NSString*)imageName;
/**
 *  Local Directory for all Thumbnail temp. images in App Documents directory
 *
 *  @param nameOfFile Name of Image
 *
 *  @return File Path inside Documents Directory
 */
-(NSString*)thumbnailPath:(NSString*)nameOfFile;
/**
 *  Userd to remove any file from App Documents directory.
 *
 *  @param pathToFile path to local file
 */
-(void)removeFileFromPath:(NSString*)pathToFile;
/**
 *  Deleting an entire directory path.
 *
 *  @param pathToDelete Path of directory to delete
 */
-(void)deletePath:(NSString*)pathToDelete;

//Blocks
@property (nonatomic, copy) void(^receivedMetadataFromDropbox)(BOOL success,NSArray* metadataContentsArray);
-(void)receivedMetadataFromDropbox:(void(^)(BOOL success,NSArray* metadataContentsArray))receivedMetadataFromDropboxCallback;
@property (nonatomic, copy) void(^receivedMetadataFromDropboxPictures)(BOOL success,NSArray* metadataContentsArray);
-(void)receivedMetadataFromDropboxPictures:(void(^)(BOOL success,NSArray* metadataContentsArray))receivedMetadataFromDropboxPicturesCallback;
@property (nonatomic, copy) void(^uploadedFileToDropbox)(BOOL success, NSError*error);
-(void)uploadedFileToDropbox:(void(^)(BOOL success, NSError*error))uploadedFileToDropboxCallback;
@property (nonatomic, copy) void(^downloadedFileToDropbox)(BOOL success, NSError*error, DropBoxImage* imageObject);
-(void)downloadedFileToDropbox:(void(^)(BOOL success, NSError*error,DropBoxImage* imageObject))downloadedFileToDropboxCallback;
@property (nonatomic, copy) void(^loadedThumbnailImage)(BOOL success, NSError*error);
-(void)loadedThumbnailImage:(void(^)(BOOL success, NSError*error))loadedThumbnailImageCallBack;
@property (nonatomic, copy) void(^deletedPath)(BOOL success, NSError*error);
-(void)deletedPath:(void(^)(BOOL success, NSError*error))deletedPathCallback;

@end
