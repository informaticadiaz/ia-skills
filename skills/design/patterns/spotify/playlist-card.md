---
name: Playlist Card
app: spotify
tags: [card, gradient, music, hover, play]
complexity: easy
---

# Spotify Playlist Card

## Descripción

Card cuadrada con imagen de portada, título y descripción. Al hover muestra botón de play con animación. Fondo con gradiente sutil.

## Anatomía

- **Container**: Card cuadrada con padding
- **Image**: Portada cuadrada con sombra
- **Play Button**: Botón circular verde (aparece en hover)
- **Title**: Nombre de la playlist (bold)
- **Description**: Descripción truncada o artistas

## Variantes

- **Playlist**: Título + descripción/artistas
- **Album**: Título + artista + año
- **Artist**: Solo imagen circular + nombre
- **Podcast**: Título + publisher

## Estados

- **Default**: Sin botón de play
- **Hover**: Botón de play aparece con slide-up
- **Playing**: Ícono de ondas en lugar de play
- **Loading**: Skeleton pulsando

## Accesibilidad

- `role="article"` en la card
- Botón de play con `aria-label="Reproducir [nombre]"`
- Imagen con alt descriptivo

---

## React + TypeScript + Tailwind

```tsx
"use client"

import { useState } from "react"
import { cn } from "@/lib/utils"
import { Play, Pause } from "lucide-react"

interface PlaylistCardProps {
  id: string
  title: string
  description?: string
  image: string
  isPlaying?: boolean
  onPlay?: (id: string) => void
  onClick?: (id: string) => void
  className?: string
}

export function PlaylistCard({
  id,
  title,
  description,
  image,
  isPlaying = false,
  onPlay,
  onClick,
  className,
}: PlaylistCardProps) {
  const [isHovered, setIsHovered] = useState(false)

  const handlePlay = (e: React.MouseEvent) => {
    e.stopPropagation()
    onPlay?.(id)
  }

  return (
    <article
      role="article"
      className={cn(
        "group p-4 rounded-lg bg-neutral-800/40 hover:bg-neutral-800 transition-colors duration-300 cursor-pointer",
        className
      )}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onClick={() => onClick?.(id)}
    >
      {/* Image Container */}
      <div className="relative mb-4">
        <div className="aspect-square overflow-hidden rounded-md shadow-lg shadow-black/40">
          <img
            src={image}
            alt={title}
            className="h-full w-full object-cover"
          />
        </div>

        {/* Play Button */}
        <button
          onClick={handlePlay}
          aria-label={isPlaying ? `Pausar ${title}` : `Reproducir ${title}`}
          className={cn(
            "absolute bottom-2 right-2 h-12 w-12 rounded-full bg-green-500 flex items-center justify-center shadow-xl shadow-black/40 transition-all duration-300",
            "hover:scale-105 hover:bg-green-400",
            "focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 focus:ring-offset-neutral-900",
            isHovered || isPlaying
              ? "opacity-100 translate-y-0"
              : "opacity-0 translate-y-2"
          )}
        >
          {isPlaying ? (
            <Pause className="h-6 w-6 text-black fill-black" />
          ) : (
            <Play className="h-6 w-6 text-black fill-black ml-1" />
          )}
        </button>
      </div>

      {/* Content */}
      <div className="space-y-1 min-h-[62px]">
        <h3 className="font-bold text-white line-clamp-1">{title}</h3>
        {description && (
          <p className="text-sm text-neutral-400 line-clamp-2">{description}</p>
        )}
      </div>
    </article>
  )
}
```

### Props

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| id | string | - | ID único de la playlist |
| title | string | - | Nombre de la playlist |
| description | string | - | Descripción o artistas |
| image | string | - | URL de la portada |
| isPlaying | boolean | false | Si está reproduciéndose |
| onPlay | (id) => void | - | Callback al presionar play |
| onClick | (id) => void | - | Callback al clickear card |

### Uso

```tsx
const playlists = [
  {
    id: "1",
    title: "Discover Weekly",
    description: "Tu mixtape semanal de música fresca",
    image: "/covers/discover.jpg",
  },
  {
    id: "2",
    title: "Liked Songs",
    description: "512 canciones",
    image: "/covers/liked.jpg",
  },
]

<div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-6 p-6">
  {playlists.map((playlist) => (
    <PlaylistCard
      key={playlist.id}
      {...playlist}
      isPlaying={currentPlaying === playlist.id}
      onPlay={(id) => playPlaylist(id)}
      onClick={(id) => router.push(`/playlist/${id}`)}
    />
  ))}
</div>
```

---

## Horizontal Scroll Section

