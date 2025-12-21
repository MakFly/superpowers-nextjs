---
name: nextjs:client-components
description: Use 'use client' directive for interactive components with hooks, event handlers, and browser APIs
---

# Client Components for Interactivity

Master building interactive React components with the `'use client'` directive. Client Components enable interactivity, state management, and browser APIs while remaining performant when strategically placed.

## Understanding Client Components

Client Components are interactive components that run in the browser with full access to React hooks, browser APIs, and event handlers. They're marked with the `'use client'` directive.

```typescript
// components/Counter.tsx
'use client'

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <button onClick={() => setCount(count + 1)}>
      Count: {count}
    </button>
  )
}
```

## Key Features

- **React Hooks**: Full access to `useState`, `useEffect`, `useContext`, etc.
- **Event Handlers**: `onClick`, `onChange`, `onSubmit`, and all browser events
- **Browser APIs**: Access `localStorage`, `sessionStorage`, `navigator`, `window`
- **Interactivity**: Real-time updates without page refresh
- **Client-side Routing**: Smooth transitions between pages

## Forms and User Input

### Basic Form Handling

```typescript
// components/ContactForm.tsx
'use client'

import { FormEvent, useState } from 'react'
import { useRouter } from 'next/navigation'

type FormData = {
  name: string
  email: string
  message: string
};

export function ContactForm() {
  const [formData, setFormData] = useState<FormData>({
    name: '',
    email: '',
    message: ''
  })
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setIsLoading(true)
    setError(null)

    try {
      const response = await fetch('/api/contact', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      })

      if (!response.ok) {
        throw new Error('Failed to send message')
      }

      setSuccess(true)
      setFormData({ name: '', email: '', message: '' })

      // Show success for 3 seconds then redirect
      setTimeout(() => {
        router.push('/thank-you')
      }, 2000)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred')
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="contact-form">
      {error && <div className="error-message">{error}</div>}
      {success && <div className="success-message">Message sent!</div>}

      <div className="form-group">
        <label htmlFor="name">Name</label>
        <input
          id="name"
          type="text"
          required
          value={formData.name}
          onChange={e => setFormData({ ...formData, name: e.target.value })}
          placeholder="Your name"
        />
      </div>

      <div className="form-group">
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          required
          value={formData.email}
          onChange={e => setFormData({ ...formData, email: e.target.value })}
          placeholder="your@email.com"
        />
      </div>

      <div className="form-group">
        <label htmlFor="message">Message</label>
        <textarea
          id="message"
          required
          value={formData.message}
          onChange={e => setFormData({ ...formData, message: e.target.value })}
          placeholder="Your message"
          rows={5}
        />
      </div>

      <button type="submit" disabled={isLoading}>
        {isLoading ? 'Sending...' : 'Send Message'}
      </button>
    </form>
  )
}
```

### Advanced Form with Validation

