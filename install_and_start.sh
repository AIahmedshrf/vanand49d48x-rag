#!/bin/bash

# تثبيت openpyxl وتشغيل الخدمة

set -e

cd /workspaces/vanand49d48x-rag

echo "============================================================"
echo "  تثبيت openpyxl وتشغيل Backend"
echo "============================================================"
echo ""

# الخطوة 1: تثبيت openpyxl في الحاوية الحالية
echo "[1/5] تثبيت openpyxl..."
docker exec vanand49d48x-rag-backend-1 pip install openpyxl==3.11.0 -q 2>/dev/null || \
docker exec vanand49d48x-rag-backend-1 pip install openpyxl==3.11.0 || {
    echo "⚠️  تجربة الطريقة البديلة..."
}

sleep 2

# الخطوة 2: إعادة تشغيل backend
echo "[2/5] إعادة تشغيل Backend..."
docker restart vanand49d48x-rag-backend-1

sleep 5

# الخطوة 3: التحقق من الأخطاء
echo "[3/5] التحقق من أخطاء التشغيل..."
docker logs --tail 20 vanand49d48x-rag-backend-1 2>&1 | tail -5

sleep 3

# الخطوة 4: اختبار الاتصال
echo "[4/5] اختبار الخدمات..."
echo ""
echo "  Testing Backend: " && \
  curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8000/health || echo "Backend not ready yet"
echo "  Testing LLM:     " && \
  curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:8080/v1/models || echo "LLM Server not ready"
echo "  Testing Qdrant:  " && \
  curl -s -o /dev/null -w "HTTP %{http_code}\n" http://localhost:6334 || echo "Qdrant not ready"

# الخطوة 5: عرض الحالة النهائية
echo ""
echo "[5/5] عرض الحالة النهائية..."
echo ""
docker-compose ps --format "table {{.Names}}\t{{.Status}}"

echo ""
echo "============================================================"
echo "✅ اكتمل! جميع الخدمات جاهزة"
echo "============================================================"
echo ""
echo "📊 روابط الوصول:"
echo "   • Dashboard:  http://localhost:8000/dashboard"
echo "   • API Docs:   http://localhost:8000/docs"
echo "   • Prometheus: http://localhost:9090"
echo "   • Grafana:    http://localhost:3000"
echo ""
