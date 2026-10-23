# libmpv-win32-video-cmake 架构与选型对照

> 锚点：`master 7f7b149`（2026-10-21）｜范围：CMake 包编排、LLVM 工具链、定制补丁、Windows 产物
> 五件套：[workflow-diagram.md](./workflow-diagram.md)｜[update-history.md](./update-history.md)｜[backlog.md](./backlog.md)｜[test-suite.md](./test-suite.md)
> 消费方：[media-kit](../../media-kit/doc/architecture.md)｜同族：[android](../../libmpv-android-video-build/doc/architecture.md)｜[darwin](../../libmpv-darwin-build/doc/architecture.md)

## 1. 定位

Windows 的 mpv/libmpv 构建仓，fork 自 `Predidit/libmpv-win32-video-cmake`。产物分两类：可直接运行的 `mpv.exe` 包，和给 media-kit 用的 `libmpv-2.dll` + 头文件。**DXGI render API 来自上游主线**；本 fork 相对 `upstream/master` 只领先 5 条（LuaJIT + 4 个 AF 滤镜提交）。

## 2. 分层

| 层 | 位置 | 职责 |
| --- | --- | --- |
| 顶层工程 | `CMakeLists.txt` | 工程选项、TARGET_ARCH、缓存与工具链检查 |
| 包编排 | `packages/CMakeLists.txt`、`packages/*.cmake` | 每个依赖一个 ExternalProject |
| 补丁 | `packages/*.patch` | 上游源码修正 |
| 工具链 | `cmake/toolchain_check.cmake`、`toolchain.cmake.in` | mingw/clang cross |
| CI | `.github/workflows/{llvm_clang,mpv_clang}.yml` | 两段式构建与发布 |

## 3. 版本与工具链

| 项 | 值 | 证据 |
| --- | --- | --- |
| mpv | `0b7ed670…` | `packages/mpv.cmake:20` |
| FFmpeg | `5b9a3ad7…` | `packages/ffmpeg.cmake:33` |
| libplacebo | `3330a515…` | `packages/libplacebo.cmake:13` |
| LuaJIT | `v2.1-agentzh` | `packages/luajit.cmake:36` |
| 编译器 | 自建 LLVM/Clang（PGO）+ mingw sysroot | `llvm_clang.yml` |
| 目标 | i686 / x86_64 / x86_64-v3 / aarch64 | `mpv_clang.yml:31-34` |

## 4. 关键定制

> 来源：DXGI/TLS/HLS/ad blocker 为上游主线；**LuaJIT 与 AF 滤镜为本地分叉（5 条）**。

| 定制 | 原因 | 位置 |
| --- | --- | --- |
| DXGI render API（`MPV_RENDER_API_TYPE_DXGI`） | Windows 下把 libmpv 画面嵌入 Flutter 纹理 | `packages/mpv-0001-dxd11-render-api.patch` |
| `dynaudnorm/loudnorm/aresample/alimiter/acompressor` | 音量均衡；`aresample` 是 loudnorm 建图必需 | `packages/ffmpeg.cmake:268-273` |
| HLS kazumi 合并补丁 | 伪装 HLS 流的探测/seek | `packages/ffmpeg-hls-kazumi-combined.patch` |
| 恢复 TLS 校验默认值 | 安全默认 | `packages/mpv-0002-restore-tls-verify-default.patch` |
| LuaJIT（Lua 5.2） | mpv 内置脚本；`mpv.cmake` 中 `-Dlua=enabled` | `packages/mpv.cmake:38` |
| Vulkan 关闭、GL 可配 | media-kit 只用 DXGI/GL 路径 | `packages/mpv.cmake:43-44` |

> 注意：`mpv.cmake`（libmpv）Lua 开启；`mpv-release.cmake`（最新版本 tarball 路径）Lua 关闭（`:49`）。选错目标会得到无 Lua 的库。

## 5. 产物与消费

- `mpv-dev-*`：`libmpv-2.dll` + `libmpv.dll.a` + `include/mpv/{client,stream_cb,render,render_gl,render_dxgi}.h`（`mpv.cmake:60-76`）。
- `mpv-*`：mpv.exe/com、fonts.conf、manual。
- media-kit `libs/windows/{audio,video}` 消费 dll；版本/哈希需人工同步。

## 6. 取舍与风险

- **CMake ExternalProject 而非脚本**：依赖图显式、增量构建好；代价是包多、配置复杂。
- **自建 LLVM PGO 工具链**：性能与 aarch64 支持；代价是两段式 CI 与缓存强耦合（缓存选错分支会全挂）。
- **风险**：1778 条历史里大量上游补丁 rebase；源码/补丁随上游漂移；aarch64 产物验证不足。

## 历史锚点

| 决策 | 提交 |
| --- | --- |
| 本地启用 loudnorm/dynaudnorm | `7042698` |
| 本地启用 alimiter/acompressor | `8575ff5` |
| 本地启用 aresample | `9db8233` |
| 本地恢复 LuaJIT | `7f7b149` |
| DXGI render API（上游） | `f162d85` |
