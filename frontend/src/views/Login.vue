<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
    <div class="bg-white w-full max-w-md rounded-2xl shadow-xl overflow-hidden transform transition-all">
      <div class="p-8 md:p-10">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-extrabold text-gray-900 tracking-tight">欢迎回来</h1>
          <p class="text-gray-500 mt-2 text-sm">登录你的云相册账号</p>
        </div>
        
        <form @submit.prevent="handleLogin" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">账号 / 邮箱</label>
            <input 
              v-model="form.username" 
              type="text" 
              class="w-full px-4 py-3 rounded-lg border border-gray-300 bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" 
              placeholder="请输入用户名"
              required
            >
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">密码</label>
            <input 
              v-model="form.password" 
              type="password" 
              class="w-full px-4 py-3 rounded-lg border border-gray-300 bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" 
              placeholder="请输入密码"
              required
            >
          </div>
          
          <button 
            type="submit" 
            class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded-lg shadow-lg hover:shadow-xl transition-all duration-200 transform hover:-translate-y-0.5"
            :disabled="loading"
          >
            <span v-if="loading">登录中...</span>
            <span v-else>立即登录</span>
          </button>
        </form>

        <div class="mt-6 text-center">
          <p class="text-sm text-gray-600">
            还没有账号? 
            <router-link to="/register" class="font-medium text-blue-600 hover:text-blue-500 transition-colors">
              免费注册
            </router-link>
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()
const loading = ref(false)
const form = reactive({ username: '', password: '' })

const handleLogin = async () => {
  loading.value = true
  try {
    const success = await auth.login(form.username, form.password)
    if (success) {
      router.push('/')
    } else {
      alert('登录失败，请检查用户名或密码')
    }
  } catch (e) {
    alert('登录发生错误')
  } finally {
    loading.value = false
  }
}
</script>