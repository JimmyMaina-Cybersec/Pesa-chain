<script setup lang="ts">
import { ref } from 'vue'
import {
  MagnifyingGlassIcon,
  BuildingOfficeIcon,
  UsersIcon,
  CurrencyDollarIcon
} from '@heroicons/vue/24/outline'

const organizations = ref([
  {
    id: 'ORG-001',
    name: 'Global Trade Ltd',
    status: 'active',
    userCount: 145,
    transactionVolume: 1234567,
    country: 'United States'
  },
  {
    id: 'ORG-002',
    name: 'Swift Pay Solutions',
    status: 'active',
    userCount: 89,
    transactionVolume: 987654,
    country: 'United Kingdom'
  },
  {
    id: 'ORG-003',
    name: 'Eastern Commerce Inc',
    status: 'pending',
    userCount: 34,
    transactionVolume: 456789,
    country: 'Singapore'
  }
])

const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    notation: 'compact',
    maximumFractionDigits: 1
  }).format(amount)
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-semibold text-gray-900">Organizations</h1>
      <div class="flex space-x-4">
        <div class="relative">
          <input
            type="text"
            placeholder="Search organizations..."
            class="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          />
          <MagnifyingGlassIcon class="h-5 w-5 text-gray-400 absolute left-3 top-2.5" />
        </div>
        <button class="px-4 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700">
          Add Organization
        </button>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div v-for="org in organizations" :key="org.id" 
           class="bg-white rounded-lg shadow p-6">
        <div class="flex items-start justify-between">
          <div class="flex items-center space-x-3">
            <div class="p-2 bg-primary-50 rounded-lg">
              <BuildingOfficeIcon class="h-6 w-6 text-primary-600" />
            </div>
            <div>
              <h3 class="text-lg font-medium text-gray-900">{{ org.name }}</h3>
              <p class="text-sm text-gray-500">{{ org.country }}</p>
            </div>
          </div>
          <span 
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
            :class="org.status === 'active' ? 'bg-green-50 text-green-600' : 'bg-yellow-50 text-yellow-600'"
          >
            {{ org.status.charAt(0).toUpperCase() + org.status.slice(1) }}
          </span>
        </div>

        <div class="mt-6 grid grid-cols-2 gap-4">
          <div class="flex items-center space-x-2">
            <UsersIcon class="h-5 w-5 text-gray-400" />
            <div>
              <p class="text-sm text-gray-500">Users</p>
              <p class="text-lg font-medium text-gray-900">{{ org.userCount }}</p>
            </div>
          </div>
          <div class="flex items-center space-x-2">
            <CurrencyDollarIcon class="h-5 w-5 text-gray-400" />
            <div>
              <p class="text-sm text-gray-500">Volume</p>
              <p class="text-lg font-medium text-gray-900">{{ formatCurrency(org.transactionVolume) }}</p>
            </div>
          </div>
        </div>

        <div class="mt-6 flex justify-end space-x-3">
          <button class="px-4 py-2 text-sm font-medium text-primary-600 hover:text-primary-700">
            View Details
          </button>
          <button class="px-4 py-2 text-sm font-medium text-white bg-primary-600 rounded-lg hover:bg-primary-700">
            Manage
          </button>
        </div>
      </div>
    </div>
  </div>
</template>