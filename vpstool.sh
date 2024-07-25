#!/bin/bash

# Linux工具箱脚本
# 功能：VPS体检区、VPS网络区、VPS软件区、VPS安全区

# 检查用户是否是root用户
if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以root身份运行" 
   exit 1
fi

# 公告
announcement() {
    echo -e "\033[31mVPSTool v0.01\033[0m"
    echo -e "\033[31m该脚本仅收集网络公开的脚本 非原创\033[0m"
    echo ""
}

# 今日使用次数统计
update_usage_count() {
    local count_file="/tmp/tool_usage_count"
    local today=$(date +%Y-%m-%d)

    if [ ! -f "$count_file" ]; then
        echo "$today 1" > "$count_file"
    else
        local last_date=$(awk '{print $1}' "$count_file")
        local count=$(awk '{print $2}' "$count_file")

        if [ "$today" == "$last_date" ]; then
            count=$((count + 1))
            echo "$today $count" > "$count_file"
        else
            echo "$today 1" > "$count_file"
        fi
    fi
}

display_usage_count() {
    local count_file="/tmp/tool_usage_count"
    if [ -f "$count_file" ]; then
        local count=$(awk '{print $2}' "$count_file")
        echo -e "\033[32m本工具今日使用次数: $count\033[0m"
    else
        echo -e "\033[32m本工具今日使用次数: 0\033[0m"
    fi
}

# VPS体检区
vps_check_menu() {
    echo -e "\033[31mVPS体检区:\033[0m"
    echo "1. IP质量检测"
    echo "2. 一键融合怪"
    echo "3. 一键检测大小包"
    read -p "输入选项 (1-3): " choice
    case $choice in
        1) ip_quality_check ;;
        2) merge_monster ;;
        3) detect_packet_size ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
}

# VPS网络区
vps_network_menu() {
    echo -e "\033[31mVPS网络区:\033[0m"
    echo "1. 网络加速BBR"
    echo "2. 一键修改DNS"
    echo "3. IP管理"
    echo "4. 磁盘管理"
    read -p "输入选项 (1-4): " choice
    case $choice in
        1) enable_bbr ;;
        2) change_dns_menu ;;
        3) ip_management_menu ;;
        4) disk_management_menu ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
}
# 磁盘管理子菜单
disk_management_menu() {
    echo "请选择一个操作:"
    echo "1. 磁盘分区"
    echo "2. 磁盘备份"
    read -p "输入选项 (1-2): " disk_choice
    case $disk_choice in
        1) partition_disk ;;
        2) backup_disk ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
}

# 磁盘分区
partition_disk() {
    read -p "输入要分区的磁盘名 (例如 /dev/sdb): " disk
    echo "开始磁盘分区..."
    (
        echo o # 创建一个新的空 DOS 分区表
        echo n # 添加新分区
        echo p # 主分区
        echo 1 # 分区号
        echo   # 默认 - 第一个扇区
        echo +500M # 分区大小
        echo n # 添加新分区
        echo p # 主分区
        echo 2 # 分区号
        echo   # 默认 - 第一个扇区
        echo   # 默认 - 最后一个扇区
        echo w # 写入分区表并退出
    ) | sudo fdisk $disk
    echo "磁盘分区完成"
    update_usage_count
}

# 磁盘备份
backup_disk() {
    read -p "输入要备份的源磁盘名 (例如 /dev/sda): " source_disk
    read -p "输入备份文件路径 (例如 /backup/sda.img): " backup_path
    echo "开始磁盘备份..."
    sudo dd if=$source_disk of=$backup_path bs=4M status=progress
    echo "磁盘备份完成"
    update_usage_count
}

# IP管理子菜单
ip_management_menu() {
    echo "请选择一个操作:"
    echo "1. 新增IP绑定"
    echo "2. 删除IP绑定"
    read -p "输入选项 (1-2): " ip_choice
    case $ip_choice in
        1) add_ip_binding ;;
        2) remove_ip_binding ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
}

# 新增IP绑定
add_ip_binding() {
    read -p "输入要绑定的接口名 (例如 eth0): " interface
    read -p "输入要绑定的IP地址: " ip_address
    sudo ip addr add $ip_address dev $interface
    echo "已绑定 IP 地址 $ip_address 到接口 $interface"
    update_usage_count
}

# 删除IP绑定
remove_ip_binding() {
    read -p "输入要解绑的接口名 (例如 eth0): " interface
    read -p "输入要解绑的IP地址: " ip_address
    sudo ip addr del $ip_address dev $interface
    echo "已从接口 $interface 解绑 IP 地址 $ip_address"
    update_usage_count
}

