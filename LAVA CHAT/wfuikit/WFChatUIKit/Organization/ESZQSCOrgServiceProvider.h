//
//  WFCUAppService.h
//  WFChatUIKit
//
//  Created by Heavyrain Lee on 2019/10/22.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ESZQSCOrganization;
@class ESZQSCEmployee;
@class ESZQSCOrgRelationship;
@class ESZQSCOrganizationEx;
@class ESZQSCEmployeeEx;

@protocol ESZQSCOrgServiceProvider <NSObject>
- (void)getRelationship:(NSString *)employeeId
                success:(void(^)(NSArray<ESZQSCOrgRelationship *> *))successBlock
                  error:(void(^)(int error_code))errorBlock;

- (void)getRootOrganization:(void(^)(NSArray<ESZQSCOrganization *> *))successBlock
                  error:(void(^)(int error_code))errorBlock;

- (void)getOrganizationEx:(NSInteger)organizationId
                    success:(void(^)(ESZQSCOrganizationEx *path))successBlock
                  error:(void(^)(int error_code))errorBlock;

- (void)getOrganizations:(NSArray<NSNumber *> *)organizationIds
                 success:(void(^)(NSArray<ESZQSCOrganization *> *organizations))successBlock
                   error:(void(^)(int error_code))errorBlock;

- (void)getBatchOrgEmployees:(NSArray<NSNumber *> *)orgIds
                success:(void(^)(NSArray<NSString *> *employeeIds))successBlock
                  error:(void(^)(int error_code))errorBlock;

- (void)getOrgEmployees:(NSInteger)orgId
                success:(void(^)(NSArray<NSString *> *employeeIds))successBlock
                  error:(void(^)(int error_code))errorBlock;

- (void)getEmployee:(NSString *)employeeId
            success:(void(^)(ESZQSCEmployee *employee))successBlock
              error:(void(^)(int error_code))errorBlock;


- (void)getEmployeeEx:(NSString *)employeeId
              success:(void(^)(ESZQSCEmployeeEx *employeeEx))successBlock
                error:(void(^)(int error_code))errorBlock;

- (void)searchEmployee:(NSInteger)organizationId
               keyword:(NSString *)keyword
               success:(void(^)(NSArray<ESZQSCEmployee *> *employees))successBlock
                 error:(void(^)(int error_code))errorBlock;
@end

NS_ASSUME_NONNULL_END
