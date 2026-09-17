//
//  LaSearchFriendVC.h
//  LAVA
//
//  Created by Rubyuer on 10/10/23.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaSearchFriendVC : LaMainVC

@property (nonatomic, copy) NSString *phoneString;

@end

@interface LaSearchUserCVCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@end



@interface LaSearchUserCRView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *asoucTitleLabel;

@end

NS_ASSUME_NONNULL_END
