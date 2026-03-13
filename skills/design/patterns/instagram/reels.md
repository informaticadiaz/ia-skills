---
name: Reels
app: instagram
tags: [video, fullscreen, scroll-snap, overlay, vertical-feed, tiktok]
complexity: hard
---

# Instagram Reels

## Descripción

Feed vertical con scroll snap que muestra un item por vez en pantalla completa. Imagen/video de fondo con gradient overlay, acciones laterales (like, share) y contenido inferior (usuario, título, audio). Navegación por swipe o botones. Patrón idéntico al feed TikTok.

## Anatomía

- **Feed Container**: `h-[100dvh]` con `overflow-y-scroll snap-y snap-mandatory`
- **Feed Item**: `h-[100dvh] snap-start snap-always` — un ítem por "pantalla"
  - **Background**: Imagen o video con `object-cover fill`
  - **Gradient Overlay**: `bg-gradient-to-t from-black/80 via-black/20 to-transparent`
  - **Side Actions**: Columna derecha con like, comment, share, más
  - **Bottom Info**: Usuario, descripción, audio track
- **Nav Buttons** (desktop): Flechas up/down en lateral derecho
- **Progress Indicators**: Líneas verticales que indican posición actual

## Variantes

- **Con video**: `<video>` o iframe de YouTube/Vimeo
- **Solo imagen**: Fallback cuando no hay video
- **Con bottom nav**: Ajuste de padding para no tapar el contenido (`pb-28` mobile)
- **Sin bottom nav**: Padding estándar (`pb-8`)

## Estados

- **Activo**: Item visible en pantalla (`isActive: true`)
- **Liked**: Corazón rojo con fill
- **Followed**: Botón de follow en avatar del usuario
- **Loading**: Skeleton fullscreen pulsando

## Accesibilidad

- `<article>` por cada item del feed
- `aria-label` en botones de acción
- `role="feed"` en el container principal

---

## React + TypeScript + Tailwind

