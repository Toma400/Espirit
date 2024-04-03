import std/strformat

type
  MWClothData* = object
    kind*   : uint32  # type (please refer to `MWClothType` enum in type section below)
    weight* : float32 # weight
    value*  : uint16  # value
    ench*   : uint16  # enchantment points
  MWClothObj* = object
    biped* : uint8  # biped object (please refer to `MWClothBipedType` enum in type section below)
    mname* : string # male name for cloth (optional)
    fname* : string # female name for cloth (optional, `mname` used if absent)
  MWCloth* = object
    id*     : string          # ID
    model*  : string          # model name
    name*   : string = ""     # name (optional)
    script* : string = ""     # script name (optional)
    ench*   : string = ""     # enchantment name (optional)
    icon*   : string = ""     # icon name (optional)
    data*   : MWClothData
    objs*   : seq[MWClothObj] # objects (repeatable)

# Enum references
type
  MWClothType* = enum
    Pants      = 0
    Shoes      = 1
    Shirt      = 2
    Belt       = 3
    Robe       = 4
    RightGlove = 5
    LeftGlove  = 6
    Skirt      = 7
    Ring       = 8
    Amulet     = 9
  MWClothBipedType* = enum
    Head          = 1
    Hair          = 2
    Cuirass       = 3
    Groin         = 4
    Skirt         = 5
    RightHand     = 6
    LeftHang      = 7
    RightWrist    = 8
    LeftWrist     = 9
    Shield        = 10
    RightForearm  = 11
    LeftForearm   = 12
    RightUpperArm = 13
    LeftUpperArm  = 14
    RightFoot     = 15
    LeftFoot      = 16
    RightAnkle    = 17
    LeftAnkle     = 18
    RightKnee     = 19
    LeftKnee      = 20
    RightUpperLeg = 21
    LeftUpperLeg  = 22
    RightPauldron = 23
    LeftPauldron  = 24
    Weapon        = 25
    Tail          = 26

proc info* (record: MWCloth): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script: " & record.script)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Kind:   {record.data.kind} [{MWClothType(record.data.kind)}]
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """