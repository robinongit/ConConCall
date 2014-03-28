//
//  SCCDCache.m
//  SimpleconfCallDialer
//
//  Created by Robin Lin on 3/19/14.
//  Copyright Robin Lin 2014.



#import "SCCDCache.h"

@interface SCCDCache ()

@property (nonatomic, strong) NSCache *cache;

@end


@implementation SCCDCache

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - SCCDCache

- (void)clear {
    [self.cache removeAllObjects];

    NSString *key = kSCCDUserDefaultsCacheconfCallNumbers;
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (NSArray *)confCallNumbers {
    NSString *key = kSCCDUserDefaultsCacheconfCallNumbers;
    
    if ([self.cache objectForKey:key]) {
        return [self NSArrayToConfCallArray:[self.cache objectForKey:key]];
    }
    
    NSArray *confcallArray = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSArray *confcallAsConfCallObj = [self NSArrayToConfCallArray:confcallArray];
    
    if (confcallArray) {
        [self.cache setObject:confcallArray forKey:key];
    }
    
    return confcallAsConfCallObj;
}

- (void) deleteConfCallNumber:(NSInteger) index {
    NSString *key = kSCCDUserDefaultsCacheconfCallNumbers;
    NSMutableArray *allConfCallsMutable;
    NSArray *allConfCalls;
    
    allConfCallsMutable = [NSMutableArray arrayWithArray:[self getConfCallArray]];
    
    [allConfCallsMutable removeObjectAtIndex:index];
    allConfCalls = [allConfCallsMutable copy];

    [self.cache setObject:allConfCalls forKey:key];
    
    [[NSUserDefaults standardUserDefaults] setObject:allConfCalls forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void) editConfCallNumber:(ConfCall *)updatedConfCall atIndex:(NSInteger)index {
    
    NSString *key = kSCCDUserDefaultsCacheconfCallNumbers;
    NSMutableArray *allConfCallsMutable;
    NSArray *allConfCalls;
    
    allConfCallsMutable = [NSMutableArray arrayWithArray:[self getConfCallArray]];
    NSArray *confCallArrayToEdit = [self ConfCallObjToNSArray:updatedConfCall];

    [allConfCallsMutable replaceObjectAtIndex:index withObject:confCallArrayToEdit];
    allConfCalls = [allConfCallsMutable copy];
    
    [self.cache setObject:allConfCalls forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:allConfCalls forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (NSArray *) getConfCallArray {
    NSString *key = kSCCDUserDefaultsCacheconfCallNumbers;
    NSArray *confCallArray;
    
    if ([self.cache objectForKey:key]) {
        confCallArray = [self.cache objectForKey:key];
    }
    else {
        confCallArray = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (confCallArray == nil) {
            confCallArray = [[NSArray alloc] init];
        }
    }
    return confCallArray;
}

- (void) setConfCallNumber:(ConfCall *)confCall {
    NSString *key = kSCCDUserDefaultsCacheconfCallNumbers;
    NSMutableArray *allConfCallsMutable;
    NSArray *allConfCalls;
    
    NSArray *confCallArrayToAdd = [self ConfCallObjToNSArray:confCall];
    allConfCallsMutable = [NSMutableArray arrayWithArray:[self getConfCallArray]];

    NSArray *currObj;
    NSString *currNickname;
    if ([allConfCallsMutable count] == 0) {
        [allConfCallsMutable addObject:confCallArrayToAdd];
    }
    else {
        for (NSUInteger i=0; i < [allConfCallsMutable count]; i++) {
            currObj = [allConfCallsMutable objectAtIndex:i];
            currNickname = [currObj objectAtIndex:0];
            if ([currNickname caseInsensitiveCompare:confCall.confCallNickname] == NSOrderedDescending)  {
                // currNickname comes alphabetically after confCall.confCallNickname
                // since we assume that the allConfCallsMutable is already alphabetical then insert object before current one
                [allConfCallsMutable insertObject:confCallArrayToAdd atIndex:i];
                break;
            }
            else if (i == [allConfCallsMutable count]-1) {
                // last object is still alphabetically before confCall.confCallNikname so just stick it in at the end
                [allConfCallsMutable addObject:confCallArrayToAdd];
                break;
            }
        }
    }
    
    allConfCalls = [allConfCallsMutable copy];
    [self.cache setObject:allConfCalls forKey:key];
    
    [[NSUserDefaults standardUserDefaults] setObject:allConfCalls forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (NSArray *) ConfCallObjToNSArray:(ConfCall *)confCall {
    NSArray *confArray = [[NSArray alloc] initWithObjects:
                          confCall.confCallNickname,
                          confCall.confCallDialInNumber,
                          confCall.confCallCode,
                          nil];
    return confArray;
}

- (NSArray *) NSArrayToConfCallArray:(NSArray *)confCallArray {
    
    NSMutableArray *mutableA = [[NSMutableArray alloc] init];
    for (NSUInteger i=0; i<[confCallArray count]; i++) {
        NSArray *ccA = [confCallArray objectAtIndex:i];
        ConfCall *ccO = [[ConfCall alloc] init];
        ccO.confCallNickname = [ccA objectAtIndex:0];
        ccO.confCallDialInNumber = [ccA objectAtIndex:1];
        ccO.confCallCode = [ccA objectAtIndex:2];
        [mutableA addObject:ccO];
    }
    
    return [mutableA copy];
}

@end
