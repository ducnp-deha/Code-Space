#!/bin/bash

# Quick start script
# Chạy script này để bắt đầu cài đặt môi trường

echo "🚀 Khởi chạy script cài đặt môi trường..."
echo "📍 Đường dẫn: $(pwd)"
echo ""

# Kiểm tra file script tồn tại
if [ ! -f "./install-environment.sh" ]; then
    echo "❌ Không tìm thấy file install-environment.sh"
    echo "📂 Hãy đảm bảo bạn đang ở thư mục chứa script"
    exit 1
fi

# Kiểm tra quyền thực thi
if [ ! -x "./install-environment.sh" ]; then
    echo "🔧 Cấp quyền thực thi cho script..."
    chmod +x ./install-environment.sh
fi

# Chạy script chính
./install-environment.sh
