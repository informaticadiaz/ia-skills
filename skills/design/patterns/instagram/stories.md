---
name: Stories
app: instagram
tags: [social, carousel, avatar, horizontal-scroll, gradient]
complexity: medium
---

# Instagram Stories

## Descripción

Carrusel horizontal de avatares circulares. El borde con gradiente indica contenido no visto. Primer elemento puede ser "Tu historia" con ícono de agregar.

## Anatomía

- **Container**: Scroll horizontal con overflow oculto
- **Story Item**: Contenedor de cada historia
  - **Ring**: Borde circular (gradiente si no visto, gris si visto)
  - **Avatar**: Imagen circular del usuario
  - **Add Icon**: Ícono + para "Tu historia" (opcional)
  - **Username**: Nombre truncado debajo

## Variantes

- **Con "Agregar historia"**: Primer item es del usuario actual con ícono +
- **Sin "Agregar historia"**: Solo muestra historias de otros
- **Tamaños**: sm (48px), md (64px), lg (80px)
- **Con/sin nombres**: Puede ocultar los usernames

## Estados

- **No visto**: Borde con gradiente colorido
- **Visto**: Borde gris claro
- **Live**: Borde con gradiente + label "EN VIVO"
- **Loading**: Skeleton circular pulsando

## Accesibilidad

- `role="list"` en container
- `role="listitem"` en cada story
- `aria-label="Historia de [username]"` en cada item
- Navegable con flechas de teclado

---

## React + TypeScript + Tailwind

```tsx
import { cn } from "@/lib/utils"

interface Story {
  id: string
  username: string
  avatar: string
  hasUnseenStory: boolean
  isLive?: boolean
}

interface StoriesProps {
  stories: Story[]
  showAddStory?: boolean
  currentUserAvatar?: string
  size?: "sm" | "md" | "lg"
  onStoryClick?: (storyId: string) => void
  onAddStoryClick?: () => void
  className?: string
}

const sizeClasses = {
  sm: { ring: "w-12 h-12", avatar: "w-10 h-10", text: "text-xs" },
  md: { ring: "w-16 h-16", avatar: "w-14 h-14", text: "text-xs" },
  lg: { ring: "w-20 h-20", avatar: "w-[72px] h-[72px]", text: "text-sm" },
}

export function Stories({
  stories,
  showAddStory = true,
  currentUserAvatar,
  size = "md",
  onStoryClick,
  onAddStoryClick,
  className,
}: StoriesProps) {
  const sizes = sizeClasses[size]

  return (
    <div
      role="list"
      className={cn(
        "flex gap-4 overflow-x-auto scrollbar-hide py-2 px-4",
        className
      )}
    >
      {/* Add Story */}
      {showAddStory && (
        <button
          onClick={onAddStoryClick}
          className="flex flex-col items-center gap-1 flex-shrink-0"
          aria-label="Agregar historia"
        >
          <div className={cn("relative", sizes.ring)}>
            <div className="absolute inset-0 rounded-full border-2 border-gray-200" />
            <img
              src={currentUserAvatar || "/placeholder-avatar.jpg"}
              alt="Tu historia"
              className={cn(
                "rounded-full object-cover absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2",
                sizes.avatar
              )}
            />
            <div className="absolute -bottom-0.5 -right-0.5 w-5 h-5 bg-blue-500 rounded-full border-2 border-white flex items-center justify-center">
              <svg className="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
              </svg>
            </div>
          </div>
          <span className={cn("text-gray-900 truncate w-16 text-center", sizes.text)}>
            Tu historia
          </span>
        </button>
      )}

      {/* Stories */}
      {stories.map((story) => (
        <button
          key={story.id}
          role="listitem"
          onClick={() => onStoryClick?.(story.id)}
          className="flex flex-col items-center gap-1 flex-shrink-0"
          aria-label={`Historia de ${story.username}`}
        >
          <div className={cn("relative", sizes.ring)}>
            {/* Gradient ring for unseen stories */}
            <div
              className={cn(
                "absolute inset-0 rounded-full p-[2px]",
                story.hasUnseenStory
                  ? "bg-gradient-to-tr from-yellow-400 via-red-500 to-purple-600"
                  : "bg-gray-200"
              )}
            >
              <div className="w-full h-full rounded-full bg-white p-[2px]">
                <img
                  src={story.avatar}
                  alt={story.username}
                  className="w-full h-full rounded-full object-cover"
                />
              </div>
            </div>
            {/* Live indicator */}
            {story.isLive && (
              <div className="absolute -bottom-1 left-1/2 -translate-x-1/2 px-1.5 py-0.5 bg-gradient-to-r from-pink-500 to-red-500 rounded text-[10px] text-white font-semibold uppercase">
                Live
              </div>
            )}
          </div>
          <span className={cn("text-gray-900 truncate w-16 text-center", sizes.text)}>
            {story.username}
          </span>
        </button>
      ))}
    </div>
  )
}
```

