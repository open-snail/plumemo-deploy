#!/bin/bash

#存放二进制包的路径
SOFTWARE_PATH='/usr/local/software'

num=$(test -d ${SOFTWARE_PATH} && echo 1 || echo 0 )
if [ ! $num -eq 1 ];then
  mkdir -p ${SOFTWARE_PATH}
fi

#java版本信息
JDK_VERSION='jdk1.8.0_144'

#jdk的安装包名
JDK_INSTALL_VERSION='jdk-8u144-linux-x64'

#mysql的版本
MYSQL_VERSION='mysql-5.7.28-el7-x86_64'

#nginx的版本
NGINX_VERSION='nginx-1.17.9'

install_list=(
 1.安装jdk,版本:jdk-8u144-linux-x64
 2.安装mysql,版本:5.7.28
 3.安装nginx,版本:1.17.9
 4.安装plumemo主题
 5.安装plumemo管理系统
 6.退出
)

# 系统环境搭建
install_url_list=(
 https://github.com/byteblogs168/hello-blog/releases/download/v1.0.1-Alpha/jdk-8u144-linux-x64.tar.gz
 https://cdn.mysql.com/archives/mysql-5.7/mysql-5.7.28-el7-x86_64.tar.gz
 http://nginx.org/download/nginx-1.17.9.tar.gz
)


# 安装plumemo主题
install_theme_version_menu_list=(
  1.theme_react_sakura
  2.theme_vue_bluesoul
)

install_theme_url_menu_list=(
  https://github.com/byteblogs168/theme-react-sakura/releases/download/v1.1.0/theme-react-sakura.zip
  https://github.com/byteblogs168/theme-vue-bluesoul/releases/download/v1.0.1-Alpha/theme-vue-bluesoul.zip
)

# 安装plumemo服务端
install_admin_version_menu_list=(
  1.v1.1.0
  2.v1.2.0
)

install_admin_version_list=(
  v1.1.0
  v1.2.0
)

install_admin_url_v1_1_0_list=(
  https://github.com/byteblogs168/plumemo/releases/download/v1.1.0/plumemo-v1.1.0.jar
  https://github.com/byteblogs168/plumemo/releases/download/v1.1.0/admin.zip
)

install_admin_url_v1_2_0_list=(
  https://github.com/byteblogs168/plumemo/releases/download/v1.2.0/plumemo-v1.2.0.jar
  https://github.com/byteblogs168/plumemo-admin/releases/download/v2.1.0/admin.zip
)

function echo_fun(){
  if [ $# -ge 2 ];then
      params_num=$1
      shift 1
      params_mes=$@
  else
      echo_fun 3 请至少输入两个参数 echo_fun ..
      exit
  fi
  case $params_num in
        1)
        echo -e "\n\033[35;40;1m ****************************** ${params_mes} ******************************\033[0m\r\n"
        ;;
        2)
        echo -e "\033[32;40;1m ${params_mes}\033[0m\r\n"
        ;;
        3)
        echo -e "\n\033[31;40;1m ${params_mes}\033[0m\r\n"
        ;;
        4)
        echo -e "\033[36;40;1m ${params_mes}\033[0m\r\n"
        ;;
        5)
        echo -e "\033[33;40;1m ${params_mes} \033[0m\r\n"
        ;;
        *)
        echo_fun 3 您输入的选项不存在
        ;;
   esac
}

