import ../records
import ../common

const field_key = "BSGN"

proc parseBSGN* (fr: var string): MWBirthsign =
    #[ Parses single BSGN key of .esm/.esp files and returns it as MWBirthsign object ]#
    result.header = parseRecordHeader(fr)

    result.id      = requiredField[zstring](fr, "NAME", field_key)
    result.name    = optionalField[zstring](fr, "FNAM")
    result.texture = optionalField[zstring](fr, "TNAM")
    result.descr   = optionalField[zstring](fr, "DESC")
    result.spell   = repeatableField[array[32, char]](fr, "NPCS")