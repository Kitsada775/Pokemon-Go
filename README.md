# Pokémon Team Builder
แอปพลิเคชัน Flutter สำหรับสร้างทีมโปเกม่อน  
ผู้ใช้สามารถเลือกโปเกม่อน จัดทีม บันทึก และแก้ไขชื่อทีมได้
คุณสมบัติหลัก
- สร้างทีมใหม่ → ตั้งชื่อทีม
- เลือกโปเกม่อนจาก PokeAPI (แสดงรูป + ชื่อ)
- ค้นหาโปเกม่อนด้วย Search Bar
- บันทึกทีม → เก็บชื่อ + รายชื่อโปเกม่อน
- ดูทีมที่บันทึกแล้ว → พร้อมแก้ไขหรือลบ
- Reset ทีมได้จาก AppBar
- มี Animation (Hero, Highlight ตอนเลือก)
ข้อกำหนดระบบ
- **Flutter SDK**: 3.0.0 ขึ้นไป
- **Dart SDK**: 2.17.0 ขึ้นไป
- **Packages ที่ใช้**
  - `get`
  - `get_storage`
  - `http`
การติดตั้งและการรัน
1. Clone โปรเจค
   ```bash
   git clone https://github.com/USERNAME/PokemonTeamBuilder.git
   cd myapp
   
flutter pub get
flutter run