function echo_list(){
    echo_fun 5 安装目录如下,请选择安装步骤:
    for (( i=0;i<${#install_list[@]};i++ ))
    do
      echo_fun 4 ${install_list[i]}
    done
}

function echo_install_admin_version_list(){
    echo_fun 5 安装后端管理系统,请选择安装步骤:
    for (( i=0;i<${#install_admin_version_menu_list[@]};i++ ))
    do
      echo_fun 3 ${install_admin_version_menu_list[i]}
    done
}

function echo_install_theme_version_list(){
    echo_fun 5 安装主题,请选择安装步骤:
    for (( i=0;i<${#install_theme_version_menu_list[@]};i++ ))
    do
      echo_fun 3 ${install_theme_version_menu_list[i]}
    done
}

function plememo_install(){
   read -p "选择安装项[1-6]: " num
   case $num in
        1)
        echo_fun 1  ${install_list[0]}
        step_jdk_fun 0
        ;;
        2)
        echo_fun 1  ${install_list[1]}
        step_mysql_fun 1
        ;;
        3)
        echo_fun 1  ${install_list[2]}
        step_nginx_fun 2
        ;;
        4)
        echo_fun 1  ${install_list[3]}
        step_theme_fun 3
        ;;
        5)
        echo_fun 1  ${install_list[4]}
        step_admin_fun 4
        ;;
        6)
        echo_fun 1 您已经退出
        exit
        ;;
        *)
        echo_fun 3 您输入的选项不存在
        exit
        ;;
   esac
}

function wget_install_packet_fun() {

  # 获取安装包
  if [ -f $1 ]; then
    echo "$1已经存在安装包"
  else
     echo "$1不存在安装包"
     wget -P /usr/local/software $2
  fi

}

#检查安装的组件是否存在
function check_cluster_package(){
  cluster_package_num=$(rpm -qa|grep $1|wc -l )
   if [ ${cluster_package_num} -ge 1 ];then
      echo_fun 2 "$1组件存在,继续下一步"
   else
      echo_fun 5 $1的依赖包,安装依赖
      yum install -y $1 >/dev/null 2>&1
   fi
}

#检查安装目录是否存在,存在则退出程序，以防误安装
function check_cluster_catalog_exist(){
   num=$(test -d $1 && echo 1 || echo 0 )
   if [ $num -eq 1 ];then
        read -p "$2目录存在,是否删除[y/n]：" answer
        echo ''
        if [ $answer == 'y' ];then
            rm -r $1
            echo_fun 4 删除完成
            mkdir -p $1
        fi
        if [ $answer == 'n' ];then
          echo_fun 4 退出安装
          exit
        fi
   else
    echo_fun 3 "$2目录不存在,创建目录$1"
    mkdir -p $1
   fi
}

#检查环境变量是否存在
function check_cluster_etc_profile(){

     cluster_path_num=$(cat /etc/profile |grep -w $1 |wc -l )
     if [ ${cluster_path_num} -ge 1 ];then
        echo_fun 5 $1 环境变量已经配置,请检查准确性
        read -p "正确与否[y/n]：" answer
	    echo ''
	    if [ $answer == 'y' ];then
          echo_fun 4 环境变量准确,继续安装.
        fi

        if [ $answer == 'n' ];then
          echo_fun 4 环境变量不准确,请手动修改/etc/profile,安装退出.
          exit
        fi
     fi
}

#---------------------------------------------------------theme安装脚本----------------------------------------------------

function menu_theme(){
    read -p "选择安装项[1-2]: " num
    case $num in
        1)
         echo_fun 1  ${install_theme_version_menu_list[0]}
         init_theme "theme-react-sakura" 0
        ;;
        2)
         echo_fun 1  ${install_theme_version_menu_list[1]}
         init_theme "theme-vue-bluesoul" 1
        ;;
        *)
        echo_fun 3 您输入的选项不存在
        exit
        ;;
    esac
}

function init_theme(){
     wget_install_packet_fun ${SOFTWARE_PATH}/$1.zip ${install_theme_url_menu_list[$2]}
     check_cluster_package unzip

     check_cluster_catalog_exist ${THEME_PLUMEMO_INSTALL_PATH}/$1 $1
     cd ${SOFTWARE_PATH}
     unzip -d  ${THEME_PLUMEMO_INSTALL_PATH}/$1 $1.zip
}

function step_theme_fun(){

   echo_fun 4 请输入主题安装位置如[ENTER默认/usr/local/plumemo/theme]
   read -p "theme_plumemo_install_path=" THEME_PLUMEMO_INSTALL_PATH
   echo ''

   if [ ! -n "${THEME_PLUMEMO_INSTALL_PATH}" ]; then
       THEME_PLUMEMO_INSTALL_PATH=/usr/local/plumemo/theme
   fi

   echo_fun 4 当前安装目录${THEME_PLUMEMO_INSTALL_PATH}
#   echo_fun 5 检查当前安装目录是否存在
#   check_cluster_catalog_exist ${THEME_PLUMEMO_INSTALL_PATH}/theme theme
   echo_install_theme_version_list
   menu_theme
}

