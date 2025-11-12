# 📋 ملخص أوامر التشغيل - نظام Enterprise RAG

## 🚀 خطوات البدء السريع

### الخطوة الأولى: تجهيز المجلد
```bash
cd /path/to/vanand49d48x-rag
```

### الخطوة الثانية: تشغيل سريع (موصى به)
```bash
# الطريقة الأولى: استخدام السكريبت السريع
chmod +x QUICK_START.sh
./QUICK_START.sh

# الطريقة الثانية: استخدام البدء المحسّن
chmod +x start_enhanced.sh
./start_enhanced.sh
```

### الخطوة الثالثة: الوصول للواجهات
```
http://localhost:8000/dashboard       # لوحة التحكم
http://localhost:8000/enhanced-upload # واجهة الرفع
http://localhost:8000/docs            # التوثيق التفاعلي
```

---

## 🔄 إدارة النماذج

### تنزيل نموذج محدد
```bash
# Qwen2.5 3B (موصى به)
MODEL_CONFIG=qwen25_3b ./init_model.sh

# TinyLlama (الأسرع)
MODEL_CONFIG=tinyllama ./init_model.sh

# Qwen2 7B (الأفضل)
MODEL_CONFIG=qwen2_7b ./init_model.sh
```

### تبديل النموذج
```bash
# تفاعلي
./switch_model.sh

# مباشر
./switch_model.sh qwen25_3b
./switch_model.sh tinyllama
./switch_model.sh qwen2_7b
```

### التحقق من النماذج المتاحة
```bash
ls -la models/
```

---

## 🐳 أوامر Docker الأساسية

### بدء الخدمات
```bash
# بدء جميع الخدمات
docker-compose up -d

# بدء مع التوليد البيئي
docker-compose --env-file configs/auto_generated.env up -d

# بدء خدمة معينة فقط
docker-compose up -d backend
docker-compose up -d qdrant
docker-compose up -d llama-cpp
```

### عرض حالة الخدمات
```bash
# حالة جميع الحاويات
docker-compose ps

# تفاصيل حاوية معينة
docker inspect <container_name>

# الموارد المستخدمة
docker stats
```

### عرض السجلات
```bash
# السجلات الحية (جميع الخدمات)
docker-compose logs -f

# السجلات للخدمة الأخيرة فقط
docker-compose logs --tail=50

# سجلات خدمة معينة
docker-compose logs -f backend
docker-compose logs -f llama-cpp
docker-compose logs -f qdrant

# سجلات خدمة بوقت معين
docker-compose logs --since 10m
```

### إيقاف الخدمات
```bash
# إيقاف جميع الخدمات
docker-compose down

# إيقاف مع حذف البيانات
docker-compose down -v

# إيقاف خدمة معينة
docker-compose stop backend
```

### إعادة تشغيل
```bash
# إعادة تشغيل جميع الخدمات
docker-compose restart

# إعادة تشغيل خدمة معينة
docker-compose restart backend

# بناء جديد وتشغيل
docker-compose build --no-cache && docker-compose up -d
```

---

## 🧪 الاختبار والتحقق

### اختبار الحالة الصحية
```bash
# Backend
curl http://localhost:8000/health

# Qdrant
curl http://localhost:6334/health

# LLM Server
curl http://localhost:8080/v1/models

# جميع الخدمات
curl http://localhost:8000/ && echo "✅ Backend OK"
curl http://localhost:6334/health && echo "✅ Qdrant OK"
curl http://localhost:8080/v1/models && echo "✅ LLM OK"
```

### اختبار API
```bash
# اختبار الدردشة
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "query": "مرحباً، من أنت؟",
    "context": "أنا نظام ذكاء اصطناعي"
  }'

# البحث
curl "http://localhost:8000/search?query=test"

# قائمة الملفات
curl http://localhost:8000/enhanced-upload/files
```

### تشغيل البرامج النصية للاختبار
```bash
# اختبار النماذج
python3 test_models.py

# اختبار الرفع المحسّن
python3 test_enhanced_upload.py

# اختبار لوحة التحكم
python3 test_dashboard.py
```

---

## 📊 مراقبة الأداء

### عرض Prometheus
```
http://localhost:9090
```

### عرض Grafana
```
http://localhost:3000
المستخدم: admin
كلمة المرور: admin
```

### مراقبة الموارد
```bash
# مراقبة استخدام CPU و Memory
docker stats

# معلومات تفصيلية عن الحاوية
docker inspect <container_name> | grep -A 20 "Resources"

# استهلاك الذاكرة في الوقت الفعلي
watch docker stats
```

