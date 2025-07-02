import ../records
import ../common
import ../parse

const field_key = "MISC"

proc parseMISC* (fr: var string): MWMisc =
  #[ Parses single MISC key of .esm/.esp files and returns it as MWMisc object ]#
  # optional handling uses `fr[0..3]` for scouting, instead of `readStr`/other
  result.header = parseRecordHeader(fr)

  result.id    = requiredField[zstring](fr, "NAME", field_key)
  result.model = requiredField[zstring](fr, "MODL", field_key)
  result.name  = optionalField[zstring](fr, "FNAM")

  if objectField(fr, "MCDT", result.data, result.id):
    result.data = MWMiscData(weight: readFloat32(fr, 4),
                             value:  readUint32(fr, 4),
                             unkn:   readUint32(fr, 4))

  result.script = optionalField[zstring](fr, "SCRI")
  result.icon   = optionalField[zstring](fr, "ITEX")