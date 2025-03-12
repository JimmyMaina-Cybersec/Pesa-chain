<template>
  <div class="transaction-list">
    <h2 class="text-xl font-bold mb-4">Transaction List</h2>
    <!-- Filters -->
    <div class="filters mb-4">
      <input v-model="searchQuery" placeholder="Search transactions..." class="input" />
      <select v-model="selectedStatus" class="select">
        <option value="">All Statuses</option>
        <option value="pending">Pending</option>
        <option value="confirmed">Confirmed</option>
        <option value="failed">Failed</option>
      </select>
    </div>
    <!-- Transactions Table -->
    <table class="table-auto w-full border-collapse border border-gray-200">
      <thead>
        <tr class="bg-gray-100">
          <th class="p-2 border">Transaction ID</th>
          <th class="p-2 border">Organization</th>
          <th class="p-2 border">Amount</th>
          <th class="p-2 border">Currency</th>
          <th class="p-2 border">Status</th>
          <th class="p-2 border">Date</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="transaction in filteredTransactions" :key="transaction.id" class="border">
          <td class="p-2 border">{{ transaction.id }}</td>
          <td class="p-2 border">{{ transaction.organization }}</td>
          <td class="p-2 border">{{ transaction.amount }}</td>
          <td class="p-2 border">{{ transaction.currency }}</td>
          <td class="p-2 border" :class="statusClass(transaction.status)">
            {{ transaction.status }}
          </td>
          <td class="p-2 border">{{ formatDate(transaction.timestamp) }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import { mapState, mapActions } from 'vuex';
import io from 'socket.io-client';

export default {
  name: 'TransactionList',
  data() {
    return {
      searchQuery: '',
      selectedStatus: '',
      socket: null,
    };
  },
  computed: {
    ...mapState({
      transactions: state => state.transactions,
    }),
    filteredTransactions() {
      return this.transactions.filter(tx => {
        const matchesQuery = !this.searchQuery || tx.id.includes(this.searchQuery);
        const matchesStatus = !this.selectedStatus || tx.status === this.selectedStatus;
        return matchesQuery && matchesStatus;
      });
    },
  },
  methods: {
    ...mapActions(['fetchTransactions', 'addTransaction']),
    statusClass(status) {
      return {
        'text-yellow-500': status === 'pending',
        'text-green-500': status === 'confirmed',
        'text-red-500': status === 'failed',
      };
    },
    formatDate(timestamp) {
      return new Date(timestamp).toLocaleString();
    },
    setupSocket() {
      this.socket = io(process.env.VUE_APP_SOCKET_URL);
      this.socket.on('connect_error', error => {
        console.error('Socket connection error:', error);
      });
      this.socket.on('transactionUpdate', transaction => {
        this.addTransaction(transaction);
      });
    },
  },
  mounted() {
    this.fetchTransactions();
    this.setupSocket();
  },
  beforeDestroy() {
    if (this.socket) {
      this.socket.disconnect();
    }
  },
};
</script>

<style scoped>
.input {
  padding: 8px;
  margin-right: 10px;
  border: 1px solid #ccc;
  border-radius: 4px;
}

.select {
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 4px;
}
</style>
