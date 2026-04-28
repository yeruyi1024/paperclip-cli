## PaperClip-CLI

项目因使用PaperClip而进行Docker容器构建改造，计划整合必要的环境，满足上线要求

## 注意事项
1. 镜像使用1000用户进行运行，而非root
2. 目前安装的环境会随着需求逐步调整，相关环境信息需要参考下方的具体说明

### 0. 基础环境
基础环境来自于paperclip，基础环境为**Node.JS**(node:lts-trixie-slim)

> ./env-default/Dockerfile
```
    make paperclip-hermes
```

### 1. Hermes服务

> ./env-hermes/install.sh 
> 对端版本v2026.4.26

目前invoke hermes-agent/script/install.sh进行安装，但会报出一系列错误，需要进行调试，将环境与脚本进行整合，满足上线要求
增加环境：**Python3.13**


#### 1.1 修改记录
1. 修改了./env-hermes/install.sh脚本，增加INSTALL_USER=1000参数，将hermes-agent安装在/usr/local/lib/hermes-agent下，并创建软链接到/usr/local/bin/hermes
2. 修改安装node deps的时候增加了 --ignore-scripts参数，跳过firefox的agent broswer修改脚本，这个包太大，500M严重影响构建。


### 2. Proj Runtime Env(NEXA)

> ./env-nexa/Dockerfile
```
    make paperclip-hermes-nexa
```

因开发环境需要，按照每个项目进行构建拉取。
增加环境：**Go1.24**/**Wails**
