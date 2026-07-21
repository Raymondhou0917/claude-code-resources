#!/usr/bin/env bash
# ════════════════════════════════════════════════════
#  超級 AI 個體 · AI 環境安裝（Mac）── 開源版
#  給所有想讓 AI 上工的人：雙擊一次，環境全部就位。
#
#  必裝：git → Homebrew → GitHub CLI → GitHub 登入
#  路線：Claude／ChatGPT·Codex／兩套都裝／只裝基礎
#  可重跑，已裝好的會自動 skip。
# ════════════════════════════════════════════════════
#  用法：
#    ./install-mac.sh                 # 互動安裝（開場選路線）
#    ./install-mac.sh --skip-auth     # 不登入 GitHub
#  非互動執行（例如交給 AI Agent 跑）時，預設只裝基礎環境。
#
#  相容性分流：
#    macOS 14+        → 完整路線（Homebrew）
#    macOS 13         → 備用路線（官方安裝器，不走 Homebrew）
#    macOS 12 以下    → 停止，導向 Claude 桌面版（macOS 11+ 可用）
#
#  開源正本：https://github.com/Raymondhou0917/claude-code-resources
set -euo pipefail

AD_URL="https://shifu.tw/course/trial/aibootcamp"

WITH_AUTH=1
for arg in "$@"; do
  case "$arg" in
    --skip-auth) WITH_AUTH=0 ;;
    -h|--help)
      echo "用法: ./install-mac.sh [--skip-auth]"
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

# 實際結果（完成畫面只依此顯示，不依「有沒有勾選」虛報）
STATUS_GIT="skip"
STATUS_BREW="skip"
STATUS_GH="skip"
STATUS_GH_AUTH="skip"
STATUS_CLAUDE="skip"
STATUS_CLAUDE_APP="skip"
STATUS_CODEX="skip"
STATUS_CHATGPT_APP="skip"

mark() {
  # mark VAR ok|fail|skip|partial
  local var="$1" val="$2"
  printf -v "$var" '%s' "$val"
}

status_line() {
  local label="$1" st="$2"
  case "$st" in
    ok)      printf '    %s✓%s %s\n' "$G" "$N" "$label" ;;
    partial) printf '    %s!%s %s（已安裝，登入／指令稍後補）\n' "$Y" "$N" "$label" ;;
    fail)    printf '    %s✗%s %s（這次沒完成，之後再跑一次可補）\n' "$R" "$N" "$label" ;;
    skip)    ;;
    *)       printf '    %s·%s %s\n' "$D" "$N" "$label" ;;
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

# ── 相容性檢查（先分流，不讓舊 Mac 卡死在半路）─────────
OS_VER="$(sw_vers -productVersion)"
OS_MAJOR="${OS_VER%%.*}"
MODE="full"
if (( OS_MAJOR >= 14 )); then
  MODE="full"
elif (( OS_MAJOR == 13 )); then
  MODE="legacy"
else
  cat <<OLD

${B}════════════════════════════════════════════════════${N}
  你的 macOS 版本是 ${B}${OS_VER}${N}，比終端機版 Claude Code
  支援的最低版本（macOS 13）還舊。與其讓你卡在半路，
  不如一開始就告訴你：這台先不硬裝 🙅

  你有兩條路：

    ${B}A${N} · 改用「Claude 桌面版」（支援 macOS 11 以上）
        → 到 claude.com/download 下載，一樣能開始用 AI
    ${B}B${N} · 把 macOS 升級到 14 以上，再回來雙擊我一次

${B}════════════════════════════════════════════════════${N}
OLD
  farewell_close
  exit 0
fi

# ── 開場 ─────────────────────────────────────────────
clear 2>/dev/null || true
cat <<BANNER
${B}════════════════════════════════════════════════════
   🦾  超級 AI 個體 · AI 環境安裝
════════════════════════════════════════════════════${N}

  嗨！我是你的環境安裝小幫手 🤖

  接下來 10～15 分鐘，我會把這台 Mac 從「普通電腦」
  升級成「AI 友善基地」—— 讓 AI 之後能真的動手
  幫你做事，而不是只出一張嘴。

  ${B}必裝地基${N}（我自動處理，你看戲就好）：
    git 時光機 · Homebrew 軟體管家
    GitHub CLI · GitHub 登入

  全程不用寫程式。中途可能請你「輸入 Mac 密碼」
  或「開瀏覽器登入」—— 都是正常關卡，不是出事 🙂

  ${D}本安裝包由「超級 AI 個體」課程開源出品${N}
