import ../records
import ../common
import ../parse

proc parseACTI* (fr: var string): MWActivator =
  #[ Parses single ACTI key of .esm/.esp files and returns it as MWActivator object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for ACTI entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(ParseError, "No MODL field found for ACTI entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.model = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "FNAM":
      discard readStr(fr, 4) # FNAM
      discard readStr(fr, 4) # loose bytes
      result.name = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "SCRI":
      discard readStr(fr, 4) # SCRI
      discard readStr(fr, 4) # loose bytes
      result.script = parseZString(fr)