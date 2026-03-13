---
name: Listing Card
app: airbnb
tags: [card, carousel, favorite, rating, price, image]
complexity: medium
---

# Airbnb Listing Card

## Descripción

Card de alojamiento con carrusel de imágenes, botón de favorito, rating, ubicación y precio por noche. Diseño limpio y escaneable.

## Anatomía

- **Container**: Card con bordes redondeados
- **Image Carousel**: Carrusel con dots de navegación
  - **Images**: Slides de imágenes
  - **Navigation Dots**: Indicadores de posición
  - **Arrows**: Flechas prev/next (hover)
- **Favorite Button**: Corazón en esquina superior derecha
- **Content**: Información del listing
  - **Rating**: Estrella + número
  - **Location**: Ciudad, País
  - **Title**: Nombre del alojamiento
  - **Dates**: Fechas disponibles
  - **Price**: Precio por noche

## Variantes

- **Con carrusel**: Múltiples imágenes navegables
- **Sin carrusel**: Imagen única
- **Compact**: Sin fechas ni descripción
- **Horizontal**: Layout en fila para listas

## Estados

- **Default**: Estado normal
- **Hover**: Flechas de carrusel visibles
- **Favorited**: Corazón relleno rojo
- **Loading**: Skeleton pulsando

## Accesibilidad

- `role="article"` en la card
- `aria-label` descriptivo
- Carrusel navegable con teclado
- Botón favorito con estado `aria-pressed`

---

## React + TypeScript + Tailwind

```tsx
"use client"

import { useState } from "react"
import { cn } from "@/lib/utils"
import { Heart, ChevronLeft, ChevronRight, Star } from "lucide-react"

interface ListingCardProps {
  id: string
  images: string[]
  title: string
  location: string
  rating?: number
  reviewCount?: number
  dates?: string
  price: number
  currency?: string
  isFavorite?: boolean
  onFavoriteToggle?: (id: string) => void
  onClick?: (id: string) => void
  className?: string
}

export function ListingCard({
  id,
  images,
  title,
  location,
  rating,
  reviewCount,
  dates,
  price,
  currency = "$",
  isFavorite = false,
  onFavoriteToggle,
  onClick,
  className,
}: ListingCardProps) {
  const [currentImage, setCurrentImage] = useState(0)
  const [isHovered, setIsHovered] = useState(false)

  const nextImage = (e: React.MouseEvent) => {
    e.stopPropagation()
    setCurrentImage((prev) => (prev + 1) % images.length)
  }

  const prevImage = (e: React.MouseEvent) => {
    e.stopPropagation()
    setCurrentImage((prev) => (prev - 1 + images.length) % images.length)
  }

  const handleFavorite = (e: React.MouseEvent) => {
    e.stopPropagation()
    onFavoriteToggle?.(id)
  }

  return (
    <article
      role="article"
      className={cn("group cursor-pointer", className)}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onClick={() => onClick?.(id)}
    >
      {/* Image Carousel */}
      <div className="relative aspect-square overflow-hidden rounded-xl">
        {/* Images */}
        <div
          className="flex h-full transition-transform duration-300 ease-out"
          style={{ transform: `translateX(-${currentImage * 100}%)` }}
        >
          {images.map((image, index) => (
            <img
              key={index}
              src={image}
              alt={`${title} - imagen ${index + 1}`}
              className="h-full w-full flex-shrink-0 object-cover"
            />
          ))}
        </div>

        {/* Favorite Button */}
        <button
          onClick={handleFavorite}
          aria-pressed={isFavorite}
          aria-label={isFavorite ? "Quitar de favoritos" : "Agregar a favoritos"}
          className="absolute right-3 top-3 z-10"
        >
          <Heart
            className={cn(
              "h-6 w-6 drop-shadow-md transition-colors",
              isFavorite
                ? "fill-red-500 text-red-500"
                : "fill-black/50 text-white hover:fill-black/30"
            )}
          />
        </button>

        {/* Navigation Arrows */}
        {images.length > 1 && isHovered && (
          <>
            {currentImage > 0 && (
              <button
                onClick={prevImage}
                aria-label="Imagen anterior"
                className="absolute left-2 top-1/2 -translate-y-1/2 rounded-full bg-white p-1.5 shadow-md opacity-90 hover:opacity-100 hover:scale-105 transition-all"
              >
                <ChevronLeft className="h-4 w-4" />
              </button>
            )}
            {currentImage < images.length - 1 && (
              <button
                onClick={nextImage}
                aria-label="Imagen siguiente"
                className="absolute right-2 top-1/2 -translate-y-1/2 rounded-full bg-white p-1.5 shadow-md opacity-90 hover:opacity-100 hover:scale-105 transition-all"
              >
                <ChevronRight className="h-4 w-4" />
              </button>
            )}
          </>
        )}

        {/* Dots */}
        {images.length > 1 && (
          <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1">
            {images.map((_, index) => (
              <button
                key={index}
                onClick={(e) => {
                  e.stopPropagation()
                  setCurrentImage(index)
                }}
                aria-label={`Ir a imagen ${index + 1}`}
                className={cn(
                  "h-1.5 w-1.5 rounded-full transition-all",
                  currentImage === index
                    ? "bg-white w-2"
                    : "bg-white/60 hover:bg-white/80"
                )}
              />
            ))}
          </div>
        )}
      </div>

      {/* Content */}
      <div className="mt-3 space-y-1">
        <div className="flex items-start justify-between">
          <h3 className="font-medium text-gray-900 line-clamp-1">{location}</h3>
          {rating && (
            <div className="flex items-center gap-1 flex-shrink-0">
              <Star className="h-4 w-4 fill-current" />
              <span className="text-sm">
                {rating.toFixed(2)}
                {reviewCount && (
                  <span className="text-gray-500"> ({reviewCount})</span>
                )}
              </span>
            </div>
          )}
        </div>
        <p className="text-gray-500 text-sm line-clamp-1">{title}</p>
        {dates && <p className="text-gray-500 text-sm">{dates}</p>}
        <p className="pt-1">
          <span className="font-semibold">{currency}{price.toLocaleString()}</span>
          <span className="text-gray-900"> noche</span>
        </p>
      </div>
    </article>
  )
}
```

