<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-indigo-100 p-4">
    <div class="bg-white w-full max-w-md rounded-2xl shadow-xl overflow-hidden transform transition-all">
      <div class="p-8 md:p-10">
        <div class="text-center mb-8">
          <h1 class="text-3xl font-extrabold text-gray-900 tracking-tight">CloudGallery</h1>
          <div class="flex justify-center gap-6 mt-4 border-b border-gray-100 pb-2">
            <button 
              @click="isRegister = false" 
              class="pb-2 text-sm font-bold transition-all"
              :class="!isRegister ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-400 hover:text-gray-600'"
            >
              登录
            </button>
            <button 
              @click="isRegister = true" 
              class="pb-2 text-sm font-bold transition-all"
              :class="isRegister ? 'text-blue-600 border-b-2 border-blue-600' : 'text-gray-400 hover:text-gray-600'"
            >
              注册新账号
            </button>
          </div>
        </div>
        
        <form v-if="!isRegister" @submit.prevent="handleLogin" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">账号 / 邮箱</label>
            <input 
              v-model="loginForm.username" 
              type="text" 
              class="w-full px-4 py-3 rounded-lg border border-gray-300 bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all" 
              placeholder="请输入用户名"
              required
            >
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">密码</label>
            <input 
              v-model="loginForm.password" 
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

        <form v-else @submit.prevent="handleRegister" class="space-y-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">用户名</label>
            <input 
              v-model="registerForm.username" 
              type="text" 
              class="w-full px-4 py-3 rounded-lg border border-gray-300 bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none transition-all" 
              placeholder="设置用户名"
              required
            >
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">电子邮箱</label>
            <input 
              v-model="registerForm.email" 
              type="email" 
              class="w-full px-4 py-3 rounded-lg border border-gray-300 bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none transition-all" 
              placeholder="例如: example@163.com"
              required
            >
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">邮箱验证码</label>
            <div class="flex gap-2">
              <input 
                v-model="registerForm.code" 
                type="text" 
                class="w-full px-4 py-3 rounded-lg border border-gray-300 bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none transition-all" 
                placeholder="6位验证码"
                required
              >
              <button 
                type="button"
                @click="sendCode"
                :disabled="isCounting"
                class="whitespace-nowrap px-4 py-3 bg-indigo-100 text-indigo-700 font-bold rounded-lg hover:bg-indigo-200 disabled:opacity-50 disabled:cursor-not-allowed transition-colors min-w-[120px]"
              >
                {{ isCounting ? `${countdown}秒后重发` : '获取验证码' }}
              </button>
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">密码</label>
            <input 
              v-model="registerForm.password" 
              type="password" 
              class="w-full px-4 py-3 rounded-lg border border-gray-300 bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none transition-all" 
              placeholder="设置密码 (至少6位)"
              required
            >
          </div>

          <button 
            type="submit" 
            class="w-full bg-green-600 hover:bg-green-700 text-white font-bold py-3 rounded-lg shadow-lg hover:shadow-xl transition-all duration-200 transform hover:-translate-y-0.5"
            :disabled="loading"
          >
            <span v-if="loading">注册中...</span>
            <span v-else>注册并登录</span>
          </button>
        </form>

      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import axios from 'axios'

const auth = useAuthStore()
const router = useRouter()
const loading = ref(false)

// 状态切换
const isRegister = ref(false)

// 登录表单
const loginForm = reactive({ username: '', password: '' })

// 注册表单
const registerForm = reactive({
  username: '',
  password: '',
  email: '',
  code: ''
})

// 倒计时逻辑
const isCounting = ref(false)
const countdown = ref(60)

// 登录逻辑
const handleLogin = async () => {
  loading.value = true
  try {
    const success = await auth.login(loginForm.username, loginForm.password)
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

// 发送验证码
const sendCode = async () => {
  if (!registerForm.email) {
    alert("请先填写邮箱地址")
    return
  }
  
  try {
    // 调用后端接口
    await axios.post('/auth/send-code', { email: registerForm.email })
    alert("验证码已发送，请查收邮箱！")
    
    // 开始倒计时
    isCounting.value = true
    countdown.value = 60
    const timer = setInterval(() => {
      countdown.value--
      if (countdown.value <= 0) {
        clearInterval(timer)
        isCounting.value = false
      }
    }, 1000)
    
  } catch (err) {
    const msg = err.response?.data?.message || "发送失败"
    alert(msg)
  }
}

// 注册逻辑
const handleRegister = async () => {
  if (registerForm.password.length < 6) {
    alert("密码至少需要6位")
    return
  }
  
  loading.value = true
  try {
    // 调用注册接口
    await axios.post('/auth/register', registerForm)
    alert("注册成功！")
    
    // 自动登录
    const success = await auth.login(registerForm.username, registerForm.password)
    if (success) router.push('/')
    
  } catch (err) {
    const msg = err.response?.data?.message || "注册失败"
    alert(msg)
  } finally {
    loading.value = false
  }
}
</script>