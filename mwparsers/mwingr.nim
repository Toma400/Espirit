import ../records
import ../parse

proc parseINGR* (fr: var string): MWIngredient =
  #[ Parses singel INGR key of .esm/.esp files and returns it as MWIngredient object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for INGR entry.")
  discard readStr(fr, 4) # loose bytes
  result.id = parseZString(fr)

  if readStr(fr, 4) != "MODL":
    raise newException(ParseError, "No MODL field found for INGR entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.model = parseZString(fr)

  if fr[0..3] == "FNAM":
    discard readStr(fr, 4) # FNAM
    discard readStr(fr, 4) # loose bytes
    result.name = parseZString(fr)

  if readStr(fr, 4) == "IRDT":
    discard readStr(fr, 4) # loose bytes
    result.data = MWIngredientData(weight:   readFloat32(fr, 4),
                                   value:    readUint32(fr, 4),
                                   effindex: [readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4)],
                                   skill:    [readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4)],
                                   attr:     [readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4),
                                              readInt32(fr, 4)])
  else:
    raise newException(ParseError, "No IRDT field found for INGR entry: " & result.id)

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