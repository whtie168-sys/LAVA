//
//  LaContactInfoTVCell.h
//  LAVA
//
//  Created by Rubyuer on 10/22/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaContactInfoTVCell : UITableViewCell

@property (nonatomic, strong) WFCCUserInfo *model;

@property (weak, nonatomic) IBOutlet UIButton *oxgcseoaiSelectButton;

@end

NS_ASSUME_NONNULL_END
