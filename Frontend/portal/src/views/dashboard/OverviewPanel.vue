<template>
  <div class="space-y-6">
    <!-- Stats Overview -->
    <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
      <div v-for="stat in stats" :key="stat.name" class="bg-white px-4 py-5 shadow rounded-lg overflow-hidden sm:p-6">
        <dt class="text-sm font-medium text-gray-500 truncate">{{ stat.name }}</dt>
        <dd class="mt-1 text-3xl font-semibold text-gray-900">{{ stat.value }}</dd>
        <div class="mt-2 flex items-center text-sm">
          <span :class="stat.change >= 0 ? 'text-green-600' : 'text-red-600'">
            {{ stat.change >= 0 ? '+' : '' }}{{ stat.change }}%
          </span>
          <span class="text-gray-500 ml-2">from last month</span>
        </div>
      </div>
    </div>

    <!-- Recent Transactions -->
    <transaction-list
      :transactions="transactions"
      :organizations="organizations"
      @refresh="fetchTransactions"
      @view="viewTransaction"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useTransactionsStore } from '@/stores/transactions'
import TransactionList from '@/components/dashboard/TransactionList.vue'
import type { Transaction, Organization } from '@/types'

const transactionsStore = useTransactionsStore()
const transactions = ref<Transaction[]>([])
const organizations = ref<Organization[]>([])

const stats = ref([
  { name: 'Total Transactions', value: '3,897', change: 12 },
  { name: 'Processing Volume', value: '$2.4M', change: 2.5 },
  { name: 'Pending Approvals', value: '24', change: -4 },
  { name: 'Success Rate', value: '98.5%', change: 0.2 }
])

const fetchTransactions = async () => {
  await transactionsStore.fetchTransactions()
  transactions.value = transactionsStore.transactions
}

const viewTransaction = (transaction: Transaction) => {
  console.log('Viewing transaction:', transaction)
}

onMounted(() => {
  fetchTransactions()
})
</script>