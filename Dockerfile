FROM golang:latest AS builder

# 设置代理环境变量
ARG PROXY
ENV http_proxy=${PROXY} https_proxy=${PROXY}

WORKDIR /src

COPY . /src

# 设置 Go module 代理
ENV GOPROXY=https://proxy.golang.org,direct

# 下载并安装依赖
RUN go mod download && go mod verify


# 编译二进制文件
RUN go build -o /app/vmq

# 编译前端
FROM node:latest AS frontend

WORKDIR /src/frontend

COPY ./frontend /src/frontend

RUN npm install && npm run build


# 阶段二
FROM ubuntu:latest

# 从 builder 阶段拷贝二进制文件
COPY --from=builder /app/vmq /app/vmq

# 从 frontend 阶段拷贝前端文件
COPY --from=frontend /src/frontend/dist /app/web

# 重置代理配置
ENV http_proxy='' https_proxy=''