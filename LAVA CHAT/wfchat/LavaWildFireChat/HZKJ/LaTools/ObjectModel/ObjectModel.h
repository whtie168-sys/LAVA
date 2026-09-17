//
//  ObjectModel.h
//  LAVA
//
//  Created by Rubyuer on 10/10/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectModel : NSObject

@end

@class AddAudioJSON;
@interface AddAudioModel : NSObject

@property (nonatomic, copy)   NSString *id; 
@property (nonatomic, copy)   NSString *userId; // 当前用户ID

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) long long createdTime; // 当前时间戳(毫秒)

@property (nonatomic, strong) AddAudioJSON    *jsonObject;

// 0131 新增 标记编辑选择
@property (nonatomic, assign) BOOL    isSelect;

@end

@interface AddAudioJSON : NSObject

@property (nonatomic, assign)   NSInteger time; // 通话时长(s)  成功建立通话状态后该字段有值。默认为0
@property (nonatomic, assign)   NSInteger status; // 状态 0 已取消(包括对方挂断)。1 未接听
@property (nonatomic, assign)   NSInteger call_out_in; // 0 呼出。 1 呼入
@property (nonatomic, assign) NSInteger callType; // 0 语音    1 视频

@property (nonatomic, copy)   NSString *targetId; // 接收方ID

@end

@interface UserExtraInfo : NSObject

@property (nonatomic, copy)   NSString *sign; // 个性签名

@property (nonatomic, assign) long long lastLoginTime; // 当前时间戳(毫秒)

@property (nonatomic, assign) NSInteger disableAutoAddFriend; // 加我为朋友时是否需要验证
// 是否显示最后上线时间   0 所有人    1 仅通讯录联系人    2 不显示在线时间
@property (nonatomic, assign) NSInteger disableShowLastLoginTime;
@property (nonatomic, assign) NSInteger disableShowPhone; // 对朋友是否展示电话号码
@property (nonatomic, assign) NSInteger disableJoinToGroup; // 邀请我加入群聊是否需要验证
@property (nonatomic, assign) NSInteger disableShowInputState; // 是否展示输入状态

// 添加我的方式
@property (nonatomic, assign) NSInteger openMobileSearch; // 手机号码
@property (nonatomic, assign) NSInteger openAccountSearch; // 86ID号

// 通知设置 ---> 声音 和 震动
@property (nonatomic, assign) NSInteger sound; // 声音
@property (nonatomic, assign) NSInteger shake; // 震动

@property (nonatomic, assign) long long birthday; //生日
@end

@interface GroupExtraInfo : NSObject

@property (nonatomic, copy)   NSString *groupId; // 群ID

@property (nonatomic, assign) NSInteger disableAddFriend; // 是否禁止群成员互加好友
@property (nonatomic, assign) NSInteger disableSendMessage; // 全员禁言   无用
@property (nonatomic, assign) long long autoDelete; // 阅后即焚 0 关闭   非0: 开启的时间戳
@property (nonatomic, assign) NSInteger waitTime; // 阅后即焚的等待时间
@property (nonatomic, assign) NSInteger needReview; // 进群是否需要审核

@end



#pragma mark - 群通知

@interface WaitAcceptList : NSObject // 列表(申请/审核)
/**
 如果为邀请 requestUser 是邀请人 checkUser是被邀请人
 如果为申请 requestUser 是申请人 checkUser是审核人
 */
@property (nonatomic, assign) NSInteger accept; // 0 待审核、1 已同意、2 被拒绝
@property (nonatomic, assign) WFCUGroupMemberSourceType source; // 来源
@property (nonatomic, assign) NSInteger type; // 0 申请加入   1 被邀请加入

@property (nonatomic, assign) long long updateTime;

@property (nonatomic, copy)   NSString *group; //
@property (nonatomic, copy)   NSString *groupId; //
@property (nonatomic, copy)   NSString *id; //
@property (nonatomic, copy)   NSString *remark; //

@property (nonatomic, copy)   NSString *inviteUser;
@property (nonatomic, copy)   NSString *inviteUserId; // 只有被邀请且群主审核阶段才有

@property (nonatomic, copy)   NSString *checkUser;
@property (nonatomic, copy)   NSString *checkUserId;
@property (nonatomic, copy)   NSString *requestUser;
@property (nonatomic, copy)   NSString *requestUserId; //

@end



@interface DeviceHistory : NSObject // 我的-安全设置-设备列表

@property (nonatomic, copy)   NSString *id;
@property (nonatomic, copy)   NSString *deviceId;
@property (nonatomic, copy)   NSString *ip; // ip地址
@property (nonatomic, copy)   NSString *type; // 设备型号
@property (nonatomic, copy)   NSString *userId;

@property (nonatomic, assign) long long lastLogin;

@end



@class MessageContent;
@interface MessageTopList : NSObject // 群消息 - 消息置顶

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) long long messageUid;

@property (nonatomic, copy) NSString *groupId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *fromUser;

@property (nonatomic, strong) MessageContent *content;

@end


@interface MessageContent : NSObject // 消息体

/** type
 * 1  文本消息
 * 5  文件消息
 * 1001  公告消息
 * 2000 自定义  是否更新了群公告内容的群公告  - 也就是原先的公告弹窗集成在这里面了、
 */
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *searchableContent;

@property (nonatomic, copy) NSString *remoteMediaUrl; // 文件消息的文件路径

@end



@interface AvatarHistoryList : NSObject // 头像 - 历史更改头像

@property (nonatomic, assign) NSInteger id;
@property (nonatomic, assign) NSInteger type;

@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *portrait;

@end



NS_ASSUME_NONNULL_END
