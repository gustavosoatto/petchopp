FROM debian:bookworm-slim
SHELL ["/bin/bash", "-c"]

# 1. Variáveis de Ambiente
ENV FLUTTER_HOME="/opt/flutter"
ENV ANDROID_SDK_ROOT="/opt/android-sdk"
ENV PATH="$FLUTTER_HOME/bin:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

# Versões (ajuste conforme necessário)
ENV FLUTTER_VERSION="3.22.2"
ENV ANDROID_CMDLINE_TOOLS_VERSION="11076708"
ENV ANDROID_COMPILE_SDK="34"
ENV ANDROID_BUILD_TOOLS_VERSION="34.0.0"

# 2. Instalação de Dependências Base
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git curl unzip openjdk-17-jdk libglu1 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 3. Instalação do SDK do Flutter
RUN mkdir -p ${FLUTTER_HOME} && \
    cd /opt && \
    git clone https://github.com/flutter/flutter.git -b ${FLUTTER_VERSION} ${FLUTTER_HOME} && \
    flutter precache

# 4. Instalação do Android SDK
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd /opt && \
    curl -o android-tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" && \
    unzip -q android-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    rm android-tools.zip && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest

# 5. Instalação das Plataformas e Build Tools do Android
RUN yes | sdkmanager --licenses --sdk_root=${ANDROID_SDK_ROOT} && \
    sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
    "platform-tools" \
    "platforms;android-${ANDROID_COMPILE_SDK}" \
    "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

WORKDIR /app

RUN flutter doctor