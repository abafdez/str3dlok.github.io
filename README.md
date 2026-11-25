# str3dlok.github.io

Web y bitácora de la investigación doctoral de Alejandro Baeza (Str3Dlok). Está hecha con Jekyll y la publica GitHub Pages.

## Estructura
- `index.html`: página de inicio. Sus textos están en `_data/inicio.yml`.
- `bitacora.html`: archivo de entradas con filtro por hashtag (se generan solos a partir de las entradas). Admite `?tag=nombre`.
- `contacto.html`: perfil y redes. Sus textos están en `_data/perfil.yml`.
- `_data/`: textos editables. `inicio.yml`, `perfil.yml` y `sitio.yml` (menú y pie).
- `_posts/`: una entrada por archivo, con el nombre `AAAA-MM-DD-titulo.md`.
- `_plantillas/entrada.md`: plantilla con todos los campos de una entrada para quien escriba a mano (no se publica).
- `_includes/`: piezas reutilizables. `md-linea.html` (Markdown en línea para títulos), `url.html` (enlaces escritos en el gestor), `icono-red.html` (iconos de redes).
- `admin/`: gestor de contenidos (Sveltia CMS).
- `assets/`: estilos, scripts (`site.js` común, `bitacora.js` filtro) e imágenes. Las imágenes de las entradas van en `assets/img/posts/`.

## Despliegue
`.github/workflows/pages.yml` construye la web y, si toca, la publica. Funciona igual en este repositorio y en cualquier copia (fork) de pruebas:

- **En cada pull request** solo construye y comprueba los enlaces internos (`.github/comprobar-enlaces.rb`), sin publicar nada.
- **En cada push a `main`** publica únicamente si en *Settings → Pages → Build and deployment → Source* está elegido **GitHub Actions**. Con «Deploy from a branch» solo comprueba que compila, y GitHub sigue publicando como siempre.
- **La ruta base sale sola**: vacía en `str3dlok.github.io` y `/str3dlok.github.io` en `usuario.github.io/str3dlok.github.io/`. Por eso en las plantillas todas las rutas pasan por `relative_url`, y el HTML que viene de Markdown (entradas, biografía) pasa por `_includes/rutas-base.html`.
- **En una copia** la web lleva `noindex` (para no duplicarla en buscadores), y su `/admin/` apunta a la propia copia, no a este repositorio.

Para probar cambios en una copia propia:
1. En la copia, pestaña *Actions*: activar los workflows (en los forks vienen desactivados).
2. *Settings → Pages → Source*: **GitHub Actions**.
3. Subir los cambios a `main` de la copia. La web queda en `https://usuario.github.io/str3dlok.github.io/`.

Comprobar los enlaces en local como si la web estuviera en una subcarpeta:
```bash
bundle exec jekyll build --baseurl /str3dlok.github.io
ruby .github/comprobar-enlaces.rb _site /str3dlok.github.io
```

## Gestor de contenidos (Sveltia CMS)
En <https://str3dlok.github.io/admin/> se editan las entradas de la bitácora y los textos de las páginas sin tocar código. Cada vez que se guarda, el gestor hace un commit en GitHub y GitHub Pages publica el cambio en uno o dos minutos.

**Acceso**: «Sign In Using Access Token» con un token de GitHub. El propio diálogo trae un enlace que abre GitHub con los permisos ya marcados. Si se crea a mano (*Settings → Developer settings → Fine-grained tokens*): en *Repository access* solo este repositorio y, en *Permissions → Contents*, «Read and write». El token se guarda en el navegador; no compartirlo.

**En local**: con `bundle exec jekyll serve` en marcha, abrir <http://localhost:4000/admin/> en Chrome o Edge y pulsar «Work with Local Repository» eligiendo la carpeta del repositorio. Los cambios se escriben en los archivos y se suben con git como cualquier otro.

Qué se puede editar:
- **Bitácora**: crear, editar y borrar entradas. Las imágenes que se suben se convierten a WebP (máx. 1600 px) y van a `assets/img/posts/`. «Publicada» desactivado = borrador.
- **Páginas**: inicio, perfil y contacto, y menú y pie. En los títulos, `**palabra**` sale en dorado y `[texto](#ancla)` es un enlace.

La configuración está en `admin/config.yml`. Las redes también están en `_config.yml` (`social.links`, para el SEO): si cambian, actualizar ambos sitios.

## Componentes del texto (en preparación)
Las piezas especiales dentro de una entrada (carrusel de imágenes, comparador antes/después, visor 3D…) siguen esta convención para que funcionen igual en el gestor, en Jekyll y si algún día se cambia de generador:

