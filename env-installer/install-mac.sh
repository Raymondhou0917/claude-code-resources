#!/usr/bin/env bash
# ════════════════════════════════════════════════════
#  雷蒙的 AI 基礎環境安裝包(MAC) ── 開源版
#  給所有想讓 AI 上工的人：雙擊一次，環境全部就位。
#
#  基礎：git → 軟體安裝工具（依環境分流）→ GitHub CLI → GitHub 登入
#  選裝路線（開場自己選，不預設）：
#    Claude 路線 / ChatGPT・Codex 路線 / 兩套都裝 / 只裝基礎環境
#  可重跑，已裝好的會自動 skip。
# ════════════════════════════════════════════════════
#  用法：
#    ./install-mac.sh                 # 互動安裝（開場會請你選路線）
#    ./install-mac.sh --skip-auth     # 不登入 GitHub
#    ./install-mac.sh --tools=claude|codex|both|base
#                                     # 直接指定路線，不進選單
#  非互動執行（例如交給 AI Agent 跑）且沒給 --tools 時，
#  只裝基礎環境，不替使用者決定要用哪家的 AI。
#
#  相容性分流：
#    Apple Silicon + macOS 15+ → Homebrew，失敗時改用官方下載
#    Intel / macOS 13–14       → 官方下載，不依賴 Homebrew
#    macOS 12 以下    → 停止並提供升級／網頁版指引
set -euo pipefail

# 版本號：打包成 .app 時會讀這行塞進 Info.plist
VERSION="1.2.0"

AD_URL="https://shifu.tw/course/trial/ai-agent-bootcamp"

WITH_AUTH=1
TOOLS=""          # claude / codex / both / base，空＝進選單問
for arg in "$@"; do
  case "$arg" in
    --skip-auth) WITH_AUTH=0 ;;
    --tools=claude|--tools=codex|--tools=both|--tools=base) TOOLS="${arg#--tools=}" ;;
    -h|--help)
      echo "用法: ./install-mac.sh [--skip-auth] [--tools=claude|codex|both|base]"
      exit 0
      ;;
    *) echo "未知參數: $arg" >&2; exit 2 ;;
  esac
done

# ── 顏色 ─────────────────────────────────────────────
if [[ -t 1 ]]; then
  G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'
  B=$'\033[1m';  C=$'\033[36m';  D=$'\033[2m'; N=$'\033[0m'
else
  G= Y= R= B= C= D= N=
fi
ok()        { printf '  %s✓%s %s\n' "$G" "$N" "$*"; }
warn()      { printf '  %s!%s %s\n' "$Y" "$N" "$*"; }
die()       { printf '  %s✗%s %s\n' "$R" "$N" "$*" >&2; exit 1; }
say()       { printf '  %s\n' "$*"; }
wait_hint() { printf '  %s⏳ %s%s\n' "$C" "$*" "$N"; }
sub()       { printf '     %s‧ %s%s\n' "$D" "$*" "$N"; }
STEP_NO=0
STEP_TOTAL=4
step()      { STEP_NO=$((STEP_NO+1)); printf '\n%s━━━ 第 %s 站 / %s · %s ━━━━━━━━━━━━━%s\n' "$B" "$STEP_NO" "$STEP_TOTAL" "$1" "$N"; }

# ── 安裝結果紀錄（完成畫面只報實際發生的事）─────────
# 值：ok / fail / skip；空字串＝這趟沒碰到，完成畫面不列
ST_GIT=""; ST_BREW=""; ST_GH=""; ST_AUTH=""
ST_CLAUDE=""; ST_CLAUDE_APP=""; ST_CODEX=""; ST_CHATGPT_APP=""
result_line() {  # $1=狀態 $2=項目名 $3=備註（fail/skip 才顯示）
  case "$1" in
    ok)   printf '    %s✓%s %s\n' "$G" "$N" "$2" ;;
    skip) printf '    %s–%s %s%s（%s）%s\n' "$Y" "$N" "$2" "$D" "$3" "$N" ;;
    fail) printf '    %s✗%s %s%s（%s）%s\n' "$R" "$N" "$2" "$D" "$3" "$N" ;;
  esac
}

# 結尾：按 Enter 後真的把 Terminal 視窗關掉
farewell_close() {
  if [[ -t 0 ]]; then
    printf '\n  %s按 Enter 關閉這個視窗 👋%s  ' "$B" "$N"
    read -r _ || true
    if [[ "${TERM_PROGRAM:-}" == "Apple_Terminal" ]]; then
      (sleep 0.2; osascript -e 'tell application "Terminal" to close front window') >/dev/null 2>&1 &
    fi
  fi
}