### Props

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| id | string | - | ID único del listing |
| images | string[] | - | URLs de imágenes |
| title | string | - | Nombre del alojamiento |
| location | string | - | Ciudad, País |
| rating | number | - | Rating promedio (ej: 4.92) |
| reviewCount | number | - | Cantidad de reviews |
| dates | string | - | Rango de fechas disponibles |
| price | number | - | Precio por noche |
| currency | string | "$" | Símbolo de moneda |
| isFavorite | boolean | false | Estado de favorito |
| onFavoriteToggle | (id) => void | - | Callback al togglear favorito |
| onClick | (id) => void | - | Callback al clickear card |

### Uso

```tsx
const listings = [
  {
    id: "1",
    images: ["/img1.jpg", "/img2.jpg", "/img3.jpg"],
    title: "Casa moderna con vista al mar",
    location: "Punta del Este, Uruguay",
    rating: 4.92,
    reviewCount: 128,
    dates: "15-20 de marzo",
    price: 150,
  },
  // ...
]

<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
  {listings.map((listing) => (
    <ListingCard
      key={listing.id}
      {...listing}
      onFavoriteToggle={(id) => toggleFavorite(id)}
      onClick={(id) => router.push(`/listing/${id}`)}
    />
  ))}
</div>
```

---

## Vue 3 + TypeScript + Tailwind

