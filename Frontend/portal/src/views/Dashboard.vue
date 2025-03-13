<script setup lang="ts">
import { ref } from 'vue'
import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
} from 'chart.js'

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
)

const chartData = {
  labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
  datasets: [
    {
      label: 'Transaction Volume',
      data: [65, 59, 80, 81, 56, 55],
      borderColor: '#0ea5e9',
      tension: 0.4
    }
  ]
}

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      display: false
    }
  }
}
</script>

<template>
  <div class="space-y-6">
    <!-- Stats Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="dashboard-card">
        <h3 class="stat-label">Total Transactions</h3>
        <p class="stat-value">$1,234,567</p>
        <p class="text-sm text-green-600 mt-2">+12.5% from last month</p>
      </div>
      <div class="dashboard-card">
        <h3 class="stat-label">Pending KYC</h3>
        <p class="stat-value">24</p>
        <p class="text-sm text-yellow-600 mt-2">5 urgent reviews</p>
      </div>
      <div class="dashboard-card">
        <h3 class="stat-label">Active Organizations</h3>
        <p class="stat-value">156</p>
        <p class="text-sm text-blue-600 mt-2">+3 this week</p>
      </div>
      <div class="dashboard-card">
        <h3 class="stat-label">Success Rate</h3>
        <p class="stat-value">99.2%</p>
        <p class="text-sm text-green-600 mt-2">+0.5% improvement</p>
      </div>
    </div>

    <!-- Charts -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="dashboard-card">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Transaction Volume</h3>
        <div class="h-64">
          <Line :data="chartData" :options="chartOptions" />
        </div>
      </div>
      <div class="dashboard-card">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Recent Activity</h3>
        <div class="space-y-4">
          <div v-for="i in 4" :key="i" class="flex items-center justify-between">
            <div>
              <p class="text-sm font-medium text-gray-900">Transaction #{{ 1000 + i }}</p>
              <p class="text-sm text-gray-500">Processed {{ i }} hour{{ i !== 1 ? 's' : '' }} ago</p>
            </div>
            <span class="text-sm font-medium text-green-600">${{ i * 1000 }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Tasks & Notifications -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="dashboard-card">
        <h3 class="text-lg font-medium text-gray-900 mb-4">Pending Tasks</h3>
        <div class="space-y-3">
          <div v-for="i in 3" :key="i" class="flex items-center">
            <input type="checkbox" class="h-4 w-4 text-primary-600 rounded border-gray-300" />
            <span class="ml-3 text-sm text-gray-700">Review KYC application #{{ 100 + i }}</span>
          </div>
        </div>
      </div>
      <div class="dashboard-card">
        <h3 class="text-lg font-medium text-gray-900 mb-4">System Notifications</h3>
        <div class="space-y-3">
          <div v-for="i in 3" :key="i" class="flex items-start">
            <div class="flex-shrink-0">
              <span class="inline-block h-2 w-2 rounded-full bg-blue-600"></span>
            </div>
            <p class="ml-3 text-sm text-gray-700">New organization registration pending approval</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>