[[ "$(uname -s)" == "Darwin" ]] || die "這套只支援 macOS（Windows 同學請看 README 的 Windows 段落）"

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    eval "$(brew shellenv 2>/dev/null)" || true
    return 0
  fi
  for b in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$b" ]]; then eval "$("$b" shellenv)"; return 0; fi
  done
  return 1
}

ensure_local_bin() {
  # 官方安裝器會把 claude 放在 ~/.local/bin，先讓這一輪找得到
  if [[ -d "${HOME}/.local/bin" ]]; then
    case ":$PATH:" in
      *":${HOME}/.local/bin:"*) ;;
      *) PATH="${HOME}/.local/bin:$PATH" ;;
    esac
  fi
}

# 把工具路徑寫進殼層設定 —— 不論這趟有沒有裝東西都要跑：
# 本來就有 Homebrew 的人，原本整段會跳過、一行都不寫（學員回報
# 「AI 說找不到 gh」的根因之一）。
# .zprofile 給 login shell（使用者自己開的終端機）；.zshenv 給非
# login 殼層 —— AI 工具跑指令用 `zsh -c`，只讀 .zshenv，少了它
# AI 看不到 /opt/homebrew/bin 或 ~/.local/bin，會誤判「沒安裝」。
# .zshenv 這段刻意不用 `brew shellenv`：新版 brew 改走 path_helper，
# 而 .zshenv 執行時 PATH 可能還沒初始化，eval 下去 PATH 會只剩
# /opt/homebrew/*，反而弄丟 /usr/bin 的系統工具。純 prepend 最穩，
# 而且靠 [ -d ] 執行期判斷，Intel／備用路線／晚點才裝 claude 都適用。
persist_ai_path() {
  if [[ -x /opt/homebrew/bin/brew ]] && ! grep -q 'brew shellenv' "${HOME}/.zprofile" 2>/dev/null; then
    {
      echo ''
      echo '# Homebrew (雷蒙的 AI 基礎環境安裝包 install-mac.sh)'
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
    } >> "${HOME}/.zprofile"
  fi
  if ! grep -q 'AI 基礎環境安裝包' "${HOME}/.zshenv" 2>/dev/null; then
    cat >> "${HOME}/.zshenv" <<'ZSHENV'

# 讓非 login 殼層（AI 工具）也找得到工具 (雷蒙的 AI 基礎環境安裝包 install-mac.sh)
# 三段依序補：Apple Silicon brew／Intel brew 與 pkg 安裝（/usr/local）／官方安裝器（~/.local/bin）
case ":${PATH:-}:" in
  *":/opt/homebrew/bin:"*) ;;
  *) [ -d /opt/homebrew/bin ] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:${PATH:-/usr/bin:/bin:/usr/sbin:/sbin}" ;;
esac
case ":${PATH:-}:" in
  *":/usr/local/bin:"*) ;;
  *) export PATH="/usr/local/bin:${PATH:-/usr/bin:/bin:/usr/sbin:/sbin}" ;;
esac
case ":${PATH:-}:" in
  *":$HOME/.local/bin:"*) ;;
  *) [ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:${PATH:-/usr/bin:/bin:/usr/sbin:/sbin}" ;;
esac
ZSHENV
  fi
}

GH_URL="https://github.com/cli/cli/releases/download/v2.102.0/gh_2.102.0_macOS_universal.pkg"
GH_SHA="1787e65f36626245a6b3cee353a458f6ea4372008548ceb8fb5d5dfb55b006d0"
CODEX_VERSION="0.159.3"
CODEX_ARM_URL="https://github.com/openai/codex/releases/download/rust-v0.159.3/codex-package-aarch64-apple-darwin.tar.gz"
CODEX_ARM_SHA="fad57a5681cabcef21d322af5aec938975cfb711b5f25d4ce4907e6561616d07"
CODEX_INTEL_URL="https://github.com/openai/codex/releases/download/rust-v0.159.3/codex-package-x86_64-apple-darwin.tar.gz"
CODEX_INTEL_SHA="fe3096a62b5d8395dd25abf9fe79334cf13c1520b825d236cd2b41eb75a63201"
CLAUDE_APP_URL="https://downloads.claude.ai/releases/darwin/universal/2.16120.0/Claude-801c07c2fc988dc8ae50cfadd67d4908a4f5cf37.zip"
CLAUDE_APP_SHA="57c22554696274c78cc2e7c04720d575b36f27a4a2fb4625615c4ae4c8edd880"
CHATGPT_ARM_URL="https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-26.928.31416.zip"
CHATGPT_ARM_SHA="87bd4eb365f9ee1e66afdd91ed961f4e91b220d72a8b8c949769229b91926b22"
CHATGPT_INTEL_URL="https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-x64-26.928.31416.zip"
CHATGPT_INTEL_SHA="f6289bc8c69f9f5c40fec97249d90ff9b6424eb4d14693647dcf639bd03cb1ab"

