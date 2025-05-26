#!/bin/bash

# MTProto Proxy Installation and Management Script
# Script cài đặt và quản lý MTProto Proxy
# Supports Ubuntu/Debian and CentOS - Hỗ trợ Ubuntu/Debian và CentOS
# Includes interactive menu, random port selection, fake-TLS, NAT, and BBR
# Bao gồm menu tương tác, chọn port ngẫu nhiên, fake-TLS, NAT, và BBR
# Must run with root or sudo privileges - Phải chạy với quyền root hoặc sudo

# Language selection - Chọn ngôn ngữ
select_language() {
  echo "Please select language / Vui lòng chọn ngôn ngữ:"
  echo "1) English"
  echo "2) Tiếng Việt"
  read -r -p "Choose [1-2] / Chọn [1-2]: " -e -i "2" LANG_CHOICE
  case $LANG_CHOICE in
    1) LANGUAGE="en" ;;
    2) LANGUAGE="vi" ;;
    *) LANGUAGE="vi" ;;
  esac
}

# Check for language parameter
LANGUAGE="vi"  # Default to Vietnamese
LANG_SET=false

for arg in "$@"; do
  case $arg in
    --lang=en|--language=en)
      LANGUAGE="en"
      LANG_SET=true
      ;;
    --lang=vi|--language=vi)
      LANGUAGE="vi"
      LANG_SET=true
      ;;
  esac
done

# If no language parameter and interactive mode, ask user
if [ "$LANG_SET" = false ] && [ "$#" -eq 0 ]; then
  select_language
fi