```typescript
// components/RegistrationForm.tsx
'use client'

import { FormEvent, useState, ChangeEvent } from 'react'

type FormErrors = {
  [key: string]: string
};

type FormValues = {
  username: string
  email: string
  password: string
  confirmPassword: string
  terms: boolean
};

const validateForm = (values: FormValues): FormErrors => {
  const errors: FormErrors = {}

  if (values.username.length < 3) {
    errors.username = 'Username must be at least 3 characters'
  }

  if (!values.email.includes('@')) {
    errors.email = 'Please enter a valid email'
  }

  if (values.password.length < 8) {
    errors.password = 'Password must be at least 8 characters'
  }

  if (values.password !== values.confirmPassword) {
    errors.confirmPassword = 'Passwords do not match'
  }

  if (!values.terms) {
    errors.terms = 'You must accept the terms'
  }

  return errors
}

export function RegistrationForm() {
  const [values, setValues] = useState<FormValues>({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
    terms: false
  })
  const [errors, setErrors] = useState<FormErrors>({})
  const [isSubmitting, setIsSubmitting] = useState(false)

  const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
    const { name, value, type, checked } = e.target
    setValues(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }))
  }

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()

    const formErrors = validateForm(values)
    setErrors(formErrors)

    if (Object.keys(formErrors).length > 0) {
      return
    }

    setIsSubmitting(true)

    try {
      const response = await fetch('/api/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          username: values.username,
          email: values.email,
          password: values.password
        })
      })

      if (!response.ok) {
        const data = await response.json()
        setErrors({ submit: data.message || 'Registration failed' })
        return
      }

      // Success - redirect to login
      window.location.href = '/login'
    } catch (err) {
      setErrors({ submit: 'An unexpected error occurred' })
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="registration-form">
      <div className="form-group">
        <label htmlFor="username">Username</label>
        <input
          id="username"
          type="text"
          name="username"
          value={values.username}
          onChange={handleChange}
          required
        />
        {errors.username && <span className="error">{errors.username}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          name="email"
          value={values.email}
          onChange={handleChange}
          required
        />
        {errors.email && <span className="error">{errors.email}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          name="password"
          value={values.password}
          onChange={handleChange}
          required
        />
        {errors.password && <span className="error">{errors.password}</span>}
      </div>

      <div className="form-group">
        <label htmlFor="confirmPassword">Confirm Password</label>
        <input
          id="confirmPassword"
          type="password"
          name="confirmPassword"
          value={values.confirmPassword}
          onChange={handleChange}
          required
        />
        {errors.confirmPassword && (
          <span className="error">{errors.confirmPassword}</span>
        )}
      </div>

      <div className="form-group checkbox">
        <input
          id="terms"
          type="checkbox"
          name="terms"
          checked={values.terms}
          onChange={handleChange}
          required
        />
        <label htmlFor="terms">I accept the terms and conditions</label>
        {errors.terms && <span className="error">{errors.terms}</span>}
      </div>

      {errors.submit && <div className="error-message">{errors.submit}</div>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating account...' : 'Register'}
      </button>
    </form>
  )
}
```

## State Management with Hooks

### useEffect for Side Effects

```typescript
// components/ChatWidget.tsx
'use client'

import { useEffect, useState, useRef } from 'react'

type Message = {
  id: string
  text: string
  timestamp: Date
  sender: 'user' | 'assistant'
};

export function ChatWidget() {
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  // Auto-scroll to latest message
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  // Load chat history on mount
  useEffect(() => {
    const loadHistory = async () => {
      try {
        const response = await fetch('/api/chat/history')
        const data = await response.json()
        setMessages(data)
      } catch (error) {
        console.error('Failed to load chat history:', error)
      }
    }

    loadHistory()
  }, [])

  const handleSendMessage = async () => {
    if (!input.trim()) return

    // Add user message optimistically
    const userMessage: Message = {
      id: Date.now().toString(),
      text: input,
      timestamp: new Date(),
      sender: 'user'
    }

    setMessages(prev => [...prev, userMessage])
    setInput('')
    setIsLoading(true)

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: input })
      })

      const data = await response.json()

      const assistantMessage: Message = {
        id: data.id,
        text: data.text,
        timestamp: new Date(data.timestamp),
        sender: 'assistant'
      }

      setMessages(prev => [...prev, assistantMessage])
    } catch (error) {
      console.error('Failed to send message:', error)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="chat-widget">
      <div className="messages">
        {messages.map(msg => (
          <div key={msg.id} className={`message ${msg.sender}`}>
            <p>{msg.text}</p>
            <time>{msg.timestamp.toLocaleTimeString()}</time>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <div className="input-area">
        <input
          type="text"
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyPress={e => {
            if (e.key === 'Enter' && !isLoading) {
              handleSendMessage()
            }
          }}
          placeholder="Type a message..."
          disabled={isLoading}
        />
        <button onClick={handleSendMessage} disabled={isLoading}>
          {isLoading ? 'Sending...' : 'Send'}
        </button>
      </div>
    </div>
  )
}
```

### useContext for Shared State