#---------------------------------------------------------admin安装脚本----------------------------------------------------

function menu_admin(){
    read -p "选择安装项[1-2]: " num
    case $num in
        1)
         echo_fun 1  ${install_admin_version_list[0]}
         init_admin  ${install_admin_url_v1_1_0_list[0]} ${install_admin_url_v1_1_0_list[1]} ${install_admin_version_list[0]}
         ;;
        2)
         echo_fun 1  ${install_admin_version_list[1]}
         init_admin  ${install_admin_url_v1_2_0_list[0]} ${install_admin_url_v1_2_0_list[1]} ${install_admin_version_list[1]}
        ;;
        *)
        echo_fun 3 您输入的选项不存在
        exit
        ;;
    esac
}

function init_admin(){
     wget_install_packet_fun ${SOFTWARE_PATH}/plumemo-$3.jar $1
     cd ${SOFTWARE_PATH}
     cp plumemo-$3.jar ${ADMIN_PLUMEMO_INSTALL_PATH}

     wget_install_packet_fun ${SOFTWARE_PATH}/admin.zip $2
     check_cluster_package unzip
     cd ${SOFTWARE_PATH}
     unzip admin.zip
     mv ${SOFTWARE_PATH}/dist admin
     cp -r ${SOFTWARE_PATH}/admin ${ADMIN_PLUMEMO_INSTALL_PATH}
     rm -rf ${SOFTWARE_PATH}/admin

     echo_fun 5 为您生成安装脚本
     create_start_exec $3
}

function create_start_exec(){
   echo_fun 1 下面我们会为您生成启动脚本,请填写数据库相关信息
    rm -f ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo_fun 4 请输入mysql的用户名[ENTER默认root]
    read -p "username=" username
    echo ''
    if [ ! -n "${username}" ]; then
      username=root
    fi

    echo_fun 4 请输入mysql的密码[ENTER默认root]
    read -p "password=" password
    echo ''
    if [ ! -n "${password}" ]; then
      password=root
    fi

    echo_fun 4 请输入mysql的数据库名称[ENTER默认plumemo]
    read -p "database=" database
    echo ''
    if [ ! -n "${database}" ]; then
      database=plumemo
    fi

    echo_fun 4 请输入mysql的IP地址名称[ENTER默认127.0.0.1]
    read -p "ip=" ip
    echo ''
    if [ ! -n "${ip}" ]; then
      ip=127.0.0.1
    fi

    echo_fun 5 正在为您生成脚本

    echo -e '#!/bin/bash -l'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'var='${ADMIN_PLUMEMO_INSTALL_PATH}'/plumemo-'$1'.jar'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'JARFILE=plumemo-'$1'.jar' >> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'PID=$(ps -ef|grep -w "$var" | grep -v grep |awk '\''{printf $2}'\'')'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh

    echo -e 'if [ ! -d "./logs" ]; then'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '    mkdir ./logs'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'fi'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'if [ ! -n "$PID" ]; then'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '    echo "pid is null"'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '    nohup $JAVA_HOME/bin/java -jar $var --MYSQL_USERNAME='${username}'  --MYSQL_PASSWORD='${password}'  --MYSQL_DATABASE=jdbc:mysql://'${ip}':3306/'${database}'?useSSL=false&characterEncoding=utf8 > $(pwd "$JARFILE")/logs/startlog.log &'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '  exit'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'else'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '  echo "pid not null"'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'fi'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'kill -9 ${PID}'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '\nif [ $? -eq 0 ];then'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '  echo "kill $JARFILE success"'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '  nohup $JAVA_HOME/bin/java -jar $var  --MYSQL_USERNAME='${username}'  --MYSQL_PASSWORD='${password}'  --MYSQL_DATABASE=jdbc:mysql://'${ip}':3306/'${database}'?useSSL=false&characterEncoding=utf8 > $(pwd "$JARFILE")/logs/startlog.log &'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'else'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e '   echo "kill $JARFILE fail"'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh
    echo -e 'fi'>> ${ADMIN_PLUMEMO_INSTALL_PATH}/deploy.sh

    echo_fun 5 脚本生成成功
}

