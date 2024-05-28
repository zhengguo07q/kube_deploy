CREATE KEYSPACE IF NOT EXISTS content with replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

use content;

// 创建一个文件信息类型
CREATE TYPE IF NOT EXISTS file_info
    (
        id                uuid,
        domain            text, // 文件存储域名
        base_path         text, // 基础路径
        storage_file_name text, // 文件地址
    );

// 二级评论对象
CREATE TABLE IF NOT EXISTS secondary_comments
(
    to_comment_id uuid,
    id            uuid,
    content       text,
    user_avatar   file_info,
    user_name     text,
    user_nickname text,
    user_id       uuid,
    created_time  timestamp,
    updated_time  timestamp,
    is_deleted    boolean,
    primary key (to_comment_id, created_time, id, user_id)
) WITH CLUSTERING ORDER BY (created_time desc);

CREATE CUSTOM INDEX secondary_comments_is_deleted ON secondary_comments (is_deleted)
    USING 'StorageAttachedIndex';

// 存储用户的评论
CREATE TABLE IF NOT EXISTS content_comments
(
    id            uuid,
    content_id    uuid,
    content       text,
    user_avatar   file_info,
    user_name     text,
    user_nickname text,
    user_id       uuid,
    created_time  timestamp,
    updated_time  timestamp,
    is_deleted    boolean,
    primary key (content_id, created_time, id, user_id)
) WITH CLUSTERING ORDER BY (created_time desc);


CREATE CUSTOM INDEX content_comments_is_deleted ON content_comments (is_deleted)
    USING 'StorageAttachedIndex';


/*  note 当前采用一级评论和二级评论分开存储
 问题一 无法单独获取一级评论 因为无法在查询的时候对uuid实现空值查找(一级评论的to_comment_id为空)
 问题二 如果将二级评论放到一级评论中  分页没办法实现
 删除或更新评论会有问题 并且查询排序有问题(uuid使用timeUuid,并且需要从业务层面检查评论未删除)

 假设一级评论和二级评论分开存储
 可能会影响到多表 可能增加数据库的查询次数
*/

// 创建用户点赞信息
-- auto-generated definition
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

// Full text search on albums title
CREATE CUSTOM INDEX content_search_index ON content.content_infos (content)
    USING 'org.apache.cassandra.index.sasi.SASIIndex';

CREATE CUSTOM INDEX content_search_index ON content.content_infos (content) USING 'org.apache.cassandra.index.sasi.SASIIndex'
    WITH OPTIONS = {
        'mode': 'CONTAINS',
        'analyzer_class': 'org.apache.cassandra.index.sasi.analyzer.StandardAnalyzer',
        'tokenization_enable_stemming': 'false',
        'tokenization_normalize_lowercase': 'false',
        'tokenization_skip_stop_words': 'false'
        };
