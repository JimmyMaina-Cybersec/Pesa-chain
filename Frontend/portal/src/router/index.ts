import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../views/Dashboard.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'Dashboard',
      component: Dashboard
    },
    {
      path: '/transactions',
      name: 'Transactions',
      component: () => import('../views/Transactions.vue')
    },
    {
      path: '/kyc',
      name: 'KYC',
      component: () => import('../views/KYC.vue')
    },
    {
      path: '/organizations',
      name: 'Organizations',
      component: () => import('../views/Organizations.vue')
    },
    {
      path: '/settings',
      name: 'Settings',
      component: () => import('../views/Settings.vue')
    }
  ]
})

export default router