# 官方下載使用固定版本與 SHA-256；升版時重新核對發行來源。
# 不依賴 Python、Node、jq 或 Homebrew，乾淨 Mac 也能執行。
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/raymond-install.XXXXXX")"
cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

download() { curl --fail --location --retry 2 --connect-timeout 20 --max-time 600 --proto '=https' --proto-redir '=https' -o "$2" "$1"; }
verified_download() {
  download "$1" "$3" || return 1
  local actual
  actual="$(shasum -a 256 "$3")" || return 1
  [[ "${actual%% *}" == "$2" ]] || { warn "下載檔案驗證失敗，請稍後重試。"; return 1; }
}
cli_works() { command -v "$1" >/dev/null 2>&1 && "$1" --version >/dev/null 2>&1; }

app_works() {
  local app="$1" exe minimum
  [[ -d "$app" ]] || return 1
  if [[ "$app" == */ChatGPT.app ]] && (( OS_MAJOR < 14 )); then return 1; fi
  exe="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$app/Contents/Info.plist" 2>/dev/null)" || return 1
  minimum="$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' "$app/Contents/Info.plist" 2>/dev/null)" || return 1
  /usr/bin/awk -v current="$OS_VER" -v minimum="$minimum" 'BEGIN {
    split(current,c,"."); split(minimum,m,".");
    for(i=1;i<=3;i++){if(c[i]+0>m[i]+0)exit 0;if(c[i]+0<m[i]+0)exit 1} exit 0
  }' || return 1
  /usr/bin/lipo -verify_arch "$CPU_ARCH" "$app/Contents/MacOS/$exe" >/dev/null 2>&1 || return 1
  /usr/bin/codesign --verify --deep --strict "$app" >/dev/null 2>&1 || return 1
}

install_official_gh() {
  verified_download "$GH_URL" "$GH_SHA" "$WORK_DIR/gh.pkg" || return 1
  /usr/sbin/pkgutil --check-signature "$WORK_DIR/gh.pkg" || return 1
  sudo /usr/sbin/installer -pkg "$WORK_DIR/gh.pkg" -target / || return 1
  export PATH="/usr/local/bin:$PATH"
  hash -r
}

install_official_codex() {
  local url sha dest
  if [[ "$CPU_ARCH" == arm64 ]]; then url="$CODEX_ARM_URL"; sha="$CODEX_ARM_SHA"
  else url="$CODEX_INTEL_URL"; sha="$CODEX_INTEL_SHA"; fi
  verified_download "$url" "$sha" "$WORK_DIR/codex.tar.gz" || return 1
  mkdir -p "$WORK_DIR/codex" || return 1
  tar -xzf "$WORK_DIR/codex.tar.gz" -C "$WORK_DIR/codex" || return 1
  # 保留整包的執行檔與 runtime，不能只複製 bin/codex。
  "$WORK_DIR/codex/bin/codex" --version >/dev/null 2>&1 || return 1
  dest="$HOME/.local/share/raymond-installer/codex-$CODEX_VERSION-$CPU_ARCH"
  mkdir -p "$HOME/.local/share/raymond-installer" "$HOME/.local/bin" || return 1
  # 不覆蓋其他安裝器或使用者的既有檔案。
  if [[ -e "$HOME/.local/bin/codex" || -L "$HOME/.local/bin/codex" ]]; then
    warn "既有 Codex 無法執行，請先處理原安裝；本次不覆蓋。"; return 1
  fi
  if [[ ! -e "$dest" ]]; then mv "$WORK_DIR/codex" "$dest" || return 1; fi
  "$dest/bin/codex" --version >/dev/null 2>&1 || return 1
  ln -s "$dest/bin/codex" "$HOME/.local/bin/codex" || return 1
  ensure_local_bin
  hash -r
}

