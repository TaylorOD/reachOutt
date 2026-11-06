import { createRouter, createWebHistory, createWebHashHistory } from 'vue-router'
import { isPreview } from '../config'
import Home from '../views/Home.vue'
import Contact from '../views/Contact.vue'
import Reachout from '../views/Reachout.vue'
import Signup from '../views/Signup.vue'
import Login from '../views/Login.vue'
import Logout from '../views/Logout.vue'

const routes = [
  { path: '/forgot-password', component: () => import('../views/PasswordReset.vue') },
  { path: '/reset-password', component: () => import('../views/PasswordReset.vue') },
  {
    path: '/',
    name: 'Home',
    component: Home,
    meta: {
      inverse: true
    }
  },
  {
    path: '/about',
    name: 'About',

    component: () => import('../views/About.vue')
  },
  { path: '/account', component: () => import('../views/Account.vue') },
  { path: '/signup', name: 'signup', component: Signup },
  { path: '/login', name: 'login', component: Login },
  { path: '/logout', name: 'logout', component: Logout },
  { path: '/contact', name: 'contact', component: Contact },
  { path: '/reachout', name: 'reachout', component: Reachout }
]

const router = createRouter({
  history: isPreview
    ? createWebHashHistory(import.meta.env.BASE_URL)
    : createWebHistory(import.meta.env.DEV ? '/app/' : '/'),
  routes
})

router.beforeEach((to) => {
  if (
    !isPreview &&
    ['/contact', '/reachout', '/account'].includes(to.path) &&
    !localStorage.getItem('jwt')
  )
    return '/login'
})

export default router
