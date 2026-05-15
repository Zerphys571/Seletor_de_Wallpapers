#!/bin/bash

# ==============================================================================
# SCRIPT DE GERENCIAMENTO DE WALLPAPER (Imagens e Vídeos)
# Descrição: Altera o fundo de tela usando mpvpaper (vídeo) ou awww (imagem).
# ==============================================================================

# --- Verificação e Criação de Pastas Base ---
[[ ! -d "${HOME}/Imagens/Wallpapers" ]] && mkdir -p "${HOME}/Imagens/Wallpapers"
[[ ! -d "${HOME}/Imagens/videos" ]] && mkdir -p "${HOME}/Imagens/videos"

# --- Configuração de Caminhos ---
DIR_WALLPAPER="${HOME}/Imagens/Wallpapers"
DIR_LOG="${HOME}/.logs"
ARQUIVO_LOG="${DIR_LOG}/wallpaper.log"
CACHE_BASE="${HOME}/.cache/wallpaper_thumbs"

# --- Definição de Cores e Estética ---
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\x1b[33m"
RESET="\e[0m"
THUMB_HEIGHT="200x200"

# --- Parâmetros de Transição (awww) ---
TRANS_TYPE="wipe"
FPS="30"
STEP="24"
TRANS_DURATION="1.5"
ANGULO_POSSIVEIS=(0 45 90 135 180 225 270 315)

# ==============================================================================
# FUNÇÕES AUXILIARES
# ==============================================================================

# Função para registro de atividades
criacao_log() {
    local STATUS="$1"
    local NOME_SCRIPT=$(basename "$0")
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$NOME_SCRIPT] $STATUS: ${PATH_WALLPAPER}" >>"${ARQUIVO_LOG}"
}

