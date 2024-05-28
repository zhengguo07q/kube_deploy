use user;

drop table if exists user_login;


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

use chat;

// 首先删除物化视图
drop materialized view if exists chat.device_by_user_id;
// 删除设备
drop table if exists chat.device;

CREATE TABLE IF NOT EXISTS device
(
    user_id        uuid,
    id             text,
    type           int,
    brand          text,
    conn_addr      text,
    client_addr    text,
    system_version text,
    sdk_version    text,
    machine        text,
    is_online      int,
    created_time   timestamp,
    updated_time   timestamp,
    is_deleted     boolean,
    PRIMARY KEY (user_id, id)
);


use organization;

drop table if exists organization.user_organization_relation;

// 存储用户加入的组织关系
CREATE TABLE IF NOT EXISTS user_organization_relation
(
    user_id               uuid,
    current_organization  uuid, // 存储当前浏览组织
    organizations         list<uuid>,
    history_organizations list<uuid>,
    PRIMARY KEY (user_id)
);