import { defineStore } from 'pinia'
import axios from 'axios'

// 设置后端地址
axios.defaults.baseURL = 'http://127.0.0.1:8000'
// 允许跨域携带 Cookie
axios.defaults.withCredentials = true

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    isAuthenticated: false
  }),
actions: {
    async login(username, password) {
      try {
        const response = await axios.post('/auth/login', { username, password })
        this.user = response.data
        this.isAuthenticated = true
        return true
      } catch (error) {
        console.error('Login failed:', error) // 打印完整错误到控制台
        return false
      }
    },
    async register(username, email, password) {
      try {
        await axios.post('/auth/register', { username, email, password })
        return true
      } catch (error) {
        //先判断有没有 response
        if (error.response && error.response.data) {
            throw error.response.data 
        } else if (error.request) {
            // 请求发了，但没收到回应
            throw new Error("服务器无响应，请检查后端是否启动")
        } else {
            // 其他代码错误
            throw new Error(error.message)
        }
      }
    }
  }
})