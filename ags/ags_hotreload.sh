#!/bin/bash
find dotfiles/ags \( -name "*.tsx" -o -name "*.ts" -o -name "*.scss" -o -name "*.css" \) | \
entr -rs 'ags quit -i desktop-shell 2>/dev/null || true; ags run dotfiles/ags/app.tsx 2>&1 | tee dotfiles/tmp/ags.log'