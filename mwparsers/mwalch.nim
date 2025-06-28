import ../records
import ../common
import ../parse

proc parseALCH* (fr: var string): MWPotion =
  #[ Parses single ALCH key of .esm/.esp files and returns it as MWPotion object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for ALCH entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "MODL":
      discard readStr(fr, 4) # MODL
      discard readStr(fr, 4) # loose bytes
      result.model = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "TEXT":
      discard readStr(fr, 4) # TEXT
      discard readStr(fr, 4) # loose bytes
      result.icon = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "SCRI":
      discard readStr(fr, 4) # SCRI
      discard readStr(fr, 4) # loose bytes
      result.script = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "FNAM":
      discard readStr(fr, 4) # FNAM
      discard readStr(fr, 4) # loose bytes
      result.name = parseZString(fr)

  if fr.len >= 4:
    if fr[0..3] == "ALDT":
      discard readStr(fr, 4) # ALDT
      discard readStr(fr, 4) # loose bytes
      result.data = MWPotionData(weight: readFloat32(fr),
                                 value:  readUint32(fr),
                                 flags:  readUint32(fr))

  while true:
    if len(fr) >= 4:
      if fr[0..3] == "ENAM":
        discard readStr(fr, 4) # ENAM
        discard readStr(fr, 4) # loose bytes
        result.ench.add(MWPotionEnch(effindex: readUint16(fr),
                                     skill:    readInt8(fr),
                                     attr:     readInt8(fr),
                                     range:    readUint32(fr),
                                     area:     readUint32(fr),
                                     duration: readUint32(fr),
                                     mmin:     readUint32(fr),
                                     mmax:     readUint32(fr)))

      break # if not ENAM anymore