install_official_app() {
  local name url sha
  case "$1" in
    claude) name=Claude; url="$CLAUDE_APP_URL"; sha="$CLAUDE_APP_SHA" ;;
    chatgpt)
      name=ChatGPT
      # 官方支援頁要求 macOS 14；不因下載檔能解壓就宣稱相容。
      if (( OS_MAJOR < 14 )); then warn "ChatGPT 桌面版需要 macOS 14 以上；其他工具會繼續安裝。"; return 1; fi
      if [[ "$CPU_ARCH" == arm64 ]]; then url="$CHATGPT_ARM_URL"; sha="$CHATGPT_ARM_SHA"
      else url="$CHATGPT_INTEL_URL"; sha="$CHATGPT_INTEL_SHA"; fi ;;
    *) return 1 ;;
  esac
  if [[ -e "/Applications/$name.app" ]]; then
    warn "既有 $name App 未通過相容性驗證，本次不覆蓋；請依官方下載頁更新。"; return 1
  fi
  verified_download "$url" "$sha" "$WORK_DIR/$name.zip" || return 1
  mkdir -p "$WORK_DIR/$name" || return 1
  /usr/bin/ditto -x -k "$WORK_DIR/$name.zip" "$WORK_DIR/$name" || return 1
  app_works "$WORK_DIR/$name/$name.app" || return 1
  /usr/sbin/spctl --assess --type execute "$WORK_DIR/$name/$name.app" || return 1
  if [[ -w /Applications ]]; then
    /usr/bin/ditto "$WORK_DIR/$name/$name.app" "/Applications/$name.app" || return 1
  else
    sudo /usr/bin/ditto "$WORK_DIR/$name/$name.app" "/Applications/$name.app" || return 1
  fi
  app_works "/Applications/$name.app"
}

# ── 相容性檢查（先分流，不讓舊 Mac 卡死在半路）─────────
OS_VER="$(sw_vers -productVersion)"
OS_MAJOR="${OS_VER%%.*}"
CPU_ARCH="$(uname -m)"
# Rosetta 回報 x86_64，先切回原生程序，避免抓錯架構。
if [[ "$CPU_ARCH" == "x86_64" ]] && [[ "$(sysctl -in sysctl.proc_translated 2>/dev/null || true)" == "1" ]]; then
  cleanup
  exec /usr/bin/arch -arm64 /bin/bash "$0" "$@"
fi
case "$CPU_ARCH" in arm64|x86_64) ;; *) die "暫不支援此處理器：$CPU_ARCH" ;; esac
MODE="legacy"
if [[ "$CPU_ARCH" == "arm64" ]] && (( OS_MAJOR >= 15 )); then
  MODE="full"
elif (( OS_MAJOR >= 13 )); then
  MODE="legacy"
else
  cat <<OLD

${B}════════════════════════════════════════════════════${N}
  你的 macOS 版本是 ${B}${OS_VER}${N}，比終端機版 Claude Code
  支援的最低版本（macOS 13）還舊。與其讓你卡在半路，
  不如一開始就告訴你：這台先不硬裝 🙅

  你有兩條路：

    ${B}A${N} · 查看「Claude 桌面版」官方系統需求
        → 到 claude.com/download 確認相容版本；無法安裝時可先用網頁版
    ${B}B${N} · 把 macOS 升級到 13 以上，再回來雙擊我一次

  🎓 想學怎麼把 AI 練成你的分身？
     完整課程「超級 AI 個體」→ ${AD_URL}

${B}════════════════════════════════════════════════════${N}
OLD
  farewell_close
  exit 0
fi

# ── 開場 ─────────────────────────────────────────────
clear 2>/dev/null || true
cat <<BANNER
${B}════════════════════════════════════════════════════
   🦾  雷蒙的 AI 基礎環境安裝包(MAC)
════════════════════════════════════════════════════${N}

  嗨！我是你的環境安裝小幫手 🤖

  接下來 10～15 分鐘，我會把這台 Mac 從「普通電腦」
  升級成「AI 友善基地」—— 讓 AI 之後能真的動手
  幫你做事，而不是只出一張嘴。

  ${B}必裝地基${N}（我自動處理，你看戲就好）：
    git 時光機 · 軟體安裝工具
    GitHub CLI · GitHub 登入

  全程不用寫程式。中途可能請你「輸入 Mac 密碼」
  或「開瀏覽器登入」—— 都是正常關卡，不是出事 🙂
BANNER

if [[ "$MODE" == "legacy" ]]; then
  printf '\n'
  warn "偵測到 macOS ${OS_VER}：我會自動改走「備用路線」——"
  sub "這台電腦改用官方下載，繼續安裝你勾選的工具，不需要 Homebrew"
fi

# ── 選裝：挑你的路線 ─────────────────────────────────
# 不預設任何一家：互動時一定要自己選，非互動又沒給 --tools 就只裝基礎環境
SEL_CLAUDE=0; SEL_CLAUDE_APP=0; SEL_CODEX=0; SEL_CHATGPT_APP=0

