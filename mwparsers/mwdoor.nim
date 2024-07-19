import ../records
import ../parse

proc parseDOOR* (fr: var string): MWDoor =
  #[ Parses single DOOR key of .esm/.esp files and returns it as MWDoor object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for DOOR entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(ParseError, "No MODL field found for DOOR entry: " & result.id)
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

  if fr.len >= 4:
    if fr[0..3] == "SNAM":
      discard readStr(fr, 4) # SCRI
      discard readStr(fr, 4) # loose bytes
      result.soundo = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "ANAM":
      discard readStr(fr, 4) # SCRI
      discard readStr(fr, 4) # loose bytes
      result.soundc = parseZString(fr)