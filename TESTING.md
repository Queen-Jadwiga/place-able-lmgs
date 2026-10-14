# v0.8.0 test

Install independently of CtZ, on a backed-up ordinary GAMMA save. Restart fully. Use a base PKM or MG42 without installed upgrades/accessories. Keep the MG42 weapon addon enabled for MG42; GT disabled.

1. Right-click Mount; confirm automatic inventory closure and optional CMO bottom-row icon. Cancel once and verify gun/ammunition untouched.
2. Place on level ground, rotate Q/E, confirm Use. Original disappears only after mounted setup. Fire, dismount and check alignment; repeat an accepted elevated placement.
3. Look at the unoccupied converted gun within 2.5 m. Confirm the native two-line Mount / Hold Pickup prompt and bound key. Tap Use mounts on release; mounted Use exits normally. Hold Use for 2.5 seconds returns the base gun, its recorded condition and the spent ammo count.
4. Look away or move away during a hold: no pickup. Save/load resets incomplete holds. Pickup frees the one slot; remount and repeat with both guns.
5. Save after firing and after pickup, reload, and verify exactly one gun with no ammo refill. If possible save/load during transfer and check it resumes without duplication. Check no extra ammo boxes are generated.
6. Send plmg.log plus the main game log for failures: missing menu/tooltip, wrong timing, lost/duplicated item, condition/ammo mismatch, sagging or exit failure.

Old CtZ objects and free debug objects are not standalone pickup inputs. No addon-specific weapon-part state is restored. Missing dependencies or incompatible loaded ammo must preserve the inventory gun. Native timer/tooltip rendering and extracted-module operation are pending verification.
