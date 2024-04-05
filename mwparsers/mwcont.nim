import ../records
import ../parse

proc parseCONT* (fr: var string): MWContainer =
  #[ Parses singel MISC key of .esm/.esp files and returns it as MWMisc object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  if readStr(fr, 4) != "NAME":
    raise newException(Exception, "No NAME field found for CONT entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(Exception, "No MODL field found for CONT entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.model = parseZString(fr)

  if fr[0..3] == "FNAM":
    discard readStr(fr, 4) # FNAM
    discard readStr(fr, 4) # loose bytes
    result.name = parseZString(fr)

  if readStr(fr, 4) != "CNDT":
    raise newException(Exception, "No CNDT field found for CONT entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.weight = readFloat32(fr, 4)

  if readStr(fr, 4) != "FLAG":
    raise newException(Exception, "No FLAG field found for CONT entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.flags = readUint32(fr, 4)

  while true:
    if len(fr) >= 4:
      if fr[0..3] == "NPCO":
        proc makeArray(size: static int, frb: var string): array[size, char] =
          for x in result.mitems:
            x = readChar(frb)

        discard readStr(fr, 4) # NPCO
        discard readStr(fr, 4) # loose bytes
        result.contents.add((readInt32(fr, 4), makeArray(32, fr)))

    if len(fr) >= 4:
      if fr[0..3] == "NPCO":
        continue
    break # if nothing, SCRI or new record is found

  if len(fr) >= 4:
    if fr[0..3] == "SCRI":
      discard readStr(fr, 4) # SCRI
      discard readStr(fr, 4) # loose bytes
      result.script = parseZString(fr)