#!/bin/bash

# Linux工具箱脚本
# 功能：IP质量检测、一键融合怪、网络加速BBR、一键安装哪吒探针(面板)、一键安装哪吒探针(被控)、一键安装网盘程序(AList)、一键修改DNS、通过iptables进行基本的攻击缓解、修改IPv4/IPv6优先级

# 检查用户是否是root用户
if [[ $EUID -ne 0 ]]; then
   echo "此脚本必须以root身份运行" 
   exit 1
fi

# 公告
announcement() {
    echo -e "\033[31mVPSTool v0.01\033[0m"
    echo -e "\033[31m该脚本仅收集网络公开的脚本 非原创\033[0m"
    echo -e "\033[31m赞助商;VKVM:www.vkvm.info\033[0m"
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

# 一键修改DNS
change_dns() {
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

# 修改IPv4/IPv6优先级
change_ip_priority() {
    echo "请选择优先级设置:"
    echo "1. IPv4优先"
    echo "2. IPv6优先"
    read -p "输入选项 (1-2): " ip_choice
    case $ip_choice in
        1) set_ipv4_priority ;;
        2) set_ipv6_priority ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
    update_usage_count
}

set_ipv4_priority() {
    echo "设置IPv4优先..."
    sudo sed -i '/^#precedence ::ffff:0:0\/96  100/s/^#//' /etc/gai.conf
    sudo sed -i '/^precedence ::ffff:0:0\/96  100/!s/^/precedence ::ffff:0:0\/96  100\n/' /etc/gai.conf
    echo "已设置为IPv4优先"
}

set_ipv6_priority() {
    echo "设置IPv6优先..."
    sudo sed -i '/^precedence ::ffff:0:0\/96  100/s/^/#/' /etc/gai.conf
    echo "已设置为IPv6优先"
}

# 菜单
show_menu() {
    echo -e "\033[31m请选择一个功能:\033[0m"
    echo "1. IP质量检测"
    echo "2. 一键融合怪"
    echo "3. 网络加速BBR"
    echo "4. 一键安装哪吒探针(面板)"
    echo "5. 一键安装哪吒探针(被控)"
    echo "6. 一键安装网盘程序(AList)"
    echo "7. 一键修改DNS"
    echo "8. 通过iptables进行基本的攻击缓解"
    echo "9. 修改IPv4/IPv6优先级"
    echo "10. 退出"
    display_usage_count
    read -p "输入选项 (1-10): " choice
    case $choice in
        1) ip_quality_check ;;
        2) merge_monster ;;
        3) enable_bbr ;;
        4) install_nezha_panel ;;
        5) install_nezha_agent ;;
        6) install_netdisk ;;
        7) change_dns ;;
        8) mitigate_attacks ;;
        9) change_ip_priority ;;
        10) exit 0 ;;
        *) echo -e "\033[31m无效选项\033[0m" ;;
    esac
}

# 主循环
while true; do
    announcement
    show_menu
done
