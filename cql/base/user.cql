CREATE KEYSPACE IF NOT EXISTS user with replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

use user;
// 用户反馈
CREATE TABLE IF NOT EXISTS feedback
(
    user_id      uuid,      // 用户ID
    id           uuid,      // 反馈id
    content      text,      // 反馈内容
    status       int,       // 状态 0 代表未处理 1 代表已处理
    created_time timestamp, // 创建时间
    updated_time timestamp, // 更新时间
    is_deleted   boolean,   // 是否删除
    PRIMARY KEY (user_id, created_time, id)
) WITH CLUSTERING ORDER BY (created_time desc);

//#############################
CREATE TABLE IF NOT EXISTS phone_code
(
    phone        text,      // 手机号
    code         text,      // 验证码
    created_time timestamp, // 创建时间
    PRIMARY KEY (phone)
) WITH default_time_to_live = 600;


//#############################
// 创建一个文件信息类型
CREATE TYPE IF NOT EXISTS file_info
    (
        id                uuid,
        domain            text, // 文件存储域名
        base_path         text, // 基础路径
        storage_file_name text, // 文件地址
    );

// 自定义分组信息 包括成员
CREATE TABLE IF NOT EXISTS user_groups
(
    organization_id uuid,              // 组织ID
    id              uuid,
    name            text,
    avatar          frozen<file_info>, // 头像使用文件信息类型
    size            int,
    abbreviation    text,
    color           text,
    character       text,
    relation        map<uuid,timestamp>,
    created_time    timestamp,         // 创建时间
    updated_time    timestamp,         // 更新时间
    is_deleted      boolean,           // 是否删除
    PRIMARY KEY (organization_id, id)
);

CREATE CUSTOM INDEX user_groups_is_deleted ON user_groups (is_deleted)
    USING 'StorageAttachedIndex';
//#############################
// 用户创建的自定义分组
CREATE TABLE IF NOT EXISTS user_group_relas
(
    organization_id uuid,                // 组织ID
    user_id         uuid,                // 用户ID
    groups          map<uuid,timestamp>, // 对应当前用户在该组织的自定义分组
    PRIMARY KEY (organization_id, user_id)
);
//#############################
// 创建一个文件信息类型
CREATE TYPE IF NOT EXISTS file_info
    (
        id                uuid,
        domain            text, // 文件存储域名
        base_path         text, // 基础路径
        storage_file_name text, // 文件地址
    );

// 自定义分组信息 包括成员
CREATE TABLE IF NOT EXISTS user_infos
(
    id                   uuid,      // 用户ID
    name                 text,      // 真实姓名
    nickname             text,      // 昵称
    avatar               file_info, // 头像
    phone                text,      // 手机号
    password             text,      // 密码
    wechat               text,      // 微信
    gender               text,      // 性别
    age                  int,       // 年龄
    work_start_time      timestamp, // 工作时间
    birthday             timestamp, // 生日
    region               text,      // 地区
    hometown             text,      // 家乡
    email                text,      // 邮箱
    email_verify         boolean,   // 邮箱是否验证
    signature            text,      // 个性签名
    permissions          int,       // 权限
    phone_display        int,       // 手机号是否可用
    disabled             int,       // 用户是否可用
    memo_color           text,      // memo颜色
    created_time         timestamp, // 创建时间
    updated_time         timestamp, // 更新时间
    okr_count            int,       // okr数量
    public_content_count int,       // 公开日志数量
    name_change_limit    int,       // 修改名字次数
    name_change_time     timestamp, // 修改名字时间
    PRIMARY KEY (id)
);
CREATE MATERIALIZED VIEW IF NOT EXISTS user_infos_by_phone AS
SELECT phone, id, disabled
FROM user_infos
WHERE phone IS NOT NULL
  AND id IS NOT NULL
PRIMARY KEY (phone, id);

CREATE CUSTOM INDEX user_info_disabled ON user_infos (disabled)
    USING 'StorageAttachedIndex';

//#############################
CREATE TABLE IF NOT EXISTS user_interest
(
    user_id     uuid,                 // 用户ID
    follow_list map<uuid, timestamp>, // 关注列表
    PRIMARY KEY (user_id)
);
//#############################
CREATE TABLE IF NOT EXISTS user_login
(
    id             uuid,
    device_id      text,      -- 设备id
    user_id        uuid,
    login_type     int,       // 登录类型
    login_account  text,      // 登录账号
    ip             text,
    login_out_time timestamp,
    login_time     timestamp,
    created_time   timestamp, // 创建时间
    updated_time   timestamp, // 更新时间
    is_deleted     boolean,   // 是否删除
    PRIMARY KEY (user_id, id)
);

CREATE CUSTOM INDEX user_login_is_deleted ON user_login (is_deleted)
    USING 'StorageAttachedIndex';
//#############################
// 用户偏好设置表
CREATE TABLE IF NOT EXISTS user_preferences
(
    user_id                 uuid,      // 用户ID
    notification            boolean,   // 是否接收消息通知
    like_reminder           boolean,   // 点赞消息通知
    comment_reminder        boolean,   // 评论消息通知
    follow_message_reminder boolean,   // 关注用户消息通知
    created_time            timestamp, // 创建时间
    updated_time            timestamp, // 更新时间
    is_deleted              boolean,   // 是否删除
    PRIMARY KEY (user_id)
);

CREATE CUSTOM INDEX user_preferences_is_deleted ON user_preferences (is_deleted)
    USING 'StorageAttachedIndex';
//#############################
CREATE TABLE IF NOT EXISTS verify_emails
(
    id      uuid, // 唯一ID
    user_id uuid, // 用户ID
    email   text, // 邮箱
    PRIMARY KEY (id)
) WITH default_time_to_live = 600;
// 数据默认十分钟过期

//#############################
CREATE TABLE IF NOT EXISTS organization_follow_list
(
    organization_id uuid,           // 组织ID
    user_id         uuid,           // 用户ID
    follow_list     map<uuid,uuid>, // 用户ID对应分组ID
    created_time    timestamp,      // 创建时间
    updated_time    timestamp,      // 更新时间
    deleted_time    timestamp,      // 删除时间
    is_deleted      boolean,        // 是否删除
    PRIMARY KEY (organization_id, user_id)
);