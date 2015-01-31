//
//  CaptureSharing.h
//  Capture
//
//  Created by Wil Ferrel on 1/30/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CaptureSharing : NSObject
+(void)shareToSocialWithImage:(UIImage*)imageForPost andText:(NSString*)textForPost fromVC:(UIViewController*)parentVC;

@end
