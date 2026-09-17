//
//  ESZQSCOrganizationPath.h
//  WFChatUIKit
//
//  Created by Rain on 2022/12/29.
//  Copyright © 2022 Wildfire Chat. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ESZQSCOrganization;
@class ESZQSCEmployee;

NS_ASSUME_NONNULL_BEGIN

@interface ESZQSCOrganizationEx : NSObject
@property (nonatomic, assign)NSInteger organizationId;
@property(nonatomic, strong)ESZQSCOrganization *organization;
@property(nonatomic, strong)NSArray<ESZQSCOrganization *> *subOrganizations;
@property(nonatomic, strong)NSArray<ESZQSCEmployee *> *employees;
@end

NS_ASSUME_NONNULL_END
