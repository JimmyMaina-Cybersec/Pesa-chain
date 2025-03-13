<script setup lang="ts">
import Sidebar from './components/layout/Sidebar.vue'
import TopBar from './components/layout/TopBar.vue'
</script>

<template>
  <div class="flex h-screen bg-gray-50">
    <Sidebar />
    <div class="flex-1 flex flex-col overflow-hidden">
      <TopBar />
      <main class="flex-1 overflow-x-hidden overflow-y-auto bg-gray-50 p-6">
        <router-view></router-view>
      </main>
    </div>
  </div>
</template>