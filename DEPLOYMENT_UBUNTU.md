# 🚀 คู่มือการ Deploy โปรเจค Hotel Management System บน Ubuntu Server

## 📋 สารบัญ
- [ความต้องการของระบบ](#ความต้องการของระบบ)
- [วิธีที่ 1: Deploy ด้วย Git (แนะนำ)](#วิธีที่-1-deploy-ด้วย-git-แนะนำ)
- [วิธีที่ 2: Deploy ด้วย Script อัตโนมัติ](#วิธีที่-2-deploy-ด้วย-script-อัตโนมัติ)
- [วิธีที่ 3: Deploy แบบ Manual](#วิธีที่-3-deploy-แบบ-manual)
- [การตั้งค่า SSL/HTTPS](#การตั้งค่า-sslhttps)
- [การ Backup และ Restore](#การ-backup-และ-restore)
- [Troubleshooting](#troubleshooting)

---

## 💻 ความต้องการของระบบ

### Hardware Requirements (ขั้นต่ำ)
- **CPU:** 2 Cores
- **RAM:** 2 GB
- **Storage:** 20 GB SSD
- **Network:** Port 80, 3306, 8080 เปิด

### Software Requirements
- **OS:** Ubuntu 20.04 LTS หรือใหม่กว่า
- **Docker:** 20.10+
- **Docker Compose:** 1.29+

### Recommended Specs (สำหรับ Production)
- **CPU:** 4 Cores
- **RAM:** 4 GB
- **Storage:** 50 GB SSD
- **Bandwidth:** 100 Mbps

---

## 🚀 วิธีที่ 1: Deploy ด้วย Git (แนะนำ)

### ขั้นตอนที่ 1: เตรียม Ubuntu Server

```bash
# อัพเดท system
sudo apt update && sudo apt upgrade -y

# ติดตั้ง Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# ติดตั้ง Docker Compose
sudo apt install -y docker-compose

# ติดตั้ง Git
sudo apt install -y git

# ตรวจสอบ
docker --version
docker-compose --version
git --version
```

### ขั้นตอนที่ 2: Clone โปรเจค

```bash
# Clone จาก GitHub (แทนที่ URL ด้วย repo ของคุณ)
git clone https://github.com/YOUR_USERNAME/hotel-app.git
cd hotel-app

# หรือ Download zip และ extract
wget https://github.com/YOUR_USERNAME/hotel-app/archive/main.zip
unzip main.zip
cd hotel-app-main
```

### ขั้นตอนที่ 3: ตั้งค่า Environment

```bash
# สร้างไฟล์ .env สำหรับ production
cat > .env << 'EOF'
APP_ENV=production
APP_DEBUG=false
DB_HOST=db
DB_NAME=hotel_management
DB_USER=root
DB_PASSWORD=t0tFlyToDream
DB_PORT=3306
EOF

# ตั้งค่า permissions
chmod 600 .env
```

### ขั้นตอนที่ 4: Deploy

```bash
# Build และ Start containers
docker-compose -f docker-compose.prod.yml up -d --build

# รอให้ MySQL พร้อม (ประมาณ 30 วินาที)
sleep 30

# Import database schema
docker exec -i hotel-db mysql -uroot -pt0tFlyToDream -e "CREATE DATABASE IF NOT EXISTS hotel_management CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
docker exec -i hotel-db mysql -uroot -pt0tFlyToDream hotel_management < src/database/schema.sql

# ตั้งค่า user passwords
docker exec hotel-db mysql -uroot -pt0tFlyToDream hotel_management << 'SQL'
UPDATE users SET password_hash = '$2y$10$kax1BzbSErfsaEoRS9o5cuDQPb4MyKzTbLlxmJDA5ge.LWfq4bWBa' WHERE username = 'admin';
UPDATE users SET password_hash = '$2y$10$ITP8utHBKobzU0m/c76iMOt9EPlgwrtrtsQfS8Q3i3V28YK3b8PM6' WHERE username IN ('reception', 'reception1');
UPDATE users SET password_hash = '$2y$10$rEIpC2oYrBiOrsyPhL7CIOueNvn1BPaSQcY7J8B8A0KGH4Mx4CRfy' WHERE username IN ('housekeeping', 'housekeeper1', 'housekeeper2');
SQL

# ตรวจสอบสถานะ
docker-compose -f docker-compose.prod.yml ps
```

### ✅ เสร็จสิ้น!

เข้าใช้งานได้ที่:
- **Web:** http://your-server-ip
- **phpMyAdmin:** http://your-server-ip:8080

---

## 🤖 วิธีที่ 2: Deploy ด้วย Script อัตโนมัติ

### ขั้นตอนเดียว!

```bash
# Clone โปรเจค
git clone https://github.com/YOUR_USERNAME/hotel-app.git
cd hotel-app

# ให้สิทธิ์รัน script
chmod +x deploy.sh

# รัน deployment script
./deploy.sh
```

Script จะทำให้อัตโนมัติ:
1. ✅ ตรวจสอบและติดตั้ง Docker
2. ✅ Build containers
3. ✅ Import database
4. ✅ ตั้งค่า users
5. ✅ แสดงข้อมูล login และ URL

---

## 🛠️ วิธีที่ 3: Deploy แบบ Manual (ไม่ใช้ Git)

### ขั้นตอนที่ 1: Upload ไฟล์โปรเจค

```bash
# บน Windows - Compress โปรเจค
# (ใช้ WinRAR/7zip หรือ tar)
tar -czf hotel-app.tar.gz D:\hotelapp

# Upload ไป Server (ใช้ WinSCP, FileZilla หรือ scp)
scp hotel-app.tar.gz username@your-server-ip:/home/username/

# บน Ubuntu Server - Extract
cd /home/username
tar -xzf hotel-app.tar.gz
cd hotel-app
```

### ขั้นตอนที่ 2: ติดตั้ง Docker

```bash
# ติดตั้ง Docker และ Docker Compose (ถ้ายังไม่มี)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
sudo apt install -y docker-compose
```

### ขั้นตอนที่ 3: Deploy

```bash
# เหมือนวิธีที่ 1 ขั้นตอนที่ 4
docker-compose -f docker-compose.prod.yml up -d --build
# ... (ตามขั้นตอนด้านบน)
```

---

## 🔒 การตั้งค่า SSL/HTTPS (Production)

### ใช้ Nginx Reverse Proxy + Let's Encrypt

```bash
# 1. ติดตั้ง Nginx
sudo apt install -y nginx certbot python3-certbot-nginx

# 2. สร้าง Nginx config
sudo nano /etc/nginx/sites-available/hotel

# เพิ่มข้อมูล:
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# 3. Enable site
sudo ln -s /etc/nginx/sites-available/hotel /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# 4. ติดตั้ง SSL Certificate
sudo certbot --nginx -d yourdomain.com

# 5. Auto-renewal
sudo systemctl enable certbot.timer
```

---

## 💾 การ Backup และ Restore

### Backup Database

```bash
# Backup แบบ Full
docker exec hotel-db mysqldump -uroot -pt0tFlyToDream hotel_management > backup_$(date +%Y%m%d).sql

# Backup และ Compress
docker exec hotel-db mysqldump -uroot -pt0tFlyToDream hotel_management | gzip > backup_$(date +%Y%m%d).sql.gz

# Backup อัตโนมัติทุกวัน (Cron)
crontab -e
# เพิ่มบรรทัด:
0 2 * * * docker exec hotel-db mysqldump -uroot -pt0tFlyToDream hotel_management | gzip > /backups/hotel_$(date +\%Y\%m\%d).sql.gz
```

### Restore Database

```bash
# Restore จาก backup
docker exec -i hotel-db mysql -uroot -pt0tFlyToDream hotel_management < backup_20251006.sql

# Restore จาก compressed file
gunzip < backup_20251006.sql.gz | docker exec -i hotel-db mysql -uroot -pt0tFlyToDream hotel_management
```

### Backup ทั้งระบบ

```bash
# Backup volumes
docker run --rm -v hotel-db-data:/data -v $(pwd):/backup ubuntu tar czf /backup/db-data-backup.tar.gz /data

# Backup source code
tar czf hotel-app-backup.tar.gz /path/to/hotel-app
```

---

## 🔧 คำสั่งที่ใช้บ่อย

```bash
# ดู logs
docker-compose -f docker-compose.prod.yml logs -f

# ดู logs เฉพาะ service
docker-compose -f docker-compose.prod.yml logs -f web

# Restart services
docker-compose -f docker-compose.prod.yml restart

# Stop all
docker-compose -f docker-compose.prod.yml down

# Update โปรเจค (ถ้าใช้ Git)
git pull origin main
docker-compose -f docker-compose.prod.yml up -d --build

# เข้า MySQL shell
docker exec -it hotel-db mysql -uroot -pt0tFlyToDream hotel_management

# เข้า Web container shell
docker exec -it hotel-web bash
```

---

## 🐛 Troubleshooting

### ปัญหา: Containers ไม่สามารถ start ได้

```bash
# ตรวจสอบ logs
docker-compose -f docker-compose.prod.yml logs

# ตรวจสอบ port ว่าถูกใช้งานอยู่หรือไม่
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :3306

# Kill process ที่ใช้ port (ถ้าจำเป็น)
sudo kill -9 <PID>
```

### ปัญหา: MySQL connection error

```bash
# ตรวจสอบ MySQL container
docker logs hotel-db

# รอให้ MySQL พร้อม
until docker exec hotel-db mysql -uroot -pt0tFlyToDream -e "SELECT 1" &> /dev/null; do
    echo "Waiting for MySQL..."
    sleep 3
done
```

### ปัญหา: Permission denied

```bash
# ตั้งค่า permissions
sudo chown -R www-data:www-data src/
sudo chmod -R 755 src/
```

### ปัญหา: Out of disk space

```bash
# ตรวจสอบ disk space
df -h

# ลบ unused Docker images/containers
docker system prune -a --volumes
```

### ปัญหา: ไม่สามารถเข้าเว็บได้

```bash
# ตรวจสอบ firewall
sudo ufw status
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp

# ตรวจสอบ SELinux (CentOS/RHEL)
sudo setenforce 0
```

---

## 📊 Monitoring และ Performance

### ติดตั้ง Monitoring Tools

```bash
# ดูสถานะ containers
docker stats

# ติดตั้ง ctop (Container monitoring)
sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
sudo chmod +x /usr/local/bin/ctop
ctop
```

### เพิ่ม Resource Limits

แก้ไข `docker-compose.prod.yml`:

```yaml
services:
  web:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 1G
  db:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

---

## 🔐 Security Checklist

- [ ] เปลี่ยน default passwords ทั้งหมด
- [ ] ตั้งค่า firewall (ufw)
- [ ] ติดตั้ง fail2ban
- [ ] ใช้ HTTPS/SSL
- [ ] ซ่อน phpMyAdmin หรือใช้ authentication
- [ ] Backup อัตโนมัติ
- [ ] Update security patches สม่ำเสมอ
- [ ] จำกัด SSH access (key-based only)

---

## 📞 Support

หากพบปัญหา:
1. ตรวจสอบ logs: `docker-compose logs`
2. ดู [Troubleshooting](#troubleshooting)
3. ติดต่อทีมพัฒนา

---

**พัฒนาโดย:** Hotel Management System Team
**เวอร์ชัน:** 1.0.0
**อัพเดต:** 6 ตุลาคม 2025
