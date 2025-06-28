import ../records
import ../common
import ../parse

proc parseBOOK* (fr: var string): MWBook =
  #[ Parses single BOOK key of .esm/.esp files and returns it as MWBook object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for BOOK entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(ParseError, "No MODL field found for BOOK entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.model = parseZString(fr)

  if fr[0..3] == "FNAM":
    discard readStr(fr, 4) # FNAM
    discard readStr(fr, 4) # loose bytes
    result.name = parseZString(fr)

  if readStr(fr, 4) == "BKDT":
    discard readStr(fr, 4) # loose bytes
    result.data = MWBookData(weight:   readFloat32(fr, 4),
                             value:    readUint32(fr, 4),
                             flags:    readUint32(fr, 4),
                             skill:    readInt32(fr, 4),
                             ench:     readUint32(fr, 4))
  else:
    raise newException(ParseError, "No BKDT field found for BOOK entry: " & result.id)

  if fr.len >= 4:
    if fr[0..3] == "SCRI":
      discard readStr(fr, 4) # SCRI
      discard readStr(fr, 4) # loose bytes
      result.script = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "ITEX":
      discard readStr(fr, 4) # ITEX
      discard readStr(fr, 4) # loose bytes
      result.icon = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "TEXT":
      discard readStr(fr, 4) # TEXT
      let length = readUint8(fr, 1).int # length of string
      discard readStr(fr, 3) # loose bytes
      result.text = readStr(fr, length)

  if fr.len >= 4:
    if fr[0..3] == "ENAM":
      discard readStr(fr, 4) # ENAM
      discard readStr(fr, 4) # loose bytes
      result.enchnm = parseZString(fr)