```tsx
'use client'

import { useRef, useState, useEffect } from 'react'
import Image from 'next/image'
import { ChevronUp, ChevronDown, Heart, MessageCircle, Share2, Music2, MoreHorizontal } from 'lucide-react'
import { cn } from '@/lib/utils'

interface ReelItem {
  id: string
  username: string
  avatar: string
  title: string
  audio?: string
  coverImage: string
  videoUrl?: string
  likes: number
  comments: number
  isFollowing?: boolean
}

interface ReelsFeedProps {
  reels: ReelItem[]
  /** true si hay bottom nav (mobile). Agrega padding extra abajo */
  hasBottomNav?: boolean
  className?: string
}

export function ReelsFeed({ reels, hasBottomNav = false, className }: ReelsFeedProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const [currentIndex, setCurrentIndex] = useState(0)

  useEffect(() => {
    const container = containerRef.current
    if (!container) return

    const handleScroll = () => {
      const index = Math.round(container.scrollTop / container.clientHeight)
      setCurrentIndex(index)
    }

    container.addEventListener('scroll', handleScroll, { passive: true })
    return () => container.removeEventListener('scroll', handleScroll)
  }, [])

  const scrollTo = (direction: 'up' | 'down') => {
    const container = containerRef.current
    if (!container) return
    const newIndex = direction === 'up'
      ? Math.max(0, currentIndex - 1)
      : Math.min(reels.length - 1, currentIndex + 1)
    container.scrollTo({ top: newIndex * container.clientHeight, behavior: 'smooth' })
  }

  return (
    <div className={cn('relative h-[100dvh] w-full bg-black', className)}>
      {/* Feed con scroll snap */}
      <div
        ref={containerRef}
        role="feed"
        className="h-full w-full overflow-y-scroll snap-y snap-mandatory scrollbar-hide"
      >
        {reels.map((reel, index) => (
          <ReelFeedItem
            key={reel.id}
            reel={reel}
            isActive={index === currentIndex}
            hasBottomNav={hasBottomNav}
          />
        ))}
      </div>

      {/* Navegación desktop */}
      <div className="hidden sm:flex absolute right-4 top-1/2 -translate-y-1/2 flex-col gap-2 z-20">
        <button
          onClick={() => scrollTo('up')}
          disabled={currentIndex === 0}
          className="p-2 rounded-full bg-white/10 backdrop-blur-sm text-white disabled:opacity-30 hover:bg-white/20 transition-opacity"
          aria-label="Reel anterior"
        >
          <ChevronUp className="w-6 h-6" />
        </button>
        <button
          onClick={() => scrollTo('down')}
          disabled={currentIndex === reels.length - 1}
          className="p-2 rounded-full bg-white/10 backdrop-blur-sm text-white disabled:opacity-30 hover:bg-white/20 transition-opacity"
          aria-label="Reel siguiente"
        >
          <ChevronDown className="w-6 h-6" />
        </button>
      </div>

      {/* Indicadores de posición */}
      <div className="absolute right-2 sm:right-14 top-1/2 -translate-y-1/2 flex flex-col gap-1 z-20">
        {reels.map((_, index) => (
          <div
            key={index}
            className={cn(
              'w-1 rounded-full transition-all duration-300',
              index === currentIndex ? 'h-6 bg-white' : 'h-1.5 bg-white/40'
            )}
          />
        ))}
      </div>
    </div>
  )
}

interface ReelFeedItemProps {
  reel: ReelItem
  isActive: boolean
  hasBottomNav: boolean
}

function ReelFeedItem({ reel, isActive, hasBottomNav }: ReelFeedItemProps) {
  const [liked, setLiked] = useState(false)
  const [likeCount, setLikeCount] = useState(reel.likes)

  const handleLike = () => {
    setLiked(!liked)
    setLikeCount(prev => liked ? prev - 1 : prev + 1)
  }

  return (
    <article className="relative h-[100dvh] w-full snap-start snap-always">
      {/* Fondo */}
      <Image
        src={reel.coverImage}
        alt={reel.title}
        fill
        className="object-cover"
        sizes="100vw"
        priority={isActive}
      />

      {/* Gradient */}
      <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/20 to-transparent" />

      {/* Acciones laterales */}
      <div className={cn(
        'absolute right-4 flex flex-col items-center gap-6 z-10',
        hasBottomNav ? 'bottom-32' : 'bottom-20'
      )}>
        {/* Avatar con follow */}
        <div className="relative">
          <img
            src={reel.avatar}
            alt={reel.username}
            className="w-10 h-10 rounded-full object-cover border-2 border-white"
          />
          <button
            className="absolute -bottom-2 left-1/2 -translate-x-1/2 w-5 h-5 bg-red-500 rounded-full flex items-center justify-center"
            aria-label={`Seguir a ${reel.username}`}
          >
            <span className="text-white text-[10px] font-bold leading-none">+</span>
          </button>
        </div>

        {/* Like */}
        <button
          onClick={handleLike}
          className="flex flex-col items-center gap-1"
          aria-label={liked ? 'Quitar like' : 'Dar like'}
        >
          <Heart className={cn('w-8 h-8', liked ? 'text-red-500 fill-red-500' : 'text-white')} />
          <span className="text-white text-xs">{formatCount(likeCount)}</span>
        </button>

        {/* Comentarios */}
        <button className="flex flex-col items-center gap-1" aria-label="Comentarios">
          <MessageCircle className="w-8 h-8 text-white" />
          <span className="text-white text-xs">{formatCount(reel.comments)}</span>
        </button>

        {/* Compartir */}
        <button className="flex flex-col items-center gap-1" aria-label="Compartir">
          <Share2 className="w-8 h-8 text-white" />
          <span className="text-white text-xs">Compartir</span>
        </button>

        {/* Más opciones */}
        <button aria-label="Más opciones">
          <MoreHorizontal className="w-8 h-8 text-white" />
        </button>
      </div>

      {/* Info inferior */}
      <div className={cn(
        'absolute inset-x-0 p-4 z-10 max-w-[75%]',
        hasBottomNav ? 'bottom-24 pb-4' : 'bottom-6'
      )}>
        <p className="text-white font-semibold text-sm mb-1">@{reel.username}</p>
        <p className="text-white text-sm mb-3 line-clamp-2">{reel.title}</p>
        {reel.audio && (
          <div className="flex items-center gap-2 text-white/80">
            <Music2 className="w-4 h-4 flex-shrink-0" />
            <span className="text-xs truncate">{reel.audio}</span>
          </div>
        )}
      </div>
    </article>
  )
}

function formatCount(n: number): string {
  if (n >= 1_000_000) return `${(n / 1_000_000).toFixed(1)}M`
  if (n >= 1_000) return `${(n / 1_000).toFixed(1)}K`
  return String(n)
}
```

### Props

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| reels | ReelItem[] | - | Lista de reels |
| hasBottomNav | boolean | false | Agrega padding para bottom nav móvil |
| className | string | - | Clases adicionales al container |

### Uso

