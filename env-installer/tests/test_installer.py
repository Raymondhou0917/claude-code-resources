"""流程回歸：隔離 HOME、模擬外部安裝，不修改測試機工具或 Applications。"""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SOURCE = Path(__file__).resolve().parents[1] / 'install-mac.sh'
SCRIPT = SOURCE.read_text()
MOCKS = r'''
uname() { if [[ "$1" == -s ]]; then echo Darwin; else echo "$TEST_ARCH"; fi; }
sw_vers() { echo "$TEST_OS"; }
sysctl() { echo 0; }
clear() { :; }
git() { echo 'git version test'; }
brew() {
 echo "brew $*" >> "$HOME/events"
 [[ "$TEST_BREW" == ok ]] || return 1
 if [[ "$1" == install ]]; then
  case "${*: -1}" in
   gh|codex) touch "$HOME/${*: -1}" ;;
   claude-code) touch "$HOME/claude" ;;
   claude) touch "$HOME/Claude.app" ;;
   chatgpt) touch "$HOME/ChatGPT.app" ;;
  esac
 fi
}
ensure_brew() { [[ "$TEST_BREW" == ok ]]; }
cli_works() { [[ -f "$HOME/$1" ]]; }
app_works() { [[ -f "$HOME/${1##*/}" ]]; }
install_official_gh() {
 echo gh >> "$HOME/events"
 [[ "$TEST_GH_FAIL" != 1 ]] || return 1
 touch "$HOME/gh"
}
install_official_codex() { echo codex >> "$HOME/events"; touch "$HOME/codex"; }
install_official_app() {
 echo "$1-app" >> "$HOME/events"
 case "$1" in claude) touch "$HOME/Claude.app";; chatgpt) touch "$HOME/ChatGPT.app";; esac
}
download() {
 echo "download $1" >> "$HOME/events"
 case "$1" in
  *Homebrew*) printf 'exit 1\n' > "$2" ;;
  *claude.ai*) printf 'touch "$HOME/claude"\n' > "$2" ;;
  *) return 1 ;;
 esac
}
env() { [[ "$TEST_PATH_FAIL" != 1 ]] || printf 'gh '; return 0; }
'''

class FlowTests(unittest.TestCase):
    def run_flow(self, arch='x86_64', version='15.0', brew='missing', tools='both', gh_fail='0', path_fail='0', existing=False):
        with tempfile.TemporaryDirectory() as root:
            home = Path(root)
            (home/'events').touch()
            if existing:
                for tool in ['gh','claude','codex','Claude.app','ChatGPT.app']:
                    (home/tool).touch()
            # 注入在函式定義後、主流程前；主流程與選項解析保持原樣。
            script = SCRIPT.replace('[[ "$(uname -s)" == "Darwin" ]]', '[[ "Darwin" == "Darwin" ]]')
            script = script.replace('# ── 相容性檢查', MOCKS+'\n# ── 相容性檢查', 1)
            file = home/'test.sh'; file.write_text(script)
            env = dict(os.environ, HOME=root, TEST_ARCH=arch, TEST_OS=version, TEST_BREW=brew,
                       TEST_GH_FAIL=gh_fail, TEST_PATH_FAIL=path_fail)
            result = subprocess.run(['/bin/bash',str(file),'--skip-auth','--tools='+tools], env=env,
                                    stdin=subprocess.DEVNULL, capture_output=True, text=True)
            return result, (home/'events').read_text()

    def test_intel_full_selection_without_brew(self):
        result, events = self.run_flow()
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertNotIn('Homebrew/install',events)
        self.assertNotIn('brew ',events)
        for item in ['gh','codex','claude-app','chatgpt-app','claude.ai/install.sh']:
            self.assertIn(item,events)
        self.assertIn('第 8 站 / 8',result.stdout)

    def test_intel_existing_brew_does_not_reenable_brew_route(self):
        result, events = self.run_flow(brew='ok')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertNotIn('brew ',events)

    def test_arm_homebrew_failure_falls_back(self):
        result, events = self.run_flow(arch='arm64')
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertIn('Homebrew/install',events)
        self.assertIn('codex',events)

    def test_arm_supported_brew_route(self):
        result, events = self.run_flow(arch='arm64',brew='ok')
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertIn('brew install --cask codex',events)
        self.assertNotIn('claude.ai/install.sh',events)

    def test_arm_14_direct_route(self):
        result, events = self.run_flow(arch='arm64',version='14.7',brew='ok')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertNotIn('brew ',events)

    def test_gh_failure_does_not_stop_other_tools(self):
        result, events = self.run_flow(gh_fail='1')
        self.assertEqual(result.returncode,1,result.stderr)
        self.assertIn('chatgpt-app',events)
        self.assertIn('沒成功',result.stdout)

    def test_path_failure_is_not_success(self):
        result, _ = self.run_flow(path_fail='1')
        self.assertEqual(result.returncode,1,result.stderr)
        self.assertIn('沒成功',result.stdout)

    def test_base_does_not_install_optional_tools(self):
        result, events = self.run_flow(tools='base')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(events,'gh\n')

    def test_rerun_skips_working_tools(self):
        result, events = self.run_flow(existing=True)
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual(events,'')

    def test_checksum_mismatch_rejected(self):
        prefix = SCRIPT.split('# ── 相容性檢查')[0]
        prefix = prefix.replace('[[ "$(uname -s)" == "Darwin" ]]','[[ "Darwin" == "Darwin" ]]')
        with tempfile.TemporaryDirectory() as root:
            code = prefix + '\ndownload() { printf corrupted > "$2"; }\nif verified_download https://example.test 000 "$WORK_DIR/file"; then exit 9; else exit 0; fi\n'
            result = subprocess.run(['/bin/bash','-c',code], env=dict(os.environ,HOME=root),capture_output=True,text=True)
            self.assertEqual(result.returncode,0,result.stderr)
            self.assertIn('驗證失敗',result.stdout)