if [[ -z "$TOOLS" ]]; then
  if [[ -t 0 ]]; then
    # 互動多選：↑↓ 移動、空白鍵勾選（可複選）、Enter 確認（bash 3.2 相容）
    m_label=("Claude 桌面版" "Claude 終端機版" "ChatGPT 桌面版" "Codex 終端機版")
    m_chk=(0 0 0 0); m_cur=0; m_first=1

    printf '\n'
    printf '%s━━━ 挑你要裝的 AI 工具 🎒 ━━━━━━━━━━━━━━━━━━━━━━━━━━%s\n' "$B" "$N"
    printf '\n  基礎環境（git、GitHub）一定會裝；軟體管家依電腦自動安排。\n'
    printf '  下面用 %s↑↓%s 移動、%s空白鍵%s 勾選（可複選）、%sEnter%s 確認：\n' "$B" "$N" "$B" "$N" "$B" "$N"

    tput civis 2>/dev/null || true
    _mrestore() { tput cnorm 2>/dev/null || true; }
    trap '_mrestore; cleanup' EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM
    while :; do
      [[ $m_first -eq 0 ]] && printf '\033[7A'
      m_first=0
      printf '\r\033[K\n'
      i=0
      while [[ $i -lt 4 ]]; do
        if [[ ${m_chk[$i]} -eq 1 ]]; then box="[${G}✓${N}]"; else box="[ ]"; fi
        if [[ $m_cur -eq $i ]]; then
          printf '\r\033[K  %s▸%s %s %s%s%s\n' "$B" "$N" "$box" "$B" "${m_label[$i]}" "$N"
        else
          printf '\r\033[K    %s %s\n' "$box" "${m_label[$i]}"
        fi
        i=$((i+1))
      done
      printf '\r\033[K\n'
      printf '\r\033[K  %s都不勾＝只裝基礎環境，AI 工具之後想要，再雙擊我一次就好%s\n' "$D" "$N"

      IFS= read -rsn1 k || k=""
      if [[ $k == $'\033' ]]; then IFS= read -rsn2 -t 1 k2 || k2=""; k="$k$k2"; fi
      case "$k" in
        $'\033[A'|$'\033OA'|k) m_cur=$(( (m_cur+3)%4 )) ;;
        $'\033[B'|$'\033OB'|j) m_cur=$(( (m_cur+1)%4 )) ;;
        ' ') m_chk[$m_cur]=$(( 1 - ${m_chk[$m_cur]} )) ;;
        1) m_chk[0]=$(( 1 - ${m_chk[0]} )) ;;
        2) m_chk[1]=$(( 1 - ${m_chk[1]} )) ;;
        3) m_chk[2]=$(( 1 - ${m_chk[2]} )) ;;
        4) m_chk[3]=$(( 1 - ${m_chk[3]} )) ;;
        '') break ;;
      esac
    done
    _mrestore; trap cleanup EXIT
    printf '\n'
    SEL_CLAUDE_APP=${m_chk[0]}
    SEL_CLAUDE=${m_chk[1]}
    SEL_CHATGPT_APP=${m_chk[2]}
    SEL_CODEX=${m_chk[3]}
  else
    TOOLS="base"
  fi
fi

case "$TOOLS" in
  claude) SEL_CLAUDE=1; SEL_CLAUDE_APP=1 ;;
  codex)  SEL_CODEX=1;  SEL_CHATGPT_APP=1 ;;
  both)   SEL_CLAUDE=1; SEL_CLAUDE_APP=1; SEL_CODEX=1; SEL_CHATGPT_APP=1 ;;
  base)   ;;
esac

export PATH="/usr/local/bin:$PATH"
ensure_local_bin
RS_CODEX="之後可再雙擊我一次重試"

LOADOUT=""
[[ "$SEL_CLAUDE" -eq 1 ]]      && LOADOUT="${LOADOUT}Claude Code、"
[[ "$SEL_CLAUDE_APP" -eq 1 ]]  && LOADOUT="${LOADOUT}Claude 桌面版、"
[[ "$SEL_CODEX" -eq 1 ]]       && LOADOUT="${LOADOUT}Codex CLI、"
[[ "$SEL_CHATGPT_APP" -eq 1 ]] && LOADOUT="${LOADOUT}ChatGPT 桌面版、"
if [[ -n "$LOADOUT" ]]; then
  ok "收到！這趟會裝：基礎環境 ＋ ${LOADOUT%、}"
else
  ok "收到！這趟只裝基礎環境（AI 工具之後想要，再雙擊我一次就好）"
fi
STEP_TOTAL=$((4 + SEL_CLAUDE + SEL_CLAUDE_APP + SEL_CODEX + SEL_CHATGPT_APP))

if [[ -t 0 ]]; then
  printf '\n  %s準備好了就按 Enter，出發 🏁%s（想離開按 Ctrl + C）  ' "$B" "$N"
  read -r _ || true
fi

# ── 第 1 站：git ─────────────────────────────────────
step "git"
ST_GIT="ok"
if command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
  ok "早就裝好了：$(git --version)（這站直接通過 ✨）"
