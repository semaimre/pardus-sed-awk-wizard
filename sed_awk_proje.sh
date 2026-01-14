#!/bin/bash


TEMP_OUT="/tmp/proje_preview.txt"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

cleanup() { rm -f "$TEMP_OUT"; }
trap cleanup EXIT

check_dependencies() {
    if ! command -v yad &> /dev/null; then
        echo -e "${RED}[HATA]${NC} 'yad' paketi yüklü değil. (sudo apt install yad)"
        exit 1
    fi
}

print_header() {
    clear
    echo -e "${BLUE}=================================================${NC}"
    echo -e "${BOLD}   PARDUS SED & AWK WIZARD (v5.0) ${NC}"
    echo -e "${BLUE}=================================================${NC}"
    echo ""
}

print_status() {
    if [ "$1" == "ok" ]; then
        echo -e "${GREEN}[BAŞARILI]${NC} $2"
    else
        echo -e "${RED}[HATA]${NC} $2"
    fi
}

gui_sed_module() {
    VALS=$(yad --form --title="SED Modülü" --center --width=600 \
        --field="Dosya Seç:FL" "" \
        --field="İşlem:CB" "Metin Değiştir!Satır Sil!Satır Değiştir" \
        --field="Aranan/Satır No:" "" --field="Yeni Metin:" "" --separator="|")
    [ -z "$VALS" ] && return
    
    FILE=$(echo "$VALS" | awk -F'|' '{print $1}')
    TYPE=$(echo "$VALS" | awk -F'|' '{print $2}')
    P1=$(echo "$VALS" | awk -F'|' '{print $3}')
    P2=$(echo "$VALS" | awk -F'|' '{print $4}')
    CLN_P1=$(echo "$P1" | tr -d '[:space:]')

    [ ! -f "$FILE" ] && return
    
    if [[ "$TYPE" == *"Metin Değiştir"* ]]; then
        sed "s~$P1~$P2~g" "$FILE" > "$TEMP_OUT"
    elif [[ "$TYPE" == *"Satır Sil"* ]]; then
        sed "${CLN_P1}d" "$FILE" > "$TEMP_OUT"
    elif [[ "$TYPE" == *"Satır Değiştir"* ]]; then
        sed "${CLN_P1}c${P2}" "$FILE" > "$TEMP_OUT"
    fi

    yad --text-info --filename="$TEMP_OUT" --width=600 --height=500 --button="İptal:1" --button="KAYDET:0"
    if [ $? -eq 0 ]; then cp "$TEMP_OUT" "$FILE"; yad --info --text="Kaydedildi!" --button="Tamam:0"; fi
}

gui_awk_module() {
    VALS=$(yad --form --title="AWK Modülü" --center --width=600 \
        --field="Dosya Seç:FL" "" --field="İşlem:CB" "Sütun Yazdır!İçerik Ara" \
        --field="Değer:" "" --field="Ayıraç:" "" --separator="|")
    [ -z "$VALS" ] && return
    
    FILE=$(echo "$VALS" | awk -F'|' '{print $1}')
    TYPE=$(echo "$VALS" | awk -F'|' '{print $2}')
    VAL=$(echo "$VALS" | awk -F'|' '{print $3}')
    DEL=$(echo "$VALS" | awk -F'|' '{print $4}')
    CLN_VAL=$(echo "$VAL" | tr -d '[:space:]')
    
    [ ! -f "$FILE" ] && return

    if [[ "$TYPE" == *"Sütun Yazdır"* ]]; then
        if [ -z "$DEL" ]; then awk -v c="$CLN_VAL" '{print $c}' "$FILE" > "$TEMP_OUT"
        else awk -F"$DEL" -v c="$CLN_VAL" '{print $c}' "$FILE" > "$TEMP_OUT"; fi
    else
        awk -v p="$VAL" '$0 ~ p' "$FILE" > "$TEMP_OUT"
    fi
    yad --text-info --filename="$TEMP_OUT" --width=600 --height=500 --button="Kapat:0"
}


