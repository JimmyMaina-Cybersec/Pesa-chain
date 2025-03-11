<template>
  <div class="sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 border-b border-gray-200 bg-white px-4 shadow-sm sm:gap-x-6 sm:px-6 lg:px-8">
    <button type="button" class="text-gray-700 lg:hidden">
      <span class="sr-only">Open sidebar</span>
      <Bars3Icon class="h-6 w-6" aria-hidden="true" />
    </button>

    <!-- Separator -->
    <div class="h-6 w-px bg-gray-200 lg:hidden" aria-hidden="true" />

    <div class="flex flex-1 gap-x-4 self-stretch lg:gap-x-6">
      <div class="flex flex-1"></div>
      <div class="flex items-center gap-x-4 lg:gap-x-6">
        <!-- Notifications -->
        <button type="button" class="-m-2.5 p-2.5 text-gray-400 hover:text-gray-500">
          <span class="sr-only">View notifications</span>
          <BellIcon class="h-6 w-6" aria-hidden="true" />
        </button>

        <!-- Profile dropdown -->
        <div class="relative">
          <button
            type="button"
            class="flex items-center gap-x-4 text-sm font-medium leading-6 text-gray-900"
            @click="isOpen = !isOpen"
          >
            <img
              class="h-8 w-8 rounded-full bg-gray-50"
              :src="user?.picture"
              alt=""
            />
            <span class="sr-only">Open user menu</span>
          </button>

          <div
            v-if="isOpen"
            class="absolute right-0 z-10 mt-2.5 w-32 origin-top-right rounded-md bg-white py-2 shadow-lg ring-1 ring-gray-900/5 focus:outline-none"
          >
            <button
              @click="logout"
              class="block px-3 py-1 text-sm leading-6 text-gray-900 hover:bg-gray-50"
            >
              Sign out
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAuth0 } from '@auth0/auth0-vue'
import { Bars3Icon, BellIcon } from '@heroicons/vue/24/outline'

const { user, logout: auth0Logout } = useAuth0()
const isOpen = ref(false)

const logout = () => {
  auth0Logout({ logoutParams: { returnTo: window.location.origin } })
}
</script>