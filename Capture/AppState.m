//
//  AppState.m
//  Capture
//
//  Created by Wil Ferrel on 1/31/15.
//  Copyright (c) 2015 WF. All rights reserved.
//

#import "AppState.h"

@implementation AppState
+ (AppState*)sharedInstance{
    static AppState *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (id)init {
    if (self = [super init]) {
        self.authenticated=NO;
    }
    return self;
}
@end
