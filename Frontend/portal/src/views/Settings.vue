<script setup lang="ts">
import { ref } from 'vue'
import {
  UserIcon,
  ShieldCheckIcon,
  BellIcon,
  GlobeAltIcon
} from '@heroicons/vue/24/outline'

const sections = [
  {
    id: 'profile',
    name: 'Profile Settings',
    icon: UserIcon,
    description: 'Update your account information and preferences.'
  },
  {
    id: 'security',
    name: 'Security',
    icon: ShieldCheckIcon,
    description: 'Manage your security settings and authentication methods.'
  },
  {
    id: 'notifications',
    name: 'Notifications',
    icon: BellIcon,
    description: 'Configure how you receive alerts and updates.'
  },
  {
    id: 'regional',
    name: 'Regional Settings',
    icon: GlobeAltIcon,
    description: 'Manage language, timezone, and currency preferences.'
  }
]

const activeSection = ref('profile')
</script>

<template>
  <div class="space-y-6">
    <div class="flex items-center justify-between">
      <h1 class="text-2xl font-semibold text-gray-900">Settings</h1>
    </div>

    <div class="bg-white rounded-lg shadow">
      <div class="grid grid-cols-1 lg:grid-cols-4">
        <!-- Settings Navigation -->
        <nav class="p-6 border-r border-gray-200">
          <ul class="space-y-2">
            <li v-for="section in sections" :key="section.id">
              <button
                @click="activeSection = section.id"
                class="w-full flex items-center px-3 py-2 text-sm font-medium rounded-lg"
                :class="activeSection === section.id ? 
                  'text-primary-600 bg-primary-50' : 
                  'text-gray-900 hover:bg-gray-50'"
              >
                <component :is="section.icon" 
                  class="h-5 w-5 mr-3"
                  :class="activeSection === section.id ? 'text-primary-600' : 'text-gray-400'"
                />
                {{ section.name }}
              </button>
            </li>
          </ul>
        </nav>

        <!-- Settings Content -->
        <div class="col-span-3 p-6">
          <div v-if="activeSection === 'profile'" class="space-y-6">
            <div>
              <h3 class="text-lg font-medium text-gray-900">Profile Information</h3>
              <p class="mt-1 text-sm text-gray-500">Update your account information and preferences.</p>
            </div>

            <form class="space-y-6">
              <div class="grid grid-cols-1 gap-6 sm:grid-cols-2">
                <div>
                  <label class="block text-sm font-medium text-gray-700">First Name</label>
                  <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" />
                </div>
                <div>
                  <label class="block text-sm font-medium text-gray-700">Last Name</label>
                  <input type="text" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" />
                </div>
                <div class="sm:col-span-2">
                  <label class="block text-sm font-medium text-gray-700">Email Address</label>
                  <input type="email" class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500" />
                </div>
              </div>

              <div class="flex justify-end">
                <button type="submit" class="px-4 py-2 text-sm font-medium text-white bg-primary-600 rounded-lg hover:bg-primary-700">
                  Save Changes
                </button>
              </div>
            </form>
          </div>

          <div v-else class="flex items-center justify-center h-64 text-gray-500">
            Select a settings section to view and edit
          </div>
        </div>
      </div>
    </div>
  </div>
</template>