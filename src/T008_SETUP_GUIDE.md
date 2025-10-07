# 🚀 T008 Housekeeping Notification System - คู่มือติดตั้งและใช้งาน

## 📋 ขั้นตอนการติดตั้ง

### 1. ติดตั้งฐานข้อมูล
```bash
# เข้า phpMyAdmin หรือใช้ MySQL command line
# รันไฟล์ SQL สำหรับติดตั้งและข้อมูลทดสอบ
```

**รันไฟล์:** `setup_t008_demo.sql`

**หรือรันทีละคำสั่ง:**
```sql
-- เข้าฐานข้อมูล
USE hotel_management;

-- สร้างตารางใหม่
CREATE TABLE telegram_notifications (...);
CREATE TABLE hotel_settings (...);

-- เพิ่มคอลัมน์ในตารางเดิม
ALTER TABLE housekeeping_jobs ADD COLUMN booking_id ...;
ALTER TABLE users ADD COLUMN telegram_chat_id ...;
```

### 2. ตั้งค่า Telegram Bot

#### 2.1 สร้าง Telegram Bot
1. เปิด Telegram และค้นหา `@BotFather`
2. ส่งคำสั่ง `/newbot`
3. ตั้งชื่อบอท เช่น `Hotel Housekeeping Bot`
4. ตั้ง username เช่น `@hotel_housekeeping_bot`
5. **เก็บ Bot Token** ที่ได้รับ (ตัวอย่าง: `123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11`)

#### 2.2 หา Chat ID
1. เพิ่มบอทเข้ากลุ่มหรือแชทส่วนตัว
2. ส่งข้อความใดๆ ให้บอท
3. เปิดใน browser: `https://api.telegram.org/bot[BOT_TOKEN]/getUpdates`
4. หา `"chat":{"id":` **เก็บ Chat ID** (ตัวอย่าง: `123456789`)

#### 2.3 อัปเดตฐานข้อมูล
```sql
-- ใส่ Bot Token
UPDATE hotel_settings
SET setting_value = 'YOUR_BOT_TOKEN_HERE'
WHERE setting_key = 'telegram_bot_token';

-- ใส่ Chat ID สำหรับแจ้งเตือนทั่วไป
UPDATE hotel_settings
SET setting_value = 'YOUR_CHAT_ID_HERE'
WHERE setting_key = 'default_housekeeping_chat_id';

-- หรือใส่ Chat ID ให้พนักงานทำความสะอาดโดยตรง
UPDATE users
SET telegram_chat_id = 'HOUSEKEEPER_CHAT_ID'
WHERE role = 'housekeeping';
```

## 🎯 การใช้งาน

### ขั้นตอนการทำงานปกติ:

1. **แขก Check-out**
   - ผ่านหน้า `rooms/checkout.php`
   - ระบบสร้างงาน housekeeping อัตโนมัติ

2. **ส่งแจ้งเตือน Telegram**
   - บอทส่งข้อความไปยังเจ้าหน้าที่
   - พร้อมลิงก์ไปยังหน้างาน

3. **เจ้าหน้าที่ทำงาน**
   - คลิกลิงก์ในข้อความ
   - เข้าหน้า `housekeeping/job.php`
   - เริ่มงาน → ทำงาน → เสร็จสิ้น

4. **ห้องกลับสู่สถานะปกติ**
   - ห้องเปลี่ยนเป็น 'available'
   - ส่งแจ้งเตือนเสร็จสิ้นงาน

## 📊 หน้าจอสำคัญ

### 1. หน้าแสดงงาน: `/?r=housekeeping.jobs`
- ดูรายการงานทั้งหมด
- กรองตามสถานะ, วันที่
- เข้าไปดูรายละเอียดงาน

### 2. หน้ารายละเอียดงาน: `/?r=housekeeping.job&id=X`
- ข้อมูลห้อง, แขก, เวลา
- เริ่มงาน/เสร็จสิ้นงาน
- เพิ่มหมายเหตุความคืบหน้า

### 3. หน้ารายงาน: `/?r=housekeeping.reports`
- สถิติประสิทธิภาพ
- รายงานรายบุคคล
- กราฟแสดงแนวโน้ม

## 🧪 ทดสอบระบบ

### ไฟล์ทดสอบ:
1. **`demo_t008.php`** - หน้าแสดงฟีเจอร์และการทำงาน
2. **`test_housekeeping_system.php`** - ทดสอบเทคนิค 7 ด้าน

### การทดสอบ:
```bash
# เข้าใช้งานผ่าน browser
http://localhost/hotel-app/demo_t008.php
http://localhost/hotel-app/test_housekeeping_system.php
```

## ⚙️ การกำหนดค่าเพิ่มเติม

### ข้อความแจ้งเตือน:
```sql
-- เปลี่ยนข้อความแจ้งเตือน
UPDATE hotel_settings
SET setting_value = '🧹 มีงานทำความสะอาดใหม่!'
WHERE setting_key = 'housekeeping_notification_template';
```

### ปิด/เปิดการแจ้งเตือน:
```sql
-- ปิดการแจ้งเตือน
UPDATE hotel_settings
SET setting_value = 'false'
WHERE setting_key = 'notification_enabled';
```

## 🔧 แก้ไขปัญหา

### ปัญหา: ไม่ส่งแจ้งเตือน
1. ตรวจสอบ Bot Token ถูกต้องหรือไม่
2. ตรวจสอบ Chat ID ถูกต้องหรือไม่
3. ดู log ในไฟล์ error.log
4. ทดสอบการเชื่อมต่อผ่าน `test_housekeeping_system.php`

### ปัญหา: งานไม่ถูกสร้าง
1. ตรวจสอบตาราง `housekeeping_jobs` มีคอลัมน์ใหม่หรือไม่
2. ตรวจสอบการ checkout ใน `rooms/checkout.php`
3. ดูใน log การสร้างงาน

### ปัญหา: หน้าไม่แสดง
1. ตรวจสอบ routing ใน `includes/router.php`
2. ตรวจสอบไฟล์อยู่ในตำแหน่งที่ถูกต้อง
3. ตรวจสอบ permission ของไฟล์

## 📞 การสนับสนุน

หากมีปัญหาในการติดตั้งหรือใช้งาน:
1. ดูใน `test_housekeeping_system.php` เพื่อวินิจฉัยปัญหา
2. ตรวจสอบ error log ของ PHP
3. ทดสอบการเชื่อมต่อฐานข้อมูล

---

## 🎉 ขั้นตอนถัดไป

เมื่อ T008 ทำงานเรียบร้อยแล้ว พร้อมพัฒนาฟีเจอร์ต่อไป:
- **T009: Room Transfer System** - ระบบย้ายห้องแขก
- **T010: Equipment Request System** - ระบบขออุปกรณ์เพิ่ม
- **T011: Room Management Admin** - ระบบจัดการห้องแอดมิน
- **T012: Hotel Information Management** - ระบบแก้ไขข้อมูลโรงแรม