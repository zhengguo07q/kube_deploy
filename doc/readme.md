

### #修改hosts文件
#C:\Windows\System32\drivers\etc\host

```
127.0.0.1       admin
127.0.0.1       chat
127.0.0.1       content
127.0.0.1       enterprise
127.0.0.1       organization
127.0.0.1       resume
127.0.0.1       thirdparty
127.0.0.1       user
```

-------------------

### 登陆阿里云镜像仓库
```shell
docker login registry.cn-hangzhou.aliyuncs.com
username: dt_1900832718
password: Admin@guyu1
```

-------------------

### 修改user.yaml里 remote字段的ip地址为本机ip， 则docker里面容器可以访问外地址

关闭掉ipv6, ipv6会导致不能正确指向首选dns