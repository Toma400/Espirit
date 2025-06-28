import ../records
import ../common
import ../parse

proc parseLEVI* (fr: var string): MWLeveledItem =
  #[ Parses single LEVI key of .esm/.esp files and returns it as MWLeveledItem object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for LEVI entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "DATA":
    raise newException(ParseError, "No DATA field found for LEVI entry.")
  discard readStr(fr, 4) # loose bytes
  result.data = readUint32(fr, 4)

  if readStr(fr, 4) != "NNAM":
    raise newException(ParseError, "No NNAM field found for LEVI entry.")
  discard readStr(fr, 4) # loose bytes
  result.nnam = readUint8(fr, 1)

  if len(fr) >= 4:
    if fr[0..3] == "INDX":
      discard readStr(fr, 4) # INDX
      discard readStr(fr, 4) # loose bytes
      result.count = readUint32(fr, 4)

  while true:
    if len(fr) >= 4:
      if fr[0..3] == "INAM":
        discard readStr(fr, 4) # INAM
        discard readStr(fr, 4) # loose bytes
        let item = parseZString(fr)

        if len(fr) >= 4:
          if fr[0..3] == "INTV":
            discard readStr(fr, 4) # INTV
            discard readStr(fr, 4) # loose bytes

            result.items.add((item, readUint16(fr, 2)))
            continue # makes every other break as "else"
          break
        break
      break
    break