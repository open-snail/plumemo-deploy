<h1 align="center"><a href="https://github.com/byteblogs168/plumemo" target="_blank">plumemo</a></h1>

> [Plumemo](https://www.plumemo.com/) 是一个轻量、易用、前后端分离的博客系统，为了解除开发人员对后端的束缚，真正做到的一个面向接口开发的博客系统。

<p align="center">
<a href="#"><img alt="JDK" src="https://img.shields.io/badge/JDK-1.8-yellow.svg?style=flat-square"/></a>
<a href="#"><img alt="GitHub release" src="https://img.shields.io/github/release/halo-dev/halo.svg?style=flat-square"/></a>
<a href="#"><img alt="GitHub All Releases" src="https://img.shields.io/github/downloads/halo-dev/halo/total.svg?style=flat-square"></a>
<a href="#"><img alt="Docker pulls" src="https://img.shields.io/docker/pulls/ruibaby/halo?style=flat-square"></a>
</p>

------------------------------

## 简介

**plumemo** [plumemo]，plume（羽） + memo（备忘录）

> 基于[SpringBoot](https://spring.io/projects/spring-boot/)实现零配置让系统的配置更简单，使用了[Mybatis-Plus](https://mp.baomidou.com/)快速开发框架，在不是复杂的查询操作下，无需写sql就可以快速完成接口编写。
> 后台管理系统使用了vue中流行的[ant](https://panjiachen.github.io/vue-element-admin-site/#/)，另外前后交互使用了[JWT](https://jwt.io/)作为令牌，进行权限、登录校验。。


> [官网](https://www.plumemo.com/) | [社区](https://www.byteblogs.com) | [QQ 交流群](https://shang.qq.com/wpa/qunwpa?idkey=4f8653da80e632ef86ca1d57ccf8751602940d1036c79b04a3a5bc668adf8864) | 

## 背景
> 由于plumemo 是前后端分离的，那么对于部署来说就一件很头疼的事情，主题、管理系统、后端java服务都需要配置安装配置。除此之外还是jdk、mysql、nginx配置无疑给很多小伙伴照成了一定的阻碍；为此经过几天的努力pluemeo-v1.0.0 安装脚本诞生了。

## 功能介绍
1. jdk
2. mysql
3. nginx
4. 主题
5. 管理系统

## 操作步骤
1. 把脚本上传到服务器（不做介绍）
2. 添加可执行权限 ```chmod +x plumemo-v1.0.0.sh```
3. 执行脚本 ```sh plumemo-v1.0.0.sh```

![QQ截图20200331221608.png](http://image.byteblogs.com/3388e350b7548f68acf209d02120190f.png)

下面您就可以根据你的选择进行安装:
## 安装jdk,版本:jdk-8u144-linux-x64
![QQ截图20200331222233.png](http://image.byteblogs.com/5d457dbe646179af7973fbec46e4c735.png)

## 安装mysql,版本:5.7.28
![QQ截图20200331224800.png](http://image.byteblogs.com/9aaa08107724f72a4476c954b89e7dd0.png)

## 安装nginx,版本:1.17.9
![QQ截图20200331225219.png](http://image.byteblogs.com/6b7bcabe5c1eb82389365609424b0d4e.png)
## 安装plumemo主题
![111.png](http://image.byteblogs.com/7269932fdd7f8ba760b50d8a119a60c0.png)
## 安装plumemo管理系统
![admin1.png](http://image.byteblogs.com/f9488ff8ea985d73d468f771c60a08b1.png)

![admin2.png](http://image.byteblogs.com/bba546a5eada5b57e31e3b588e5f19e6.png)

### 生成的启动脚本
1. 添加可执行权限 ```chmod +x deploy.sh```
2. 执行脚本 ```sh deploy.sh```

![aa.png](http://image.byteblogs.com/321532365639f31b3b9f8ea8be0c6be2.png)

### 配置nginx.conf
```
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;
    gzip on;
    gzip_min_length  1k;
    gzip_buffers     4 16k;
    gzip_http_version 1.0;
    gzip_comp_level 2;
    gzip_types       text/plain text/css text/xml text/javascript application/x-javascript application/xml application/rss+xml application/xhtml+xml application/atom_xml;
    gzip_vary on;

    proxy_set_header Host $host;
	proxy_set_header X-Real-IP $remote_addr;
	proxy_set_header REMOTE-HOST $remote_addr;
	proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    server {
        listen       80;
        server_name  localhost;
		
        location ^~ / {
                  # 配置主题访问地址
                  # 这里需要改为您自己的地址
		  root /usr/local/plumemo/front;
		  index index.html index.htm;
		  try_files $uri $uri/ /index.html;
        }
		
        location /admin {
                 # 配置后端管理系统访问地址
		 # 这里需要改为您自己的地址
		 root /usr/local/plumemo/;
		 index index.html index.htm;
		 try_files $uri $uri/ /admin/index.html;
        }

	    location ^~ /api/blog {
		    index  index.html index.htm index.php;  
			index  proxy_set_header Host $host;  
			index  proxy_set_header X-Real-IP $remote_addr;  
			index  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
			proxy_pass http://localhost:8086/api/hello-blog-service; #后端服务器，具体配置upstream部分即可  
        }
		
    }
}

```
至此安装已经完成，开启了您的博客之旅。