import { createRouter, createWebHistory } from 'vue-router'
import { authGuard } from '@auth0/auth0-vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      redirect: '/dashboard'
    },
    {
      path: '/dashboard',
      component: () => import('../views/DashboardView.vue'),
      beforeEnter: authGuard,
      children: [
        {
          path: '',
          name: 'dashboard',
          component: () => import('../views/dashboard/OverviewPanel.vue')
        },
        {
          path: 'transactions',
          name: 'transactions',
          component: () => import('../views/dashboard/TransactionsPanel.vue')
        },
        {
          path: 'kyc',
          name: 'kyc',
          component: () => import('../views/dashboard/KYCPanel.vue')
        },
        {
          path: 'analytics',
          name: 'analytics',
          component: () => import('../views/dashboard/AnalyticsPanel.vue')
        },
        {
          path: 'audit',
          name: 'audit',
          component: () => import('../views/dashboard/AuditPanel.vue')
        }
      ]
    },
    {
      path: '/callback',
      component: () => import('../views/CallbackView.vue')
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue')
    }
  ]
})

export default router