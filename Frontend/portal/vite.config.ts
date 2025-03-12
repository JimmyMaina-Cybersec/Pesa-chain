import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import path from 'path';

export default defineConfig({
  plugins: [vue()],
  server: {
    host: true, // listen on all network interfaces
    allowedHosts: ['6d06-196-200-33-84.ngrok-free.app'] // allow your ngrok host
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
});
