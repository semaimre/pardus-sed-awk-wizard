#!/bin/bash

# ============================================================
# Proje: Pardus Sed & Awk Sihirbazı (v4.3 - Column Shift Fix)
# Düzeltme: Ayıraç çakışması giderildi (! ve | ayrımı)
# ============================================================

TEMP_OUT="/tmp/proje_preview.txt"

cleanup() { rm -f "$TEMP_OUT"; }
trap cleanup EXIT

# ------------------------------------------------------------
# BAŞLANGIÇ KONTROLLERİ
# ------------------------------------------------------------
check_dependencies() {
    if ! command -v yad &> /dev/null; then
        if command -v whiptail &> /dev/null; then
            whiptail --title "Hata" --msgbox "yad paketi eksik.\nsudo apt install yad" 10 60
        else
            echo "HATA: 'yad' paketi eksik."
        fi
        exit 1
    fi
}
check_dependencies

show_error() {
    yad --error --title="Hata" --text="$1" --center --width=300 --button="Tamam:0"
}

# ------------------------------------------------------------
# 1. GUI: SED MODÜLÜ (GÜNCELLENDİ)
# ------------------------------------------------------------
gui_sed_module() {
    # DÜZELTME: Menü seçeneklerini ayırmak için ! kullanıyoruz.
    # Sonuçları ayırmak için varsayılan | (boru) kullanıyoruz.
    
    VALS=$(yad --form \
        --title="SED Modülü" \
        --center --width=600 \
        --image="text-editor" \
        --text="<span color='red'><b>DİKKAT:</b></span> Dosya yolları (/usr/bin) güvenle kullanılabilir." \
        --field="Dosya Seç:FL" "" \
        --field="İşlem Tipi:CB" "Metin Değiştir (Kelime bul/yeni yap)!Satır Sil (Numara gir)!Satır Değiştir (Numara gir komple değişsin)" \
        --field="Aranan Metin VEYA Satır No:" "" \
        --field="Yeni Metin (Değişim için):" "" \
        --separator="|")

    if [ -z "$VALS" ]; then return; fi

    # Ayıraç | olduğu için awk -F'|' kullanıyoruz
    FILE=$(echo "$VALS" | awk -F'|' '{print $1}')
    TYPE=$(echo "$VALS" | awk -F'|' '{print $2}')
    PARAM1=$(echo "$VALS" | awk -F'|' '{print $3}')
    PARAM2=$(echo "$VALS" | awk -F'|' '{print $4}')

    CLEAN_P1=$(echo "$PARAM1" | tr -d '[:space:]')

    if [ ! -f "$FILE" ]; then show_error "Dosya seçilmedi!"; return; fi
    if [ ! -w "$FILE" ]; then show_error "Yazma izniniz yok!"; return; fi
    if [ -z "$PARAM1" ]; then show_error "Aranan değer boş olamaz!"; return; fi

    if [[ "$TYPE" == *"Metin Değiştir"* ]]; then
        if [[ "$CLEAN_P1" =~ ^[0-9]+$ ]]; then
             yad --question --title="Uyarı" --text="Sadece sayı ($PARAM1) girdiniz ama 'Metin Değiştir' seçili.\nDevam edilsin mi?" --button="Hayır:1" --button="Evet:0"
             if [ $? -ne 0 ]; then return; fi
        fi
        sed "s~$PARAM1~$PARAM2~g" "$FILE" > "$TEMP_OUT"

    elif [[ "$TYPE" == *"Satır Sil"* ]]; then
        if ! [[ "$CLEAN_P1" =~ ^[0-9]+$ ]]; then show_error "Lütfen geçerli bir satır numarası girin!"; return; fi
        sed "${CLEAN_P1}d" "$FILE" > "$TEMP_OUT"

    elif [[ "$TYPE" == *"Satır Değiştir"* ]]; then
        if ! [[ "$CLEAN_P1" =~ ^[0-9]+$ ]]; then show_error "Lütfen geçerli bir satır numarası girin!"; return; fi
        sed "${CLEAN_P1}c${PARAM2}" "$FILE" > "$TEMP_OUT"
    fi

    yad --text-info --title="Önizleme" --width=600 --height=500 --filename="$TEMP_OUT" --button="İptal:1" --button="KAYDET:0"

    if [ $? -eq 0 ]; then
        cp "$TEMP_OUT" "$FILE"
        yad --info --text="Kaydedildi!" --button="Tamam:0"
    fi
}

