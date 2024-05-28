use organization;

// 新增该组织是否显示真名
ALTER TABLE organizations
    ADD show_real_name boolean;

use user;

// 用户板块新增两个字段 公开日志数量 ork数量
ALTER TABLE user.user_infos
    ADD public_content_count int;
ALTER TABLE user.user_infos
    ADD okr_count int;

CREATE MATERIALIZED VIEW IF NOT EXISTS user_infos_by_phone AS
SELECT phone, id, disabled
FROM user_infos
WHERE phone IS NOT NULL
  AND id IS NOT NULL
PRIMARY KEY (phone, id);