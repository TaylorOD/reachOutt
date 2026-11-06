import axios from 'axios'

axios.defaults.baseURL = '/'
axios.defaults.timeout = 15000
axios.interceptors.request.use(config => {
  const token = localStorage.getItem('jwt')
  if (token) config.headers.Authorization = 'Bearer ' + token
  else delete config.headers.Authorization
  return config
})
axios.interceptors.response.use(response => response, error => {
  if (error.response?.status === 401 && error.config?.url !== '/api/sessions') {
    localStorage.removeItem('jwt')
    window.location.assign(import.meta.env.DEV ? '/app/login' : '/login')
  }
  return Promise.reject(error)
})
export default axios
