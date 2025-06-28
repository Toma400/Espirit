import ../records
import ../common
import ../parse

proc parseREPA* (fr: var string): MWRepairTool =
  #[ Parses single REPA key of .esm/.esp files and returns it as MWRepairTool object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for REPA entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(ParseError, "No MODL field found for REPA entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.model = parseZString(fr)

  if fr[0..3] == "FNAM":
    discard readStr(fr, 4) # FNAM
    discard readStr(fr, 4) # loose bytes
    result.name = parseZString(fr)

  if readStr(fr, 4) != "RIDT":
    raise newException(ParseError, "No RIDT field found for REPA entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.data = MWRepairToolData(weight:  readFloat32(fr),
                                 value:   readUint32(fr),
                                 uses:    readUint32(fr),
                                 quality: readFloat32(fr))

  if len(fr) >= 4:
    if fr[0..3] == "ITEX":
      discard readStr(fr, 4) # ITEX
      discard readStr(fr, 4) # loose bytes
      result.icon = parseZString(fr)

  if len(fr) >= 4:
    if fr[0..3] == "SCRI":
      discard readStr(fr, 4) # SCRI
      discard readStr(fr, 4) # loose bytes
      result.script = parseZString(fr)