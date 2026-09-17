//
//  LaAvatarVC.h
//  WildFireChat
//
//  Created by Rubyuer on 7/22/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^AvatarSetBlock)(NSString *);
@interface LaAvatarVC : LaMainVC
@property BOOL isRegister;
@property AvatarSetBlock setBlock;
@end


@interface LaAvatarCVCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoIconV;

@end

NS_ASSUME_NONNULL_END
