<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow-sm">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16 items-center">
          <h1 class="text-xl font-bold text-gray-800">我的云相册</h1>
          <div class="flex items-center space-x-4">
            <span v-if="auth.user" class="text-gray-600">欢迎, {{ auth.user.username }}</span>
            <button @click="handleLogout" class="text-red-500 hover:text-red-700 font-medium">
              退出
            </button>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-8 p-6 bg-white rounded-lg shadow-sm border border-gray-200 text-center">
        <p class="text-gray-500 mb-4">这里稍后放置上传按钮</p>
      </div>

      <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
         <div class="h-48 bg-gray-200 rounded-lg flex items-center justify-center text-gray-400">
           图片展示区
         </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()

const handleLogout = async () => {
  // 这里之后会调用后端注销接口
  auth.user = null
  auth.isAuthenticated = false
  router.push('/login')
}
</script>