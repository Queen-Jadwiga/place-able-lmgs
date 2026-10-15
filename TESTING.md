# 0.8.2 native test plan

Use full restart and backed-up standalone saves. This is a candidate, not a verified fix release. Test both PKM and MG42; MG42 requires Hisalute's MG-42/MG-3 addon.

1. On open level ground, check preview, rotation and confirmation. Sweep aim left/right/up/down; compare the new 90-degree horizontal / 60-degree vertical per-second speeds against the old native defaults of 10.
2. Remove ALL compatible ammunition from inventory, including other quality variants. Mount an empty gun, press Reload repeatedly, dismount and pick up: magazine must remain empty and no ammunition may appear. Repeat with a partially loaded gun; reload must not increase count without inventory ammo.
3. Carry a known small amount (e.g. 17 rounds) of one compatible type; reload from empty. Compare total ammunition in inventory plus gun before/after. Only supplied rounds may be loaded. Test a full belt and residual boxes; test original ammo and another supported type, then pack up. Total rounds must be conserved.
4. Save/load with empty, partial and full magazines. Counts must not refill on loading, mounting or dismounting. Repeat pickup and remount conversion.
5. Place next to a wall, doorway, low ceiling, step and ledge. Clear operator space behind the gun is required; rotation changes that checked space. Unsafe placements should not show a valid preview or consume inventory. Existing unsafe guns can still be packed up and repositioned.
6. Test repeated native exits in open areas, at elevation and near the previously problematic doorway. Exit should remain at the operator's feet rather than half a metre behind. If static geometry obstructs the exit before Use, it should be refused with a message. Do not force a blocked exit. Moving-object collisions and unusual map geometry still require investigation.
7. Report any underground movement, launch, stuck operator, rejected reasonable placement, free ammunition or loss/duplication. Include plmg.log if generated and the X-Ray log. The quiet end-user package does not produce routine physics dumps.
