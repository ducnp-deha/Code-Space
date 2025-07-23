#!/bin/bash

# Script cài đặt môi trường PHP, MySQL, Cloudflare Tunnel trên Ubuntu
# Author: Code-Space
# Version: 1.0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Symbols
CHECK="✓"
CROSS="✗"
ARROW="→"
STAR="★"

# Function to print colored output
print_color() {
    printf "${1}${2}${NC}\n"
}

# Function to print header
print_header() {
    clear
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║          🚀 SCRIPT CÀI ĐẶT MÔI TRƯỜNG PHÁT TRIỂN 🚀          ║"
    echo "║                                                              ║"
    echo "║              PHP + MySQL + Cloudflare Tunnel                ║"
    echo "║                        Ubuntu 20.04+                        ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
}

# Function to print menu
print_menu() {
    print_color $CYAN "┌─────────────────────────────────────────────────────────────┐"
    print_color $CYAN "│                      MENU CHÍNH                             │"
    print_color $CYAN "├─────────────────────────────────────────────────────────────┤"
    print_color $WHITE "│  1. ${GREEN}${CHECK}${WHITE} Cài đặt tất cả (Khuyến nghị)                     │"
    print_color $WHITE "│  2. ${YELLOW}${ARROW}${WHITE} Cài đặt PHP + Extensions                         │"
    print_color $WHITE "│  3. ${YELLOW}${ARROW}${WHITE} Cài đặt MySQL Server                            │"
    print_color $WHITE "│  4. ${YELLOW}${ARROW}${WHITE} Cài đặt Apache Web Server                       │"
    print_color $WHITE "│  5. ${YELLOW}${ARROW}${WHITE} Cài đặt Nginx Web Server                        │"
    print_color $WHITE "│  6. ${YELLOW}${ARROW}${WHITE} Cài đặt Cloudflare Tunnel                       │"
    print_color $WHITE "│  7. ${BLUE}${STAR}${WHITE} Kiểm tra hệ thống                              │"
    print_color $WHITE "│  8. ${PURPLE}${ARROW}${WHITE} Tạo project PHP mẫu                             │"
    print_color $WHITE "│  9. ${CYAN}${ARROW}${WHITE} Cấu hình Firewall                               │"
    print_color $WHITE "│  0. ${RED}${CROSS}${WHITE} Thoát                                            │"
    print_color $CYAN "└─────────────────────────────────────────────────────────────┘"
    echo ""
}

