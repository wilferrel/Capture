//
//  DropboxManager.m
//  Capture
//
//  Created by Wil Ferrel on 1/29/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "DropboxManager.h"
#import "DropBoxImage.h"

#define IMAGE_DROPBOX_PATH  @"/Photos/"
#define DROPBOX_MAIN_PATH  @"/"

@implementation DropboxManager

+ (DropboxManager*)sharedInstance{
    static DropboxManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (id)init {
    if (self = [super init]) {
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self;
        self.photoMetadataContentsArray=[[NSMutableArray alloc]init];
    }
    return self;
}
-(void)refreshPhotoMetadataContentsWithArray:(NSArray*)metadataContents{
    if([_photoMetadataContentsArray count]>0){
        [_photoMetadataContentsArray removeAllObjects];
    }
    _photoMetadataContentsArray=[NSMutableArray arrayWithArray:metadataContents];
}

#pragma mark- Upload Related Methods
-(void)uploadImageToDropboxWithName:(NSString*)fileName imageRev:(NSString*)parentImageRev andImagePath:(NSString*)imagePath{
    NSString *destDir = IMAGE_DROPBOX_PATH;
    [self.restClient uploadFile:fileName toPath:destDir withParentRev:parentImageRev fromPath:imagePath];
}
- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    [self loadSinglePhotoToArray:metadata];
    if (_uploadedFileToDropbox) {
        _uploadedFileToDropbox(YES,nil);
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
    if (_uploadedFileToDropbox) {
        _uploadedFileToDropbox(NO,error);
    }
}
#pragma mark- Metadata Related
-(void)getAllMetadata{
    [self.restClient loadMetadata:DROPBOX_MAIN_PATH];
}
-(void)getMetadataForImages{
    [self.restClient loadMetadata:IMAGE_DROPBOX_PATH];
}
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        if ([metadata.path isEqualToString:@"/Photos"]) {
            //Parse Photo Contents
            if ([metadata.contents count]>0) {
                [self loadPhotoContentesToArray:metadata.contents];
            }else{
                if (_receivedMetadataFromDropboxPictures) {
                    _receivedMetadataFromDropboxPictures(NO,_photoMetadataContentsArray);
                }
            }
        }
        else{
            //Outside of Photos Folder
            [self refreshPhotoMetadataContentsWithArray:metadata.contents];
            //Check if Initial Folders were created
            if ([metadata.contents count]==0) {
                [self createFolderWithName:@"Photos"];
                [self createFolderWithName:@"Audio"];
                [self createFolderWithName:@"Notes"];
                if (_receivedMetadataFromDropbox) {
                    _receivedMetadataFromDropbox(YES, metadata.contents);
                }
            }else{
                BOOL photosFolderExists=NO;
                BOOL audioFolderExists=NO;
                BOOL notesFolderExists=NO;
                for (DBMetadata* child in metadata.contents) {
                    if(child.isDirectory && [child.filename isEqualToString:@"Photos"]){
                        photosFolderExists=YES;
                    }
                    if(child.isDirectory && [child.filename isEqualToString:@"Audio"]){
                        audioFolderExists=YES;
                    }
                    if(child.isDirectory && [child.filename isEqualToString:@"Notes"]){
                        notesFolderExists=YES;
                    }
                }
                //Create Folders If They Dont Exist
                if (!photosFolderExists) {
                    [self createFolderWithName:@"Photos"];
                }
                if (!audioFolderExists) {
                    [self createFolderWithName:@"Audio"];
                }
                if (!notesFolderExists) {
                    [self createFolderWithName:@"Notes"];
                }
            }
            if (_receivedMetadataFromDropbox) {
                _receivedMetadataFromDropbox(YES, metadata.contents);
            }

        }
    }
}
-(void)loadSinglePhotoToArray:(DBMetadata*)uploadedImageMetadata{
    if (!uploadedImageMetadata.isDeleted) {
        DropBoxImage *tempImage=[[DropBoxImage alloc]init];
        tempImage.dbPath=uploadedImageMetadata.path;
        tempImage.imageName=uploadedImageMetadata.filename;
        tempImage.revNum=uploadedImageMetadata.rev;
        [self.restClient loadThumbnail:tempImage.dbPath ofSize:@"iphone_bestfit" intoPath:[self thumbnailPath:tempImage.imageName]];
        [_photoMetadataContentsArray addObject:tempImage];
        if (_receivedMetadataFromDropboxPictures) {
            _receivedMetadataFromDropboxPictures(YES,_photoMetadataContentsArray);
        }
    }
}
-(void)loadPhotoContentesToArray:(NSArray*)photoContents{
    if ([_photoMetadataContentsArray count]>0) {
        [_photoMetadataContentsArray removeAllObjects];
    }
    [self removeAllThumbnails];
    for (DBMetadata* child in photoContents) {
        if (!child.isDeleted) {
            DropBoxImage *tempImage=[[DropBoxImage alloc]init];
            tempImage.dbPath=child.path;
            tempImage.imageName=child.filename;
            tempImage.revNum=child.rev;
            [self.restClient loadThumbnail:tempImage.dbPath ofSize:@"iphone_bestfit" intoPath:[self thumbnailPath:tempImage.imageName]];
            [_photoMetadataContentsArray addObject:tempImage];
        }
        
    }
    if (_receivedMetadataFromDropboxPictures) {
        _receivedMetadataFromDropboxPictures(YES,_photoMetadataContentsArray);
    }
}
- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    if (_receivedMetadataFromDropbox) {
        _receivedMetadataFromDropbox(NO, nil);
    }
    NSLog(@"Error loading metadata: %@", error);
}