# Text functions for multilingual support
get_text() {
  local key="$1"
  case $LANGUAGE in
    "en")
      case $key in
        "root_required") echo "Please run this script with root privileges" ;;
        "installing_lsof") echo "Installing lsof package..." ;;
        "lsof_warning") echo "$(tput setaf 3)Warning!$(tput sgr 0) lsof package installation failed. Random port may be in use." ;;
        "bbr_already_enabled") echo "BBR was already enabled." ;;
        "bbr_warning") echo "$(tput setaf 3)Warning:$(tput sgr 0) Cannot load tcp_bbr module. Kernel: $(uname -r)." ;;
        "bbr_enabled") echo "BBR has been successfully enabled." ;;
        "bbr_config_exists") echo "BBR configuration already exists, applying..." ;;
        "mtproxy_installed") echo "You have MTProxy installed! What would you like to do?" ;;
        "menu_show_links") echo "  1) Show connection links" ;;
        "menu_change_tag") echo "  2) Change TAG" ;;
        "menu_add_secret") echo "  3) Add secret" ;;
        "menu_remove_secret") echo "  4) Remove secret" ;;
        "menu_change_workers") echo "  5) Change worker count" ;;
        "menu_change_nat") echo "  6) Change NAT settings" ;;
        "menu_change_custom") echo "  7) Change custom parameters" ;;
        "menu_firewall_rules") echo "  8) Create firewall rules" ;;
        "menu_uninstall") echo "  9) Uninstall Proxy" ;;
        "menu_info") echo "  10) Information" ;;
        "menu_exit") echo "  *) Exit" ;;
        "enter_number") echo "Please enter number: " ;;
        "getting_ip") echo "$(tput setaf 3)Getting your IP address.$(tput sgr 0)" ;;
        "cannot_get_ip") echo "Cannot get public IP. Please replace YOUR_IP with your server IP." ;;
        "tag_empty") echo "Your advertisement TAG seems to be empty. Get TAG from https://t.me/mtproxybot and enter here:" ;;
        "tag_current") echo "Current TAG is \$TAG. To remove, press Enter. Otherwise, enter new TAG:" ;;
        "completed") echo "Completed" ;;
        "error_max_secrets") echo "$(tput setaf 1)Error$(tput sgr 0) You cannot have more than 16 secrets" ;;
        "secret_manual_or_random") echo "Do you want to enter secret manually or let me generate randomly?" ;;
        "secret_manual") echo "   1) Enter secret manually" ;;
        "secret_random") echo "   2) Generate random secret" ;;
        "choose_1_2") echo "Please choose [1-2]: " ;;
        "enter_hex_secret") echo "Enter 32-character string with 0-9 and a-f (hexadecimal): " ;;
        "error_invalid_hex") echo "$(tput setaf 1)Error:$(tput sgr 0) Please enter hexadecimal characters and secret must be 32 characters long." ;;
        "secret_generated") echo "Generated secret: \$SECRET" ;;
        "invalid_option") echo "$(tput setaf 1)Invalid option$(tput sgr 0)" ;;
        "connect_with_secret") echo "You can connect to server with this secret via link:" ;;
        "cannot_remove_last") echo "Cannot remove the last secret." ;;
        "choose_secret_remove") echo "Choose secret to remove:" ;;
        "choose_secret_number") echo "Choose the number of secret to remove: " ;;
        "error_invalid_number") echo "$(tput setaf 1)Error:$(tput sgr 0) Input is not a valid number" ;;
        "error_invalid_range") echo "$(tput setaf 1)Error$(tput sgr 0) Invalid number" ;;
        "cpu_cores_detected") echo "I detected your server has \$CPU_CORES cores. I can configure proxy to use all cores, creating \$CPU_CORES workers. However, proxy may have issues if using more than 16 cores. Please choose number from 1 to 16." ;;
        "how_many_workers") echo "How many workers do you want proxy to create? " ;;
        "error_enter_greater_1") echo "$(tput setaf 1)Error:$(tput sgr 0) Enter number greater than 1." ;;
        "warning_over_16") echo "$(tput setaf 3)Warning:$(tput sgr 0) Values over 16 may cause issues. Continue at your own risk." ;;
        "nat_question") echo "Is your server behind NAT? (You may need this option if using AWS)(y/n) " ;;
        "enter_public_ip") echo "Please enter public IP address: " ;;
        "detected_private_ip") echo "I detected \$IP is a private IP address. Please confirm." ;;
        "enter_private_ip") echo "Please enter private IP address: " ;;
        "custom_params_prompt") echo "If you want to use custom parameters to run proxy, enter here; Otherwise, press Enter." ;;
        "apply_rules_question") echo "Do you want to apply these rules?[y/n] " ;;
        "uninstall_question") echo "I will keep some packages like \"Development Tools\". Do you want to uninstall MTProto-Proxy?(y/n) " ;;
        "uninstall_completed") echo "Uninstall completed." ;;
        "script_info") echo "MTProto Proxy Installation Script" ;;
        "mtproxy_source") echo "MTProxy Source: https://github.com/GetPageSpeed/MTProxy" ;;
        "telegram_official") echo "Telegram Official: https://github.com/TelegramMessenger/MTProxy" ;;
        "welcome_message") echo "Welcome to the automatic MTProto-Proxy installer!" ;;
        "using_mtproxy") echo "Using GetPageSpeed/MTProxy" ;;
        "gathering_info") echo "Now I will gather some information from you..." ;;
        "choose_port") echo "Choose port to proxy listen on (-1 for random): " ;;
        "port_selected") echo "I have selected \$PORT as your port." ;;
        "error_invalid_port") echo "$(tput setaf 1)Error:$(tput sgr 0) Input is not a valid number" ;;
        "error_port_range") echo "$(tput setaf 1)Error:$(tput sgr 0) Number must be less than 65536" ;;
        "want_add_more_secret") echo "Do you want to add another secret?(y/n) " ;;
        "want_setup_tag") echo "Do you want to set up advertisement TAG?(y/n) " ;;
        "tag_note") echo "$(tput setaf 1)Note:$(tput sgr 0) Users and admins who have already joined will not see the ad channel at the top." ;;
        "tag_instructions") echo "On Telegram, go to @MTProxybot and enter this server's IP and port \$PORT. Then enter secret \$SECRET" ;;
        "tag_bot_response") echo "The bot will provide a TAG string. Enter it here:" ;;
        "want_auto_update") echo "Do you want to enable automatic config updates? I will update \"proxy-secret\" and \"proxy-multi.conf\" daily at 12:00 AM. Recommended to enable.[y/n] " ;;
        "choose_tls_domain") echo "Choose host that DPI thinks you are visiting (TLS_DOMAIN). Leave empty to disable Fake-TLS. Enabling this option will automatically disable 'dd' secret: " ;;
        "want_custom_params") echo "If you want to use custom parameters to run proxy, enter here; Otherwise, press Enter." ;;
        "want_bbr") echo "Do you want to use BBR? BBR can help proxy run faster (y/n): " ;;
        "press_any_key") echo "Press any key to install..." ;;
        "error_no_secret") echo "$(tput setaf 1)Error:$(tput sgr 0) Please enter at least one secret" ;;
        "error_invalid_secret") echo "$(tput setaf 1)Error:$(tput sgr 0) Secret must be 32 hexadecimal characters. Error at secret \$SECRET" ;;
        "port_auto_selected") echo "I have selected \$PORT as your port." ;;
        "setting_firewall") echo "Setting up firewall rules" ;;
        "firewalld_not_installed") echo "It seems \"firewalld\" is not installed. Do you want to install it?(y/n) " ;;
        "ufw_not_installed") echo "It seems \"UFW\" (Firewall) is not installed. Do you want to install it?(y/n) " ;;
        "compile_warning") echo "$(tput setaf 3)Warning: $(tput sgr 0)Compilation successful but service is not running." ;;
        "check_status") echo "Check status with \"systemctl status MTProxy\"" ;;
        "proxy_links_header") echo "Here are the links for your proxy:" ;;
        "register_with_bot") echo "You can register your proxy with @MTProxybot on Telegram." ;;
        "check_stats") echo "To check proxy statistics, visit: http://localhost:8888/stats" ;;
        "error_build_failed") echo "$(tput setaf 1)Error:$(tput sgr 0) Build failed with exit code \$BUILD_STATUS" ;;
        "removing_project_files") echo "Removing project files..." ;;
        "error_proxy_secret") echo "$(tput setaf 1)Error:$(tput sgr 0) Cannot download proxy-secret from Telegram server." ;;
        "error_proxy_config") echo "$(tput setaf 1)Error:$(tput sgr 0) Cannot download proxy-multi.conf from Telegram server." ;;
        "setup_mtconfig") echo "Setting up mtconfig.conf" ;;
        "updater_log_message") echo "Update ran at \$(date). Exit codes for getProxySecret and getProxyConfig are \$STATUS_SECRET and \$STATUS_CONF" ;;
        "completed") echo "Completed" ;;
        "cannot_get_ip") echo "Cannot get your IP address. Please replace YOUR_IP with your server's IP address." ;;
        *) echo "$key" ;;
      esac
      ;;
    "vi")
      case $key in
        "root_required") echo "Vui lòng chạy script này với quyền root" ;;
        "installing_lsof") echo "Đang cài đặt gói lsof..." ;;
        "lsof_warning") echo "$(tput setaf 3)Cảnh báo!$(tput sgr 0) Gói lsof không được cài đặt thành công. Port ngẫu nhiên có thể đang được sử dụng." ;;
        "bbr_already_enabled") echo "BBR đã được kích hoạt trước đó." ;;
        "bbr_warning") echo "$(tput setaf 3)Cảnh báo:$(tput sgr 0) Không thể tải module tcp_bbr. Kernel: $(uname -r)." ;;
        "bbr_enabled") echo "BBR đã được kích hoạt thành công." ;;
        "bbr_config_exists") echo "Cấu hình BBR đã tồn tại, đang áp dụng..." ;;
        "mtproxy_installed") echo "Bạn đã cài đặt MTProxy! Bạn muốn làm gì?" ;;
        "menu_show_links") echo "  1) Hiển thị liên kết kết nối" ;;
        "menu_change_tag") echo "  2) Thay đổi TAG" ;;
        "menu_add_secret") echo "  3) Thêm secret" ;;
        "menu_remove_secret") echo "  4) Xóa secret" ;;
        "menu_change_workers") echo "  5) Thay đổi số lượng Worker" ;;
        "menu_change_nat") echo "  6) Thay đổi cài đặt NAT" ;;
        "menu_change_custom") echo "  7) Thay đổi tham số tùy chỉnh" ;;
        "menu_firewall_rules") echo "  8) Tạo quy tắc tường lửa" ;;
        "menu_uninstall") echo "  9) Gỡ cài đặt Proxy" ;;
        "menu_info") echo "  10) Thông tin" ;;
        "menu_exit") echo "  *) Thoát" ;;
        "enter_number") echo "Vui lòng nhập số: " ;;
        "getting_ip") echo "$(tput setaf 3)Đang lấy địa chỉ IP của bạn.$(tput sgr 0)" ;;
        "cannot_get_ip") echo "Không thể lấy IP công cộng. Vui lòng thay YOUR_IP bằng IP server của bạn." ;;
        "tag_empty") echo "Có vẻ TAG quảng cáo của bạn đang trống. Lấy TAG tại https://t.me/mtproxybot và nhập vào đây:" ;;
        "tag_current") echo "TAG hiện tại là \$TAG. Nếu muốn xóa, nhấn Enter. Nếu không, nhập TAG mới:" ;;
        "completed") echo "Hoàn tất" ;;
        "error_max_secrets") echo "$(tput setaf 1)Lỗi$(tput sgr 0) Bạn không thể có quá 16 secret" ;;
        "secret_manual_or_random") echo "Bạn muốn tự nhập secret hay để tôi tạo ngẫu nhiên?" ;;
        "secret_manual") echo "   1) Nhập secret thủ công" ;;
        "secret_random") echo "   2) Tạo secret ngẫu nhiên" ;;
        "choose_1_2") echo "Vui lòng chọn [1-2]: " ;;
        "enter_hex_secret") echo "Nhập chuỗi 32 ký tự gồm 0-9 và a-f (hexadecimal): " ;;
        "error_invalid_hex") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Vui lòng nhập ký tự hexadecimal và secret phải dài 32 ký tự." ;;
        "secret_generated") echo "Đã tạo secret: \$SECRET" ;;
        "invalid_option") echo "$(tput setaf 1)Tùy chọn không hợp lệ$(tput sgr 0)" ;;
        "connect_with_secret") echo "Bạn có thể kết nối tới server với secret này qua liên kết:" ;;
        "cannot_remove_last") echo "Không thể xóa secret cuối cùng." ;;
        "choose_secret_remove") echo "Chọn secret để xóa:" ;;
        "choose_secret_number") echo "Chọn số thứ tự của secret để xóa: " ;;
        "error_invalid_number") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Đầu vào không phải số hợp lệ" ;;
        "error_invalid_range") echo "$(tput setaf 1)Lỗi$(tput sgr 0) Số không hợp lệ" ;;
        "cpu_cores_detected") echo "Tôi phát hiện server của bạn có \$CPU_CORES lõi. Tôi có thể cấu hình proxy sử dụng tất cả lõi, tạo \$CPU_CORES worker. Tuy nhiên, proxy có thể gặp lỗi nếu dùng quá 16 lõi. Vui lòng chọn số từ 1 đến 16." ;;
        "how_many_workers") echo "Bạn muốn proxy tạo bao nhiêu worker? " ;;
        "error_enter_greater_1") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Nhập số lớn hơn 1." ;;
        "warning_over_16") echo "$(tput setaf 3)Cảnh báo:$(tput sgr 0) Giá trị trên 16 có thể gây vấn đề. Tiếp tục với rủi ro của bạn." ;;
        "nat_question") echo "Server của bạn có nằm sau NAT không? (Bạn có thể cần tùy chọn này nếu dùng AWS)(y/n) " ;;
        "enter_public_ip") echo "Vui lòng nhập địa chỉ IP công cộng: " ;;
        "detected_private_ip") echo "Tôi phát hiện \$IP là địa chỉ IP riêng. Vui lòng xác nhận." ;;
        "enter_private_ip") echo "Vui lòng nhập địa chỉ IP riêng: " ;;
        "custom_params_prompt") echo "Nếu muốn sử dụng tham số tùy chỉnh để chạy proxy, nhập vào đây; Nếu không, nhấn Enter." ;;
        "apply_rules_question") echo "Bạn có muốn áp dụng các quy tắc này không?[y/n] " ;;
        "uninstall_question") echo "Tôi sẽ giữ lại một số gói như \"Development Tools\". Bạn có muốn gỡ cài đặt MTProto-Proxy không?(y/n) " ;;
        "uninstall_completed") echo "Đã gỡ cài đặt xong." ;;
        "script_info") echo "Script cài đặt MTProto Proxy" ;;
        "mtproxy_source") echo "Nguồn MTProxy: https://github.com/GetPageSpeed/MTProxy" ;;
        "telegram_official") echo "Telegram Official: https://github.com/TelegramMessenger/MTProxy" ;;
        "welcome_message") echo "Chào mừng bạn đến với trình cài đặt tự động MTProto-Proxy!" ;;
        "using_mtproxy") echo "Sử dụng GetPageSpeed/MTProxy" ;;
        "gathering_info") echo "Bây giờ tôi sẽ thu thập một số thông tin từ bạn..." ;;
        "choose_port") echo "Chọn port để proxy lắng nghe (-1 để chọn ngẫu nhiên): " ;;
        "port_selected") echo "Tôi đã chọn \$PORT làm port của bạn." ;;
        "error_invalid_port") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Đầu vào không phải số hợp lệ" ;;
        "error_port_range") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Số phải nhỏ hơn 65536" ;;
        "want_add_more_secret") echo "Bạn có muốn thêm secret khác không?(y/n) " ;;
        "want_setup_tag") echo "Bạn có muốn thiết lập TAG quảng cáo không?(y/n) " ;;
        "tag_note") echo "$(tput setaf 1)Lưu ý:$(tput sgr 0) Người dùng và quản trị viên đã tham gia sẽ không thấy kênh quảng cáo ở đầu." ;;
        "tag_instructions") echo "Trên Telegram, vào @MTProxybot và nhập IP của server này cùng port \$PORT. Sau đó nhập secret \$SECRET" ;;
        "tag_bot_response") echo "Bot sẽ cung cấp một chuỗi TAG. Nhập vào đây:" ;;
        "want_auto_update") echo "Bạn có muốn bật cập nhật cấu hình tự động không? Tôi sẽ cập nhật \"proxy-secret\" và \"proxy-multi.conf\" mỗi ngày lúc 12:00 AM. Khuyến nghị bật.[y/n] " ;;
        "choose_tls_domain") echo "Chọn host mà DPI nghĩ bạn đang truy cập (TLS_DOMAIN). Để trống để tắt Fake-TLS. Bật tùy chọn này sẽ tự động tắt secret 'dd': " ;;
        "want_custom_params") echo "Nếu muốn sử dụng tham số tùy chỉnh để chạy proxy, nhập vào đây; Nếu không, nhấn Enter." ;;
        "want_bbr") echo "Bạn có muốn sử dụng BBR? BBR có thể giúp proxy chạy nhanh hơn (y/n): " ;;
        "press_any_key") echo "Nhấn phím bất kỳ để cài đặt..." ;;
        "error_no_secret") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Vui lòng nhập ít nhất một secret" ;;
        "error_invalid_secret") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Secret phải là 32 ký tự hexadecimal. Lỗi tại secret \$SECRET" ;;
        "port_auto_selected") echo "Tôi đã chọn \$PORT làm port của bạn." ;;
        "setting_firewall") echo "Đang thiết lập quy tắc tường lửa" ;;
        "firewalld_not_installed") echo "Có vẻ \"firewalld\" chưa được cài đặt. Bạn có muốn cài không?(y/n) " ;;
        "ufw_not_installed") echo "Có vẻ \"UFW\" (Tường lửa) chưa được cài đặt. Bạn có muốn cài không?(y/n) " ;;
        "compile_warning") echo "$(tput setaf 3)Cảnh báo: $(tput sgr 0)Biên dịch thành công nhưng dịch vụ không chạy." ;;
        "check_status") echo "Kiểm tra trạng thái với \"systemctl status MTProxy\"" ;;
        "proxy_links_header") echo "Đây là các liên kết cho proxy:" ;;
        "register_with_bot") echo "Bạn có thể đăng ký proxy với @MTProxybot trên Telegram." ;;
        "check_stats") echo "Để kiểm tra thống kê proxy, truy cập: http://localhost:8888/stats" ;;
        "error_build_failed") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Biên dịch thất bại với mã lỗi \$BUILD_STATUS" ;;
        "removing_project_files") echo "Đang xóa các file dự án..." ;;
        "error_proxy_secret") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Không thể tải proxy-secret từ server Telegram." ;;
        "error_proxy_config") echo "$(tput setaf 1)Lỗi:$(tput sgr 0) Không thể tải proxy-multi.conf từ server Telegram." ;;
        "setup_mtconfig") echo "Thiết lập mtconfig.conf" ;;
        "updater_log_message") echo "Cập nhật chạy lúc \$(date). Mã thoát của getProxySecret và getProxyConfig là \$STATUS_SECRET và \$STATUS_CONF" ;;
        "completed") echo "Hoàn tất" ;;
        "cannot_get_ip") echo "Không thể lấy địa chỉ IP của bạn. Vui lòng thay thế YOUR_IP bằng địa chỉ IP của server." ;;
        *) echo "$key" ;;
      esac
      ;;
  esac
}

