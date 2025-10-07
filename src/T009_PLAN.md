# T009: Room Transfer System
## ระบบย้ายห้องแขกที่เข้าพักแล้ว

### 🎯 ภาพรวมโครงการ

**วัตถุประสงค์:** พัฒนาระบบย้ายห้องสำหรับแขกที่เข้าพักแล้ว เพื่อรองรับสถานการณ์ต่างๆ เช่น ห้องเสีย, อัพเกรด, หรือตามความต้องการของแขก

**ระยะเวลา:** 1-2 สัปดาห์

---

### 🏠 ฟีเจอร์หลัก (Core Features)

#### 1. **Room Transfer Interface**
- หน้าจอเลือกห้องปลายทาง
- แสดงห้องว่างที่เหมาะสม
- ตรวจสอบความเข้ากันได้ของประเภทห้อง
- คำนวณค่าใช้จ่ายเพิ่มเติม (หากมี)

#### 2. **Transfer Validation**
- ตรวจสอบสถานะห้องปลายทาง
- ยืนยันราคาและเงื่อนไข
- ตรวจสอบสิทธิ์การย้าย
- แจ้งเตือนข้อจำกัด (ถ้ามี)

#### 3. **Billing Adjustment**
- คำนวณค่าใช้จ่ายใหม่อัตโนมัติ
- จัดการค่าต่างห้อง (Upgrade/Downgrade)
- สร้างใบแจ้งหนี้เพิ่มเติม
- บันทึกประวัติการเปลี่ยนแปลง

#### 4. **Housekeeping Integration**
- แจ้งเตือนทีมแม่บ้านทำความสะอาดห้องเดิม
- จัดเตรียมห้องใหม่
- ส่งการแจ้งเตือน Telegram
- อัปเดตสถานะห้องอัตโนมัติ

#### 5. **Guest Communication**
- แจ้งเตือนแขกเรื่องการย้ายห้อง
- ส่ง SMS/Email ข้อมูลห้องใหม่
- Key Card ใหม่
- ข้อมูล Wi-Fi และสิ่งอำนวยความสะดวก

---

### 🔄 กระบวนการย้ายห้อง (Transfer Process)

#### Step 1: เลือกการจอง
```
📋 เลือกแขกที่ต้องการย้าย
├── ดูข้อมูลการจองปัจจุบัน
├── ตรวจสอบสถานะการชำระเงิน
└── ยืนยันสิทธิ์การย้าย
```

#### Step 2: เลือกห้องใหม่
```
🏠 เลือกห้องปลายทาง
├── กรองห้องว่างที่เหมาะสม
├── เปรียบเทียบประเภทห้อง
├── แสดงราคาและค่าต่าง
└── ตรวจสอบสิ่งอำนวยความสะดวก
```

#### Step 3: คำนวณค่าใช้จ่าย
```
💰 คำนวณการเงิน
├── ค่าห้องต่อคืนใหม่
├── ค่าต่างห้อง (ถ้ามี)
├── ภาษีและค่าบริการ
└── ยอดรวมที่ต้องชำระเพิ่ม
```

#### Step 4: ยืนยันการย้าย
```
✅ ยืนยันการย้าย
├── บันทึกประวัติการย้าย
├── อัปเดตข้อมูลการจอง
├── สร้างใบแจ้งหนี้ (ถ้ามี)
└── ส่งการแจ้งเตือน
```

---

### 🗄️ Database Schema

#### Room Transfer History
```sql
CREATE TABLE room_transfers (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id INT UNSIGNED NOT NULL,
    from_room_id INT UNSIGNED NOT NULL,
    to_room_id INT UNSIGNED NOT NULL,
    transfer_date DATETIME NOT NULL,
    transfer_reason ENUM('upgrade', 'downgrade', 'maintenance', 'guest_request', 'overbooking') NOT NULL,
    price_difference DECIMAL(10,2) DEFAULT 0,
    additional_charges DECIMAL(10,2) DEFAULT 0,
    transferred_by INT UNSIGNED NOT NULL,
    guest_notified TINYINT(1) DEFAULT 0,
    housekeeping_notified TINYINT(1) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id) REFERENCES bookings(id),
    FOREIGN KEY (from_room_id) REFERENCES rooms(id),
    FOREIGN KEY (to_room_id) REFERENCES rooms(id),
    FOREIGN KEY (transferred_by) REFERENCES users(id),

    INDEX idx_booking_transfer (booking_id),
    INDEX idx_transfer_date (transfer_date)
);
```

