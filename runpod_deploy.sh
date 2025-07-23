#!/bin/bash

# Runpod Deployment Script for Ultra-Fast Voice Assistant
echo "🚀 Starting Runpod deployment for Ultra-Fast Voice Assistant"

# Set environment variables for Runpod
export PYTHONUNBUFFERED=1
export CUDA_VISIBLE_DEVICES=0
export RUNPOD_TCP_PORT_7860=7860

# Create logs directory
mkdir -p /tmp/logs

# Update system and install dependencies (matching commands.txt)
echo "📦 Installing system dependencies..."
apt-get update && apt-get install -y \
    libsox-dev \
    libsndfile1-dev \
    portaudio19-dev \
    ffmpeg \
    python3-dev \
    build-essential \
    git \
    wget \
    curl

# Upgrade pip
echo "🔧 Upgrading pip..."
pip install --upgrade pip

# Install PyTorch with CUDA support (matching commands.txt)
echo "🔥 Installing PyTorch with CUDA support..."
pip install torch==2.6.0 torchvision==0.21.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124

# Install other Python dependencies
echo "🐍 Installing other Python dependencies..."
pip install transformers librosa chatterbox-tts gradio numpy scipy huggingface-hub peft accelerate
pip install torch-audiomentations silero-vad aiortc websockets aiohttp aiofiles soundfile webrtcvad pyaudio uvloop

# Pre-download models to avoid cold start delays
echo "📥 Pre-downloading models..."
python3 -c "
import torch
import os
import sys

try:
    print('🔥 Checking CUDA availability...')
    print(f'CUDA available: {torch.cuda.is_available()}')
    if torch.cuda.is_available():
        print(f'GPU: {torch.cuda.get_device_name(0)}')
    
    print('📥 Downloading Ultravox model...')
    from transformers import pipeline
    pipeline('automatic-speech-recognition', model='fixie-ai/ultravox-v0_4', trust_remote_code=True)
    print('✅ Ultravox downloaded')

    print('📥 Downloading ChatterboxTTS model...')
    from chatterbox.tts import ChatterboxTTS
    ChatterboxTTS.from_pretrained()
    print('✅ ChatterboxTTS downloaded')

    print('📥 Downloading Silero VAD model...')
    torch.hub.load('snakers4/silero-vad', 'silero_vad', force_reload=False)
    print('✅ Silero VAD downloaded')

    print('🎉 All models pre-downloaded successfully!')
    
except Exception as e:
    print(f'❌ Model download error: {e}')
    print('⚠️ Continuing anyway...')
"

# Set proper permissions
chmod +x ultraandchat_runpod.py

echo "✅ Runpod deployment setup complete"
echo "🎯 Starting server..."