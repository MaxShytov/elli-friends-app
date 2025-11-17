#!/bin/bash

# Script to run Flutter web app with Chrome
# Handles common DDS issues and supports Russian locale

echo "🧹 Cleaning up old processes..."
pkill -f "dart" 2>/dev/null || true
pkill -f "flutter" 2>/dev/null || true
lsof -ti:8080,9100,9200,9300 2>/dev/null | xargs kill -9 2>/dev/null || true
sleep 1

echo "🧼 Cleaning Flutter build cache..."
flutter clean > /dev/null 2>&1

echo "📦 Getting dependencies..."
flutter pub get > /dev/null 2>&1

echo "🌍 Generating localization files..."
flutter gen-l10n > /dev/null 2>&1

echo "🌐 Starting Flutter web app on Chrome..."
echo "📍 App will be available at: http://localhost:8080"
echo ""
echo "💡 Поддерживаемые языки:"
echo "   - English (en)"
echo "   - Русский (ru) ✅"
echo "   - Français (fr)"
echo "   - Deutsch (de)"
echo "   - Italiano (it)"
echo ""
echo "⚠️  Для работы TTS на Chrome:"
echo "   1. Кликните на странице перед началом урока"
echo "   2. Убедитесь, что звук разрешен в браузере"
echo ""

# Run in release mode to avoid DDS issues
flutter run -d chrome --release

echo ""
echo "✅ App closed"