else
  say "git 還沒裝，正在呼叫系統的「命令列工具」…"
  wait_hint "等下會跳出一個系統視窗，請按「安裝」—— 不要按「取得 Xcode」，那是給工程師的大全套，用不到 🙅"
  sub "下載大概 5～10 分鐘（看網速）。裝好我會自動接續，這個視窗開著就好"
  xcode-select --install 2>/dev/null || true
  # 輪詢等 CLT 就緒，裝好自動接續，不用重開 App。
  # 用 xcode-select -p 當條件：它只查註冊狀態，不會像 git --version 那樣再觸發彈窗。
  waited=0
  until xcode-select -p >/dev/null 2>&1; do
    sleep 5
    waited=$((waited+5))
    if (( waited % 60 == 0 )); then
      say "還在等系統把「命令列工具」裝完…（已等 $((waited/60)) 分鐘，裝好會自動接續）"
      sub "按到「取消」或視窗不見了？重新雙擊我一次，安裝視窗就會再跳出來"
    fi
    if (( waited >= 1800 )); then
      die "等了 30 分鐘還沒完成。請確認網路正常，再雙擊我一次重試。"
    fi
  done
  hash -r 2>/dev/null || true
  if command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
    ok "$(git --version)"
  else
    die "「命令列工具」裝好了但 git 還是不能用，請再雙擊我一次重試。"
  fi
fi

# ── 第 2 站：Homebrew ────────────────────────────────
step "Homebrew"
ST_BREW="ok"
if [[ "$MODE" == "legacy" ]]; then
  ST_BREW="skip"
  warn "這台 Mac 使用官方下載路線，跳過 Homebrew，繼續安裝其他工具。"
elif ensure_brew && brew --version >/dev/null 2>&1; then
  ok "Homebrew 已經裝好了（這站直接通過 ✨）"
else
  say "正在安裝 Homebrew（Mac 的軟體管家，之後裝東西都靠它）…"
  wait_hint "大概 3～5 分鐘；若要輸入 Mac 密碼，打字時看不到字是正常的。"
  if download https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh "$WORK_DIR/brew.sh" &&
     /bin/bash "$WORK_DIR/brew.sh" && ensure_brew && brew --version >/dev/null 2>&1; then
    ok "Homebrew 就位"
  else
    MODE="legacy"; ST_BREW="skip"
    warn "Homebrew 這次沒裝成功，改用官方下載繼續，不用重新操作。"
  fi
fi
persist_ai_path

# ── 第 3 站：GitHub CLI ──────────────────────────────
step "GitHub CLI"
ST_GH="ok"
if cli_works gh; then
  ok "GitHub CLI 已經裝好了（這站直接通過 ✨）"
else
  say "正在安裝 GitHub CLI…"
  if [[ "$MODE" == "full" ]]; then brew install gh || true; fi
  if ! cli_works gh; then install_official_gh || true; fi
  if cli_works gh; then
    ok "GitHub CLI 就位"
  else
    ST_GH="fail"
    warn "GitHub CLI 沒裝成功，會繼續安裝其他工具；之後再雙擊我一次重試。"
  fi
fi

# ── 第 4 站：GitHub 登入 ─────────────────────────────
step "GitHub 登入"
if [[ "$WITH_AUTH" -eq 0 ]]; then
  ST_AUTH="skip"
  warn "你選了不登入（--skip-auth），這站跳過。"
elif [[ "$ST_GH" != "ok" ]]; then
  ST_AUTH="fail"
  warn "GitHub CLI 尚未就位，登入留待重跑時完成。"
elif gh auth status >/dev/null 2>&1; then
  ST_AUTH="ok"
  ok "已經登入 GitHub 了（這站直接通過 ✨）"
else
  say "來連結你的 GitHub 帳號 —— 讓 AI 之後能幫你備份、管理做出來的專案 🔑"
  sub "還沒有 GitHub 帳號？可以先按 Ctrl+C 離開，辦好帳號再跑一次"
  wait_hint "等下會開瀏覽器，照畫面選："
  sub "GitHub.com → HTTPS → Login with a web browser"
  sub "再把終端機顯示的 one-time code 貼進瀏覽器"
  gh auth login || true
  if gh auth status >/dev/null 2>&1; then
    ST_AUTH="ok"
    ok "GitHub 登入成功，鑰匙到手 🔑"
  else
    ST_AUTH="fail"
    warn "還沒完成登入 —— 沒關係，之後再打開這個 App 一次就能補登。"
  fi
fi

