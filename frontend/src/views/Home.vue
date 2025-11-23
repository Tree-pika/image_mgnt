<script setup>
import { ref, onMounted, onUnmounted, watch, computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import axios from 'axios'
// --- Swiper 相关导入 ---
import { Swiper, SwiperSlide } from 'swiper/vue'
import { Autoplay, Navigation, Pagination, Keyboard, EffectFade } from 'swiper/modules'
import 'swiper/css'
import 'swiper/css/navigation'
import 'swiper/css/pagination'
import 'swiper/css/effect-fade'

import { 
  CloudArrowUpIcon, XMarkIcon, MagnifyingGlassIcon,
  ChevronLeftIcon, ChevronRightIcon, 
  CheckCircleIcon, PlayCircleIcon, Square2StackIcon // 新增图标
} from '@heroicons/vue/24/outline'
import { CheckCircleIcon as CheckCircleIconSolid } from '@heroicons/vue/24/solid'

// --- 初始化 ---
const auth = useAuthStore()
const router = useRouter()
const modules = [Autoplay, Navigation, Pagination, Keyboard, EffectFade] // Swiper 模块

// --- 状态 ---
const images = ref([])
const loading = ref(false)
const searchQuery = ref('')
const showUploadModal = ref(false)
const isDragging = ref(false)
const uploading = ref(false)
const uploadResult = ref(null)
const fileInput = ref(null)

// --- 轮播/大图状态 ---
const selectedImage = ref(null)
const currentIndex = ref(-1)

// --- 新增：选择模式与幻灯片状态 ---
const isSelectionMode = ref(false)
const selectedImageIds = ref(new Set()) // 使用 Set 存储选中的 ID
const showSlideshow = ref(false)
const slideshowList = ref([]) // 最终进入轮播的图片列表

// --- 获取图片 ---
const fetchImages = async () => {
  loading.value = true
  try {
    const params = {}
    if (searchQuery.value) params.search = searchQuery.value
    const response = await axios.get('/images', { params })
    images.value = response.data
  } catch (err) {
    if (err.response?.status === 401) handleLogout()
  } finally {
    loading.value = false
  }
}

// 搜索监听
let searchTimeout
watch(searchQuery, () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(fetchImages, 500)
})

// 键盘监听 (普通大图模式)
const handleKeydown = (e) => {
  if (showSlideshow.value) return // 如果正在播放幻灯片，交给 Swiper 处理
  if (!selectedImage.value) return
  if (e.key === 'ArrowRight') nextImage()
  if (e.key === 'ArrowLeft') prevImage()
  if (e.key === 'Escape') closeLightbox()
}

onMounted(() => {
  fetchImages()
  window.addEventListener('keydown', handleKeydown)
})

onUnmounted(() => {
  window.removeEventListener('keydown', handleKeydown)
})

const handleLogout = async () => {
  try { await axios.post('/auth/logout') } catch(e){}
  auth.user = null
  auth.isAuthenticated = false
  router.push('/login')
}

// --- 选择模式逻辑 ---
const toggleSelectionMode = () => {
  isSelectionMode.value = !isSelectionMode.value
  selectedImageIds.value.clear() // 退出或进入都清空一下，防止逻辑混乱
}

const toggleSelection = (id) => {
  if (selectedImageIds.value.has(id)) {
    selectedImageIds.value.delete(id)
  } else {
    selectedImageIds.value.add(id)
  }
}

// 全选/取消全选
const toggleSelectAll = () => {
  if (selectedImageIds.value.size === images.value.length) {
    selectedImageIds.value.clear()
  } else {
    images.value.forEach(img => selectedImageIds.value.add(img.id))
  }
}

// 开始幻灯片播放
const startSlideshow = () => {
  // 如果有选中的，播放选中的；如果没有选中的，播放当前列表所有图片
  if (selectedImageIds.value.size > 0) {
    // 保持原来的顺序
    slideshowList.value = images.value.filter(img => selectedImageIds.value.has(img.id))
  } else {
    slideshowList.value = images.value
  }
  
  if (slideshowList.value.length === 0) {
    alert("没有图片可播放")
    return
  }
  
  showSlideshow.value = true
}

