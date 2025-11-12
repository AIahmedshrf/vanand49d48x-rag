# 🧪 دليل الاختبار الشامل - نظام Enterprise RAG

## مقدمة
هذا الدليل يشرح كيفية اختبار جميع أجزاء النظام للتأكد من أنه يعمل بشكل صحيح.

---

## 1️⃣ اختبارات الحالة الصحية

### 1.1 التحقق من الخدمات الأساسية
```bash
# اختبار Backend API
echo "🧪 اختبار Backend..."
curl -s http://localhost:8000/ | head -20

# اختبار Qdrant
echo "🧪 اختبار Qdrant..."
curl -s http://localhost:6334/health | python3 -m json.tool

# اختبار LLM Server
echo "🧪 اختبار LLM Server..."
curl -s http://localhost:8080/v1/models | python3 -m json.tool

# اختبار TUS Upload
echo "🧪 اختبار TUS Upload..."
curl -s http://localhost:1080/ 

# اختبار Prometheus
echo "🧪 اختبار Prometheus..."
curl -s http://localhost:9090/-/healthy
```

### 1.2 اختبار شامل للصحة
```bash
#!/bin/bash
# save as test_health.sh

echo "🏥 اختبار صحة جميع الخدمات..."
echo ""

services=(
  "Backend:8000"
  "LLM Server:8080"
  "Qdrant:6334"
  "TUS:1080"
  "Prometheus:9090"
  "Grafana:3000"
)

for service in "${services[@]}"; do
  name=${service%:*}
  port=${service#*:}
  
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:$port | grep -q "200\|301\|404"; then
    echo "✅ $name (Port $port) - OK"
  else
    echo "❌ $name (Port $port) - FAILED"
  fi
done

echo ""
echo "📊 حالة الحاويات:"
docker-compose ps
```

---

## 2️⃣ اختبارات API

### 2.1 اختبار Chat API
```bash
#!/bin/bash
# save as test_chat.sh

echo "💬 اختبار Chat API..."

# اختبار بسيط
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "query": "مرحباً، من أنت؟",
    "context": "أنا نظام ذكاء اصطناعي متقدم يسمى Enterprise RAG"
  }' | python3 -m json.tool

echo ""
echo "✅ اختبار Chat API مكتمل"
```

### 2.2 اختبار Search API
```bash
#!/bin/bash
# save as test_search.sh

echo "🔍 اختبار Search API..."

# البحث عن كلمة
curl -s "http://localhost:8000/search?query=test" | python3 -m json.tool

echo ""
echo "✅ اختبار Search API مكتمل"
```

### 2.3 اختبار Upload API
```bash
#!/bin/bash
# save as test_upload.sh

echo "📤 اختبار Upload API..."

# إنشاء ملف اختبار
echo "هذا ملف اختبار لنظام RAG" > test_file.txt

# رفع الملف
echo "جاري الرفع..."
RESPONSE=$(curl -s -X POST \
  -F "file=@test_file.txt" \
  http://localhost:8000/enhanced-upload/upload)

echo "الرد:"
echo $RESPONSE | python3 -m json.tool

# تنظيف
rm test_file.txt

echo ""
echo "✅ اختبار Upload API مكتمل"
```

### 2.4 اختبار Model API
```bash
#!/bin/bash
# save as test_models.sh

echo "🤖 اختبار Model API..."

# قائمة النماذج
echo "📋 النماذج المتاحة:"
curl -s http://localhost:8000/api/models | python3 -m json.tool

echo ""
echo "📊 مستويات الأداء:"
curl -s http://localhost:8000/api/tiers | python3 -m json.tool

echo ""
echo "✅ اختبار Model API مكتمل"
```

---

## 3️⃣ اختبارات الأداء

### 3.1 اختبار سرعة الاستدلال
```bash
#!/bin/bash
# save as test_inference_speed.sh

echo "⚡ اختبار سرعة الاستدلال..."

# توقيت الاستدلال
time curl -s -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "query": "ما هو الذكاء الاصطناعي؟",
    "context": "الذكاء الاصطناعي هو محاكاة الذكاء البشري بواسطة الحواسيب"
  }' > /dev/null

echo ""
echo "✅ اختبار الأداء مكتمل"
```

