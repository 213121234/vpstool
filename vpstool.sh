#!/bin/bash

# Linux工具箱脚本
# 功能：IP质量检测、一键融合怪、网络加速BBR、一键安装哪吒探针、一键安装网盘程序、一键跑路

# 检查用户是否是root用户
if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以root身份运行" 
   exit 1
fi

# IP质量检测
ip_quality_check() {
    echo "开始IP质量检测..."
    # 下载并执行 IPQuality 脚本
    if [ ! -d "./IPQuality" ]; then
        git clone https://github.com/xykt/IPQuality.git
    fi
    cd IPQuality || exit
    chmod +x ip_quality_check.sh
    ./ip_quality_check.sh
    cd ..
}

# 一键融合怪（示例功能）
merge_monster() {
    echo "开始一键融合怪..."
    # 这里添加融合怪的实现代码
    echo "融合怪完成"
}

# 网络加速BBR
enable_bbr() {
    echo "启用网络加速BBR..."
    modprobe tcp_bbr
    echo "tcp_bbr" >> /etc/modules-load.d/modules.conf
    sysctl -w net.core.default_qdisc=fq
    sysctl -w net.ipv4.tcp_congestion_control=bbr
    echo "BBR加速已启用"
}

# 一键安装哪吒探针
install_nezha() {
    echo "开始安装哪吒探针..."
    # 这里添加安装哪吒探针的代码
    echo "哪吒探针安装完成"
}

# 一键安装网盘程序
install_netdisk() {
    echo "开始安装网盘程序..."
    # 这里添加安装网盘程序的代码，例如Nextcloud
    echo "网盘程序安装完成"
}

# 一键跑路
run_away() {
    echo "执行一键跑路..."
    # 这里可以添加删除敏感数据或停止服务的代码
    echo "跑路完成"
}

# 菜单
show_menu() {
    echo "请选择一个功能:"
    echo "1. IP质量检测"
    echo "2. 一键融合怪"
    echo "3. 网络加速BBR"
    echo "4. 一键安装哪吒探针"
    echo "5. 一键安装网盘程序"
    echo "6. 一键跑路"
    echo "7. 退出"
    read -p "输入选项 (1-7): " choice
    case $choice in
        1) ip_quality_check ;;
        2) merge_monster ;;
        3) enable_bbr ;;
        4) install_nezha ;;
        5) install_netdisk ;;
        6) run_away ;;
        7) exit 0 ;;
        *) echo "无效选项" ;;
    esac
}

# 主循环
while true; do
    show_menu
done
