import std/strformat
import std/strutils
import indexes

export indexes

const reserved_records* = [
  "ACTI", "ALCH", "APPA", "ARMO", "BODY", "BOOK", "BSGN", "CELL", "CLAS", "CLOT", "CONT", "CREA", "DIAL", "DOOR", "ENCH",
  "FACT", "GLOB", "GMST", "INFO", "INGR", "LAND", "LEVC", "LEVI", "LIGH", "LOCK", "LTEX", "MGEF", "MISC", "NPC_", "PGRD",
  "PROB", "RACE", "REGN", "REPA", "SCPT", "SKIL", "SNDG", "SOUN", "SPEL", "SSCR", "STAT", "TES3", "WEAP"
]

type
  MWClothData* = object
    kind*   : uint32  # type (please refer to `MWClothType` enum in type section below)
    weight* : float32 # weight
    value*  : uint16  # value
    ench*   : uint16  # enchantment points
  MWClothObj* = object
    #[ TODO: Is this a struct with `mname/fname`, or are those separate? Ref: https://en.uesp.net/wiki/Morrowind_Mod:Mod_File_Format/CLOT ]#
    biped* : uint8       # biped object (please refer to `MWClothBipedType` enum in type section below)
    mname* : string = "" # male name for cloth (optional)
    fname* : string = "" # female name for cloth (optional, `mname` used if absent)
  MWCloth* = object
    id*     : string          # ID
    model*  : string          # model name
    name*   : string = ""     # name (optional)
    script* : string = ""     # script name (optional)
    enchnm* : string = ""     # enchantment name (optional)
    icon*   : string = ""     # icon name (optional)
    data*   : MWClothData
    objs*   : seq[MWClothObj] # objects (repeatable)
  MWMiscData* = object
    weight* : float32 # weight
    value*  : uint32  # value
    unkn*   : uint32  # unknown field, only uses 0 and 1, but usually unused
  MWMisc* = object
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWMiscData
  MWStatic* = object
    id*    : string # ID
    model* : string # model name
  MWContainer* = object
    id*       : string      # ID
    model*    : string      # model name
    name*     : string = "" # name (optional)
    script*   : string = "" # script name (optional)
    weight*   : float32
    flags*    : uint32      # 0x1 = organic, 0x2 = respawns (organic only), 0x8 = unknown, always set
    contents* : seq[(int32, array[32, char])] # see if struct isn't better
  MWIngredientData* = object
    weight*   : float32         # weight
    value*    : uint32          # value
    effindex* : array[4, int32] # effect indexes
    skill*    : array[4, int32] # skill IDs
    attr*     : array[4, int32] # attribute IDs
  MWIngredient* = object
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWIngredientData
  MWBookData* = object
    weight* : float32 # weight
    value*  : uint32  # value
    flags*  : uint32  # if scroll or not
    skill*  : int32   # -1 if none
    ench*   : uint32  # enchantment points
  MWBook* = object
    id*     : string      # ID
    model*  : string      # model name
    name*   : string = "" # name (optional)
    script* : string = "" # script name (optional)
    enchnm* : string = "" # enchantment name (optional)
    text*   : string = "" # text contents (optional)
    icon*   : string = "" # icon name (optional)
    data*   : MWBookData
  MWLeveledItem* = object
    id*     : string      # ID
    data*   : uint32      # flags (0x1 = Calculate for each item in count | 0x2 = Calculate from all levels <= PC's level)
    nnam*   : uint8       # chance none?
    count*  : uint32 = 0  # count of following items (optional)
    items*  : seq[(string, uint16)] # (item name, PC level)

# Enum references
# type
#   MWClothType* = enum
#     Pants      = 0
#     Shoes      = 1
#     Shirt      = 2
#     Belt       = 3
#     Robe       = 4
#     RightGlove = 5
#     LeftGlove  = 6
#     Skirt      = 7
#     Ring       = 8
#     Amulet     = 9
#   MWClothBipedType* = enum
#     Head          = 1
#     Hair          = 2
#     Cuirass       = 3
#     Groin         = 4
#     Skirt         = 5
#     RightHand     = 6
#     LeftHang      = 7
#     RightWrist    = 8
#     LeftWrist     = 9
#     Shield        = 10
#     RightForearm  = 11
#     LeftForearm   = 12
#     RightUpperArm = 13
#     LeftUpperArm  = 14
#     RightFoot     = 15
#     LeftFoot      = 16
#     RightAnkle    = 17
#     LeftAnkle     = 18
#     RightKnee     = 19
#     LeftKnee      = 20
#     RightUpperLeg = 21
#     LeftUpperLeg  = 22
#     RightPauldron = 23
#     LeftPauldron  = 24
#     Weapon        = 25
#     Tail          = 26

type
  MWRecord* = MWCloth | MWMisc | MWStatic | MWIngredient | MWContainer | MWBook | MWLeveledItem

type
  ParseError* = object of Exception

proc `$`* (record: MWRecord): string =
    result = record.id

proc `$`* (clobj: MWClothObj): string =
    result = fmt"{clobj.biped}: {MWClothBipedType(clobj.biped)} | {clobj.mname}, {clobj.fname}"

proc info* (record: MWCloth): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.enchnm != "":
      options.add("\n    Enchant: " & record.enchnm)
    if record.objs.len > 0:
      options.add("\n    Objects:")
      for obj in record.objs:
        options.add("\n    - " & $obj)
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

proc info* (record: MWMisc): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """

proc info* (record: MWIngredient): string =
    var options = ""
    var effects = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    for c, ef in record.data.effindex:
      if ef != -1:
        var sk = ""
        var at = ""
        if record.data.skill[c] > 0: sk = fmt"[SkillIndex:     {record.data.skill[c]}]"
        if record.data.attr[c]  > 0: at = fmt"[AttributeIndex: {record.data.attr[c]}]"
        effects.add("\n      - " & fmt"{ef} [{MWEffectType(ef)}] {sk}{at}")
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
      Effects:    {effects}
    ====={options}
    """

proc info* (record: MWContainer): string =
    proc getID(a: array[32, char]): string =
      for i in a:
        if i != '\0': result.add(i)

    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.contents.len > 0:
      options.add("\n    Contents:")
      for it in record.contents:
        options.add("\n" & fmt"    - {it[1].getID} [{it[0]}]")
    # TODO: lacks some flags info
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    =====
      Weight: {record.weight}
    ====={options}
    """

proc info* (record: MWBook): string =
    var options = ""
    if record.script != "":
      options.add("\n    Script:  " & record.script)
    if record.enchnm != "":
      options.add("\n    Enchant: " & record.enchnm)
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Weight: {record.data.weight}
      Value:  {record.data.value}
    ====={options}
    """
    # TODO: Not all values added

proc read* (record: MWBook): string =
    proc mwFormat(r: string): string =
      result = r
      result = result.replace("<br>", "\n")
      result = result.replace("<BR>", "\n")

    return mwFormat(record.text)

proc info* (record: MWLeveledItem): string =
    var items = ""
    if record.count > 0:
      items.add("\n    Count: " & $record.count)
    if record.items.len > 0:
      items.add("\n    Items:")
    for i in record.items:
      items.add("\n    - " & fmt"{i[0]}: {i[1]}")
    result = fmt"""
    ID:    {record.id}
    ====={items}
    =====
    """