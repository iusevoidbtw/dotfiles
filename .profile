### --- PATH --
export PATH="$PATH:$HOME/.local/bin:/opt/diet/bin"

### --- GENERAL CHANGES ---

# avoid loading nvidia modules when not necessary
# export __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/50_mesa.json

# set va-api drivers to ihd properly
export LIBVA_DRIVER_NAME=iHD
export LIBVA_DRIVERS_PATH=/usr/lib/dri/

# set nvim as the default editor
export EDITOR=nvim

# use catppuccin for bat and bemenu
export BAT_THEME="Catppuccin-mocha"
export BEMENU_OPTS='--fb "#1e1e2e" --ff "#cdd6f4" --nb "#1e1e2e" --nf "#cdd6f4" --tb "#1e1e2e" --hb "#1e1e2e" --tf "#f38ba8" --hf "#f9e2af" --af "#cdd6f4" --ab "#1e1e2e"'

# use wayland for sdl2
export SDL_VIDEODRIVER=wayland