tui_sed_module() {
    print_header
    echo -e "${CYAN}:: SED MODÜLÜ (Metin Düzenleme)${NC}"
    echo "---------------------------------"
    
    read -e -p "📂 İşlenecek dosya yolu: " FILE
    if [ ! -f "$FILE" ]; then print_status "err" "Dosya bulunamadı!"; sleep 2; return; fi
    if [ ! -w "$FILE" ]; then print_status "err" "Yazma izniniz yok!"; sleep 2; return; fi

    echo ""
    echo "1) Metin Değiştir (Bul -> Değiştir)"
    echo "2) Satır Sil (Satır No ile)"
    echo "3) Satır Değiştir (Satır No ile)"
    echo ""
    read -p "👉 Seçiminiz [1-3]: " ACT

    case $ACT in
        1)
            read -p "🔍 Aranan Kelime: " OLD
            read -p "✏️  Yeni Kelime: " NEW
            sed "s~$OLD~$NEW~g" "$FILE" > "$TEMP_OUT"
            MSG="Metin değiştirildi."
            ;;
        2)
            read -p "❌ Silinecek Satır No: " LN
            # Temizlik
            LN=$(echo "$LN" | tr -d '[:space:]')
            sed "${LN}d" "$FILE" > "$TEMP_OUT"
            MSG="$LN. satır silindi."
            ;;
        3)
            read -p "🔄 Değişecek Satır No: " LN
            read -p "✏️  Yeni Satır İçeriği: " NEW
            LN=$(echo "$LN" | tr -d '[:space:]')
            sed "${LN}c${NEW}" "$FILE" > "$TEMP_OUT"
            MSG="$LN. satır değiştirildi."
            ;;
        *)
            print_status "err" "Geçersiz seçim."; sleep 1; return ;;
    esac

    echo ""
    echo -e "${YELLOW}--- ÖNİZLEME (İlk 10 Satır) ---${NC}"
    head -n 10 "$TEMP_OUT"
    echo -e "${YELLOW}-------------------------------${NC}"
    echo ""

    read -p "💾 Değişiklikler bu dosyaya kaydedilsin mi? (e/h): " CONFIRM
    if [[ "$CONFIRM" == "e" || "$CONFIRM" == "E" ]]; then
        cp "$TEMP_OUT" "$FILE"
        print_status "ok" "Dosya başarıyla güncellendi!"
    else
        print_status "err" "İşlem iptal edildi."
    fi
    read -p "Ana menü için Enter'a bas..."
}

tui_awk_module() {
    print_header
    echo -e "${CYAN}:: AWK MODÜLÜ (Raporlama & Süzme)${NC}"
    echo "---------------------------------"

    read -e -p "📂 İşlenecek dosya yolu: " FILE
    if [ ! -f "$FILE" ]; then print_status "err" "Dosya bulunamadı!"; sleep 2; return; fi

    echo ""
    echo "1) Sütun Yazdır (Örn: Sadece isimleri çek)"
    echo "2) İçerik Ara/Filtrele"
    echo ""
    read -p "👉 Seçiminiz [1-2]: " ACT

    case $ACT in
        1)
            read -p "📊 Sütun Numarası (1, 2...): " COL
            read -p "✂️  Ayıraç (Boşluk için Enter'a bas): " DEL
            COL=$(echo "$COL" | tr -d '[:space:]')
            
            if [ -z "$DEL" ]; then
                awk -v c="$COL" '{print $c}' "$FILE" > "$TEMP_OUT"
            else
                awk -F"$DEL" -v c="$COL" '{print $c}' "$FILE" > "$TEMP_OUT"
            fi
            ;;
        2)
            read -p "🔍 Aranacak Kelime/Regex: " PAT
            awk -v p="$PAT" '$0 ~ p' "$FILE" > "$TEMP_OUT"
            ;;
        *)
            return ;;
    esac

    echo ""
    echo -e "${YELLOW}--- SONUÇLAR (Tümü Gösteriliyor) ---${NC}"
   
    LINES=$(wc -l < "$TEMP_OUT")
    if [ "$LINES" -gt 20 ]; then
        less "$TEMP_OUT"
    else
        cat "$TEMP_OUT"
    fi
    echo ""
    read -p "Ana menü için Enter'a bas..."
}

check_dependencies

while true; do
    print_header
    echo -e "Hangi arayüzü kullanmak istersiniz?"
    echo ""
    echo -e "  ${GREEN}1)${NC} Grafik Arayüz (GUI - Yad)"
    echo -e "  ${YELLOW}2)${NC} Terminal Arayüzü (CLI - Pure Bash)"
    echo -e "  ${RED}3)${NC} Çıkış"
    echo ""
    read -p "Seçiminiz: " MAIN_CHOICE

    case $MAIN_CHOICE in
        1)
            # GUI Modu
            ACTION=$(yad --list --title="Ana Menü" --column="Modül" --column="Açıklama" \
                --width=500 --height=300 --print-column=1 --separator="" \
                "SED" "Düzenle" "AWK" "Raporla")
            [[ "$ACTION" == "SED" ]] && gui_sed_module
            [[ "$ACTION" == "AWK" ]] && gui_awk_module
            ;;
        2)
            # CLI Modu (Döngüye sokuyoruz ki işlem bitince menüye dönsün)
            while true; do
                print_header
                echo -e "${YELLOW}[ TERMINAL MODU ]${NC}"
                echo "1) SED Modülü (Düzenle)"
                echo "2) AWK Modülü (Raporla)"
                echo "3) < Geri Dön"
                echo ""
                read -p "Seçiminiz: " CLI_CHOICE
                case $CLI_CHOICE in
                    1) tui_sed_module ;;
                    2) tui_awk_module ;;
                    3) break ;;
                    *) ;;
                esac
            done
            ;;
        3)
            echo "Güle güle..."
            exit 0
            ;;
        *)
            ;;
    esac
done
