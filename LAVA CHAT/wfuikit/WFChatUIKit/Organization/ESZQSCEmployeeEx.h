//
//  ESZQSCEmployeeEx.h
//  WFChatUIKit
//
//  Created by Rain on 2022/12/29.
//  Copyright © 2022 Wildfire Chat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESZQSCEmployee;
@class ESZQSCOrgRelationship;
NS_ASSUME_NONNULL_BEGIN

@interface ESZQSCEmployeeEx : NSObject
@property(nonatomic, strong)NSString *employeeId;
@property(nonatomic, strong)ESZQSCEmployee *employee;
@property(nonatomic, strong)NSArray<ESZQSCOrgRelationship *> *relationships;
@end

NS_ASSUME_NONNULL_END
