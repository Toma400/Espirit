import ../records
import ../common
import ../parse

const field_key = "CELL"

proc parseCELL* (fr: var string): MWCell =
    #[ Parses single CELL key of .esm/.esp files and returns it as MWCell object ]#
    result.header = parseRecordHeader(fr)

    result.name  = requiredField[zstring](fr, "NAME", field_key)

    if objectField(fr, "DATA", result.data, result.name):
      result.data = MWCellData(flags:  readUint32(fr),
                               grid_x: readInt32(fr),
                               grid_y: readInt32(fr))

    result.region = optionalField[zstring](fr, "RGNN")
    result.mapcol = optionalField[rgb](fr, "NAM5")
    result.waterh = optionalField[float32](fr, "WHGT")

    if objectField(fr, "AMBI", result.light, result.name):
      result.light = MWAmbientLight(ambcol: readRGB(fr),
                                    suncol: readRGB(fr),
                                    fogcol: readRGB(fr),
                                    fogden: readFloat32(fr))