# Check root privileges
if [ "$EUID" -ne 0 ]; then
  get_text "root_required"
  exit 1
fi

# Detect operating system
distro=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"')
regex='^[0-9]+$'

# Random port selection function
GetRandomPort() {
  if ! [ "$INSTALLED_LSOF" == true ]; then
    get_text "installing_lsof"
    if [[ $distro =~ "CentOS" ]]; then
      yum -y -q install lsof
    elif [[ $distro =~ "Ubuntu" ]] || [[ $distro =~ "Debian" ]]; then
      apt-get -y install lsof >/dev/null
    fi
    RETURN_CODE=$?
    if [ $RETURN_CODE -ne 0 ]; then
      get_text "lsof_warning"
    else
      INSTALLED_LSOF=true
    fi
  fi
  PORT=$((RANDOM % 16383 + 49152))
  if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null; then
    GetRandomPort
  fi
}

# Generate systemd service function
GenerateService() {
  local ARGS_STR
  ARGS_STR="-u nobody -H $PORT"
  for i in "${SECRET_ARY[@]}"; do
    ARGS_STR+=" -S $i"
  done
  if [ -n "$TAG" ]; then
    ARGS_STR+=" -P $TAG "
  fi
  if [ -n "$TLS_DOMAIN" ]; then
    ARGS_STR+=" -D $TLS_DOMAIN "
  fi
  if [ "$HAVE_NAT" == "y" ]; then
    ARGS_STR+=" --nat-info $PRIVATE_IP:$PUBLIC_IP "
  fi
  NEW_CORE=$((CPU_CORES - 1))
  ARGS_STR+=" -M $NEW_CORE $CUSTOM_ARGS --aes-pwd proxy-secret proxy-multi.conf"
  SERVICE_STR="[Unit]
Description=MTProxy
After=network.target

[Service]
Type=simple
WorkingDirectory=/opt/MTProxy
ExecStart=/opt/MTProxy/mtproto-proxy $ARGS_STR
Restart=on-failure
StartLimitBurst=0

[Install]
WantedBy=multi-user.target"
}

