<template>
  <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 sm:rounded-lg">
    <!-- Search and Filters -->
    <div class="bg-white p-4 border-b border-gray-200">
      <div class="flex flex-col sm:flex-row gap-4">
        <div class="flex-1">
          <input
            type="text"
            v-model="searchQuery"
            placeholder="Search..."
            class="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-primary-600 sm:text-sm sm:leading-6"
            @input="handleSearch"
          />
        </div>
        <div class="flex gap-2">
          <button
            class="inline-flex items-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
            @click="exportData"
          >
            Export
          </button>
          <slot name="actions" />
        </div>
      </div>
    </div>

    <!-- Table -->
    <table class="min-w-full divide-y divide-gray-300">
      <thead class="bg-gray-50">
        <tr>
          <th
            v-for="column in columns"
            :key="column.key"
            scope="col"
            class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"
            :class="column.class"
          >
            <a
              v-if="column.sortable"
              href="#"
              class="group inline-flex"
              @click.prevent="sort(column.key)"
            >
              {{ column.label }}
              <span class="ml-2 flex-none rounded text-gray-400">
                <ChevronUpDownIcon class="h-5 w-5" aria-hidden="true" />
              </span>
            </a>
            <span v-else>{{ column.label }}</span>
          </th>
        </tr>
      </thead>
      <tbody class="divide-y divide-gray-200 bg-white">
        <tr v-for="item in paginatedData" :key="item.id">
          <td
            v-for="column in columns"
            :key="column.key"
            class="whitespace-nowrap px-3 py-4 text-sm text-gray-500"
            :class="column.class"
          >
            <slot :name="column.key" :item="item">
              {{ item[column.key] }}
            </slot>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Pagination -->
    <div class="flex items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6">
      <div class="flex flex-1 justify-between sm:hidden">
        <button
          :disabled="currentPage === 1"
          @click="currentPage--"
          class="relative inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
        >
          Previous
        </button>
        <button
          :disabled="currentPage === totalPages"
          @click="currentPage++"
          class="relative ml-3 inline-flex items-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
        >
          Next
        </button>
      </div>
      <div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
        <div>
          <p class="text-sm text-gray-700">
            Showing
            <span class="font-medium">{{ startIndex + 1 }}</span>
            to
            <span class="font-medium">{{ Math.min(endIndex, filteredData.length) }}</span>
            of
            <span class="font-medium">{{ filteredData.length }}</span>
            results
          </p>
        </div>
        <div>
          <nav class="isolate inline-flex -space-x-px rounded-md shadow-sm" aria-label="Pagination">
            <button
              :disabled="currentPage === 1"
              @click="currentPage = 1"
              class="relative inline-flex items-center rounded-l-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
            >
              <span class="sr-only">First</span>
              <ChevronDoubleLeftIcon class="h-5 w-5" aria-hidden="true" />
            </button>
            <button
              :disabled="currentPage === 1"
              @click="currentPage--"
              class="relative inline-flex items-center px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
            >
              <span class="sr-only">Previous</span>
              <ChevronLeftIcon class="h-5 w-5" aria-hidden="true" />
            </button>
            <button
              :disabled="currentPage === totalPages"
              @click="currentPage++"
              class="relative inline-flex items-center px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
            >
              <span class="sr-only">Next</span>
              <ChevronRightIcon class="h-5 w-5" aria-hidden="true" />
            </button>
            <button
              :disabled="currentPage === totalPages"
              @click="currentPage = totalPages"
              class="relative inline-flex items-center rounded-r-md px-2 py-2 text-gray-400 ring-1 ring-inset ring-gray-300 hover:bg-gray-50 focus:z-20 focus:outline-offset-0"
            >
              <span class="sr-only">Last</span>
              <ChevronDoubleRightIcon class="h-5 w-5" aria-hidden="true" />
            </button>
          </nav>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import {
  ChevronUpDownIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  ChevronDoubleLeftIcon,
  ChevronDoubleRightIcon
} from '@heroicons/vue/20/solid'

interface Column {
  key: string
  label: string
  sortable?: boolean
  class?: string
}

interface Props {
  data: any[]
  columns: Column[]
  itemsPerPage?: number
}

const props = withDefaults(defineProps<Props>(), {
  itemsPerPage: 10
})

const emit = defineEmits(['search', 'sort', 'export'])

const currentPage = ref(1)
const searchQuery = ref('')
const sortKey = ref('')
const sortOrder = ref<'asc' | 'desc'>('asc')

const filteredData = computed(() => {
  let result = [...props.data]
  
  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    result = result.filter(item => 
      Object.values(item).some(val => 
        String(val).toLowerCase().includes(query)
      )
    )
  }

  if (sortKey.value) {
    result.sort((a, b) => {
      const aVal = a[sortKey.value]
      const bVal = b[sortKey.value]
      if (sortOrder.value === 'asc') {
        return aVal > bVal ? 1 : -1
      } else {
        return aVal < bVal ? 1 : -1
      }
    })
  }

  return result
})

const totalPages = computed(() => 
  Math.ceil(filteredData.value.length / props.itemsPerPage)
)

const startIndex = computed(() => 
  (currentPage.value - 1) * props.itemsPerPage
)

const endIndex = computed(() => 
  startIndex.value + props.itemsPerPage
)

const paginatedData = computed(() => 
  filteredData.value.slice(startIndex.value, endIndex.value)
)

const handleSearch = () => {
  currentPage.value = 1
  emit('search', searchQuery.value)
}

const sort = (key: string) => {
  if (sortKey.value === key) {
    sortOrder.value = sortOrder.value === 'asc' ? 'desc' : 'asc'
  } else {
    sortKey.value = key
    sortOrder.value = 'asc'
  }
  emit('sort', { key, order: sortOrder.value })
}

const exportData = () => {
  emit('export', filteredData.value)
}
</script>