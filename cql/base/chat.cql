CREATE KEYSPACE IF NOT EXISTS chat with replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

use chat;



// 创建一个文件信息类型
CREATE TYPE IF NOT EXISTS file_info
    (
        id                uuid,
        domain            text, // 文件存储域名
        base_path         text, // 基础路径
        storage_file_name text, // 文件地址
    );

//######################################
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