- **En el Markdown** son un bloque HTML en su propia línea, con `data-cmp="nombre"` en el elemento raíz. Sin JavaScript se tienen que ver bien (por ejemplo, las imágenes una debajo de otra). Kramdown no procesa el Markdown dentro de esos bloques, así que los pies van en texto o HTML.
  ```html
  <figure data-cmp="comparar"><img src="/assets/img/posts/antes.webp" alt="Antes"><img src="/assets/img/posts/despues.webp" alt="Después"><figcaption>Antes y después</figcaption></figure>
  ```
- **En el gestor**: `CMS.registerEditorComponent` en `admin/componentes.js` (campos, `pattern`, `toBlock` y `toPreview`), y añadir su id en `editor_components` del campo `body` en `admin/config.yml`.
- **En la web**: estilos en `assets/css/style.css` y, si necesita interacción, un módulo en `assets/js/cmp/nombre.js` que se carga solo en las páginas donde aparece.

Las imágenes con pie que inserta el propio gestor ya se guardan así (`<figure><img><figcaption>`) y tienen estilo.

## Modo desarrollo (ver la web en local)
GitHub Pages construye la web sola en cada `push`, así que esto solo hace falta para probar cambios antes de subirlos. Se necesita Ruby (con Bundler) y las herramientas para compilar algunas gemas.

### 1. Instalar Ruby
**Linux / WSL (Debian, Ubuntu)**
```bash
sudo apt update
sudo apt install ruby-full ruby-bundler build-essential zlib1g-dev libssl-dev pkg-config
```
- `ruby-bundler`: en Debian el comando `bundle` va en un paquete aparte; sin él aparece `command not found: bundle`.
- `libssl-dev` y `pkg-config`: la gema `openssl` (dependencia de `github-pages`) se compila al instalarla; sin ellos falla con `OpenSSL library could not be found`.

**macOS** (con [Homebrew](https://brew.sh); el Ruby que trae el sistema es antiguo)
```bash
brew install ruby
echo 'export PATH="$(brew --prefix ruby)/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

**Windows**: instalar [RubyInstaller](https://rubyinstaller.org/downloads/) en su versión *Ruby+Devkit* (3.3) y, al terminar, aceptar el paso `ridk install` (opción 3, MSYS2 y MINGW). También funciona usar WSL y seguir los pasos de Linux.

Comprobar: `ruby -v` (3.x) y `bundle -v`.

### 2. Instalar las dependencias (una vez)
Desde la carpeta del repositorio:
```bash
bundle config set --local path vendor/bundle   # las gemas se quedan en el proyecto, sin sudo
bundle install
```
Si se lanza `bundle install` sin la primera línea, intenta escribir en la carpeta del sistema y falla con `Bundler::PermissionError ... /var/lib/gems`. Basta con ejecutar la línea `bundle config` y repetir.

El `Gemfile` usa la gema `github-pages`, que instala exactamente la misma versión de Jekyll y de los plugins que usa GitHub Pages. Las carpetas `vendor/` y `.bundle/` y el `Gemfile.lock` no se suben al repositorio.

### 3. Arrancar la web
```bash
bundle exec jekyll serve --livereload
```
Abrir <http://localhost:4000>. La página se recarga sola al guardar cualquier archivo. Detener con `Ctrl+C`.

- Jekyll está instalado dentro del proyecto, no en el sistema: siempre `bundle exec jekyll ...`. Escribir solo `jekyll` da `command not found: jekyll`.
- Los cambios en `_config.yml` **no** se recargan: hay que parar y volver a arrancar.
- `--drafts` muestra también los borradores de `_drafts/`.
- `bundle exec jekyll build` solo genera la web en `_site/`, sin servidor.
- Avisos normales que se pueden ignorar: `To use retry middleware with Faraday v2.0+, install faraday-retry gem`, `GitHub Metadata: No GitHub API authentication could be found` y, en WSL, el de que la regeneración automática puede no funcionar en Windows (sí funciona si el repositorio está dentro de Linux, p. ej. en `~/code`, y no en `/mnt/c`).
- Para actualizar a la versión que use GitHub Pages en cada momento: `bundle update github-pages`.

## Campos de cada entrada
`title`, `date`, `published`, `author`, `image`, `image_alt`, `description` (corta, se ve en la bitácora), `resumen` (amplia, dentro de la entrada) y `tags` (hashtags). Opcionales: `youtube` y `sketchfab`. `published: false` deja la entrada como borrador. La declaración de uso de IA va en el pie de todas las páginas.

## Interfaz
Tres temas (Oscuro, Claro y Neón) que se guardan en el navegador. Incluye una rejilla que se ilumina bajo el cursor, un botón flotante para ir arriba o abajo, desplazamiento suave en los enlaces internos, migas de pan y navegación anterior/siguiente (también con las flechas del teclado).

## Normas de contenido
La bitácora es pública. No incluye resultados concretos, tablas, parámetros, herramientas propias ni nombres de personas, entidades, obras o colaboradores.