### Props

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| stories | Story[] | - | Lista de historias a mostrar |
| showAddStory | boolean | true | Mostrar botón "Tu historia" |
| currentUserAvatar | string | - | Avatar del usuario actual |
| size | "sm" \| "md" \| "lg" | "md" | Tamaño de los avatares |
| onStoryClick | (id: string) => void | - | Callback al clickear historia |
| onAddStoryClick | () => void | - | Callback al clickear agregar |
| className | string | - | Clases adicionales |

### Uso

```tsx
const stories = [
  { id: "1", username: "maria", avatar: "/avatars/maria.jpg", hasUnseenStory: true },
  { id: "2", username: "carlos", avatar: "/avatars/carlos.jpg", hasUnseenStory: true, isLive: true },
  { id: "3", username: "ana", avatar: "/avatars/ana.jpg", hasUnseenStory: false },
]

<Stories
  stories={stories}
  currentUserAvatar="/avatars/me.jpg"
  onStoryClick={(id) => openStoryViewer(id)}
  onAddStoryClick={() => openCamera()}
/>
```

---

## Vue 3 + TypeScript + Tailwind

```vue
<script setup lang="ts">
interface Story {
  id: string
  username: string
  avatar: string
  hasUnseenStory: boolean
  isLive?: boolean
}

interface Props {
  stories: Story[]
  showAddStory?: boolean
  currentUserAvatar?: string
  size?: "sm" | "md" | "lg"
}

const props = withDefaults(defineProps<Props>(), {
  showAddStory: true,
  size: "md",
})

const emit = defineEmits<{
  storyClick: [storyId: string]
  addStoryClick: []
}>()

const sizeClasses = {
  sm: { ring: "w-12 h-12", avatar: "w-10 h-10", text: "text-xs" },
  md: { ring: "w-16 h-16", avatar: "w-14 h-14", text: "text-xs" },
  lg: { ring: "w-20 h-20", avatar: "w-[72px] h-[72px]", text: "text-sm" },
}

const sizes = computed(() => sizeClasses[props.size])
</script>

<template>
  <div role="list" class="flex gap-4 overflow-x-auto scrollbar-hide py-2 px-4">
    <!-- Add Story -->
    <button
      v-if="showAddStory"
      @click="emit('addStoryClick')"
      class="flex flex-col items-center gap-1 flex-shrink-0"
      aria-label="Agregar historia"
    >
      <div class="relative" :class="sizes.ring">
        <div class="absolute inset-0 rounded-full border-2 border-gray-200" />
        <img
          :src="currentUserAvatar || '/placeholder-avatar.jpg'"
          alt="Tu historia"
          class="rounded-full object-cover absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"
          :class="sizes.avatar"
        />
        <div class="absolute -bottom-0.5 -right-0.5 w-5 h-5 bg-blue-500 rounded-full border-2 border-white flex items-center justify-center">
          <svg class="w-3 h-3 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
        </div>
      </div>
      <span class="text-gray-900 truncate w-16 text-center" :class="sizes.text">
        Tu historia
      </span>
    </button>

    <!-- Stories -->
    <button
      v-for="story in stories"
      :key="story.id"
      role="listitem"
      @click="emit('storyClick', story.id)"
      class="flex flex-col items-center gap-1 flex-shrink-0"
      :aria-label="`Historia de ${story.username}`"
    >
      <div class="relative" :class="sizes.ring">
        <div
          class="absolute inset-0 rounded-full p-[2px]"
          :class="story.hasUnseenStory
            ? 'bg-gradient-to-tr from-yellow-400 via-red-500 to-purple-600'
            : 'bg-gray-200'"
        >
          <div class="w-full h-full rounded-full bg-white p-[2px]">
            <img
              :src="story.avatar"
              :alt="story.username"
              class="w-full h-full rounded-full object-cover"
            />
          </div>
        </div>
        <div
          v-if="story.isLive"
          class="absolute -bottom-1 left-1/2 -translate-x-1/2 px-1.5 py-0.5 bg-gradient-to-r from-pink-500 to-red-500 rounded text-[10px] text-white font-semibold uppercase"
        >
          Live
        </div>
      </div>
      <span class="text-gray-900 truncate w-16 text-center" :class="sizes.text">
        {{ story.username }}
      </span>
    </button>
  </div>
</template>
```