# BBR check and enable function
enable_bbr() {
  # Check current BBR status
  if [ "$(sysctl -n net.ipv4.tcp_congestion_control)" = "bbr" ]; then
    get_text "bbr_already_enabled"
    return 0
  fi

  # Load tcp_bbr module if not loaded
  if ! lsmod | grep -q tcp_bbr; then
    modprobe tcp_bbr 2>/dev/null
    if [ $? -ne 0 ]; then
      get_text "bbr_warning"
      return 1
    fi
    # Save module for auto-load on boot
    echo "tcp_bbr" >> /etc/modules-load.d/tcp_bbr.conf
  fi

  # Enable BBR
  if ! grep -q "net.core.default_qdisc=fq" /etc/sysctl.conf || ! grep -q "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf; then
    echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf
    sysctl -p >/dev/null
    get_text "bbr_enabled"
  else
    get_text "bbr_config_exists"
    sysctl -p >/dev/null
    get_text "bbr_enabled"
  fi
  return 0
}

# Menu for installed case
if [ -d "/opt/MTProxy" ]; then
  get_text "mtproxy_installed"
  get_text "menu_show_links"
  get_text "menu_change_tag"
  get_text "menu_add_secret"
  get_text "menu_remove_secret"
  get_text "menu_change_workers"
  get_text "menu_change_nat"
  get_text "menu_change_custom"
  get_text "menu_firewall_rules"
  get_text "menu_uninstall"
  get_text "menu_info"
  get_text "menu_exit"
  read -r -p "$(get_text "enter_number")" OPTION
  source /opt/MTProxy/mtconfig.conf # Load configuration
  case $OPTION in
  1)
    clear
    get_text "getting_ip"
    PUBLIC_IP=$(curl -s https://api.ipify.org || wget -qO- http://ipecho.net/plain)
    CURL_EXIT_STATUS=$?
    if [ $CURL_EXIT_STATUS -ne 0 ]; then
      PUBLIC_IP="YOUR_IP"
      get_text "cannot_get_ip"
    fi
    HEX_DOMAIN=$(printf "%s" "$TLS_DOMAIN" | xxd -pu)
    HEX_DOMAIN=$(echo "$HEX_DOMAIN" | tr '[A-Z]' '[a-z]')
    for i in "${SECRET_ARY[@]}"; do
      if [ -z "$TLS_DOMAIN" ]; then
        echo "tg://proxy?server=$PUBLIC_IP&port=$PORT&secret=dd$i"
      else
        echo "tg://proxy?server=$PUBLIC_IP&port=$PORT&secret=ee$i$HEX_DOMAIN"
      fi
    done
    ;;
  2)
    if [ -z "$TAG" ]; then
      get_text "tag_empty"
    else
      echo "$(get_text "tag_current" | sed "s/\\\$TAG/$TAG/")"
    fi
    read -r TAG
    cd /etc/systemd/system || exit 2
    systemctl stop MTProxy
    GenerateService
    echo "$SERVICE_STR" >MTProxy.service
    systemctl daemon-reload
    systemctl start MTProxy
    cd /opt/MTProxy || exit 2
    sed -i "s/^TAG=.*/TAG=\"$TAG\"/" mtconfig.conf
    get_text "completed"
    ;;
  3)
    if [ "${#SECRET_ARY[@]}" -ge 16 ]; then
      get_text "error_max_secrets"
      exit 1
    fi
    get_text "secret_manual_or_random"
    get_text "secret_manual"
    get_text "secret_random"
    read -r -p "$(get_text "choose_1_2")" -e -i 2 OPTION
    case $OPTION in
    1)
      get_text "enter_hex_secret"
      read -r SECRET
      SECRET=$(echo "$SECRET" | tr '[A-Z]' '[a-z]')
      if ! [[ $SECRET =~ ^[0-9a-f]{32}$ ]]; then
        get_text "error_invalid_hex"
        exit 1
      fi
      ;;
    2)
      SECRET=$(hexdump -vn "16" -e ' /1 "%02x"' /dev/urandom)
      echo "$(get_text "secret_generated" | sed "s/\\\$SECRET/$SECRET/")"
      ;;
    *)
      get_text "invalid_option"
      exit 1
      ;;
    esac
    SECRET_ARY+=("$SECRET")
    cd /etc/systemd/system || exit 2
    systemctl stop MTProxy
    GenerateService
    echo "$SERVICE_STR" >MTProxy.service
    systemctl daemon-reload
    systemctl start MTProxy
    cd /opt/MTProxy || exit 2
    SECRET_ARY_STR=${SECRET_ARY[*]}
    sed -i "s/^SECRET_ARY=.*/SECRET_ARY=($SECRET_ARY_STR)/" mtconfig.conf
    get_text "completed"
    PUBLIC_IP=$(curl -s https://api.ipify.org || wget -qO- http://ipecho.net/plain)
    CURL_EXIT_STATUS=$?
    if [ $CURL_EXIT_STATUS -ne 0 ]; then
      PUBLIC_IP="YOUR_IP"
    fi
    echo
    get_text "connect_with_secret"
    echo "tg://proxy?server=$PUBLIC_IP&port=$PORT&secret=dd$SECRET"
    ;;
  4)
    NUMBER_OF_SECRETS=${#SECRET_ARY[@]}
    if [ "$NUMBER_OF_SECRETS" -le 1 ]; then
      get_text "cannot_remove_last"
      exit 1
    fi
    get_text "choose_secret_remove"
    COUNTER=1
    for i in "${SECRET_ARY[@]}"; do
      echo "  $COUNTER) $i"
      COUNTER=$((COUNTER + 1))
    done
    read -r -p "$(get_text "choose_secret_number")" USER_TO_REVOKE
    if ! [[ $USER_TO_REVOKE =~ $regex ]]; then
      get_text "error_invalid_number"
      exit 1
    fi
    if [ "$USER_TO_REVOKE" -lt 1 ] || [ "$USER_TO_REVOKE" -gt "$NUMBER_OF_SECRETS" ]; then
      get_text "error_invalid_range"
      exit 1
    fi
    USER_TO_REVOKE1=$((USER_TO_REVOKE - 1))
    SECRET_ARY=("${SECRET_ARY[@]:0:$USER_TO_REVOKE1}" "${SECRET_ARY[@]:$USER_TO_REVOKE}")
    cd /etc/systemd/system || exit 2
    systemctl stop MTProxy
    GenerateService
    echo "$SERVICE_STR" >MTProxy.service
    systemctl daemon-reload
    systemctl start MTProxy
    cd /opt/MTProxy || exit 2
    SECRET_ARY_STR=${SECRET_ARY[*]}
    sed -i "s/^SECRET_ARY=.*/SECRET_ARY=($SECRET_ARY_STR)/" mtconfig.conf
    get_text "completed"
    ;;
  5)
    CPU_CORES=$(nproc --all)
    echo "$(get_text "cpu_cores_detected" | sed "s/\\\$CPU_CORES/$CPU_CORES/g")"
    read -r -p "$(get_text "how_many_workers")" -e -i "$CPU_CORES" CPU_CORES
    if ! [[ $CPU_CORES =~ $regex ]]; then
      get_text "error_invalid_number"
      exit 1
    fi
    if [ "$CPU_CORES" -lt 1 ]; then
      get_text "error_enter_greater_1"
      exit 1
    fi
    if [ "$CPU_CORES" -gt 16 ]; then
      get_text "warning_over_16"
    fi
    cd /etc/systemd/system || exit 2
    systemctl stop MTProxy
    GenerateService
    echo "$SERVICE_STR" >MTProxy.service
    systemctl daemon-reload
    systemctl start MTProxy
    cd /opt/MTProxy || exit 2
    sed -i "s/^CPU_CORES=.*/CPU_CORES=$CPU_CORES/" mtconfig.conf
    get_text "completed"
    ;;
  6)
    IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
    HAVE_NAT="n"
    if echo "$IP" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
      HAVE_NAT="y"
    fi
    read -r -p "$(get_text "nat_question")" -e -i "$HAVE_NAT" HAVE_NAT
    if [[ "$HAVE_NAT" == "y" || "$HAVE_NAT" == "Y" ]]; then
      PUBLIC_IP=$(curl -s https://api.ipify.org || wget -qO- http://ipecho.net/plain)
      read -r -p "$(get_text "enter_public_ip")" -e -i "$PUBLIC_IP" PUBLIC_IP
      if echo "$IP" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
        echo "$(get_text "detected_private_ip" | sed "s/\\\$IP/$IP/")"
      else
        IP=""
      fi
      read -r -p "$(get_text "enter_private_ip")" -e -i "$IP" PRIVATE_IP
    fi
    cd /opt/MTProxy || exit 2
    sed -i "s/^HAVE_NAT=.*/HAVE_NAT=\"$HAVE_NAT\"/" mtconfig.conf
    sed -i "s/^PUBLIC_IP=.*/PUBLIC_IP=\"$PUBLIC_IP\"/" mtconfig.conf
    sed -i "s/^PRIVATE_IP=.*/PRIVATE_IP=\"$PRIVATE_IP\"/" mtconfig.conf
    cd /etc/systemd/system || exit 2
    systemctl stop MTProxy
    GenerateService
    echo "$SERVICE_STR" >MTProxy.service
    systemctl daemon-reload
    systemctl start MTProxy
    get_text "completed"
    ;;
  7)
    get_text "custom_params_prompt"
    read -r -e -i "$CUSTOM_ARGS" CUSTOM_ARGS
    cd /etc/systemd/system || exit 2
    systemctl stop MTProxy
    GenerateService
    echo "$SERVICE_STR" >MTProxy.service
    systemctl daemon-reload
    systemctl start MTProxy
    cd /opt/MTProxy || exit 2
    sed -i "s/^CUSTOM_ARGS=.*/CUSTOM_ARGS=\"$CUSTOM_ARGS\"/" mtconfig.conf
    get_text "completed"
    ;;
  8)
    if [[ $distro =~ "CentOS" ]]; then
      echo "firewall-cmd --zone=public --add-port=$PORT/tcp"
      echo "firewall-cmd --runtime-to-permanent"
    elif [[ $distro =~ "Ubuntu" ]]; then
      echo "ufw allow $PORT/tcp"
    elif [[ $distro =~ "Debian" ]]; then
      echo "iptables -A INPUT -p tcp --dport $PORT --jump ACCEPT"
      echo "iptables-save > /etc/iptables/rules.v4"
    fi
    read -r -p "$(get_text "apply_rules_question")" -e -i "y" OPTION
    if [ "$OPTION" == "y" ] || [ "$OPTION" == "Y" ]; then
      if [[ $distro =~ "CentOS" ]]; then
        firewall-cmd --zone=public --add-port="$PORT"/tcp
        firewall-cmd --runtime-to-permanent
      elif [[ $distro =~ "Ubuntu" ]]; then
        ufw allow "$PORT"/tcp
      elif [[ $distro =~ "Debian" ]]; then
        iptables -A INPUT -p tcp --dport "$PORT" --jump ACCEPT
        iptables-save >/etc/iptables/rules.v4
      fi
    fi
    ;;
  9)
    read -r -p "$(get_text "uninstall_question")" OPTION
    case $OPTION in
    "y" | "Y")
      cd /opt/MTProxy || exit 2
      systemctl stop MTProxy
      systemctl disable MTProxy
      if [[ $distro =~ "CentOS" ]]; then
        firewall-cmd --remove-port="$PORT"/tcp
        firewall-cmd --runtime-to-permanent
      elif [[ $distro =~ "Ubuntu" ]]; then
        ufw delete allow "$PORT"/tcp
      elif [[ $distro =~ "Debian" ]]; then
        iptables -D INPUT -p tcp --dport "$PORT" --jump ACCEPT
        iptables-save >/etc/iptables/rules.v4
      fi
      rm -rf /opt/MTProxy /etc/systemd/system/MTProxy.service
      systemctl daemon-reload
      sed -i '\|cd /opt/MTProxy && bash updater.sh|d' /etc/crontab
      if [[ $distro =~ "CentOS" ]]; then
        systemctl restart crond
      elif [[ $distro =~ "Ubuntu" ]] || [[ $distro =~ "Debian" ]]; then
        systemctl restart cron
      fi
      get_text "uninstall_completed"
      ;;
    esac
    ;;
  10)
    get_text "script_info"
    get_text "mtproxy_source"
    get_text "telegram_official"
    ;;
  *)
    exit 0
    ;;
  esac
  exit
