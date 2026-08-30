#
# Ghostty - live theme switching and low-DPI font toggle
#

# ─── Themes ─────────────────────────────────────────────────────────────────

# Ghostty exposes no CLI for rethemeing a running window: reload_config is a
# keybind action only, and `+show-config --theme=X` is not a thing. What it does
# implement is the xterm color OSCs (src/terminal/osc/parsers/color.zig): 4 sets
# an ANSI slot, 10/11/12 the foreground/background/cursor, 17/19 the selection
# colors, and 104/110/111/112/117/119 reset them. A Ghostty theme file is just a
# list of exactly those colors, so replaying one as escape sequences retimes the
# session live - and writing the same sequences to another tty retimes that one.
#
# The sequences are terminated with BEL rather than the nominally preferred
# ESC-backslash: printf '%b' collapses the backslash pairs needed to emit an
# ESC-backslash, which swallows the ESC of the *next* sequence and dumps the
# remainder on screen as text. Ghostty accepts either terminator.

GHOSTTY_THEME_DIRS=(
  "$HOME/.config/ghostty/themes"
  "/Applications/Ghostty.app/Contents/Resources/ghostty/themes"
)

# Resolve a theme name to a file, preferring your own themes over the built-ins
_gtheme_file() {
  local dir
  for dir in $GHOSTTY_THEME_DIRS; do
    [[ -f "$dir/$1" ]] && { print -r -- "$dir/$1"; return 0 }
  done
  return 1
}

# Translate a theme file into the escape sequences that apply it
_gtheme_escapes() {
  local line key val out=""
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == \#* ]] && continue
    key=${line%% =*}
    val=${line#*= }
    case $key in
      palette)              out+="\e]4;${val%%=*};${val#*=}\a" ;;
      foreground)           out+="\e]10;$val\a" ;;
      background)           out+="\e]11;$val\a" ;;
      cursor-color)         out+="\e]12;$val\a" ;;
      selection-background) out+="\e]17;$val\a" ;;
      selection-foreground) out+="\e]19;$val\a" ;;
    esac
  done < "$1"
  print -r -- "$out"
}

# Write to this terminal, or to every terminal we are allowed to write to
_gtheme_emit() {
  local seq=$2 tty
  if (( $1 )); then
    for tty in /dev/ttys*; do
      [[ -w "$tty" ]] && printf '%b' "$seq" > "$tty"
    done
  else
    printf '%b' "$seq"
  fi
}

# gtheme [-a] <name>   apply a theme to this session, or -a for all of them
# gtheme [-a] -r       reset to whatever the config file says
# gtheme               list your themes
gtheme() {
  local all=0
  [[ "$1" == "-a" || "$1" == "--all" ]] && { all=1; shift }

  case "$1" in
    "")
      print "usage: gtheme [-a] <theme>    apply theme (-a: every session)"
      print "       gtheme [-a] -r         reset to the configured theme"
      print ""
      print "your themes:"
      local dir theme
      for theme in "$GHOSTTY_THEME_DIRS[1]"/*(N); do print "  ${theme:t}"; done
      print ""
      print "built-ins: ghostty +list-themes"
      ;;
    -r|--reset)
      # 104 resets the ANSI slots, 110-112 fg/bg/cursor, 117/119 the selection
      _gtheme_emit $all "\e]104\a\e]110\a\e]111\a\e]112\a\e]117\a\e]119\a"
      ;;
    *)
      local file
      if ! file=$(_gtheme_file "$1"); then
        print -u2 "gtheme: no theme named '$1' (try: gtheme)"
        return 1
      fi
      _gtheme_emit $all "$(_gtheme_escapes "$file")"
      ;;
  esac
}

# ─── Font ───────────────────────────────────────────────────────────────────

# Font family cannot be changed in a running session: Ghostty implements no OSC
# for it and its only runtime font actions are size ones. So `gfont` writes the
# override file that config includes, and the change lands on config reload -
# which applies to every window, not just this one. That is the whole truth of
# what Ghostty allows here.

GHOSTTY_FONT_OVERRIDE="$HOME/.config/ghostty/font-override.conf"

# gfont          toggle between the SF Mono default and CommitMono
# gfont on|off   force CommitMono on or off
gfont() {
  local want=$1
  [[ -z "$want" ]] && { [[ -f "$GHOSTTY_FONT_OVERRIDE" ]] && want=off || want=on }

  case "$want" in
    on)
      # font-family is repeatable, so reset the list before re-adding, or this
      # would only append and SF Mono would stay first in the fallback chain.
      cat > "$GHOSTTY_FONT_OVERRIDE" <<'CONF'
font-family =
font-family = CommitMono
font-family = Symbols Nerd Font Mono
font-thicken = true
CONF
      print "font: CommitMono + thickening (low DPI)"
      ;;
    off)
      rm -f "$GHOSTTY_FONT_OVERRIDE"
      print "font: SF Mono (default)"
      ;;
    *)
      print -u2 "usage: gfont [on|off]   (no argument toggles)"
      return 1
      ;;
  esac
  print "press ⌘⇧, to reload — affects every window (Ghostty has no per-session font)"
}
