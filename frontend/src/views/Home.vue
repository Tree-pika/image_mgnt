<script setup>
import { ref } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import axios from 'axios'

// --- 初始化 ---
const auth = useAuthStore()
const router = useRouter()
axios.defaults.baseURL = 'http://127.0.0.1:8000/api'
axios.defaults.withCredentials = true 

// --- 状态管理 ---
const showUploadModal = ref(false) // 控制上传弹窗显示
const isDragging = ref(false)
const uploading = ref(false)
const uploadResult = ref(null)
const fileInput = ref(null)

// --- 方法 ---

// 登出
const handleLogout = async () => {
  await axios.post('/auth/logout')
  auth.user = null
  auth.isAuthenticated = false
  router.push('/login')
}

// 打开/关闭上传框
const openUpload = () => { showUploadModal.value = true; uploadResult.value = null; }
const closeUpload = () => { showUploadModal.value = false; }

// 触发文件选择
const triggerFileSelect = () => fileInput.value.click()

// 处理文件上传核心逻辑
const processUpload = async (file) => {
  if (!file || !file.type.startsWith('image/')) {
    alert('请上传图片文件')
    return
  }

  uploading.value = true
  const formData = new FormData()
  formData.append('file', file)

  try {
    const response = await axios.post('/upload', formData)
    // 上传成功，显示结果
    uploadResult.value = response.data
    console.log("上传结果:", response.data)
  } catch (err) {
    alert('上传失败: ' + (err.response?.data?.message || '网络错误'))
  } finally {
    uploading.value = false
    isDragging.value = false
  }
}

// 文件 input 改变事件
const handleFileChange = (e) => {
  processUpload(e.target.files[0])
  e.target.value = '' // 重置，允许重复上传同名文件
}

// 拖拽相关事件
const onDragOver = () => { isDragging.value = true }
const onDragLeave = () => { isDragging.value = false }
const onDrop = (e) => {
  isDragging.value = false
  const files = e.dataTransfer.files
  if (files.length > 0) processUpload(files[0])
}

// 日期格式化
const formatDate = (d) => d ? new Date(d).toLocaleDateString() + ' ' + new Date(d).toLocaleTimeString() : '未知'
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    
    <nav class="sticky top-0 z-30 bg-white/80 backdrop-blur-md border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16 items-center">
          <div class="flex items-center gap-2 cursor-pointer" @click="router.push('/')">
            <div class="w-8 h-8 bg-gradient-to-br from-blue-500 to-purple-600 rounded-lg flex items-center justify-center text-white font-bold shadow-md">
              C
            </div>
            <span class="text-xl font-bold text-gray-800 tracking-tight">CloudGallery</span>
          </div>

          <div class="flex items-center gap-4">
            <button 
              @click="openUpload"
              class="hidden md:flex items-center gap-2 bg-gray-900 hover:bg-black text-white px-4 py-2 rounded-full text-sm font-medium transition-all shadow-sm hover:shadow-md"
            >
              <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
              上传图片
            </button>

            <div class="flex items-center gap-3 pl-4 border-l border-gray-200">
              <span class="text-sm font-medium text-gray-700 hidden sm:block">{{ auth.user?.username || 'User' }}</span>
              <button 
                @click="handleLogout" 
                class="text-sm text-gray-500 hover:text-red-600 transition-colors"
              >
                退出
              </button>
            </div>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      
      <div class="md:hidden mb-6">
        <button 
          @click="openUpload"
          class="w-full flex justify-center items-center gap-2 bg-gray-900 text-white py-3 rounded-xl font-medium shadow-lg"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path></svg>
          上传新照片
        </button>
      </div>

      <div class="text-center py-20">
        <div class="inline-block p-6 rounded-full bg-gray-100 mb-4">
           <svg class="w-10 h-10 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
        </div>
        <h3 class="text-lg font-medium text-gray-900">暂无图片展示</h3>
        <p class="text-gray-500 mt-1">点击右上角上传按钮添加你的第一张图片</p>
      </div>

    </main>

    <div v-if="showUploadModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-gray-900/50 backdrop-blur-sm transition-opacity" @click="closeUpload"></div>
      
      <div class="relative bg-white w-full max-w-2xl rounded-2xl shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
        
        <div class="flex justify-between items-center p-5 border-b border-gray-100">
          <h3 class="text-lg font-bold text-gray-800">上传图片</h3>
          <button @click="closeUpload" class="p-1 hover:bg-gray-100 rounded-full transition">
            <svg class="w-6 h-6 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
          </button>
        </div>

        <div class="p-6 overflow-y-auto">
          
          <div 
            v-if="!uploadResult"
            class="border-2 border-dashed rounded-xl p-10 text-center transition-all duration-200 group cursor-pointer"
            :class="isDragging ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-blue-400 hover:bg-gray-50'"
            @dragover.prevent="onDragOver"
            @dragleave.prevent="onDragLeave"
            @drop.prevent="onDrop"
            @click="triggerFileSelect"
          >
            <input type="file" ref="fileInput" class="hidden" accept="image/*" @change="handleFileChange" />
            
            <div v-if="uploading" class="py-8">
              <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600 mx-auto mb-4"></div>
              <p class="text-gray-600">正在解析 EXIF 并上传...</p>
            </div>
            
            <div v-else class="py-4">
              <div class="mx-auto w-16 h-16 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                <svg class="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path></svg>
              </div>
              <p class="text-lg font-medium text-gray-900">点击或拖拽图片到此处</p>
              <p class="text-sm text-gray-500 mt-2">支持 JPG, PNG 自动提取元数据</p>
            </div>
          </div>

          <div v-else class="bg-green-50 rounded-xl border border-green-100 overflow-hidden">
            <div class="p-3 bg-green-100 text-green-800 text-sm font-medium flex items-center justify-between">
              <span class="flex items-center"><svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg> 上传成功</span>
              <button @click="uploadResult = null" class="text-green-700 hover:text-green-900 text-xs underline">继续上传</button>
            </div>
            
            <div class="p-5 flex flex-col md:flex-row gap-6">
              <div class="md:w-1/3 h-40 bg-gray-200 rounded-lg overflow-hidden shadow-sm">
                <img :src="`http://127.0.0.1:8000${uploadResult.file}`" class="w-full h-full object-cover" />
              </div>
              <div class="flex-1 space-y-3">
                <div>
                  <span class="text-xs font-bold text-gray-400 uppercase">文件名</span>
                  <p class="text-gray-800 font-medium truncate">{{ uploadResult.title }}</p>
                </div>
                <div class="grid grid-cols-2 gap-4">
                   <div>
                    <span class="text-xs font-bold text-gray-400 uppercase">拍摄时间</span>
                    <p class="text-blue-600 font-semibold">{{ formatDate(uploadResult.shot_time) }}</p>
                  </div>
                  <div>
                    <span class="text-xs font-bold text-gray-400 uppercase">分辨率</span>
                    <p class="text-gray-600">{{ uploadResult.width }} x {{ uploadResult.height }}</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>

  </div>
</template>