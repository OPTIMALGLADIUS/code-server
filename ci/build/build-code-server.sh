#!/usr/bin/env bash
set -euo pipefail

# --- MOBILE UI & MAC ADDRESS INJECTIONS ---

# 1. MAC Address Fix: Overwrite the crashing network function with a synchronous dummy string
echo "export function getMac(): string { return '00:00:00:00:00:00'; }" > lib/vscode/src/vs/base/node/macAddress.ts

# 2. Viewport Lock & Auto-Collapse Sidebar: Inject directly into the core workbench template
cat << 'EOF' >> lib/vscode/src/vs/code/browser/workbench/workbench.html
<style>
  html, body, .monaco-workbench {
    position: fixed !important; top: 0 !important; bottom: 0 !important;
    left: 0 !important; right: 0 !important; width: 100vw !important;
    height: 100dvh !important; overflow: hidden !important;
  }
  .editor-instance, .monaco-scrollable-element {
    touch-action: pan-x pan-y !important;
  }
</style>
<script>
  window.addEventListener('load', () => {
    document.body.addEventListener('touchstart', (e) => {
      const editorPart = e.target.closest('.part.editor');
      if (editorPart) {
        const sidebar = document.querySelector('.part.sidebar');
        if (sidebar && sidebar.offsetWidth > 0) {
          document.dispatchEvent(new KeyboardEvent('keydown', {
            key: 'b', code: 'KeyB', ctrlKey: true, bubbles: true
          }));
        }
      }
    }, { passive: true });
  });
</script>
EOF

# ------------------------------------------

main() {
  cd "$(dirname "${0}")/../.."

  tsc

  # If out/node/entry.js does not already have the shebang,
  # we make sure to add it and make it executable.
  if ! grep -q -m1 "^#!/usr/bin/env node" out/node/entry.js; then
    sed -i.bak "1s;^;#!/usr/bin/env node\n;" out/node/entry.js && rm out/node/entry.js.bak
    chmod +x out/node/entry.js
  fi
}

main "$@"
