import { createApp } from 'vue'
import { createPinia } from 'pinia'
import './style.css'
import App from './App.vue'
import router from './router'
import axios from 'axios'

// const hostname = window.location.hostname; 
// const apiBaseURL = `http://${hostname}:8000/api`;
// axios.defaults.baseURL = apiBaseURL;

// 1. 如果访问 http://localhost，API 请求为 http://localhost/api/...
// 2. Nginx 会拦截这个 /api 请求并转发给后端
axios.defaults.baseURL = '/api'; 


// 2、允许携带 Cookie (Session ID)
axios.defaults.withCredentials = true 

// 3. 自动处理 Django 的 CSRF Token 
axios.defaults.xsrfCookieName = 'csrftoken'
axios.defaults.xsrfHeaderName = 'X-CSRFToken'

const app = createApp(App)

app.use(createPinia()) 
app.use(router)
app.mount('#app')