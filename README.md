# pardus-sed-awk-wizard

**Pardus Sed & Awk Wizard**, Linux terminalindeki karmaşık metin işleme komutlarını herkes için erişilebilir kılan, hata kontrollü ve çift arayüzlü (GUI & TUI) bir otomasyon aracıdır.

> **English:** A dual-interface (GUI/TUI) Bash automation tool designed for Pardus Linux that simplifies complex `sed` and `awk` text processing operations with safety checks and real-time previews.

---

## 📺 Demo Video & Tutorial

Projenin nasıl çalıştığını ve özelliklerini aşağıdaki videodan izleyebilirsiniz:

[![YouTube Demo](https://img.youtube.com/vi/VIDEO_ID_BURAYA/maxresdefault.jpg)](https://www.youtube.com/watch?v=VIDEO_ID_BURAYA)

---
## 📸 Arayüzler ve Kullanım Detayları (Screenshots)

Pardus Sed & Awk Wizard, kullanıcının çalışma ortamına (Masaüstü veya Sunucu) göre otomatik olarak adapte olabilen esnek bir yapıya sahiptir. Aşağıda programın sunduğu arayüzleri ve özellikleri inceleyebilirsiniz.

### 1. Akıllı Başlangıç Menüsü
Program ilk çalıştırıldığında sistem analizi yapar ve gerekli bağımlılıkları (`yad`) kontrol eder. Ardından size çalışma modunu sorar.

> **Özellik:** Bu menü, sisteminizde grafik arayüz (X11/Wayland) olup olmadığını algılar ve sizi en doğru moda yönlendirir.

![Başlangıç Menüsü](screenshots/main.png)

---

### 2. Grafik Arayüz (GUI Modu) - Masaüstü Kullanıcıları İçin
Pardus masaüstü kullanıcıları için `Yad` teknolojisi ile geliştirilmiş modern bir arayüz sunar.

* **Dosya Seçici:** Hata yapmayı önlemek için görsel dosya seçme penceresi.
* **İşlem Menüleri:** `sed` ve `awk` komutlarını ezberlemenize gerek kalmadan, açılır menülerden işlem seçebilirsiniz.
* **Güvenlik:** "Yazma izni olmayan" veya "sistem dosyalarını" seçerseniz program sizi uyarır.

![GUI Ana Menü](screenshots/guimain.png)

---

### 3. Terminal Arayüzü (TUI Modu) - Sunucu ve Hız Tutkunları İçin
Grafik arayüzün olmadığı sunucularda (Headless Server) veya terminalden ayrılmak istemeyenler için **Saf Bash (Pure CLI)** arayüzü devreye girer.

* **Hız:** Herhangi bir grafik kütüphanesine ihtiyaç duymaz, çok hızlı çalışır.
* **Renkli Çıktılar:** Hataları kırmızı, onayları yeşil, bilgileri mavi renkle göstererek okunabilirliği artırır.
* **Klavye Kontrolü:** Farenizi kullanmadan tüm işlemleri klavye ile yönetebilirsiniz.

![TUI Terminal Modu](screenshots/tuimain.png)

---

### 4. Canlı Önizleme ve Sonuç Raporu
İster GUI ister TUI kullanın, hiçbir işlem dosyanıza doğrudan uygulanmaz. Önce geçici bir alanda (buffer) işlem yapılır ve size **"Önizleme Penceresi"** sunulur.

> **Güvenlik:** Sonuçtan memnun kalırsanız "Kaydet" butonuna basarsınız. Böylece veri kaybı riski %0'a indirilir.

![Sonuç Önizleme](screenshots/ongosterim.png)

##  Özellikler / Features

*  **Çift Arayüz (Dual Interface):** İster grafik arayüz (Yad), ister terminal arayüzü (Whiptail) kullanın.
*  **Gelişmiş SED İşlemleri:**
    * Metin Bul/Değiştir (Path/URL destekli `s~old~new~g` yapısı).
    * Satır Silme.
    * Satır Değiştirme (Komple satır revizyonu).
*  **Akıllı AWK Süzgeci:** Sütun çekme ve Regex tabanlı içerik filtreleme.
*  **Güvenlik Kontrolleri:**
    * Dosya yazma izni kontrolü (Write permission check).
    * Görünmez karakter temizliği (Input sanitization/trimming).
    * Kaydetmeden önce **Canlı Önizleme** (Live Preview).
*  **Bağımlılık Kontrolü:** Eksik paketleri (`yad`, `whiptail`) açılışta tespit eder.

---

##  Kurulum ve Kullanım (Adım Adım)

Bu aracı Pardus veya Debian tabanlı (Ubuntu, Linux Mint, Kali vb.) tüm sistemlerde sorunsuz çalıştırabilirsiniz.

### 1. Adım: Gerekli Paketleri Yükleyin
Programın grafik arayüzü için `yad`, projeyi indirmek için `git` paketine ihtiyacınız var. Terminali açın ve şu komutu yapıştırın:

```bash
sudo apt update
sudo apt install yad git -y
```

### 2. Adım: Projeyi Bilgisayarınıza İndirin
Github üzerindeki proje dosyalarını bilgisayarınıza çekmek için şu komutu kullanın:

```bash
# Aşağıdaki linkteki KULLANICI_ADIN kısmını kendi GitHub adınızla değiştirin
git clone https://github.com/KULLANICI_ADIN/pardus-sed-awk-wizard.git
```

### 3. Adım: Proje Klasörüne Girin

İndirdiğiniz klasörün içine girin:
```bash
cd pardus-sed-awk-wizard
```

### 4. Adım: Çalıştırma İzni Verin ve Başlatın

İndirilen dosya güvenlik gereği hemen çalışmaz. Önce ona "çalışabilir" izni vermeli, sonra başlatmalısınız:
```bash
# İzin ver
chmod +x wizard.sh

# Programı çalıştır
./wizard.sh
```
