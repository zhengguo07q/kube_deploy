// 首先将content_info的数据迁移到临时表
use content;


// 删除物化视图
drop materialized view if exists content_infos_by_user;

// 删除内容表
drop table if exists content_infos;

// 删除元祖
drop type if exists user_appreciates;

// 创建元祖
create type user_appreciates
    (
        user_id       uuid,
        user_name     text,
        user_nickname text,
        avatar        frozen<file_info>,
        created_time  timestamp
    );


CREATE TABLE IF NOT EXISTS content_infos
(
    id                      uuid,           // 假设这里是组织发布的组织ID则使用组织ID作为分区键 如果是用户ID做的 则使用用户ID作为分区键
    title                   text,
    content                 text,
    files                   list<frozen<file_info>>,
    position                text,
    user_id                 uuid,
    organization_id         uuid,
    record_type             int,
    permissions             int,
    okr_from_time_stamp     timestamp,
    okr_to_time_stamp       timestamp,
    file_type               int,
    color                   text,
    appreciates             map<uuid, FROZEN<user_appreciates>>,
    comments                map<uuid,text>, // 仅仅只存储10条假设 数据量超过10条 那么将该评论迁移到单独的存储表中
    comments_num            int,            // 存储评论数
    should_migrate_comments boolean,        // 如果数据量超过10条 那么将该字段设置为true 代表数据存储到单独的表中
    created_time            timestamp,      // 创建时间
    updated_time            timestamp,      // 更新时间
    is_deleted              boolean,        // 日志是否被删除
    PRIMARY KEY (organization_id, created_time, id, user_id)
) WITH CLUSTERING ORDER BY (created_time desc);

CREATE CUSTOM INDEX content_infos_record_type ON content_infos (record_type)
    USING 'StorageAttachedIndex';

CREATE CUSTOM INDEX content_infos_permissions ON content_infos (permissions)
    USING 'StorageAttachedIndex';

CREATE CUSTOM INDEX content_infos_is_deleted ON content_infos (is_deleted)
    USING 'StorageAttachedIndex';

CREATE CUSTOM INDEX content_infos_should_migrate_comments ON content_infos (should_migrate_comments)
    USING 'StorageAttachedIndex';

CREATE MATERIALIZED VIEW IF NOT EXISTS content_infos_by_user AS
SELECT *
FROM content_infos
WHERE user_id IS NOT NULL
  AND created_time IS NOT NULL
  and organization_id is not null
  AND id IS NOT NULL
PRIMARY KEY (user_id, created_time, organization_id, id);


