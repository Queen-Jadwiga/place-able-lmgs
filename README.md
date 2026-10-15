# Placeable LMGs v0.8.2 Experimental

Place a base PKM or MG42 from inventory as a working stationary emplacement, then pack it back up. Supported inventory sections: `wpn_pkm`, GAMMA `wpn_pkm_siber`, and `wpn_mg42`. One emplacement at a time. Upgraded weapons, attached accessories and the Zenit PKM variant are excluded.

Right-click **Mount**; inventory closes automatically. Aim at nearby level ground and rotate with Q/E. Use confirms placement; Escape cancels. Once dismounted, tap Use to mount on release or **hold Use for 2.5 seconds to pick up**. Native interaction text reads `F Mount` with `Hold F Pickup` beneath it when Use is bound to F; it follows rebinding. While mounted, Use still dismounts normally.

Loaded rounds map by exact ammunition section without a free refill. Incompatible loaded ammunition blocks placement until the gun is unloaded. Pickup returns the original base weapon section with recorded condition and current remaining rounds. Individual GAMMA weapon-part data, upgrades and attachments are not restored. Transfer/pickup state survives saving, with descriptor/ownership checks and rollback before destructive steps. Ambiguous state suspends rather than fabricating a refund.

## Requirements and installation

Use a recent Monolith X-Ray modded executable with the new native stationary class `_S_STMGU`, DLTX `mod_system` loading, world visual attachments and the supplied `ui_inventory.UIInventory` property interface used by GAMMA. This targets the tested GAMMA setup; stock Anomaly/executable compatibility is not certified. For **MG42 support only**, install and enable the **MG-42/MG-3 addon** from [Hisalute's Weapon Packs Repacked](https://www.moddb.com/mods/stalker-anomaly/addons/hisalutes-weapon-packs-repacked). Only that addon from the pack is required; the other weapon packs are optional. It supplies the MG42 weapon, ammunition, sounds and textures. **PKM works with GAMMA alone**, without Hisalute's pack. The MG3 itself is not currently supported for mounting. PKM requires the effective GAMMA belt/AP ammo sections listed in `mod_system_plmg.ltx`. GT Emplacement is not needed and should remain disabled.

Install `Placeable_LMGs_0.8.2.zip` in MO2; its FOMOD installer displays **Placeable LMGs**. Alternatively, install the complete runtime ZIP manually, or put its `gamedata` folder in an isolated mod. Context Menu Overhaul is optional; when installed, Mount appears at the bottom with a dedicated tripod MG icon. Placeable Campfires and Hideout Furniture are not dependencies. No native, inventory or third-party addon script is overwritten.

**This public repository is source plus project-owned textures, not a complete asset distribution.** Adapted game models are omitted. A source checkout alone requires separately supplied `gamedata/meshes/plmg/mounted_pkm.ogf` and `mounted_mg42.ogf`. `tools/route_models.py` retargets already prepared private CtZ models without geometry/physics changes; it does not manufacture them from arbitrary inventory models. Model hashes are recorded in `PRIVATE_MODELS.json`. Obtain permission before publicly redistributing adapted game models; no third-party sound or gun texture assets are included.

## Compatibility and scope

Use this package independently of CtZ's legacy mounted-gun feature. Clean CtZ 0.1.36 removes that feature and can coexist with PLMGs. It owns `plmg_*` scripts, `plmg_transfer` save state and `plmg.log`. If CtZ's `ctz_mount_conversion` namespace is present, standalone event registration and entry are disabled to avoid duplicate handlers. Pack up CtZ guns before switching packages; CtZ saves/emplacements are not migrated to standalone IDs. Test standalone on an ordinary GAMMA save without CtZ mounted objects.

This package contains no CtZ campaign, economy, dialogue, faction-war logic, PDA or debug spawning. Models/profile definitions retain the tested native physics and distinct PKM/MG42 firing behavior. Dynamic obstacle clearance, multiple emplacements, NPC operators and additional LMG models are future work.

The inherited CtZ 0.1.34 behavior passed the user's native conversion/pickup test. The user accepted standalone 0.8.1, including the corrected native tooltip, after placement/pickup testing. The 0.8.2 API and combined CtZ startup need native testing. Automated verification: `python3 verification/check_build.py` (liblua5.4 required) runs 13 native lifecycle, 63 preview/menu, 40 conversion and 40 pickup/return fixture assertions; 9 scripts compile. Fixtures are not game-runtime proof.

## v0.8.1 tooltip fix

Correct the pickup script localization ID so the native prompt resolves to Mount and Hold Pickup rather than displaying a raw string ID. Tooltip references are checked against the shipped string table. Standalone diagnostics are written to `plmg.log`, not `ctz.log`. The user subsequently confirmed the standalone tooltip works.

## Experimental API v1

The released beta stays on main at 0.8.1; this 0.8.2 candidate lives on experimental. `plmg_api.describe()` reports API major 1, package version, availability and capabilities. `start_placement(item)` and `cancel_placement()` use the existing player preview/conversion path. API consumers must check availability/capabilities and handle refusal; no transfer records are public. The caller owns any inventory UI closure needed by its entry point. Scripted faction spawning, NPC operators, multiple guns and ownership/supply integration are not implemented.

CtZ 0.1.36's optional adapter observes only this interface. The older `ctz_mount_conversion` guard is deliberately retained for old CtZ or temporary recovery installs; clean CtZ does not ship that namespace. No CtZ-specific exception weakens the guard. Existing CtZ objects require pack-up under their old implementation before upgrading; PLMGs does not migrate them. API v1 adds no changes to gun physics, models, profiles or save schema.
