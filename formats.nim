import std/tables
import records
import parse

proc parseZString(fr: var string): string =
    #[ Reads from string pseudo-stream until finds end of string ]#
    while true:
      let o = readChar(fr)
      if o != '\0':
        result.add(o)
      else: break

proc parseMAST* (fr: var string, tabl: var OrderedTable[string, uint64]) =
    #[ Parses single MAST key of .esm/.esp files and adds it to `tabl` ]#
    discard readStr(fr, 4) # loose bytes
    var mast_name = parseZString(fr)

    if readStr(fr, 4) != "DATA":
      raise newException(Exception, "No byte length found for master file: " & mast_name)
    discard readStr(fr, 4) # loose bytes

    tabl[mast_name] = readUint64(fr, 4)

proc parseCLOT* (fr: var string): MWCloth =
    #[ Parses singel CLOT key of .esm/.esp files and returns it as MWCloth object ]#
    # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
    discard readStr(fr, 12) # loose bytes

    if readStr(fr, 4) != "NAME":
      raise newException(Exception, "No NAME field found for CLOT entry.")
    discard readStr(fr, 4) # loose bytes
    result.id = parseZString(fr)

    if readStr(fr, 4) != "MODL":
      raise newException(Exception, "No MODL field found for CLOT entry: " & result.id)
    discard readStr(fr, 4) # loose bytes
    result.model = parseZString(fr)

    if fr[0..3] == "FNAM":
      discard readStr(fr, 4) # FNAM
      discard readStr(fr, 4) # loose bytes
      result.name = parseZString(fr)

    if readStr(fr, 4) == "CTDT":
      discard readStr(fr, 4) # loose bytes
      result.data = MWClothData(kind:   readUint32(fr, 4),
                                weight: readFloat32(fr, 4),
                                value:  readUint16(fr, 2),
                                ench:   readUint16(fr, 2))
    else:
      raise newException(Exception, "No CTDT field found for CLOT entry: " & result.id)

    # ==================
      # TODO
      # - INDX/BNAM/CNAM
      # - ENAM
    # ==================
    result.ench   = ""

    if len(fr) >= 4:
      if fr[0..3] == "SCRI":
        discard readStr(fr, 4) # SCRI
        discard readStr(fr, 4) # loose bytes
        result.script = parseZString(fr)

    if len(fr) >= 4:
      if fr[0..3] == "ITEX":
        discard readStr(fr, 4) # ITEX
        discard readStr(fr, 4) # loose bytes
        result.icon = parseZString(fr)