BANNER

if [[ "$MODE" == "legacy" ]]; then
  printf '\n'
  warn "偵測到 macOS ${OS_VER}：我會自動改走「備用路線」——"
  sub "跳過 Homebrew（它已不再完整支援 macOS 13，硬裝很容易失敗）"
  sub "GitHub CLI 與 Claude Code 改用官方安裝器，結果一樣"
  sub "桌面版 App 這條路線不代裝，結尾會給你官方下載連結"
fi

# ── 選路線（對齊課程 1-2：不要預設所有人都裝 Claude）──
SEL_CLAUDE=0; SEL_CLAUDE_APP=0; SEL_CODEX=0; SEL_CHATGPT_APP=0
ROUTE="base"

pick_route() {
  local choice="$1"
  case "$choice" in
    1)
      ROUTE="claude"
      SEL_CLAUDE=1; SEL_CLAUDE_APP=1
      SEL_CODEX=0; SEL_CHATGPT_APP=0
      ;;
    2)
      ROUTE="codex"
      SEL_CLAUDE=0; SEL_CLAUDE_APP=0
      SEL_CODEX=1; SEL_CHATGPT_APP=1
      ;;
    3)
      ROUTE="both"
      SEL_CLAUDE=1; SEL_CLAUDE_APP=1
      SEL_CODEX=1; SEL_CHATGPT_APP=1
      ;;
    4|"")
      ROUTE="base"
      SEL_CLAUDE=0; SEL_CLAUDE_APP=0
      SEL_CODEX=0; SEL_CHATGPT_APP=0
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}

if [[ "$MODE" == "legacy" ]]; then
  # 備用路線：桌面版不代裝；互動時仍可選終端機路線
  if [[ -t 0 ]]; then
    cat <<MENU

${B}━━━ 選你的安裝路線 🎒 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}

  （macOS 13 備用路線：桌面版 App 請之後自行下載）

    ${B}[1]${N} Claude 路線     ${D}→ 只裝 Claude Code 終端機版${N}
    ${B}[2]${N} ChatGPT／Codex  ${D}→ 只裝 Codex CLI${N}
    ${B}[3]${N} 兩套都裝         ${D}→ Claude Code ＋ Codex CLI${N}
    ${B}[4]${N} 只裝基礎環境     ${D}→ git／gh／GitHub 登入${N}

  輸入 ${B}1${N}／${B}2${N}／${B}3${N}／${B}4${N} 後按 Enter（直接 Enter＝只裝基礎）
MENU
    printf '\n  你的選擇：'
    read -r PICK || PICK=""
    PICK="${PICK// /}"
    if ! pick_route "$PICK"; then
      warn "看不懂「${PICK}」，這趟先只裝基礎環境。"
      pick_route 4
    fi
    # legacy：關掉桌面版代裝
    SEL_CLAUDE_APP=0
    SEL_CHATGPT_APP=0
  else
    pick_route 4
  fi
elif [[ -t 0 ]]; then
  cat <<MENU

${B}━━━ 選你的安裝路線 🎒 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}

  請選一條（對齊課程 1-2 教學路線，沒有預設「大家都裝 Claude」）：

    ${B}[1]${N} Claude 路線
        ${D}Claude Code 終端機版 ＋ Claude 桌面版 App${N}
    ${B}[2]${N} ChatGPT／Codex 路線
        ${D}Codex CLI ＋ ChatGPT 桌面版 App${N}
    ${B}[3]${N} 兩套都裝
        ${D}上面兩條一次到位（雙棲）${N}
    ${B}[4]${N} 只裝基礎環境
        ${D}git／Homebrew／GitHub CLI／登入；Agent 之後再補${N}

  輸入 ${B}1${N}／${B}2${N}／${B}3${N}／${B}4${N} 後按 Enter（直接 Enter＝只裝基礎）
MENU
  printf '\n  你的選擇：'
  read -r PICK || PICK=""
  PICK="${PICK// /}"
  if ! pick_route "$PICK"; then
    warn "看不懂「${PICK}」，這趟先只裝基礎環境。"
    pick_route 4
  fi
else
  # 非互動：不預設幫人裝 Claude／Codex
  pick_route 4
fi

case "$ROUTE" in
  claude) ok "收到！這趟：必裝地基 ＋ Claude 路線" ;;
  codex)  ok "收到！這趟：必裝地基 ＋ ChatGPT／Codex 路線" ;;
  both)   ok "收到！這趟：必裝地基 ＋ Claude 與 Codex 兩套都裝" ;;
  *)      ok "收到！這趟只裝必裝地基（之後想補路線，再雙擊一次就好）" ;;
