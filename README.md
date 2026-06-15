# Gerenciador de Wallpapers para Hyprland

Um script simples para gerenciar wallpapers estáticos e animados no **Hyprland**, utilizando **Rofi** como menu visual interativo.

Compatível com imagens, GIFs e vídeos, com suporte a cache automático de miniaturas para melhorar o desempenho.

---

# ✨ Funcionalidades

- Seleção visual de wallpapers com **Rofi**
- Suporte a wallpapers:
  - Estáticos
  - GIFs animados
  - Vídeos
- Sistema de cache de miniaturas
- Aplicação rápida de wallpapers
- Integração completa com o **Hyprland**
- Compatível com Wayland

---

# 📂 Formatos Suportados

## Imagens

- `.jpg`
- `.jpeg`
- `.png`
- `.gif`

## Vídeos

- `.mp4`
- `.mkv`
- `.webm`

---

# 📁 Estrutura de Diretórios

Organize seus arquivos da seguinte forma dentro da pasta `~/Imagens`:

```plaintext
~/Imagens/
├── Wallpapers/
│   ├── wallpaper1.jpg
│   ├── wallpaper2.png
│   └── animado.gif
│
└── videos/
    ├── video1.mp4
    ├── anime.mkv
    └── loop.webm
```
O script verifica automaticamente se as pastas principais existem e, caso não existam, elas serão criadas automaticamente na primeira execução.

O script criará automaticamente:

```plaintext
~/.cache/wallpaper_thumbs
~/.logs
~/Imagens/Wallpapers
~/Imagens/videos
```

Essas pastas serão utilizadas para:

- Cache de miniaturas
- Histórico de wallpapers utilizados

---

# 📦 Dependências

Instale os seguintes pacotes:

## Necessários

- `mpv`
- `mpvpaper`
- `rofi`
- `ffmpeg`
- `imagemagick`
- `swww` *(ou awww)*

---

# ⚙️ Configuração no Hyprland

Adicione a seguinte linha ao arquivo:

```plaintext
~/.config/hypr/hyprland.conf
```

Caso utilize `swww`:

```ini
exec-once = swww-daemon
```

Caso utilize `awww`:

```ini
exec-once = awww-daemon
```

---

# 🚀 Instalação

## 1. Dar permissão de execução

```bash
chmod +x wallpaper.sh
```

## 2. Mover para o sistema

```bash
sudo cp ./wallpaper.sh /usr/local/bin/wallpaper
```

Agora o comando `wallpaper` poderá ser executado em qualquer terminal.

---

# 🖼️ Uso

## Abrir seletor de imagens

```bash
wallpaper
```

ou

```bash
wallpaper -m
```

---

## Abrir seletor de vídeos

```bash
wallpaper -v
```

---

## Aplicar wallpaper diretamente

```bash
wallpaper ~/Imagens/Wallpapers/wallpaper1.jpg
```

---

## Exibir ajuda

```bash
wallpaper --help
```

---

# ⌨️ Atalhos no Hyprland

Adicione ao arquivo:

```plaintext
~/.config/hypr/hyprland.conf
```

## Exemplo

```ini
# Abrir seletor de imagens
bind = $mainMod, W, exec, wallpaper -m

# Abrir seletor de vídeos
bind = $mainMod SHIFT, W, exec, wallpaper -v
```

---

# 📌 Exemplos de Uso

## Aplicando uma imagem

```bash
wallpaper ~/Imagens/Wallpapers/neon_city.png
```

---

## Aplicando um GIF

```bash
wallpaper ~/Imagens/Wallpapers/animado.gif
```

---

## Aplicando um vídeo

```bash
wallpaper ~/Imagens/videos/cyberpunk.mp4
```

---

# 🛠️ Tecnologias Utilizadas

- Hyprland
- Rofi
- mpv
- FFmpeg
- ImageMagick

---

# 👤 Autor: Luis Guilherme

Script desenvolvido para uso pessoal e compartilhamento com a comunidade.
