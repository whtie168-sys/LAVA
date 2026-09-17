//
//  LaComplaintVC.m
//  LAVA
//
//  Created by Rubyuer on 10/17/23.
//

#import "LaComplaintVC.h"
#import "LaComplaintBBVC.h"


@interface LaComplaintVC ()

@property (weak, nonatomic) IBOutlet UILabel *complaintAL;
@property (weak, nonatomic) IBOutlet UILabel *complaintBL;
@property (weak, nonatomic) IBOutlet UILabel *complaintCL;

@end

@implementation LaComplaintVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"CauseOfComplaint");
    
    _complaintAL.text = LLLLLL(@"ComplaintDescA");
    _complaintBL.text = LLLLLL(@"ComplaintDescB");
    _complaintCL.text = LLLLLL(@"ComplaintDescC");
}


- (IBAction)oxaicsgoeComplaint:(UIButton *)sender {
    LaComplaintBBVC *vc = LaComplaintBBVC.new;
    vc.reason = @[_complaintAL.text, _complaintAL.text, _complaintCL.text, @""][sender.tag];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
