//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "WDCARFaceBoard.h"

#import "WDCARStickerItem.h"
#import "YLImageView.h"
#import "YLGIFImage.h"
#import "WDCARFaceButton.h"
#import "QWERImage.h"
#import "QWERUtilities.h"
#import <LavaWFChatClient/WFCChatClient.h>

#import "WDCARFaceEmojBoard.h"
#import "UIColor+YH.h"
#import "WDCARFaceCustomBoard.h"
#import "EmojiManagerView.h"


@interface WDCARFaceBoard() <UIScrollViewDelegate,WDCARFaceEmojBoardDelegate,WDCARFaceCustomBoardDelegate,EmojiManagerViewDelegate>
@property(nonatomic,strong)UIView *tabbarView;

@property(nonatomic, strong)UIScrollView *tabView;

@property(nonatomic, strong)WDCARFaceEmojBoard *faceEmojView;

@end

#define EMOJ_TAB_HEIGHT 75
#define EMOJ_FACE_VIEW_HEIGHT 190
#define EMOJ_PAGE_CONTROL_HEIGHT 20

#define EMOJ_AREA_HEIGHT (EMOJ_TAB_HEIGHT + EMOJ_FACE_VIEW_HEIGHT + EMOJ_PAGE_CONTROL_HEIGHT)
@implementation WDCARFaceBoard{
    int width;
    int location;
}

@synthesize delegate;

- (id)init {
    width = [UIScreen mainScreen].bounds.size.width;
    self = [super initWithFrame:CGRectMake(0, 0, width, EMOJ_AREA_HEIGHT + [QWERUtilities wf_safeDistanceBottom] + 42)];
    
    if (self) {
        _tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, EMOJ_TAB_HEIGHT)];
        _tabbarView.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
        [self addSubview:_tabbarView];
                
        NSArray *imgs = @[@"表情",@"喜欢",@"宠物",@"旗帜",@"足球"];
        for (int i = 0; i<imgs.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20+65*i, 5, 40, 40)];
            [btn setImage:[QWERImage imageNamed:imgs[i]] forState:UIControlStateNormal];
            [btn setBackgroundImage:[QWERImage imageNamed:@"chatinputbar_emoj_select"] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(emojAct:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [_tabbarView addSubview:btn];
            
            if (i == 0) {
                btn.selected = YES;
            }
        }
        
        //键盘向上弹出
        UIView *highV = [[UIView alloc] initWithFrame:CGRectMake(0, 55, self.frame.size.width, 20)];
        highV.backgroundColor = [UIColor colorWithHexString:@"#FBFBFB"];
        [_tabbarView addSubview:highV];
        
        UIButton *highbtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
        [highbtn setImage:[QWERImage imageNamed:@"chatinputbar_emoj_higher"] forState:UIControlStateNormal];
        [highbtn addTarget:self action:@selector(upAct:) forControlEvents:UIControlEventTouchUpInside];
        [highV addSubview:highbtn];

        _tabView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,EMOJ_TAB_HEIGHT,width, EMOJ_AREA_HEIGHT + [QWERUtilities wf_safeDistanceBottom] + 42-EMOJ_TAB_HEIGHT)];
        _tabView.showsHorizontalScrollIndicator = NO;
        _tabView.contentSize = CGSizeMake(self.frame.size.width*5, 0);
        _tabView.pagingEnabled = YES;
        _tabView.delegate = self;
        _tabView.backgroundColor = [UIColor colorWithHexString:@"#FBFBFB"];
        [self addSubview:_tabView];
        
                
        WDCARFaceEmojBoard *emoj = [[WDCARFaceEmojBoard alloc] initWithFrame:CGRectMake(0, 0, width, _tabView.bounds.size.height)];
        self.faceEmojView = emoj;
        emoj.delegate = self;
        [_tabView addSubview:emoj];
        
        EmojiManagerView *xihuanV = [[EmojiManagerView alloc] initWithFrame:CGRectMake(width, 0, width, _tabView.bounds.size.height)];
        xihuanV.delegate = self;
        [_tabView addSubview:xihuanV];

        
        WDCARFaceCustomBoard *chongwuV = [[WDCARFaceCustomBoard alloc] initWithFrame:CGRectMake(width*2, 0, width, _tabView.bounds.size.height) type:2];
        chongwuV.delegate = self;
        [_tabView addSubview:chongwuV];
        
        WDCARFaceCustomBoard *qizhiV = [[WDCARFaceCustomBoard alloc] initWithFrame:CGRectMake(width*3, 0, width, _tabView.bounds.size.height) type:3];
        qizhiV.delegate = self;
        [_tabView addSubview:qizhiV];

        WDCARFaceCustomBoard *zuqiuV = [[WDCARFaceCustomBoard alloc] initWithFrame:CGRectMake(width*4, 0, width, _tabView.bounds.size.height) type:4];
        zuqiuV.delegate = self;
        [_tabView addSubview:zuqiuV];
    }

    return self;
}

- (void)upAct:(UIButton*)sender {
    self.isUp = !self.isUp;
    if (self.isUp) {
        self.frame = CGRectMake(0, 0, width, EMOJ_AREA_HEIGHT + [QWERUtilities wf_safeDistanceBottom] + 42 + 200);
    } else {
        self.frame = CGRectMake(0, 0, width, EMOJ_AREA_HEIGHT + [QWERUtilities wf_safeDistanceBottom] + 42);
    }
    if (self.delegate) {
        [self.delegate isUpView:self.isUp];
    }

}

- (void)emojAct:(UIButton *)sender {
    for (UIView *v in _tabbarView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)v;
            btn.selected = NO;
        }
    }
    sender.selected = YES;
    [_tabView setContentOffset:CGPointMake(sender.tag*width, 0) animated:YES];
}

- (void)sendBtnHandle:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTouchSendEmoj)]) {
        [self.delegate didTouchSendEmoj];
    }
}

- (void)didTouchEmoj:(NSString *)emojString {
    if (self.delegate) {
        [self.delegate didTouchEmoj:emojString];
    }
}

- (void)didTouchBackEmoj {
    if (self.delegate) {
        [self.delegate didTouchBackEmoj];
    }
}

- (void)didTouchSendEmoj {
    if (self.delegate) {
        [self.delegate didTouchSendEmoj];
    }
}

- (void)didSelectedSticker:(NSString *)stickerPath {
    if ([self.delegate respondsToSelector:@selector(didSelectedSticker:)]) {
        [self.delegate didSelectedSticker:stickerPath];
    }
}

- (void)backFace{
    if ([delegate respondsToSelector:@selector(didTouchBackEmoj)]) {
        [delegate didTouchBackEmoj];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger currentPage = round(scrollView.contentOffset.x / scrollView.frame.size.width);
    for (UIView *v in _tabbarView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)v;
            btn.selected = NO;
            if (btn.tag == currentPage) {
                btn.selected = YES;
            }
        }
    }
}


@end
