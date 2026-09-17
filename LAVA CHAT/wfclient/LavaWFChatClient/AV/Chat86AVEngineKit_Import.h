//
//  Chat86AVEngineKit.h
//  Chat86AVEngineKit
//
//  Created by heavyrain on 17/9/27.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Chat86AVEngineKit : NSObject
+ (instancetype _Nonnull)sharedEngineKit;
@property(nonatomic, assign, readonly)BOOL supportMultiCall;
@property(nonatomic, assign, readonly)BOOL supportConference;
- (NSString *)checkAddress:(NSString *_Nonnull)host;
@end