// --- 普通网格点击处理 ---
const handleImageClick = (img) => {
  if (isSelectionMode.value) {
    toggleSelection(img.id)
  } else {
    openLightbox(img)
  }
}

// --- 上传逻辑 (保持不变) ---
const openUpload = () => { showUploadModal.value = true; uploadResult.value = null; }
const closeUpload = () => { showUploadModal.value = false; fetchImages(); }
const triggerFileSelect = () => fileInput.value.click()
const processUpload = async (file) => {
  if (!file || !file.type.startsWith('image/')) { alert('请上传图片'); return; }
  uploading.value = true
  const formData = new FormData()
  formData.append('file', file)
  try {
    const response = await axios.post('/upload', formData)
    uploadResult.value = response.data
    fetchImages()
  } catch (err) {
    alert('上传失败: ' + (err.response?.data?.message || '请检查是否登录'))
  } finally {
    uploading.value = false
    isDragging.value = false
  }
}
const handleFileChange = (e) => { processUpload(e.target.files[0]); e.target.value = '' }
const onDragOver = () => isDragging.value = true
const onDragLeave = () => isDragging.value = false
const onDrop = (e) => { isDragging.value = false; if(e.dataTransfer.files.length) processUpload(e.dataTransfer.files[0]); }

// --- 普通大图预览逻辑 (保持不变) ---
const openLightbox = (img) => {
  selectedImage.value = img
  currentIndex.value = images.value.findIndex(i => i.id === img.id)
}
const closeLightbox = () => { selectedImage.value = null; currentIndex.value = -1 }
const nextImage = () => {
  if (images.value.length === 0) return
  if (currentIndex.value < images.value.length - 1) currentIndex.value++
  else currentIndex.value = 0
  selectedImage.value = images.value[currentIndex.value]
}
const prevImage = () => {
  if (images.value.length === 0) return
  if (currentIndex.value > 0) currentIndex.value--
  else currentIndex.value = images.value.length - 1
  selectedImage.value = images.value[currentIndex.value]
}

const formatDate = (d) => d ? new Date(d).toLocaleDateString() : '未知日期'
</script>