# 一键修改DNS子菜单
change_dns_menu() {
    echo "请选择一个DNS:"
    echo "1. 修改为 1.1.1.1"
    echo "2. 修改为 8.8.8.8"
    echo "3. VKVM HK 15.235.198.195"
    echo "4. VKVM US 51.79.74.126"
    echo "5. VKVM SG 139.99.42.249"
    read -p "输入选项 (1-5): " dns_choice
    case $dns_choice in
        1) set_dns "1.1.1.1" ;;
        2) set_dns "8.8.8.8" ;;
        3) set_dns "15.235.198.195" ;;
        4) set_dns "51.79.74.126" ;;
        5) set_dns "139.99.42.249" ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
    update_usage_count
}

set_dns() {
    local dns=$1
    echo "nameserver $dns" | sudo tee /etc/resolv.conf > /dev/null
    echo "DNS 已修改为 $dns"
}
# VPS软件区
vps_software_menu() {
    echo -e "\033[31mVPS软件区:\033[0m"
    echo "1. 一键安装哪吒探针(面板)"
    echo "2. 一键安装哪吒探针(被控)"
    echo "3. 一键安装网盘程序(AList)"
    read -p "输入选项 (1-3): " choice
    case $choice in
        1) install_nezha_panel ;;
        2) install_nezha_agent ;;
        3) install_netdisk ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
}

# VPS安全区
vps_security_menu() {
    echo -e "\033[31mVPS安全区:\033[0m"
    echo "1. 通过iptables进行基本的攻击缓解"
    read -p "输入选项 (1): " choice
    case $choice in
        1) mitigate_attacks ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
}

# IP质量检测
ip_quality_check() {
    echo "开始IP质量检测..."
    bash <(curl -Ls IP.Check.Place)
    update_usage_count
}

# 一键融合怪
merge_monster() {
    echo "开始一键融合怪..."
    curl -L https://gitlab.com/spiritysdx/za/-/raw/main/ecs.sh -o ecs.sh
    chmod +x ecs.sh
    bash ecs.sh
    echo "融合怪完成"
    update_usage_count
}

# 网络加速BBR
enable_bbr() {
    echo "启用网络加速BBR..."
    echo 'net.core.default_qdisc=fq' | sudo tee -a /etc/sysctl.conf
    echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
    echo "BBR加速已启用"
    # 验证BBR是否启用
    sysctl net.ipv4.tcp_congestion_control
    lsmod | grep bbr
    update_usage_count
}

# 一键安装哪吒探针(面板)
install_nezha_panel() {
    echo "开始安装哪吒探针(面板)..."
    curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh
    chmod +x nezha.sh
    sudo ./nezha.sh
    echo "哪吒探针(面板)安装完成"
    update_usage_count
}

# 一键安装哪吒探针(被控)
install_nezha_agent() {
    echo "开始安装哪吒探针(被控)..."
    curl -L https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -o nezha.sh
    chmod +x nezha.sh
    sudo ./nezha.sh
    echo "哪吒探针(被控)安装完成"
    update_usage_count
}

# 一键安装网盘程序(AList)
install_netdisk() {
    echo "开始安装网盘程序(AList)..."
    curl -fsSL "https://alist.nn.ci/v3.sh" | bash -s install
    echo "网盘程序(AList)安装完成"
    update_usage_count
}

# 一键检测大小包
detect_packet_size() {
    echo "开始检测大小包..."
    curl nxtrace.org/nt | bash
    echo "检测完成"
    update_usage_count
}

# 通过iptables进行基本的攻击缓解
mitigate_attacks() {
    echo "开始通过iptables进行基本的攻击缓解..."
    # 限制SSH连接速率
    sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
    sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 10 -j DROP

    # 丢弃ping请求
    sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

    # 防止SYN洪泛攻击
    sudo iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

    # 防止端口扫描
    sudo iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
    sudo iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

    echo "基本攻击缓解规则已应用"
    update_usage_count
}

# 主菜单
show_menu() {
    echo -e "\033[31m请选择一个功能:\033[0m"
    echo "1. VPS体检区"
    echo "2. VPS网络区"
    echo "3. VPS软件区"
    echo "4. VPS安全区"
    echo "5. 退出"
    display_usage_count
    read -p "输入选项 (1-5): " choice
    case $choice in
        1) vps_check_menu ;;
        2) vps_network_menu ;;
        3) vps_software_menu ;;
        4) vps_security_menu ;;
        5) exit 0 ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
}

# 主循环
while true; do
    announcement
    show_menu
done
