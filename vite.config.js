import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  root: './src/dashboard',
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src/dashboard'),
      '@components': path.resolve(__dirname, './src/components')
    }
  },
  server: {
    port: 5173,
    open: true
  },
  build: {
    outDir: '../../dist',
    sourcemap: true,
    rollupOptions: {
      input: {
        main: path.resolve(__dirname, './src/dashboard/index.html')
      }
    }
  },
  // Ensure CSS modules work properly
  css: {
    modules: {
      localsConvention: 'camelCase'
    }
  }
});
