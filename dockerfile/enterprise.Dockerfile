FROM golang:1.21.6

#开启并设置go模块
ENV GO111MODULE=on
RUN go env -w GOPROXY=https://goproxy.cn

#关闭模块验证
RUN go env -w GOSUMDB=off
RUN go env -w GOSUMDB="sum.golang.google.cn"

#定义文件的工作目录
WORKDIR $GOPATH/dolphin/professional_server

COPY professional_proto/gen_go/ $GOPATH/dolphin/professional_proto/gen_go/

#拷贝go.mod go.sum到工作目录并且执行环境下载
COPY go.mod go.sum ./
RUN cd $GOPATH/dolphin/professional_server && go mod download

#拷贝代码
COPY internal/ $GOPATH/dolphin/professional_server/internal
COPY app $GOPATH/dolphin/professional_server/app
COPY common $GOPATH/dolphin/professional_server/common

#进入app运行命令并编译生成执行文件 ，全链接编译,linux模式
WORKDIR $GOPATH/dolphin/professional_server/app/enterprise
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /app-enterprise .

#创造linux生产环境
FROM alpine:latest
#替换掉原来的源，避免可能出现的权限报错
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

#配置环境，安装根证书
RUN apk --no-cache add ca-certificates

#把上面生成的执行文件拷贝进bin
COPY --from=0 /app-enterprise /usr/local/bin/app-enterprise

#入口点执行
ENTRYPOINT ["/usr/local/bin/app-enterprise"]