function step_admin_fun(){
   echo_fun 4 请输入后端管理系统安装位置如[ENTER默认/usr/local/plumemo]
   read -p "admin_plumemo_install_path=" ADMIN_PLUMEMO_INSTALL_PATH
   echo ''

   if [ ! -n "${ADMIN_PLUMEMO_INSTALL_PATH}" ]; then
       ADMIN_PLUMEMO_INSTALL_PATH=/usr/local/plumemo
   fi

   echo_fun 4 当前安装目录${ADMIN_PLUMEMO_INSTALL_PATH}
   echo_fun 5 检查当前安装目录是否存在
   check_cluster_catalog_exist ${ADMIN_PLUMEMO_INSTALL_PATH}/admin admin
   echo_install_admin_version_list
   menu_admin

   cd ${ADMIN_PLUMEMO_INSTALL_PATH}
   chmod  +x deploy.sh
}

#---------------------------------------------------------JDK安装脚本----------------------------------------------------
#安装jdk
function step_jdk_fun(){

   echo_fun 4 请输入java安装位置如[ENTER默认/usr/local/plumemo]
   read -p "jdk_install_path=" JDK_INSTALL_PATH
   echo ''

   if [ ! -n "${JDK_INSTALL_PATH}" ]; then
       JDK_INSTALL_PATH=/usr/local/plumemo
   fi

   echo_fun 4 当前安装目录${JDK_INSTALL_PATH}
   echo_fun 5  检查java安装目录是否存在

   wget_install_packet_fun  ${SOFTWARE_PATH}/${JDK_INSTALL_VERSION}.tar.gz ${install_url_list[$1]}

   #检查目录是否存在
   check_cluster_catalog_exist ${JDK_INSTALL_PATH}/${JDK_VERSION} java

   if [ $num -eq 0 ];then
     #解压jdk包
     echo_fun 4 解压jdk二进制包
     cd ${SOFTWARE_PATH}
     tar -xf ${JDK_INSTALL_VERSION}.tar.gz  -C  ${JDK_INSTALL_PATH}
   fi

    echo_fun 4 检查环境变量
    check_cluster_etc_profile ${JDK_INSTALL_PATH}/${JDK_VERSION}

    if [ ${cluster_path_num} -lt 1 ];then
        echo_fun 4 配置环境变量
        echo -e '\nJAVA_HOME='${JDK_INSTALL_PATH}/${JDK_VERSION}'\nCLASSPATH=$JAVA_HOME/lib/ \nPATH=$PATH:$JAVA_HOME/bin \nexport PATH JAVA_HOME CLASSPATH'>> /etc/profile
        source /etc/profile
    fi
}

function chown_user(){
    cd $1;chown -R $2:$3 $4
}
#---------------------------------------------------------MYSQL安装脚本----------------------------------------------------

