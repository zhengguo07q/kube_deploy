CREATE KEYSPACE IF NOT EXISTS thirdparty with replication = {'class': 'SimpleStrategy', 'replication_factor': 1};

use thirdparty;

CREATE TABLE IF NOT EXISTS file_infos
(
    id               uuid,
    filename         text,
    domain           text,
    file_size        int,
    base_path        text,
    platform         text,
    content_type     text,
    storage_filename text,
    created_time     timestamp,
    updated_time     timestamp,
    is_deleted       boolean,
    PRIMARY KEY ( id)
);

CREATE CUSTOM INDEX file_infos_is_deleted ON file_infos (is_deleted)
    USING 'StorageAttachedIndex';

// 默认用户头像
INSERT INTO file_infos (id, base_path, content_type, created_time, domain, file_size, filename, is_deleted, platform, storage_filename, updated_time)
VALUES (38336261-3161-3636-2d39-6432332d3434, '', 'chat/image', '2024-03-07 11:39:34.090', 'http://content.mindmvp.com', 32972, '91342175-B565-4C49-A560-680CA4F2C288_L0_001_1709570139.107583_o_IMG_7808.jpg', false, '七牛云', '5ae563d7-148a-4b40-90ba-08189d002e9a.jpg', toTimestamp(now()));
