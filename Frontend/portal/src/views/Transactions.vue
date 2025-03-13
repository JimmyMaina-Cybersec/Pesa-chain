<script setup lang="ts">
import { ref } from 'vue'
import {
  MagnifyingGlassIcon,
  FunnelIcon,
  CheckCircleIcon,
  XCircleIcon,
  ClockIcon
} from '@heroicons/vue/24/outline'

const transactions = ref([
  {
    id: 'TXN-001',
    amount: 5000.00,
    sender: 'John Smith',
    recipient: 'Maria Garcia',
    status: 'completed',
    date: '2024-02-20T10:30:00',
    currency: 'USD'
  },
  {
    id: 'TXN-002',
    amount: 3500.00,
    sender: 'Alice Johnson',
    recipient: 'Bob Wilson',
    status: 'pending',
    date: '2024-02-20T09:45:00',
    currency: 'EUR'
  },
  {
    id: 'TXN-003',
    amount: 7500.00,
    sender: 'Sarah Brown',
    recipient: 'James Miller',
    status: 'failed',
    date: '2024-02-20T08:15:00',
    currency: 'GBP'
  },
  {
    id: 'TXN-004',
    amount: 2000.00,
    sender: 'David Lee',
    recipient: 'Emma Davis',
    status: 'completed',
    date: '2024-02-20T07:30:00',
    currency: 'USD'
  },
  {
    id: 'TXN-005',
    amount: 4500.00,
    sender: 'Michael Wang',
    recipient: 'Sophie Chen',
    status: 'pending',
    date: '2024-02-20T06:45:00',
    currency: 'EUR'
  }
])

const getStatusColor = (status: string) => {
  switch (status) {
    case 'completed':
      return 'text-green-600 bg-green-50'
    case 'pending':
      return 'text-yellow-600 bg-yellow-50'
    case 'failed':
      return 'text-red-600 bg-red-50'
    default:
      return 'text-gray-600 bg-gray-50'
  }
}

const getStatusIcon = (status: string) => {
  switch (status) {
    case 'completed':
      return CheckCircleIcon
    case 'pending':
      return ClockIcon
    case 'failed':
      return XCircleIcon
    default:
      return ClockIcon
  }
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return new Intl.DateTimeFormat('en-US', {
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  }).format(date)
}

const formatCurrency = (amount: number, currency: string) => {
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: currency
  }).format(amount)
}
</script>

<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <h1 class="text-2xl font-semibold text-gray-900">Transactions</h1>
      <div class="flex space-x-4">
        <div class="relative">
          <input
            type="text"
            placeholder="Search transactions..."
            class="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary-500 focus:border-primary-500"
          />
          <MagnifyingGlassIcon class="h-5 w-5 text-gray-400 absolute left-3 top-2.5" />
        </div>
        <button class="flex items-center px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50">
          <FunnelIcon class="h-5 w-5 text-gray-400 mr-2" />
          Filter
        </button>
      </div>
    </div>

    <div class="bg-white rounded-lg shadow">
      <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
          <thead class="bg-gray-50">
            <tr>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Transaction ID
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Amount
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Sender
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Recipient
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Status
              </th>
              <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Date
              </th>
            </tr>
          </thead>
          <tbody class="bg-white divide-y divide-gray-200">
            <tr v-for="transaction in transactions" :key="transaction.id" class="hover:bg-gray-50">
              <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                {{ transaction.id }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                {{ formatCurrency(transaction.amount, transaction.currency) }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ transaction.sender }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ transaction.recipient }}
              </td>
              <td class="px-6 py-4 whitespace-nowrap">
                <span
                  class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                  :class="getStatusColor(transaction.status)"
                >
                  <component :is="getStatusIcon(transaction.status)" class="h-4 w-4 mr-1" />
                  {{ transaction.status.charAt(0).toUpperCase() + transaction.status.slice(1) }}
                </span>
              </td>
              <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                {{ formatDate(transaction.date) }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="bg-white px-4 py-3 border-t border-gray-200 sm:px-6">
        <div class="flex items-center justify-between">
          <div class="text-sm text-gray-700">
            Showing <span class="font-medium">1</span> to <span class="font-medium">5</span> of <span class="font-medium">20</span> results
          </div>
          <div class="flex-1 flex justify-end">
            <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
              <a
                href="#"
                class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
              >
                Previous
              </a>
              <a
                href="#"
                class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                1
              </a>
              <a
                href="#"
                class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                2
              </a>
              <a
                href="#"
                class="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                3
              </a>
              <a
                href="#"
                class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
              >
                Next
              </a>
            </nav>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>