#### Transfer Billing
```sql
CREATE TABLE transfer_billing (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    transfer_id INT UNSIGNED NOT NULL,
    original_rate DECIMAL(10,2) NOT NULL,
    new_rate DECIMAL(10,2) NOT NULL,
    rate_difference DECIMAL(10,2) NOT NULL,
    nights_affected INT NOT NULL,
    additional_services DECIMAL(10,2) DEFAULT 0,
    total_adjustment DECIMAL(10,2) NOT NULL,
    payment_status ENUM('pending', 'paid', 'waived') DEFAULT 'pending',
    payment_method VARCHAR(50),
    payment_date DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (transfer_id) REFERENCES room_transfers(id),
    INDEX idx_payment_status (payment_status)
);
```

---

### 📱 UI/UX Design

#### Transfer Modal
```
┌─────────────────────────────────────────┐
│  🔄 ย้ายห้องแขก                         │
├─────────────────────────────────────────┤
│  👤 ข้อมูลแขก                          │
│  • ชื่อ: คุณสมชาย ใจดี                  │
│  • ห้องปัจจุบัน: 101 (Standard)         │
│  • วันที่เข้าพัก: 15/01/2024             │
│  • วันที่ออก: 17/01/2024                │
├─────────────────────────────────────────┤
│  🏠 เลือกห้องใหม่                       │
│  [DropDown: ประเภทห้อง]                 │
│  [Grid: ห้องว่าง] 102 103 105 201...    │
├─────────────────────────────────────────┤
│  💰 การคำนวณค่าใช้จ่าย                   │
│  • ราคาเดิม: ฿1,500/คืน                │
│  • ราคาใหม่: ฿2,000/คืน                │
│  • ค่าต่าง: ฿500/คืน × 2 คืน = ฿1,000   │
├─────────────────────────────────────────┤
│  📝 เหตุผลการย้าย                       │
│  [Dropdown: เลือกเหตุผล]               │
│  [TextArea: หมายเหตุเพิ่มเติม]          │
├─────────────────────────────────────────┤
│  [ยกเลิก] [ยืนยันการย้าย] ✅           │
└─────────────────────────────────────────┘
```

---

### 🎛️ ระบบแจ้งเตือน

#### Telegram Notifications
```php
🔄 การย้ายห้องแขก

👤 แขก: คุณสมชาย ใจดี
🏠 จาก: ห้อง 101 (Standard)
➡️ ไป: ห้อง 201 (Deluxe)
📅 วันที่: 15/01/2024
💰 ค่าต่าง: +฿1,000
📋 เหตุผล: Upgrade ตามความต้องการแขก

🧹 งานแม่บ้าน:
• ทำความสะอาดห้อง 101
• เตรียมห้อง 201

👤 ดำเนินการโดย: พนักงานต้อนรับ
```

#### Email/SMS แขก
```
เรียน คุณสมชาย ใจดี

ขอแจ้งให้ทราบว่าห้องพักของท่านได้ถูกย้าย
จาก: ห้อง 101 ไป: ห้อง 201

รายละเอียด:
• ประเภทห้อง: Deluxe Room
• Key Card ใหม่: รับได้ที่เคาน์เตอร์
• Wi-Fi: Hotel_Guest / รหัส: 12345
• ค่าใช้จ่ายเพิ่มเติม: ฿1,000

ขออภัยในความไม่สะดวก
โรงแรม ABC
```

---

### 🔧 Business Rules