```vue
<script setup lang="ts">
import { ref } from "vue"
import { Heart, ChevronLeft, ChevronRight, Star } from "lucide-vue-next"

interface Props {
  id: string
  images: string[]
  title: string
  location: string
  rating?: number
  reviewCount?: number
  dates?: string
  price: number
  currency?: string
  isFavorite?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  currency: "$",
  isFavorite: false,
})

const emit = defineEmits<{
  favoriteToggle: [id: string]
  click: [id: string]
}>()

const currentImage = ref(0)
const isHovered = ref(false)

const nextImage = (e: Event) => {
  e.stopPropagation()
  currentImage.value = (currentImage.value + 1) % props.images.length
}

const prevImage = (e: Event) => {
  e.stopPropagation()
  currentImage.value = (currentImage.value - 1 + props.images.length) % props.images.length
}

const handleFavorite = (e: Event) => {
  e.stopPropagation()
  emit("favoriteToggle", props.id)
}
</script>

<template>
  <article
    role="article"
    class="group cursor-pointer"
    @mouseenter="isHovered = true"
    @mouseleave="isHovered = false"
    @click="emit('click', id)"
  >
    <div class="relative aspect-square overflow-hidden rounded-xl">
      <div
        class="flex h-full transition-transform duration-300 ease-out"
        :style="{ transform: `translateX(-${currentImage * 100}%)` }"
      >
        <img
          v-for="(image, index) in images"
          :key="index"
          :src="image"
          :alt="`${title} - imagen ${index + 1}`"
          class="h-full w-full flex-shrink-0 object-cover"
        />
      </div>

      <button
        @click="handleFavorite"
        :aria-pressed="isFavorite"
        :aria-label="isFavorite ? 'Quitar de favoritos' : 'Agregar a favoritos'"
        class="absolute right-3 top-3 z-10"
      >
        <Heart
          class="h-6 w-6 drop-shadow-md transition-colors"
          :class="isFavorite
            ? 'fill-red-500 text-red-500'
            : 'fill-black/50 text-white hover:fill-black/30'"
        />
      </button>

      <template v-if="images.length > 1 && isHovered">
        <button
          v-if="currentImage > 0"
          @click="prevImage"
          aria-label="Imagen anterior"
          class="absolute left-2 top-1/2 -translate-y-1/2 rounded-full bg-white p-1.5 shadow-md"
        >
          <ChevronLeft class="h-4 w-4" />
        </button>
        <button
          v-if="currentImage < images.length - 1"
          @click="nextImage"
          aria-label="Imagen siguiente"
          class="absolute right-2 top-1/2 -translate-y-1/2 rounded-full bg-white p-1.5 shadow-md"
        >
          <ChevronRight class="h-4 w-4" />
        </button>
      </template>

      <div v-if="images.length > 1" class="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1">
        <button
          v-for="(_, index) in images"
          :key="index"
          @click.stop="currentImage = index"
          :aria-label="`Ir a imagen ${index + 1}`"
          class="h-1.5 rounded-full transition-all"
          :class="currentImage === index ? 'bg-white w-2' : 'bg-white/60 w-1.5'"
        />
      </div>
    </div>

    <div class="mt-3 space-y-1">
      <div class="flex items-start justify-between">
        <h3 class="font-medium text-gray-900 line-clamp-1">{{ location }}</h3>
        <div v-if="rating" class="flex items-center gap-1 flex-shrink-0">
          <Star class="h-4 w-4 fill-current" />
          <span class="text-sm">{{ rating.toFixed(2) }}</span>
        </div>
      </div>
      <p class="text-gray-500 text-sm line-clamp-1">{{ title }}</p>
      <p v-if="dates" class="text-gray-500 text-sm">{{ dates }}</p>
      <p class="pt-1">
        <span class="font-semibold">{{ currency }}{{ price.toLocaleString() }}</span>
        <span class="text-gray-900"> noche</span>
      </p>
    </div>
  </article>
</template>
```

---

## Personalización

- **Aspect ratio**: Cambiar `aspect-square` por `aspect-[4/3]` o `aspect-video`
- **Bordes**: Agregar `shadow-sm` o `border` para más definición
- **Transiciones**: Modificar `duration-300` para carrusel más rápido/lento
- **Rating**: Cambiar ícono de estrella por otro sistema
- **Favorito**: Usar animación de "pop" con `animate-ping` al marcar
