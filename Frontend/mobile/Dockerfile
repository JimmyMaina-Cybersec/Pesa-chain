# Dockerfile.android
FROM node:18 as build

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run android

# ---- Stage for Android build ----
FROM openjdk:23

# Set environment variables for Android build
ENV ANDROID_HOME /root/Android/Sdk
ENV PATH $ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

# Install Java (OpenJDK), Android SDK, and other build tools
RUN apt update && \
    apt install -y curl unzip && \
    curl -s https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip -o cmdline-tools.zip && \
    mkdir -p $ANDROID_HOME/cmdline-tools/latest && \
    unzip cmdline-tools.zip -d $ANDROID_HOME/cmdline-tools/latest && \
    rm cmdline-tools.zip && \
    yes | $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --licenses && \
    $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"

# Copy the built project files
COPY --from=build /app /app

# Build the Android app
WORKDIR /app/android
RUN ./gradlew assembleRelease
