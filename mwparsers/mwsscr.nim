import ../records
import ../common
import ../parse

proc parseSSCR* (fr: var string): MWStartScript =
  #[ Parses single SSCR key of .esm/.esp files and returns it as MWStartScript object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  if readStr(fr, 4) != "DATA":
    raise newException(ParseError, "No DATA field found for SSCR entry.")
  let length1 = int(readUint32(fr)) # 'loose bytes', or more precisely the length of the string here
  result.data = readStr(fr, length1)

  if readStr(fr, 4) != "NAME":
    raise newException(ParseError, "No NAME field found for SSCR entry.")
  let length2 = int(readUint32(fr)) # 'loose bytes', or more precisely the length of the string here
  result.name = readStr(fr, length2)