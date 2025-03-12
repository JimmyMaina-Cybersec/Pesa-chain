<template>
  <div class="hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-72 lg:flex-col">
    <!-- Sidebar component -->
    <div class="flex grow flex-col gap-y-5 overflow-y-auto border-r border-gray-200 bg-white px-6 pb-4">
      <div class="flex h-16 shrink-0 items-center">
        <img class="h-8 w-auto" src="https://tailwindui.com/img/logos/mark.svg?color=primary&shade=600" alt="Company Logo" />
      </div>
      <nav class="flex flex-1 flex-col">
        <ul role="list" class="flex flex-1 flex-col gap-y-7">
          <li>
            <ul role="list" class="-mx-2 space-y-1">
              <li v-for="item in navigation" :key="item.name">
                <router-link
                  :to="item.to"
                  :class="[
                    $route.name === item.name
                      ? 'bg-gray-50 text-primary-600'
                      : 'text-gray-700 hover:text-primary-600 hover:bg-gray-50',
                    'group flex gap-x-3 rounded-md p-2 text-sm leading-6 font-semibold'
                  ]"
                >
                  <component
                    :is="item.icon"
                    :class="[
                      $route.name === item.name ? 'text-primary-600' : 'text-gray-400 group-hover:text-primary-600',
                      'h-6 w-6 shrink-0'
                    ]"
                    aria-hidden="true"
                  />
                  {{ item.name }}
                </router-link>
              </li>
            </ul>
          </li>
        </ul>
      </nav>
    </div>
  </div>
</template>

<script setup lang="ts">
import {
  HomeIcon,
  CurrencyDollarIcon,
  UserGroupIcon,
  ChartBarIcon,
  ClipboardDocumentListIcon
} from '@heroicons/vue/24/outline'

const navigation = [
  { name: 'dashboard', to: '/', icon: HomeIcon },
  { name: 'transactions', to: '/transactions', icon: CurrencyDollarIcon },
  { name: 'kyc', to: '/kyc', icon: UserGroupIcon },
  { name: 'analytics', to: '/analytics', icon: ChartBarIcon },
  { name: 'audit', to: '/audit', icon: ClipboardDocumentListIcon }
]
</script>