# Placeable LMGs — v0.8.3 beta

Turn a supported inventory LMG into a placeable, usable emplacement, then pack it up again.

## Requirements

- S.T.A.L.K.E.R. GAMMA with Demonized modded exes **2026.10.11**. Older executable versions are unsupported.
- **PKM:** available through GAMMA; supported base sections are wpn_pkm and wpn_pkm_siber.
- **MG42 only:** enable the **MG-42/MG-3 addon** from [Hisalute's Weapon Packs Repacked](https://www.moddb.com/mods/stalker-anomaly/addons/hisalutes-weapon-packs-repacked). The other weapon packs are not required. MG3 mounting is not supported.

Context Menu Overhaul is optional. Homestead, Hideout Furniture, Placeable Campfires, GT Emplacement and CtZ are not required. With Context Menu Overhaul, Mount appears at the bottom with its own icon.

## Installation

Install the ZIP through MO2 and enable Placeable LMGs. Replace your previous standalone package completely; do not enable two versions together. Existing standalone 0.8.1 saves use the same weapon sections and save format.

Older CtZ builds with their own mounted-gun system cannot run this feature alongside PLMGs: PLMGs pauses to prevent duplicate handling. Pack up old CtZ guns using their original mod before switching. Clean CtZ 0.1.36 can coexist with standalone inventory placement; this release does not include the experimental CtZ API.

## Controls

1. Right-click a supported base gun in inventory and choose **Mount**. Inventory closes and a placement preview appears.
2. Aim at nearby, fairly level ground with clear standing space behind the gun. **Q/E** rotates the gun. **Use** confirms placement; **Escape** cancels and keeps your inventory gun.
3. Tap **Use** while looking at the emplacement to mount it. Use again to dismount.
4. While dismounted, look at the gun within 2.5 metres and **hold Use for 2.5 seconds** to pick it up. The prompt follows your bound Use key.

## Current limits

One emplacement at a time. Supported models are PKM and MG42. Upgraded weapons, attached accessories and the Zenit PKM variant cannot be converted. There is no separate mount item.

Pickup returns the original base weapon with its recorded condition and current remaining ammunition. Individual GAMMA weapon-part condition is not preserved. Incompatible loaded ammunition must be unloaded before placement. Reloading consumes compatible ammunition from the operator's inventory. Without ammunition, the gun stays empty. Save/load retains the emplacement and its ammunition. NPC operators are not included. Placement and mounting check standing space and headroom behind the gun; dismounting uses the same feet position instead of moving another half-metre backward. These conservative static checks cannot certify every collision with moving objects. If an exit becomes blocked, Use is refused with a message; native exit handling remains in charge.

Pack up your emplacement and finish any transfer before disabling or uninstalling the mod. Keep a backup save.

## Reporting problems

Include the weapon, what happened, your executable version and any reproduction steps. If present, attach `appdata/logs/plmg.log` and the main X-Ray log. PLMGs records failures only; normal play does not generate a verbose session log. The lack of a fresh plmg.log during successful play is expected.

## Credits

Mounted assemblies were prepared from the supplied Anomaly/GAMMA PKM and MG42 models with an adapted tripod. MG42 weapon, sound and texture assets are supplied by Hisalute's MG-42/MG-3 addon. Required third-party gun sounds and textures are not bundled here. Placeable Campfires and Context Menu Overhaul informed compatibility research; their scripts are not included.

## v0.8.3 test candidate

Turret tracking increased from the native 10-degree/second defaults to 90 degrees/second horizontally and 60 vertically. Reloads now consume inventory ammunition instead of generating belts. Exit offset is aligned with the operating position, with standing/exit clearance checks. Full restart required; reposition existing guns if the new checks refuse entry. This candidate needs native testing before public promotion.
