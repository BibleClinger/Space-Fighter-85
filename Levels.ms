// Each wave:
// - EnemyType
// - amount
// - can warp?
// - pre-delay
// - proceedNext: immediately, or post-time, or minimum enemy, or all enemies done 
// - scrollmessage

Wave = {}
Wave.Create = function(type, amount, distance, direction, warptrigger, predelay, scrollmessage, proceedNext, proceedArg=null)
    instance = new self
    instance.type = type
    instance.amount = amount
    instance.distance = distance
    instance.direction = direction
    instance.warptrigger = warptrigger
    instance.predelay = predelay
    instance.proceedNext = proceedNext
    instance.proceedArg = proceedArg
    instance.scrollmessage = scrollmessage
    return instance
end function

resolveDistance = function(distance)
    if distance == eSpawnDistanceType.FAR then
        return ceil(mathUtil.randRange(850-1,1000))
    else if distance == eSpawnDistanceType.MEDIUM then
        return ceil(mathUtil.randRange(650-1,850))
    else if distance == eSpawnDistanceType.NEAR then
        return ceil(mathUtil.randRange(400-1, 650))
    end if
end function

resolveDirection = function(direction)
    if direction == eSpawnDirectionType.FRONT then
        return {
            "x":ceil(mathUtil.randRange(0-1,game.SCREEN_WIDTH)),
            "y":ceil(mathUtil.randRange(0-1,game.SCREEN_HEIGHT)),
            "front":true,
        }
    else if direction == eSpawnDirectionType.SIDE then
        return {
            "x":ceil(mathUtil.randRange(0-1,game.SCREEN_WIDTH/4)),
            "y":ceil(mathUtil.randRange(0-1,game.SCREEN_HEIGHT/4)),
            "front":ceil(mathUtil.randRange(-1, 1)),
        }
    else
        return {
            "x":ceil(mathUtil.randRange(0,game.SCREEN_WIDTH)),
            "y":ceil(mathUtil.randRange(0-1,game.SCREEN_HEIGHT)),
            "front":false,
        }
    end if
end function
        


eLevelMode = bclib.Enum.Create("CAMPAIGN SURVIVAL")

//eSpawnGroupType = bclib.Enum.Create("GROUPED SPREAD")
eSpawnDistanceType = bclib.Enum.Create("FAR MEDIUM NEAR")
eSpawnDirectionType = bclib.Enum.Create("FRONT SIDE BEHIND")
eProceedType = bclib.Enum.Create("IMMEDIATE POSTDELAY MINENEMY")

mode = eLevelMode.CAMPAIGN
level = 0
wave = 0

Campaign = [// Level 1
    { 
        "planets": 0, "waves": [ Wave.Create(Enemy, 1, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, true, 5, "Scramble. Kill the enemy fighter!", eProceedType.MINENEMY, 0) ],
    },
    {   // Level 2
        "planets":0,
        "waves": [
            Wave.Create(Enemy, 1, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, "Scramble. Kill the enemy fighter!", eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 1, eSpawnDistanceType.FAR, eSpawnDirectionType.BEHIND, true, 5, "AMBUSH", eProceedType.MINENEMY, 0) ],
    },
    {   // Level 3
        "planets":1,
        "waves":
        [
            Wave.Create(Enemy, 2, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, "Two fighters.", eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 2, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, "Two more fighters.", eProceedType.MINENEMY, 0),
            Wave.Create(Satellite, 1, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, true, 5, "New target found. Enemy satellite...", eProceedType.MINENEMY, 0),
        ],
    },
    {   // Level 4
        "planets":2,
        "waves":
        [
            Wave.Create(Enemy, 3, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, "The enemy is sending a squadron!", eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 4, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 5, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Satellite, 1, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, true, 5, "No enemies. Good job.", eProceedType.POSTDELAY, 0),
        ],
    },
    {   // Level 5
        "planets":3,
        "waves":
        [
            Wave.Create(Enemy, 3, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, "Trxnsmixsixns dixficulxies..x", eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 4, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 5, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Satellite, 1, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 5, eSpawnDistanceType.FAR, eSpawnDirectionType.BEHIND, true, 5, "Five more.", eProceedType.MINENEMY, 0),
        ],
    },
    {
        // Level 6
        "planets":4,
        "waves":
        [    // Level 6
            Wave.Create(Enemy, 3, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, "Trxnsmixsixns dixficulxies..x", eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 4, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 5, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Satellite, 2, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 0, eSpawnDistanceType.FAR, eSpawnDirectionType.BEHIND, true, 5, "Scanning for enemies...", eProceedType.POSTDELAY, 5),
        ],
    },
    {
        // Level 7
        "planets":5,
        "waves":
        [
            Wave.Create(Enemy, 3, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, "Trxnsmixsixns dixficulxies..x", eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 4, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 0, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 5, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 0, null, eProceedType.MINENEMY, 0),
            Wave.Create(Satellite, 1, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 0, eSpawnDistanceType.FAR, eSpawnDirectionType.BEHIND, true, 5, "Scanning for enemies...", eProceedType.IMMEDIATE, 0),
            Wave.Create(Enemy, 3, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, "Enemies found...", eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 4, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 0, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 5, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 0, null, eProceedType.MINENEMY, 0),
            Wave.Create(Satellite, 1, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 0, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 0, eSpawnDistanceType.FAR, eSpawnDirectionType.BEHIND, true, 5, "Scanning for enemies...", eProceedType.IMMEDIATE, 0),
            Wave.Create(Enemy, 3, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, "Enemies found...", eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 4, eSpawnDistanceType.FAR, eSpawnDirectionType.SIDE, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 5, eSpawnDistanceType.FAR, eSpawnDirectionType.FRONT, false, 5, null, eProceedType.MINENEMY, 0),
            Wave.Create(Enemy, 0, eSpawnDistanceType.FAR, eSpawnDirectionType.BEHIND, true, 5, "Scanning for enemies...", eProceedType.POSTDELAY, 5),
        ],
    },
]

Survival = [

]
