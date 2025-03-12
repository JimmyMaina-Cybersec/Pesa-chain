<template>
  <div class="bg-white p-6 rounded-lg shadow">
    <div class="mb-4">
      <h3 class="text-lg font-medium leading-6 text-gray-900">Transaction Volume</h3>
      <div class="mt-1">
        <div class="flex space-x-4">
          <select
            v-model="timeRange"
            class="mt-1 block w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base focus:border-primary-500 focus:outline-none focus:ring-primary-500 sm:text-sm"
          >
            <option value="day">Last 24 Hours</option>
            <option value="week">Last Week</option>
            <option value="month">Last Month</option>
            <option value="year">Last Year</option>
          </select>
        </div>
      </div>
    </div>
    <div class="h-72">
      <line-chart
        :labels="chartData.labels"
        :datasets="chartData.datasets"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import LineChart from '../common/Charts/LineChart.vue'

const timeRange = ref('day')

// Mock data - replace with real data from your store
const chartData = computed(() => {
  const now = new Date()
  const labels = []
  const volumeData = []
  const successRateData = []

  let points = 24
  let interval = 60 * 60 * 1000 // 1 hour in milliseconds

  switch (timeRange.value) {
    case 'week':
      points = 7
      interval = 24 * 60 * 60 * 1000 // 1 day
      break
    case 'month':
      points = 30
      interval = 24 * 60 * 60 * 1000 // 1 day
      break
    case 'year':
      points = 12
      interval = 30 * 24 * 60 * 60 * 1000 // ~1 month
      break
  }

  for (let i = points - 1; i >= 0; i--) {
    const date = new Date(now.getTime() - (i * interval))
    labels.push(formatDate(date, timeRange.value))
    volumeData.push(Math.floor(Math.random() * 1000))
    successRateData.push(85 + Math.random() * 15)
  }

  return {
    labels,
    datasets: [
      {
        label: 'Transaction Volume',
        data: volumeData,
        borderColor: '#0ea5e9',
        backgroundColor: 'rgba(14, 165, 233, 0.1)'
      },
      {
        label: 'Success Rate (%)',
        data: successRateData,
        borderColor: '#10b981',
        backgroundColor: 'rgba(16, 185, 129, 0.1)'
      }
    ]
  }
})

const formatDate = (date: Date, range: string) => {
  switch (range) {
    case 'day':
      return date.toLocaleTimeString([], { hour: '2-digit' })
    case 'week':
      return date.toLocaleDateString([], { weekday: 'short' })
    case 'month':
      return date.toLocaleDateString([], { day: 'numeric', month: 'short' })
    case 'year':
      return date.toLocaleDateString([], { month: 'short' })
    default:
      return date.toLocaleDateString()
  }
}
</script>