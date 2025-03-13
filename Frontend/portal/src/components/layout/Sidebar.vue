<script setup lang="ts">
import { ref } from 'vue'
import {
  HomeIcon,
  CurrencyDollarIcon,
  UserGroupIcon,
  BuildingOfficeIcon,
  Cog6ToothIcon,
} from '@heroicons/vue/24/outline'

const navigation = [
  { name: 'Dashboard', icon: HomeIcon, path: '/' },
  { name: 'Transactions', icon: CurrencyDollarIcon, path: '/transactions' },
  { name: 'KYC Management', icon: UserGroupIcon, path: '/kyc' },
  { name: 'Organizations', icon: BuildingOfficeIcon, path: '/organizations' },
  { name: 'Settings', icon: Cog6ToothIcon, path: '/settings' },
]
</script>

<template>
  <aside class="bg-gray-900 w-64 flex flex-col">
    <div class="flex items-center justify-center h-16 bg-gray-800">
      <span class="text-white text-xl font-semibold">Remittance Admin</span>
    </div>
    <nav class="mt-6 flex-1">
      <div class="px-3 space-y-1">
        <router-link
          v-for="item in navigation"
          :key="item.name"
          :to="item.path"
          class="sidebar-link"
          :class="{ 'active': $route.path === item.path }"
        >
          <component :is="item.icon" class="h-5 w-5 mr-3" />
          {{ item.name }}
        </router-link>
      </div>
    </nav>
  </aside>
</template>