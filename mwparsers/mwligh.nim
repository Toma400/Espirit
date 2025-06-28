import ../records
import ../common
import ../parse

proc parseLIGH* (fr: var string): MWLight =
    #[ Parses singel LIGH key of .esm/.esp files and returns it as MWLight object ]#
    # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
    result.header = parseRecordHeader(fr)

    if readStr(fr, 4) != "NAME":
      raise newException(ParseError, "No NAME field found for LIGH entry.")
    discard readStr(fr, 4) # loose bytes
    result.id = parseZString(fr)

    if readStr(fr, 4) != "MODL":
      raise newException(ParseError, "No MODL field found for LIGH entry: " & result.id)
    discard readStr(fr, 4) # loose bytes
    result.model = parseZString(fr)

    if fr[0..3] == "FNAM":
      discard readStr(fr, 4) # FNAM
      discard readStr(fr, 4) # loose bytes
      result.name = parseZString(fr)

    if fr[0..3] == "ITEX":
      discard readStr(fr, 4) # ITEX
      discard readStr(fr, 4) # loose bytes
      result.icon = parseZString(fr)

    if readStr(fr, 4) == "LHDT":
      discard readStr(fr, 4) # loose bytes
      result.data = MWLightData(weight: readFloat32(fr, 4),
                                value:  readUint32(fr, 4),
                                time:   readInt32(fr, 4),
                                radius: readUint32(fr, 4),
                                color:  (readUint8(fr, 1), readUint8(fr, 1), readUint8(fr, 1), readUint8(fr, 1)),
                                flags:  readUint32(fr, 4))
    else:
      raise newException(ParseError, "No LHDT field found for LIGH entry: " & result.id)

    if len(fr) >= 4:
      if fr[0..3] == "SNAM":
        discard readStr(fr, 4) # SNAM
        discard readStr(fr, 4) # loose bytes
        result.sound = parseZString(fr)

    if len(fr) >= 4:
      if fr[0..3] == "SCRI":
        discard readStr(fr, 4) # SCRI
        discard readStr(fr, 4) # loose bytes
        result.script = parseZString(fr)