<template>
  <div class="bg-white p-6 rounded-lg shadow">
    <div class="mb-4">
      <h3 class="text-lg font-medium leading-6 text-gray-900">Transaction Volume</h3>
      <div class="mt-1">
        <div class="flex space-x-4">
          <select
            v-model="timeRange"
            @change="updateChartData"
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
      <line-chart :labels="chartData.labels" :datasets="chartData.datasets" />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import LineChart from '../common/Charts/LineChart.vue';

interface ChartDataset {
  label: string;
  data: number[];
  borderColor: string;
  backgroundColor: string;
}

interface ChartData {
  labels: string[];
  datasets: ChartDataset[];
}

const timeRange = ref<'day' | 'week' | 'month' | 'year'>('day');
const chartData = ref<ChartData>({ labels: [], datasets: [] });

const generateChartData = (range: string) => {
  const now = new Date();
  const labels: string[] = [];
  const volumeData: number[] = [];
  const successRateData: number[] = [];

  let points = 24, interval = 60 * 60 * 1000;
  if (range === 'week') { points = 7; interval = 24 * 60 * 60 * 1000; }
  if (range === 'month') { points = 30; interval = 24 * 60 * 60 * 1000; }
  if (range === 'year') { points = 12; interval = 30 * 24 * 60 * 60 * 1000; }

  for (let i = points - 1; i >= 0; i--) {
    const date = new Date(now.getTime() - i * interval);
    labels.push(formatDate(date, range));
    volumeData.push(Math.floor(Math.random() * 1000));
    successRateData.push(85 + Math.random() * 15);
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
  };
};

const formatDate = (date: Date, range: string): string => {
  const options: Intl.DateTimeFormatOptions =
    range === 'day' ? { hour: '2-digit' } :
    range === 'week' ? { weekday: 'short' } :
    range === 'month' ? { day: 'numeric', month: 'short' } :
    { month: 'short' };
  return new Intl.DateTimeFormat('en-US', options).format(date);
};

const updateChartData = () => {
  chartData.value = generateChartData(timeRange.value);
};

updateChartData(); // Initialize data on mount
</script>
