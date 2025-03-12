<template>
  <div class="relative">
    <Line
      :data="chartData"
      :options="chartOptions"
    />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
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
import { Line } from 'vue-chartjs'

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
)

interface Props {
  labels: string[]
  datasets: {
    label: string
    data: number[]
    borderColor?: string
    backgroundColor?: string
  }[]
  title?: string
}

const props = withDefaults(defineProps<Props>(), {
  title: ''
})

const chartData = computed(() => ({
  labels: props.labels,
  datasets: props.datasets.map(dataset => ({
    ...dataset,
    tension: 0.4
  }))
}))

const chartOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'top' as const
    },
    title: {
      display: !!props.title,
      text: props.title
    }
  },
  scales: {
    y: {
      beginAtZero: true
    }
  }
}))
</script>