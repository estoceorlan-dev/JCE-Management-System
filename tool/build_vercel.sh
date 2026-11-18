#!/usr/bin/env bash
set -euo pipefail

required=(
  JCE_PUBLIC_ORIGIN
  JCE_DEPLOYMENT_ID
  JCE_ORGANIZATION_CODE
  JCE_OFFLINE_VERIFICATION_KEYS
  JCE_APPROVED_PRODUCTION_DEPLOYMENT_ID
)
for name in "${required[@]}"; do
  if [[ -z "${!name:-}" ]]; then
    echo "$name is required for the hosted web build." >&2
    exit 64
  fi
done

flutter_version="${JCE_FLUTTER_VERSION:-3.44.9}"
cache_root="${VERCEL_CACHE_DIR:-.vercel-cache}"
flutter_root="$cache_root/flutter-$flutter_version"
if [[ ! -x "$flutter_root/bin/flutter" ]]; then
  if [[ -e "$flutter_root" ]]; then
    echo "Cached Flutter SDK is incomplete; clear only $flutter_root and rebuild." >&2
    exit 70
  fi
  git clone --depth 1 --branch "$flutter_version" \
    https://github.com/flutter/flutter.git "$flutter_root"
fi

"$flutter_root/bin/flutter" config --no-analytics >/dev/null
"$flutter_root/bin/flutter" pub get --enforce-lockfile
profile_dir="$(mktemp -d .dart_tool/vercel-profile.XXXXXXXX)"
trap 'rm -f "$profile_dir/public.json"; rmdir "$profile_dir"' EXIT
"$flutter_root/bin/dart" run tool/hosted_web_profile.dart "$profile_dir/public.json"
"$flutter_root/bin/flutter" build web \
  --no-pub \
  --release \
  --no-web-resources-cdn \
  --no-source-maps \
  "--dart-define-from-file=$profile_dir/public.json" \
  "--dart-define=JCE_APPROVED_PRODUCTION_DEPLOYMENT_ID=$JCE_APPROVED_PRODUCTION_DEPLOYMENT_ID"