#修改mysql上/etc/my.cnf配置文件
function  alter_mysql_file(){
  cd /var/lib
  mkdir mysql

  cd  /var/log/
  mkdir mariadb
  touch /var/log/mariadb/mariadb.log
  chmod 777 /var/log/mariadb/mariadb.log
  chown mysql:mysql /var/log/mariadb/mariadb.log

  cp ${MYSQL_INSTALL_PATH}/mysql/support-files/mysql.server  /etc/init.d/mysql

  rm -f /etc/my.cnf
  rm -f /tmp/mysql.sock
  echo -e '\n[mysqld]'>> /etc/my.cnf
  echo -e '\ncharacter-set-server=utf8mb4'>> /etc/my.cnf
  echo -e '\ndatadir=/var/lib/mysql'>> /etc/my.cnf
  echo -e '\nbasedir='${MYSQL_INSTALL_PATH}'/mysql'>> /etc/my.cnf
  echo -e '\nsocket=/var/lib/mysql/mysql.sock'>> /etc/my.cnf

  echo -e '\nport=3306'>> /etc/my.cnf
  echo -e '\nsymbolic-links=0'>> /etc/my.cnf
  echo -e '\nsql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES'>> /etc/my.cnf
  echo -e '\ncharacter-set-server=utf8mb4'>> /etc/my.cnf

  echo -e '\n[mysqld_safe]'>> /etc/my.cnf
  echo -e '\nlog-error=/var/log/mariadb/mariadb.log'>> /etc/my.cnf
  echo -e '\npid-file=/var/run/mariadb/mariadb.pid'>> /etc/my.cnf

  ln -s /var/lib/mysql/mysql.sock /tmp/mysql.sock
}

#初始化数据库
function init_mysql(){
 ${MYSQL_INSTALL_PATH}/mysql/bin/mysqld --defaults-file=/etc/my.cnf --basedir=${MYSQL_INSTALL_PATH}/mysql/ --datadir=/var/lib/mysql/ --initialize --user=mysql
 /etc/init.d/mysql start  --skip-grant-tables
}

#mysql部署
function mysql_install(){

   echo_fun 5 mysql的安装开始
   echo ''
   echo_fun 4 请输入mysql安装位置如[回车默认选择/usr/local/plumemo]
   read -p "mysql_install_path=" MYSQL_INSTALL_PATH
   echo ''
   if [ ! -n "${MYSQL_INSTALL_PATH}" ]; then
       MYSQL_INSTALL_PATH=/usr/local/plumemo
   fi

   echo_fun 4 当前安装目录${MYSQL_INSTALL_PATH}

    #检查mysql安装包是否存在
    wget_install_packet_fun  ${SOFTWARE_PATH}/${MYSQL_VERSION}.tar.gz ${install_url_list[$1]}

   #检查主机器mysql安装目录是否存在
   check_cluster_catalog_exist ${MYSQL_INSTALL_PATH}/mysql mysql

   if [ $num -eq 0 ];then
     echo_fun 4 解压安装包
     cd ${SOFTWARE_PATH}
     tar -xf ${MYSQL_VERSION}.tar.gz -C ${MYSQL_INSTALL_PATH}

     echo_fun 4 复制文件到mysql
     cd  ${MYSQL_INSTALL_PATH}/${MYSQL_VERSION}
     cp -r ./ ../mysql
   fi

   #安装依赖
   check_cluster_package libaio

    groupadd mysql
    useradd -r -g mysql mysql

    cd ${MYSQL_INSTALL_PATH}

    #授权
    chown_user ${MYSQL_INSTALL_PATH} mysql mysql ${MYSQL_INSTALL_PATH}/mysql*

    echo_fun 4 修改mysql的配置文件
    alter_mysql_file
    echo_fun 2 mysql配置文件修改完毕

    echo_fun 4 检查环境变量
    check_cluster_etc_profile ${MYSQL_INSTALL_PATH}/mysql

    if [ ${cluster_path_num} -lt 1 ];then
      echo_fun 4 配置环境变量
      echo -e '\nexport MYSQL_HOME='${MYSQL_INSTALL_PATH}'/mysql\nexport PATH=$MYSQL_HOME/bin:$PATH'>> /etc/profile
      source /etc/profile
    fi

   #初始化mysql,并启动
   echo_fun 4 初始化mysql,并启动
   init_mysql
   echo ''

   #mysql设置密码和配置
   echo_fun 4  初始化主mysql密码

   echo_fun 5 请输入root用户密码[ENTER默认为root]
   read -p "root_password=" root_password
   echo ''
   
   echo_fun 5 请输入plumemo用户密码[ENTER默认为123456]
   read -p "plumemo_password=" plumemo_password
   echo ''

   if [ ! -n "${root_password}" ]; then
       root_password=root
   fi
   
   if [ ! -n "${plumemo_password}" ]; then
       plumemo_password=123456
   fi

   echo_fun 4  当前密码为${root_password}
   mysql  -uroot <<eof
     use mysql;
     update user set authentication_string = password('${root_password}'), password_expired = 'N', password_last_changed = now() where user = 'root';
     flush privileges;
     GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${root_password}';
     flush privileges;
     GRANT ALL PRIVILEGES ON *.* TO 'root'@localhost IDENTIFIED BY '${root_password}';
     flush privileges;
     CREATE DATABASE plumemo DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
     CREATE USER 'plumemo'@'host' IDENTIFIED BY '${plumemo_password}';
     grant all privileges on plumemo.* to plumemo@localhost identified by '${plumemo_password}';
     flush privileges;
eof

    if [ $? -eq 0 ];then
       echo_fun 4 初始化密码成功
    fi

}

