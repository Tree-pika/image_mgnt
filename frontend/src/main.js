import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import App from './App.vue'
import router from './router'
import axios from 'axios'


// --- 动态配置后端地址 ---
// 逻辑：如果浏览器访问的是 localhost，就请求 http://localhost:8000
//      如果浏览器访问的是 127.0.0.1，就请求 http://127.0.0.1:8000
// 这样可以避免跨域造成的 Cookie 丢失问题
const hostname = window.location.hostname; 
const apiBaseURL = `http://${hostname}:8000/api`;

axios.defaults.baseURL = apiBaseURL;

// 2、允许携带 Cookie (Session ID)
axios.defaults.withCredentials = true 

// 3. 自动处理 Django 的 CSRF Token 
axios.defaults.xsrfCookieName = 'csrftoken'
axios.defaults.xsrfHeaderName = 'X-CSRFToken'
const app = createApp(App)

app.use(createPinia()) // 使用 Pinia
app.use(router)
app.mount('#app')