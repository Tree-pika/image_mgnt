<template>
  <div class="flex min-h-screen items-center justify-center bg-gray-100">
    <div class="w-full max-w-md bg-white p-8 rounded-lg shadow-md">
      <h2 class="text-2xl font-bold text-center mb-6 text-gray-800">注册新账号</h2>
      
      <form @submit.prevent="handleRegister" class="space-y-4">
        <div>
          <label class="block text-gray-700">用户名</label>
          <input v-model="form.username" type="text" class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500" required>
        </div>
        <div>
          <label class="block text-gray-700">邮箱</label>
          <input v-model="form.email" type="email" class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500" required>
        </div>
        <div>
          <label class="block text-gray-700">密码 (至少6位)</label>
          <input v-model="form.password" type="password" class="w-full px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-green-500" required>
        </div>
        
        <button type="submit" class="w-full bg-green-600 text-white py-2 rounded-lg hover:bg-green-700 transition">
          注册
        </button>
      </form>

      <p class="mt-4 text-center text-sm text-gray-600">
        已有账号? 
        <router-link to="/login" class="text-blue-500 hover:underline">去登录</router-link>
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
const form = reactive({ username: '', email: '', password: '' })

const handleRegister = async () => {
  try {
    await auth.register(form.username, form.email, form.password)
    alert('注册成功！请登录')
    router.push('/login')
  } catch (error) {
    alert('注册失败: ' + (error.message || '未知错误'))
  }
}
</script>