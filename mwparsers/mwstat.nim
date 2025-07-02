import ../records
import ../common

const field_key = "STAT"

proc parseSTAT* (fr: var string): MWStatic =
  #[ Parses single STAT key of .esm/.esp files and returns it as MWStatic object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  result.id    = requiredField[zstring](fr, "NAME", field_key)
  result.model = requiredField[zstring](fr, "MODL", field_key)