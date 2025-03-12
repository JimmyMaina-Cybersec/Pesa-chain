import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import axios from 'axios'
import type { Transaction, TransactionStatus } from '../types'

export const useTransactionsStore = defineStore('transactions', () => {
  const transactions = ref<Transaction[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  const pendingTransactions = computed(() => 
    transactions.value.filter(t => t.status === 'pending')
  )

  const completedTransactions = computed(() => 
    transactions.value.filter(t => t.status === 'completed')
  )

  const failedTransactions = computed(() => 
    transactions.value.filter(t => t.status === 'failed')
  )

  async function fetchTransactions(params?: {
    page?: number
    limit?: number
    status?: TransactionStatus
    organizationId?: string
  }) {
    try {
      isLoading.value = true
      // Mock data for now - replace with actual API call
      transactions.value = [
        {
          id: '1',
          amount: 1000,
          currency: 'USD',
          status: 'completed',
          senderOrganization: 'Org A',
          receiverOrganization: 'Org B',
          timestamp: new Date().toISOString(),
          fees: 10,
          exchangeRate: 1
        },
        {
          id: '2',
          amount: 2000,
          currency: 'EUR',
          status: 'pending',
          senderOrganization: 'Org C',
          receiverOrganization: 'Org D',
          timestamp: new Date().toISOString(),
          fees: 20,
          exchangeRate: 1.1
        }
      ]
    } catch (err) {
      error.value = 'Failed to fetch transactions'
      console.error(err)
    } finally {
      isLoading.value = false
    }
  }

  async function updateTransactionStatus(
    transactionId: string,
    status: TransactionStatus
  ) {
    try {
      await axios.patch(`/api/transactions/${transactionId}`, { status })
      await fetchTransactions()
    } catch (err) {
      error.value = 'Failed to update transaction status'
      console.error(err)
    }
  }

  return {
    transactions,
    isLoading,
    error,
    pendingTransactions,
    completedTransactions,
    failedTransactions,
    fetchTransactions,
    updateTransactionStatus
  }
})