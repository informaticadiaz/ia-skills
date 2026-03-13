---
name: Content Viewer
app: common
tags: [overlay, fullscreen, portal, trigger, stories, reels, posts, immersive]
complexity: medium
---

# Content Viewer

## Descripción

Overlay fullscreen (`fixed inset-0 z-[9999]`) que se activa con un botón trigger. Cubre TODO: nav, header, bottom bar, menú lateral. UI limpia con solo el contenido y un botón cerrar. Reutilizable para Stories, Reels, Posts o cualquier contenido inmersivo.

Inspirado en el comportamiento de Instagram/TikTok: tocás un avatar, una card o un post y la UI de la app desaparece completamente para mostrar solo el contenido.

## Anatomía

- **ContentTrigger**: Wrapper que envuelve cualquier elemento y lo hace clickeable
- **ContentViewer**: Portal `fixed inset-0 z-[9999]` con fondo negro
  - **Close Button**: Botón X en esquina superior derecha
  - **Content Slot**: Área donde se renderiza el contenido pasado
  - **Backdrop**: Fondo oscuro que al clickearse cierra el viewer

## Diferencia con modales normales

| Modal normal | Content Viewer |
|---|---|
| `absolute` o `relative` al parent | `fixed` respecto al viewport |
| Z-index bajo/medio | `z-[9999]` — encima de TODO |
| Nav/header visible | Nav/header completamente tapado |
| Scroll del body funciona | Body bloqueado (`overflow-hidden`) |

## Variantes

- **Con trigger button**: Cualquier elemento hijo actúa como trigger
- **Controlado externamente**: `open` + `onClose` como props (sin estado interno)
- **Con animación**: Fade in/out con Tailwind transitions

## Estados

- **Cerrado**: Nada renderizado (o `hidden` con `display:none`)
- **Abierto**: Fixed fullscreen visible
- **Closing**: Animación de salida antes de desmontar

---

## React + TypeScript + Tailwind

```tsx
'use client'

import { useState, useEffect, useCallback } from 'react'
import { createPortal } from 'react-dom'
import { X } from 'lucide-react'
import { cn } from '@/lib/utils'

// ─── TIPOS ────────────────────────────────────────────────────────────────────

interface ContentViewerProps {
  /** Contenido a mostrar en el overlay */
  children: React.ReactNode
  /** Controlado externamente: si true, el viewer está abierto */
  open: boolean
  /** Callback para cerrar */
  onClose: () => void
  /** Clases adicionales al container del overlay */
  className?: string
}

interface ContentTriggerProps {
  /** Elemento que activa el viewer al hacer click */
  children: React.ReactNode
  /** Callback que se ejecuta al hacer click en el trigger */
  onTrigger: () => void
  className?: string
  /** Tag HTML del wrapper. Default: 'button' */
  as?: 'button' | 'div' | 'a'
}

// ─── CONTENT VIEWER ───────────────────────────────────────────────────────────

/**
 * Overlay fullscreen que tapa TODO: nav, header, bottom bar, menú.
 * Se monta como portal en document.body.
 *
 * Uso básico:
 * const [open, setOpen] = useState(false)
 * <ContentViewer open={open} onClose={() => setOpen(false)}>
 *   <MiContenido />
 * </ContentViewer>
 */
export function ContentViewer({ children, open, onClose, className }: ContentViewerProps) {
  // Bloquear scroll del body cuando está abierto
  useEffect(() => {
    if (open) {
      document.body.style.overflow = 'hidden'
    } else {
      document.body.style.overflow = ''
    }
    return () => {
      document.body.style.overflow = ''
    }
  }, [open])

  // Cerrar con Escape
  useEffect(() => {
    if (!open) return
    const handleKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') onClose()
    }
    document.addEventListener('keydown', handleKey)
    return () => document.removeEventListener('keydown', handleKey)
  }, [open, onClose])

  if (!open) return null

  // Portal: se monta en document.body, por eso tapa todo
  return createPortal(
    <div
      className={cn(
        // z-[9999] asegura que esté por encima de nav, modales, tooltips, etc.
        'fixed inset-0 z-[9999] bg-black',
        className
      )}
      role="dialog"
      aria-modal="true"
    >
      {/* Botón cerrar — siempre visible arriba a la derecha */}
      <button
        onClick={onClose}
        className="absolute top-4 right-4 z-10 p-2 rounded-full bg-black/40 backdrop-blur-sm text-white hover:bg-black/60 transition-colors"
        aria-label="Cerrar"
      >
        <X className="w-6 h-6" />
      </button>

      {/* Contenido */}
      <div className="w-full h-full">
        {children}
      </div>
    </div>,
    document.body
  )
}

// ─── CONTENT TRIGGER ──────────────────────────────────────────────────────────

/**
 * Wrapper que convierte cualquier elemento en trigger del ContentViewer.
 *
 * Uso:
 * <ContentTrigger onTrigger={() => setOpen(true)}>
 *   <StoryAvatar ... />
 * </ContentTrigger>
 */
export function ContentTrigger({
  children,
  onTrigger,
  className,
  as: Tag = 'button',
}: ContentTriggerProps) {
  return (
    <Tag
      onClick={onTrigger}
      className={cn('cursor-pointer', className)}
      // Si es button, evitar estilos por defecto del browser
      {...(Tag === 'button' ? { type: 'button' } : {})}
    >
      {children}
    </Tag>
  )
}

// ─── HOOK HELPER ──────────────────────────────────────────────────────────────

/**
 * Hook para manejar el estado del ContentViewer.
 * Retorna open, handleOpen, handleClose.
 */
export function useContentViewer() {
  const [open, setOpen] = useState(false)

  const handleOpen = useCallback(() => setOpen(true), [])
  const handleClose = useCallback(() => setOpen(false), [])

  return { open, handleOpen, handleClose }
}
```

