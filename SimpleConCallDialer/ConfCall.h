//
//  ConfCall.h
//  SimpleConfCallDialer
//
//  Created by Robin Lin on 3/19/14.
//  Copyright (c) 2014 Robin Lin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfCall : NSObject

@property (nonatomic, strong) NSString *confCallNickname;
@property (nonatomic, strong) NSString *confCallDialInNumber;
@property (nonatomic, strong) NSString *confCallCode;
@property (nonatomic, assign) NSInteger tag;

- (BOOL) isDefaultNickname;
- (BOOL) hasDialInNumber;

@end
