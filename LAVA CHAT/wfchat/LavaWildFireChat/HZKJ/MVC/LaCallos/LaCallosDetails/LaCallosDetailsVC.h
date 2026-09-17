//
//  LaCallosDetailsVC.h
//  WildFireChat
//
//  Created by Ruby on 11/6/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaCallosDetailsVC : LaMainVC

@property (nonatomic, strong) NSMutableArray<AddAudioModel *> *dataSource;

@property(nonatomic, copy)void (^callosDeleteSuccessBlock)(void);

@end

@interface LaCallosRecordCVCell : UITableViewCell

@property (nonatomic, strong) AddAudioModel *audioModel;

@end


NS_ASSUME_NONNULL_END
