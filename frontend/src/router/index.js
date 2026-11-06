import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Contact from '../views/Contact.vue'
import Reachout from '../views/Reachout.vue'
import Signup from "../views/Signup.vue"
import Login from "../views/Login.vue"
import Logout from "../views/Logout.vue"



const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home, 
    meta: {
      // allows us to use a separate nav baron home
      inverse: true
    }
  },
  {
    path: '/about',
    name: 'About',
    // route level code-splitting
    // this generates a separate chunk (about.[hash].js) for this route
    // which is lazy-loaded when the route is visited.
    component: () => import(/* webpackChunkName: "about" */ '../views/About.vue')
  },
  { path: "/account", component: () => import("../views/Account.vue") },
  { path: "/signup", name: "signup", component: Signup },
  { path: "/login", name: "login", component: Login },
  { path: "/logout", name: "logout", component: Logout },
  { path: "/contact", name: "contact", component: Contact },
  { path: "/reachout", name: "reachout", component: Reachout },


]

const router = createRouter({
  history: createWebHistory(import.meta.env.DEV ? "/app/" : "/"),
  routes
})

router.beforeEach(to => {
  if (['/contact', '/reachout', '/account'].includes(to.path) && !localStorage.getItem('jwt')) return '/login'
})

export default router
