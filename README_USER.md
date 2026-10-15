# Placeable LMGs — v0.8.3 test candidate

Turn a supported inventory LMG into a placeable, usable emplacement, then pack it up again.

## Requirements

- S.T.A.L.K.E.R. GAMMA with Demonized modded exes **2026.10.11**. Older executable versions are unsupported.
- **PKM:** available through GAMMA; supported base sections are wpn_pkm and wpn_pkm_siber.
- **MG42 only:** enable the **MG-42/MG-3 addon** from [Hisalute's Weapon Packs Repacked](https://www.moddb.com/mods/stalker-anomaly/addons/hisalutes-weapon-packs-repacked). The other weapon packs are not required. MG3 mounting is not supported.

Context Menu Overhaul is optional. Homestead, Hideout Furniture, Placeable Campfires, GT Emplacement and CtZ are not required. With Context Menu Overhaul, Mount appears at the bottom with its own icon.

## Installation

Install the ZIP through MO2 and enable Placeable LMGs. Replace your previous standalone package completely; do not enable two versions together. Back up your save first. Existing standalone 0.8.1/0.8.2 emplacement records are imported automatically without spawning replacement guns. Multiple-gun saves use a new record format. Before returning to an older release, pack up every gun, wait for transfers to finish, save and exit fully; an empty idle save is written in the older format.

Older CtZ builds with their own mounted-gun system cannot run this feature alongside PLMGs: PLMGs pauses to prevent duplicate handling. Pack up old CtZ guns using their original mod before switching. Clean CtZ 0.1.36 can coexist with standalone inventory placement; this release does not include the experimental CtZ API.

## Controls

1. Right-click a supported base gun in inventory and choose **Mount**. Inventory closes and a placement preview appears.
2. Aim at nearby, fairly level ground with clear standing space behind the gun. **Q/E** rotates the gun. **Use** confirms placement; **Escape** cancels and keeps your inventory gun.
3. Tap **Use** while looking at the emplacement to mount it. Use again to dismount.
4. While dismounted, look at the gun within 2.5 metres and **hold Use for 2.5 seconds** to pick it up. The prompt follows your bound Use key.

## Current limits

Multiple emplacements are supported, with one placement or pickup transfer at a time. Keep at least **1.5 metres between emplacements** to avoid overlapping tripods. Supported models are PKM and MG42. Upgraded weapons, attached accessories and the Zenit PKM variant cannot be converted. There is no separate mount item.

Pickup returns the original base weapon with its recorded condition and current remaining ammunition. Individual GAMMA weapon-part condition is not preserved. Incompatible loaded ammunition must be unloaded before placement. Reloading consumes compatible ammunition from the operator's inventory. Without ammunition, the gun stays empty. Save/load retains the emplacement and its ammunition. NPC operators are not included. Placement and mounting check standing space and headroom behind the gun; dismounting uses the same feet position instead of moving another half-metre backward. These conservative static checks cannot certify every collision with moving objects. If an exit becomes blocked, Use is refused with a message; native exit handling remains in charge.

Pack up your emplacement and finish any transfer before disabling or uninstalling the mod. Keep a backup save.

## Reporting problems

Include the weapon, what happened, your executable version and any reproduction steps. If present, attach `appdata/logs/plmg.log` and the main X-Ray log. PLMGs records failures only; normal play does not generate a verbose session log. The lack of a fresh plmg.log during successful play is expected.

## Credits

Mounted assemblies were prepared from the supplied Anomaly/GAMMA PKM and MG42 models with an adapted tripod. MG42 weapon, sound and texture assets are supplied by Hisalute's MG-42/MG-3 addon. Required third-party gun sounds and textures are not bundled here. Placeable Campfires and Context Menu Overhaul informed compatibility research; their scripts are not included.

## v0.8.3 test changes

Place several guns, including several of the same model. Aim at the particular gun you want to pick up; its original weapon, condition and current ammo are handled independently. A new placement or pickup waits for the previous inventory transfer to complete. The faster aiming, consuming reloads, quiet logs and conservative exit checks from 0.8.2 are retained. This multiple-emplacement candidate needs in-game testing before release.