# ------------------------------------------------------------
# 2. GUI: AWK MODÜLÜ (DÜZELTİLDİ)
# ------------------------------------------------------------
gui_awk_module() {
    # DÜZELTME: Menü içi ayrımı ^ yerine ! yapıldı. Sonuç ayrımı | yapıldı.
    VALS=$(yad --form \
        --title="AWK Modülü" \
        --center --width=600 \
        --image="format-indent-more" \
        --text="<span color='blue'><b>BİLGİ:</b></span> Sütun yazdırmak için 1, 2 girin. Ayıraç boşsa 'boşluk' varsayılır." \
        --field="Dosya Seç:FL" "" \
        --field="İşlem Tipi:CB" "Sütun Yazdır (print \$N)!İçerik Ara (Filtrele)" \
        --field="Değer (Sütun No veya Aranacak):" "" \
        --field="Ayıraç (Opsiyonel):" "" \
        --separator="|")

    if [ -z "$VALS" ]; then return; fi

    # Değişkenleri | ile ayırarak çekiyoruz
    FILE=$(echo "$VALS" | awk -F'|' '{print $1}')
    TYPE=$(echo "$VALS" | awk -F'|' '{print $2}')
    VAL=$(echo "$VALS" | awk -F'|' '{print $3}')
    DELIM=$(echo "$VALS" | awk -F'|' '{print $4}')

    if [ ! -f "$FILE" ]; then show_error "Dosya seçilmedi!"; return; fi
    if [ -z "$VAL" ]; then show_error "Değer alanı boş olamaz!"; return; fi

    CLEAN_VAL=$(echo "$VAL" | tr -d '[:space:]')

    # HATA AYIKLAMA İÇİN: TYPE değişkeninin ne geldiğini kontrol ediyoruz.
    # Eğer "Sütun Yazdır" seçiliyse işlem yap
    if [[ "$TYPE" == *"Sütun Yazdır"* ]]; then
        if ! [[ "$CLEAN_VAL" =~ ^[0-9]+$ ]]; then 
            show_error "HATA: Sütun yazdırmak için sayı girmelisiniz!\nGirdiğiniz değer: '$VAL'" 
            return
        fi

        if [ -z "$DELIM" ]; then 
            awk -v col="$CLEAN_VAL" '{print $col}' "$FILE" > "$TEMP_OUT"
        else 
            awk -F"$DELIM" -v col="$CLEAN_VAL" '{print $col}' "$FILE" > "$TEMP_OUT"
        fi
    else
        # İçerik Ara
        awk -v pat="$VAL" '$0 ~ pat' "$FILE" > "$TEMP_OUT"
    fi

    if [ ! -s "$TEMP_OUT" ]; then
        echo "Sonuç bulunamadı veya dosya boş." > "$TEMP_OUT"
    fi

    yad --text-info --title="AWK Raporu" --width=600 --height=500 --filename="$TEMP_OUT" --button="Kapat:0"
}

# ------------------------------------------------------------
# 3. TUI (WHIPTAIL) MODÜLLERİ (AYNI KALDI)
# ------------------------------------------------------------
tui_sed_module() {
    FILE=$(whiptail --inputbox "Dosya Yolu:" 10 60 $(pwd) 3>&1 1>&2 2>&3)
    [ ! -f "$FILE" ] && return
    ACT=$(whiptail --menu "SED İşlemleri" 15 60 3 "1" "Metin Değiştir" "2" "Satır Sil" "3" "Satır Değiştir" 3>&1 1>&2 2>&3)
    case $ACT in
        1)
            OLD=$(whiptail --inputbox "Aranan:" 10 60 3>&1 1>&2 2>&3)
            NEW=$(whiptail --inputbox "Yeni:" 10 60 3>&1 1>&2 2>&3)
            sed "s~$OLD~$NEW~g" "$FILE" > "$TEMP_OUT" ;;
        2)
            LN=$(whiptail --inputbox "Silinecek Satır No:" 10 60 3>&1 1>&2 2>&3)
            sed "${LN}d" "$FILE" > "$TEMP_OUT" ;;
        3)
            LN=$(whiptail --inputbox "Değişecek Satır No:" 10 60 3>&1 1>&2 2>&3)
            NEW=$(whiptail --inputbox "Yeni Satır İçeriği:" 10 60 3>&1 1>&2 2>&3)
            sed "${LN}c${NEW}" "$FILE" > "$TEMP_OUT" ;;
    esac
    whiptail --textbox "$TEMP_OUT" 20 80
    if (whiptail --yesno "Kaydet?" 10 60); then cp "$TEMP_OUT" "$FILE"; fi
}

tui_awk_module() {
    FILE=$(whiptail --inputbox "Dosya Yolu:" 10 60 $(pwd) 3>&1 1>&2 2>&3)
    [ ! -f "$FILE" ] && return
    COL=$(whiptail --inputbox "Sütun No:" 10 60 3>&1 1>&2 2>&3)
    CLEAN_COL=$(echo "$COL" | tr -d '[:space:]')
    awk -v c="$CLEAN_COL" '{print $c}' "$FILE" > "$TEMP_OUT"
    whiptail --textbox "$TEMP_OUT" 20 80
}

# ------------------------------------------------------------
# ANA AKIŞ
# ------------------------------------------------------------
MODE=$(whiptail --menu "Arayüz Seçimi (v4.3)" 12 50 2 "1" "GUI (Yad)" "2" "TUI (Terminal)" 3>&1 1>&2 2>&3)
[ $? -ne 0 ] && exit 0

if [ "$MODE" == "1" ]; then
    # Ana menüde de ayrımı düzelttik
    ACT=$(yad --list --title="Ana Menü" --column="Modül" --column="Açıklama" \
          --width=500 --height=300 \
          --print-column=1 --separator="" "SED" "Düzenle" "AWK" "Raporla")
    [[ "$ACT" == "SED" ]] && gui_sed_module
    [[ "$ACT" == "AWK" ]] && gui_awk_module
else
    ACT=$(whiptail --menu "Ana Menü" 15 60 2 "1" "SED" "2" "AWK" 3>&1 1>&2 2>&3)
    case $ACT in 1) tui_sed_module ;; 2) tui_awk_module ;; esac
fi
