import ../records
import ../parse

proc parseBODY* (fr: var string): MWBody =
  #[ Parses single BODY key of .esm/.esp files and returns it as MWBody object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for BODY entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(ParseError, "No MODL field found for BODY entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.model = parseZString(fr)

  if readStr(fr, 4) != "FNAM":
    raise newException(ParseError, "No FNAM field found for BODY entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.race = parseZString(fr)

  if readStr(fr, 4) != "BYDT":
    raise newException(ParseError, "No BYDT field found for BODY entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.data = MWBodyData(part: readUint8(fr), vampire: readUint8(fr), flags: readUint8(fr), pkind: readUint8(fr))