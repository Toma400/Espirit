import ../records
import ../parse

proc parseSKIL* (fr: var string): MWSkill =
  #[ Parses singel SKIL key of .esm/.esp files and returns it as MWSkill object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  if readStr(fr, 4) != "INDX":
    raise newException(ParseError, "No INDX field found for SKIL entry.")
  discard readStr(fr, 4) # loose bytes
  result.index = readUint32(fr)

  if readStr(fr, 4) != "SKDT":
    raise newException(ParseError, "No SKDT field found for SKIL entry: " & result.id)
  discard readStr(fr, 4) # loose bytes
  result.data = MWSkillData(attr: readUint32(fr),
                            spec: readUint32(fr),
                            usev: (readFloat32(fr),
                                   readFloat32(fr),
                                   readFloat32(fr),
                                   readFloat32(fr)))

  if len(fr) >= 4:
    if fr[0..3] == "DESC":
      discard readStr(fr, 4) # DESC
      discard readStr(fr, 4) # loose bytes
      result.descr = parseZString(fr)