esac

STEP_TOTAL=$((4 + SEL_CLAUDE + SEL_CLAUDE_APP + SEL_CODEX + SEL_CHATGPT_APP))

if [[ -t 0 ]]; then
  printf '\n  %s準備好了就按 Enter，出發 🏁%s（想離開按 Ctrl + C）  ' "$B" "$N"
  read -r _ || true
fi

# ── 第 1 站：git ─────────────────────────────────────
step "git ── AI 的時光機"
if command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
  ok "早就裝好了：$(git --version)（這站直接通過 ✨）"
  mark STATUS_GIT ok
else
  say "git 還沒裝，正在呼叫系統的「命令列工具」…"
  wait_hint "會跳出一個系統安裝視窗，請按「安裝」，可能要幾分鐘。"
  sub "裝好後，請「再打開一次這個 App」，我會從這站接續"
  xcode-select --install 2>/dev/null || true
  if command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1; then
    ok "$(git --version)"
    mark STATUS_GIT ok
  else
    mark STATUS_GIT fail
    die "git 還沒就緒。裝完「命令列工具」後，再打開一次這個 App 就會接續。"
  fi
fi

# ── 第 2 站：Homebrew ────────────────────────────────
step "Homebrew ── 請軟體管家上工"
if [[ "$MODE" == "legacy" ]]; then
  if ensure_brew; then
    ok "你本來就有 Homebrew：$(brew --version | head -1)，太好了，直接請它上工"
    MODE="full"
    mark STATUS_BREW ok
  else
    warn "macOS ${OS_VER} 跳過 Homebrew（備用路線），下一站直接裝 GitHub CLI。"
    mark STATUS_BREW skip
  fi
elif ensure_brew; then
  ok "早就裝好了：$(brew --version | head -1)（這站直接通過 ✨）"
  mark STATUS_BREW ok
else
  say "正在安裝 Homebrew（Mac 的軟體管家，之後裝東西都靠它）…"
  wait_hint "全程最花時間的一站，大概 3～5 分鐘。去倒杯水，回來剛剛好 ☕"
  sub "畫面卡著不動 = 正在下載，不是當機"
  sub "若要你輸入 Mac 密碼：打字時看不到字是正常的，打完按 Enter"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if ensure_brew; then
    # Apple Silicon：把 brew 寫進 PATH（沒寫過才加）
    if [[ "$(uname -m)" == "arm64" && -x /opt/homebrew/bin/brew ]]; then
      if ! grep -q 'brew shellenv' "${HOME}/.zprofile" 2>/dev/null; then
        {
          echo ''
          echo '# Homebrew (超級 AI 個體 install-mac.sh)'
          echo 'eval "$(/opt/homebrew/bin/brew shellenv)"'
        } >> "${HOME}/.zprofile"
      fi
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    ok "$(brew --version | head -1)"
    mark STATUS_BREW ok
  else
    mark STATUS_BREW fail
    die "Homebrew 裝好了但找不到 brew，請依畫面把 PATH 加好後再跑一次。"
  fi
fi

# ── 第 3 站：GitHub CLI ──────────────────────────────
step "GitHub CLI ── 跟 GitHub 搭上線"
if command -v gh >/dev/null 2>&1; then
  ok "早就裝好了：$(gh --version | head -1)（這站直接通過 ✨）"
  mark STATUS_GH ok
elif [[ "$MODE" == "full" ]]; then
  say "請管家順手裝一下 gh…"
  wait_hint "大概 1～2 分鐘。"
  brew install gh
  if command -v gh >/dev/null 2>&1; then
    ok "$(gh --version | head -1)"
    mark STATUS_GH ok
  else
    mark STATUS_GH fail
    die "gh 安裝失敗，請再跑一次本程式。"
  fi
else
  say "正在下載 GitHub 官方安裝包（備用路線）…"
  wait_hint "大概 1～2 分鐘。裝的時候會請你輸入 Mac 密碼。"
  GH_PKG_URL="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
    | grep -o 'https://[^"]*macOS_universal\.pkg' | head -1)"
  [[ -n "$GH_PKG_URL" ]] || { mark STATUS_GH fail; die "抓不到 gh 安裝包網址，請檢查網路後再跑一次。"; }
  GH_PKG="$(mktemp -d)/gh.pkg"
  curl -fsSL -o "$GH_PKG" "$GH_PKG_URL"
  sudo installer -pkg "$GH_PKG" -target /
  if command -v gh >/dev/null 2>&1; then
    ok "$(gh --version | head -1)"
    mark STATUS_GH ok
  else
    mark STATUS_GH fail
    die "gh 安裝失敗，請再跑一次本程式。"
  fi
