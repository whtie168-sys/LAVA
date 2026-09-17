//
//  LaCustomerServiceVC.m
//  WildFireChat
//
//  Created by Rubyuer on 2/29/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaCustomerServiceVC.h"

@interface LaCustomerServiceVC ()

@property (weak, nonatomic) IBOutlet UILabel *openL;

@end

@implementation LaCustomerServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"CustomerService");
    
    if ([CommonHelper.main isChinese]) {
    }else {
        _openL.text = @"Tính năng này sẽ sớm mở";
    }
}


@end
