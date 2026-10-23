# libmpv-win32-video-cmake 修改历史（Git 复现）

> 锚点：`master 7f7b149`（2026-10-21）｜全仓 **1778** 条；相对 `upstream/master` 本地分叉 **5** 条
> 五件套：[workflow-diagram.md](./workflow-diagram.md)｜[architecture.md](./architecture.md)｜[backlog.md](./backlog.md)｜[test-suite.md](./test-suite.md)
> 消费方：[media-kit](../../media-kit/doc/update-history.md)

> 关键口径：DXGI render API、ad blocker、TLS 等来自上游主线；**本地分叉只有 LuaJIT 与 AF 滤镜 5 条**。

## 1. 复现命令

```bash
git log --date=short --pretty=format:'%h %ad %an %s'
git log --date=short --pretty=format:'%h %ad %an %s' upstream/master..HEAD
git log --author=gaoxing64 --date=short --pretty=format:'%h %ad %s'
git log --since=2026-01-01 --date=short --pretty=format:'%h %ad %s'
```

## 2. 本地分叉（相对 upstream/master）

| 日期 | 提交 | 作者 | 内容 |
| --- | --- | --- | --- |
| 2026-09-28 | `7f7b149` | G | feat(lua): 恢复 LuaJIT 支持 |
| 2026-09-27 | `9db8233` | G | feat(ffmpeg): enable aresample filter |
| 2026-09-27 | `8575ff5` | G | feat(ffmpeg): enable alimiter/acompressor audio filters |
| 2026-09-26 | `84c41ee` | G | ci: drop call_workflow job from llvm bootstrap |
| 2026-09-26 | `7042698` | G | feat(ffmpeg): enable dynaudnorm/loudnorm audio filters |

## 3. fork 作者提交（5 条）

| 日期 | 提交 | 作者 | 内容 |
| --- | --- | --- | --- |
| 2026-09-28 | `7f7b149` | G | feat(lua): 恢复 LuaJIT 支持 |
| 2026-09-27 | `9db8233` | G | feat(ffmpeg): enable aresample filter |
| 2026-09-27 | `8575ff5` | G | feat(ffmpeg): enable alimiter/acompressor audio filters |
| 2026-09-26 | `84c41ee` | G | ci: drop call_workflow job from llvm bootstrap |
| 2026-09-26 | `7042698` | G | feat(ffmpeg): enable dynaudnorm/loudnorm audio filters |

## 4. 2026 年提交（25 条，全量）

| 日期 | 提交 | 作者 | 内容 |
| --- | --- | --- | --- |
| 2026-09-28 | `7f7b149` | G | feat(lua): 恢复 LuaJIT 支持 |
| 2026-09-27 | `9db8233` | G | feat(ffmpeg): enable aresample filter |
| 2026-09-27 | `8575ff5` | G | feat(ffmpeg): enable alimiter/acompressor audio filters |
| 2026-09-26 | `84c41ee` | G | ci: drop call_workflow job from llvm bootstrap |
| 2026-09-26 | `7042698` | G | feat(ffmpeg): enable dynaudnorm/loudnorm audio filters |
| 2026-09-15 | `fdf7512` | P | fix(ci): add hours and minutes to mpv release names and tags |
| 2026-09-15 | `c999784` | P | fix: tls verify default (#7) |
| 2026-09-15 | `90278c4` | P | deps: mainline refresh (#6) |
| 2026-08-11 | `6ef6f2e` | P | fix(ffmpeg): improve HLS probing for disguised streams |
| 2026-08-11 | `252e309` | P | fix: cppwinrt winmd url (#5) |
| 2026-08-11 | `4f976e2` | P | fix: update cppwinrt winmd source path |
| 2026-06-23 | `9887721` | P | fix: fail release upload errors |
| 2026-06-22 | `330dba7` | P | fix: refresh ffmpeg hls patch context |
| 2026-06-22 | `c7aa58f` | P | fix: sync xz source with upstream |
| 2026-06-22 | `afa7de7` | P | fix: disable harfbuzz utilities |
| 2026-06-22 | `50658fb` | P | fix: create openssl apps include directory |
| 2026-06-22 | `8cabcbe` | P | fix: refresh vulkan windows patch context |
| 2026-06-22 | `06243c6` | P | fix: apply vulkan patch without three-way merge |
| 2026-06-22 | `f2557bc` | P | fix: refresh vulkan loader patch |
| 2026-06-22 | `75bd306` | P | fix: sync graphengine sources with upstream |
| 2026-06-22 | `6cbefa1` | P | ci: sync mpv download source with upstream |
| 2026-06-22 | `74c5128` | P | ci: refresh mpv sources on cache miss |
| 2026-06-22 | `30f8d83` | P | ci: package aarch64 mpv artifacts as zip |
| 2026-06-22 | `effdf50` | P | fix: sync LLVM toolchain with upstream |
| 2026-06-21 | `87a4835` | P | ci: install supported meson in workflows |

## 5. 年度分布（含本地分叉）

| 年度 | 提交数 | 主题 |
| --- | --- | --- |
| 2026 | 25 | LuaJIT、AF 滤镜（loudnorm/aresample/alimiter/acompressor）、CI/缓存、aarch64 打包 |
| 2025 | 61 | DXGI render API、ad blocker、libarchive/opus/fontconfig 升级 |
| 2024 | 111 | 补丁 rebase、依赖升级、发布流程 |
| 2023 | 293 | CMake 包体系、LLVM 工具链、PGO、i686/x86_64 矩阵 |
| 2022 及更早 | 1288 | 项目初始与长期维护 |

> 全量 1778 条用 §1 第一条命令导出。

## 6. 当前状态

- 分支 `master`，HEAD `7f7b149`；相对 `upstream/master` 领先 5 条（LuaJIT + 4 个滤镜提交）。
- DXGI/TLS/ad blocker 等来自上游；产物由本仓 CI 构建，media-kit 固定下载对应 Release。
