<script setup lang="ts">
import { BellIcon } from '@heroicons/vue/24/outline'
</script>

<template>
  <header class="bg-white shadow-sm">
    <div class="flex justify-between items-center px-6 py-4">
      <h1 class="text-2xl font-semibold text-gray-900">Dashboard</h1>
      <div class="flex items-center space-x-4">
        <button class="p-2 rounded-full hover:bg-gray-100">
          <BellIcon class="h-6 w-6 text-gray-500" />
        </button>
        <div class="flex items-center">
          <img
            class="h-8 w-8 rounded-full"
            src="https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80"
            alt="User avatar"
          />
        </div>
      </div>
    </div>
  </header>
</template>