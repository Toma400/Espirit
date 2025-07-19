import ../records
import ../common
import ../parse

const field_key = "CLAS"

proc parseCLAS* (fr: var string): MWClass =
    #[ Parses single CLAS key of .esm/.esp files and returns it as MWClass object ]#
    result.header = parseRecordHeader(fr)

    result.id   = requiredField[zstring](fr, "NAME", field_key)
    result.name = requiredField[zstring](fr, "FNAM", field_key)

    if objectField(fr, "CLDT", result.data, result.id):
      result.data = MWClassData(attr:    [readUint32(fr), readUint32(fr)],
                                spec:    readUint32(fr),
                                skill:   [
                                    [readUint32(fr), readUint32(fr)],
                                    [readUint32(fr), readUint32(fr)],
                                    [readUint32(fr), readUint32(fr)],
                                    [readUint32(fr), readUint32(fr)],
                                    [readUint32(fr), readUint32(fr)]
                                ],
                                flags:   readUint32(fr),
                                flagsac: readUint32(fr))

    result.descr = optionalField[string](fr, "DESC")