import ../records
import ../parse

proc parseLTEX* (fr: var string): MWLandTexture =
  #[ Parses single LTEX key of .esm/.esp files and returns it as MWLandTexture object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for LTEX entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "INTV":
    raise newException(ParseError, "No INTV field found for LTEX entry.")
  discard readStr(fr, 4) # loose bytes
  result.index = readUint32(fr)

  if readStr(fr, 4) != "DATA":
    raise newException(ParseError, "No DATA field found for LTEX entry.")
  discard readStr(fr, 4) # loose bytes
  result.tex = parseZString(fr)
