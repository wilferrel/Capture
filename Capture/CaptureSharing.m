//
//  CaptureSharing.m
//  Capture
//
//  Created by Wil Ferrel on 1/30/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "CaptureSharing.h"

@implementation CaptureSharing
+(void)shareToSocialWithImage:(UIImage*)imageForPost andText:(NSString*)textForPost fromVC:(UIViewController*)parentVC{
    
    NSString *message= @"Picture sharing by Capture";
    if ([textForPost length]>0) {
        message=textForPost;
    }
    NSMutableArray * shareItems = [[NSMutableArray alloc]init];;
    [shareItems addObject:message];
    if (imageForPost) {
        [shareItems addObject:imageForPost];
    }
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    [parentVC presentViewController:avc animated:YES completion:nil];
}

@end
