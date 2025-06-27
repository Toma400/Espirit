import ../records
import ../parse

proc parseSCPT* (fr: var string): MWScript =
  #[ Parses single SCPT key of .esm/.esp files and returns it as MWScript object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  discard readStr(fr, 12) # loose bytes

  if readStr(fr, 4) != "SCHD":
    raise newException(ParseError, "No SCHD field found for SCPT entry.")
  discard readStr(fr, 4) # loose bytes
  result.header = MWScriptHeader(name:     read32Chars(fr),
                                 numshort: readUint32(fr),
                                 numlong:  readUint32(fr),
                                 numfloat: readUint32(fr),
                                 size_sdt: readUint32(fr),
                                 size_lvr: readUint32(fr))

  if len(fr) >= 4:
    if fr[0..3] == "SCVR":
      discard readStr(fr, 4) # SCVR
      discard readStr(fr, 4) # loose bytes
      # raw string copy
      let raw = fr[0..result.header.size_lvr-1]
      var ssh = newSeq[string]()
      var slg = newSeq[string]()
      var sfl = newSeq[string]()

      # concrete values
      if result.header.numshort > 0:
        for _ in 1..result.header.numshort:
          ssh.add(parseZString(fr))
      if result.header.numlong > 0:
        for _ in 1..result.header.numlong:
          slg.add(parseZString(fr))
      if result.header.numfloat > 0:
        for _ in 1..result.header.numfloat:
          sfl.add(parseZString(fr))

      # putting all elements in struct
      result.vars = MWScriptVariables(raw:    raw,
                                      shorts: ssh,
                                      longs:  slg,
                                      floats: sfl)

  if len(fr) >= 4:
    if fr[0..3] == "SCDT":
      discard readStr(fr, 4) # SCDT
      discard readStr(fr, 4) # loose bytes
      for _ in 1..result.header.size_sdt:
        result.cdata.add(readUint8(fr))

  if len(fr) >= 4:
    if fr[0..3] == "SCTX":
      discard readStr(fr, 4)           # SCDT
      let length = int(readUint32(fr)) # 'loose bytes', or more precisely the length of the string here
      result.text = readStr(fr, length)