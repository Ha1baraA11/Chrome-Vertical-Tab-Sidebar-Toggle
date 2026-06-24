<p align="center">
  <img src="assets/logo.png" alt="Chrome-Vertical-Tab-Sidebar-Toggle Logo" width="200">
</p>

<h1 align="center">Chrome-Vertical-Tab-Sidebar-Toggle</h1>

<p align="center">
  <strong>macOS 손쉬운 사용 API를 사용하여 Chrome의 기본 수직 탭 사이드바를 토글하는 Hammerspoon 스크립트</strong><br>
  키보드 단축키, 화면 가장자리 마우스 호버 트리거, 또는 둘 다 — 원하는 대로 선택하세요.
</p>

<p align="center">
  <a href="README.md">English</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.zh-TW.md">繁體中文</a> · <a href="README_ja.md">日本語</a> · <a href="README_es.md">Español</a> · <a href="README_pt-BR.md">Português</a> · <a href="README_ru.md">Русский</a> · <a href="README_fr.md">Français</a> · <a href="README_de.md">Deutsch</a>
</p>

---

## 소개

Chrome에는 내장된 수직 탭 사이드바가 있지만, 이를 토글할 키보드 단축키가 없습니다. 이 스크립트는 두 가지 버전으로 이 문제를 해결합니다:

- **`init.lua`** — 세 가지 선택 가능한 스킴 지원 (키보드 / 화면 가장자리 호버 / 둘 다)
- **`init-keyboard-only.lua`** — 키보드 단축키만, 마우스 감지 없음

Chrome의 손쉬운 사용 트리(`AXUIElement`)를 탐색하여 "Expand Tabs" / "Collapse Tabs" 버튼을 찾고 `AXPress`로 누르는 방식입니다. [ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast)와 동일한 접근 방식입니다.

## 데모

https://github.com/user-attachments/assets/bcf2a76a-8028-4b63-bc8a-f0b9e1178a25

## 지원 Chrome 로케일

스크립트는 Chrome의 손쉬운 사용 트리에 있는 사이드바 버튼 레이블을 매칭하여 작동합니다. 다음 로케일에서 바로 사용할 수 있습니다:

| 언어 | 로케일 | 탭 펼치기 | 탭 접기 |
|------|--------|----------|---------|
| 영어 | `en` | Expand tabs | Collapse tabs |
| 번체 중국어 | `zh-TW` / `zh-HK` | 展開分頁 | 收合分頁 |
| 간체 중국어 | `zh-CN` | 展开标签页 | 收起标签页 |
| 일본어 | `ja` | タブを開く | タブを閉じる |
| 한국어 | `ko` | 탭 펼치기 | 탭 접기 |
| 독일어 | `de` | Tabs maximieren | Tabs minimieren |
| 스페인어 | `es` | Mostrar pestañas | Ocultar pestañas |
| 프랑스어 | `fr` | Développer les onglets | Réduire les onglets |
| 포르투갈어 (브라질) | `pt-BR` | Mostrar guias | Ocultar guias |
| 러시아어 | `ru` | Развернуть вкладки | Свернуть вкладки |

다른 언어를 추가하려면 사용 중인 Chrome 로케일의 버튼 레이블을 확인하여 `init.lua`의 `SIDEBAR_LABELS` 테이블에 추가하세요.

## 요구 사항

