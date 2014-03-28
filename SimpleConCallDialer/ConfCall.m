//
//  confCall.m
//  SimpleconfCallDialer
//
//  Created by Robin Lin on 3/19/14.
//
//  Copyright Robin Lin 2014.



#import "ConfCall.h"

static NSString *DefaultconfCallNickname = @"Conference Call Name";

@implementation ConfCall

- (id) init {
    if ((self = [super init])) {
        self.confCallNickname = DefaultconfCallNickname;
    }
    return self;
}

- (BOOL) isDefaultNickname {
    return [self.confCallNickname isEqualToString:DefaultconfCallNickname];
}

- (BOOL) hasDialInNumber {
    return (self.confCallDialInNumber.length > 0);
}

@end
