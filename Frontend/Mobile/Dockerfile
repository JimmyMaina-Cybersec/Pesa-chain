# Use the official Node.js image as a base
FROM node:18

# Install dependencies for React Native (Android SDK, etc.)
RUN apt-get update && apt-get install -y \
  openjdk-8-jdk \
  wget \
  unzip \
  lib32stdc++6 \
  lib32z1 \
  lib32ncurses5 \
  lib32bz2-1.0 \
  watchman && \
  apt-get clean

# Install Android SDK
RUN mkdir -p /usr/local/android-sdk-linux && cd /usr/local/android-sdk-linux && \
  wget https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip && \
  unzip commandlinetools-linux-7302050_latest.zip && \
  rm commandlinetools-linux-7302050_latest.zip

# Set environment variables for Android SDK
ENV ANDROID_SDK_ROOT=/usr/local/android-sdk-linux
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/bin:$ANDROID_SDK_ROOT/tools/bin

# Accept Android SDK licenses
RUN yes | sdkmanager --licenses

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies first
COPY package.json package-lock.json /app/

# Install project dependencies
RUN npm install

# Copy the rest of your project files into the container
COPY . /app/

# Expose port 8081 for React Native development server
EXPOSE 8081

# Add a non-root user for security
RUN adduser -D appuser
USER appuser

# Command to run React Native Metro bundler
CMD ["npm", "start"]