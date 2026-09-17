//
//  LaCommunityVC.m
//  WildFireChat
//
//  Created by Rubyuer on 8/12/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaCommunityVC.h"

@interface LaCommunityVC ()

@property (weak, nonatomic) IBOutlet UILabel *csoeoxCommunityL;

@property (weak, nonatomic) IBOutlet UILabel *csoeoxStatusL;



@end

@implementation LaCommunityVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([CommonHelper.main isChinese]) {
        _csoeoxStatusL.text = @"此功能即将上线";
    }else {
        _csoeoxStatusL.text = @"Tính năng này sẽ được kích hoạt";
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _csoeoxCommunityL.text = LLLLLL(@"Community");

}

@end