# ── 選裝站：Claude Code ──────────────────────────────
if [[ "$SEL_CLAUDE" -eq 1 ]]; then
  step "Claude Code"
  ensure_local_bin
  if cli_works claude; then
    ST_CLAUDE="ok"
    ok "早就裝好了：$(claude --version 2>/dev/null || echo 'Claude Code')（這站直接通過 ✨）"
  else
    if [[ "$MODE" == "full" ]]; then
      say "來裝你的 AI Agent 本體…"
      wait_hint "大概 1～3 分鐘，裝好就能在終端機打 claude 跟它對話。"
      brew install --cask claude-code || true
    fi
    if ! cli_works claude; then
      say "用 Anthropic 官方安裝器裝 Claude Code（備用路線）…"
      wait_hint "大概 1～3 分鐘。"
      if download https://claude.ai/install.sh "$WORK_DIR/claude.sh"; then
        /bin/bash "$WORK_DIR/claude.sh" || true
      fi
    fi
    ensure_local_bin
    hash -r 2>/dev/null || true
    if cli_works claude; then
      ST_CLAUDE="ok"
      ok "Claude Code 就位：$(claude --version 2>/dev/null || echo '已安裝')"
    else
      ST_CLAUDE="fail"
      warn "這個視窗還找不到 claude 指令 —— 先重開終端機打 claude 試試；"
      sub "還是沒有的話，就是這次沒裝成功，再雙擊我一次會重試"
    fi
  fi
fi

# ── 選裝站：Claude 桌面版 ────────────────────────────
if [[ "$SEL_CLAUDE_APP" -eq 1 ]]; then
  step "Claude 桌面版"
  if app_works "/Applications/Claude.app"; then
    ST_CLAUDE_APP="ok"
    ok "應用程式裡已經有 Claude 了（這站直接通過 ✨）"
  else
    say "下載 Claude 桌面版 App（圖形介面，拖檔案就能用）…"
    wait_hint "大概 1～3 分鐘。"
    if [[ "$MODE" == "full" ]]; then brew install --cask claude || true; fi
    if ! app_works "/Applications/Claude.app"; then install_official_app claude || true; fi
    if app_works "/Applications/Claude.app"; then
      ST_CLAUDE_APP="ok"
      ok "Claude 桌面版就位，第一次打開時用你的 Claude 帳號登入即可"
    else
      ST_CLAUDE_APP="fail"
      warn "沒抓到安裝結果 —— 可以之後手動到 claude.com/download 下載，不影響其他步驟。"
    fi
  fi
fi

# ── 選裝站：Codex CLI ────────────────────────────────
if [[ "$SEL_CODEX" -eq 1 ]]; then
  step "Codex CLI"
  if cli_works codex; then
    ST_CODEX="ok"
    ok "早就裝好了：$(codex --version 2>/dev/null || echo 'Codex CLI')（這站直接通過 ✨）"
  else
    say "來裝 Codex CLI（用 ChatGPT 帳號跑的 AI Agent）…"
    wait_hint "大概 1～2 分鐘。"
    if [[ "$MODE" == "full" ]]; then brew install --cask codex || true; fi
    if ! cli_works codex; then install_official_codex || true; fi
    hash -r 2>/dev/null || true
    if cli_works codex; then
      ST_CODEX="ok"
      ok "Codex CLI 就位，第一次在終端機打 codex 時會請你登入 ChatGPT 帳號"
    else
      ST_CODEX="fail"
      warn "Codex CLI 沒裝成功 —— 不影響其他步驟，之後可再雙擊我一次重試。"
    fi
  fi
fi

# ── 選裝站：ChatGPT 桌面版 ───────────────────────────
if [[ "$SEL_CHATGPT_APP" -eq 1 ]]; then
  step "ChatGPT 桌面版"
  if app_works "/Applications/ChatGPT.app"; then
    ST_CHATGPT_APP="ok"
    ok "應用程式裡已經有 ChatGPT 了（這站直接通過 ✨）"
  else
    say "下載 ChatGPT 桌面版 App（在裡面就能開 Codex）…"
    wait_hint "大概 1～3 分鐘。"
    if [[ "$MODE" == "full" ]]; then brew install --cask chatgpt || true; fi
    if ! app_works "/Applications/ChatGPT.app"; then install_official_app chatgpt || true; fi
    if app_works "/Applications/ChatGPT.app"; then
      ST_CHATGPT_APP="ok"
      ok "ChatGPT 桌面版就位，第一次打開時登入你的 ChatGPT 帳號即可"
    else
      ST_CHATGPT_APP="fail"
      warn "沒抓到安裝結果 —— 可以之後手動到 chatgpt.com/download 下載，不影響其他步驟。"
    fi
  fi
fi

