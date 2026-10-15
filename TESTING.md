# 0.8.3 multi-emplacement native test

Back up an ordinary standalone 0.8.2 save. Restart fully with this candidate only, without old CtZ mounted code or recovery. Keep the backup if returning to 0.8.2.

1. Begin with an existing 0.8.2 emplacement, if possible. Load and confirm its original ammo, model, mounting and pickup are retained. No replacement object or extra inventory gun should appear.
2. Place PKM, MG42 and another PKM at least 1.5 m apart, with distinct ammo counts (e.g. 11, 23, 37) and conditions. Both same-model guns must remain individually usable; placing the next gun must not disable earlier guns. A coincident/too-close placement must be refused without consuming inventory.
3. Mount, fire/reload and dismount each. Total ammo must be conserved with/without compatible inventory ammunition. Verify the existing aiming/exit fixes, including nearby geometry and elevated floors.
4. Save/load with all three placed. Each keeps its own count. Travel to another map and back if practical; offline guns must remain recorded and recoverable.
5. Pick up the middle gun first, then another, leaving one placed. The aimed-at gun must disappear and return its correct base section, recorded condition and current ammunition. Other guns must remain usable. Place another gun while one remains.
6. Save/load during placement/pickup if practical. There must be no repeated inventory consumption, duplicate refund, free refill, or other gun disappearance. Only one transfer may run at a time.
7. Pack every gun, wait for completion, save and exit. This idle save should be readable again by 0.8.2; do not downgrade while guns or transfers remain.
8. Send X-Ray log and plmg.log if generated for failures, along with which guns were placed/picked up and counts before/after. Native multi-emplacement acceptance is pending.
