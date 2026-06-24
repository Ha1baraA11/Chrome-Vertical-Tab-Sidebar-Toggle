<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>Un script Hammerspoon pour afficher/masquer la barre latérale d'onglets verticaux native de Chrome via l'API d'Accessibilité de macOS</strong><br>
  Raccourci clavier, déclenchement par bord de l'écran, ou les deux — à vous de choisir.
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README_ja.md">日本語</a> · <a href="README_ko.md">한국어</a> · <a href="README_es.md">Español</a> · <a href="README_pt-BR.md">Português</a> · <a href="README_ru.md">Русский</a> · <a href="README_de.md">Deutsch</a>
</p>

---

## Fonctionnalités

Chrome dispose d'une barre latérale d'onglets verticaux intégrée, mais aucun raccourci clavier ne permet de l'afficher ou de la masquer. Ce script propose deux versions pour y remédier :

- **`init.lua`** — prend en charge trois schémas sélectionnables (clavier / bord de l'écran / les deux)
- **`init-keyboard-only.lua`** — raccourci clavier uniquement, sans détection de souris

Fonctionne en parcourant l'arbre d'accessibilité de Chrome (`AXUIElement`) pour trouver le bouton "Expand Tabs" / "Collapse Tabs" et le presser via `AXPress`. Même approche que [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast).

## Démo

https://github.com/user-attachments/assets/bcf2a76a-8028-4b63-bc8a-f0b9e1178a25

## Paramètres régionaux Chrome pris en charge

Le script compare les libellés des boutons de la barre latérale dans l'arbre d'accessibilité de Chrome. Il fonctionne directement avec ces paramètres régionaux :

| Langue | Paramètre régional | Développer les onglets | Réduire les onglets |
|--------|---------------------|------------------------|---------------------|
| Anglais | `en` | Expand tabs | Collapse tabs |
| Chinois traditionnel | `zh-TW` / `zh-HK` | 展開分頁 | 收合分頁 |
| Chinois simplifié | `zh-CN` | 展开标签页 | 收起标签页 |
| Japonais | `ja` | タブを開く | タブを閉じる |
| Coréen | `ko` | 탭 펼치기 | 탭 접기 |
| Allemand | `de` | Tabs maximieren | Tabs minimieren |
| Espagnol | `es` | Mostrar pestañas | Ocultar pestañas |
| Français | `fr` | Développer les onglets | Réduire les onglets |
| Portugais (Brésil) | `pt-BR` | Mostrar guias | Ocultar guias |
| Russe | `ru` | Развернуть вкладки | Свернуть вкладки |

Pour ajouter une autre langue, trouvez le libellé du bouton dans votre paramètre régional Chrome et ajoutez-le au tableau `SIDEBAR_LABELS` dans `init.lua`.

## Prérequis

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- Google Chrome avec la barre latérale d'onglets verticaux activée
- Autorisation d'accessibilité accordée à Hammerspoon

## Activer la barre latérale d'onglets verticaux dans Chrome

La barre latérale d'onglets verticaux n'est pas activée par défaut. Pour l'activer:

1. Tapez `chrome://flags/#vertical-tabs` dans la barre d'adresse
2. Changez **Vertical tabs** en **Enabled**
3. Cliquez sur **Relaunch** pour redémarrer Chrome
4. Après le redémarrage, faites un clic droit sur une zone vide de la barre d'onglets pour voir l'option

## Installation

1. Installez Hammerspoon :

   ```bash
   brew install --cask hammerspoon
   ```

2. Choisissez une version et copiez-la dans la configuration Hammerspoon :

   **Version avec schémas** (trois modes, par défaut) :
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **Version clavier uniquement** :
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   Si vous avez déjà un `~/.hammerspoon/init.lua`, ajoutez le contenu à la fin.

3. Accordez l'autorisation d'accessibilité :
   - Réglages Système → Confidentialité et sécurité → Accessibilité
   - Ajoutez et activez Hammerspoon

4. Rechargez la configuration Hammerspoon (cliquez sur l'icône de la barre de menus → Recharger la configuration)

5. (Facultatif) Ajoutez Hammerspoon aux éléments de connexion pour un démarrage automatique :
   - Réglages Système → Général → Ouverture
   - Ajoutez Hammerspoon

## Schémas (`init.lua`)

Modifiez la variable `SCHEME` en haut du fichier `init.lua` pour choisir un mode :

| Schéma | Valeur | Déclencheurs |
|--------|--------|--------------|
| Clavier uniquement | `1` | `Cmd+S` bascule la barre latérale |
| Bord de l'écran uniquement | `2` | Survolez le bord gauche de l'écran pour développer, déplacez au-delà de 380px pour réduire |
| Clavier + Souris | `3` | Les deux déclencheurs actifs (par défaut) |

```lua
local SCHEME = 3  -- 1 = Clavier, 2 = Bord de l'écran, 3 = Les deux
```

Lorsque Chrome n'est pas l'application au premier plan, tous les déclencheurs sont automatiquement désactivés.

## Déclencheurs

| Déclencheur | Action | Schéma |
|-------------|--------|--------|
| `Cmd+S` | Basculer la barre latérale | 1 & 3 |
| Souris sur le bord gauche (0-2px) pendant 0,15 s | Développer la barre latérale | 2 & 3 |
| Souris se déplace au-delà de 380px du bord gauche | Réduire la barre latérale | 2 & 3 |

## Débogage

| Raccourci | Action |
|-----------|--------|
| `Cmd+Alt+D` | Afficher l'état du service |
| `Cmd+Alt+B` | Exporter tous les boutons AX de Chrome dans la console |
| `Cmd+Alt+R` | Forcer le redémarrage de tous les services |

## Configuration

### Sélecteur de schéma (`init.lua`)

```lua
local SCHEME = 3  -- 1 = Clavier, 2 = Bord de l'écran, 3 = Les deux
```

### Seuils du bord de l'écran (init.lua, schémas 2 & 3)

```lua
local EDGE_THRESHOLD    = 2       -- pixels depuis le bord gauche pour déclencher
local EXIT_THRESHOLD    = 380     -- pixels depuis le bord gauche pour réduire
local WAIT_TIME         = 0.15    -- temps d'attente en secondes avant déclenchement (0,15 s)
local MOUSE_POLL_INTERVAL = 0.05  -- secondes entre les vérifications de position de la souris
```

### Les deux versions

```lua
local DEBUG = true  -- afficher les messages de débogage dans la console
```

## Personnaliser le raccourci clavier

Disponible dans `init.lua` et `init-keyboard-only.lua`. Le raccourci par défaut est `Cmd+S`, qui remplace le raccourci natif de Chrome pour « Enregistrer la page ». Pour le modifier, éditez la vérification de touche dans la fonction `createKeyTap`:

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### Touches modificatrices

Modifiez les conditions `flags.*` pour définir la combinaison de modificateurs souhaitée:

| Modificateur | Flag | Exemple |
|--------------|------|---------|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

Définissez le flag sur `true` pour l'exiger, `not flags.xxx` pour l'exclure.

### Code de touche

Changez `keycodes.map["s"]` par n'importe quel nom de touche. Exemples courants :

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Return/Entrée
keycodes.map["space"]   -- Espace
keycodes.map["f1"]      -- F1
```

Liste complète des noms de touches : exécutez `hs.keycodes.map` dans la console Hammerspoon.

### Exemples

**`Ctrl+Shift+B`**:
```lua
if flags.ctrl and not flags.cmd and flags.shift and not flags.alt
    and keyCode == keycodes.map["b"] then
```

**`Cmd+Alt+/`**:
```lua
if flags.cmd and not flags.ctrl and flags.alt and not flags.shift
    and keyCode == keycodes.map["/"] then
```

**`Cmd+Shift+Return`**:
```lua
if flags.cmd and not flags.ctrl and not flags.alt and flags.shift
    and keyCode == keycodes.map["return"] then
```

Après modification, rechargez la configuration Hammerspoon pour appliquer les changements.

## Comment ça fonctionne

1. Un `eventtap` intercepte `Cmd+S` lorsque Chrome est au premier plan (schémas 1 & 3)
2. Un sondage de position de la souris (50Hz) détecte le survol du bord gauche et la sortie (schémas 2 & 3)
3. Les deux déclencheurs appellent `toggleSidebar()` qui :
   - Obtient l'élément racine AX de Chrome via `hs.axuielement.applicationElement()`
   - Recherche dans les fenêtres un bouton avec `AXDescription` correspondant à "Expand Tabs" ou "Collapse Tabs"
   - Appelle `performAction("AXPress")` sur le bouton trouvé
4. Un mécanisme de « watchdog » détecte si le sondage de la souris échoue et le redémarre automatiquement (schémas 2 & 3)
5. Un délai de tolérance empêche les déclenchements intempestifs lors du changement d'applications

## Fichiers

| Fichier | Description |
|---------|-------------|
| `init.lua` | Version avec 3 schémas (clavier / souris / les deux) |
| `init-keyboard-only.lua` | Version clavier uniquement, sans détection de souris |

## Crédits

- Concept original : [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) par RotulPlastik
- Adapté pour Hammerspoon avec déclenchement par bord de l'écran

## Licence

MIT