---

## 🔐 إدارة البيانات

### قائمة الملفات المرفوعة
```bash
# عبر API
curl http://localhost:8000/enhanced-upload/files

# من النظام
ls -la data/uploads/
```

### حذف الملفات
```bash
# حذف ملف واحد (file_id)
curl -X DELETE http://localhost:8000/enhanced-upload/files/FILE_ID

# حذف ملفات متعددة
curl -X DELETE http://localhost:8000/enhanced-upload/files/batch \
  -H "Content-Type: application/json" \
  -d '["FILE_ID_1", "FILE_ID_2"]'

# حذف يدوي من النظام
rm -rf data/uploads/*
rm -rf data/processed/*
```

### النسخ الاحتياطية
```bash
# نسخ احتياطية من Qdrant
docker exec qdrant tar czf /tmp/qdrant_backup.tar.gz /qdrant/storage/
docker cp qdrant:/tmp/qdrant_backup.tar.gz ./backups/

# نسخ احتياطية من البيانات
tar czf backups/data_backup.tar.gz data/
```

---

## 🛠️ استكشاف الأخطاء الشائعة

### المشكلة: "Port 8000 is already in use"
```bash
# البحث عن العملية
lsof -i :8000

# إيقاف العملية
kill -9 <PID>

# أو استخدم منفذ مختلف
docker-compose -p myapp up -d
```

### المشكلة: "Docker daemon is not running"
```bash
# Linux
sudo systemctl start docker

# macOS
open /Applications/Docker.app

# Windows
start "Docker Desktop"
```

### المشكلة: "Insufficient memory"
```bash
# زيادة ذاكرة Docker (من الإعدادات)
# أو استخدم نموذج أصغر
./switch_model.sh tinyllama

# تقليل حجم الدفعة في config.yaml
```

### المشكلة: "Model download failed"
```bash
# تنزيل يدوي
curl -L -o models/qwen2.5-3b-instruct-q4_k_m.gguf \
  "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"

# التحقق من الملف
ls -lh models/
```

### المشكلة: "Qdrant connection failed"
```bash
# التحقق من صحة Qdrant
curl http://localhost:6334/health

# إعادة تشغيل Qdrant
docker-compose restart qdrant

# عرض السجلات
docker-compose logs qdrant
```

---

## 🔄 تحديث النظام

### تحديث الشيفرة
```bash
# الحصول على أحدث النسخة
git pull origin main

# إعادة بناء وتشغيل
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### تحديث الصور
```bash
# سحب أحدث الصور
docker-compose pull

# إعادة التشغيل
docker-compose up -d
```

---

## 📈 الأداء المتقدم

### توسيع الموارد
```bash
# زيادة الذاكرة المتاحة
# عدّل docker-compose.yml وأضف:
environment:
  - MEMORY_LIMIT=32g

docker-compose up -d
```

### تمكين GPU
```bash
# استخدم ملف docker-compose GPU
docker-compose -f docker-compose.gpu.yml up -d
```

### تحسين الأداء
```bash
# تشغيل سكريبت التحسين
./scripts/advanced_optimization.sh

# أو تحسين CPU محدد
./scripts/apply_cpu_optimizations.sh

# تطبيق إعدادات سريعة
./scripts/apply_fast_config.sh
```

---

## 📚 المراجع السريعة

### المنافذ الافتراضية
```
8000   - FastAPI Backend
8080   - LLM Server (llama.cpp)
6333   - Qdrant GRPC
6334   - Qdrant HTTP
1080   - TUS Upload Service
9090   - Prometheus
3000   - Grafana
```

### المجلدات المهمة
```
models/                    - النماذج
data/uploads/              - الملفات المرفوعة
data/processed/            - الملفات المعالجة
data/logs/                 - السجلات
configs/                   - الإعدادات
```

### ملفات التكوين
```
config.yaml                         - الإعدادات الرئيسية
configs/auto_generated.env          - متغيرات البيئة
docker-compose.yml                  - تكوين الحاويات
```

---

## ⚡ أوامر سريعة

```bash
# بدء سريع
./QUICK_START.sh

# بدء محسّن
./start_enhanced.sh

# اختبار شامل
python3 test_models.py

# عرض الحالة
docker-compose ps

# عرض السجلات
docker-compose logs -f

# إيقاف آمن
docker-compose down

# إعادة تشغيل كاملة
docker-compose down && docker-compose up -d
```

---

**آخر تحديث:** نوفمبر 2025
**الإصدار:** 1.0.0
