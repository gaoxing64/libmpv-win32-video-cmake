# libmpv-win32-video-cmake 待办与优化清单

> 锚点：`master 7f7b149`（2026-10-21）
> 五件套：[workflow-diagram.md](./workflow-diagram.md)｜[architecture.md](./architecture.md)｜[update-history.md](./update-history.md)｜[test-suite.md](./test-suite.md)
> 消费方：[media-kit](../../media-kit/doc/architecture.md)

## P0 — 会直接影响播放

| ID | 现象 | 证据 | 建议 |
| --- | --- | --- | --- |
| P0-1 | `mpv-release`（最新 tarball）路径 `-Dlua=disabled`，用它替换 libmpv 会丢 Lua 脚本 | `packages/mpv-release.cmake:49` vs `mpv.cmake:38` | 明确「libmpv 必须走 `mpv` 目标」；release 说明标注 |
| P0-2 | 音量均衡依赖定制 ffmpeg；换回上游库则 loudnorm 静默失效 | `packages/ffmpeg.cmake:268-273` | media-kit 更新 dll 时校验滤镜符号 |
| P0-3 | 无 DXGI 补丁的 libmpv 无法嵌入 Flutter Windows 画面 | `packages/mpv-0001-dxd11-render-api.patch` | 升级 mpv 时优先验证 `render_dxgi.h` 仍存在 |

## P1 — 构建脆弱点

| ID | 现象 | 证据 | 建议 |
| --- | --- | --- | --- |
| P1-1 | 18 个补丁随上游源码漂移，`git apply` 易失败 | `packages/*.patch` | bump 时逐个重放；记录适用 commit |
| P1-2 | 两段式 CI 依赖 `CACHE_VERSION` 作用域；选错分支会缺 clang | `llvm_clang.yml`、`mpv_clang.yml:71-98` | 在 README/流程里固化「先 llvm 后 mpv」 |
| P1-3 | aarch64 产物无真机验证 | `mpv_clang.yml:31-34` | Windows on ARM 冒烟一次 |
| P1-4 | 源码缓存失效时全量下载，耗时长 | `mpv_clang.yml:81-110` | 保留 repository cache，失败重试 |
| P1-5 | x86_64_v3 与 x86_64 同名 arch，仅靠 `-v3` 后缀区分 | `mpv_clang.yml:46-50` | 产物命名与消费侧核对 |
| P1-6 | FFmpeg 以 `CONF=1` 配置，不产出 `config.log`，AV1 parser 只能查构建配方 | `packages/ffmpeg.cmake`；CI `Verifying libmpv feature set` | 校验步骤用 `--config-source packages/ffmpeg.cmake` |
| P1-7 | aarch64 编译 openal-soft 的 wave.cpp 时 clang 崩溃（exit 139） | `openal-soft-build-out.log` | 已移除 ffmpeg 对 openal-soft 的多余依赖：ffmpeg 未启用 `--enable-openal`，mpv 也禁用 openal |
| P1-8 | 着色器工具链四个包各自跟踪 `main`，版本漂移后 shaderc 编译失败（`no member named 'StorageClassToString' in namespace 'spvtools'`） | `packages/shaderc.cmake` | 已统一固定到 google/shaderc DEPS 指定的一组 revision；升级时四个包要一起换 |

## P2 — 可维护性

| ID | 现象 | 证据 | 建议 |
| --- | --- | --- | --- |
| P2-1 | dll 哈希靠人工同步 media-kit | `media-kit/libs/windows` | 发布后自动开 PR |
| P2-2 | `mpv.cmake` 与 `mpv-release.cmake` 配置重复且已分叉 | 两文件 | 抽公共 configure 片段 |
| P2-3 | 无自动化产物检查 | CI 仅断言文件存在 | 加滤镜/Lua/DXGI 符号检查 |

## 已决策取舍

- 继续自建 LLVM PGO 工具链：性能与 arm64 优先。
- Vulkan 关闭：media-kit 不使用；减少依赖面。

## 历史锚点

| 条目 | 来源提交 |
| --- | --- |
| P0-1 release 目标禁 Lua | `7f7b149` 只改 `mpv.cmake`，`mpv-release.cmake` 仍禁用 |
| P0-2 滤镜依赖定制构建 | `7042698`、`8575ff5`、`9db8233` |
| P0-3 无 DXGI 无法嵌入 | 上游 `f162d85` |
