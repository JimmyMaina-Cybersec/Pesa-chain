<template>
  <div>
    <h1 class="text-2xl font-semibold text-gray-900">Transactions</h1>
    <div class="mt-6">
      <transaction-list
        :transactions="transactions"
        :organizations="organizations"
        @refresh="fetchTransactions"
        @view="viewTransaction"
      />
    </div>
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