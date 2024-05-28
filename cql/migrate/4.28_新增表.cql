use user;

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

use organization;

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

alter table organization.organizations
    add allow_search_user list<uuid>;
alter table organization.organizations
    add not_allow_search_user list<uuid>;
alter table organization.apply_message
    add allow_search boolean;

CREATE CUSTOM INDEX content_search_index ON content.content_infos (content) USING 'org.apache.cassandra.index.sasi.SASIIndex'
    WITH OPTIONS = {
        'mode': 'CONTAINS',
        'analyzer_class': 'org.apache.cassandra.index.sasi.analyzer.StandardAnalyzer',
        'tokenization_enable_stemming': 'false',
        'tokenization_normalize_lowercase': 'false',
        'tokenization_skip_stop_words': 'false'
        };


CREATE CUSTOM INDEX ON organizations (not_allow_search_user)
    USING 'StorageAttachedIndex';
CREATE CUSTOM INDEX ON organizations (allow_search_user)
    USING 'StorageAttachedIndex';
CREATE CUSTOM INDEX ON user_organization_history (is_deleted)
    USING 'StorageAttachedIndex';