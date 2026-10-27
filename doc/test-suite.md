# libmpv-win32-video-cmake 测试案例库（面向 AI）

> 锚点：`master 7f7b149`（2026-10-21）｜无单元测试，验收以构建产物 + Windows 冒烟为准
> 五件套：[workflow-diagram.md](./workflow-diagram.md)｜[architecture.md](./architecture.md)｜[update-history.md](./update-history.md)｜[backlog.md](./backlog.md)
> 消费方：[media-kit](../../media-kit/doc/architecture.md)

## 1. 怎么跑

```bash
# 本地（Linux/容器 + mingw clang）或 CI workflow_dispatch
cmake -DTARGET_ARCH=x86_64-w64-mingw32 -DCOMPILER_TOOLCHAIN=clang -G Ninja -B build_x86_64 -S .
ninja -C build_x86_64 mpv
ninja -C build_x86_64 mpv-packaging
```

CI：`.github/workflows/mpv_clang.yml`（手动）；工具链先跑 `llvm_clang.yml`。

## 2. 构建验收用例

| ID | 前置 | 步骤 | 期望 |
| --- | --- | --- | --- |
| TC-W-01 | clang 缓存就绪 | workflow_dispatch 跑 mpv_clang | 4 个 arch job 成功；artifact 含 `mpv-<arch>-*` |
| TC-W-02 | 产物解包 | `7z l mpv-x86_64-*.7z` | 含 `mpv.exe`、`mpv.com`、`fonts.conf`、manual |
| TC-W-03 | dev 包 | 检查 `mpv-dev-x86_64-*` | 含 `libmpv-2.dll`、`libmpv.dll.a`、`render_dxgi.h` |
| TC-W-04 | DLL 架构 | `objdump -f libmpv-2.dll`（或 Dependencies） | Machine 与目标 arch 一致 |
| TC-W-05 | 滤镜 | `sh scripts/verify_libmpv_artifacts.sh libmpv-2.dll --config-source packages/ffmpeg.cmake` | loudnorm/aresample/alimiter/acompressor 均 PASS |
| TC-W-06 | Lua/stats.lua | 同上，检查 `display-stats-toggle`、`display-page-1-toggle` | 均 PASS（stats.lua 内置；`mpv` 与 `mpv-release` 两个目标都要有） |
| TC-W-06b | 编解码器 | 同上，检查 `h264`/`hevc`/`av1`/`libdav1d` | 均 PASS |
| TC-W-06c | AV1 parser | 同上，查构建配方 `--enable-parser=av1` | PASS；二进制里 av1 与解码器同名，只能查配方（FFmpeg 以 `CONF=1` 配置，不产出 config.log） |
| TC-W-07 | DXGI | `dumpbin /exports libmpv-2.dll` 或头文件检查 | 存在 DXGI render API 入口 |
| TC-W-08 | 播放 | Windows 运行 `mpv.exe <直播流>` | 起播、有声、可 seek |
| TC-W-09 | 嵌入 | media-kit Windows 示例播放 | 画面嵌入窗口，不另开窗口 |
| TC-W-10 | 音量均衡 | 打开 loudnorm 播放 | 响度生效，无静音 |
| TC-W-11 | 伪装 HLS | 播放扩展名非 m3u8 的 HLS | 正确识别（kazumi 补丁） |

## 3. 发布前清单

1. 确认使用的是 `mpv` 目标（Lua 开启），不是 `mpv-release`。
2. 记录 dll SHA256 并同步 media-kit `libs/windows`。
3. x86_64 与 aarch64 各跑一次 TC-W-09。
4. 若升级 mpv/ffmpeg，补跑 TC-W-05/06/07/11。

## 4. 已知限制

- 构建只能在 Linux 容器/mingw 下完成；Windows 仅做产物冒烟。
- 无自动化符号断言（backlog P2-3）。

## 历史锚点

| 用例 | 守护的提交 |
| --- | --- |
| TC-W-05 滤镜 | `7042698`、`8575ff5`、`9db8233` |
| TC-W-06 Lua | `7f7b149` |
| TC-W-07 DXGI | `f162d85`（上游） |