fi

# Installation logic
SECRET_ARY=()
if [ "$#" -ge 2 ]; then
  AUTO=true
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      -s|--secret) SECRET_ARY+=("$2"); shift ;;
      -p|--port) PORT=$2; shift ;;
      -t|--tag) TAG=$2; shift ;;
      --workers) CPU_CORES=$2; shift ;;
      --disable-updater) ENABLE_UPDATER="n" ;;
      --tls) TLS_DOMAIN="$2"; shift ;;
      --custom-args) CUSTOM_ARGS="$2"; shift ;;
      --no-nat) HAVE_NAT="n" ;;
      --no-bbr) ENABLE_BBR="n" ;;
    esac
    shift
  done
  if [[ ${#SECRET_ARY[@]} -eq 0 ]]; then
    get_text "error_no_secret"
    exit 1
  fi
  for i in "${SECRET_ARY[@]}"; do
    if ! [[ $i =~ ^[0-9a-f]{32}$ ]]; then
      echo "$(get_text "error_invalid_secret" | sed "s/\\\$SECRET/$i/")"
      exit 1
    fi
  done
  if [ -z "${PORT+x}" ]; then
    GetRandomPort
    echo "$(get_text "port_auto_selected" | sed "s/\\\$PORT/$PORT/")"
  fi
  if ! [[ $PORT =~ $regex ]]; then
    get_text "error_invalid_port"
    exit 1
  fi
  if [ "$PORT" -gt 65535 ]; then
    get_text "error_port_range"
    exit 1
  fi
  if [[ "$HAVE_NAT" != "n" ]]; then
    PRIVATE_IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
    PUBLIC_IP=$(curl -s https://api.ipify.org || wget -qO- http://ipecho.net/plain)
    HAVE_NAT="n"
    if echo "$PRIVATE_IP" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
      HAVE_NAT="y"
    fi
  fi
  if [ -z "${CPU_CORES+x}" ]; then CPU_CORES=$(nproc --all); fi
  if [ -z "${ENABLE_UPDATER+x}" ]; then ENABLE_UPDATER="y"; fi
  if [ -z "${TLS_DOMAIN+x}" ]; then TLS_DOMAIN="www.cloudflare.com"; fi
  if [ -z "${ENABLE_BBR+x}" ]; then ENABLE_BBR="y"; fi
else
  get_text "welcome_message"
  get_text "using_mtproxy"
  get_text "gathering_info"
  echo ""
  read -r -p "$(get_text "choose_port")" -e -i "443" PORT
  if [[ $PORT -eq -1 ]]; then
    GetRandomPort
    echo "$(get_text "port_selected" | sed "s/\\\$PORT/$PORT/")"
  fi
  if ! [[ $PORT =~ $regex ]]; then
    get_text "error_invalid_port"
    exit 1
  fi
  if [ "$PORT" -gt 65535 ]; then
    get_text "error_port_range"
    exit 1
  fi
  while true; do
    get_text "secret_manual_or_random"
    get_text "secret_manual"
    get_text "secret_random"
    read -r -p "$(get_text "choose_1_2")" -e -i 2 OPTION
    case $OPTION in
    1)
      get_text "enter_hex_secret"
      read -r SECRET
      SECRET=$(echo "$SECRET" | tr '[A-Z]' '[a-z]')
      if ! [[ $SECRET =~ ^[0-9a-f]{32}$ ]]; then
        get_text "error_invalid_hex"
        exit 1
      fi
      ;;
    2)
      SECRET=$(hexdump -vn "16" -e ' /1 "%02x"' /dev/urandom)
      echo "$(get_text "secret_generated" | sed "s/\\\$SECRET/$SECRET/")"
      ;;
    *)
      get_text "invalid_option"
      exit 1
      ;;
    esac
    SECRET_ARY+=("$SECRET")
    read -r -p "$(get_text "want_add_more_secret")" -e -i "n" OPTION
    case $OPTION in
    'y' | "Y")
      if [ "${#SECRET_ARY[@]}" -ge 16 ]; then
        get_text "error_max_secrets"
        break
      fi
      ;;
    'n' | "N")
      break
      ;;
    *)
      get_text "invalid_option"
      exit 1
      ;;
    esac
  done
  read -r -p "$(get_text "want_setup_tag")" -e -i "n" OPTION
  if [[ "$OPTION" == "y" || "$OPTION" == "Y" ]]; then
    get_text "tag_note"
    echo "$(get_text "tag_instructions" | sed "s/\\\$PORT/$PORT/" | sed "s/\\\$SECRET/$SECRET/")"
    get_text "tag_bot_response"
    read -r TAG
  fi
  CPU_CORES=$(nproc --all)
  echo "$(get_text "cpu_cores_detected" | sed "s/\\\$CPU_CORES/$CPU_CORES/g")"
  read -r -p "$(get_text "how_many_workers")" -e -i "$CPU_CORES" CPU_CORES
  if ! [[ $CPU_CORES =~ $regex ]]; then
    get_text "error_invalid_number"
    exit 1
  fi
  if [ "$CPU_CORES" -lt 1 ]; then
    get_text "error_enter_greater_1"
    exit 1
  fi
  if [ "$CPU_CORES" -gt 16 ]; then
    get_text "warning_over_16"
  fi
  read -r -p "$(get_text "want_auto_update")" -e -i "y" ENABLE_UPDATER
  read -r -p "$(get_text "choose_tls_domain")" -e -i "www.cloudflare.com" TLS_DOMAIN
  IP=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1)
  HAVE_NAT="n"
  if echo "$IP" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
    HAVE_NAT="y"
  fi
  read -r -p "$(get_text "nat_question")" -e -i "$HAVE_NAT" HAVE_NAT
  if [[ "$HAVE_NAT" == "y" || "$HAVE_NAT" == "Y" ]]; then
    PUBLIC_IP=$(curl -s https://api.ipify.org || wget -qO- http://ipecho.net/plain)
    read -r -p "$(get_text "enter_public_ip")" -e -i "$PUBLIC_IP" PUBLIC_IP
    if echo "$IP" | grep -qE '^(10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|192\.168)'; then
      echo "$(get_text "detected_private_ip" | sed "s/\\\$IP/$IP/")"
    else
      IP=""
    fi
    read -r -p "$(get_text "enter_private_ip")" -e -i "$IP" PRIVATE_IP
  fi
  get_text "want_custom_params"
  read -r CUSTOM_ARGS
  # Ask about BBR / Hỏi về BBR
  if [ "$(sysctl -n net.ipv4.tcp_congestion_control)" != "bbr" ]; then
    if [ "$AUTO" != true ]; then
      echo
      read -r -p "$(get_text "want_bbr")" -e -i "y" ENABLE_BBR
    fi
  else
    get_text "bbr_already_enabled"
    ENABLE_BBR="n"
  fi
  read -n 1 -s -r -p "$(get_text "press_any_key")"
  clear
fi

# Install packages
if [[ $distro =~ "CentOS" ]]; then
  yum -y install epel-release
  yum -y install openssl-devel zlib-devel curl ca-certificates sed cronie vim-common
  yum -y groupinstall "Development Tools"
elif [[ $distro =~ "Ubuntu" ]] || [[ $distro =~ "Debian" ]]; then
  apt-get update
  apt-get -y install git curl build-essential libssl-dev zlib1g-dev sed cron ca-certificates vim-common
fi
timedatectl set-ntp on

# Download and compile
cd /opt || exit 2
git clone https://github.com/GetPageSpeed/MTProxy.git
cd MTProxy || exit 2

# ----- BEGIN PATCH: declare prototype để tránh implicit declaration -----
# chèn dòng extern vào đầu file engine/engine.c
sed -i '1iextern int do_reload_config(int mode);' engine/engine.c
# ----- END PATCH -----

# Giữ nguyên các sửa flags nếu cần
sed -i 's/CFLAGS=/CFLAGS=-fcommon -Wno-implicit-function-declaration /' Makefile
sed -i 's/LDFLAGS=/LDFLAGS=-fcommon /' Makefile

# Build
make

BUILD_STATUS=$?
if [ $BUILD_STATUS -ne 0 ]; then
  echo "$(get_text "error_build_failed" | sed "s/\\\$BUILD_STATUS/$BUILD_STATUS/")"
  get_text "removing_project_files"
  rm -rf /opt/MTProxy
  get_text "completed"
  exit 3
fi
mkdir -p /opt/MTProxy
cp objs/bin/mtproto-proxy /opt/MTProxy/
cd /opt/MTProxy || exit 2
curl -s https://core.telegram.org/getProxySecret -o proxy-secret
STATUS_SECRET=$?
if [ $STATUS_SECRET -ne 0 ]; then
  get_text "error_proxy_secret"
  exit 1
fi
curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf
STATUS_CONF=$?
if [ $STATUS_CONF -ne 0 ]; then
  get_text "error_proxy_config"
  exit 1
fi

# Setup mtconfig.conf
get_text "setup_mtconfig"
echo "PORT=$PORT" >mtconfig.conf
echo "CPU_CORES=$CPU_CORES" >>mtconfig.conf
echo "SECRET_ARY=(${SECRET_ARY[*]})" >>mtconfig.conf
echo "TAG=\"$TAG\"" >>mtconfig.conf
echo "CUSTOM_ARGS=\"$CUSTOM_ARGS\"" >>mtconfig.conf
echo "TLS_DOMAIN=\"$TLS_DOMAIN\"" >>mtconfig.conf
echo "HAVE_NAT=\"$HAVE_NAT\"" >>mtconfig.conf
echo "PUBLIC_IP=\"$PUBLIC_IP\"" >>mtconfig.conf
echo "PRIVATE_IP=\"$PRIVATE_IP\"" >>mtconfig.conf

# Setup firewall
get_text "setting_firewall"
if [[ $distro =~ "CentOS" ]]; then
  SETFIREWALL=true
  if ! yum -q list installed firewalld &>/dev/null; then
    echo ""
    if [ "$AUTO" = true ]; then
      OPTION="y"
    else
      read -r -p "$(get_text "firewalld_not_installed")" -e -i "y" OPTION
    fi
    case $OPTION in
    "y" | "Y")
      yum -y install firewalld
      systemctl enable firewalld
      ;;
    *)
      SETFIREWALL=false
      ;;
    esac
  fi
  if [ "$SETFIREWALL" = true ]; then
    systemctl start firewalld
    firewall-cmd --zone=public --add-port="$PORT"/tcp
    firewall-cmd --runtime-to-permanent
  fi