```tsx
interface PlaylistSectionProps {
  title: string
  playlists: PlaylistCardProps[]
}

export function PlaylistSection({ title, playlists }: PlaylistSectionProps) {
  return (
    <section className="space-y-4">
      <div className="flex items-center justify-between px-6">
        <h2 className="text-2xl font-bold text-white">{title}</h2>
        <button className="text-sm font-semibold text-neutral-400 hover:text-white transition-colors">
          Mostrar todo
        </button>
      </div>
      <div className="flex gap-6 overflow-x-auto scrollbar-hide px-6 pb-4">
        {playlists.map((playlist) => (
          <PlaylistCard
            key={playlist.id}
            {...playlist}
            className="flex-shrink-0 w-[180px]"
          />
        ))}
      </div>
    </section>
  )
}
```

---

## Vue 3 + TypeScript + Tailwind

```vue
<script setup lang="ts">
import { ref } from "vue"
import { Play, Pause } from "lucide-vue-next"

interface Props {
  id: string
  title: string
  description?: string
  image: string
  isPlaying?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  isPlaying: false,
})

const emit = defineEmits<{
  play: [id: string]
  click: [id: string]
}>()

const isHovered = ref(false)

const handlePlay = (e: Event) => {
  e.stopPropagation()
  emit("play", props.id)
}
</script>

<template>
  <article
    role="article"
    class="group p-4 rounded-lg bg-neutral-800/40 hover:bg-neutral-800 transition-colors duration-300 cursor-pointer"
    @mouseenter="isHovered = true"
    @mouseleave="isHovered = false"
    @click="emit('click', id)"
  >
    <div class="relative mb-4">
      <div class="aspect-square overflow-hidden rounded-md shadow-lg shadow-black/40">
        <img :src="image" :alt="title" class="h-full w-full object-cover" />
      </div>

      <button
        @click="handlePlay"
        :aria-label="isPlaying ? `Pausar ${title}` : `Reproducir ${title}`"
        class="absolute bottom-2 right-2 h-12 w-12 rounded-full bg-green-500 flex items-center justify-center shadow-xl transition-all duration-300 hover:scale-105 hover:bg-green-400"
        :class="isHovered || isPlaying ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-2'"
      >
        <Pause v-if="isPlaying" class="h-6 w-6 text-black fill-black" />
        <Play v-else class="h-6 w-6 text-black fill-black ml-1" />
      </button>
    </div>

    <div class="space-y-1 min-h-[62px]">
      <h3 class="font-bold text-white line-clamp-1">{{ title }}</h3>
      <p v-if="description" class="text-sm text-neutral-400 line-clamp-2">
        {{ description }}
      </p>
    </div>
  </article>
</template>
```

---

## HTML + CSS

```html
<article class="playlist-card">
  <div class="playlist-image-container">
    <img src="/cover.jpg" alt="Discover Weekly" class="playlist-image">
    <button class="play-button" aria-label="Reproducir Discover Weekly">
      <svg viewBox="0 0 24 24" fill="currentColor">
        <path d="M8 5v14l11-7z"/>
      </svg>
    </button>
  </div>
  <div class="playlist-content">
    <h3 class="playlist-title">Discover Weekly</h3>
    <p class="playlist-description">Tu mixtape semanal de música fresca</p>
  </div>
</article>
```

```css
.playlist-card {
  padding: 1rem;
  border-radius: 0.5rem;
  background: rgba(38, 38, 38, 0.4);
  cursor: pointer;
  transition: background 0.3s;
}

.playlist-card:hover {
  background: rgb(38, 38, 38);
}

.playlist-image-container {
  position: relative;
  margin-bottom: 1rem;
}

.playlist-image {
  aspect-ratio: 1;
  width: 100%;
  object-fit: cover;
  border-radius: 0.375rem;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
}

.play-button {
  position: absolute;
  bottom: 0.5rem;
  right: 0.5rem;
  width: 3rem;
  height: 3rem;
  border-radius: 50%;
  background: #1db954;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transform: translateY(0.5rem);
  transition: all 0.3s;
  cursor: pointer;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.4);
}

.play-button svg {
  width: 1.5rem;
  height: 1.5rem;
  color: black;
  margin-left: 2px;
}

.playlist-card:hover .play-button {
  opacity: 1;
  transform: translateY(0);
}

.play-button:hover {
  transform: scale(1.05);
  background: #1ed760;
}

.playlist-content {
  min-height: 62px;
}

.playlist-title {
  font-weight: 700;
  color: white;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  margin: 0;
}

.playlist-description {
  font-size: 0.875rem;
  color: #a3a3a3;
  margin: 0.25rem 0 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
```

---

## Personalización

- **Color del botón play**: Cambiar `bg-green-500` por color de tu marca
- **Fondo de card**: Ajustar `bg-neutral-800/40` para más/menos transparencia
- **Sombra de imagen**: Modificar `shadow-black/40` según fondo
- **Animación**: Cambiar `duration-300` y `translate-y-2` para efecto diferente
- **Tamaño grid**: Usar `grid-cols-[repeat(auto-fill,minmax(180px,1fr))]` para responsivo