fi

# ── 第 4 站：GitHub 登入 ─────────────────────────────
step "GitHub 登入 ── 拿到你的鑰匙"
if [[ "$WITH_AUTH" -eq 0 ]]; then
  warn "你選了不登入（--skip-auth），這站跳過。"
  mark STATUS_GH_AUTH skip
elif gh auth status >/dev/null 2>&1; then
  ok "已經登入 GitHub 了（這站直接通過 ✨）"
  mark STATUS_GH_AUTH ok
else
  say "來連結你的 GitHub 帳號 —— 讓 AI 之後能幫你備份、管理做出來的專案 🔑"
  sub "還沒有 GitHub 帳號？可以先按 Ctrl+C 離開，辦好帳號再跑一次"
  wait_hint "等下會開瀏覽器，照畫面選："
  sub "GitHub.com → HTTPS → Login with a web browser"
  sub "再把終端機顯示的 one-time code 貼進瀏覽器"
  gh auth login || true
  if gh auth status >/dev/null 2>&1; then
    ok "GitHub 登入成功，鑰匙到手 🔑"
    mark STATUS_GH_AUTH ok
  else
    warn "還沒完成登入 —— 沒關係，之後再打開這個 App 一次就能補登。"
    mark STATUS_GH_AUTH fail
  fi
fi

# ── 選裝站：Claude Code ──────────────────────────────
if [[ "$SEL_CLAUDE" -eq 1 ]]; then
  step "Claude Code ── 主角進場"
  ensure_local_bin
  if command -v claude >/dev/null 2>&1; then
    ok "早就裝好了：$(claude --version 2>/dev/null || echo 'Claude Code')（這站直接通過 ✨）"
    mark STATUS_CLAUDE ok
  elif [[ "$MODE" == "full" ]]; then
    say "來裝你的 AI Agent 本體…"
    wait_hint "大概 1～3 分鐘，裝好就能在終端機打 claude 跟它對話。"
    brew install --cask claude-code
    hash -r 2>/dev/null || true
    if command -v claude >/dev/null 2>&1; then
      ok "Claude Code 就位：$(claude --version 2>/dev/null || echo '已安裝')"
      mark STATUS_CLAUDE ok
    else
      warn "Claude Code 可能已安裝，但這個視窗還找不到指令 —— 重開終端機後打 claude 即可。"
      mark STATUS_CLAUDE partial
    fi
  else
    say "用 Anthropic 官方安裝器裝 Claude Code（備用路線）…"
    wait_hint "大概 1～3 分鐘。"
    curl -fsSL https://claude.ai/install.sh | bash
    ensure_local_bin
    hash -r 2>/dev/null || true
    if command -v claude >/dev/null 2>&1; then
      ok "Claude Code 就位：$(claude --version 2>/dev/null || echo '已安裝')"
      mark STATUS_CLAUDE ok
    else
      warn "Claude Code 可能已安裝，但這個視窗還找不到指令 —— 重開終端機後打 claude 即可。"
      mark STATUS_CLAUDE partial
    fi
  fi
fi

# ── 選裝站：Claude 桌面版 ────────────────────────────
if [[ "$SEL_CLAUDE_APP" -eq 1 ]]; then
  step "Claude 桌面版 ── 給 AI 一張臉"
  if [[ -d "/Applications/Claude.app" ]]; then
    ok "應用程式裡已經有 Claude 了（這站直接通過 ✨）"
    mark STATUS_CLAUDE_APP ok
  else
    say "下載 Claude 桌面版 App（圖形介面，拖檔案就能用）…"
    wait_hint "大概 1～3 分鐘。"
    brew install --cask claude
    if [[ -d "/Applications/Claude.app" ]]; then
      ok "Claude 桌面版就位，第一次打開時用你的 Claude 帳號登入即可"
      mark STATUS_CLAUDE_APP ok
    else
      warn "沒抓到安裝結果 —— 可以之後手動到 claude.com/download 下載，不影響其他步驟。"
      mark STATUS_CLAUDE_APP fail
    fi
  fi
fi

