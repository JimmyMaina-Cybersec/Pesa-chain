<script setup lang="ts">
import { ref } from 'vue'
import {
  MagnifyingGlassIcon,
  DocumentCheckIcon,
  DocumentMagnifyingGlassIcon,
  XCircleIcon
} from '@heroicons/vue/24/outline'

const kycApplications = ref([
  {
    id: 'KYC-001',
    name: 'John Smith',
    status: 'verified',
    submissionDate: '2024-02-19T14:30:00',
    documentType: 'Passport',
    organization: 'Global Trade Ltd'
  },
  {
    id: 'KYC-002',
    name: 'Maria Garcia',
    status: 'pending',
    submissionDate: '2024-02-20T09:15:00',
    documentType: 'National ID',
    organization: 'Swift Pay Solutions'
  },
  {
    id: 'KYC-003',
    name: 'David Chen',
    status: 'rejected',
    submissionDate: '2024-02-18T16:45:00',
    documentType: 'Driver License',
    organization: 'Eastern Commerce Inc'
  }
])

const getStatusColor = (status: string) => {
  switch (status) {
    case 'verified':
      return 'text-green-600 bg-green-50'
    case 'pending':
      return 'text-yellow-600 bg-yellow-50'
    case 'rejected':
      return 'text-red-600 bg-red-50'
    default:
      return 'text-gray-600 bg-gray-50'
  }
}

const getStatusIcon = (status: string) => {
  switch (status) {
    case 'verified':
      return DocumentCheckIcon
    case 'pending':
      return DocumentMagnifyingGlassIcon
    case 'rejected':
      return XCircleIcon
    default:
      return DocumentMagnifyingGlassIcon
  }
}

const formatDate = (dateString: string) => {
  return new Intl.DateTimeFormat('en-US', {
    dateStyle: 'medium',
    timeStyle: 'short'
  }).format(new Date(dateString))
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-semibold text-gray-900">KYC Management</h1>
      <div class="flex space-x-4">
        <div class="relative">
          <input
            type="text"
            placeholder="Search applications..."
            class="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          />
          <MagnifyingGlassIcon class="h-5 w-5 text-gray-400 absolute left-3 top-2.5" />
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <div v-for="application in kycApplications" :key="application.id" 
           class="bg-white rounded-lg shadow p-6 space-y-4">
        <div class="flex justify-between items-start">
          <div>
            <h3 class="text-lg font-medium text-gray-900">{{ application.name }}</h3>
            <p class="text-sm text-gray-500">{{ application.organization }}</p>
          </div>
          <span
            class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
            :class="getStatusColor(application.status)"
          >
            <component :is="getStatusIcon(application.status)" class="h-4 w-4 mr-1" />
            {{ application.status.charAt(0).toUpperCase() + application.status.slice(1) }}
          </span>
        </div>
        
        <div class="space-y-2">
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">Document Type</span>
            <span class="text-gray-900">{{ application.documentType }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">Submission Date</span>
            <span class="text-gray-900">{{ formatDate(application.submissionDate) }}</span>
          </div>
          <div class="flex justify-between text-sm">
            <span class="text-gray-500">Reference ID</span>
            <span class="text-gray-900">{{ application.id }}</span>
          </div>
        </div>

        <div class="pt-4 flex justify-end space-x-3">
          <button class="px-4 py-2 text-sm font-medium text-primary-600 hover:text-primary-700">
            View Details
          </button>
          <button 
            v-if="application.status === 'pending'"
            class="px-4 py-2 text-sm font-medium text-white bg-primary-600 rounded-lg hover:bg-primary-700"
          >
            Review
          </button>
        </div>
      </div>
    </div>
  </div>
</template>