class DownloadHelperTests(unittest.TestCase):
    def run_helper(self, extra):
        prefix = SCRIPT.split('# ── 相容性檢查')[0]
        prefix = prefix.replace('[[ "$(uname -s)" == "Darwin" ]]','[[ "Darwin" == "Darwin" ]]')
        with tempfile.TemporaryDirectory() as root:
            return subprocess.run(['/bin/bash','-c',prefix+'\n'+extra],
                                  env=dict(os.environ,HOME=root),capture_output=True,text=True)

    def test_codex_preserves_runtime_and_rerun(self):
        result = self.run_helper(r"""
CPU_ARCH=x86_64
verified_download() {
  mkdir -p "$WORK_DIR/fixture/bin" "$WORK_DIR/fixture/lib"
  printf '#!/bin/bash\necho codex-test\n' > "$WORK_DIR/fixture/bin/codex"
  chmod +x "$WORK_DIR/fixture/bin/codex"
  printf runtime > "$WORK_DIR/fixture/lib/companion"
  tar -czf "$3" -C "$WORK_DIR/fixture" .
}
install_official_codex
cli_works codex
[[ -f "$HOME/.local/share/raymond-installer/codex-$CODEX_VERSION-$CPU_ARCH/lib/companion" ]]
[[ -L "$HOME/.local/bin/codex" ]]
""")
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)

    def test_codex_unrunnable_payload_not_installed(self):
        result = self.run_helper(r"""
CPU_ARCH=x86_64
verified_download() {
  mkdir -p "$WORK_DIR/fixture/bin"
  printf '#!/bin/bash\nexit 1\n' > "$WORK_DIR/fixture/bin/codex"
  chmod +x "$WORK_DIR/fixture/bin/codex"
  tar -czf "$3" -C "$WORK_DIR/fixture" .
}
if install_official_codex; then exit 9; fi
[[ ! -e "$HOME/.local/bin/codex" ]]
""")
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)

    def test_chatgpt_13_rejected_before_download(self):
        result = self.run_helper(r"""
OS_MAJOR=13; CPU_ARCH=x86_64
verified_download() { echo unexpected-download; return 99; }
if install_official_app chatgpt; then exit 9; fi
""")
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertIn('macOS 14',result.stdout)
        self.assertNotIn('unexpected-download',result.stdout)

if __name__ == '__main__': unittest.main()

