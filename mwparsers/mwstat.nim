import ../records
import ../common
import ../parse

proc parseSTAT* (fr: var string): MWStatic =
  #[ Parses single STAT key of .esm/.esp files and returns it as MWStatic object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for STAT entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(ParseError, "No MODL field found for STAT entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.model = parseZString(fr)