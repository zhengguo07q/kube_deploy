use organization;


// 删除物化试图
DROP MATERIALIZED VIEW IF EXISTS organization_by_name;
// 删除旧表
DROP TABLE IF EXISTS organizations;

// 创建新表
CREATE TABLE IF NOT EXISTS organizations
(
    id           uuid,
    name         text,
    avatar       file_info,
    city         text,
    size         int,
    disabled     int,           // 0 代表是正常使用  1代表组织已经解散
    type         int,
    permissions  int,
    credit_code  text,
    status       int,
    admins       list<uuid>,    // 存储管理员ID
    members      map<uuid,int>, // 存储成员ID(包括管理员)
    created_time timestamp,
    updated_time timestamp,
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



// 删除物化试图
DROP MATERIALIZED VIEW IF EXISTS apply_message_by_user;
// 删除旧表
DROP TABLE IF EXISTS apply_message;
CREATE TABLE IF NOT EXISTS apply_message
(
    id              uuid,
    from_user_id    uuid,
    organization_id uuid,
    status          int,
    content         text,
    created_time    timestamp, // 创建时间即代表了申请时间
    updated_time    timestamp,
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