# Função Principal de Seleção (Rofi + Miniaturas)
verificacao() {
    # Lista arquivos (Adicionado suporte a GIF)
    mapfile -t WALLPAPERS < <(find "${DIR_WALLPAPER}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.mp4" -o -iname "*.gif" -o -iname "*.webm" \) -printf "%f\n")

    if [[ ${#WALLPAPERS[@]} -eq 0 ]]; then
        echo -e "${RED}Erro: Nenhum wallpaper encontrado em ${DIR_WALLPAPER}${RESET}"
        criacao_log "Erro: Pasta vazia"
        exit 1
    fi

    # Limpeza de cache órfão
    for arq in "${CACHE_THUMBS}"/*; do
        [ -e "${arq}" ] || continue
        nome_arquivo=$(basename "${arq}")
        original="${nome_arquivo%.png}"

        if [[ ! -f "$DIR_WALLPAPER/${nome_arquivo}" && ! -f "${DIR_WALLPAPER}/${original}" ]]; then
            rm "${arq}"
            criacao_log "Lixo removido: ${nome_arquivo}"
        fi
    done

    # Geração de miniaturas em background
    for arquivo in "${WALLPAPERS[@]}"; do
        EXT="${arquivo##*.}"
        EXT="${EXT,,}"

        if [[ "$EXT" == "mp4" || "$EXT" == "webm" || "$EXT" == "mkv" ]]; then
            [[ -f "${CACHE_THUMBS}/${arquivo}.png" ]] && continue
            ffmpeg -y -i "${DIR_WALLPAPER}/${arquivo}" -ss 00:00:01 -vframes 1 -f image2 "${CACHE_THUMBS}/${arquivo}.png" &>/dev/null &
        elif [[ "$EXT" == "jpg" || "$EXT" == "jpeg" || "$EXT" == "png" || "$EXT" == "gif" ]]; then
            [[ -f "${CACHE_THUMBS}/${arquivo}" ]] && continue
            magick "${DIR_WALLPAPER}/${arquivo}" -thumbnail "${THUMB_HEIGHT}" "${CACHE_THUMBS}/${arquivo}" &
        fi
    done

    wait # Aguarda processamento das imagens

    # Menu Rofi
    ESCOLHA=$(for img in "${WALLPAPERS[@]}"; do
        EXT_IMG="${img##*.}"
        EXT_IMG="${EXT_IMG,,}"

        if [[ "$EXT_IMG" == "mp4" || "$EXT_IMG" == "mkv" || "$EXT_IMG" == "webm" ]]; then
            printf "%s\x00icon\x1f${CACHE_THUMBS}/%s\n" "${img}" "${img}.png"
        else
            printf "%s\x00icon\x1f${CACHE_THUMBS}/%s\n" "${img}" "${img}"
        fi
    done | sort | rofi -dmenu -p "Selecione o Wallpaper:" -show-icons)

    [[ -z "${ESCOLHA}" ]] && exit 1
    PATH_WALLPAPER="${DIR_WALLPAPER}/${ESCOLHA}"
}

# --- Preparação do Ambiente ---
#Cria a pasta dos LOGs e a de CACHE para as thumbs
mkdir -p "${DIR_LOG}" "${CACHE_BASE}/imagens" "${CACHE_BASE}/videos"

# ==============================================================================
# 1. VERIFICAÇÃO DE DEPENDÊNCIAS
# ==============================================================================
for cmd in mpvpaper awww rofi ffmpeg magick; do
    if ! command -v $cmd >/dev/null; then
        echo -e "${RED}Erro: $cmd não instalado.${RESET}"
        exit 1
    fi
done

# ==============================================================================
# 2. LÓGICA DE ENTRADA
# ==============================================================================

if [[ "${1}" == "--help" || "${1}" == "-h" ]]; then
    echo -e "${YELLOW}Uso: wallpaper [opção] ou [caminho]${RESET}"
    echo -e "\nDescrição: Altera o wallpaper da área de trabalho."
    echo -e "\nOpções:"
    echo -e " -h, --help    Mostra esta ajuda"
    echo -e " -m, --menu    Menu de imagens (Wallpapers)"
    echo -e " -v, --video   Menu de vídeos (Videos)"
    exit 0

elif [[ "${1}" == "-v" || "${1}" == "--video" ]]; then
    DIR_WALLPAPER="${HOME}/Imagens/videos"
    CACHE_THUMBS="${CACHE_BASE}/videos"
    verificacao

elif [[ "${1}" == "--menu" || "${1}" == "-m" || -z "${1}" ]]; then
    CACHE_THUMBS="${CACHE_BASE}/imagens"
    verificacao

else
    PATH_WALLPAPER="$1"
    [[ -z "$PATH_WALLPAPER" ]] && exit 1
fi

# ==============================================================================
# 3. EXECUÇÃO E APLICAÇÃO
# ==============================================================================

if [[ -f "$PATH_WALLPAPER" ]]; then
    EXTENSAO="${PATH_WALLPAPER##*.}"
    EXTENSAO="${EXTENSAO,,}"

    pkill mpvpaper

    # Vídeos
    if [[ "$EXTENSAO" == "mp4" || "$EXTENSAO" == "mkv" || "$EXTENSAO" == "webm" ]]; then
        { nohup mpvpaper -o "hwdec=auto no-audio profile=fast framedrop=vo --vf=fade=t=in:st=0:d=1 loop" '*' "${PATH_WALLPAPER}" &>/dev/null && criacao_log "Sucesso (Vídeo)"; } &

    # Imagens e GIFs
    elif [[ "$EXTENSAO" == "jpeg" || "$EXTENSAO" == "png" || "$EXTENSAO" == "jpg" || "$EXTENSAO" == "gif" ]]; then
        ANGULO=${ANGULO_POSSIVEIS[$RANDOM % ${#ANGULO_POSSIVEIS[@]}]}

        if awww img "${PATH_WALLPAPER}" \
            --transition-type "${TRANS_TYPE}" \
            --transition-fps "${FPS}" \
            --transition-step "${STEP}" \
            --transition-duration "${TRANS_DURATION}" \
            --transition-angle "${ANGULO}"; then
            criacao_log "Sucesso (Imagem)"
        else
            echo -e "${RED}Erro na aplicação${RESET}"
            criacao_log "Erro na aplicação"
            exit 1
        fi
    fi
else
    echo -e "${RED}Erro: Arquivo não encontrado.${RESET}"
    exit 1
fi
