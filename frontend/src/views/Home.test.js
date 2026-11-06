import { afterEach, expect, it, vi } from 'vitest'
import { createApp, nextTick } from 'vue'
import Home from './Home.vue'

let app
function mount(reducedMotion = false) {
  vi.useFakeTimers()
  vi.stubGlobal('matchMedia', () => ({ matches: reducedMotion }))
  const node = document.createElement('div')
  document.body.append(node)
  app = createApp(Home)
  app.mount(node)
  return node.querySelector('.greeting')
}

afterEach(() => {
  app.unmount()
  document.body.innerHTML = ''
  vi.useRealTimers()
  vi.unstubAllGlobals()
})

it('erases and types one character at a time through all four phrases and loops', async () => {
  const greeting = mount()
  const phrases = [
    "I'm a family member",
    "I'm a friend",
    "I'm someone who misses you",
    "I'm ReachOutt",
    "I'm a family member"
  ]
  expect(greeting.textContent).toBe(phrases[0])
  for (const phrase of phrases.slice(1)) {
    while (greeting.textContent) {
      const previous = greeting.textContent
      await vi.advanceTimersToNextTimerAsync()
      await nextTick()
      expect(greeting.textContent).toBe(previous.slice(0, -1))
    }
    for (let length = 1; length <= phrase.length; length++) {
      await vi.advanceTimersToNextTimerAsync()
      await nextTick()
      expect(greeting.textContent).toBe(phrase.slice(0, length))
    }
  }
  expect(greeting.getAttribute('aria-hidden')).toBe('true')
  app.unmount()
  expect(vi.getTimerCount()).toBe(0)
})

it('keeps the greeting still when reduced motion is requested', () => {
  const greeting = mount(true)
  vi.advanceTimersByTime(30000)
  expect(greeting.textContent).toBe("I'm a family member")
  expect(vi.getTimerCount()).toBe(0)
})
