//
//  WDCARFaceEmojCustomCell.m
//  WFChatUIKit
//
//  Created by wtb on 2025/5/16.
//  Copyright © 2025 Tom Lee. All rights reserved.
//

#import "WDCARFaceEmojCustomCell.h"

@implementation WDCARFaceEmojCustomCell

- (WDCARFaceButton *)emojBtn {
    if (!_emojBtn) {
        _emojBtn = [[WDCARFaceButton alloc] init];
        [self.contentView addSubview:_emojBtn];
    }
    return _emojBtn;
}

@end
