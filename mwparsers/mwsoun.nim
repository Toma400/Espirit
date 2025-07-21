import ../records
import ../common
import ../parse

const field_key = "SOUN"

proc parseSOUN* (fr: var string): MWSound =
    #[ Parses single SOUN key of .esm/.esp files and returns it as MWSound object ]#
    result.header = parseRecordHeader(fr, result)

    result.id    = requiredField[zstring](fr, "NAME", field_key)
    result.fname = requiredField[zstring](fr, "FNAM", field_key)

    if objectField(fr, "DATA", result.data, result.id):
      result.data = MWSoundData(volume:    readUint8(fr),
                                range_min: readUint8(fr),
                                range_max: readUint8(fr))