```typescript
// lib/theme-context.tsx
'use client'

import {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode
} from 'react'

type Theme = 'light' | 'dark' | 'system'

type ThemeContextType = {
  theme: Theme
  setTheme: (theme: Theme) => void
  isDark: boolean
};

const ThemeContext = createContext<ThemeContextType | undefined>(undefined)

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeState] = useState<Theme>('system')
  const [isDark, setIsDark] = useState(false)

  useEffect(() => {
    // Load theme from localStorage
    const stored = localStorage.getItem('theme') as Theme | null
    if (stored) {
      setThemeState(stored)
    }

    // Listen for system theme changes
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    const handleChange = () => {
      updateDarkMode(stored || 'system')
    }
    mediaQuery.addEventListener('change', handleChange)

    return () => mediaQuery.removeEventListener('change', handleChange)
  }, [])

  const updateDarkMode = (t: Theme) => {
    const dark =
      t === 'dark' ||
      (t === 'system' &&
        window.matchMedia('(prefers-color-scheme: dark)').matches)
    setIsDark(dark)
    document.documentElement.classList.toggle('dark', dark)
  }

  const setTheme = (newTheme: Theme) => {
    setThemeState(newTheme)
    localStorage.setItem('theme', newTheme)
    updateDarkMode(newTheme)
  }

  return (
    <ThemeContext.Provider value={{ theme, setTheme, isDark }}>
      {children}
    </ThemeContext.Provider>
  )
}

export function useTheme() {
  const context = useContext(ThemeContext)
  if (context === undefined) {
    throw new Error('useTheme must be used within ThemeProvider')
  }
  return context
}
```

```typescript
// components/ThemeToggle.tsx
'use client'

import { useTheme } from '@/lib/theme-context'

export function ThemeToggle() {
  const { theme, setTheme } = useTheme()

  return (
    <div className="theme-toggle">
      <button
        onClick={() => setTheme('light')}
        className={theme === 'light' ? 'active' : ''}
      >
        Light
      </button>
      <button
        onClick={() => setTheme('dark')}
        className={theme === 'dark' ? 'active' : ''}
      >
        Dark
      </button>
      <button
        onClick={() => setTheme('system')}
        className={theme === 'system' ? 'active' : ''}
      >
        System
      </button>
    </div>
  )
}
```

## Browser APIs

### Working with localStorage

```typescript
// components/UserPreferences.tsx
'use client'

import { useEffect, useState } from 'react'

type Preferences = {
  language: string
  notifications: boolean
  sidebarCollapsed: boolean
};

const DEFAULT_PREFERENCES: Preferences = {
  language: 'en',
  notifications: true,
  sidebarCollapsed: false
}

export function UserPreferences() {
  const [preferences, setPreferences] = useState<Preferences>(DEFAULT_PREFERENCES)

  // Load preferences from localStorage on mount
  useEffect(() => {
    const stored = localStorage.getItem('userPreferences')
    if (stored) {
      try {
        setPreferences(JSON.parse(stored))
      } catch (error) {
        console.error('Failed to parse preferences:', error)
      }
    }
  }, [])

  // Save to localStorage whenever preferences change
  useEffect(() => {
    localStorage.setItem('userPreferences', JSON.stringify(preferences))

    // Dispatch custom event so other tabs can sync
    window.dispatchEvent(
      new CustomEvent('preferencesChanged', { detail: preferences })
    )
  }, [preferences])

  const handleLanguageChange = (language: string) => {
    setPreferences(prev => ({ ...prev, language }))
  }

  const handleNotificationsToggle = () => {
    setPreferences(prev => ({ ...prev, notifications: !prev.notifications }))
  }

  const handleSidebarToggle = () => {
    setPreferences(prev => ({
      ...prev,
      sidebarCollapsed: !prev.sidebarCollapsed
    }))
  }

  return (
    <div className="preferences">
      <div className="preference-group">
        <label>Language</label>
        <select value={preferences.language} onChange={e => handleLanguageChange(e.target.value)}>
          <option value="en">English</option>
          <option value="es">Español</option>
          <option value="fr">Français</option>
          <option value="de">Deutsch</option>
        </select>
      </div>

      <div className="preference-group">
        <label>
          <input
            type="checkbox"
            checked={preferences.notifications}
            onChange={handleNotificationsToggle}
          />
          Enable notifications
        </label>
      </div>

      <div className="preference-group">
        <label>
          <input
            type="checkbox"
            checked={preferences.sidebarCollapsed}
            onChange={handleSidebarToggle}
          />
          Collapse sidebar
        </label>
      </div>
    </div>
  )
}
```