# Function to show progress
show_progress() {
    local duration=$1
    local message=$2
    
    echo -ne "${YELLOW}${message}${NC}"
    for ((i=0; i<=duration; i++)); do
        echo -ne "."
        sleep 0.1
    done
    echo -e " ${GREEN}${CHECK}${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to update system
update_system() {
    print_color $BLUE "📦 Cập nhật hệ thống..."
    sudo apt update -y >/dev/null 2>&1
    sudo apt upgrade -y >/dev/null 2>&1
    print_color $GREEN "${CHECK} Cập nhật hệ thống hoàn tất!"
}

# Function to install PHP
install_php() {
    print_color $BLUE "🐘 Cài đặt PHP và extensions..."
    
    if command_exists php; then
        print_color $YELLOW "${CHECK} PHP đã được cài đặt: $(php --version | head -n 1)"
        return
    fi
    
    show_progress 20 "Đang cài đặt PHP"
    
    sudo apt install -y php php-cli php-fpm php-mysql php-xml php-curl \
                       php-gd php-mbstring php-zip php-intl php-bcmath \
                       php-json php-opcache php-readline >/dev/null 2>&1
    
    # Install Composer
    if ! command_exists composer; then
        print_color $BLUE "📦 Cài đặt Composer..."
        curl -sS https://getcomposer.org/installer | php >/dev/null 2>&1
        sudo mv composer.phar /usr/local/bin/composer
        sudo chmod +x /usr/local/bin/composer
    fi
    
    print_color $GREEN "${CHECK} PHP đã được cài đặt thành công!"
    print_color $CYAN "   ${ARROW} Phiên bản: $(php --version | head -n 1)"
    print_color $CYAN "   ${ARROW} Composer: $(composer --version 2>/dev/null || echo 'Chưa cài đặt')"
}

# Function to install MySQL
install_mysql() {
    print_color $BLUE "🗄️  Cài đặt MySQL Server..."
    
    if command_exists mysql; then
        print_color $YELLOW "${CHECK} MySQL đã được cài đặt"
        return
    fi
    
    show_progress 25 "Đang cài đặt MySQL"
    
    sudo apt install -y mysql-server >/dev/null 2>&1
    sudo systemctl enable mysql >/dev/null 2>&1
    sudo systemctl start mysql >/dev/null 2>&1
    
    print_color $GREEN "${CHECK} MySQL đã được cài đặt thành công!"
    print_color $YELLOW "⚠️  Hãy chạy 'sudo mysql_secure_installation' để bảo mật MySQL"
    
    # Tạo database và user mẫu
    read -p "Bạn có muốn tạo database và user mẫu không? (y/n): " create_db
    if [[ $create_db =~ ^[Yy]$ ]]; then
        create_sample_database
    fi
}

# Function to create sample database
create_sample_database() {
    print_color $BLUE "📊 Tạo database và user mẫu..."
    
    read -p "Tên database: " db_name
    read -p "Tên user: " db_user
    read -s -p "Mật khẩu user: " db_pass
    echo ""
    
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS $db_name;" 2>/dev/null
    mysql -u root -e "CREATE USER IF NOT EXISTS '$db_user'@'localhost' IDENTIFIED BY '$db_pass';" 2>/dev/null
    mysql -u root -e "GRANT ALL PRIVILEGES ON $db_name.* TO '$db_user'@'localhost';" 2>/dev/null
    mysql -u root -e "FLUSH PRIVILEGES;" 2>/dev/null
    
    print_color $GREEN "${CHECK} Database '$db_name' và user '$db_user' đã được tạo!"
}

# Function to install Apache
install_apache() {
    print_color $BLUE "🌐 Cài đặt Apache Web Server..."
    
    if command_exists apache2; then
        print_color $YELLOW "${CHECK} Apache đã được cài đặt"
        return
    fi
    
    show_progress 15 "Đang cài đặt Apache"
    
    sudo apt install -y apache2 libapache2-mod-php >/dev/null 2>&1
    sudo systemctl enable apache2 >/dev/null 2>&1
    sudo systemctl start apache2 >/dev/null 2>&1
    
    # Enable necessary modules
    sudo a2enmod rewrite >/dev/null 2>&1
    sudo systemctl restart apache2 >/dev/null 2>&1
    
    print_color $GREEN "${CHECK} Apache đã được cài đặt thành công!"
    print_color $CYAN "   ${ARROW} Truy cập: http://localhost"
    print_color $CYAN "   ${ARROW} Document root: /var/www/html"
}

# Function to install Nginx
install_nginx() {
    print_color $BLUE "🌐 Cài đặt Nginx Web Server..."
    
    if command_exists nginx; then
        print_color $YELLOW "${CHECK} Nginx đã được cài đặt"
        return
    fi
    
    show_progress 15 "Đang cài đặt Nginx"
    
    sudo apt install -y nginx >/dev/null 2>&1
    sudo systemctl enable nginx >/dev/null 2>&1
    sudo systemctl start nginx >/dev/null 2>&1
    
    print_color $GREEN "${CHECK} Nginx đã được cài đặt thành công!"
    print_color $CYAN "   ${ARROW} Truy cập: http://localhost"
    print_color $CYAN "   ${ARROW} Document root: /var/www/html"
}

# Function to install Cloudflare Tunnel
install_cloudflared() {
    print_color $BLUE "☁️  Cài đặt Cloudflare Tunnel..."
    
    if command_exists cloudflared; then
        print_color $YELLOW "${CHECK} Cloudflare Tunnel đã được cài đặt"
        return
    fi
    
    show_progress 20 "Đang tải Cloudflare Tunnel"
    
    # Download and install cloudflared
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb >/dev/null 2>&1
    rm cloudflared-linux-amd64.deb
    
    print_color $GREEN "${CHECK} Cloudflare Tunnel đã được cài đặt thành công!"
    print_color $YELLOW "⚠️  Hãy chạy 'cloudflared tunnel login' để đăng nhập"
    
    # Hỏi có muốn cấu hình tunnel không
    read -p "Bạn có muốn cấu hình tunnel ngay bây giờ không? (y/n): " config_tunnel
    if [[ $config_tunnel =~ ^[Yy]$ ]]; then
        configure_cloudflare_tunnel
    fi
}

# Function to configure Cloudflare tunnel
configure_cloudflare_tunnel() {
    print_color $BLUE "⚙️  Cấu hình Cloudflare Tunnel..."
    
    read -p "Tên tunnel: " tunnel_name
    read -p "Domain của bạn: " domain_name
    
    # Login to Cloudflare
    print_color $YELLOW "Đăng nhập vào Cloudflare (sẽ mở trình duyệt)..."
    cloudflared tunnel login
    
    # Create tunnel
    cloudflared tunnel create $tunnel_name
    
    # Get tunnel ID
    tunnel_id=$(cloudflared tunnel list | grep $tunnel_name | awk '{print $1}')
    
    # Create config file
    mkdir -p ~/.cloudflared
    cat > ~/.cloudflared/config.yml << EOF
tunnel: $tunnel_id
credentials-file: /home/$USER/.cloudflared/$tunnel_id.json

ingress:
  - hostname: $domain_name
    service: http://localhost:80
  - service: http_status:404
EOF
    
    # Create DNS record
    cloudflared tunnel route dns $tunnel_name $domain_name
    
    print_color $GREEN "${CHECK} Tunnel '$tunnel_name' đã được cấu hình!"
    print_color $CYAN "   ${ARROW} Chạy tunnel: cloudflared tunnel run $tunnel_name"
}

# Function to check system
check_system() {
    print_header
    print_color $BLUE "🔍 KIỂM TRA HỆ THỐNG"
    echo ""
    
    # Check OS
    print_color $CYAN "📋 Thông tin hệ thống:"
    print_color $WHITE "   ${ARROW} OS: $(lsb_release -d | cut -f2)"
    print_color $WHITE "   ${ARROW} Kernel: $(uname -r)"
    print_color $WHITE "   ${ARROW} Architecture: $(uname -m)"
    echo ""
    
    # Check installed components
    print_color $CYAN "📦 Trạng thái các thành phần:"
    
    if command_exists php; then
        print_color $GREEN "   ${CHECK} PHP: $(php --version | head -n 1 | awk '{print $2}')"
    else
        print_color $RED "   ${CROSS} PHP: Chưa cài đặt"
    fi
    
    if command_exists mysql; then
        print_color $GREEN "   ${CHECK} MySQL: $(mysql --version | awk '{print $3}' | cut -d',' -f1)"
    else
        print_color $RED "   ${CROSS} MySQL: Chưa cài đặt"
    fi
    
    if command_exists apache2; then
        print_color $GREEN "   ${CHECK} Apache: $(apache2 -v | head -n 1 | awk '{print $3}' | cut -d'/' -f2)"
    elif command_exists nginx; then
        print_color $GREEN "   ${CHECK} Nginx: $(nginx -v 2>&1 | awk '{print $3}' | cut -d'/' -f2)"
    else
        print_color $RED "   ${CROSS} Web Server: Chưa cài đặt"
    fi
    
    if command_exists composer; then
        print_color $GREEN "   ${CHECK} Composer: $(composer --version 2>/dev/null | awk '{print $3}')"
    else
        print_color $RED "   ${CROSS} Composer: Chưa cài đặt"
    fi
    
    if command_exists cloudflared; then
        print_color $GREEN "   ${CHECK} Cloudflare Tunnel: $(cloudflared --version | awk '{print $3}')"
    else
        print_color $RED "   ${CROSS} Cloudflare Tunnel: Chưa cài đặt"
    fi
    
    echo ""
    
    # Check services
    print_color $CYAN "🔧 Trạng thái dịch vụ:"
    
    if systemctl is-active --quiet mysql; then
        print_color $GREEN "   ${CHECK} MySQL: Đang chạy"
    else
        print_color $RED "   ${CROSS} MySQL: Không chạy"
    fi
    
    if systemctl is-active --quiet apache2; then
        print_color $GREEN "   ${CHECK} Apache: Đang chạy"
    elif systemctl is-active --quiet nginx; then
        print_color $GREEN "   ${CHECK} Nginx: Đang chạy"
    else
        print_color $RED "   ${CROSS} Web Server: Không chạy"
    fi
    
    echo ""
    read -p "Nhấn Enter để tiếp tục..."
}

# Function to create sample project
create_sample_project() {
    print_color $BLUE "📁 Tạo project PHP mẫu..."
    
    read -p "Tên project: " project_name
    project_path="/var/www/html/$project_name"
    
    sudo mkdir -p $project_path
    
    # Create index.php
    sudo tee $project_path/index.php > /dev/null << 'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to PHP Project</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f4f4f4; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; }
        .info { background: #e8f4fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .success { background: #d4edda; color: #155724; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 PHP Project đã hoạt động!</h1>
        
        <div class="success">
            <strong>Chúc mừng!</strong> Môi trường PHP của bạn đã được cài đặt thành công.
        </div>
        
        <div class="info">
            <h3>📊 Thông tin hệ thống:</h3>
            <p><strong>PHP Version:</strong> <?php echo PHP_VERSION; ?></p>
            <p><strong>Server:</strong> <?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'Unknown'; ?></p>
            <p><strong>Document Root:</strong> <?php echo $_SERVER['DOCUMENT_ROOT']; ?></p>
            <p><strong>Current Time:</strong> <?php echo date('Y-m-d H:i:s'); ?></p>
        </div>
        
        <div class="info">
            <h3>🔗 Liên kết hữu ích:</h3>
            <ul>
                <li><a href="phpinfo.php">PHP Info</a></li>
                <li><a href="test-mysql.php">Test MySQL Connection</a></li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF

    # Create phpinfo.php
    sudo tee $project_path/phpinfo.php > /dev/null << 'EOF'
<?php
phpinfo();
?>
EOF

    # Create MySQL test file
    sudo tee $project_path/test-mysql.php > /dev/null << 'EOF'
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>MySQL Connection Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .success { color: green; }
        .error { color: red; }
    </style>
</head>
<body>
    <h1>MySQL Connection Test</h1>
    
    <?php
    $servername = "localhost";
    $username = "root";
    $password = "";
    
    try {
        $pdo = new PDO("mysql:host=$servername", $username, $password);
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        echo '<p class="success">✓ Kết nối MySQL thành công!</p>';
        
        // Show databases
        $stmt = $pdo->query("SHOW DATABASES");
        echo '<h3>Databases có sẵn:</h3><ul>';
        while ($row = $stmt->fetch()) {
            echo '<li>' . $row[0] . '</li>';
        }
        echo '</ul>';
        
    } catch(PDOException $e) {
        echo '<p class="error">✗ Kết nối thất bại: ' . $e->getMessage() . '</p>';
    }
    ?>
    
    <br>
    <a href="index.php">← Quay lại trang chủ</a>
</body>
</html>
EOF

    # Set permissions
    sudo chown -R www-data:www-data $project_path
    sudo chmod -R 755 $project_path
    
    print_color $GREEN "${CHECK} Project '$project_name' đã được tạo!"
    print_color $CYAN "   ${ARROW} Truy cập: http://localhost/$project_name"
}

# Function to configure firewall
configure_firewall() {
    print_color $BLUE "🔥 Cấu hình Firewall..."
    
    if ! command_exists ufw; then
        sudo apt install -y ufw >/dev/null 2>&1
    fi
    
    # Enable UFW
    sudo ufw --force enable >/dev/null 2>&1
    
    # Allow necessary ports
    sudo ufw allow 22 >/dev/null 2>&1    # SSH
    sudo ufw allow 80 >/dev/null 2>&1    # HTTP
    sudo ufw allow 443 >/dev/null 2>&1   # HTTPS
    sudo ufw allow 3306 >/dev/null 2>&1  # MySQL (only from localhost)
    
    print_color $GREEN "${CHECK} Firewall đã được cấu hình!"
    print_color $CYAN "   ${ARROW} Ports đã mở: 22 (SSH), 80 (HTTP), 443 (HTTPS), 3306 (MySQL)"
}

# Function to install all components
install_all() {
    print_color $PURPLE "🎯 BẮT ĐẦU CÀI ĐẶT TẤT CẢ THÀNH PHẦN..."
    echo ""
    
    update_system
    install_php
    install_mysql
    
    # Choose web server
    print_color $YELLOW "Chọn web server:"
    print_color $WHITE "1. Apache"
    print_color $WHITE "2. Nginx"
    read -p "Lựa chọn (1-2): " web_choice
    
    case $web_choice in
        1) install_apache ;;
        2) install_nginx ;;
        *) install_apache ;;
    esac
    
    install_cloudflared
    configure_firewall
    create_sample_project
    
    print_color $GREEN "🎉 CÀI ĐẶT HOÀN TẤT!"
    print_color $CYAN "Hệ thống đã sẵn sàng để phát triển!"
}

# Main function
main() {
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        print_color $RED "❌ Không nên chạy script này với quyền root!"
        print_color $YELLOW "Hãy chạy: bash $0"
        exit 1
    fi
    
    # Check if Ubuntu
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_color $RED "❌ Script này chỉ hỗ trợ Ubuntu!"
        exit 1
    fi
    
    while true; do
        print_header
        print_menu
        
        read -p "$(print_color $YELLOW "Nhập lựa chọn của bạn: ")" choice
        echo ""
        
        case $choice in
            1)
                install_all
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            2)
                update_system
                install_php
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            3)
                update_system
                install_mysql
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            4)
                update_system
                install_apache
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            5)
                update_system
                install_nginx
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            6)
                update_system
                install_cloudflared
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            7)
                check_system
                ;;
            8)
                create_sample_project
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            9)
                configure_firewall
                read -p "Nhấn Enter để tiếp tục..."
                ;;
            0)
                print_color $GREEN "👋 Cảm ơn bạn đã sử dụng script!"
                exit 0
                ;;
            *)
                print_color $RED "❌ Lựa chọn không hợp lệ!"
                sleep 2
                ;;
        esac
    done
}

# Run main function
main "$@"