# ── AI 殼層驗證（模擬 AI 工具跑指令的環境）───────────
# AI 工具執行指令用的是非 login 殼層（zsh -c），只讀 ~/.zshenv、
# 不讀 ~/.zprofile。這裡用乾淨環境實測 AI 到底找不找得到工具，
# 免得工具都裝好了，AI 卻跟學員說「找不到 gh」害人以為裝錯要重做。
AI_TOOLS="git"
[[ "$ST_GH" == "ok" ]] && AI_TOOLS="$AI_TOOLS gh"
[[ "$ST_BREW"   == "ok" ]] && AI_TOOLS="$AI_TOOLS brew"
[[ "$ST_CLAUDE" == "ok" ]] && AI_TOOLS="$AI_TOOLS claude"
[[ "$ST_CODEX"  == "ok" ]] && AI_TOOLS="$AI_TOOLS codex"
AI_MISSING="$(env -i HOME="$HOME" zsh -c '
  for t in '"$AI_TOOLS"'; do
    command -v "$t" >/dev/null 2>&1 || printf "%s " "$t"
  done
' 2>/dev/null || true)"

# ── 完成畫面（只報這趟實際發生的結果）───────────────
HAS_FAIL=0
[[ -n "$AI_MISSING" ]] && HAS_FAIL=1
for s in "$ST_GIT" "$ST_BREW" "$ST_GH" "$ST_AUTH" \
         "$ST_CLAUDE" "$ST_CLAUDE_APP" "$ST_CODEX" "$ST_CHATGPT_APP"; do
  [[ "$s" == "fail" ]] && HAS_FAIL=1
done

if [[ "$HAS_FAIL" -eq 1 ]]; then
  TITLE="🧩  差不多好了 —— 有幾項這次沒成功"
else
  TITLE="🎉  完工！這台 Mac 正式成為「AI 友善基地」"
fi

# 驗貨指令：只列真的裝起來的
VERIFY="git --version"
[[ "$ST_GH" == "ok" ]] && VERIFY="${VERIFY} && gh --version"
[[ "$ST_CLAUDE" == "ok" ]] && VERIFY="${VERIFY} && claude --version"
[[ "$ST_CODEX"  == "ok" ]] && VERIFY="${VERIFY} && codex --version"

printf '\n%s════════════════════════════════════════════════════\n' "$B"
printf '   %s\n' "$TITLE"
printf '════════════════════════════════════════════════════%s\n\n' "$N"
printf '  這趟的實際結果：\n'
result_line "$ST_GIT"          "git"
result_line "$ST_BREW"         "Homebrew"        "備用路線不裝，不影響使用"
result_line "$ST_GH"           "GitHub CLI"       "再雙擊我一次會重試"
result_line "$ST_AUTH"         "GitHub 登入"     "之後再雙擊我一次就能補登"
result_line "$ST_CLAUDE"       "Claude Code"     "再雙擊我一次會重試"
result_line "$ST_CLAUDE_APP"   "Claude 桌面版"   "或手動到 claude.com/download 下載"
result_line "$ST_CODEX"        "Codex CLI"       "$RS_CODEX"
result_line "$ST_CHATGPT_APP"  "ChatGPT 桌面版"  "或手動到 chatgpt.com/download 下載"
if [[ -z "$AI_MISSING" ]]; then
  printf '    %s✓%s AI 殼層驗證（AI 執行指令時，上面的工具它都找得到）\n' "$G" "$N"
else
  printf '    %s!%s AI 殼層驗證%s（AI 可能看不到：%s—— 是 PATH 問題，不是沒裝）%s\n' "$Y" "$N" "$D" "${AI_MISSING}" "$N"
  printf '       %s‧ 打開 AI 工具後，把這句貼給它：%s\n' "$D" "$N"
  printf '       %s‧ 「請檢查 ~/.zshenv 有沒有把 /opt/homebrew/bin 加進 PATH，並檢查 /usr/local/bin 與 ~/.local/bin」%s\n' "$D" "$N"
fi

cat <<DONE

  想自己驗貨的話（可選），複製這行貼上按 Enter：
    ${D}${VERIFY}${N}
DONE

[[ "$ST_AUTH" == "fail" ]] && printf '\n    GitHub 還沒登完 —— 終端機打 %sgh auth login%s 也可以補。\n' "$B" "$N"

cat <<DONE

${B}  ─────────────────────────────────────────────${N}
  🎓 安裝結果請以上方清單為準。

  想知道怎樣養出自己的 AI Agent，把 AI 從工具變成員工！
  馬上報名「超級 AI 個體」線上體驗課 👇

  ${B}→ ${AD_URL}${N}
${B}════════════════════════════════════════════════════${N}
DONE

farewell_close
exit "$HAS_FAIL"
