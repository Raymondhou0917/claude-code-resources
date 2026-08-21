#!/usr/bin/env bash
# ════════════════════════════════════════════════════
#  雷蒙的 AI 基礎環境安裝包(MAC) ── 開源版
#  給所有想讓 AI 上工的人：雙擊一次，環境全部就位。
#
#  必裝：git → Homebrew → GitHub CLI → GitHub 登入
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
#    macOS 14+        → 完整路線（Homebrew）
#    macOS 13         → 備用路線（官方安裝器，不走 Homebrew）
#    macOS 12 以下    → 停止，導向 Claude 桌面版（macOS 11+ 可用）
set -euo pipefail

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
    git 時光機 · Homebrew 軟體管家
    GitHub CLI · GitHub 登入

  全程不用寫程式。中途可能請你「輸入 Mac 密碼」
  或「開瀏覽器登入」—— 都是正常關卡，不是出事 🙂
BANNER

if [[ "$MODE" == "legacy" ]]; then
  printf '\n'
  warn "偵測到 macOS ${OS_VER}：我會自動改走「備用路線」——"
  sub "跳過 Homebrew（它已不再完整支援 macOS 13，硬裝很容易失敗）"
  sub "GitHub CLI 與 Claude Code 改用官方安裝器，結果一樣"
  sub "桌面版 App 這條路線不代裝，結尾會給你官方下載連結"
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
    printf '\n  基礎環境（git、Homebrew、GitHub）一定會裝。\n'
    printf '  下面用 %s↑↓%s 移動、%s空白鍵%s 勾選（可複選）、%sEnter%s 確認：\n' "$B" "$N" "$B" "$N" "$B" "$N"

    tput civis 2>/dev/null || true
    _mrestore() { tput cnorm 2>/dev/null || true; }
    trap '_mrestore' EXIT INT TERM
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
    _mrestore; trap - EXIT INT TERM
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

# 備用路線（macOS 13）：桌面版 App 與 Codex CLI 都靠 Homebrew，這裡不代裝，
# 改成結尾給官方下載連結。Claude Code 有官方安裝器，仍然可以裝。
RS_CODEX="之後可再雙擊我一次重試"
if [[ "$MODE" == "legacy" ]]; then
  if [[ "$SEL_CLAUDE_APP" -eq 1 ]]; then SEL_CLAUDE_APP=0; ST_CLAUDE_APP="skip"; fi
  if [[ "$SEL_CHATGPT_APP" -eq 1 ]]; then SEL_CHATGPT_APP=0; ST_CHATGPT_APP="skip"; fi
  if [[ "$SEL_CODEX" -eq 1 ]]; then
    SEL_CODEX=0; ST_CODEX="skip"; RS_CODEX="macOS ${OS_VER} 不支援，結尾有替代做法"
    warn "備用路線裝不了 Codex CLI（它靠 Homebrew）——桌面版 App 也改成結尾給你官方連結。"
  fi
fi

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
  if ensure_brew; then
    ok "你本來就有 Homebrew：$(brew --version | head -1)，太好了，直接請它上工"
    MODE="full"
  else
    ST_BREW="skip"
    warn "macOS ${OS_VER} 跳過 Homebrew（備用路線），下一站直接裝 GitHub CLI。"
  fi
elif ensure_brew; then
  ok "早就裝好了：$(brew --version | head -1)（這站直接通過 ✨）"
else
  say "正在安裝 Homebrew（Mac 的軟體管家，之後裝東西都靠它）…"
  wait_hint "全程最花時間的一站，大概 3～5 分鐘。去倒杯水，回來剛剛好 ☕"
  sub "畫面卡著不動 = 正在下載，不是當機"
  sub "若要你輸入 Mac 密碼：打字時看不到字是正常的，打完按 Enter"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ensure_brew || die "Homebrew 裝好了但找不到 brew，請依畫面把 PATH 加好後再跑一次。"
  ok "$(brew --version | head -1)"
fi
persist_ai_path

# ── 第 3 站：GitHub CLI ──────────────────────────────
step "GitHub CLI"
ST_GH="ok"
if command -v gh >/dev/null 2>&1; then
  ok "早就裝好了：$(gh --version | head -1)（這站直接通過 ✨）"
elif [[ "$MODE" == "full" ]]; then
  say "請管家順手裝一下 gh…"
  wait_hint "大概 1～2 分鐘。"
  brew install gh
  command -v gh >/dev/null 2>&1 || die "gh 安裝失敗，請再跑一次本程式。"
  ok "$(gh --version | head -1)"
else
  say "正在下載 GitHub 官方安裝包（備用路線）…"
  wait_hint "大概 1～2 分鐘。裝的時候會請你輸入 Mac 密碼。"
  GH_PKG_URL="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
    | grep -o 'https://[^"]*macOS_universal\.pkg' | head -1)"
  [[ -n "$GH_PKG_URL" ]] || die "抓不到 gh 安裝包網址，請檢查網路後再跑一次。"
  GH_PKG="$(mktemp -d)/gh.pkg"
  curl -fsSL -o "$GH_PKG" "$GH_PKG_URL"
  sudo installer -pkg "$GH_PKG" -target /
  command -v gh >/dev/null 2>&1 || die "gh 安裝失敗，請再跑一次本程式。"
  ok "$(gh --version | head -1)"