### Props

**ContentViewer:**

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| children | ReactNode | - | Contenido a mostrar fullscreen |
| open | boolean | - | Controlado: si está abierto |
| onClose | () => void | - | Callback para cerrar |
| className | string | - | Clases adicionales |

**ContentTrigger:**

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| children | ReactNode | - | Elemento trigger |
| onTrigger | () => void | - | Callback al hacer click |
| as | 'button' \| 'div' \| 'a' | 'button' | Tag HTML del wrapper |
| className | string | - | Clases adicionales |

---

### Uso con Stories

```tsx
function StoriesBar({ stories }: { stories: Story[] }) {
  const { open, handleOpen, handleClose } = useContentViewer()
  const [activeStory, setActiveStory] = useState<Story | null>(null)

  const openStory = (story: Story) => {
    setActiveStory(story)
    handleOpen()
  }

  return (
    <>
      <div className="flex gap-4 overflow-x-auto p-4">
        {stories.map((story) => (
          <ContentTrigger key={story.id} onTrigger={() => openStory(story)}>
            <StoryAvatar story={story} />
          </ContentTrigger>
        ))}
      </div>

      {/* Se abre encima de TODO, incluyendo el nav */}
      <ContentViewer open={open} onClose={handleClose}>
        {activeStory && <StoryViewer story={activeStory} onEnd={handleClose} />}
      </ContentViewer>
    </>
  )
}
```

---

### Uso con Reels

```tsx
function ReelsGrid({ reels }: { reels: ReelItem[] }) {
  const { open, handleOpen, handleClose } = useContentViewer()
  const [startIndex, setStartIndex] = useState(0)

  const openReel = (index: number) => {
    setStartIndex(index)
    handleOpen()
  }

  return (
    <>
      {/* Grid de thumbnails */}
      <div className="grid grid-cols-3 gap-1">
        {reels.map((reel, index) => (
          <ContentTrigger key={reel.id} onTrigger={() => openReel(index)}>
            <div className="aspect-square relative">
              <img src={reel.coverImage} alt={reel.title} className="w-full h-full object-cover" />
            </div>
          </ContentTrigger>
        ))}
      </div>

      {/* Viewer fullscreen — tapa nav, header, todo */}
      <ContentViewer open={open} onClose={handleClose}>
        <ReelsFeed reels={reels} />
      </ContentViewer>
    </>
  )
}
```

---

### Uso con Posts

```tsx
function PostCard({ post }: { post: Post }) {
  const { open, handleOpen, handleClose } = useContentViewer()

  return (
    <>
      <ContentTrigger onTrigger={handleOpen} as="div" className="cursor-pointer">
        <img src={post.image} alt={post.caption} className="w-full aspect-square object-cover" />
      </ContentTrigger>

      <ContentViewer open={open} onClose={handleClose}>
        <PostFullscreen post={post} onClose={handleClose} />
      </ContentViewer>
    </>
  )
}
```

---

## Por qué `z-[9999]`

En un layout típico de Next.js con nav:

```
z-10   → Header / Navbar
z-20   → Sticky elements, tooltips
z-30   → Dropdowns, popovers
z-40   → Modales normales
z-50   → Toasts, notifications
z-[9999] → ContentViewer (encima de TODO)
```

Si el nav tiene `z-50`, el ContentViewer con `z-[9999]` siempre gana.

## Personalización

- **Sin fondo negro**: cambiar `bg-black` por `bg-white` o `bg-brand-base`
- **Con animación de entrada**: agregar `animate-fade-in` o usar Framer Motion
- **Con swipe para cerrar**: agregar touch handlers para detectar swipe hacia abajo
- **Sin botón X**: remover el `<button>` y manejar el cierre con swipe o click en backdrop
