# libmpv-darwin-build 待办与优化清单

> 锚点：`main df6799f`（2026-10-21）
> 五件套：[workflow-diagram.md](./workflow-diagram.md)｜[architecture.md](./architecture.md)｜[update-history.md](./update-history.md)｜[test-suite.md](./test-suite.md)
> 消费方：[media-kit](../../media-kit/doc/architecture.md)

## P0 — 会直接影响播放

| ID | 现象 | 证据 | 建议 |
| --- | --- | --- | --- |
| P0-1 | 音量均衡依赖定制 ffmpeg；若产物被替换成上游库，`loudnorm/aresample` 消失且滤镜静默失效 | `nix/packages/mk-pkg-ffmpeg/meson.build:169-175`；`49443a3` | release 说明标注滤镜能力；media-kit 更新二进制时校验 `strings` |
| P0-2 | iOS 产物未在当前开发机（Windows）验证，媒体控制/音频会话回归不可见 | `89406df`；本机平台限制 | 每次 release 前在 macOS/iOS 真机冒烟（见 test-suite） |
| P0-3 | Xcode 塞入 `/nix/store` 的路径与哈希写死在 CI | `ci.yaml:35-43` | 升级 Xcode 时同步路径/哈希，或改用 nixpkgs xcode |

## P1 — 构建脆弱点

| ID | 现象 | 证据 | 建议 |
| --- | --- | --- | --- |
| P1-1 | Lua 走 `external_project`，mpv 升级后目标名可能变化 | `453562a`、`nix/packages/mk-pkg-lua/meson.build` | 升级 mpv 时先跑 test-suite 的 Lua 用例 |
| P1-2 | ffmpeg 5 个补丁按上下文打，上游刷新后易冲突 | `mk-pkg-ffmpeg/default.nix:36-52` | 每次 bump ffmpeg 重放补丁并记录偏移 |
| P1-3 | 产物无签名/公证，macOS Gatekeeper 可能拦截 | `ci.yaml` 无签名步骤 | 如需分发 App 外使用，补 codesign/notarize |
| P1-4 | 音频变体删 libass，字幕不可用 | `mpv-remove-libass.patch` | 明确文档化，避免误用 audio 产物做视频 |

## P2 — 结构 / 可维护性

| ID | 现象 | 证据 | 建议 |
| --- | --- | --- | --- |
| P2-1 | 产物哈希靠人工同步到 media-kit | `media-kit/libs/{macos,ios}` | 发布后自动开 PR 更新下载锁 |
| P2-2 | 依赖版本分散在 `packages.lock.nix` 与 flake.lock | `packages.lock.nix`、`flake.lock` | 提供 bump 脚本/清单 |
| P2-3 | Nix 构建日志未归档 | `ci.yaml` 仅上传产物 | 失败时上传 `configure.log` |
| P2-4 | mpv 0.36 的 stats.lua 缺 `display-page-N-toggle`，靠补丁补齐；升 mpv 后补丁会失效 | `patches/mpv-stats-page-toggle.patch` | 升 mpv 时删补丁并确认新版自带该绑定；补丁里的绑定名必须是字面量（运行时拼接在二进制里查不到） |
| P2-5 | 产物有两种布局：libs 是散装 dylib，xcframeworks 是 framework bundle（dylib 名为 `Mpv`） | `nix/packages/mk-out-frameworks/*/build-*.sh` | 校验脚本要同时匹配 `libmpv*.dylib` 与 `Mpv` |
| P2-6 | Lua 5.2.4 的 `loslib.c` 在 iOS 调 `system()`，SDK 不可用 | `patches/lua-ios-no-system.patch` | 升 Lua 时重放补丁 |

## 已决策取舍

- 继续用 flakelight/Nix，不改为 Xcode 工程：可复现性优先。
- 保持 `audio ⊂ video`、`default ⊂ full ⊂ encodersgpl` 的产物包含关系，不新增组合。

## 历史锚点

| 条目 | 来源提交 |
| --- | --- |
| P0-1 滤镜依赖定制构建 | `49443a3` |
| P0-2 iOS 媒体控制未本机验证 | 上游 `89406df` |
| P1-1 Lua 目标名/工具链 | `453562a`、`df6799f` |