fi

# ── 第 4 站：GitHub 登入 ─────────────────────────────
step "GitHub 登入"
if [[ "$WITH_AUTH" -eq 0 ]]; then
  ST_AUTH="skip"
  warn "你選了不登入（--skip-auth），這站跳過。"
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
  if command -v claude >/dev/null 2>&1; then
    ST_CLAUDE="ok"
    ok "早就裝好了：$(claude --version 2>/dev/null || echo 'Claude Code')（這站直接通過 ✨）"
  else
    if [[ "$MODE" == "full" ]]; then
      say "來裝你的 AI Agent 本體…"
      wait_hint "大概 1～3 分鐘，裝好就能在終端機打 claude 跟它對話。"
      brew install --cask claude-code || true
    else
      say "用 Anthropic 官方安裝器裝 Claude Code（備用路線）…"
      wait_hint "大概 1～3 分鐘。"
      curl -fsSL https://claude.ai/install.sh | bash || true
    fi
    ensure_local_bin
    hash -r 2>/dev/null || true
    if command -v claude >/dev/null 2>&1; then
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
  if [[ -d "/Applications/Claude.app" ]]; then
    ST_CLAUDE_APP="ok"
    ok "應用程式裡已經有 Claude 了（這站直接通過 ✨）"
  else
    say "下載 Claude 桌面版 App（圖形介面，拖檔案就能用）…"
    wait_hint "大概 1～3 分鐘。"
    brew install --cask claude || true
    if [[ -d "/Applications/Claude.app" ]]; then
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
  if command -v codex >/dev/null 2>&1; then
    ST_CODEX="ok"
    ok "早就裝好了：$(codex --version 2>/dev/null || echo 'Codex CLI')（這站直接通過 ✨）"
  else
    say "來裝 Codex CLI（用 ChatGPT 帳號跑的 AI Agent）…"
    wait_hint "大概 1～2 分鐘。"
    brew install codex || true
    hash -r 2>/dev/null || true
    if command -v codex >/dev/null 2>&1; then
      ST_CODEX="ok"
      ok "Codex CLI 就位，第一次在終端機打 codex 時會請你登入 ChatGPT 帳號"
    else
      ST_CODEX="fail"
      warn "Codex CLI 沒裝成功 —— 不影響其他步驟，之後可再跑一次或手動 brew install codex。"
    fi
  fi
fi

# ── 選裝站：ChatGPT 桌面版 ───────────────────────────
if [[ "$SEL_CHATGPT_APP" -eq 1 ]]; then
  step "ChatGPT 桌面版"
  if [[ -d "/Applications/ChatGPT.app" ]]; then
    ST_CHATGPT_APP="ok"
    ok "應用程式裡已經有 ChatGPT 了（這站直接通過 ✨）"
  else
    say "下載 ChatGPT 桌面版 App（在裡面就能開 Codex）…"
    wait_hint "大概 1～3 分鐘。"
    brew install --cask chatgpt || true
    if [[ -d "/Applications/ChatGPT.app" ]]; then
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
AI_TOOLS="git gh"
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
VERIFY="git --version && gh --version"
[[ "$ST_CLAUDE" == "ok" ]] && VERIFY="${VERIFY} && claude --version"
[[ "$ST_CODEX"  == "ok" ]] && VERIFY="${VERIFY} && codex --version"

printf '\n%s════════════════════════════════════════════════════\n' "$B"
printf '   %s\n' "$TITLE"
printf '════════════════════════════════════════════════════%s\n\n' "$N"
printf '  這趟的實際結果：\n'
result_line "$ST_GIT"          "git"
result_line "$ST_BREW"         "Homebrew"        "備用路線不裝，不影響使用"
result_line "$ST_GH"           "GitHub CLI"
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
  printf '       %s‧ 「請檢查 ~/.zshenv 有沒有把 /opt/homebrew/bin 加進 PATH，我的工具裝在那裡」%s\n' "$D" "$N"
fi

cat <<DONE

  想自己驗貨的話（可選），複製這行貼上按 Enter：
    ${D}${VERIFY}${N}
DONE

[[ "$ST_AUTH" == "fail" ]] && printf '\n    GitHub 還沒登完 —— 終端機打 %sgh auth login%s 也可以補。\n' "$B" "$N"

cat <<DONE

${B}  ─────────────────────────────────────────────${N}
  🎓 現在你的 Mac 已經完成基本的 AI 環境安裝！

  想知道怎樣養出自己的 AI Agent，把 AI 從工具變成員工！
  馬上報名「超級 AI 個體」線上體驗課 👇

  ${B}→ ${AD_URL}${N}
${B}════════════════════════════════════════════════════${N}
DONE

if [[ "$MODE" == "legacy" ]]; then
  printf '\n'
  say "備用路線不代裝 App，這幾個自己點官方連結下載就好："
  [[ "$ST_CLAUDE_APP" == "skip" ]]  && sub "Claude 桌面版：claude.com/download"
  [[ "$ST_CHATGPT_APP" == "skip" ]] && sub "ChatGPT 桌面版：chatgpt.com/download"
  [[ "$ST_CODEX" == "skip" ]]       && sub "Codex：先裝 ChatGPT 桌面版，裡面就能開 Codex"
fi

farewell_close
