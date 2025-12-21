<script setup>
import { ref, onMounted, onUnmounted, watch, nextTick, computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import axios from 'axios'
import Cropper from 'cropperjs'
import 'cropperjs/dist/cropper.css'
import { Swiper, SwiperSlide } from 'swiper/vue'
import { Autoplay, Navigation, Pagination, Keyboard, EffectFade } from 'swiper/modules'
import 'swiper/css'
import 'swiper/css/navigation'
import 'swiper/css/pagination'
import 'swiper/css/effect-fade'

import { 
  CloudArrowUpIcon, XMarkIcon, MagnifyingGlassIcon,
  ChevronLeftIcon, ChevronRightIcon, 
  CheckCircleIcon, PlayCircleIcon, Square2StackIcon,
  TrashIcon, TagIcon, ScissorsIcon, CheckIcon,
  ArrowPathIcon, ExclamationTriangleIcon, PlusIcon, 
  ArrowUturnLeftIcon, AdjustmentsHorizontalIcon,
  SparklesIcon // <--- AI魔法棒图标
} from '@heroicons/vue/24/outline'
import { CheckCircleIcon as CheckCircleIconSolid } from '@heroicons/vue/24/solid'

const auth = useAuthStore()
const router = useRouter()
const modules = [Autoplay, Navigation, Pagination, Keyboard, EffectFade]

// --- 状态 ---
const images = ref([])
const loading = ref(false)
const searchQuery = ref('')
const showUploadModal = ref(false)
const isDragging = ref(false)
const uploading = ref(false)
const uploadResult = ref(null)
const fileInput = ref(null)

const selectedImage = ref(null)
const currentIndex = ref(-1)
const isSelectionMode = ref(false)
const selectedImageIds = ref(new Set())
const showSlideshow = ref(false)
const slideshowList = ref([])

// 编辑状态
const newTagInput = ref('')
const isCropping = ref(false)
const cropperInstance = ref(null)
const imageRef = ref(null)
const savingCrop = ref(false)

// 色调参数 (默认 1.0)
const editParams = ref({
  rotate: 0,
  brightness: 1.0,
  contrast: 1.0,
  saturation: 1.0
})

// 分页状态
const pagination = ref({
  page: 1,
  size: 12,
  total: 0,
  pages: 0
})

const isTrashMode = ref(false)
const activeTags = ref([]) 

// AI 分析状态
const isAnalyzing = ref(false)

// --- 获取图片 (支持分页) ---
const fetchImages = async (page = 1) => {
  loading.value = true
  try {
    const params = { 
      trash: isTrashMode.value,
      page: page,
      size: pagination.value.size
    }
    if (searchQuery.value) params.search = searchQuery.value
    if (activeTags.value.length > 0) params.tag = activeTags.value.join(',')
    
    params.t = new Date().getTime()
    const response = await axios.get('/images', { params })
    
    // 更新列表和分页信息
    images.value = response.data.items
    pagination.value.total = response.data.total
    pagination.value.page = response.data.page
    pagination.value.pages = response.data.pages
    
    // 刷新大图逻辑
    if (selectedImage.value) {
      const updatedImg = images.value.find(i => i.id === selectedImage.value.id)
      if (updatedImg) selectedImage.value = updatedImg
      else if (isTrashMode.value && !updatedImg) closeLightbox()
    }
  } catch (err) {
    if (err.response?.status === 401) handleLogout()
  } finally {
    loading.value = false
  }
}

// 分页跳转
const changePage = (newPage) => {
  if (newPage < 1 || newPage > pagination.value.pages) return
  fetchImages(newPage)
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

let searchTimeout
watch(searchQuery, () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => fetchImages(1), 500) // 搜索重置回第1页
})

watch(isTrashMode, () => {
  selectedImageIds.value.clear()
  isSelectionMode.value = false
  searchQuery.value = ''
  activeTags.value = []
  fetchImages(1)
})

watch(activeTags, () => { fetchImages(1) }, { deep: true })

