import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import path from 'path';

export default defineConfig({
  plugins: [vue()],
  server: {
    host: true, // listen on all network interfaces
    allowedHosts: ['2b88-41-215-37-30.ngrok-free.app'] // allow your ngrok host
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
