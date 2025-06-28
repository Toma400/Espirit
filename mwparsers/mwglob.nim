import ../records
import ../common
import ../parse

proc parseGLOB* (fr: var string): MWGlobal =
  #[ Parses single GLOB key of .esm/.esp files and returns it as MWGlobal object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for GLOB entry.")
  discard readStr(fr, 4) # loose bytes
  result.name = parseZString(fr)

  if readStr(fr, 4) != "FNAM":
    raise newException(ParseError, "No FNAM field found for GLOB entry: " & result.name)
  discard readStr(fr, 4) # loose bytes
  result.ftype = readChar(fr)

  if readStr(fr, 4) != "FLTV":
    raise newException(ParseError, "No FNAM field found for GLOB entry: " & result.name)
  discard readStr(fr, 4) # loose bytes
  result.value = readFloat32(fr)