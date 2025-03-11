<template>
  <div
    v-if="isOpen"
    class="fixed inset-0 z-50 overflow-hidden"
    aria-labelledby="slide-over-title"
    role="dialog"
    aria-modal="true"
  >
    <div class="absolute inset-0 overflow-hidden">
      <!-- Background overlay -->
      <div
        class="absolute inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
        @click="close"
      ></div>

      <div class="pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10">
        <div class="pointer-events-auto w-screen max-w-md">
          <div class="flex h-full flex-col overflow-y-scroll bg-white shadow-xl">
            <div class="bg-primary-700 py-6 px-4 sm:px-6">
              <div class="flex items-center justify-between">
                <h2 class="text-lg font-medium text-white" id="slide-over-title">Notifications</h2>
                <div class="ml-3 flex h-7 items-center">
                  <button
                    type="button"
                    class="rounded-md bg-primary-700 text-primary-200 hover:text-white focus:outline-none focus:ring-2 focus:ring-white"
                    @click="close"
                  >
                    <span class="sr-only">Close panel</span>
                    <XMarkIcon class="h-6 w-6" aria-hidden="true" />
                  </button>
                </div>
              </div>
            </div>
            <div class="relative flex-1 px-4 py-6 sm:px-6">
              <!-- Notification list -->
              <div class="space-y-6">
                <div v-if="notifications.length === 0" class="text-center text-gray-500">
                  No new notifications
                </div>
                <div
                  v-for="notification in notifications"
                  :key="notification.id"
                  class="relative bg-white p-4 hover:bg-gray-50"
                >
                  <div class="flex space-x-3">
                    <div class="flex-1">
                      <p class="text-sm text-gray-900">{{ notification.message }}</p>
                      <p class="mt-1 text-xs text-gray-500">
                        {{ new Date(notification.timestamp).toLocaleString() }}
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { XMarkIcon } from '@heroicons/vue/24/outline'

interface Notification {
  id: string
  message: string
  timestamp: string
}

const isOpen = ref(false)
const notifications = ref<Notification[]>([])

const close = () => {
  isOpen.value = false
}

// This would typically be connected to a WebSocket or Server-Sent Events
const fetchNotifications = () => {
  // Mock notifications for now
  notifications.value = [
    {
      id: '1',
      message: 'New transaction requires approval',
      timestamp: new Date().toISOString()
    },
    {
      id: '2',
      message: 'KYC verification completed',
      timestamp: new Date(Date.now() - 3600000).toISOString()
    }
  ]
}

fetchNotifications()
</script>