const handleKeydown = (e) => {
  if (showSlideshow.value || isCropping.value) return 
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
  if (cropperInstance.value) cropperInstance.value.destroy()
})

const handleLogout = async () => {
  try { await axios.post('/auth/logout') } catch(e){}
  auth.user = null
  auth.isAuthenticated = false
  router.push('/login')
}

// --- 基础交互 ---
const toggleSelectionMode = () => { isSelectionMode.value = !isSelectionMode.value; selectedImageIds.value.clear() }
const toggleSelection = (id) => { selectedImageIds.value.has(id) ? selectedImageIds.value.delete(id) : selectedImageIds.value.add(id) }
const toggleSelectAll = () => { selectedImageIds.value.size === images.value.length ? selectedImageIds.value.clear() : images.value.forEach(img => selectedImageIds.value.add(img.id)) }
const startSlideshow = () => {
  if (selectedImageIds.value.size > 0) slideshowList.value = images.value.filter(img => selectedImageIds.value.has(img.id))
  else slideshowList.value = images.value
  if (slideshowList.value.length === 0) return alert("没有图片可播放")
  showSlideshow.value = true
}
const handleImageClick = (img) => { isSelectionMode.value ? toggleSelection(img.id) : openLightbox(img) }
const handleImageError = (e, img) => { if (e.target.src !== `${img.file}`) e.target.src = `${img.file}` }
const toggleTagFilter = (tag) => { if (activeTags.value.includes(tag)) activeTags.value = activeTags.value.filter(t => t !== tag); else activeTags.value.push(tag) }

// --- 批量操作 ---
const bulkDelete = async () => {
  if (selectedImageIds.value.size === 0) return
  if (!confirm(`确定要删除选中的 ${selectedImageIds.value.size} 张图片吗？`)) return
  try {
    await axios.post('/images/bulk_delete', { image_ids: Array.from(selectedImageIds.value) })
    selectedImageIds.value.clear()
    fetchImages(pagination.value.page)
  } catch(e) { alert("批量删除失败") }
}

// --- 上传 ---
const openUpload = () => { showUploadModal.value = true; uploadResult.value = null; }
const closeUpload = () => { showUploadModal.value = false; fetchImages(1); } // 上传后回第1页
const triggerFileSelect = () => fileInput.value.click()
const processUpload = async (file) => {
  if (!file || !file.type.startsWith('image/')) { alert('请上传图片'); return; }
  uploading.value = true
  const formData = new FormData()
  formData.append('file', file)
  try {
    const response = await axios.post('/upload', formData)
    uploadResult.value = response.data
    fetchImages(1)
  } catch (err) { alert('上传失败') } finally { uploading.value = false; isDragging.value = false }
}
const handleFileChange = (e) => { processUpload(e.target.files[0]); e.target.value = '' }
const onDragOver = () => isDragging.value = true
const onDragLeave = () => isDragging.value = false
const onDrop = (e) => { isDragging.value = false; if(e.dataTransfer.files.length) processUpload(e.dataTransfer.files[0]); }

// --- Lightbox ---
const openLightbox = (img) => { selectedImage.value = img; currentIndex.value = images.value.findIndex(i => i.id === img.id); isCropping.value = false; }
const closeLightbox = () => { selectedImage.value = null; currentIndex.value = -1; isCropping.value = false; if(cropperInstance.value) cropperInstance.value.destroy(); }
const nextImage = () => {
  if (images.value.length === 0 || isCropping.value) return
  if (currentIndex.value < images.value.length - 1) currentIndex.value++
  else currentIndex.value = 0
  selectedImage.value = images.value[currentIndex.value]
}
const prevImage = () => {
  if (images.value.length === 0 || isCropping.value) return
  if (currentIndex.value > 0) currentIndex.value--
  else currentIndex.value = images.value.length - 1
  selectedImage.value = images.value[currentIndex.value]
}