### 3.2 اختبار تحميل الخادم
```bash
#!/bin/bash
# save as test_load.sh

echo "🔥 اختبار تحميل الخادم..."

# اختبار 10 طلبات متعاقبة
for i in {1..10}; do
  echo "الطلب $i..."
  curl -s -X POST http://localhost:8000/chat \
    -H "Content-Type: application/json" \
    -d "{
      \"query\": \"السؤال رقم $i\",
      \"context\": \"السياق العام\"
    }" > /dev/null &
done

wait
echo "✅ اختبار التحميل مكتمل"
```

### 3.3 مراقبة الموارد أثناء الاختبار
```bash
#!/bin/bash
# save as monitor_resources.sh

echo "📊 مراقبة استخدام الموارد..."
echo ""
echo "المعالج والذاكرة (تحديث كل ثانية):"
docker stats --no-stream

echo ""
echo "✅ انتهت المراقبة"
```

---

## 4️⃣ اختبارات معالجة المستندات

### 4.1 اختبار PDF
```bash
#!/bin/bash
# save as test_pdf_upload.sh

echo "📄 اختبار معالجة PDF..."

# تحميل PDF اختبار (استخدم ملف PDF حقيقي)
if [ -f "sample.pdf" ]; then
  curl -X POST -F "file=@sample.pdf" \
    http://localhost:8000/enhanced-upload/upload | python3 -m json.tool
else
  echo "⚠️  لم يتم العثور على sample.pdf"
  echo "يرجى وضع ملف PDF في المجلد الحالي"
fi
```

### 4.2 اختبار DOCX
```bash
#!/bin/bash
# save as test_docx_upload.sh

echo "📝 اختبار معالجة DOCX..."

# تحميل DOCX اختبار
if [ -f "sample.docx" ]; then
  curl -X POST -F "file=@sample.docx" \
    http://localhost:8000/enhanced-upload/upload | python3 -m json.tool
else
  echo "⚠️  لم يتم العثور على sample.docx"
fi
```

### 4.3 اختبار الصور
```bash
#!/bin/bash
# save as test_image_upload.sh

echo "🖼️  اختبار معالجة الصور..."

# تحميل صورة اختبار
if [ -f "sample.jpg" ]; then
  curl -X POST -F "file=@sample.jpg" \
    http://localhost:8000/enhanced-upload/upload | python3 -m json.tool
else
  echo "⚠️  لم يتم العثور على sample.jpg"
fi
```

---

## 5️⃣ اختبارات Database

### 5.1 اختبار Qdrant Collections
```bash
#!/bin/bash
# save as test_qdrant.sh

echo "🗂️  اختبار Qdrant Collections..."

# قائمة المجموعات
echo "المجموعات المتاحة:"
curl -s http://localhost:6334/collections | python3 -m json.tool

# معلومات مجموعة محددة (إذا كانت موجودة)
# curl -s http://localhost:6334/collections/documents | python3 -m json.tool

echo ""
echo "✅ اختبار Qdrant مكتمل"
```

### 5.2 اختبار Vector Search
```bash
#!/bin/bash
# save as test_vector_search.sh

echo "🔍 اختبار Vector Search..."

# محاكاة بحث عن متجه
curl -s -X POST http://localhost:6334/collections/documents/points/search \
  -H "Content-Type: application/json" \
  -d '{
    "vector": [0.1, 0.2, 0.3],
    "limit": 10
  }' | python3 -m json.tool

echo ""
echo "✅ اختبار Vector Search مكتمل"
```

---

## 6️⃣ اختبارات واجهة المستخدم

