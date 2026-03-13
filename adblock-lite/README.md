# 🛡️ Adblock-Lite: Hệ Thống Chặn DNS Nhẹ Và Hiệu Quả

Adblock-Lite là một giải pháp DNS blocking mạnh mẽ nhưng tiết kiệm tài nguyên, được thiết kế đặc biệt cho các thiết bị OpenWrt với bộ nhớ hạn chế. Hệ thống sử dụng danh sách chặn từ HaGeZi để ngăn chặn quảng cáo, malware, phishing và các nội dung không mong muốn trên toàn bộ mạng.

## 📋 Mục Lục

- [Tính Năng](#tính-năng)
- [Yêu Cầu](#yêu-cầu)
- [Cài Đặt](#cài-đặt)
- [Sử Dụng](#sử-dụng)
- [Cấu Hình Nâng Cao](#cấu-hình-nâng-cao)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

## ✨ Tính Năng

- **Chặn DNS toàn bộ mạng**: Bảo vệ tất cả thiết bị kết nối vào router
- **Tiết kiệm tài nguyên**: Sử dụng cache nhỏ (5000 entries) phù hợp với RAM thấp
- **Danh sách chặn cập nhật**: Sử dụng danh sách HaGeZi Pro Plus Mini (định dạng dnsmasq)
- **Whitelist/Blacklist tùy chỉnh**: Thêm hoặc loại trừ các domain riêng
- **Dễ bật/tắt**: Các script đơn giản để quản lý trạng thái
- **Khôi phục toàn bộ (Rollback)**: Hoàn nguyên trạng thái ban đầu nếu cần

## 🔧 Yêu Cầu

- **Router OpenWrt** (hoặc Linux với dnsmasq)
- **Quyền root** để chỉnh sửa cấu hình DNS
- **Kết nối Internet** để tải danh sách chặn (có thể dùng danh sách cũ nếu mất kết nối)
- **Dung lượng `/root`**: ~1-2MB cho danh sách + backup

## 📦 Cài Đặt

### Bước 1: Copy các file vào router

```bash
# Sao chép folder adblock-lite vào /root trên router
scp -r adblock-lite/ root@192.168.1.1:/root/
```

### Bước 2: Chạy script cài đặt

```bash
ssh root@192.168.1.1
cd /root/adblock-lite
chmod +x *.sh
./install.sh
```

**Điều gì xảy ra**:
- Tạo thư mục `/etc/dnsmasq.d` (nếu chưa có)
- Backup cấu hình dhcp/dnsmasq vào `/root/rollback-adblock-lite` (chỉ lần đầu)
- Cấu hình dnsmasq để tải config từ `/etc/dnsmasq.d`
- Tạo file whitelist và blacklist trống
- **Chưa kích hoạt chặn quảng cáo** (bước tiếp theo)

### Bước 3: Bật chặn quảng cáo

```bash
./start.sh
```

**Điều gì xảy ra**:
- Chờ kết nối WAN có sẵn (~30s tối đa)
- Tải danh sách chặn từ GitHub
- Khởi động lại dnsmasq để áp dụng

## 🚀 Sử Dụng

### Các Script Chính

| Script | Chức Năng | Ví Dụ |
|--------|----------|-------|
| `install.sh` | Cài đặt lần đầu, tạo backup | `./install.sh` |
| `start.sh` | Bật chặn quảng cáo | `./start.sh` |
| `stop.sh` | Tắt chặn quảng cáo (giữ lại cấu hình) | `./stop.sh` |
| `restart.sh` | Tắt rồi bật lại | `./restart.sh` |
| `update.sh` | Cập nhật danh sách chặn | `./update.sh` |
| `rollback.sh` | Hoàn nguyên trước cài đặt | `./rollback.sh` |

### Kiểm Tra Hoạt Động

```bash
# Trên router (hoặc máy tính khác trong mạng)
nslookup ads.google.com 192.168.1.1

# Kết quả mong đợi:
# Name:   ads.google.com
# Address: 0.0.0.0      (hoặc NXDOMAIN, tùy danh sách)
```

```bash
# Hoặc dùng dig
dig ads.google.com @192.168.1.1

# Dùng host
host ads.google.com 192.168.1.1
```

### Lên Lịch Cập Nhật (Cron)

Để tự động cập nhật danh sách chặn hàng tuần:

```bash
# SSH vào router
ssh root@192.168.1.1

# Mở cron editor
crontab -e

# Thêm dòng này (cập nhật thứ 7 lúc 3:00 sáng)
0 3 * * 6 /root/adblock-lite/update.sh >> /var/log/adblock-update.log 2>&1
```

## 🔐 Cấu Hình Nâng Cao

### Whitelist (Cho phép domain bị chặn)

Chỉnh sửa `/etc/dnsmasq.d/ad-allowlist.conf` trên router:

```conf
# Cho phép các domain này thông qua
server=/example-whitelist.com/#
server=/bank.example.vn/#
server=/trusted-analytics.com/#
```

**Giải thích**: `server=/domain/#` = dnsmasq sẽ trả về NXDOMAIN (không chặn) thay vì đáp ứng danh sách chặn

### Blacklist (Chặn thêm domain)

Chỉnh sửa `/etc/dnsmasq.d/ad-denylist.conf` trên router:

```conf
# Chặn các domain bổ sung
address=/example-blacklist.com/0.0.0.0
address=/ads.example.vn/0.0.0.0
address=/tracker.example.jp/0.0.0.0
```

**Giải thích**: `address=/domain/0.0.0.0` = trả về địa chỉ 0.0.0.0 (chặn)

### Thay Đổi Danh Sách Chặn

Sửa biến `LIST_URL` trong `start.sh` hoặc `update.sh`:

```bash
# Các tùy chọn từ HaGeZi:
LIST_URL="https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/dnsmasq/pro.mini.txt"
LIST_URL="https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/dnsmasq/pro.plus.mini.txt"
LIST_URL="https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/dnsmasq/pro.txt"
```

### Tối Ưu Hiệu Năng

Tuning được áp dụng tự động trong `install.sh`:

```bash
cache_size='5000'      # Cache nhỏ (mặc định 150, tiết kiệm RAM)
negcache='1'           # Lưu cache kết quả không tìm thấy
domainneeded='1'       # Không forward query không đủ điều kiện
boguspriv='1'          # Ngăn forward private IP queries
```

## 🆘 Troubleshooting

### ❌ Danh sách không tải được

```bash
# 1. Kiểm tra kết nối mạng
ping 1.1.1.1

# 2. Kiểm tra curl/wget
curl https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/dnsmasq/pro.plus.mini.txt

# 3. Xem log dnsmasq
logread | grep -i dnsmasq

# 4. Thử tải thủ công
uclient-fetch -O /etc/dnsmasq.d/adblock.conf https://...
```

### ❌ Quảng cáo vẫn xuất hiện

```bash
# 1. Kiểm tra xem danh sách có được tải không
ls -la /etc/dnsmasq.d/adblock.conf

# 2. Test DNS trực tiếp
nslookup ads.google.com 127.0.0.1

# 3. Xem log
tail -f /var/log/messages | grep dnsmasq

# 4. Restart dnsmasq
service dnsmasq restart
```

### ❌ Không thể rollback

```bash
# Kiểm tra backup có tồn tại không
ls -la /root/rollback-adblock-lite/

# Restore thủ công
cp /root/rollback-adblock-lite/dhcp /etc/config/dhcp
rm -rf /etc/dnsmasq.d
service dnsmasq restart
```

### ⚠️ Hiệu năng router giảm

```bash
# Giảm cache size
uci set dhcp.@dnsmasq[0].cache_size='1000'
uci commit dhcp
service dnsmasq restart
```

## ❓ FAQ

### Q: Có ảnh hưởng đến tốc độ Internet không?

**A**: Ảnh hưởng rất nhỏ. Lookup danh sách chặn cục bộ nhanh hơn forward tới DNS server ngoài. Có thể giảm ~1-5ms so với không có adblock.

### Q: Tôi có thể thêm danh sách chặn riêng không?

**A**: Có! Tạo file `/etc/dnsmasq.d/custom-block.conf` với định dạng:
```
address=/custom-ad-domain.com/0.0.0.0
```
Rồi restart dnsmasq: `service dnsmasq restart`

### Q: Whitelist không hoạt động?

**A**: Đảm bảo định dạng đúng:
```conf
server=/domain-to-allow.com/#
```
Sau đó: `service dnsmasq restart`

### Q: Danh sách quá lớn, router bị chậm?

**A**: Dùng danh sách nhỏ hơn (`.mini` thay vì `.txt`) hoặc giảm cache:
```bash
uci set dhcp.@dnsmasq[0].cache_size='1000'
uci commit dhcp
service dnsmasq restart
```

### Q: Làm sao biết danh sách được tải thành công?

**A**: 
```bash
# Kiểm tra kích thước file
ls -lh /etc/dnsmasq.d/adblock.conf

# Đếm số domain chặn
wc -l /etc/dnsmasq.d/adblock.conf
```

### Q: Có thể cập nhật tự động không?

**A**: Có, thêm vào crontab:
```bash
0 2 * * * /root/adblock-lite/update.sh >> /var/log/adblock-update.log 2>&1
```

### Q: Muốn hoàn nguyên hoàn toàn?

**A**: Chạy `rollback.sh`:
```bash
./rollback.sh
```
Điều này sẽ:
- Restore cấu hình dhcp gốc
- Xóa toàn bộ adblock config
- Restart dnsmasq

## 📁 Cấu Trúc Tập Tin

```
adblock-lite/
├── README.md                      # Tài liệu này
├── install.sh                     # Cài đặt lần đầu + backup
├── start.sh                       # Tải danh sách và bật blocking
├── stop.sh                        # Tắt blocking (giữ cấu hình)
├── restart.sh                     # Tắt rồi bật lại
├── update.sh                      # Cập nhật danh sách chặn
└── rollback.sh                    # Khôi phục trạng thái ban đầu

/etc/dnsmasq.d/
├── adblock.conf                   # Danh sách chặn chính (tự động tải)
├── ad-allowlist.conf              # Whitelist (tạo tự động)
└── ad-denylist.conf               # Blacklist (tạo tự động)

/root/rollback-adblock-lite/
├── dhcp                           # Backup cấu hình dhcp
├── dnsmasq.conf                   # Backup cấu hình dnsmasq
├── dnsmasq.d/                     # Backup folder dnsmasq.d
└── .backup_done                   # Marker tập tin
```

## 🔗 Liên Kết Hữu Ích

- [HaGeZi DNS Blocklists](https://github.com/hagezi/dns-blocklists)
- [Dnsmasq Documentation](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html)
- [OpenWrt UCI Documentation](https://openwrt.org/docs/guide_user/base_system/uci)

## 📝 Ghi Chú

- Tất cả script sử dụng `set -eu` (exit on error, undefined vars)
- Logs có prefix `[install]`, `[start]`, `[stop]`, etc. để dễ debug
- Backup được tạo chỉ 1 lần, để rollback an toàn
- Danh sách tải về có retry 3 lần với delay 2s

## 📄 License

Sử dụng cho mục đích cá nhân. Danh sách chặn từ HaGeZi có license riêng.

---

**Cập nhật lần cuối**: 2026-03-13