<template>
  <div class="min-h-screen bg-gray-50 font-sans text-gray-900">
    
    <nav class="sticky top-0 z-30 bg-white/90 backdrop-blur-md border-b border-gray-200 transition-all">
       <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16 items-center gap-4">
           
           <div class="flex items-center gap-2 cursor-pointer flex-shrink-0" @click="router.push('/')">
              <span class="text-xl font-bold bg-clip-text text-transparent bg-gradient-to-r from-gray-900 to-gray-600">CloudGallery</span>
           </div>
           
           <div v-if="!isSelectionMode" class="flex-1 max-w-lg mx-4 hidden md:block">
             <div class="relative group">
                <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <MagnifyingGlassIcon class="h-5 w-5 text-gray-400" />
                </div>
                <input v-model="searchQuery" type="text" class="block w-full pl-10 pr-3 py-2 border border-gray-200 rounded-full bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500" placeholder="搜索图片..." />
             </div>
           </div>
           <div v-else class="flex-1 mx-4 text-center font-bold text-gray-700">
              已选择 {{ selectedImageIds.size }} 张图片
           </div>

           <div class="flex items-center gap-3">
             
             <template v-if="!isSelectionMode">
               <button @click="startSlideshow" class="hidden sm:flex items-center gap-1 text-gray-600 hover:text-blue-600 px-3 py-2 rounded-lg transition-colors" title="播放全部">
                 <PlayCircleIcon class="w-6 h-6" />
               </button>
               
               <button @click="toggleSelectionMode" class="flex items-center gap-1 text-gray-600 hover:text-blue-600 px-3 py-2 rounded-lg transition-colors">
                 <Square2StackIcon class="w-5 h-5" />
                 <span class="hidden sm:inline">选择</span>
               </button>

               <button @click="openUpload" class="flex items-center gap-2 bg-gray-900 text-white px-5 py-2 rounded-full text-sm shadow-lg hover:-translate-y-0.5 transition-all">
                 <CloudArrowUpIcon class="w-4 h-4"/> <span class="hidden sm:inline">上传</span>
               </button>
             </template>

             <template v-else>
               <button @click="toggleSelectAll" class="text-gray-600 hover:text-blue-600 text-sm font-medium px-2">
                 {{ selectedImageIds.size === images.length ? '取消全选' : '全选' }}
               </button>
               
               <button @click="startSlideshow" class="flex items-center gap-2 bg-blue-600 text-white px-5 py-2 rounded-full text-sm shadow-lg hover:bg-blue-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed" :disabled="selectedImageIds.size === 0">
                 <PlayCircleIcon class="w-4 h-4"/> 播放选中
               </button>
               
               <button @click="toggleSelectionMode" class="text-gray-500 hover:text-gray-800 text-sm px-2">
                 退出
               </button>
             </template>
             
             <div class="flex items-center gap-3 pl-4 border-l border-gray-200 hidden sm:flex">
                <div class="text-right">
                    <p class="text-sm font-bold text-gray-800">{{ auth.user?.username || 'User' }}</p>
                </div>
                <button @click="handleLogout" class="text-gray-500 hover:text-red-600 text-sm">退出</button>
             </div>
           </div>

        </div>
       </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 select-none">
      <div v-if="images.length > 0" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
         <div v-for="img in images" :key="img.id" 
              class="group relative bg-white rounded-2xl shadow-sm overflow-hidden aspect-w-1 aspect-h-1 border border-gray-100 transition-all cursor-pointer"
              :class="{'ring-4 ring-blue-500 ring-offset-2': isSelectionMode && selectedImageIds.has(img.id)}"
              @click="handleImageClick(img)">
            
            <img :src="`http://127.0.0.1:8000${img.thumbnail || img.file}`" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"/>
            
            <div v-if="!isSelectionMode" class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex items-end p-4 pointer-events-none">
                <p class="text-white text-sm font-medium truncate">{{ img.title }}</p>
            </div>

            <div v-if="isSelectionMode" class="absolute top-2 right-2 z-10">
               <div v-if="selectedImageIds.has(img.id)" class="text-blue-600 bg-white rounded-full">
                 <CheckCircleIconSolid class="w-8 h-8" />
               </div>
               <div v-else class="text-white/80 hover:text-white drop-shadow-lg">
                 <CheckCircleIcon class="w-8 h-8" />
               </div>
            </div>
         </div>
      </div>
      
      <div v-else-if="!loading" class="text-center py-20 text-gray-500">
         <p>暂无图片，请点击右上角上传</p>
      </div>
    </main>

    <div v-if="showUploadModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="fixed inset-0 bg-gray-900/60 backdrop-blur-sm" @click="closeUpload"></div>
        <div class="relative bg-white w-full max-w-xl rounded-2xl shadow-2xl p-6 transition-all transform">
            <div class="flex justify-between items-center mb-4">
                <h3 class="text-lg font-bold text-gray-800">上传图片</h3>
                <button @click="closeUpload" class="p-1 hover:bg-gray-100 rounded-full"><XMarkIcon class="w-6 h-6 text-gray-500"/></button>
            </div>
            <div v-if="!uploadResult" class="border-2 border-dashed rounded-xl p-10 text-center cursor-pointer transition-colors"
                 :class="isDragging ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-blue-400'"
                 @click="triggerFileSelect" @dragover.prevent="onDragOver" @dragleave.prevent="onDragLeave" @drop.prevent="onDrop">
                 <input type="file" ref="fileInput" class="hidden" accept="image/*" @change="handleFileChange" />
                 <div v-if="uploading" class="animate-pulse text-blue-600 font-bold">正在上传...</div>
                 <div v-else>
                    <CloudArrowUpIcon class="w-12 h-12 text-blue-500 mx-auto mb-2"/>
                    <p class="text-gray-600">点击或拖拽上传</p>
                 </div>
            </div>
            <div v-else class="bg-green-50 p-4 rounded-xl flex items-center gap-4">
                 <img :src="`http://127.0.0.1:8000${uploadResult.file}`" class="w-16 h-16 object-cover rounded bg-gray-200">
                 <div>
                    <p class="text-green-800 font-bold">上传成功</p>
                    <button @click="uploadResult=null" class="text-sm text-blue-600 underline mt-1">继续上传</button>
                 </div>
            </div>
        </div>
    </div>

    <div v-if="showSlideshow" class="fixed inset-0 z-[100] bg-black text-white flex flex-col">
       <div class="absolute top-0 left-0 right-0 z-20 p-4 flex justify-between items-center bg-gradient-to-b from-black/80 to-transparent opacity-0 hover:opacity-100 transition-opacity duration-300">
          <div class="text-sm font-medium">
             {{ slideshowList.length }} 张图片轮播中
          </div>
          <button @click="showSlideshow = false" class="bg-white/10 hover:bg-white/20 p-2 rounded-full backdrop-blur-md transition-colors">
             <XMarkIcon class="w-6 h-6" />
          </button>
       </div>

       <swiper
          :modules="modules"
          :slides-per-view="1"
          :space-between="30"
          :loop="slideshowList.length > 1"
          :effect="'fade'"
          :fade-effect="{ crossFade: true }"
          :autoplay="{ delay: 3000, disableOnInteraction: false, pauseOnMouseEnter: true }"
          :keyboard="{ enabled: true }"
          :pagination="{ clickable: true, dynamicBullets: true }"
          :navigation="true"
          class="w-full h-full"
       >
          <swiper-slide v-for="img in slideshowList" :key="img.id" class="flex items-center justify-center bg-black">
             <div class="w-full h-full flex items-center justify-center p-4 md:p-10 relative">
                <img :src="`http://127.0.0.1:8000${img.file}`" 
                     class="max-w-full max-h-full object-contain shadow-2xl" 
                     loading="lazy" />
                
                <div class="absolute bottom-10 left-0 right-0 text-center pointer-events-none">
                   <p class="text-white/90 text-lg font-bold drop-shadow-md">{{ img.title }}</p>
                   <p class="text-white/70 text-sm drop-shadow-md">{{ formatDate(img.shot_time) }}</p>
                </div>
             </div>
          </swiper-slide>
       </swiper>
    </div>

    <div v-if="selectedImage && !showSlideshow" 
         class="fixed inset-0 z-[60] flex items-center justify-center bg-black/95 backdrop-blur-sm">
      <button @click="closeLightbox" class="absolute top-4 right-4 text-white/70 hover:text-white p-2 z-[70] bg-white/10 rounded-full">
        <XMarkIcon class="w-8 h-8" />
      </button>
      <button v-if="images.length > 1" @click.stop="prevImage" class="absolute left-4 top-1/2 -translate-y-1/2 p-3 rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors z-[70]">
        <ChevronLeftIcon class="w-8 h-8" />
      </button>
      <button v-if="images.length > 1" @click.stop="nextImage" class="absolute right-4 top-1/2 -translate-y-1/2 p-3 rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors z-[70]">
        <ChevronRightIcon class="w-8 h-8" />
      </button>
      <div class="flex flex-col md:flex-row w-full h-full max-w-7xl mx-auto p-4 gap-4" @click.stop>
        <div class="flex-1 flex items-center justify-center relative overflow-hidden">
          <img :key="selectedImage.id" :src="`http://127.0.0.1:8000${selectedImage.file}`" class="max-w-full max-h-[80vh] object-contain shadow-2xl rounded-sm transition-opacity duration-300"/>
        </div>
        <div class="w-full md:w-80 bg-gray-900/80 text-white p-6 rounded-2xl backdrop-blur-md h-fit md:self-center border border-white/10">
          <h2 class="text-lg font-bold mb-2 break-words">{{ selectedImage.title }}</h2>
          <div class="space-y-2 text-sm text-gray-300">
             <p>拍摄时间: <span class="text-white">{{ formatDate(selectedImage.shot_time) }}</span></p>
             <p>分辨率: {{ selectedImage.width }} x {{ selectedImage.height }}</p>
             <p>文件大小: {{ (selectedImage.size / 1024).toFixed(1) }} KB</p>
             <div class="flex flex-wrap gap-2 mt-4">
                <span v-for="tag in selectedImage.tags" :key="tag" class="px-2 py-1 bg-blue-600/30 text-blue-200 text-xs rounded">#{{ tag }}</span>
             </div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<style>
/* Swiper 样式微调 */
.swiper-button-next, .swiper-button-prev {
  color: white !important;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
}
.swiper-pagination-bullet {
  background: white !important;
  opacity: 0.5;
}
.swiper-pagination-bullet-active {
  opacity: 1;
}
</style>