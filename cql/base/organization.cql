CREATE KEYSPACE IF NOT EXISTS organization with replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

use organization;

CREATE TABLE IF NOT EXISTS apply_message
(
    id              uuid,
    from_user_id    uuid,
    organization_id uuid,
    status          int,
    content         text,
    created_time    timestamp, // 创建时间即代表了申请时间
    updated_time    timestamp,
    allow_search    boolean,
    PRIMARY KEY (organization_id, created_time, id)
) WITH CLUSTERING ORDER BY (created_time desc);

CREATE MATERIALIZED VIEW IF NOT EXISTS apply_message_by_user AS
SELECT from_user_id, organization_id, id, created_time, status
FROM apply_message
WHERE from_user_id IS NOT NULL
  AND organization_id IS NOT NULL
  and created_time is not null
  and id is not null
PRIMARY KEY (from_user_id, organization_id, created_time, id);


//################################

// 存储组织的历史记录
CREATE TABLE IF NOT EXISTS organization_history
(
    id                uuid,
    user_id           uuid,
    organization_id   uuid,
    organization_type int,
    organization_name text,
    avatar            uuid,
    action            int,      // 执行的操作 1 加入组织 2 退出组织  3 解散组织
    created_time      timestamp,// 创建时间
    updated_time      timestamp,// 修改时间
    is_deleted        boolean,  // 是否删除
    PRIMARY KEY (organization_id, created_time, id)
) WITH CLUSTERING ORDER BY (created_time desc);

CREATE MATERIALIZED VIEW IF NOT EXISTS organization_history_by_user AS
SELECT *
FROM organization_history
WHERE user_id IS NOT NULL
  AND organization_id IS NOT NULL
  AND id IS NOT NULL
  and created_time is not null
PRIMARY KEY (user_id, created_time, organization_id, id);

CREATE CUSTOM INDEX ON organization_history (is_deleted)
    USING 'StorageAttachedIndex';

//##########################

CREATE TABLE IF NOT EXISTS organization_invite
(
    id              text,
    count           int,
    link_type       int,
    organization_id uuid,
    invite_id       uuid,
    PRIMARY KEY (id)
);

//#########################

// 创建一个文件信息类型
CREATE TYPE IF NOT EXISTS file_info
    (
        id                uuid,
        domain            text, // 文件存储域名
        base_path         text, // 基础路径
        storage_file_name text, // 文件地址
    );
CREATE TABLE IF NOT EXISTS organizations
(
    id                    uuid,
    name                  text,
    avatar                file_info,
    city                  text,
    size                  int,
    disabled              int,           // 0 代表是正常使用  1代表组织已经解散
    type                  int,
    permissions           int,
    credit_code           text,
    status                int,
    admins                list<uuid>,    // 存储管理员ID
    members               map<uuid,int>, // 存储成员ID(包括管理员)
    allow_search_user     list<uuid>,    // 允许被搜索到的用户
    not_allow_search_user list<uuid>,    // 不允许被搜索到的用户
    created_time          timestamp,
    updated_time          timestamp,
    show_real_name        boolean,       // 组织内是否显示真实姓名
    PRIMARY KEY (id)
);
CREATE MATERIALIZED VIEW IF NOT EXISTS organization_by_name AS
SELECT name, id
FROM organizations
WHERE name IS NOT NULL
  AND id IS NOT NULL
PRIMARY KEY (name, id);


CREATE CUSTOM INDEX ON organizations (disabled)
    USING 'StorageAttachedIndex';

//######################
// 仅仅只存放可被搜索到的组织
CREATE TABLE IF NOT EXISTS organizations_search
(
    id   uuid,
    name text,
    PRIMARY KEY (id)
);

CREATE CUSTOM INDEX ON organizations_search (name)
    USING 'org.apache.cassandra.index.sasi.SASIIndex'
    WITH OPTIONS = {
        'mode': 'CONTAINS',
        'analyzer_class': 'org.apache.cassandra.index.sasi.analyzer.StandardAnalyzer',
        'case_sensitive': 'false'
        };

//######################
// 存储用户加入的组织关系
CREATE TABLE IF NOT EXISTS user_organization_relation
(
    user_id               uuid,
    current_organization  uuid, // 存储当前浏览组织
    organizations         list<uuid>,
    history_organizations list<uuid>,
    PRIMARY KEY (user_id)
);

//######################
// 存储用户组织历史关注成员
CREATE TABLE IF NOT EXISTS user_organization_history
(
    user_id         uuid,
    organization_id uuid,
    follow_user_id  uuid,
    group_id        uuid,
    created_time    timestamp,
    updated_time    timestamp,
    deleted_time    timestamp,
    is_deleted      boolean,
    PRIMARY KEY (user_id, organization_id, follow_user_id)
);

CREATE CUSTOM INDEX ON organizations (not_allow_search_user)
    USING 'StorageAttachedIndex';
CREATE CUSTOM INDEX ON organizations (allow_search_user)
    USING 'StorageAttachedIndex';

CREATE CUSTOM INDEX ON user_organization_history (is_deleted)
    USING 'StorageAttachedIndex';