# ── 選裝站：Codex CLI ────────────────────────────────
if [[ "$SEL_CODEX" -eq 1 ]]; then
  step "Codex CLI ── 第二位隊友報到"
  if command -v codex >/dev/null 2>&1; then
    ok "早就裝好了：$(codex --version 2>/dev/null || echo 'Codex CLI')（這站直接通過 ✨）"
    mark STATUS_CODEX ok
  else
    say "來裝 Codex CLI（用 ChatGPT 帳號跑的 AI Agent）…"
    wait_hint "大概 1～2 分鐘。"
    brew install codex
    hash -r 2>/dev/null || true
    if command -v codex >/dev/null 2>&1; then
      ok "Codex CLI 就位，第一次在終端機打 codex 時會請你登入 ChatGPT 帳號"
      mark STATUS_CODEX ok
    else
      warn "Codex CLI 沒裝成功 —— 不影響其他步驟，之後可再跑一次或手動 brew install codex。"
      mark STATUS_CODEX fail
    fi
  fi
fi

# ── 選裝站：ChatGPT 桌面版 ───────────────────────────
if [[ "$SEL_CHATGPT_APP" -eq 1 ]]; then
  step "ChatGPT 桌面版"
  if [[ -d "/Applications/ChatGPT.app" ]]; then
    ok "應用程式裡已經有 ChatGPT 了（這站直接通過 ✨）"
    mark STATUS_CHATGPT_APP ok
  else
    say "下載 ChatGPT 桌面版 App（在裡面就能開 Codex）…"
    wait_hint "大概 1～3 分鐘。"
    brew install --cask chatgpt
    if [[ -d "/Applications/ChatGPT.app" ]]; then
      ok "ChatGPT 桌面版就位，第一次打開時登入你的 ChatGPT 帳號即可"
      mark STATUS_CHATGPT_APP ok
    else
      warn "沒抓到安裝結果 —— 可以之後手動到 chatgpt.com/download 下載，不影響其他步驟。"
      mark STATUS_CHATGPT_APP fail
    fi
  fi
fi

# ── 完成畫面（依實際結果）─────────────────────────────
NEXT_HINT="在終端機打指令開始跟 AI 對話（見下方建議）。"
if [[ "$STATUS_CLAUDE" == "ok" || "$STATUS_CLAUDE" == "partial" ]]; then
  NEXT_HINT="在終端機打  ${B}claude${N}  就能開始跟你的 AI 對話。"
elif [[ "$STATUS_CODEX" == "ok" ]]; then
  NEXT_HINT="在終端機打  ${B}codex${N}  就能開始跟你的 AI 對話。"
elif [[ "$STATUS_CLAUDE_APP" == "ok" ]]; then
  NEXT_HINT="打開「Claude」App，用你的 Claude 帳號登入後開始用。"
elif [[ "$STATUS_CHATGPT_APP" == "ok" ]]; then
  NEXT_HINT="打開「ChatGPT」App，登入後切到 Codex 或 Work 模式。"
elif [[ "$ROUTE" == "base" ]]; then
  NEXT_HINT="基礎環境好了。想裝 Claude 或 Codex，再雙擊一次安裝包、選路線 1／2／3。"
fi

cat <<DONE

${B}════════════════════════════════════════════════════
   🎉  這趟安裝跑完了
════════════════════════════════════════════════════${N}

  實際結果（只顯示這次有處理到的項目）：
DONE

status_line "git" "$STATUS_GIT"
status_line "Homebrew" "$STATUS_BREW"
status_line "GitHub CLI" "$STATUS_GH"
status_line "GitHub 登入" "$STATUS_GH_AUTH"
status_line "Claude Code" "$STATUS_CLAUDE"
status_line "Claude 桌面版" "$STATUS_CLAUDE_APP"
status_line "Codex CLI" "$STATUS_CODEX"
status_line "ChatGPT 桌面版" "$STATUS_CHATGPT_APP"

cat <<DONE2

  下一步 ▸
    ${NEXT_HINT}

${B}  ─────────────────────────────────────────────${N}
  🎓 環境好了，然後呢？

  這個安裝包是${B}「超級 AI 個體」${N}課程的第 0 步。
  完整課程教你把 AI 練成你的分身 ——
  用中文指揮它處理工作、實現想法，不用會寫程式。

  ${B}→ ${AD_URL}${N}
${B}════════════════════════════════════════════════════${N}
DONE2

if [[ "$MODE" == "legacy" ]]; then
  say "桌面版 App 想要的話，自己點這兩個官方連結下載："
  sub "Claude 桌面版：claude.com/download"
  sub "ChatGPT 桌面版：chatgpt.com/download"
fi

farewell_close