elif [[ $distro =~ "Ubuntu" ]]; then
  if dpkg --get-selections | grep -q "^ufw[[:space:]]*install$" >/dev/null; then
    ufw allow "$PORT"/tcp
  else
    if [ "$AUTO" = true ]; then
      OPTION="y"
    else
      echo
      read -r -p "$(get_text "ufw_not_installed")" -e -i "y" OPTION
    fi
    case $OPTION in
    "y" | "Y")
      apt-get install ufw
      ufw enable
      ufw allow ssh
      ufw allow "$PORT"/tcp
      ;;
    esac
  fi
elif [[ $distro =~ "Debian" ]]; then
  apt-get install -y iptables iptables-persistent
  iptables -A INPUT -p tcp --dport "$PORT" --jump ACCEPT
  iptables-save >/etc/iptables/rules.v4
fi

# Enable BBR if user selected
if [ "$ENABLE_BBR" == "y" ] || [ "$ENABLE_BBR" == "Y" ]; then
  enable_bbr
fi

# Setup service file
cd /etc/systemd/system || exit 2
GenerateService
echo "$SERVICE_STR" >MTProxy.service
systemctl daemon-reload
systemctl start MTProxy
systemctl is-active --quiet MTProxy
SERVICE_STATUS=$?
if [ $SERVICE_STATUS -ne 0 ]; then
  get_text "compile_warning"
  get_text "check_status"
  exit 1
