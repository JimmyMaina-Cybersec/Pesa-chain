<template>
  <div class="min-h-screen bg-gray-50">
    <template v-if="isAuthenticated">
      <nav-sidebar />
      <div class="lg:pl-72">
        <top-header />
        <main class="py-10">
          <div class="px-4 sm:px-6 lg:px-8">
            <router-view></router-view>
          </div>
        </main>
      </div>
      <notifications-panel />
    </template>
    <template v-else>
      <login-view />
    </template>
  </div>
</template>

<script setup lang="ts">
import { useAuth0 } from '@auth0/auth0-vue'
import NavSidebar from './components/layout/NavSidebar.vue'
import TopHeader from './components/layout/TopHeader.vue'
import NotificationsPanel from './components/layout/NotificationsPanel.vue'
import LoginView from './views/LoginView.vue'

const { isAuthenticated } = useAuth0()
</script>