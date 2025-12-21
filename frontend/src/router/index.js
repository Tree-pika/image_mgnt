import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Register from '../views/Register.vue'
import Home from '../views/Home.vue'
import { useAuthStore } from '../stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    { 
      path: '/login', 
      name: 'login', 
      component: Login,
      meta: { guest: true }
    },
    { 
      path: '/register', 
      name: 'register', 
      component: Register,
      meta: { guest: true }
    },
    { 
      path: '/', 
      name: 'home', 
      component: Home,
      meta: { requiresAuth: true } 
    }
  ]
})

// 检查用户是否已登录
router.beforeEach(async (to, from, next) => {
  const auth = useAuthStore()
  
  // 如果去往需要登录的页面，且没有登录
  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    next('/login')
  } 
  // 如果已登录用户试图访问登录/注册页，重定向到首页
  else if (to.meta.guest && auth.isAuthenticated) {
    next('/')
  } 
  else {
    next()
  }
})

export default router