#### Transfer Eligibility
```php
// เงื่อนไขการย้ายห้อง
$canTransfer = [
    'guest_checked_in' => true,      // แขกต้องเช็คอินแล้ว
    'payment_current' => true,       // ค่าห้องปัจจุบันชำระแล้ว
    'target_room_available' => true, // ห้องปลายทางว่าง
    'no_pending_issues' => true,     // ไม่มีปัญหาค้างชำระ
    'within_stay_period' => true     // อยู่ในช่วงการพัก
];
```

#### Rate Calculation
```php
// คำนวณค่าต่างห้อง
function calculateTransferCost($fromRoom, $toRoom, $remainingNights) {
    $originalRate = $fromRoom['current_rate'];
    $newRate = $toRoom['rate'];
    $rateDifference = $newRate - $originalRate;
    $totalDifference = $rateDifference * $remainingNights;

    return [
        'rate_difference_per_night' => $rateDifference,
        'total_difference' => $totalDifference,
        'tax' => $totalDifference * 0.07,
        'service_charge' => $totalDifference * 0.10
    ];
}
```

---

### 📋 Implementation Steps

#### Phase 1: Core Transfer System (Week 1)
- [ ] Transfer interface design
- [ ] Room availability checking
- [ ] Basic transfer functionality
- [ ] Database schema implementation

#### Phase 2: Billing Integration (Week 1)
- [ ] Rate calculation engine
- [ ] Billing adjustment system
- [ ] Payment processing
- [ ] Invoice generation

#### Phase 3: Notifications (Week 2)
- [ ] Telegram integration
- [ ] Email/SMS notifications
- [ ] Housekeeping alerts
- [ ] Guest communication

#### Phase 4: Validation & Testing (Week 2)
- [ ] Business rules validation
- [ ] Transfer history tracking
- [ ] Error handling
- [ ] User acceptance testing

---

### 🎯 Success Metrics

#### Operational Efficiency
- Transfer process completion < 5 minutes
- 100% accurate billing calculations
- Real-time inventory updates
- Zero data inconsistencies

#### User Experience
- Intuitive transfer interface
- Clear cost breakdowns
- Automated notifications
- Comprehensive audit trail

---

### 📁 File Structure

```
t009_room_transfer/
├── rooms/
│   ├── transfer.php              # Main transfer interface
│   ├── transfer_process.php      # Transfer processing logic
│   └── transfer_history.php      # Transfer history view
├── api/
│   ├── get_available_rooms.php   # AJAX: Available rooms
│   ├── calculate_transfer.php    # AJAX: Cost calculation
│   └── process_transfer.php      # AJAX: Process transfer
├── lib/
│   ├── transfer_engine.php       # Core transfer logic
│   ├── billing_calculator.php    # Billing calculations
│   └── notification_service.php  # Notification handling
├── reports/
│   └── transfer_report.php       # Transfer analytics
└── database/
    ├── transfer_schema.sql       # Database schema
    └── transfer_sample_data.sql  # Sample data
```

---

### 🚀 Quick Start Guide

#### For Reception Staff
1. ไปที่ Room Board
2. คลิก "ย้ายห้อง" ในห้องที่มีแขก
3. เลือกห้องใหม่จากรายการ
4. ตรวจสอบค่าใช้จ่าย
5. ใส่เหตุผลการย้าย
6. ยืนยันการย้าย

#### For Managers
1. ดูประวัติการย้ายห้องใน Reports
2. ตรวจสอบสถิติการ Upgrade/Downgrade
3. วิเคราะห์ความถี่การย้ายห้อง
4. Monitor customer satisfaction

---

**หมายเหตุ:** T009 นี้เน้นการพัฒนาระบบย้ายห้องที่ครอบคลุมทุกขั้นตอน ตั้งแต่การเลือกห้อง การคำนวณค่าใช้จ่าย ไปจนถึงการแจ้งเตือนและการติดตามผล เพื่อให้การบริการแขกเป็นไปอย่างราบรื่นและมีประสิทธิภาพ