```tsx
const reels = [
  {
    id: '1',
    username: 'mariagtz',
    avatar: '/avatars/maria.jpg',
    title: 'El atardecer más increíble que vi en mi vida 🌅',
    audio: 'Flowers - Miley Cyrus',
    coverImage: '/reels/cover1.jpg',
    likes: 12400,
    comments: 234,
  },
  {
    id: '2',
    username: 'carlos_v',
    avatar: '/avatars/carlos.jpg',
    title: 'Viaje espontáneo a la montaña ⛰️',
    coverImage: '/reels/cover2.jpg',
    likes: 8900,
    comments: 156,
  },
]

// Con bottom nav (mobile app layout)
<ReelsFeed reels={reels} hasBottomNav />

// Sin bottom nav
<ReelsFeed reels={reels} />
```

---

## Personalización

- **Con bottom nav**: pasar `hasBottomNav={true}` — ajusta los `bottom-*` para no tapar el contenido
- **Scroll sin nav visible**: combinar con `ContentViewer` del patrón `common/content-viewer` para abrir en overlay fullscreen
- **Con video real**: reemplazar `<Image>` por `<video autoPlay muted loop playsInline>` cuando `isActive`
- **Colores de acción**: cambiar `text-red-500` del like por tu color de acento

---

## Composición con ContentViewer

El patrón completo de Instagram/TikTok no es solo el feed — es **grid de thumbnails → tap → feed fullscreen**. El `ContentViewer` tapa nav, header y todo el layout.

### Anatomía de la composición

```
GridViewer
├── Grid de thumbnails (aspect-[9/16], 2-4 columnas)
│   └── ContentTrigger (cada thumbnail es clickeable)
│       └── <Image> + gradient + info inferior
└── ContentViewer (fixed inset-0 z-[9999], portal)
    └── ReelsFeed (con initialIndex para abrir en el item correcto)
```

### Código

```tsx
'use client'

import { useState } from 'react'
import Image from 'next/image'
import { Play } from 'lucide-react'
import { ContentViewer, ContentTrigger } from '@/components/ui/content-viewer'
import { ReelsFeed } from './ReelsFeed'
import type { ReelItem } from './types'

interface ReelsGridViewerProps {
  reels: ReelItem[]
  /** true para abrir el viewer inmediatamente al montar */
  autoOpen?: boolean
}

export function ReelsGridViewer({ reels, autoOpen = false }: ReelsGridViewerProps) {
  const [open, setOpen] = useState(autoOpen)
  const [startIndex, setStartIndex] = useState(0)

  const openAt = (index: number) => {
    setStartIndex(index)
    setOpen(true)
  }

  return (
    <>
      {/* Grid de thumbnails — aspect-[9/16] para formato vertical */}
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-1 p-1">
        {reels.map((reel, index) => (
          <ContentTrigger
            key={reel.id}
            onTrigger={() => openAt(index)}
            className="relative aspect-[9/16] overflow-hidden bg-black group w-full"
          >
            <Image
              src={reel.coverImage}
              alt={reel.title}
              fill
              className="object-cover transition-transform duration-300 group-hover:scale-105"
              sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 25vw"
            />

            {/* Gradient */}
            <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-transparent to-transparent" />

            {/* Play icon on hover */}
            <div className="absolute inset-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
              <div className="p-3 rounded-full bg-white/20 backdrop-blur-sm">
                <Play className="w-6 h-6 text-white fill-white" />
              </div>
            </div>

            {/* Info inferior */}
            <div className="absolute bottom-0 inset-x-0 p-2">
              <p className="text-white text-xs font-semibold leading-tight line-clamp-2">
                {reel.title}
              </p>
            </div>
          </ContentTrigger>
        ))}
      </div>

      {/* Viewer fullscreen — tapa nav, header, todo */}
      <ContentViewer open={open} onClose={() => setOpen(false)}>
        <ReelsFeed reels={reels} initialIndex={startIndex} />
      </ContentViewer>
    </>
  )
}
```

### Props del ReelsFeed extendido

Para que funcione con `initialIndex`, el `ReelsFeed` necesita la prop y hacer scroll al montar:

```tsx
interface ReelsFeedProps {
  reels: ReelItem[]
  hasBottomNav?: boolean
  /** Índice inicial al abrir. Default: 0 */
  initialIndex?: number
  className?: string
}

// Dentro del componente, agregar este effect:
useEffect(() => {
  const container = containerRef.current
  if (!container || initialIndex === 0) return
  container.scrollTop = initialIndex * container.clientHeight
}, [initialIndex])
```

### Uso

```tsx
// Página — server component fetcha, client component renderiza
const reels = await getReels()

// Con autoOpen: abre el viewer directamente (sin mostrar el grid)
<ReelsGridViewer reels={reels} autoOpen />

// Sin autoOpen: muestra el grid primero
<ReelsGridViewer reels={reels} />
```

### Cuándo usar `autoOpen`

- La ruta `/reels` debe abrir el feed directamente → `autoOpen={true}`
- Un componente embebido en un perfil o home → `autoOpen={false}` (muestra el grid)