fi
systemctl enable MTProxy

# Setup cronjob
if [ "$ENABLE_UPDATER" = "y" ] || [ "$ENABLE_UPDATER" == "Y" ]; then
  # Get the localized log message
  LOG_MESSAGE=$(get_text "updater_log_message" | sed "s/\\\$STATUS_SECRET/\$STATUS_SECRET/g" | sed "s/\\\$STATUS_CONF/\$STATUS_CONF/g")

  cat > /opt/MTProxy/updater.sh << EOF
#!/bin/bash
systemctl stop MTProxy
cd /opt/MTProxy
curl -s https://core.telegram.org/getProxySecret -o proxy-secret1
STATUS_SECRET=\$?
if [ \$STATUS_SECRET -eq 0 ]; then
  cp proxy-secret1 proxy-secret
fi
rm proxy-secret1
curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf1
STATUS_CONF=\$?
if [ \$STATUS_CONF -eq 0 ]; then
  cp proxy-multi.conf1 proxy-multi.conf
fi
rm proxy-multi.conf1
systemctl start MTProxy
echo "$LOG_MESSAGE" >> updater.log
EOF
  chmod +x /opt/MTProxy/updater.sh
  echo "" >>/etc/crontab
  echo "0 0 * * * root cd /opt/MTProxy && bash updater.sh" >>/etc/crontab
  if [[ $distro =~ "CentOS" ]]; then
    systemctl restart crond
  elif [[ $distro =~ "Ubuntu" ]] || [[ $distro =~ "Debian" ]]; then
    systemctl restart cron
  fi
fi

# Display proxy links
tput setaf 3
printf "%$(tput cols)s" | tr ' ' '#'
tput sgr 0
get_text "proxy_links_header"
PUBLIC_IP=$(curl -s https://api.ipify.org || wget -qO- http://ipecho.net/plain)
CURL_EXIT_STATUS=$?
if [ $CURL_EXIT_STATUS -ne 0 ]; then
  PUBLIC_IP="YOUR_IP"
  get_text "cannot_get_ip"
fi
HEX_DOMAIN=$(printf "%s" "$TLS_DOMAIN" | xxd -pu)
HEX_DOMAIN=$(echo "$HEX_DOMAIN" | tr '[A-Z]' '[a-z]')
for i in "${SECRET_ARY[@]}"; do
  if [ -z "$TLS_DOMAIN" ]; then
    echo "tg://proxy?server=$PUBLIC_IP&port=$PORT&secret=dd$i"
  else
    echo "tg://proxy?server=$PUBLIC_IP&port=$PORT&secret=ee$i$HEX_DOMAIN"
  fi
done
get_text "register_with_bot"
get_text "check_stats"
