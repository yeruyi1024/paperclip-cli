## PaperClip-CLI

项目因使用PaperClip而进行Docker容器构建改造，计划整合必要的环境，满足上线要求

## 注意事项
1. 镜像使用1000用户进行运行，而非root
2. 目前安装的环境会随着需求逐步调整，相关环境信息需要参考下方的具体说明

## 升级方式
0. 基本概念Dockerfile为paperclip提供，其他的组件在Dockerfile上进行改造。
1. 本地更新依赖代码，检查PaperClip是否有更新Dockerfile，对比版本写在最上方，
    1.1 若要更新Dockerfile，需要更新所有的env-*文件夹，包括env-default等，因为基础依赖发生变化
2. 考虑是否升级组件升级组件需要逐步更新，比如hermes，更新的话需要检查env-hermes的脚本是否有更新。

## 升级记录

### 2026年05月18日
**paperclip-hermes-nexa:P05180-H0516**
- 升级了Dockerfile，（ab8b471685bf17efd7d170cd43187c0318dcdeaa）
- 升级Hermes版本为 v0.14.0 20260516
- 追加 Docker环境
- 追加 gemini cli环境

### 2026年05月09日
**paperclip-hermes-nexa:P05090-H0507**
- 升级了Dockerfile，（4272c1604dd17955f37b4cc5db6672dffe75709c）
- 升级Hermes版本为 v0.13.0 20260507

### 2026年04月29日
**paperclip-hermes:P04280-H04230**
- paperclip升级到v2026.428.0，
- 更新了Dockerfile，导致需要更新所有的env文件夹

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
