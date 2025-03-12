import { defineStore } from 'pinia'
import { ref } from 'vue'
import { io, Socket } from 'socket.io-client'

export interface Notification {
  id: string
  type: 'info' | 'success' | 'warning' | 'error'
  message: string
  timestamp: string
  read: boolean
}

export const useNotificationsStore = defineStore('notifications', () => {
  const notifications = ref<Notification[]>([])
  const socket = ref<Socket | null>(null)
  const unreadCount = ref(0)

  const initializeWebSocket = () => {
    socket.value = io(import.meta.env.VITE_WEBSOCKET_URL)

    socket.value.on('connect', () => {
      console.log('WebSocket connected')
    })

    socket.value.on('notification', (notification: Notification) => {
      addNotification(notification)
    })

    socket.value.on('disconnect', () => {
      console.log('WebSocket disconnected')
    })
  }

  const addNotification = (notification: Notification) => {
    notifications.value.unshift({
      ...notification,
      read: false,
      timestamp: new Date().toISOString()
    })
    updateUnreadCount()
  }

  const markAsRead = (id: string) => {
    const notification = notifications.value.find(n => n.id === id)
    if (notification) {
      notification.read = true
      updateUnreadCount()
    }
  }

  const markAllAsRead = () => {
    notifications.value.forEach(n => n.read = true)
    updateUnreadCount()
  }

  const updateUnreadCount = () => {
    unreadCount.value = notifications.value.filter(n => !n.read).length
  }

  const clearNotifications = () => {
    notifications.value = []
    updateUnreadCount()
  }

  return {
    notifications,
    unreadCount,
    initializeWebSocket,
    addNotification,
    markAsRead,
    markAllAsRead,
    clearNotifications
  }
})