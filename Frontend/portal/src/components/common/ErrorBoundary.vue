<template>
  <div>
    <slot v-if="!hasError" />
    <div v-else class="p-4 bg-red-50 border border-red-200 rounded-md">
      <div class="flex">
        <div class="flex-shrink-0">
          <XCircleIcon class="h-5 w-5 text-red-400" aria-hidden="true" />
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800">An error has occurred</h3>
          <div class="mt-2 text-sm text-red-700">
            <p>{{ error?.message }}</p>
          </div>
          <div class="mt-4">
            <button
              type="button"
              class="rounded-md bg-red-50 px-2 py-1.5 text-sm font-medium text-red-800 hover:bg-red-100"
              @click="retry"
            >
              Try again
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onErrorCaptured } from 'vue'
import { XCircleIcon } from '@heroicons/vue/24/outline'

const hasError = ref(false)
const error = ref<Error | null>(null)

onErrorCaptured((err) => {
  hasError.value = true
  error.value = err as Error
  return false
})

const retry = () => {
  hasError.value = false
  error.value = null
}
</script>