- macOS 13+
- [Hammerspoon](https://www.hammerspoon.org)
- 수직 탭 사이드바가 활성화된 Google Chrome
- Hammerspoon에 손쉬운 사용 권한이 부여되어 있어야 함

## Chrome에서 수직 탭 사이드바 활성화하기

수직 탭 사이드바는 기본적으로 비활성화되어 있습니다. 활성화하려면:

1. 주소창에 `chrome://flags/#vertical-tabs`를 입력하세요
2. **Vertical tabs**를 **Enabled**로 변경하세요
3. **Relaunch**(다시 시작)를 클릭하여 Chrome을 재시작하세요
4. 재시작 후 탭 표시줄의 빈 공간을 우클릭하여 옵션을 확인하세요

## 설치

1. Hammerspoon을 설치하세요:

   ```bash
   brew install --cask hammerspoon
   ```

2. 버전을 선택하고 Hammerspoon 설정 디렉터리에 복사하세요:

   **스킴 버전** (3가지 모드, 기본값):
   ```bash
   cp init.lua ~/.hammerspoon/init.lua
   ```

   **키보드 전용 버전**:
   ```bash
   cp init-keyboard-only.lua ~/.hammerspoon/init.lua
   ```

   이미 `~/.hammerspoon/init.lua`가 있는 경우 내용을 끝에 추가하세요.

3. 손쉬운 사용 권한을 부여하세요:
   - 시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용
   - Hammerspoon을 추가하고 활성화하세요

4. Hammerspoon 설정을 다시 로드하세요 (메뉴 표시줄 아이콘 → 설정 다시 로드 클릭)

5. (선택) Hammerspoon을 로그인 항목에 추가하여 자동 시작을 설정하세요:
   - 시스템 설정 → 일반 → 로그인 항목
   - Hammerspoon을 추가하세요

## 스킴 (`init.lua`)

`init.lua` 상단의 `SCHEME` 변수를 편집하여 모드를 선택:

| 스킴 | 값 | 트리거 |
|------|-----|--------|
| 키보드만 | `1` | `Cmd+S`로 사이드바 토글 |
| 화면 가장자리 호버만 | `2` | 화면 가장자리에 호버 시 펼치기, 380px 초과 이동 시 접기 |
| 키보드 + 마우스 | `3` | 두 트리거 모두 활성 (기본값) |

```lua
local SCHEME = 3  -- 1 = 키보드, 2 = 화면 가장자리 호버, 3 = 둘 다
```

Chrome이 포그라운드 앱이 아닐 때 모든 트리거는 자동으로 비활성화됩니다.

## 트리거

| 트리거 | 동작 | 스킴 |
|--------|------|------|
| `Cmd+S` | 사이드바 토글 | 1 & 3 |
| 왼쪽 가장자리 (0-2px)에 0.15초 호버 | 사이드바 펼치기 | 2 & 3 |
| 왼쪽 가장자리에서 380px 초과 마우스 이동 | 사이드바 접기 | 2 & 3 |

## 디버그

| 단축키 | 동작 |
|--------|------|
| `Cmd+Alt+D` | 서비스 상태 표시 |
| `Cmd+Alt+B` | Chrome의 AX 버튼을 모두 콘솔에 출력 |
| `Cmd+Alt+R` | 모든 서비스 강제 재시작 |

## 설정

### 스킴 선택 (`init.lua`)

```lua
local SCHEME = 3  -- 1 = 키보드, 2 = 화면 가장자리 호버, 3 = 둘 다
```

### 화면 가장자리 호버 임계값 (`init.lua`, 스킴 2 & 3)

```lua
local EDGE_THRESHOLD    = 2       -- 왼쪽 가장자리에서의 트리거 거리 (픽셀)
local EXIT_THRESHOLD    = 380     -- 접기 트리거의 왼쪽 가장자리로부터의 거리 (픽셀)
local WAIT_TIME         = 0.15    -- 호버 대기 시간 (초)
local MOUSE_POLL_INTERVAL = 0.05  -- 마우스 위치 확인 간격 (초)
```

### 두 버전 공통

```lua
local DEBUG = true  -- 콘솔에 디버그 메시지 출력
```

## 키보드 단축키 사용자 정의

`init.lua`와 `init-keyboard-only.lua` 모두에서 사용 가능합니다. 기본 단축키는 `Cmd+S`이며, Chrome의 "페이지 저장" 단축키를 덮어씁니다. 변경하려면 `createKeyTap` 함수 내의 키 검사를 편집하세요:

```lua
-- Cmd+S -> toggle sidebar
if flags.cmd and not flags.ctrl and not flags.alt and not flags.shift
    and keyCode == keycodes.map["s"] then
```

### 수정 키

`flags.*` 조건을 변경하여 원하는 수정 키 조합을 설정:

| 수정 키 | 플래그 | 예 |
|---------|--------|-----|
| Cmd | `flags.cmd` | `flags.cmd and not flags.ctrl` |
| Ctrl | `flags.ctrl` | `flags.ctrl and not flags.cmd` |
| Alt/Option | `flags.alt` | `flags.alt` |
| Shift | `flags.shift` | `flags.shift` |

플래그를 `true`로 설정하면 필수, `not flags.xxx`로 설정하면 제외됩니다.

### 키 코드

`keycodes.map["s"]`를 원하는 키 이름으로 변경. 자주 사용하는 예:

```lua
keycodes.map["s"]       -- S
keycodes.map["b"]       -- B
keycodes.map["/"]       -- /
keycodes.map["return"]  -- Return/Enter
keycodes.map["space"]   -- Space
keycodes.map["f1"]      -- F1
```

전체 키 이름 목록: Hammerspoon 콘솔에서 `hs.keycodes.map`를 실행하세요.

### 예시

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

편집 후 Hammerspoon 설정을 다시 로드하여 적용하세요.

## 작동 방식

1. Chrome 포그라운드 시 `Cmd+S` 차단 및 제어 (스킴 1 & 3)
2. 화면 왼쪽 가장자리 호버 및 이탈 감지 (스킴 2 & 3)
3. 두 트리거 모두 `toggleSidebar()` 호출:
   - `hs.axuielement.applicationElement()`로 Chrome의 AX 루트 요소 가져오기
   - 윈도우에서 `AXDescription`이 "Expand Tabs" 또는 "Collapse Tabs"와 일치하는 버튼 검색하기
   - 찾은 버튼에 `performAction("AXPress")` 호출하기
4. 마우스 폴러 오류 감지 및 자동 재시작 (스킴 2 & 3)
5. 앱 전환 시 오작동 방지 유예 시간을 통한 오작동 방지

## 파일

| 파일 | 설명 |
|------|------|
| `init.lua` | 3스킴 버전 (키보드 / 마우스 / 둘 다) |
| `init-keyboard-only.lua` | 키보드 전용 버전, 마우스 감지 없음 |

## 크레딧

- 원본 개념:[ChromeSidebarToggleRaycast](https://github.com/RotulPlastik/ChromeSidebarToggleRaycast) by RotulPlastik
- Hammerspoon에 맞게 적응하고 화면 가장자리 호버 트리거 추가

## 라이선스

MIT
