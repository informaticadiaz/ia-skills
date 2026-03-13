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
