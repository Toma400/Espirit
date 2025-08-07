import ../records
import ../common
import ../parse

const field_key = "RACE"

proc parseRACE* (fr: var string, header: MWRecordHeader): MWRace =
    #[ Parses single RACE key of .esm/.esp files and returns it as MWRace object ]#
    setRecordData(result, header)

    result.id   = requiredField[zstring](fr, "NAME", field_key)
    result.name = optionalField[zstring](fr, "FNAM")

    if objectField(fr, "RADT", result.data, result.id):
      result.data = MWRaceData(skill:  [
                                  (readInt32(fr), readInt32(fr)),
                                  (readInt32(fr), readInt32(fr)),
                                  (readInt32(fr), readInt32(fr)),
                                  (readInt32(fr), readInt32(fr)),
                                  (readInt32(fr), readInt32(fr)),
                                  (readInt32(fr), readInt32(fr)),
                                  (readInt32(fr), readInt32(fr))
                               ],
                               attr:   [
                                  [readUint32(fr), readUint32(fr)],
                                  [readUint32(fr), readUint32(fr)],
                                  [readUint32(fr), readUint32(fr)],
                                  [readUint32(fr), readUint32(fr)],
                                  [readUint32(fr), readUint32(fr)],
                                  [readUint32(fr), readUint32(fr)],
                                  [readUint32(fr), readUint32(fr)],
                                  [readUint32(fr), readUint32(fr)]
                               ],
                               height: (readFloat32(fr), readFloat32(fr)),
                               weight: (readFloat32(fr), readFloat32(fr)),
                               flags:  readUint32(fr)
      )

    result.power = repeatableField[array[32, char]](fr, "NPCS")
    result.descr = optionalField[string](fr, "DESC")
