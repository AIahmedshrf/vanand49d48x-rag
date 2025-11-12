#!/bin/bash

# STATUS CHECK - Enterprise RAG System
# يرجى تشغيل هذا الملف للتحقق من حالة النظام

clear

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎯 فحص حالة نظام Enterprise RAG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd /workspaces/vanand49d48x-rag 2>/dev/null || {
    echo "❌ خطأ: لم يتمكن من الدخول للمجلد"
    exit 1
}

# التحقق من Docker
echo "📋 التحقق من المتطلبات..."
echo ""

if ! command -v docker &> /dev/null; then
    echo "❌ Docker غير مثبت"
    exit 1
fi
echo "✅ Docker متاح"

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose غير مثبت"
    exit 1
fi
echo "✅ Docker Compose متاح"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📊 حالة الخدمات"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker-compose ps 2>/dev/null || {
    echo "⚠️  لا توجد خدمات مشغلة حالياً"
    echo ""
    echo "للبدء، شغل:"
    echo "  docker-compose up -d"
    exit 0
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🧪 اختبار الاتصالات"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -n "Backend API (8000)... "
if curl -s http://localhost:8000/health > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌ (جاري التشغيل أو معطل)"
fi

echo -n "LLM Server (8080)... "
if curl -s http://localhost:8080/v1/models > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

echo -n "Qdrant (6334)... "
if curl -s http://localhost:6334 > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

echo -n "Prometheus (9090)... "
if curl -s http://localhost:9090 > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

echo -n "Grafana (3000)... "
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅"
else
    echo "❌"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  💾 استخدام الموارد"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

docker stats --no-stream 2>/dev/null || echo "⚠️  لا توجد حاويات تعمل"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📁 حالة الملفات"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check model file
if [ -f "models/qwen2.5-3b-instruct-q4_k_m.gguf" ]; then
    SIZE=$(du -h "models/qwen2.5-3b-instruct-q4_k_m.gguf" | cut -f1)
    echo "✅ نموذج Qwen2.5 3B موجود ($SIZE)"
else
    echo "❌ نموذج Qwen2.5 3B غير موجود"
fi

# Check data directories
for dir in data/uploads data/logs data/processed; do
    if [ -d "$dir" ]; then
        COUNT=$(find "$dir" -type f 2>/dev/null | wc -l)
        echo "✅ مجلد $dir موجود ($COUNT ملف)"
    fi
done

# Check Docker image
if docker images | grep -q "vanand49d48x-rag\|rag"; then
    SIZE=$(docker images | grep -E "vanand49d48x-rag|rag" | head -1 | awk '{print $7}')
    echo "✅ صورة Docker موجودة ($SIZE)"
else
    echo "❌ صورة Docker غير موجودة"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎯 الحالة الإجمالية"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Count running containers
RUNNING=$(docker-compose ps 2>/dev/null | grep -c "Up" || echo "0")
TOTAL=$(docker-compose ps 2>/dev/null | grep -c "vanand49d48x-rag" || echo "6")

echo "الخدمات المشغلة: $RUNNING/$TOTAL"

if [ "$RUNNING" -eq 6 ]; then
    echo ""
    echo "✅ النظام يعمل بشكل كامل!"
    echo ""
    echo "🌐 يمكنك الوصول إلى:"
    echo "   • Dashboard:  http://localhost:8000/dashboard"
    echo "   • API Docs:   http://localhost:8000/docs"
    echo "   • Prometheus: http://localhost:9090"
    echo "   • Grafana:    http://localhost:3000"
elif [ "$RUNNING" -gt 0 ]; then
    echo ""
    echo "⚠️  بعض الخدمات تعمل ($RUNNING/$TOTAL)"
    echo ""
    echo "للتحقق من المشاكل:"
    echo "   docker-compose logs"
elif [ "$RUNNING" -eq 0 ]; then
    echo ""
    echo "⏸️  النظام موقوف"
    echo ""
    echo "للبدء:"
    echo "   docker-compose up -d"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
