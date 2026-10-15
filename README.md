# Placeable LMGs 0.8.3 — multiple emplacements

Builds on user-accepted 0.8.2, with independent readiness/anchor identity and saved source/ammo/condition metadata per gun. The one-emplacement limit and global full-ID scan are removed. One inventory transaction and one preview still run at a time. Keep at least 1.5 metres between tripod roots. No NPC operator or CtZ API integration is added.

See README_USER.md for installation and docs/0.8.3-multiple.md for lifecycle/save boundaries. Tests and source model metadata remain outside the installable ZIP. Public source omits adapted models and third-party sound/gun textures. `tools/package_release.py` requires the two separately supplied prepared models.

Automated checks cover both native readiness entries, multiple guns of the same model, targeted pickup in a different order, cross-map persistence, legacy pending/active/returning imports, duplicate/invalid save records, failures retaining other guns, independent ammo/condition and safe empty-state downgrade. The user accepted the v0.8.3 candidate on 2026-10-15. The supplied X-Ray log shows multiple PKM and MG42 objects spawning, with no PLMG errors. This release promotes the tested runtime unchanged to end-user and experimental. The regression plan in TESTING.md retains additional edge cases; acceptance does not certify every listed scenario.
