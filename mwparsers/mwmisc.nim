import ../records
import ../parse

proc parseMISC* (fr: var string): MWMisc =
  #[ Parses singel MISC key of .esm/.esp files and returns it as MWMisc object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  if readStr(fr, 4) != "NAME":
    raise newException(Exception, "No NAME field found for MISC entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(Exception, "No MODL field found for MISC entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.model = parseZString(fr)

  if fr[0..3] == "FNAM":
    discard readStr(fr, 4) # FNAM
    discard readStr(fr, 4) # loose bytes
    result.name = parseZString(fr)

  if readStr(fr, 4) == "MCDT":
    discard readStr(fr, 4) # loose bytes
    result.data = MWMiscData(weight: readFloat32(fr, 4),
                             value:  readUint32(fr, 4),
                             unkn:   readUint32(fr, 4))
  else:
    raise newException(Exception, "No MCDT field found for MISC entry: " & result.id)

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