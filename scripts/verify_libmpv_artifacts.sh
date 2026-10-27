#!/bin/sh
# Verify libmpv artifacts carry the codecs, stats.lua and audio filters we ship.
#
# Decoder and filter names are stored as NUL-terminated C strings, so those are
# checked with `grep -a` against the raw binary. Parser availability cannot be
# told apart from decoder names that way (both are just "av1"), so parsers are
# verified against the FFmpeg configure log instead.
#
# Every run also checks positive controls: if those go missing the scan itself is
# broken and the result must not be trusted (see .workbuddy/memory/2026-10-06.md,
# where a broken `strings` produced a false "feature missing" verdict).
#
# Usage:
#   verify_libmpv_artifacts.sh [--expect-audio-only] [--config-log <log>] \
#       <libmpv binary> [label]

set -eu

expect_audio_only=0
config_log=""
config_sources=""
while [ $# -gt 0 ]; do
	case "$1" in
	--expect-audio-only)
		expect_audio_only=1
		shift
		;;
	--config-log)
		config_log="${2:-}"
		shift 2
		;;
	--config-source)
		config_sources="$config_sources ${2:-}"
		shift 2
		;;
	*)
		break
		;;
	esac
done

binary="${1:-}"
label="${2:-$(basename "$binary" 2>/dev/null || echo unknown)}"
if [ -z "$binary" ] || { [ ! -f "$binary" ] && [ ! -d "$binary" ]; }; then
	echo "ERROR: libmpv binary not found: ${binary:-<empty>}" >&2
	exit 2
fi

failures=0

check() {
	group="$1"
	name="$2"
	needle="$3"
	if has "$needle"; then
		printf '  [PASS] %-42s %s\n' "$name" "$group"
	else
		printf '  [FAIL] %-42s %s\n' "$name" "$group" >&2
		failures=$((failures + 1))
	fi
}

echo "artifact: $label"

# The Darwin build ships libmpv as a set of dylibs (libmpv, libavcodec, libdav1d,
# ...), and the filter/Lua/codec symbols live in whichever of them the linker
# pulled them into. Scan every dylib in the tree and treat a hit in any of them
# as present.
scan_paths=""
if [ -d "$binary" ]; then
	# The Darwin xcframeworks packages rename each dylib into a framework
	# bundle (libavfilter.59.dylib -> Avfilter.framework/Versions/A/Avfilter),
	# so file names are not a reliable selector here. Scan every regular file;
	# grep only matches inside binaries that actually contain the needle.
	scan_paths=$(find "$binary" -type f -size +1k ! -name '*.h' ! -name '*.a' \
		! -name '*.modulemap' ! -name '*.plist' ! -name '*.json' ! -name '*.txt')
else
	scan_paths="$binary"
fi

has() {
	for path in $scan_paths; do
		if grep -aqF "$1" "$path"; then
			return 0
		fi
	done
	return 1
}

controls_failed=0
for control in h264 hevc aac mp3 equalizer overlay scale volume; do
	if has "$control"; then
		printf '  [PASS] %-42s %s\n' "$control" "positive control"
	else
		printf '  [FAIL] %-42s %s\n' "$control" "positive control" >&2
		controls_failed=$((controls_failed + 1))
	fi
done
if [ "$controls_failed" -ne 0 ]; then
	echo "SCAN BROKEN: $controls_failed positive control(s) missing; refusing to judge the build" >&2
	exit 3
fi

if [ "$expect_audio_only" -eq 0 ]; then
	for codec in h264 hevc av1 libdav1d vp9 vp8; do
		check "video codec" "$codec" "$codec"
	done
	for filter in loudnorm aresample dynaudnorm alimiter acompressor; do
		check "audio filter" "$filter" "$filter"
	done
fi

# stats.lua ships inside libmpv only when Lua is compiled in, and these are the
# bindings the app calls (simple_live_app/lib/modules/live_room/player/player_controller.dart).
# LuaJIT/Lua are statically linked and stripped, so their C symbols are not a
# usable signal; the embedded script is.
check "stats.lua" "display-stats-toggle" "display-stats-toggle"
check "stats.lua" "display-page-1-toggle" "display-page-1-toggle"

if [ -n "$config_log" ]; then
	if [ ! -f "$config_log" ]; then
		echo "ERROR: configure log not found: $config_log" >&2
		exit 2
	fi
	if grep -aq -- "--enable-parser=av1" "$config_log"; then
		printf '  [PASS] %-42s %s\n' "av1" "video parser (configure log)"
	else
		printf '  [FAIL] %-42s %s\n' "av1" "video parser (configure log)" >&2
		failures=$((failures + 1))
	fi
fi
# Some builds record the FFmpeg flags in a meson recipe rather than in a log the
# artifact ships. Accept those sources too so the parser check stays meaningful.
for source in $config_sources; do
	if [ ! -f "$source" ]; then
		echo "ERROR: config source not found: $source" >&2
		exit 2
	fi
	if grep -aq -- "enable-parser=av1" "$source"; then
		printf '  [PASS] %-42s %s\n' "av1" "video parser (build recipe)"
	else
		printf '  [FAIL] %-42s %s\n' "av1" "video parser (build recipe)" >&2
		failures=$((failures + 1))
	fi
done

if [ "$failures" -ne 0 ]; then
	echo "$failures requirement(s) missing" >&2
	exit 1
fi
echo "all requirements present"