// --- 管理 API ---
const deleteImage = async () => { if (!confirm("确定移入回收站？")) return; try { await axios.delete(`/images/${selectedImage.value.id}`); closeLightbox(); fetchImages(pagination.value.page); } catch (e) { alert("删除失败") } }
const restoreImage = async (imgId = null) => { const id = imgId || selectedImage.value.id; try { await axios.post(`/images/${id}/restore`); if(selectedImage.value) closeLightbox(); fetchImages(pagination.value.page); } catch (e) { alert("还原失败") } }
const hardDeleteImage = async (imgId = null) => { const id = imgId || selectedImage.value.id; if (!confirm("永久删除不可恢复，确定？")) return; try { await axios.delete(`/images/${id}/hard`); if(selectedImage.value) closeLightbox(); fetchImages(pagination.value.page); } catch (e) { alert("删除失败") } }

const addTag = async (tagStr = null) => {
  const tag = tagStr || newTagInput.value.trim()
  if (!tag) return
  try {
    const res = await axios.post(`/images/${selectedImage.value.id}/tags`, { tag })
    selectedImage.value = res.data
    newTagInput.value = ''
    const idx = images.value.findIndex(i => i.id === selectedImage.value.id)
    if (idx !== -1) images.value[idx] = res.data
  } catch (e) { alert("添加失败") }
}

const removeTag = async (tag) => {
  try {
    const res = await axios.delete(`/images/${selectedImage.value.id}/tags/${tag}`)
    selectedImage.value = res.data
    const idx = images.value.findIndex(i => i.id === selectedImage.value.id)
    if (idx !== -1) images.value[idx] = res.data
  } catch (e) { alert("删除失败") }
}

const quickAddTag = async (img) => {
  const tag = prompt("新标签：")
  if (!tag) return
  try {
    await axios.post(`/images/${img.id}/tags`, { tag })
    fetchImages(pagination.value.page)
  } catch(e) { alert("失败") }
}

// AI 智能分析
const analyzeImage = async () => {
  if (isAnalyzing.value) return
  isAnalyzing.value = true
  try {
    const res = await axios.post(`/images/${selectedImage.value.id}/analyze`)
    selectedImage.value = res.data
    const idx = images.value.findIndex(i => i.id === selectedImage.value.id)
    if (idx !== -1) images.value[idx] = res.data
  } catch (e) {
    alert("AI 分析失败，请检查后端日志")
  } finally {
    isAnalyzing.value = false
  }
}

// 图片编辑功能
const startCrop = () => { 
  isCropping.value = true;
  editParams.value = { rotate: 0, brightness: 1.0, contrast: 1.0, saturation: 1.0 }
  nextTick(() => { 
    if (imageRef.value) cropperInstance.value = new Cropper(imageRef.value, { 
      viewMode: 1, background: false, autoCropArea: 0.8, rotatable: true 
    }) 
  }) 
}

const rotateImage = () => {
  if (cropperInstance.value) {
    cropperInstance.value.rotate(90)
    editParams.value.rotate = (editParams.value.rotate + 90) % 360
  }
}

const saveCrop = async () => { 
  if (!cropperInstance.value) return; 
  savingCrop.value = true; 
  const data = cropperInstance.value.getData(); 
  try { 
    const payload = {
      x: Math.round(data.x), y: Math.round(data.y), 
      width: Math.round(data.width), height: Math.round(data.height),
      rotate: editParams.value.rotate,
      brightness: parseFloat(editParams.value.brightness),
      contrast: parseFloat(editParams.value.contrast),
      saturation: parseFloat(editParams.value.saturation)
    }
    const res = await axios.post(`/images/${selectedImage.value.id}/crop`, payload); 
    cropperInstance.value.destroy(); 
    cropperInstance.value = null; 
    isCropping.value = false; 
    selectedImage.value = res.data
    await fetchImages(pagination.value.page); 
  } catch (e) { alert("保存失败") } finally { savingCrop.value = false } 
}
const cancelCrop = () => { if (cropperInstance.value) cropperInstance.value.destroy(); isCropping.value = false; }

