<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>Um script Hammerspoon que alterna a barra lateral de abas verticais nativa do Chrome através da API de Acessibilidade do macOS</strong><br>
  Atalho de teclado, ativação pela borda do mouse, ou ambos — você escolhe.
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README_ja.md">日本語</a> · <a href="README_ko.md">한국어</a> · <a href="README_es.md">Español</a> · <a href="README_ru.md">Русский</a> · <a href="README_fr.md">Français</a> · <a href="README_de.md">Deutsch</a>
</p>

---

## O que faz

O Chrome tem uma barra lateral de abas verticais integrada, mas sem atalho de teclado para alterná-la. Este script resolve isso com duas versões：

- **`init.lua`** — suporta três esquemas selecionáveis (teclado / borda do mouse / ambos)
- **`init-keyboard-only.lua`** — apenas atalho de teclado, sem detecção de mouse

Funciona percorrendo a árvore de acessibilidade do Chrome (`AXUIElement`) para encontrar o botão "Expand Tabs" / "Collapse Tabs" e pressioná-lo via `AXPress`. Mesma abordagem do [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast).

## Demo

https://github.com/user-attachments/assets/bcf2a76a-8028-4b63-bc8a-f0b9e1178a25

## Requisitos

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- Google Chrome com a barra lateral de abas verticais habilitada
- Permissão de acessibilidade concedida ao Hammerspoon

## Ativar a barra lateral de abas verticais no Chrome

A barra lateral de abas verticais não está ativada por padrão. Para ativar：

1. Digite `chrome://flags/#vertical-tabs` na barra de endereços
2. Altere **Vertical tabs** para **Enabled**
3. Clique em **Relaunch** para reiniciar o Chrome
4. Após reiniciar, clique com o botão direito em uma área vazia da barra de abas para ver a opção

## Instalação

1. Instalar o Hammerspoon：

   ```bash
   brew install --cask hammerspoon
   ```

2. Escolher uma versão e copiar para a configuração do Hammerspoon：

   **Versão com esquemas**（três modos, padrão）：
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **Versão apenas teclado**：
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   Se você já tem um `~/.hammerspoon/init.lua`, adicione o conteúdo ao final.

3. Conceder permissão de acessibilidade：
   - Ajustes do Sistema → Privacidade e Segurança → Acessibilidade
   - Adicionar e habilitar o Hammerspoon

4. Recarregar a configuração do Hammerspoon（clique no ícone da barra de menu → Recarregar Configuração）

5. （Opcional）Adicionar o Hammerspoon aos itens de login para iniciar automaticamente：
   - Ajustes do Sistema → Geral → Itens de Login
   - Adicionar Hammerspoon

## Esquemas（`init.lua`）

Edite a variável `SCHEME` no topo do `init.lua` para escolher um modo：

| Esquema | Valor | Gatilhos |
|---------|-------|----------|
| Apenas teclado | `1` | `Cmd+S` alterna a barra lateral |
| Apenas borda do mouse | `2` | Passar o mouse na borda esquerda para expandir, mover além de 380px para recolher |
| Teclado + Mouse | `3` | Ambos os gatilhos ativos（padrão） |

```lua
local SCHEME = 3  -- 1 = Teclado, 2 = Borda do mouse, 3 = Ambos
```

Quando o Chrome não é o aplicativo em primeiro plano, todos os gatilhos são desativados automaticamente.

## Gatilhos

| Gatilho | Ação | Esquema |
|---------|------|---------|
| `Cmd+S` | Alternar barra lateral | 1 & 3 |
| Mouse na borda esquerda (0-2px) por 0.15s | Expandir barra lateral | 2 & 3 |
| Mouse se move além de 380px da borda esquerda | Recolher barra lateral | 2 & 3 |

## Depuração

| Atalho | Ação |
|--------|------|
| `Cmd+Alt+D` | Mostrar status do serviço |
| `Cmd+Alt+B` | Despejar todos os botões AX do Chrome no console |
| `Cmd+Alt+R` | Forçar reinício de todos os serviços |

## Configuração

### Seletor de esquema（`init.lua`）

```lua
local SCHEME = 3  -- 1 = Teclado, 2 = Borda do mouse, 3 = Ambos
```

### Limites da borda do mouse（`init.lua`, esquemas 2 & 3）

```lua
local EDGE_THRESHOLD    = 2       -- pixels da borda esquerda para ativar
local EXIT_THRESHOLD    = 380     -- pixels da borda esquerda para recolher
local WAIT_TIME         = 0.15    -- segundos de espera antes de ativar
local MOUSE_POLL_INTERVAL = 0.05  -- segundos entre verificações de posição do mouse
```

### Ambas as versões

```lua
local DEBUG = true  -- imprimir mensagens de depuração no console
```

## Personalizar o atalho de teclado

Disponível em `init.lua` e `init-keyboard-only.lua`. O atalho padrão é `Cmd+S`, que sobrescreve o atalho nativo do Chrome para "Salvar página". Para alterar, edite a verificação de tecla na função `createKeyTap`：

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### Teclas modificadoras

Altere as condições `flags.*` para definir a combinação de modificadores desejada：

| Modificador | Flag | Exemplo |
|-------------|------|---------|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

Defina a flag como `true` para exigir, `not flags.xxx` para excluir.

### Código da tecla

Altere `keycodes.map["s"]` para qualquer nome de tecla. Exemplos comuns：

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Return/Enter
keycodes.map["space"]   -- Espaço
keycodes.map["f1"]      -- F1
```

Lista completa de nomes de teclas：execute `hs.keycodes.map` no console do Hammerspoon.

### Exemplos

**`Ctrl+Shift+B`**：
```lua
if flags.ctrl and not flags.cmd and flags.shift and not flags.alt
    and keyCode == keycodes.map["b"] then
```

**`Cmd+Alt+/`**：
```lua
if flags.cmd and not flags.ctrl and flags.alt and not flags.shift
    and keyCode == keycodes.map["/"] then
```

**`Cmd+Shift+Return`**：
```lua
if flags.cmd and not flags.ctrl and not flags.alt and flags.shift
    and keyCode == keycodes.map["return"] then
```

Após editar, recarregue a configuração do Hammerspoon para aplicar.

## Como funciona

1. Um `eventtap` intercepta `Cmd+S` quando o Chrome está em primeiro plano（esquemas 1 & 3）
2. Um monitor de posição do mouse (50Hz) detecta a passagem pela borda esquerda e a saída（esquemas 2 & 3）
3. Ambos os gatilhos chamam `toggleSidebar()` que：
   - Obtém o elemento raiz AX do Chrome via `hs.axuielement.applicationElement()`
   - Procura nas janelas um botão com `AXDescription` correspondendo a "Expand Tabs" ou "Collapse Tabs"
   - Chama `performAction("AXPress")` no botão encontrado
4. Um watchdog detecta se o monitor do mouse falha e reinicia automaticamente（esquemas 2 & 3）
5. Períodos de graça previnem gatilhos falsos durante a troca de aplicativos

## Arquivos

| Arquivo | Descrição |
|---------|-----------|
| `init.lua` | Versão com 3 esquemas（teclado / mouse / ambos） |
| `init-keyboard-only.lua` | Versão apenas teclado, sem detecção de mouse |

## Créditos

- Conceito original：[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- Adaptado para Hammerspoon com suporte a ativação pela borda do mouse

## Licença

MIT