#pragma mark- Download Related
- (void)downloadPictureFromDropBoxPath:(NSString*)dropboxPath withImageName:(NSString*)imageName{
    [self.restClient loadFile:dropboxPath intoPath:[self photosPath:imageName]];
}
- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata {
//    NSLog(@"File loaded into path: %@", localPath);
    NSLog(@"File loaded");
    DropBoxImage *tempDownloadedImage=[self loadSinglePhotoAfterDownload:metadata];
    if (_downloadedFileToDropbox) {
        _downloadedFileToDropbox(YES,nil,tempDownloadedImage);
    }
}
-(DropBoxImage*)loadSinglePhotoAfterDownload:(DBMetadata*)downloadedImageMetadata{
    if (!downloadedImageMetadata.isDeleted) {
        DropBoxImage *tempImage=[[DropBoxImage alloc]init];
        tempImage.dbPath=downloadedImageMetadata.path;
        tempImage.imageName=downloadedImageMetadata.filename;
        tempImage.revNum=downloadedImageMetadata.rev;
        NSString *fullPath=[NSString stringWithFormat:@"%@/%@",[self getLocalPathForImages],tempImage.imageName];
        tempImage.localPath=fullPath;
        UIImage *downloadedImage=[UIImage imageWithContentsOfFile:fullPath];
        if (downloadedImage) {
            tempImage.originalImage=downloadedImage;
        }
        return tempImage;
    }else{
        return nil;
    }
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
    if (_downloadedFileToDropbox) {
        _downloadedFileToDropbox(NO,error,nil);
    }
}

#pragma mark- NSFileManager related
-(NSString*)getLocalPathForImages{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    
    NSString    *filePath = [NSString stringWithFormat:@"%@/photos", documentsDirectory];
    return filePath;
}
-(void)removeFileFromPath:(NSString*)pathToFile{
    NSError *error;
    if ([[NSFileManager defaultManager] isDeletableFileAtPath:pathToFile]) {
        BOOL success = [[NSFileManager defaultManager] removeItemAtPath:pathToFile error:&error];
        if (!success) {
            NSLog(@"Error removing file at path: %@", error.localizedDescription);
        }
    }
}
-(NSString*)photosPath:(NSString*)nameOfFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString   *filePath = [NSString stringWithFormat:@"%@/photos/%@", documentsDirectory,nameOfFile];
    NSString   *dirFilePath = [NSString stringWithFormat:@"%@/photos", documentsDirectory];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirFilePath]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dirFilePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        if (error) {
            NSLog(@"Error Creating Directory");
        }
    }
    return filePath;
}
#pragma mark- Initial Folder Creation
-(void)createFolderWithName:(NSString*)folderName{
    NSString *fullFolderName=[NSString stringWithFormat:@"/%@",folderName];
    [self.restClient createFolder:fullFolderName];
}
// Folder is the metadata for the newly created folder
- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder{
    NSLog(@"Created Folder Path %@",folder.path);
    NSLog(@"Created Folder name %@",folder.filename);

}
- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error{
    NSLog(@"%@",error);
    
}
- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath metadata:(DBMetadata*)metadata{
    if (_loadedThumbnailImage) {
        _loadedThumbnailImage(YES,nil);
    }
}
- (BOOL)removeAllThumbnails{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString   *filePath = [NSString stringWithFormat:@"%@/thumb", documentsDirectory];
    return [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
}
-(NSString*)thumbnailPath:(NSString*)nameOfFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString   *filePath = [NSString stringWithFormat:@"%@/thumb/%@", documentsDirectory,nameOfFile];
    NSString   *dirFilePath = [NSString stringWithFormat:@"%@/thumb", documentsDirectory];

    if (![[NSFileManager defaultManager] fileExistsAtPath:dirFilePath]){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:dirFilePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        if (error) {
            NSLog(@"Error Creating Directory");
        }
    }
    return filePath;
}
- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error{
    
}
#pragma mark- Delete Related
-(void)deletePath:(NSString*)pathToDelete{
    [self.restClient deletePath:pathToDelete];
}
- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path{
    NSLog(@"Deleted path %@",path);
    if (_deletedPath) {
        _deletedPath(YES,nil);
    }
}
- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error{
    NSLog(@"Failed to delete path.");
    if (_deletedPath) {
        _deletedPath(NO,error);
    }
}
#pragma mark- Blocks
-(void)receivedMetadataFromDropbox:(void(^)(BOOL success, NSArray* metadataContentsArray))receivedMetadataFromDropboxCallback{
    _receivedMetadataFromDropbox=receivedMetadataFromDropboxCallback;
}
-(void)uploadedFileToDropbox:(void(^)(BOOL success, NSError*error))uploadedFileToDropboxCallback{
    _uploadedFileToDropbox=uploadedFileToDropboxCallback;
}
-(void)downloadedFileToDropbox:(void(^)(BOOL success, NSError*error, DropBoxImage* imageObject))downloadedFileToDropboxCallback{
    _downloadedFileToDropbox=downloadedFileToDropboxCallback;
}
-(void)receivedMetadataFromDropboxPictures:(void(^)(BOOL success,NSArray* metadataContentsArray))receivedMetadataFromDropboxPicturesCallback{
    _receivedMetadataFromDropboxPictures=receivedMetadataFromDropboxPicturesCallback;
}
-(void)loadedThumbnailImage:(void(^)(BOOL success, NSError*error))loadedThumbnailImageCallBack{
    _loadedThumbnailImage=loadedThumbnailImageCallBack;
}
-(void)deletedPath:(void(^)(BOOL success, NSError*error))deletedPathCallback{
    _deletedPath=deletedPathCallback;
}

@end
