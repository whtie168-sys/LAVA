//
//  GeneralModifyViewController.m
//  WildFireChat
//
//  Created by heavyrain lee on 24/12/2017.
//  Copyright © 2017 WildFireChat. All rights reserved.
//

#import "RWADCGeneralModifyVC.h"
#import "MBProgressHUD.h"
#import "QWERConfigManager.h"
#import "QWERUtilities.h"

@interface RWADCGeneralModifyVC () <UITextFieldDelegate>
@property (nonatomic, strong)UITextField *textField;
@end

@implementation RWADCGeneralModifyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.titleText) {
        [self setTitle:_titleText];
    }
    
    self.textField.text = self.defaultValue;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:WFCString(@"Cancel") style:UIBarButtonItemStyleDone target:self action:@selector(onCancel:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:WFCString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(onDone:)];
    
    self.view.backgroundColor = [QWERConfigManager globalManager].backgroudColor;
    
    [self.textField becomeFirstResponder];
}

- (void)onCancel:(id)sender {
  [self.textField resignFirstResponder];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onDone:(id)sender {
  [self.textField resignFirstResponder];
    __weak typeof(self) ws = self;
    
    __block MBProgressHUD *hud;
    if (!self.noProgress) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = WFCString(@"Updating");
        [hud showAnimated:YES];
    }
    
    self.tryModify(self.textField.text, ^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!self.noProgress) {
                [hud hideAnimated:NO];
            }
            
            if(success) {
                [ws.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                if (!self.noProgress) {
                    hud = [MBProgressHUD showHUDAddedTo:ws.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = WFCString(@"UpdateFailure");
                    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                    [hud hideAnimated:YES afterDelay:1.f];
                }
            }
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITextField *)textField {
    if(!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, [QWERUtilities wf_navigationFullHeight] + 20, [UIScreen mainScreen].bounds.size.width, 32)];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.clearButtonMode = UITextFieldViewModeAlways;
        _textField.delegate = self;
        [self.view addSubview:_textField];
    }
    return _textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self onDone:textField];
    return YES;
}
@end