### Geolocation API

```typescript
// components/LocationAwareDeal.tsx
'use client'

import { useEffect, useState } from 'react'

type Location = {
  latitude: number
  longitude: number
};

export function LocationAwareDeal() {
  const [location, setLocation] = useState<Location | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [nearbyDeals, setNearbyDeals] = useState<any[]>([])

  useEffect(() => {
    if (!navigator.geolocation) {
      setError('Geolocation is not supported')
      setIsLoading(false)
      return
    }

    navigator.geolocation.getCurrentPosition(
      async position => {
        const { latitude, longitude } = position.coords
        setLocation({ latitude, longitude })

        // Fetch nearby deals
        try {
          const response = await fetch(
            `/api/deals/nearby?lat=${latitude}&lon=${longitude}&radius=10`
          )
          const deals = await response.json()
          setNearbyDeals(deals)
        } catch (err) {
          setError('Failed to fetch nearby deals')
        } finally {
          setIsLoading(false)
        }
      },
      error => {
        setError(`Geolocation error: ${error.message}`)
        setIsLoading(false)
      }
    )
  }, [])

  if (isLoading) return <div>Finding nearby deals...</div>
  if (error) return <div className="error">{error}</div>

  return (
    <div className="nearby-deals">
      <h2>Deals near you</h2>
      {nearbyDeals.length === 0 ? (
        <p>No deals nearby</p>
      ) : (
        <ul>
          {nearbyDeals.map(deal => (
            <li key={deal.id}>
              <h3>{deal.name}</h3>
              <p>{deal.distance} km away</p>
              <p className="discount">{deal.discount}</p>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
```

## Event Handling Patterns

### Debouncing Search Input

```typescript
// components/SearchUsers.tsx
'use client'

import { useState, useCallback, useEffect } from 'react'
import { debounce } from '@/lib/utils'

type User = {
  id: string
  name: string
  email: string
};

export function SearchUsers() {
  const [query, setQuery] = useState('')
  const [results, setResults] = useState<User[]>([])
  const [isSearching, setIsSearching] = useState(false)

  const performSearch = useCallback(async (searchQuery: string) => {
    if (!searchQuery.trim()) {
      setResults([])
      return
    }

    setIsSearching(true)
    try {
      const response = await fetch(
        `/api/users/search?q=${encodeURIComponent(searchQuery)}`
      )
      const data = await response.json()
      setResults(data)
    } catch (error) {
      console.error('Search failed:', error)
    } finally {
      setIsSearching(false)
    }
  }, [])

  const debouncedSearch = useCallback(
    debounce((query: string) => performSearch(query), 300),
    [performSearch]
  )

  const handleInputChange = (value: string) => {
    setQuery(value)
    debouncedSearch(value)
  }

  return (
    <div className="search-users">
      <input
        type="text"
        placeholder="Search users..."
        value={query}
        onChange={e => handleInputChange(e.target.value)}
      />
      {isSearching && <div className="loading">Searching...</div>}
      <ul className="results">
        {results.map(user => (
          <li key={user.id}>
            <strong>{user.name}</strong>
            <p>{user.email}</p>
          </li>
        ))}
      </ul>
    </div>
  )
}
```

## Client vs Server: When to Use Each

```typescript
// app/page.tsx - Server Component
import UserProfile from '@/components/UserProfile' // Server Component
import InteractiveChart from '@/components/InteractiveChart' // Client Component

export default async function Home() {
  // Can fetch data directly from database
  const userData = await fetchUserData()

  return (
    <div>
      {/* Server Component - no JS sent to browser */}
      <UserProfile user={userData} />

      {/* Client Component - full interactivity */}
      <InteractiveChart data={userData.metrics} />
    </div>
  )
}
```

Client Components are essential for any interactive features, forms, and real-time updates in your Next.js applications.
