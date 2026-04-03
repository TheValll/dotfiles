#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# GDK BACKEND. Change to either wayland or x11 if having issues
BACKEND=wayland
# Check if rofi or yad is running and kill them if they are
if pidof rofi > /dev/null; then
pkill rofi
fi
if pidof yad > /dev/null; then
pkill yad
fi
# Launch yad with calculated width and height
GDK_BACKEND=$BACKEND yad \
--center \
--title="KooL Quick Cheat Sheet" \
--no-buttons \
--list \
--column=Key: \
--column=Description: \
--column=Command: \
--timeout-indicator=bottom \
"ESC" "Fermer ce menu" "" \
" = " "SUPER KEY (Windows Key)" "" \
"" "" "" \
"" "━━━━━━━━━━━━━━━━━ HYPRLAND ━━━━━━━━━━━━━━━━━" "" \
"" "" "" \
"🚀 LANCEMENT RAPIDE" "" "" \
" Enter" "Terminal" "kitty" \
" Shift Enter" "Terminal dropdown" "Q pour fermer" \
" B" "Navigateur" "Browser par défaut" \
" D" "Lanceur d'applications" "rofi" \
" E" "Gestionnaire de fichiers" "Thunar" \
" S" "Recherche Google" "via rofi" \
" Shift K" "Recherche keybinds" "rofi" \
" H" "Ce menu d'aide" "" \
"" "" "" \
"🪟 GESTION FENÊTRES" "" "" \
" Q" "Fermer fenêtre" "soft close" \
" Shift Q" "Tuer fenêtre" "force kill" \
" Shift F" "Plein écran" "" \
" Ctrl F" "Faux plein écran" "" \
" Space" "Toggle float" "fenêtre actuelle" \
" Alt Space" "Toggle float ALL" "toutes fenêtres" \
" Alt L" "Toggle Layout" "Dwindle/Master" \
"" "" "" \
"🎨 APPARENCE" "" "" \
" W" "Changer wallpaper" "menu wallpaper" \
" Shift W" "Effets wallpaper" "imagemagick + swww" \
"Ctrl Alt W" "Wallpaper aléatoire" "swww" \
" Alt O" "Toggle Blur" "" \
" Ctrl O" "Toggle Opacité" "fenêtre active" \
" Shift A" "Menu animations" "rofi" \
" Shift G" "Gamemode" "ON/OFF animations" \
" Ctrl R" "Thèmes Rofi" "menu v1" \
" Ctrl Shift R" "Thèmes Rofi v2" "Theme Selector" \
"" "" "" \
"📊 INTERFACE & PANNEAUX" "" "" \
" A" "Vue d'ensemble" "AGS" \
" Ctrl Alt B" "Toggle Waybar" "hide/show" \
" Ctrl B" "Styles Waybar" "menu" \
" Alt B" "Layout Waybar" "menu" \
" Alt R" "Reload interface" "waybar/swaync/rofi" \
" Shift N" "Notifications" "swaync" \
" Alt V" "Clipboard" "cliphist" \
" Alt E" "Émojis" "rofi" \
" Shift E" "Settings Hyprland" "menu KooL" \
"" "" "" \
"📸 CAPTURES D'ÉCRAN" "" "" \
" Print" "Screenshot complet" "grim" \
" Shift Print" "Screenshot région" "grim + slurp" \
" Shift S" "Screenshot région" "swappy" \
"Ctrl Print" "Screenshot timer 5s" "grim" \
"Ctrl Shift Print" "Screenshot timer 10s" "grim" \
"Alt Print" "Screenshot fenêtre" "active only" \
"" "" "" \
"🔧 SYSTÈME" "" "" \
" Alt Scroll" "Zoom bureau" "magnifier" \
"Ctrl Alt P" "Menu power" "wlogout" \
"Ctrl Alt L" "Verrouiller" "hyprlock" \
"Ctrl Alt Del" "Quitter Hyprland" "exit immédiat" \
"" "" "" \
"" "━━━━━━━━━━━━━━━━━━━ TMUX ━━━━━━━━━━━━━━━━━━━" "" \
"Prefix = Ctrl+a" "Appuyer AVANT toute commande" "" \
"" "" "" \
"⚙️ CONFIGURATION" "" "" \
"Ctrl+a → r" "Recharger config" "~/.tmux.conf" \
"Ctrl+a → ?" "Aide tmux" "tous les raccourcis" \
"Ctrl+a → :" "Mode commande" "taper commandes tmux" \
"" "" "" \
"🔄 SESSIONS" "" "" \
"Ctrl+a → d" "Détacher session" "tmux en background" \
"Ctrl+a → s" "Liste sessions" "navigation interactive" \
"Ctrl+a → $" "Renommer session" "" \
"Ctrl+a → (" "Session précédente" "" \
"Ctrl+a → )" "Session suivante" "" \
"" "" "" \
"📑 WINDOWS (Onglets)" "" "" \
"Ctrl+a → c" "Créer window" "nouvelle" \
"Ctrl+a → ," "Renommer window" "" \
"Ctrl+a → x" "Fermer window" "avec confirmation" \
"Ctrl+a → n" "Window suivante" "next" \
"Ctrl+a → p" "Window précédente" "previous" \
"Ctrl+a → l" "Dernière window" "last visited" \
"Ctrl+a → 0-9" "Window numéro N" "accès direct" \
"Ctrl+a → w" "Liste windows" "interactive" \
"Ctrl+a → f" "Rechercher window" "par nom" \
"" "" "" \
"🔲 PANES (Panneaux)" "" "" \
"Ctrl+a → |" "Split vertical" "pane droite" \
"Ctrl+a → -" "Split horizontal" "pane bas" \
"Ctrl+a → x" "Fermer pane" "avec confirmation" \
"Ctrl+a → z" "Zoom/Dézoom" "fullscreen toggle" \
"Ctrl+a → !" "Pane → window" "nouvelle window" \
"" "" "" \
"🧭 NAVIGATION PANES" "" "" \
"Ctrl+a → h" "Pane gauche" "←" \
"Ctrl+a → j" "Pane bas" "↓" \
"Ctrl+a → k" "Pane haut" "↑" \
"Ctrl+a → l" "Pane droite" "→" \
"Ctrl+a → o" "Pane suivant" "cycle" \
"Ctrl+a → ;" "Dernier pane" "last active" \
"Ctrl+a → q" "Numéros panes" "taper N pour aller" \
"" "" "" \
"📏 REDIMENSIONNER PANES" "" "" \
"Ctrl+a → H" "Rétrécir gauche" "répétable" \
"Ctrl+a → J" "Agrandir bas" "répétable" \
"Ctrl+a → K" "Rétrécir haut" "répétable" \
"Ctrl+a → L" "Agrandir droite" "répétable" \
"Ctrl+a → Space" "Changer layout" "cycle layouts" \
"" "" "" \
"📋 MODE COPIE (Vim)" "" "" \
"Ctrl+a → [" "Mode copie" "entrer" \
"v (mode copie)" "Sélection" "vim style" \
"y (mode copie)" "Copier & quitter" "" \
"h/j/k/l (mode copie)" "Navigation" "vim style" \
"q/Esc (mode copie)" "Quitter" "sans copier" \
"Ctrl+a → ]" "Coller" "dernier copié" \
"" "" "" \
"💻 COMMANDES LIGNE" "" "" \
"tmux ls" "Lister sessions" "toutes les sessions" \
"tmux new -s nom" "Créer session" "avec nom" \
"tmux attach -t nom" "Rejoindre session" "par nom" \
"tmux kill-session -t nom" "Tuer session" "par nom" \
"tmux rename-session nom" "Renommer session" "session active" \
"tmux rename-session -t old new" "Renommer session" "par nom" \
"tmux rename-window nom" "Renommer window" "window active" \
"tmux rename-window -t N nom" "Renommer window N" "par numéro" \
"" "" "" \
"" "━━━━━━━━━━━━━━━━━ FIREFOX ━━━━━━━━━━━━━━━━━" "" \
"" "" "" \
"📑 ONGLETS" "" "" \
"Ctrl+T" "Nouvel onglet" "" \
"Ctrl+W" "Fermer onglet" "" \
"Ctrl+Shift+T" "Rouvrir onglet" "dernier fermé" \
"Ctrl+Tab" "Onglet suivant" "" \
"Ctrl+Shift+Tab" "Onglet précédent" "" \
"Ctrl+1 à 8" "Onglet numéro N" "accès direct" \
"Ctrl+9" "Dernier onglet" "" \
"Ctrl+Shift+E" "Gestionnaire onglets" "Tree Style Tab" \
"" "" "" \
"🧭 NAVIGATION" "" "" \
"Ctrl+L / F6" "Barre URL" "focus" \
"Alt+←" "Page précédente" "back" \
"Alt+→" "Page suivante" "forward" \
"Ctrl+R / F5" "Recharger" "" \
"Ctrl+Shift+R" "Recharger cache" "force reload" \
"Ctrl+D" "Marque-page" "ajouter" \
"Ctrl+Shift+D" "Tous → marque-pages" "" \
"Ctrl+H" "Historique" "" \
"" "" "" \
"🔍 RECHERCHE" "" "" \
"Ctrl+F" "Rechercher page" "" \
"Ctrl+G" "Résultat suivant" "" \
"Ctrl+Shift+G" "Résultat précédent" "" \
"Ctrl+K" "Barre recherche" "focus" \
"/" "Recherche rapide" "" \
"" "" "" \
"🪟 FENÊTRES" "" "" \
"Ctrl+N" "Nouvelle fenêtre" "" \
"Ctrl+Shift+P" "Navigation privée" "" \
"Ctrl+Shift+N" "Restaurer fenêtre" "dernière fermée" \
"F11" "Plein écran" "toggle" \
"" "" "" \
"🔎 ZOOM" "" "" \
"Ctrl + +" "Zoom avant" "" \
"Ctrl + -" "Zoom arrière" "" \
"Ctrl+0" "Zoom par défaut" "100%" \
"" "" "" \
"🛠️ DÉVELOPPEUR" "" "" \
"F12" "DevTools" "" \
"Ctrl+Shift+C" "Inspecteur" "" \
"Ctrl+Shift+K" "Console web" "" \
"Ctrl+Shift+I" "DevTools" "alternative" \
"Ctrl+U" "Code source" "view source" \
"" "" "" \
"📋 UTILITAIRES" "" "" \
"Ctrl+S" "Enregistrer page" "" \
"Ctrl+P" "Imprimer" "" \
"Ctrl+," "Paramètres" "" \
"Ctrl+Shift+Del" "Effacer données" "" \
"Space" "Défiler bas" "scroll down" \
"Shift+Space" "Défiler haut" "scroll up" \
"" "" "" \
"More tips:" "https://github.com/JaKooLit/Hyprland-Dots/wiki" ""