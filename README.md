# Placeable LMGs 0.8.1 beta — end-user cleanup

See [README_USER.md](README_USER.md) for player requirements, controls and limitations. The installable package contains only gamedata, FOMOD, meta.ini and that player guide. The experimental 0.8.2 CtZ API is not included.

This source branch retains tests, model-routing tools and private model hashes for maintenance; they are not installed. Adapted OGF models are omitted from the public repository and must be supplied separately. Third-party weapon sounds and textures are not bundled.

`python3 tools/package_release.py` builds the end-user ZIP and verifies its exact install contents. `python3 verification/check_build.py` runs lifecycle/preview/conversion/pickup and quiet-logging checks; `python3 verification/check_assets.py` validates profiles, prompt and assets. Native physics, ammo/condition transactions, save keys, input duration and prepared model geometry retain 0.8.1 behavior. Timed physics sampling and input tracing have been removed. Only failure/recovery messages are logged. A native smoke test of this cleanup is pending; main remains the accepted 0.8.1 beta.
