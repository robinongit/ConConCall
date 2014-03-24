//
//  SCCDCache.h
//  SimpleconfCallDialer
//
//  Created by Robin Lin on 3/19/14.
//  Copyright (c) 2014 Robin Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ConfCall.h"

@interface SCCDCache : NSObject

+ (id)sharedCache;

- (NSArray *)confCallNumbers;
- (void) setConfCallNumber:(ConfCall *)confCall;
- (void) deleteConfCallNumber:(NSInteger) index;
- (void) editConfCallNumber:(ConfCall *)updatedConfCall atIndex:(NSInteger)index;

@end
