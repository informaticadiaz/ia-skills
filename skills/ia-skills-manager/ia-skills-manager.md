# /ia-skills - Gestión del Repositorio ia-skills

Skill para trabajar con el repositorio `ia-skills`: agregar patrones, crear skills nuevas, editar existentes y mantener todo sincronizado.

---

## ⚠️ REGLA FUNDAMENTAL

> **TODO cambio en `~/.claude/ia-skills/` DEBE ser commiteado y pusheado al origen.**
> No existe "edición local sin commit". Si lo editás, lo commiteás. Si lo commiteás, lo pusheás.
> El repo es la fuente de verdad. Lo que no está en GitHub no existe.

```bash
# Flujo obligatorio después de cualquier cambio
cd ~/.claude/ia-skills
git add .
git commit -m "tipo(scope): descripción"
git push
```

---

## Comandos Disponibles

### Verificar estado del repo

Antes de hacer cualquier cosa, revisar que el repo local esté sincronizado:

```bash
cd ~/.claude/ia-skills && git status && git log --oneline -5
```

Si hay commits remotos que no tenés localmente:

```bash
cd ~/.claude/ia-skills && git pull
```

### Listar skills y patrones disponibles

```bash
# Ver estructura completa
find ~/.claude/ia-skills/skills -name "*.md" | sort

# Ver patrones de una app específica
ls ~/.claude/ia-skills/skills/design/patterns/[app]/
```

---

## Estructura del Repositorio

```
ia-skills/
├── README.md
├── install.sh                          # Instalador automático
└── skills/
    ├── design/
    │   ├── design.md                   # Skill principal /design
    │   ├── patterns.json               # Índice de patrones
    │   └── patterns/
    │       ├── TEMPLATE.md             # Plantilla para nuevos patrones
    │       ├── airbnb/
    │       │   └── listing-card.md
    │       ├── instagram/
    │       │   └── stories.md
    │       └── spotify/
    │           └── playlist-card.md
    └── ia-skills-manager/
        └── ia-skills-manager.md        # Este archivo
```

---

## Tareas Comunes

### 1. Agregar un nuevo patrón a una app existente

**Paso 1:** Copiar el TEMPLATE

```bash
cp ~/.claude/ia-skills/skills/design/patterns/TEMPLATE.md \
   ~/.claude/ia-skills/skills/design/patterns/[app]/[nombre-patron].md
```

**Paso 2:** Editar el archivo con el contenido del patrón

Estructura mínima requerida:
- Descripción del patrón
- Anatomía (partes que lo componen)
- Código para React + TypeScript + Tailwind (mínimo)
- Ejemplo de uso

**Paso 3:** Actualizar `patterns.json` con la nueva entrada

```json
{
  "app": "nombre-app",
  "pattern": "nombre-patron",
  "file": "skills/design/patterns/[app]/[nombre-patron].md",
  "tags": ["tag1", "tag2"],
  "complexity": "easy | medium | hard"
}
```

**Paso 4:** Commitear y pushear

```bash
cd ~/.claude/ia-skills
git add .
git commit -m "feat(design): agregar patrón [nombre] de [app]"
git push
```

---

### 2. Agregar una app nueva

**Paso 1:** Crear carpeta de la app

```bash
mkdir ~/.claude/ia-skills/skills/design/patterns/[nueva-app]
```

**Paso 2:** Crear el primer patrón usando el TEMPLATE

**Paso 3:** Agregar la app al skill principal `design.md`

En la sección "Paso 2: Mostrar Apps Disponibles" y "Paso 3: Mostrar Patrones de la App", agregar la nueva app con sus patrones.

**Paso 4:** Commitear y pushear

```bash
cd ~/.claude/ia-skills
git add .
git commit -m "feat(design): agregar app [nombre] con patrón [patrón]"
git push
```

---

### 3. Crear una skill nueva (categoría distinta a design)

**Paso 1:** Crear la carpeta de la skill

```bash
mkdir ~/.claude/ia-skills/skills/[nombre-skill]
```

**Paso 2:** Crear el archivo principal `[nombre-skill].md`

Estructura mínima:
```markdown
# /[nombre-skill] - Descripción breve

## Instrucciones
[Cómo funciona la skill]

## Paso 1: ...
## Paso 2: ...
```

**Paso 3:** Crear el symlink para que Claude Code lo detecte

```bash
ln -s ~/.claude/ia-skills/skills/[nombre-skill]/[nombre-skill].md \
      ~/.claude/commands/[nombre-skill].md
```

**Paso 4:** Commitear y pushear

```bash
cd ~/.claude/ia-skills
git add .
git commit -m "feat([nombre-skill]): crear skill [descripción]"
git push
```

---

### 4. Editar una skill o patrón existente

Editá directamente el archivo en `~/.claude/ia-skills/`.

**Regla:** Al terminar de editar, siempre:

```bash
cd ~/.claude/ia-skills
git add .
git commit -m "feat|fix|docs([scope]): descripción del cambio"
git push
```

No hay "voy a ver si funciona y después commiteo". Commitear ES parte del proceso de edición.

---

### 5. Sincronizar en otra máquina

Si trabajás en otra máquina o reinstalás:

```bash
# Clonar repo
gh repo clone informaticadiaz/ia-skills ~/.claude/ia-skills

# Recrear symlinks
mkdir -p ~/.claude/commands
ln -s ~/.claude/ia-skills/skills/design/design.md ~/.claude/commands/design.md
ln -s ~/.claude/ia-skills/skills/ia-skills-manager/ia-skills-manager.md ~/.claude/commands/ia-skills-manager.md
```

O simplemente correr el installer (que debería mantenerse actualizado):

```bash
curl -fsSL https://raw.githubusercontent.com/informaticadiaz/ia-skills/main/install.sh | bash
```

---

## Convenciones de Commits

```bash
# Nuevo patrón
feat(design): agregar patrón [nombre] de [app]

# Nueva skill
feat([skill]): crear skill [descripción]

# Modificación de patrón existente
fix(design): corregir código de [patrón] en [app]

# Mejora de documentación
docs([skill]): mejorar descripción de [patrón]

# Nueva app
feat(design): agregar app [nombre] con patrones iniciales
```

---

## Verificación Rápida

Antes de cerrar cualquier sesión de trabajo en `ia-skills`:

```bash
cd ~/.claude/ia-skills && git status
```

Si hay cambios sin commitear → commitear y pushear antes de cerrar.
Si el output dice `nothing to commit, working tree clean` → estás bien.
