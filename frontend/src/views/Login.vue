<template>
  <div class="flex min-h-screen items-center justify-center bg-gray-100">
    <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-md">
      <h2 class="text-2xl font-bold text-center mb-6 text-gray-800">用户登录</h2>
      
      <form @submit.prevent="handleLogin" class="space-y-4">
        <div>
          <label class="block text-gray-700">用户名 或 邮箱</label>
          <input v-model="form.username" type="text" class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" required>
        </div>
        <div>
          <label class="block text-gray-700">密码</label>
          <input v-model="form.password" type="password" class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500" required>
        </div>
        
        <button type="submit" class="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition">
          登录
        </button>
      </form>

      <p class="mt-4 text-center text-sm text-gray-600">
        还没有账号? 
        <router-link to="/register" class="text-blue-500 hover:underline">去注册</router-link>
      </p>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()
const form = reactive({ username: '', password: '' })

const handleLogin = async () => {
  const success = await auth.login(form.username, form.password)
  if (success) {
    // alert('登录成功！')
    router.push('/')
  } else {
    alert('登录失败，请检查用户名或密码')
  }
}
</script>