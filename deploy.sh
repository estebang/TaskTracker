#!/bin/bash

# === CONFIG ===
APP_NAME="tasktracker-$RANDOM"
RESOURCE_GROUP="tasktracker-rg"
PLAN_NAME="tasktracker-plan"
LOCATION="eastus"
PYTHON_VERSION="PYTHON:3.10"
ZIP_FILE="app.zip"
STARTUP_COMMAND="gunicorn --bind=0.0.0.0 --timeout 600 app:app"

echo "🔐 Logging into Azure..."
az login

echo "📁 Creating Resource Group: $RESOURCE_GROUP..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "📦 Creating App Service Plan: $PLAN_NAME..."
az appservice plan create \
  --name "$PLAN_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --sku B1 \
  --is-linux

echo "🚀 Creating Web App: $APP_NAME..."
az webapp create \
  --resource-group "$RESOURCE_GROUP" \
  --plan "$PLAN_NAME" \
  --name "$APP_NAME" \
  --runtime "$PYTHON_VERSION"

echo "⚙️ Setting Startup Command..."
az webapp config set \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_NAME" \
  --startup-file "$STARTUP_COMMAND"

echo "📦 Zipping application (excluding venv and __pycache__)..."
zip -r "$ZIP_FILE" . -x "venv/*" "__pycache__/*"

echo "📤 Deploying to Azure..."
az webapp deployment source config-zip \
  --resource-group "$RESOURCE_GROUP" \
  --name "$APP_NAME" \
  --src "$ZIP_FILE"

echo "🌐 App deployed! Visit it at:"
echo "https://$APP_NAME.azurewebsites.net"
