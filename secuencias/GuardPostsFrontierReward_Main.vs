ObjList zone;
ObjList capitalList;
Unit u;
Building stateBuilding;
Building capitalForum;
int baseAX;
int baseAY;
int baseBX;
int baseBY;
int spawnX;
int spawnY;
int owner;
int i;
int army;
int rewarded;
int zoneId;
int checkIndex;
int sameOwner;
int CONTROL_INTERVAL;
int TROOP_LEVEL;
CONTROL_INTERVAL = 1000;
TROOP_LEVEL = 12;
while (1)
{
    Sleep(CONTROL_INTERVAL);
    for (zoneId = 1; zoneId <= 10; zoneId += 1)
    {
        zone.Clear();
        if (zoneId == 1)
        {
            zone = Group("RewardZone_01").GetObjList();
        }
        if (zoneId == 2)
        {
            zone = Group("RewardZone_02").GetObjList();
        }
        if (zoneId == 3)
        {
            zone = Group("RewardZone_03").GetObjList();
        }
        if (zoneId == 4)
        {
            zone = Group("RewardZone_04").GetObjList();
        }
        if (zoneId == 5)
        {
            zone = Group("RewardZone_05").GetObjList();
        }
        if (zoneId == 6)
        {
            zone = Group("RewardZone_06").GetObjList();
        }
        if (zoneId == 7)
        {
            zone = Group("RewardZone_07").GetObjList();
        }
        if (zoneId == 8)
        {
            zone = Group("RewardZone_08").GetObjList();
        }
        if (zoneId == 9)
        {
            zone = Group("RewardZone_09").GetObjList();
        }
        if (zoneId == 10)
        {
            zone = Group("RewardZone_10").GetObjList();
        }
        zone.ClearDead();
        if (zone.count < 2)
        {
            continue;
        }
        stateBuilding = zone[0].AsBuilding();
        owner = zone[0].player;
        sameOwner = 1;
        if (
            owner < 1
            ||
            owner > 8
        )
        {
            continue;
        }
        for (
            checkIndex = 1;
            checkIndex < zone.count;
            checkIndex += 1
        )
        {
            if (zone[checkIndex].player != owner)
            {
                sameOwner = 0;
            }
        }
        if (sameOwner == 0)
        {
            continue;
        }
        rewarded = 0;
        if (
            zoneId == 1
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ1_P1"
                );
        }
        if (
            zoneId == 1
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ1_P2"
                );
        }
        if (
            zoneId == 1
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ1_P3"
                );
        }
        if (
            zoneId == 1
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ1_P4"
                );
        }
        if (
            zoneId == 1
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ1_P5"
                );
        }
        if (
            zoneId == 1
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ1_P6"
                );
        }
        if (
            zoneId == 1
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ1_P7"
                );
        }
        if (
            zoneId == 1
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ1_P8"
                );
        }
        if (
            zoneId == 2
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ2_P1"
                );
        }
        if (
            zoneId == 2
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ2_P2"
                );
        }
        if (
            zoneId == 2
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ2_P3"
                );
        }
        if (
            zoneId == 2
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ2_P4"
                );
        }
        if (
            zoneId == 2
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ2_P5"
                );
        }
        if (
            zoneId == 2
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ2_P6"
                );
        }
        if (
            zoneId == 2
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ2_P7"
                );
        }
        if (
            zoneId == 2
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ2_P8"
                );
        }
        if (
            zoneId == 3
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ3_P1"
                );
        }
        if (
            zoneId == 3
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ3_P2"
                );
        }
        if (
            zoneId == 3
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ3_P3"
                );
        }
        if (
            zoneId == 3
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ3_P4"
                );
        }
        if (
            zoneId == 3
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ3_P5"
                );
        }
        if (
            zoneId == 3
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ3_P6"
                );
        }
        if (
            zoneId == 3
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ3_P7"
                );
        }
        if (
            zoneId == 3
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ3_P8"
                );
        }
        if (
            zoneId == 4
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ4_P1"
                );
        }
        if (
            zoneId == 4
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ4_P2"
                );
        }
        if (
            zoneId == 4
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ4_P3"
                );
        }
        if (
            zoneId == 4
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ4_P4"
                );
        }
        if (
            zoneId == 4
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ4_P5"
                );
        }
        if (
            zoneId == 4
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ4_P6"
                );
        }
        if (
            zoneId == 4
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ4_P7"
                );
        }
        if (
            zoneId == 4
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ4_P8"
                );
        }
        if (
            zoneId == 5
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ5_P1"
                );
        }
        if (
            zoneId == 5
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ5_P2"
                );
        }
        if (
            zoneId == 5
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ5_P3"
                );
        }
        if (
            zoneId == 5
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ5_P4"
                );
        }
        if (
            zoneId == 5
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ5_P5"
                );
        }
        if (
            zoneId == 5
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ5_P6"
                );
        }
        if (
            zoneId == 5
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ5_P7"
                );
        }
        if (
            zoneId == 5
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ5_P8"
                );
        }
        if (
            zoneId == 6
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ6_P1"
                );
        }
        if (
            zoneId == 6
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ6_P2"
                );
        }
        if (
            zoneId == 6
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ6_P3"
                );
        }
        if (
            zoneId == 6
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ6_P4"
                );
        }
        if (
            zoneId == 6
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ6_P5"
                );
        }
        if (
            zoneId == 6
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ6_P6"
                );
        }
        if (
            zoneId == 6
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ6_P7"
                );
        }
        if (
            zoneId == 6
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ6_P8"
                );
        }
        if (
            zoneId == 7
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ7_P1"
                );
        }
        if (
            zoneId == 7
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ7_P2"
                );
        }
        if (
            zoneId == 7
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ7_P3"
                );
        }
        if (
            zoneId == 7
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ7_P4"
                );
        }
        if (
            zoneId == 7
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ7_P5"
                );
        }
        if (
            zoneId == 7
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ7_P6"
                );
        }
        if (
            zoneId == 7
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ7_P7"
                );
        }
        if (
            zoneId == 7
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ7_P8"
                );
        }
        if (
            zoneId == 8
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ8_P1"
                );
        }
        if (
            zoneId == 8
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ8_P2"
                );
        }
        if (
            zoneId == 8
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ8_P3"
                );
        }
        if (
            zoneId == 8
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ8_P4"
                );
        }
        if (
            zoneId == 8
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ8_P5"
                );
        }
        if (
            zoneId == 8
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ8_P6"
                );
        }
        if (
            zoneId == 8
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ8_P7"
                );
        }
        if (
            zoneId == 8
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ8_P8"
                );
        }
        if (
            zoneId == 9
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ9_P1"
                );
        }
        if (
            zoneId == 9
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ9_P2"
                );
        }
        if (
            zoneId == 9
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ9_P3"
                );
        }
        if (
            zoneId == 9
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ9_P4"
                );
        }
        if (
            zoneId == 9
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ9_P5"
                );
        }
        if (
            zoneId == 9
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ9_P6"
                );
        }
        if (
            zoneId == 9
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ9_P7"
                );
        }
        if (
            zoneId == 9
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ9_P8"
                );
        }
        if (
            zoneId == 10
            &&
            owner == 1
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ10_P1"
                );
        }
        if (
            zoneId == 10
            &&
            owner == 2
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ10_P2"
                );
        }
        if (
            zoneId == 10
            &&
            owner == 3
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ10_P3"
                );
        }
        if (
            zoneId == 10
            &&
            owner == 4
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ10_P4"
                );
        }
        if (
            zoneId == 10
            &&
            owner == 5
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ10_P5"
                );
        }
        if (
            zoneId == 10
            &&
            owner == 6
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ10_P6"
                );
        }
        if (
            zoneId == 10
            &&
            owner == 7
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ10_P7"
                );
        }
        if (
            zoneId == 10
            &&
            owner == 8
        )
        {
            rewarded =
                EnvReadInt(
                    stateBuilding,
                    "GFR_RZ10_P8"
                );
        }
        if (rewarded == 1)
        {
            continue;
        }
        capitalList.Clear();
        if (owner == 1)
        {
            capitalList = Group("CapitalForum_P1").GetObjList();
        }
        if (owner == 2)
        {
            capitalList = Group("CapitalForum_P2").GetObjList();
        }
        if (owner == 3)
        {
            capitalList = Group("CapitalForum_P3").GetObjList();
        }
        if (owner == 4)
        {
            capitalList = Group("CapitalForum_P4").GetObjList();
        }
        if (owner == 5)
        {
            capitalList = Group("CapitalForum_P5").GetObjList();
        }
        if (owner == 6)
        {
            capitalList = Group("CapitalForum_P6").GetObjList();
        }
        if (owner == 7)
        {
            capitalList = Group("CapitalForum_P7").GetObjList();
        }
        if (owner == 8)
        {
            capitalList = Group("CapitalForum_P8").GetObjList();
        }
        capitalList.ClearDead();
        if (capitalList.count != 1)
        {
            continue;
        }
        capitalForum =
            capitalList[0]
            .AsBuilding();
        baseAX =
            capitalForum.pos.x
            +
            450;
        baseAY =
            capitalForum.pos.y
            -
            350;
        baseBX =
            capitalForum.pos.x
            -
            1450;
        baseBY =
            capitalForum.pos.y
            -
            350;
        for (army = 0; army < 2; army += 1)
        {
            if (army == 0)
            {
                spawnX = baseAX;
                spawnY = baseAY;
            }
            else
            {
                spawnX = baseBX;
                spawnY = baseBY;
            }
            if (owner == 1)
            {
                for (i = 0; i < 18; i += 1)
                {
                    u = Place("RHastatus", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 10; i += 1)
                {
                    u = Place("RArcher", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 8; i += 1)
                {
                    u = Place("RVelit", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 6; i += 1)
                {
                    u = Place("RPraetorian", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 7; i += 1)
                {
                    u = Place("RScout", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                u = Place("MHero1", capitalForum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                capitalForum.settlement.ForceAddUnit(u);
            }
            if (owner == 2)
            {
                for (i = 0; i < 18; i += 1)
                {
                    u = Place("CLibyanFootman", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 11; i += 1)
                {
                    u = Place("CJavelinThrower", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 8; i += 1)
                {
                    u = Place("CBerberAssassin", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 5; i += 1)
                {
                    u = Place("CNoble", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 7; i += 1)
                {
                    u = Place("CNumidianRider", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                u = Place("CHero1", capitalForum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                capitalForum.settlement.ForceAddUnit(u);
            }
            if (owner == 3)
            {
                for (i = 0; i < 17; i += 1)
                {
                    u = Place("IDefender", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 11; i += 1)
                {
                    u = Place("ISlinger", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 8; i += 1)
                {
                    u = Place("IMilitiaman", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 6; i += 1)
                {
                    u = Place("IEliteGuard", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 7; i += 1)
                {
                    u = Place("ICavalry", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                u = Place("IHero1", capitalForum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                capitalForum.settlement.ForceAddUnit(u);
            }
            if (owner == 4)
            {
                for (i = 0; i < 20; i += 1)
                {
                    u = Place("GWomanWarrior", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 11; i += 1)
                {
                    u = Place("GArcher", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 11; i += 1)
                {
                    u = Place("GAxeman", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 7; i += 1)
                {
                    u = Place("GHorseman", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                u = Place("GHero1", capitalForum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                capitalForum.settlement.ForceAddUnit(u);
            }
            if (owner == 5)
            {
                for (i = 0; i < 15; i += 1)
                {
                    u = Place("BBronzeSpearman", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 5; i += 1)
                {
                    u = Place("BHighlander", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 15; i += 1)
                {
                    u = Place("BBowman", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 14; i += 1)
                {
                    u = Place("BJavelineer", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                u = Place("BHero1", capitalForum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                capitalForum.settlement.ForceAddUnit(u);
            }
            if (owner == 6)
            {
                for (i = 0; i < 20; i += 1)
                {
                    u = Place("TMaceman", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 10; i += 1)
                {
                    u = Place("TArcher", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 12; i += 1)
                {
                    u = Place("THuntress", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 7; i += 1)
                {
                    u = Place("TTeutonRider", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                u = Place("THero1", capitalForum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                capitalForum.settlement.ForceAddUnit(u);
            }
            if (owner == 7)
            {
                for (i = 0; i < 18; i += 1)
                {
                    u = Place("RHastatus", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 10; i += 1)
                {
                    u = Place("RArcher", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 8; i += 1)
                {
                    u = Place("RGladiator", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 6; i += 1)
                {
                    u = Place("RTribune", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 7; i += 1)
                {
                    u = Place("RScout", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                u = Place("RHero1", capitalForum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                capitalForum.settlement.ForceAddUnit(u);
            }
            if (owner == 8)
            {
                for (i = 0; i < 19; i += 1)
                {
                    u = Place("EGuardian", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 10; i += 1)
                {
                    u = Place("EArcher", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 9; i += 1)
                {
                    u = Place("EAxetrower", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 5; i += 1)
                {
                    u = Place("EAnubisWarrior", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                for (i = 0; i < 6; i += 1)
                {
                    u = Place("EChariot", capitalForum.pos, owner);
                    u.SetLevel(TROOP_LEVEL);
                    capitalForum.settlement.ForceAddUnit(u);
                }
                u = Place("EHero1", capitalForum.pos, owner);
                u.SetLevel(TROOP_LEVEL);
                capitalForum.settlement.ForceAddUnit(u);
            }
        }
        if (
            zoneId == 1
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ1_P1",
                1
            );
        }
        if (
            zoneId == 1
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ1_P2",
                1
            );
        }
        if (
            zoneId == 1
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ1_P3",
                1
            );
        }
        if (
            zoneId == 1
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ1_P4",
                1
            );
        }
        if (
            zoneId == 1
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ1_P5",
                1
            );
        }
        if (
            zoneId == 1
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ1_P6",
                1
            );
        }
        if (
            zoneId == 1
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ1_P7",
                1
            );
        }
        if (
            zoneId == 1
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ1_P8",
                1
            );
        }
        if (
            zoneId == 2
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ2_P1",
                1
            );
        }
        if (
            zoneId == 2
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ2_P2",
                1
            );
        }
        if (
            zoneId == 2
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ2_P3",
                1
            );
        }
        if (
            zoneId == 2
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ2_P4",
                1
            );
        }
        if (
            zoneId == 2
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ2_P5",
                1
            );
        }
        if (
            zoneId == 2
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ2_P6",
                1
            );
        }
        if (
            zoneId == 2
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ2_P7",
                1
            );
        }
        if (
            zoneId == 2
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ2_P8",
                1
            );
        }
        if (
            zoneId == 3
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ3_P1",
                1
            );
        }
        if (
            zoneId == 3
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ3_P2",
                1
            );
        }
        if (
            zoneId == 3
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ3_P3",
                1
            );
        }
        if (
            zoneId == 3
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ3_P4",
                1
            );
        }
        if (
            zoneId == 3
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ3_P5",
                1
            );
        }
        if (
            zoneId == 3
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ3_P6",
                1
            );
        }
        if (
            zoneId == 3
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ3_P7",
                1
            );
        }
        if (
            zoneId == 3
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ3_P8",
                1
            );
        }
        if (
            zoneId == 4
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ4_P1",
                1
            );
        }
        if (
            zoneId == 4
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ4_P2",
                1
            );
        }
        if (
            zoneId == 4
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ4_P3",
                1
            );
        }
        if (
            zoneId == 4
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ4_P4",
                1
            );
        }
        if (
            zoneId == 4
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ4_P5",
                1
            );
        }
        if (
            zoneId == 4
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ4_P6",
                1
            );
        }
        if (
            zoneId == 4
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ4_P7",
                1
            );
        }
        if (
            zoneId == 4
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ4_P8",
                1
            );
        }
        if (
            zoneId == 5
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ5_P1",
                1
            );
        }
        if (
            zoneId == 5
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ5_P2",
                1
            );
        }
        if (
            zoneId == 5
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ5_P3",
                1
            );
        }
        if (
            zoneId == 5
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ5_P4",
                1
            );
        }
        if (
            zoneId == 5
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ5_P5",
                1
            );
        }
        if (
            zoneId == 5
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ5_P6",
                1
            );
        }
        if (
            zoneId == 5
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ5_P7",
                1
            );
        }
        if (
            zoneId == 5
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ5_P8",
                1
            );
        }
        if (
            zoneId == 6
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ6_P1",
                1
            );
        }
        if (
            zoneId == 6
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ6_P2",
                1
            );
        }
        if (
            zoneId == 6
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ6_P3",
                1
            );
        }
        if (
            zoneId == 6
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ6_P4",
                1
            );
        }
        if (
            zoneId == 6
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ6_P5",
                1
            );
        }
        if (
            zoneId == 6
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ6_P6",
                1
            );
        }
        if (
            zoneId == 6
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ6_P7",
                1
            );
        }
        if (
            zoneId == 6
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ6_P8",
                1
            );
        }
        if (
            zoneId == 7
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ7_P1",
                1
            );
        }
        if (
            zoneId == 7
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ7_P2",
                1
            );
        }
        if (
            zoneId == 7
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ7_P3",
                1
            );
        }
        if (
            zoneId == 7
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ7_P4",
                1
            );
        }
        if (
            zoneId == 7
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ7_P5",
                1
            );
        }
        if (
            zoneId == 7
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ7_P6",
                1
            );
        }
        if (
            zoneId == 7
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ7_P7",
                1
            );
        }
        if (
            zoneId == 7
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ7_P8",
                1
            );
        }
        if (
            zoneId == 8
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ8_P1",
                1
            );
        }
        if (
            zoneId == 8
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ8_P2",
                1
            );
        }
        if (
            zoneId == 8
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ8_P3",
                1
            );
        }
        if (
            zoneId == 8
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ8_P4",
                1
            );
        }
        if (
            zoneId == 8
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ8_P5",
                1
            );
        }
        if (
            zoneId == 8
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ8_P6",
                1
            );
        }
        if (
            zoneId == 8
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ8_P7",
                1
            );
        }
        if (
            zoneId == 8
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ8_P8",
                1
            );
        }
        if (
            zoneId == 9
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ9_P1",
                1
            );
        }
        if (
            zoneId == 9
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ9_P2",
                1
            );
        }
        if (
            zoneId == 9
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ9_P3",
                1
            );
        }
        if (
            zoneId == 9
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ9_P4",
                1
            );
        }
        if (
            zoneId == 9
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ9_P5",
                1
            );
        }
        if (
            zoneId == 9
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ9_P6",
                1
            );
        }
        if (
            zoneId == 9
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ9_P7",
                1
            );
        }
        if (
            zoneId == 9
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ9_P8",
                1
            );
        }
        if (
            zoneId == 10
            &&
            owner == 1
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ10_P1",
                1
            );
        }
        if (
            zoneId == 10
            &&
            owner == 2
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ10_P2",
                1
            );
        }
        if (
            zoneId == 10
            &&
            owner == 3
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ10_P3",
                1
            );
        }
        if (
            zoneId == 10
            &&
            owner == 4
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ10_P4",
                1
            );
        }
        if (
            zoneId == 10
            &&
            owner == 5
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ10_P5",
                1
            );
        }
        if (
            zoneId == 10
            &&
            owner == 6
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ10_P6",
                1
            );
        }
        if (
            zoneId == 10
            &&
            owner == 7
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ10_P7",
                1
            );
        }
        if (
            zoneId == 10
            &&
            owner == 8
        )
        {
            EnvWriteInt(
                stateBuilding,
                "GFR_RZ10_P8",
                1
            );
        }
    }
}
