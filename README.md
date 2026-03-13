# ia-skills

Skills de IA para Claude Code. Catálogo de patrones UI de apps populares.

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/informaticadiaz/ia-skills.git ~/.claude/ia-skills

# Ejecutar instalador
~/.claude/ia-skills/install.sh
```

O en un solo comando:

```bash
curl -fsSL https://raw.githubusercontent.com/informaticadiaz/ia-skills/main/install.sh | bash
```

## Skills disponibles

### `/design` - Patrones UI

Genera componentes basados en patrones de diseño de apps populares.

```
/design
```

La skill detecta automáticamente tu framework (React, Vue, Svelte) y estilos (Tailwind, CSS).

#### Apps soportadas

| App | Patrones |
|-----|----------|
| **Instagram** | stories, feed-card, profile-grid, reels, story-viewer |
| **Airbnb** | listing-card, search-bar, map-listings, review-summary, host-card |
| **Spotify** | playlist-card, track-row, now-playing, horizontal-scroll, artist-header |
| **Common** | bottom-sheet, command-palette, masonry-grid |

#### Ejemplo de uso

```
Usuario: /design

Claude: ¿De qué app querés el patrón?
        [Instagram] [Airbnb] [Spotify] [Common]

Usuario: Instagram

Claude: ¿Qué componente?
        [Stories] [Feed Card] [Profile Grid] [Reels] [Story Viewer]

Usuario: Stories

Claude: Detecté: React + TypeScript + Tailwind
        → Generando componente...
```

## Estructura del proyecto

```
ia-skills/
├── README.md
├── install.sh
└── skills/
    └── design/
        ├── design.md           # Skill principal
        ├── patterns.json       # Índice de patrones
        └── patterns/
            ├── instagram/
            ├── airbnb/
            ├── spotify/
            └── common/
```

## Contribuir

1. Fork del repositorio
2. Crear branch para tu patrón: `git checkout -b pattern/app-name`
3. Agregar patrón en `skills/design/patterns/app/pattern-name.md`
4. Actualizar `patterns.json`
5. Pull request

### Formato de patrones

Cada patrón debe seguir el template en `skills/design/patterns/TEMPLATE.md`.

## Licencia

MIT
