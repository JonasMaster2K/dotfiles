#!/bin/bash
find dotfiles/ags -name "*.tsx" -o -name "*.scss" -o -name "*.css" | entr -rs 'ags quit; ags run dotfiles/ags/app.tsx'