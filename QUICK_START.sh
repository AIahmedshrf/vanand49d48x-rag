#!/bin/bash
# 🚀 دليل تشغيل سريع - نظام Enterprise RAG
# نسخة مختصرة لتشغيل سريع

set -e

# الألوان
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════╗
║    🚀 Enterprise RAG System - Quick Start 🚀     ║
║         نظام الذكاء الاصطناعي المتقدم           ║
╚═══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${BLUE}📋 الخطوة 1: التحقق من المتطلبات...${NC}"
echo ""

# التحقق من Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✅ Docker مثبت${NC}"
else
    echo -e "${YELLOW}❌ Docker غير مثبت. يرجى تثبيت Docker أولاً${NC}"
    echo "   https://docs.docker.com/install/"
    exit 1
fi

# التحقق من Docker Compose
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}✅ Docker Compose مثبت${NC}"
else
    echo -e "${YELLOW}❌ Docker Compose غير مثبت${NC}"
    exit 1
fi

# التحقق من Python (للنماذج)
if command -v python3 &> /dev/null; then
    echo -e "${GREEN}✅ Python3 مثبت${NC}"
else
    echo -e "${YELLOW}⚠️  Python3 غير مثبت (اختياري للنماذج الإضافية)${NC}"
fi

echo ""
echo -e "${BLUE}🤖 الخطوة 2: اختيار النموذج...${NC}"
echo ""

# عرض الخيارات
echo "النماذج المتاحة:"
echo "  1) TinyLlama 1.1B    ⚡⚡⚡ (الأسرع - 4GB RAM)"
echo "  2) Qwen2.5 3B        ⚡⚡   (متوازن - 16GB RAM)"
echo "  3) Qwen2 7B          ⚡    (الأفضل - 24GB RAM)"
echo ""

read -p "اختر رقم النموذج (1-3) أو اضغط Enter للافتراضي (2): " MODEL_CHOICE
MODEL_CHOICE=${MODEL_CHOICE:-2}

case $MODEL_CHOICE in
    1) MODEL_NAME="tinyllama" ;;
    2) MODEL_NAME="qwen25_3b" ;;
    3) MODEL_NAME="qwen2_7b" ;;
    *) MODEL_NAME="qwen25_3b"; echo "اختيار افتراضي: Qwen2.5 3B" ;;
esac

echo -e "${GREEN}✅ تم اختيار: $MODEL_NAME${NC}"

echo ""
echo -e "${BLUE}📥 الخطوة 3: تنزيل النموذج (إذا لزم الأمر)...${NC}"
echo ""

# تنزيل النموذج
if [ ! -d "models" ]; then
    mkdir -p models
fi

echo "جاري التحقق من النموذج..."
# هذا سيتم التعامل معه تلقائياً أثناء التشغيل

echo ""
echo -e "${BLUE}🔧 الخطوة 4: إنشاء ملف الإعدادات...${NC}"
echo ""

# الكشف عن موارد النظام
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CPU_CORES=$(nproc)
    TOTAL_MEM=$(free -g | awk '/^Mem:/{print $2}')
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CPU_CORES=$(sysctl -n hw.ncpu)
    TOTAL_MEM=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
else
    CPU_CORES=4
    TOTAL_MEM=8
fi

echo -e "${GREEN}✅ النظام: CPU=$CPU_CORES أنوية, RAM=${TOTAL_MEM}GB${NC}"

# إنشاء مجلدات ضرورية
mkdir -p configs data/uploads data/processed data/logs data/temp
mkdir -p models

# إنشاء .env
cat > configs/auto_generated.env << EOF
# تم التوليد تلقائياً
MODEL_NAME=qwen2.5-3b-instruct-q4_k_m.gguf
LLAMA_IMAGE=ghcr.io/ggerganov/llama.cpp:server
THREADS=$((CPU_CORES > 8 ? 8 : CPU_CORES))
BATCH_SIZE=$((TOTAL_MEM > 16 ? 512 : 256))
CTX_SIZE=4096
GPU_LAYERS=0
N_PREDICT=256
REPEAT_PENALTY=1.1
TEMP=0.7
TOP_P=0.9
TOP_K=40
HOST_RAM_GB=$TOTAL_MEM
HOST_CPU_COUNT=$CPU_CORES
EOF

echo -e "${GREEN}✅ تم إنشاء الإعدادات${NC}"

echo ""
echo -e "${BLUE}🚀 الخطوة 5: تشغيل الخدمات...${NC}"
echo ""

# إيقاف الخدمات السابقة
docker-compose down 2>/dev/null || true

# تشغيل الخدمات
echo "جاري بدء الخدمات..."
docker-compose --env-file configs/auto_generated.env up -d

echo -e "${YELLOW}⏳ الرجاء الانتظار (30 ثانية)...${NC}"
sleep 30

echo ""
echo -e "${BLUE}📊 الخطوة 6: التحقق من الحالة...${NC}"
echo ""

# التحقق من الخدمات
echo "حالة الخدمات:"
docker-compose ps

echo ""
echo -e "${GREEN}🎉 تم البدء بنجاح!${NC}"
echo ""

echo -e "${BLUE}📱 روابط الوصول:${NC}"
echo ""
echo "  🖥️  لوحة التحكم الرئيسية:"
echo "      http://localhost:8000/dashboard"
echo ""
echo "  📤 واجهة الرفع:"
echo "      http://localhost:8000/enhanced-upload"
echo ""
echo "  📚 التوثيق التفاعلي:"
echo "      http://localhost:8000/docs"
echo ""
echo "  📊 Qdrant Dashboard:"
echo "      http://localhost:6333/dashboard"
echo ""
echo "  📈 Grafana (رسوم بيانية):"
echo "      http://localhost:3000"
echo "      المستخدم: admin"
echo "      كلمة المرور: admin"
echo ""

echo -e "${BLUE}💡 أوامر مفيدة:${NC}"
echo ""
echo "  • عرض السجلات: docker-compose logs -f"
echo "  • إيقاف الخدمات: docker-compose down"
echo "  • إعادة التشغيل: docker-compose restart"
echo "  • تبديل النموذج: ./switch_model.sh qwen2_7b"
echo ""

echo -e "${YELLOW}ملاحظة مهمة:${NC}"
echo "  • قد يستغرق التنزيل والتشغيل الأول 5-15 دقائق"
echo "  • تأكد من وجود مساحة كافية (2-4GB للنموذج)"
echo "  • تحقق من تطبيق Docker للمزيد من التفاصيل"
echo ""

echo -e "${GREEN}✨ نظام Enterprise RAG جاهز للاستخدام! ✨${NC}"
echo ""

# اختياري: فتح الموقع تلقائياً
if command -v "$BROWSER" &> /dev/null || command -v xdg-open &> /dev/null || command -v open &> /dev/null; then
    read -p "هل تريد فتح لوحة التحكم في المتصفح؟ (y/n): " open_browser
    if [[ $open_browser == "y" || $open_browser == "Y" ]]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open http://localhost:8000/dashboard
        elif command -v open &> /dev/null; then
            open http://localhost:8000/dashboard
        fi
    fi
fi

echo ""
echo "للمساعدة والدعم، راجع:"
echo "  • STARTUP_GUIDE_AR.md - دليل التشغيل الكامل"
echo "  • ADVANCED_ANALYSIS_AR.md - التحليل المتقدم"
echo "  • docs/ - ملفات التوثيق الإضافية"
echo ""