> Ver skill `common/content-viewer` para detalles del overlay y el hook `useContentViewer`.

---

## Variantes: Orden Aleatorio + Loop Infinito

Dos mejoras independientes que se pueden combinar. El shuffle se aplica **una sola vez al montar**. El loop ocurre **cuando el feed llega al último item**.

### 1. Orden aleatorio al montar

Shufflear el array en el `useState` lazy initializer — se ejecuta una sola vez, no en cada re-render.

```tsx
function shuffleArray<T>(arr: T[]): T[] {
  const result = [...arr]
  for (let i = result.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[result[i], result[j]] = [result[j], result[i]]
  }
  return result
}
```

En el componente que recibe los items (grid viewer o feed directamente):

```tsx
export function ReelsGridViewer({ reels, autoOpen = false }: ReelsGridViewerProps) {
  // Shuffle una sola vez al montar — lazy initializer
  const [items] = useState(() => shuffleArray(reels))
  const [open, setOpen] = useState(autoOpen)
  const [startIndex, setStartIndex] = useState(0)

  // El grid y el feed usan `items`, no `reels`
  // ...
}
```

### 2. Loop infinito al llegar al final

Modificar `scrollTo` en `ReelsFeed` para que al llegar al último item, el siguiente scroll vuelva al primero con el mismo `behavior: 'smooth'` — igual que cualquier otra transición.

```tsx
const scrollTo = (direction: 'up' | 'down') => {
  const container = containerRef.current
  if (!container) return

  let newIndex: number
  if (direction === 'down' && currentIndex === items.length - 1) {
    newIndex = 0  // loop al inicio
  } else {
    newIndex = direction === 'up'
      ? Math.max(0, currentIndex - 1)
      : Math.min(items.length - 1, currentIndex + 1)
  }

  container.scrollTo({ top: newIndex * container.clientHeight, behavior: 'smooth' })
}
```

Para que el loop también funcione con **swipe táctil** (no solo con los botones), detectar cuando el usuario intenta scrollear más allá del último item:

```tsx
useEffect(() => {
  const container = containerRef.current
  if (!container) return

  const handleScroll = () => {
    const index = Math.round(container.scrollTop / container.clientHeight)
    setCurrentIndex(index)

    // Cuando llega al último, volver al primero en el siguiente frame
    if (index === items.length - 1) {
      const onNextScroll = () => {
        container.scrollTo({ top: 0, behavior: 'smooth' })
        container.removeEventListener('scroll', onNextScroll)
      }
      container.addEventListener('scroll', onNextScroll, { once: true, passive: true })
    }
  }

  container.addEventListener('scroll', handleScroll, { passive: true })
  return () => container.removeEventListener('scroll', handleScroll)
}, [items.length])
```

### Combinados en ReelsFeed

```tsx
export function ReelsFeed({ reels, hasBottomNav = false, initialIndex = 0, className }: ReelsFeedProps) {
  // Shuffle una sola vez
  const [items] = useState(() => shuffleArray(reels))

  const containerRef = useRef<HTMLDivElement>(null)
  const [currentIndex, setCurrentIndex] = useState(initialIndex)

  // Scroll al índice inicial
  useEffect(() => {
    const container = containerRef.current
    if (!container || initialIndex === 0) return
    container.scrollTop = initialIndex * container.clientHeight
  }, [initialIndex])

  // Tracking de posición + loop táctil
  useEffect(() => {
    const container = containerRef.current
    if (!container) return

    const handleScroll = () => {
      const index = Math.round(container.scrollTop / container.clientHeight)
      setCurrentIndex(index)

      if (index === items.length - 1) {
        const onNextScroll = () => {
          container.scrollTo({ top: 0, behavior: 'smooth' })
          container.removeEventListener('scroll', onNextScroll)
        }
        container.addEventListener('scroll', onNextScroll, { once: true, passive: true })
      }
    }

    container.addEventListener('scroll', handleScroll, { passive: true })
    return () => container.removeEventListener('scroll', handleScroll)
  }, [items.length])

  // Loop en botones de navegación
  const scrollTo = (direction: 'up' | 'down') => {
    const container = containerRef.current
    if (!container) return

    let newIndex: number
    if (direction === 'down' && currentIndex === items.length - 1) {
      newIndex = 0
    } else {
      newIndex = direction === 'up'
        ? Math.max(0, currentIndex - 1)
        : Math.min(items.length - 1, currentIndex + 1)
    }

    container.scrollTo({ top: newIndex * container.clientHeight, behavior: 'smooth' })
  }

  // ... resto del render usando `items` en lugar de `reels`
}
```
