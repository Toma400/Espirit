import ../recordsutils
import ../records
import ../indexes
import ../common
import ../parse

const field_key = "NPC_"

proc parseNPC* (fr: var string): MWNPC =
    #[ Parses single NPC_ key of .esm/.esp files and returns it as MWNPC object ]#
    result.header = parseRecordHeader(fr)

    result.id      = requiredField[zstring](fr, "NAME", field_key)
    result.model   = optionalField[zstring](fr, "MODL")
    result.name    = optionalField[zstring](fr, "FNAM")
    result.race    = requiredField[zstring](fr, "RNAM", field_key)
    result.class   = requiredField[zstring](fr, "CNAM", field_key)
    result.faction = optionalField[zstring](fr, "ANAM")
    result.head    = requiredField[zstring](fr, "BNAM", field_key)
    result.hair    = optionalField[zstring](fr, "KNAM")
    result.script  = optionalField[zstring](fr, "SCRI")

    if readStr(fr, 4) != "NPDT":
      raise newException(ParseError, "No NPDT field found for NPC_ entry.")
    else:
      let length = getLength(fr)
      case length:
        of 12:
          result.auc     = true
          result.data[1] = MWNPCDataACSet(level:   readUint16(fr),
                                          disp:    readUint8(fr),
                                          rep:     readUint8(fr),
                                          rank:    readUint8(fr),
                                          alg_pad: readUint8(fr),
                                          gold:    readUint32(fr),
                                          size:    length)
        of 52:
          result.auc     = false
          result.data[0] = MWNPCDataACClear(level: readUint16(fr),
                                            attr:  [readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr)
                                                    ],
                                            skill: [readUint8(fr), readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr), readUint8(fr),
                                                    readUint8(fr), readUint8(fr), readUint8(fr)
                                                    ],
                                            alg_pad: readUint8(fr),
                                            hp:      readUint16(fr),
                                            mp:      readUint16(fr),
                                            fatigue: readUint16(fr),
                                            disp:    readUint8(fr),
                                            rep:     readUint8(fr),
                                            rank:    readUint8(fr),
                                            alg_p2d: readUint8(fr),
                                            gold:    readUint32(fr),
                                            size:    length)
        else:
          raise newException(ParseError, "NPDT field has length out of allowed values (12, 52)")

    result.flags = requiredField[uint32](fr, "FLAG", field_key)
    if (AutoCalc in checkFlags(result)) != result.auc: # checks whether autocalc flag is set according to NPDT parsing
      raise newException(ParseError, "NPC_ autocalc value set differs from NPDT size")

    var npco: int
    while repeatableObjectField(fr, "NPCO", npco):
      result.carry.add(MWCarriedObject(count: readUint32(fr),
                                       name:  read32Chars(fr)))

    result.spells = repeatableField[array[32, char]](fr, "NPCS")

    if objectField(fr, "AIDT", result.aidata, result.id):
      result.aidata = MWAIData(hello:   readUint8(fr),
                               unknown: readUint8(fr),
                               fight:   readUint8(fr),
                               flee:    readUint8(fr),
                               alarm:   readUint8(fr),
                               alg_pad: (readUint8(fr), readUint8(fr), readUint8(fr)),
                               flags:   readUint32(fr))

    # using below to struct-ify a pair of struct and zstring (hence getting field name on zstring)
    var dodt: int
    while repeatableObjectField(fr, "DODT", dodt):
      result.dest.add(MWCellTravelDestination(pos_x:    readFloat32(fr),
                                              pos_y:    readFloat32(fr),
                                              pos_z:    readFloat32(fr),
                                              rot_x:    readFloat32(fr),
                                              rot_y:    readFloat32(fr),
                                              rot_z:    readFloat32(fr),
                                              prv_dest: optionalField[zstring](fr, "DNAM")))

    result.aipkg = processAIPackage(fr)