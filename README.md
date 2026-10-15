# Placeable LMGs 0.8.3 — bug-fix candidate

See [README_USER.md](README_USER.md) for player requirements, controls and limitations. The installable package contains only gamedata, FOMOD, meta.ini and that player guide. The experimental 0.8.2 CtZ API is not included.

This source branch retains tests, model-routing tools and private model hashes for maintenance; they are not installed. Adapted OGF models are omitted from the public repository and must be supplied separately. Third-party weapon sounds and textures are not bundled.

`python3 tools/package_release.py` builds the end-user ZIP and verifies its exact install contents. `python3 verification/check_build.py` runs lifecycle/preview/conversion/pickup and quiet-logging checks; `python3 verification/check_assets.py` validates profiles, prompt and assets. Native physics anchoring, ammo/condition transfer records, save keys, input duration and model geometry retain accepted 0.8.1 behavior. This candidate adds faster native aiming parameters, consuming reloads and conservative operator/exit clearance checks. Timed physics sampling and input tracing have been removed. Only failure/recovery messages are logged. Native tests of these fixes are pending. See docs/0.8.3-fixes.md.
