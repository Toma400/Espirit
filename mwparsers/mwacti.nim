import ../records
import ../common

const field_key = "ACTI"

proc parseACTI* (fr: var string): MWActivator =
  #[ Parses single ACTI key of .esm/.esp files and returns it as MWActivator object ]#
  result.header = parseRecordHeader(fr)

  result.id     = requiredField[zstring](fr, "NAME", field_key)
  result.model  = requiredField[zstring](fr, "MODL", field_key)
  result.name   = optionalField[zstring](fr, "FNAM")
  result.script = optionalField[zstring](fr, "SCRI")