import ../records
import ../common
import ../parse

const field_key = "CREA"

proc parseCREA* (fr: var string): MWCreature =
  #[ Parses single CREA key of .esm/.esp files and returns it as MWCreature object ]#
  result.header = parseRecordHeader(fr)

  result.id     = requiredField[zstring](fr, "NAME", field_key)
  result.model  = requiredField[zstring](fr, "MODL", field_key)
  result.sgen   = optionalField[zstring](fr, "CNAM")
  result.name   = optionalField[zstring](fr, "FNAM")
  result.script = optionalField[zstring](fr, "SCRI")

  if objectField(fr, "NPDT", result.data, result.id):
    result.data = MWCreatureData(kind:  readUint32(fr),
                                 level: readUint32(fr),
                                 attr:  [
                                    readUint32(fr), readUint32(fr),
                                    readUint32(fr), readUint32(fr),
                                    readUint32(fr), readUint32(fr),
                                    readUint32(fr), readUint32(fr)
                                 ],
                                 health:   readUint32(fr),
                                 mana:     readUint32(fr),
                                 fatigue:  readUint32(fr),
                                 soul:     readUint32(fr),
                                 combat:   readUint32(fr),
                                 magic:    readUint32(fr),
                                 stealth:  readUint32(fr),
                                 att1_min: readUint32(fr),
                                 att1_max: readUint32(fr),
                                 att2_min: readUint32(fr),
                                 att2_max: readUint32(fr),
                                 att3_min: readUint32(fr),
                                 att3_max: readUint32(fr),
                                 gold:     readUint32(fr))

  result.flags = requiredField[uint32](fr, "FLAG", field_key)
  result.scale = optionalField[float32](fr, "XSCL")
  if result.scale == 0.0: # default value if XSCL missing
    result.scale = 1.0

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