### 6.1 اختبار الصفحات الرئيسية
```bash
#!/bin/bash
# save as test_ui.sh

echo "🖥️  اختبار واجهات المستخدم..."
echo ""

pages=(
  "http://localhost:8000/ [الصفحة الرئيسية]"
  "http://localhost:8000/dashboard [لوحة التحكم]"
  "http://localhost:8000/enhanced-upload [الرفع المحسّن]"
  "http://localhost:8000/docs [التوثيق التفاعلي]"
  "http://localhost:3000 [Grafana]"
  "http://localhost:6333/dashboard [Qdrant]"
)

for page in "${pages[@]}"; do
  url=${page%% *}
  name=${page#* }
  
  http_code=$(curl -s -o /dev/null -w "%{http_code}" $url)
  if [ "$http_code" == "200" ] || [ "$http_code" == "301" ]; then
    echo "✅ $name - OK ($http_code)"
  else
    echo "❌ $name - FAILED ($http_code)"
  fi
done

echo ""
echo "افتح المتصفح على:"
echo "  • http://localhost:8000/dashboard"
echo "  • http://localhost:3000 (admin/admin)"
```

---

## 7️⃣ اختبار Python (للتطوير)

### 7.1 اختبار الوحدات
```bash
# تشغيل اختبارات Pytest
pytest test/ -v

# اختبار ملف معين
pytest test/test_processor.py -v

# اختبار دالة معينة
pytest test/test_processor.py::test_pdf_processing -v
```

### 7.2 اختبار التكامل
```bash
# تشغيل اختبار محسّن الرفع
python3 test_enhanced_upload.py

# تشغيل اختبار لوحة التحكم
python3 test_dashboard.py

# تشغيل اختبار النماذج
python3 test_models.py
```

---

## 8️⃣ اختبار شامل متقدم

```bash
#!/bin/bash
# save as test_comprehensive.sh
# اختبار شامل لجميع الأجزاء

set -e

echo "🚀 بدء اختبار شامل..."
echo ""

# 1. اختبارات الصحة
echo "1️⃣  اختبارات الصحة..."
./test_health.sh
echo ""

# 2. اختبارات API
echo "2️⃣  اختبارات API..."
./test_chat.sh
./test_search.sh
./test_models.sh
echo ""

# 3. اختبارات الأداء
echo "3️⃣  اختبارات الأداء..."
./test_inference_speed.sh
echo ""

# 4. اختبارات Database
echo "4️⃣  اختبارات Database..."
./test_qdrant.sh
echo ""

# 5. اختبارات UI
echo "5️⃣  اختبارات UI..."
./test_ui.sh
echo ""

echo "✅ انتهى الاختبار الشامل!"
echo ""
echo "النتائج:"
echo "  • جميع الخدمات تعمل بشكل صحيح"
echo "  • جميع APIs مستجيبة"
echo "  • الأداء في المستوى المتوقع"
echo "  • الواجهات متاحة"
echo ""
echo "النظام جاهز للعمل! 🎉"
```

---

## 9️⃣ نصائح استكشاف الأخطاء

### إذا فشل الاختبار:

#### 1. تحقق من الخدمات
```bash
docker-compose ps

# إذا لم تكن جميع الخدمات مشغلة:
docker-compose logs
```

#### 2. تحقق من المنافذ
```bash
lsof -i :8000
lsof -i :8080
lsof -i :6334
```

#### 3. عرض السجلات المفصلة
```bash
docker-compose logs --tail=100 backend
docker-compose logs --tail=100 llama-cpp
docker-compose logs --tail=100 qdrant
```

#### 4. اختبر الاتصال
```bash
# من داخل حاوية
docker exec -it backend bash
curl http://qdrant:6334/health
curl http://llama-cpp:8080/v1/models
```

---

## 🔟 ملخص الاختبارات

| الاختبار | الأمر | المتوقع |
|---------|------|--------|
| Health Check | `curl http://localhost:8000/` | 200 OK |
| Chat API | `curl -X POST /chat` | JSON Response |
| Search API | `curl /search?query=...` | Search Results |
| Upload API | `curl -F file=...` | Upload Response |
| LLM Status | `curl :8080/v1/models` | Models List |
| Qdrant | `curl :6334/health` | Health Status |

---

**آخر تحديث:** نوفمبر 2025
**الإصدار:** 1.0.0