//复制图片的ID
const copyId = async () => {
  if (!selectedImage.value) return
  try {
    await navigator.clipboard.writeText(selectedImage.value.id)
    alert("ID 已复制: " + selectedImage.value.id)
  } catch (err) {
    console.error('复制失败', err)
  }
}

// CSS 变量计算
const filterVars = computed(() => {
  return {
    '--brightness': editParams.value.brightness,
    '--contrast': editParams.value.contrast,
    '--saturation': editParams.value.saturation,
  }
})

const formatDate = (d) => d ? new Date(d).toLocaleDateString() : '未知日期'
</script>

<template>
  <div class="min-h-screen bg-gray-50 font-sans text-gray-900 pb-12">
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
                <input v-model="searchQuery" type="text" class="block w-full pl-10 pr-3 py-2 border border-gray-200 rounded-full bg-gray-50 focus:bg-white focus:ring-2 focus:ring-blue-500" placeholder="搜索图片标题、地点、标签..." />
             </div>
             <div v-if="activeTags.length > 0" class="absolute top-14 left-0 flex flex-wrap gap-2 px-1">
               <span v-for="tag in activeTags" :key="tag" class="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-700 text-xs rounded-full font-medium shadow-sm">
                 #{{ tag }} <button @click="toggleTagFilter(tag)" class="hover:text-blue-900"><XMarkIcon class="w-3 h-3"/></button>
               </span>
               <button @click="activeTags = []" class="text-xs text-gray-500 hover:text-gray-800 underline ml-2">清除所有</button>
             </div>
           </div>
           <div v-else class="flex-1 mx-4 text-center font-bold text-gray-700">已选择 {{ selectedImageIds.size }} 张</div>

           <div class="flex items-center gap-3">
             <button @click="isTrashMode = !isTrashMode" class="flex items-center gap-1 px-3 py-2 rounded-lg transition-colors" :class="isTrashMode ? 'bg-red-100 text-red-600' : 'text-gray-600 hover:text-gray-900'">
                <TrashIcon class="w-5 h-5" /><span class="hidden sm:inline">{{ isTrashMode ? '退出回收站' : '回收站' }}</span>
             </button>
             <template v-if="!isTrashMode">
                <template v-if="!isSelectionMode">
                  <button @click="startSlideshow" class="hidden sm:flex items-center gap-1 text-gray-600 hover:text-blue-600 px-3 py-2 rounded-lg transition-colors"><PlayCircleIcon class="w-6 h-6" /></button>
                  <button @click="toggleSelectionMode" class="flex items-center gap-1 text-gray-600 hover:text-blue-600 px-3 py-2 rounded-lg transition-colors"><Square2StackIcon class="w-5 h-5" /><span class="hidden sm:inline">选择</span></button>
                  <button @click="openUpload" class="flex items-center gap-2 bg-gray-900 text-white px-5 py-2 rounded-full text-sm shadow-lg hover:-translate-y-0.5 transition-all"><CloudArrowUpIcon class="w-4 h-4"/> <span class="hidden sm:inline">上传</span></button>
                </template>
                <template v-else>
                  <button @click="toggleSelectAll" class="text-gray-600 hover:text-blue-600 text-sm font-medium px-2">{{ selectedImageIds.size === images.length ? '取消全选' : '全选' }}</button>
                  <button @click="bulkDelete" class="flex items-center gap-2 bg-red-600 text-white px-5 py-2 rounded-full text-sm shadow-lg hover:bg-red-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed" :disabled="selectedImageIds.size === 0"><TrashIcon class="w-4 h-4"/> 删除选中</button>
                  <button @click="startSlideshow" class="flex items-center gap-2 bg-blue-600 text-white px-5 py-2 rounded-full text-sm shadow-lg hover:bg-blue-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed" :disabled="selectedImageIds.size === 0"><PlayCircleIcon class="w-4 h-4"/> 播放选中</button>
                  <button @click="toggleSelectionMode" class="text-gray-500 hover:text-gray-800 text-sm px-2">退出</button>
                </template>
             </template>
             <div class="flex items-center gap-3 pl-4 border-l border-gray-200 hidden sm:flex">
                <div class="text-right"><p class="text-sm font-bold text-gray-800">{{ auth.user?.username || 'User' }}</p></div>
                <button @click="handleLogout" class="text-gray-500 hover:text-red-600 text-sm">退出</button>
             </div>
           </div>
        </div>
       </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 select-none" :class="{'mt-6': activeTags.length > 0}">
      <div v-if="isTrashMode" class="mb-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg flex items-center gap-2">
        <ExclamationTriangleIcon class="w-5 h-5" /><span>回收站模式：删除将永久销毁文件。</span>
      </div>

      <div v-if="images.length > 0" class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
         <div v-for="img in images" :key="img.id" 
              class="group relative bg-white rounded-2xl shadow-sm overflow-hidden aspect-w-1 aspect-h-1 border border-gray-100 transition-all cursor-pointer"
              :class="{'ring-4 ring-blue-500 ring-offset-2': isSelectionMode && selectedImageIds.has(img.id)}"
              @click="handleImageClick(img)">
            <img :src="`${img.thumbnail || img.file}`" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500 bg-gray-100" @error="(e) => handleImageError(e, img)"/>
            
            <div v-if="!isSelectionMode" class="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity flex flex-col justify-end p-4 pointer-events-none">
                <p class="text-white text-sm font-medium truncate">{{ img.title }}</p>
                <div class="flex flex-wrap gap-1 mt-1">
                   <span v-for="tag in img.tags.slice(0, 2)" :key="tag" class="text-[10px] bg-white/20 text-white px-1.5 rounded">{{ tag }}</span>
                </div>
            </div>
            <button v-if="!isSelectionMode && !isTrashMode" @click.stop="quickAddTag(img)" class="absolute top-2 left-2 p-1.5 bg-white/90 rounded-full text-gray-600 hover:text-blue-600 opacity-0 group-hover:opacity-100 transition-opacity z-20 shadow-sm" title="快速添加标签"><PlusIcon class="w-4 h-4" /></button>
            <div v-if="isSelectionMode" class="absolute top-2 right-2 z-10">
               <div v-if="selectedImageIds.has(img.id)" class="text-blue-600 bg-white rounded-full"><CheckCircleIconSolid class="w-8 h-8" /></div>
               <div v-else class="text-white/80 hover:text-white drop-shadow-lg"><CheckCircleIcon class="w-8 h-8" /></div>
            </div>
         </div>
      </div>
      <div v-else-if="!loading" class="text-center py-20 text-gray-500">
         <p v-if="isTrashMode">回收站是空的</p>
         <p v-else-if="activeTags.length > 0">没有找到包含这些标签的图片</p>
         <p v-else>暂无图片，请点击右上角上传</p>
      </div>

      <div v-if="pagination.pages > 1" class="mt-12 flex justify-center items-center gap-4">
        <button @click="changePage(pagination.page - 1)" :disabled="pagination.page === 1" class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">上一页</button>
        <span class="text-sm text-gray-600">第 <span class="font-bold text-gray-900">{{ pagination.page }}</span> / {{ pagination.pages }} 页</span>
        <button @click="changePage(pagination.page + 1)" :disabled="pagination.page === pagination.pages" class="px-4 py-2 bg-white border border-gray-300 rounded-lg text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">下一页</button>
      </div>
    </main>

    <div v-if="showUploadModal" class="fixed inset-0 z-50 flex items-center justify-center p-4">
        <div class="fixed inset-0 bg-gray-900/60 backdrop-blur-sm" @click="closeUpload"></div>
        <div class="relative bg-white w-full max-w-xl rounded-2xl shadow-2xl p-6 transition-all transform">
            <div class="flex justify-between items-center mb-4"><h3 class="text-lg font-bold text-gray-800">上传图片</h3><button @click="closeUpload" class="p-1 hover:bg-gray-100 rounded-full"><XMarkIcon class="w-6 h-6 text-gray-500"/></button></div>
            <div v-if="!uploadResult" class="border-2 border-dashed rounded-xl p-10 text-center cursor-pointer transition-colors" :class="isDragging ? 'border-blue-500 bg-blue-50' : 'border-gray-300 hover:border-blue-400'" @click="triggerFileSelect" @dragover.prevent="onDragOver" @dragleave.prevent="onDragLeave" @drop.prevent="onDrop"><input type="file" ref="fileInput" class="hidden" accept="image/*" @change="handleFileChange" /><div v-if="uploading" class="animate-pulse text-blue-600 font-bold">正在上传...</div><div v-else><CloudArrowUpIcon class="w-12 h-12 text-blue-500 mx-auto mb-2"/><p class="text-gray-600">点击或拖拽上传</p></div></div>
            <div v-else class="bg-green-50 p-4 rounded-xl flex items-center gap-4"><img :src="`${uploadResult.file}`" class="w-16 h-16 object-cover rounded bg-gray-200"><div><p class="text-green-800 font-bold">上传成功</p><button @click="uploadResult=null" class="text-sm text-blue-600 underline mt-1">继续上传</button></div></div>
        </div>
    </div>

    <div v-if="showSlideshow" class="fixed inset-0 z-[100] bg-black text-white flex flex-col">
       <div class="absolute top-0 left-0 right-0 z-20 p-4 flex justify-between items-center bg-gradient-to-b from-black/80 to-transparent opacity-0 hover:opacity-100 transition-opacity duration-300">
          <div class="text-sm font-medium">{{ slideshowList.length }} 张图片轮播中</div>
          <button @click="showSlideshow = false" class="bg-white/10 hover:bg-white/20 p-2 rounded-full backdrop-blur-md transition-colors"><XMarkIcon class="w-6 h-6" /></button>
       </div>
       <swiper :modules="modules" :slides-per-view="1" :space-between="30" :loop="slideshowList.length > 1" :effect="'fade'" :fade-effect="{ crossFade: true }" :autoplay="{ delay: 3000, disableOnInteraction: false, pauseOnMouseEnter: true }" :keyboard="{ enabled: true }" :pagination="{ clickable: true, dynamicBullets: true }" :navigation="true" class="w-full h-full"><swiper-slide v-for="img in slideshowList" :key="img.id" class="flex items-center justify-center bg-black"><div class="w-full h-full flex items-center justify-center p-4 md:p-10 relative"><img :src="`${img.file}`" class="max-w-full max-h-full object-contain shadow-2xl" loading="lazy" /><div class="absolute bottom-10 left-0 right-0 text-center pointer-events-none"><p class="text-white/90 text-lg font-bold drop-shadow-md">{{ img.title }}</p><p class="text-white/70 text-sm drop-shadow-md">{{ formatDate(img.shot_time) }}</p></div></div></swiper-slide></swiper>
    </div>

    <div v-if="selectedImage && !showSlideshow" class="fixed inset-0 z-[60] flex items-center justify-center bg-black/95 backdrop-blur-sm">
      <button @click="closeLightbox" class="absolute top-4 right-4 text-white/70 hover:text-white p-2 z-[70] bg-white/10 rounded-full"><XMarkIcon class="w-8 h-8" /></button>
      <template v-if="!isCropping && images.length > 1"><button @click.stop="prevImage" class="absolute left-4 top-1/2 -translate-y-1/2 p-3 rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors z-[70]"><ChevronLeftIcon class="w-8 h-8" /></button><button @click.stop="nextImage" class="absolute right-4 top-1/2 -translate-y-1/2 p-3 rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors z-[70]"><ChevronRightIcon class="w-8 h-8" /></button></template>
      <div class="flex flex-col md:flex-row w-full h-full max-w-7xl mx-auto p-4 gap-4" @click.stop>
        
        <div 
          class="flex-1 flex items-center justify-center relative overflow-hidden bg-black/50 rounded-lg"
          :style="filterVars"
        >
          <img ref="imageRef" :key="selectedImage.id + (isCropping ? '-crop' : '')" :src="`${selectedImage.file}?t=${new Date().getTime()}`" class="max-w-full max-h-[80vh] object-contain shadow-2xl transition-opacity duration-300" 
               :class="{'opacity-100': !savingCrop, 'opacity-50': savingCrop}" />
          
          <div v-if="isCropping" class="absolute bottom-6 z-[80] flex flex-col items-center gap-4 w-full px-4">
             <div class="bg-black/60 backdrop-blur-md p-4 rounded-xl flex gap-6 text-white text-xs w-full max-w-lg">
                <div class="flex-1"><div class="flex justify-between mb-1"><span>亮度</span><span>{{ editParams.brightness }}</span></div><input type="range" min="0" max="2" step="0.1" v-model="editParams.brightness" class="w-full h-1 bg-gray-600 rounded-lg appearance-none cursor-pointer"></div>
                <div class="flex-1"><div class="flex justify-between mb-1"><span>对比度</span><span>{{ editParams.contrast }}</span></div><input type="range" min="0" max="2" step="0.1" v-model="editParams.contrast" class="w-full h-1 bg-gray-600 rounded-lg appearance-none cursor-pointer"></div>
                <div class="flex-1"><div class="flex justify-between mb-1"><span>饱和度</span><span>{{ editParams.saturation }}</span></div><input type="range" min="0" max="2" step="0.1" v-model="editParams.saturation" class="w-full h-1 bg-gray-600 rounded-lg appearance-none cursor-pointer"></div>
             </div>
             <div class="flex gap-4">
               <button @click="rotateImage" class="bg-white text-gray-800 px-4 py-2 rounded-full font-bold shadow-lg hover:bg-gray-100 flex items-center gap-2"><ArrowUturnLeftIcon class="w-5 h-5" /> 旋转</button>
               <button @click="saveCrop" class="bg-green-600 text-white px-6 py-2 rounded-full font-bold shadow-lg hover:bg-green-700 flex items-center gap-2"><CheckIcon class="w-5 h-5" /> 另存为新图</button>
               <button @click="cancelCrop" class="bg-white text-gray-800 px-6 py-2 rounded-full font-bold shadow-lg hover:bg-gray-100">取消</button>
             </div>
          </div>
        </div>

        <div class="w-full md:w-80 bg-gray-900/80 text-white p-6 rounded-2xl backdrop-blur-md h-fit md:self-center border border-white/10 flex flex-col gap-6">
          <div><h2 class="text-lg font-bold mb-2 break-words">{{ selectedImage.title }}</h2><div class="space-y-1 text-sm text-gray-400">
              <p>日期: {{ formatDate(selectedImage.shot_time) }}</p>
              <p>尺寸: {{ selectedImage.width }} x {{ selectedImage.height }}</p>
              <p>大小: {{ (selectedImage.size / 1024).toFixed(1) }} KB</p>
              
              <div class="flex items-center gap-2 group pt-1">
                <p class="font-mono text-xs text-gray-500 truncate max-w-[150px]" title="Image ID">
                  ID: {{ selectedImage.id }}
                </p>
                <button 
                  @click="copyId" 
                  class="text-blue-500 hover:text-blue-400 text-xs opacity-0 group-hover:opacity-100 transition-opacity"
                >
                  复制
                </button>
              </div>

              <p v-if="selectedImage.deleted_at" class="text-red-400 font-bold mt-2">已在回收站</p>
            </div></div>
          
          <div>
             <div class="flex items-center justify-between mb-2">
                <div class="flex items-center gap-2 text-sm font-bold text-gray-300">
                  <TagIcon class="w-4 h-4" /> 标签
                </div>
                <button 
                  v-if="!isTrashMode"
                  @click="analyzeImage" 
                  :disabled="isAnalyzing"
                  class="text-xs flex items-center gap-1 px-2 py-1 rounded bg-gradient-to-r from-purple-600 to-blue-600 text-white hover:from-purple-500 hover:to-blue-500 disabled:opacity-50 transition-all"
                  title="AI 自动识别图片内容"
                >
                  <SparklesIcon class="w-3 h-3" :class="{'animate-spin': isAnalyzing}" />
                  {{ isAnalyzing ? '分析中...' : 'AI 识别' }}
                </button>
             </div>
             <div class="flex flex-wrap gap-2 mb-3"><span v-for="tag in selectedImage.tags" :key="tag" class="px-2 py-1 bg-blue-600/30 border border-blue-500/30 text-blue-200 text-xs rounded flex items-center gap-1 group">#{{ tag }}<button v-if="!isTrashMode" @click="removeTag(tag)" class="hover:text-white text-blue-300/50"><XMarkIcon class="w-3 h-3" /></button></span><span v-if="selectedImage.tags.length === 0" class="text-xs text-gray-500 italic">暂无标签</span></div><div v-if="!isTrashMode" class="flex gap-2"><input v-model="newTagInput" @keyup.enter="addTag(null)" type="text" placeholder="输入标签按回车..." class="bg-black/30 border border-white/10 rounded px-3 py-1.5 text-sm text-white focus:outline-none focus:border-blue-500 w-full" /><button @click="addTag(null)" class="bg-blue-600 hover:bg-blue-700 px-3 rounded text-sm">+</button></div>
          </div>
          
          <div class="pt-4 border-t border-white/10 flex flex-col gap-3"><template v-if="!isTrashMode"><button v-if="!isCropping" @click="startCrop" class="w-full py-2 bg-gray-700 hover:bg-gray-600 rounded-lg flex items-center justify-center gap-2 transition-colors"><ScissorsIcon class="w-4 h-4" /> 编辑 / 裁剪</button><button @click="deleteImage" class="w-full py-2 bg-red-600/20 hover:bg-red-600/40 text-red-300 hover:text-red-100 rounded-lg flex items-center justify-center gap-2 transition-colors border border-red-500/20"><TrashIcon class="w-4 h-4" /> 移入回收站</button></template><template v-else><button @click="restoreImage(null)" class="w-full py-2 bg-green-600/20 hover:bg-green-600/40 text-green-300 hover:text-green-100 rounded-lg flex items-center justify-center gap-2 transition-colors border border-green-500/20"><ArrowPathIcon class="w-4 h-4" /> 还原图片</button><button @click="hardDeleteImage(null)" class="w-full py-2 bg-red-800/40 hover:bg-red-700 text-red-200 hover:text-white rounded-lg flex items-center justify-center gap-2 transition-colors border border-red-500/40"><TrashIcon class="w-4 h-4" /> 永久删除</button></template></div>
        </div>
      </div>
    </div>
  </div>
</template>

<style>
/* Swiper 样式微调 */
.swiper-button-next, .swiper-button-prev { color: white !important; text-shadow: 0 2px 4px rgba(0,0,0,0.5); }
.swiper-pagination-bullet { background: white !important; opacity: 0.5; }
.swiper-pagination-bullet-active { opacity: 1; }

/* Cropper 样式适配 */
.cropper-modal { opacity: 0.8; background-color: #000; }
.cropper-view-box { outline: 1px solid #3b82f6; outline-color: rgba(59, 130, 246, 0.75); }
.cropper-line { background-color: #3b82f6; }
.cropper-point { background-color: #3b82f6; }

/* 利用 CSS 变量强制应用滤镜，利用 GPU 加速，零卡顿 */
.cropper-container img {
  filter: brightness(var(--brightness)) contrast(var(--contrast)) saturate(var(--saturation)) !important;
  transition: filter 0.1s linear; 
}
</style>