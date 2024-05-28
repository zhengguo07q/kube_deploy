use user;

// 给user_infos表新增两个栏目
alter table user_infos
    add name_change_limit int; // 限制真实昵称次数(新用户默认两次)
alter table user_infos
    add name_change_time timestamp;// 上次修改昵称时间

use thirdparty;

alter type chat.file_info add blur_hash text;
alter type organization.file_info add blur_hash text;
alter type user.file_info add blur_hash text;
alter type content.file_info add blur_hash text;

alter table thirdparty.file_infos
    add blur_hash text; // 新增图片模糊hash值
