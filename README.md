# pardus-sed-awk-wizard
Pardus Linux için geliştirilmiş; sed ve awk işlemlerini basitleştiren, hata kontrollü ve önizlemeli, çift arayüzlü (GUI &amp; TUI) otomasyon aracı.

![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Pardus%20%2F%20Linux-1793D1?style=for-the-badge&logo=linux&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

**Pardus Sed & Awk Wizard**, Linux terminalindeki karmaşık metin işleme komutlarını herkes için erişilebilir kılan, hata kontrollü ve çift arayüzlü (GUI & TUI) bir otomasyon aracıdır.

> **English:** A dual-interface (GUI/TUI) Bash automation tool designed for Pardus Linux that simplifies complex `sed` and `awk` text processing operations with safety checks and real-time previews.

---

## 📺 Demo Video & Tutorial

Projenin nasıl çalıştığını ve özelliklerini aşağıdaki videodan izleyebilirsiniz:

[![YouTube Demo](https://img.youtube.com/vi/VIDEO_ID_BURAYA/maxresdefault.jpg)](https://www.youtube.com/watch?v=VIDEO_ID_BURAYA)

---

## 📸 Screenshots (Ekran Görüntüleri)

| Ana Menü (GUI) | SED Modülü |
| :---: | :---: |
| ![Main Menu](screenshots/main_menu.png) | ![SED Module](screenshots/sed_module.png) |
| *Yad tabanlı modern arayüz* | *Hata kontrollü düzenleme* |

| AWK Raporlama | TUI Modu (Terminal) |
| :---: | :---: |
| ![AWK Result](screenshots/awk_result.png) | ![TUI Mode](screenshots/tui_mode.png) |
| *Anlık veri önizleme* | *Whiptail ile sunucu uyumu* |

---

## 🌟 Özellikler / Features

* ✅ **Çift Arayüz (Dual Interface):** İster grafik arayüz (Yad), ister terminal arayüzü (Whiptail) kullanın.
* ✅ **Gelişmiş SED İşlemleri:**
    * Metin Bul/Değiştir (Path/URL destekli `s~old~new~g` yapısı).
    * Satır Silme.
    * Satır Değiştirme (Komple satır revizyonu).
* ✅ **Akıllı AWK Süzgeci:** Sütun çekme ve Regex tabanlı içerik filtreleme.
* ✅ **Güvenlik Kontrolleri:**
    * Dosya yazma izni kontrolü (Write permission check).
    * Görünmez karakter temizliği (Input sanitization/trimming).
    * Kaydetmeden önce **Canlı Önizleme** (Live Preview).
* ✅ **Bağımlılık Kontrolü:** Eksik paketleri (`yad`, `whiptail`) açılışta tespit eder.

---

## 🚀 Kurulum ve Kullanım (Installation)

Bu aracı kullanmak için Pardus veya herhangi bir Debian tabanlı (Ubuntu, Mint, Kali) dağıtım kullanabilirsiniz.

### 1. Gereksinimleri Yükleyin
Scriptin grafik arayüzü için `yad`, terminal arayüzü için `whiptail` gereklidir.

```bash
sudo apt update
sudo apt install yad whiptail
