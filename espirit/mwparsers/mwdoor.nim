import ../records
import ../common

const field_key = "DOOR"

proc parseDOOR* (fr: var string, header: MWRecordHeader): MWDoor =
    #[ Parses single DOOR key of .esm/.esp files and returns it as MWDoor object ]#
    setRecordData(result, header)

    result.id     = requiredField[zstring](fr, "NAME", field_key)
    result.model  = requiredField[zstring](fr, "MODL", field_key)
    result.name   = optionalField[zstring](fr, "FNAM")
    result.script = optionalField[zstring](fr, "SCRI")
    result.soundo = optionalField[zstring](fr, "SNAM")
    result.soundc = optionalField[zstring](fr, "ANAM")