#mysql的安装
function step_mysql_fun(){
   mysql_install $1
}


# ------------------------------------------------nginx安装开始----------------------------------------------------
#初始化ngxin的二进制包。
function init_nginx(){
    echo_fun 4 正在进行nginx编译安装,时间较长耐心等待....
    cd ${SOFTWARE_PATH}/${NGINX_VERSION}
   ./configure --prefix=./configure --prefix=${NGINX_INSTALL_PATH}/nginx\
    --error-log-path=/usr/local/nginx/error.log\
    --pid-path=/usr/local/nginx/nginx.pid\
    --http-log-path=/usr/local/nginx/access.log\
    --with-http_stub_status_module\
    --with-ipv6\
    --with-http_sub_module\
    --with-http_gzip_static_module \
    --with-http_ssl_module\
    --with-http_v2_module \
     >/dev/null 2>&1

    make >/dev/null 2>&1 && make install >/dev/null 2>&1
}

function start_nginx(){
   echo_fun 4 启动nginx

   cd ${NGINX_INSTALL_PATH}/nginx/sbin
   ./nginx

   #判断进程是否存在
   nginx_pid_num=$(ps -ef |grep nginx|grep -v grep|wc -l)
   if [ ${nginx_pid_num} -ge 1 ];then
     echo_fun 2 nginx has started....
   fi
}

#nginx的部署
function step_nginx_fun(){

  # 获取nginx 安装包
  wget_install_packet_fun ${SOFTWARE_PATH}/${NGINX_VERSION}.tar.gz ${install_url_list[$1]}

  echo_fun 4 请输入nginx安装位置默认[/usr/local/plumemo]
  read -p "nginx_install_path=" NGINX_INSTALL_PATH
  echo ''
   if [ ! -n "${NGINX_INSTALL_PATH}" ]; then
       NGINX_INSTALL_PATH=/usr/local/plumemo
   fi
   echo_fun 4 当前安装目录${NGINX_INSTALL_PATH}

  echo_fun 4 检查nginx安装目录是否存在

  #循环检查nginx目录是否存在
  check_cluster_catalog_exist ${NGINX_INSTALL_PATH}/nginx nginx

  #解压nginx包
  echo_fun 4 解压nginx二进制包
  cd ${SOFTWARE_PATH}
  tar -xf  ${NGINX_VERSION}.tar.gz

  #删除解压的包
#  cd ${SOFTWARE_PATH}
#  rm -rf ${NGINX_VERSION}

   #安装依赖
   check_cluster_package openssl-devel
   check_cluster_package pcre-devel
   check_cluster_package zlib-devel
   check_cluster_package gcc

   #初始化nginx
   init_nginx

   #启动
   start_nginx
}

# ------------------------------------------------程序开始----------------------------------------------------
opt='y'
echo_fun 1 PLUMEMO - 一个轻量 易用 前后端分离的博客
echo_fun 1 开源地址:https://github.com/byteblogs168 喜欢就star一下
echo_fun 1 当前版本 v1.0.0 脚本由 PLUMEMO 官方提供
echo_fun 1 系统部署脚本正在执行
while [ "$opt" == "y" ];do
  echo_list
  plememo_install
  read -p '是否继续安装其他组件[y/n]:' opt
  echo ''
done




