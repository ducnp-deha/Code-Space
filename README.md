# Code-Space

## Hướng dẫn cài đặt môi trường phát triển trên Ubuntu

Tài liệu này hướng dẫn cài đặt và cấu hình môi trường phát triển PHP với MySQL và Cloudflare Tunnel trên Ubuntu.

## 🚀 Cài đặt nhanh với Script

Chúng tôi đã tạo sẵn một script tự động với giao diện menu đẹp để cài đặt môi trường một cách dễ dàng:

```bash
# Chạy script cài đặt
./start.sh

# Hoặc chạy trực tiếp
./install-environment.sh
```

**Tính năng của script:**
- ✅ Menu tương tác đẹp mắt với màu sắc
- ✅ Cài đặt từng thành phần riêng lẻ hoặc tất cả
- ✅ Kiểm tra hệ thống và trạng thái dịch vụ
- ✅ Tạo project PHP mẫu
- ✅ Cấu hình Firewall tự động
- ✅ Hỗ trợ cả Apache và Nginx
- ✅ Cấu hình Cloudflare Tunnel
- ✅ Tạo database và user MySQL mẫu

## Mục lục

1. [Cài đặt nhanh với Script](#-cài-đặt-nhanh-với-script)
2. [Cài đặt PHP](#cài-đặt-php)
3. [Cài đặt MySQL](#cài-đặt-mysql)
4. [Cài đặt Cloudflare Tunnel](#cài-đặt-cloudflare-tunnel)
5. [Cấu hình và kiểm tra](#cấu-hình-và-kiểm-tra)

## Cài đặt PHP

### 1. Cập nhật hệ thống

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Cài đặt PHP và các extension cần thiết

```bash
# Cài đặt PHP và các module phổ biến
sudo apt install -y php php-cli php-fpm php-mysql php-xml php-curl php-gd php-mbstring php-zip php-intl php-bcmath php-json

# Kiểm tra phiên bản PHP đã cài
php --version
```

### 3. Cài đặt Composer (PHP package manager)

```bash
# Tải Composer
curl -sS https://getcomposer.org/installer | php

# Di chuyển vào thư mục bin để sử dụng globally
sudo mv composer.phar /usr/local/bin/composer

# Kiểm tra cài đặt
composer --version
```

### 4. Cài đặt Apache hoặc Nginx (tùy chọn)

#### Cài đặt Apache:
```bash
sudo apt install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2

# Cài đặt module PHP cho Apache
sudo apt install -y libapache2-mod-php
sudo systemctl restart apache2
```

#### Hoặc cài đặt Nginx:
```bash
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

## Cài đặt MySQL

### 1. Cài đặt MySQL Server

```bash
sudo apt install -y mysql-server
```

### 2. Chạy script bảo mật MySQL

```bash
sudo mysql_secure_installation
```

Trong quá trình cấu hình, bạn sẽ được hỏi:
- Thiết lập mật khẩu root
- Xóa người dùng ẩn danh
- Tắt đăng nhập root từ xa
- Xóa database test
- Reload bảng quyền

### 3. Khởi động và kích hoạt MySQL

```bash
sudo systemctl enable mysql
sudo systemctl start mysql
sudo systemctl status mysql
```

### 4. Tạo database và user mới

```bash
# Đăng nhập MySQL với quyền root
sudo mysql -u root -p

# Tạo database mới
CREATE DATABASE your_database_name;

# Tạo user mới và cấp quyền
CREATE USER 'your_username'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON your_database_name.* TO 'your_username'@'localhost';
FLUSH PRIVILEGES;

# Thoát MySQL
EXIT;
```

## Cài đặt Cloudflare Tunnel

### 1. Tải và cài đặt cloudflared

```bash
# Tải cloudflared
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb

# Cài đặt package
sudo dpkg -i cloudflared-linux-amd64.deb

# Kiểm tra cài đặt
cloudflared --version
```

### 2. Đăng nhập vào Cloudflare

```bash
cloudflared tunnel login
```

Lệnh này sẽ mở trình duyệt để bạn đăng nhập vào tài khoản Cloudflare và xác thực.

### 3. Tạo tunnel mới

```bash
# Tạo tunnel với tên của bạn
cloudflared tunnel create your-tunnel-name

# Liệt kê các tunnel đã tạo
cloudflared tunnel list
```

### 4. Cấu hình tunnel

Tạo file cấu hình `~/.cloudflared/config.yml`:

```yaml
tunnel: your-tunnel-id
credentials-file: /home/your-username/.cloudflared/your-tunnel-id.json

ingress:
  - hostname: your-domain.com
    service: http://localhost:80
  - hostname: api.your-domain.com
    service: http://localhost:8080
  - service: http_status:404
```

### 5. Tạo DNS record

```bash
# Tạo CNAME record trỏ domain về tunnel
cloudflared tunnel route dns your-tunnel-name your-domain.com
```

### 6. Chạy tunnel

```bash
# Chạy tunnel
cloudflared tunnel run your-tunnel-name

# Hoặc chạy như service
cloudflared tunnel install your-tunnel-name
sudo systemctl start cloudflared
sudo systemctl enable cloudflared
```

## Cấu hình và kiểm tra

### 1. Kiểm tra PHP

Tạo file test PHP:

```bash
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php
```

Truy cập `http://localhost/info.php` để kiểm tra thông tin PHP.

### 2. Kiểm tra MySQL

```bash
# Kiểm tra kết nối MySQL
mysql -u your_username -p -e "SHOW DATABASES;"
```

### 3. Kiểm tra Cloudflare Tunnel

```bash
# Kiểm tra trạng thái tunnel
cloudflared tunnel info your-tunnel-name

# Kiểm tra logs
sudo journalctl -u cloudflared -f
```

### 4. Test kết nối PHP-MySQL

Tạo file test kết nối:

```php
<?php
$servername = "localhost";
$username = "your_username";
$password = "your_password";
$dbname = "your_database_name";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Kết nối thành công!";
} catch(PDOException $e) {
    echo "Kết nối thất bại: " . $e->getMessage();
}
?>
```

## Các lệnh hữu ích

### PHP
```bash
# Khởi động lại PHP-FPM
sudo systemctl restart php8.1-fpm

# Kiểm tra cấu hình PHP
php -m  # Liệt kê modules
php -i  # Thông tin PHP
```

### MySQL
```bash
# Khởi động lại MySQL
sudo systemctl restart mysql

# Backup database
mysqldump -u username -p database_name > backup.sql

# Restore database
mysql -u username -p database_name < backup.sql
```

### Cloudflare Tunnel
```bash
# Dừng tunnel
sudo systemctl stop cloudflared

# Xem logs
sudo journalctl -u cloudflared

# Cập nhật cấu hình
cloudflared tunnel ingress validate
```

## Lưu ý

- Thay thế `your_username`, `your_password`, `your_database_name`, `your-tunnel-name`, và `your-domain.com` bằng giá trị thực tế của bạn
- Đảm bảo firewall cho phép kết nối đến các port cần thiết
- Thường xuyên cập nhật hệ thống và các package để đảm bảo bảo mật
- Backup dữ liệu thường xuyên

## Khắc phục sự cố

### Lỗi PHP
- Kiểm tra logs: `sudo tail -f /var/log/apache2/error.log`
- Kiểm tra cấu hình: `php --ini`

### Lỗi MySQL
- Kiểm tra logs: `sudo tail -f /var/log/mysql/error.log`
- Kiểm tra trạng thái: `sudo systemctl status mysql`

### Lỗi Cloudflare Tunnel
- Kiểm tra logs: `cloudflared tunnel info your-tunnel-name`
- Validate cấu hình: `cloudflared tunnel ingress validate`

## 📁 Cấu trúc project

```
Code-Space/
├── README.md                    # Tài liệu hướng dẫn
├── install-environment.sh       # Script cài đặt môi trường chính
└── start.sh                    # Script khởi chạy nhanh
```

## 🎯 Các file script

### `install-environment.sh`
Script chính với đầy đủ tính năng:
- Menu tương tác màu sắc đẹp mắt
- Cài đặt từng thành phần hoặc tất cả
- Kiểm tra và cấu hình hệ thống
- Tạo project mẫu

### `start.sh`
Script khởi chạy nhanh:
- Kiểm tra file script tồn tại
- Tự động cấp quyền thực thi
- Khởi chạy script chính

## 🔧 Hướng dẫn sử dụng Script

1. **Cấp quyền thực thi** (nếu cần):
   ```bash
   chmod +x install-environment.sh
   chmod +x start.sh
   ```

2. **Chạy script**:
   ```bash
   # Cách 1: Sử dụng script khởi chạy nhanh
   ./start.sh
   
   # Cách 2: Chạy trực tiếp script chính
   ./install-environment.sh
   ```

3. **Sử dụng menu**:
   - Chọn `1` để cài đặt tất cả (khuyến nghị cho lần đầu)
   - Chọn `7` để kiểm tra hệ thống
   - Chọn `8` để tạo project PHP mẫu
   - Chọn `0` để thoát

## 📸 Screenshot Menu

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║          🚀 SCRIPT CÀI ĐẶT MÔI TRƯỜNG PHÁT TRIỂN 🚀          ║
║                                                              ║
║              PHP + MySQL + Cloudflare Tunnel                ║
║                        Ubuntu 20.04+                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────┐
│                      MENU CHÍNH                             │
├─────────────────────────────────────────────────────────────┤
│  1. ✓ Cài đặt tất cả (Khuyến nghị)                     │
│  2. → Cài đặt PHP + Extensions                         │
│  3. → Cài đặt MySQL Server                            │
│  4. → Cài đặt Apache Web Server                       │
│  5. → Cài đặt Nginx Web Server                        │
│  6. → Cài đặt Cloudflare Tunnel                       │
│  7. ★ Kiểm tra hệ thống                              │
│  8. → Tạo project PHP mẫu                             │
│  9. → Cấu hình Firewall                               │
│  0. ✗ Thoát                                            │
└─────────────────────────────────────────────────────────────┘
```

## ⚡ Tính năng nổi bật của Script

- **🎨 Giao diện đẹp**: Menu màu sắc, biểu tượng sinh động
- **🔧 Cài đặt thông minh**: Kiểm tra thành phần đã cài, tránh cài trùng
- **📊 Theo dõi tiến trình**: Progress bar và thông báo chi tiết
- **🛡️ Bảo mật**: Cấu hình firewall và MySQL security
- **🌐 Linh hoạt**: Chọn Apache hoặc Nginx
- **☁️ Cloud ready**: Tích hợp Cloudflare Tunnel
- **📁 Project mẫu**: Tạo sẵn project PHP demo với database test