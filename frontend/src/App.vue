<!-- <script setup>
import HelloWorld from './components/HelloWorld.vue'
</script>

<template>
  <div>
    <a href="https://vite.dev" target="_blank">
      <img src="/vite.svg" class="logo" alt="Vite logo" />
    </a>
    <a href="https://vuejs.org/" target="_blank">
      <img src="./assets/vue.svg" class="logo vue" alt="Vue logo" />
    </a>
  </div>
  <HelloWorld msg="Vite + Vue" />
</template>

<style scoped>
.logo {
  height: 6em;
  padding: 1.5em;
  will-change: filter;
  transition: filter 300ms;
}
.logo:hover {
  filter: drop-shadow(0 0 2em #646cffaa);
}
.logo.vue:hover {
  filter: drop-shadow(0 0 2em #42b883aa);
}
</style> -->
<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

// 配置 Axios 基础路径 (指向Django 后端)
axios.defaults.baseURL = 'http://127.0.0.1:8000/api'

const fileInput = ref(null)
const uploading = ref(false)
const uploadResult = ref(null)
const errorMsg = ref('')

// 触发文件选择
const triggerUpload = () => {
  fileInput.value.click()
}

// 处理上传
const handleFileChange = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  // 简单验证
  if (!file.type.startsWith('image/')) {
    alert('请上传图片文件')
    return
  }

  uploading.value = true
  errorMsg.value = ''
  uploadResult.value = null

  const formData = new FormData()
  formData.append('file', file)

  try {
    // 发送 POST 请求到后端
    const response = await axios.post('/upload', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    })
    console.log('上传成功:', response.data)
    uploadResult.value = response.data
  } catch (err) {
    console.error(err)
    errorMsg.value = '上传失败，请检查后端是否启动或跨域设置'
  } finally {
    uploading.value = false
    // 清空 input 防止重复上传同一文件不触发 change
    event.target.value = ''
  }
}

// 格式化日期
const formatDate = (dateStr) => {
  if (!dateStr) return '未知时间'
  return new Date(dateStr).toLocaleString()
}
</script>

<template>
  <div class="min-h-screen bg-gray-50 p-4 md:p-8">
    <div class="max-w-3xl mx-auto">
      
      <header class="mb-8 text-center">
        <h1 class="text-3xl font-bold text-gray-800">我的云相册</h1>
        <p class="text-gray-500 mt-2">Step 5: 图片上传与 EXIF 解析测试</p>
      </header>

      <div class="bg-white rounded-xl shadow-md p-6 mb-8 transition-all">
        <div 
          class="border-2 border-dashed border-blue-300 rounded-lg p-8 text-center hover:bg-blue-50 cursor-pointer transition-colors"
          @click="triggerUpload"
        >
          <input 
            type="file" 
            ref="fileInput" 
            class="hidden" 
            accept="image/*" 
            @change="handleFileChange"
          />
          
          <div v-if="uploading" class="text-blue-600 font-semibold">
            <svg class="animate-spin h-8 w-8 mx-auto mb-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            正在分析并上传...
          </div>
          
          <div v-else>
            <div class="mx-auto h-12 w-12 text-blue-400 mb-3">
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V16.5m-13.5-9L12 3m0 0l4.5 4.5M12 3v13.5" />
              </svg>
            </div>
            <p class="text-lg font-medium text-gray-700">点击上传图片</p>
            <p class="text-sm text-gray-400 mt-1">支持 JPG, PNG (会自动提取 EXIF)</p>
          </div>
        </div>
        
        <div v-if="errorMsg" class="mt-4 p-3 bg-red-100 text-red-700 rounded-md text-sm">
          {{ errorMsg }}
        </div>
      </div>

      <div v-if="uploadResult" class="bg-white rounded-xl shadow-md overflow-hidden">
        <div class="p-4 border-b border-gray-100 bg-green-50">
          <h3 class="text-green-800 font-semibold flex items-center">
            <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path></svg>
            上传成功！数据库记录已创建
          </h3>
        </div>
        
        <div class="p-6 md:flex gap-6">
          <div class="md:w-1/3 mb-4 md:mb-0">
             <img 
              :src="`http://127.0.0.1:8000${uploadResult.file}`" 
              class="w-full h-48 object-cover rounded-lg shadow-sm bg-gray-200"
              alt="Uploaded"
            />
            <p class="text-xs text-center text-gray-400 mt-2">ID: {{ uploadResult.id }}</p>
          </div>

          <div class="md:w-2/3 space-y-3">
            <div>
              <span class="text-xs font-bold text-gray-400 uppercase tracking-wider">文件名</span>
              <p class="text-gray-800 truncate">{{ uploadResult.title }}</p>
            </div>
            
            <div class="grid grid-cols-2 gap-4">
              <div>
                <span class="text-xs font-bold text-gray-400 uppercase tracking-wider">拍摄时间</span>
                <p class="text-blue-600 font-medium">{{ formatDate(uploadResult.shot_time) }}</p>
              </div>
              <div>
                <span class="text-xs font-bold text-gray-400 uppercase tracking-wider">尺寸</span>
                <p class="text-gray-800">{{ uploadResult.width }} x {{ uploadResult.height }}</p>
              </div>
            </div>

            <div>
              <span class="text-xs font-bold text-gray-400 uppercase tracking-wider">当前标签</span>
              <div class="flex flex-wrap gap-2 mt-1">
                <span v-if="uploadResult.tags.length === 0" class="text-sm text-gray-400 italic">暂无标签</span>
                <span 
                  v-for="tag in uploadResult.tags" 
                  :key="tag"
                  class="px-2 py-1 bg-gray-100 text-gray-600 text-xs rounded-full"
                >
                  {{ tag }}
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>