---

## HTML + CSS

```html
<div class="stories" role="list">
  <!-- Add Story -->
  <button class="story-item" aria-label="Agregar historia">
    <div class="story-ring story-ring--add">
      <img src="/avatar.jpg" alt="Tu historia" class="story-avatar">
      <div class="story-add-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
        </svg>
      </div>
    </div>
    <span class="story-username">Tu historia</span>
  </button>

  <!-- Unseen Story -->
  <button class="story-item" role="listitem" aria-label="Historia de maria">
    <div class="story-ring story-ring--unseen">
      <div class="story-ring-inner">
        <img src="/maria.jpg" alt="maria" class="story-avatar">
      </div>
    </div>
    <span class="story-username">maria</span>
  </button>

  <!-- Seen Story -->
  <button class="story-item" role="listitem" aria-label="Historia de carlos">
    <div class="story-ring story-ring--seen">
      <div class="story-ring-inner">
        <img src="/carlos.jpg" alt="carlos" class="story-avatar">
      </div>
    </div>
    <span class="story-username">carlos</span>
  </button>
</div>
```

```css
.stories {
  display: flex;
  gap: 1rem;
  overflow-x: auto;
  padding: 0.5rem 1rem;
  scrollbar-width: none;
}

.stories::-webkit-scrollbar {
  display: none;
}

.story-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.25rem;
  flex-shrink: 0;
  background: none;
  border: none;
  cursor: pointer;
}

.story-ring {
  position: relative;
  width: 64px;
  height: 64px;
  border-radius: 50%;
  padding: 2px;
}

.story-ring--unseen {
  background: linear-gradient(to top right, #fbbf24, #ef4444, #9333ea);
}

.story-ring--seen {
  background: #e5e7eb;
}

.story-ring--add {
  border: 2px solid #e5e7eb;
}

.story-ring-inner {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: white;
  padding: 2px;
}

.story-avatar {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  object-fit: cover;
}

.story-add-icon {
  position: absolute;
  bottom: -2px;
  right: -2px;
  width: 20px;
  height: 20px;
  background: #3b82f6;
  border-radius: 50%;
  border: 2px solid white;
  display: flex;
  align-items: center;
  justify-content: center;
}

.story-add-icon svg {
  width: 12px;
  height: 12px;
  color: white;
}

.story-username {
  font-size: 0.75rem;
  color: #111827;
  width: 64px;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
```

---

## Personalización

- **Colores del gradiente**: Cambiar `from-yellow-400 via-red-500 to-purple-600` por tu paleta
- **Tamaño del ring**: Ajustar las clases en `sizeClasses`
- **Espaciado**: Modificar `gap-4` en el container
- **Ancho del scroll**: Agregar padding lateral según diseño
- **Animación**: Agregar `transition-transform hover:scale-105` para efecto hover
