# libmpv-win32-video-cmake 工作流程图

> 锚点：`master 7f7b149`（2026-10-21）｜范围：LLVM 工具链、CMake ExternalProject、mpv 产物、CI 发布
> 五件套：[architecture.md](./architecture.md)｜[update-history.md](./update-history.md)｜[backlog.md](./backlog.md)｜[test-suite.md](./test-suite.md)
> 消费方：[media-kit](../../media-kit/doc/architecture.md)｜同族：[android](../../libmpv-android-video-build/doc/architecture.md)｜[darwin](../../libmpv-darwin-build/doc/architecture.md)

## 1. 两段式 CI

```
① llvm_clang.yml（手动/上游触发）
   Arch 容器 → 用 CMake 构建 LLVM+Clang（PGO）
   → 产出 clang_root + 4 套 mingw sysroot
   → 存 actions cache（按 CACHE_VERSION 作用域）

② mpv_clang.yml（手动 workflow_dispatch）
   matrix: i686 | x86_64 | x86_64_v3 | aarch64
   → 恢复 clang 缓存（缺失则先跑 ①）
   → cmake 配置工程（下载全部源码）
   → ninja mpv / mpv-release
   → ninja mpv-packaging（7z/zip）
   → 上传 artifact；可选 GitHub Release
```

证据：`.github/workflows/llvm_clang.yml`、`.github/workflows/mpv_clang.yml:26-190`。

## 2. 单 arch 构建链

```
cmake -DTARGET_ARCH=<arch>-w64-mingw32 -G Ninja
  → ninja download        # packages/*.cmake 拉源码
  → ninja update          # 打 packages/*.patch
  → ninja mpv             # libmpv + mpv.exe
  → ninja mpv-packaging   # 目录 → 7z/zip
```

包依赖由 `ExternalProject_Add` 的 `DEPENDS` 决定，核心链：

```
ffmpeg + luajit + libplacebo + libass + uchardet + shaderc/spirv-cross
  → mpv → mpv.exe / libmpv-2.dll
```

## 3. 产物

| 产物 | 内容 | 去向 |
| --- | --- | --- |
| `mpv-<arch>-<date>-git-<sha>` | mpv.exe/com、fonts.conf、manual | 发布包 |
| `mpv-dev-<arch>-…` | `libmpv-2.dll`、`libmpv.dll.a`、`include/mpv/*.h` | media-kit Windows |
| `mpv-debug-…` | PDB | 仅 artifact，发布前删 |
| `.7z` / `.zip` | 上述目录压缩 | Release |

证据：`packages/mpv.cmake:55-85`、`packages/mpv-packaging.cmake:1-20`。

## 4. 消费路径

```
Release 7z → media-kit/libs/windows/{audio,video} 解包 libmpv-2.dll
  → media_kit 加载 → simple_live_app Windows 播放
  → 视频嵌入走定制 DXGI render API（packages/mpv-0001-dxd11-render-api.patch）
```

## 5. 失败与兜底

| 失败点 | 表现 | 兜底 |
| --- | --- | --- |
| clang 缓存缺失/作用域错 | 编译期找不到 clang | 先跑 llvm_clang.yml，确认 CACHE_VERSION |
| 源码缓存失效 | 下载慢/失败 | `ninja download` 重试；repository cache |
| 补丁上下文漂移 | `git apply` 失败 | 重新 rebase patch（见 backlog P1-1） |
| `mpv-release` 无 Lua | 内置脚本不可用 | 需要 Lua 时用 `mpv` 目标（`mpv.cmake`） |
| 发布上传失败 | Release 缺附件 | 工作流已改为 fail-on-error（`9887721`） |

## 历史锚点

| 流程 | 关键提交 |
| --- | --- |
| 本地 AF 滤镜 | `7042698`、`8575ff5`、`9db8233` |
| 本地 LuaJIT | `7f7b149` |
| DXGI render API（上游） | `f162d85` |
