import ../records
import ../common
import ../parse

const field_key = "RACE"

proc parseRACE* (fr: var string): MWRace =
  #[ Parses single STAT key of .esm/.esp files and returns it as MWStatic object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  result.id   = requiredField[zstring](fr, "NAME", field_key)
  result.name = optionalField[zstring](fr, "FNAM")

