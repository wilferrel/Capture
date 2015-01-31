//
//  AppState.h
//  Capture
//
//  Created by Wil Ferrel on 1/31/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppState : NSObject
@property (assign, nonatomic) BOOL authenticated;
+ (AppState*)sharedInstance;

@end
