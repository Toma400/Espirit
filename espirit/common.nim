# [ COMMON ] #
# Collect common procedures that will be used in future Espirit versions
# to ensure better code practices & readability
import strformat
import indexes
import records
import parse

type
  # [ FILTER TYPES ] | Do not use below types in records' fields, only in [T] of procs below!
  zstring* = string                       # used only to differentiate between MW's string and zstring for [T] handling
  rgb*     = (uint8, uint8, uint8, uint8) # shortcut

proc parseRecordHeader* (fr: var string): MWRecordHeader = # parses first 12 'loose bytes'
    for _ in 1..4:
      result.name.add(readChar(fr))
    result.size  = readUint32(fr)
    result.dummy = readUint32(fr)
    result.flags = readUint32(fr)

    # TODO: parse [size] amount of bytes! so MWRecord parsing will be on header's contents, not `fr`
    # also: ensure `fr` contains at least `size` amount of bytes

proc setRecordData* (rc: var MWRecord, header: MWRecordHeader) =
    let flags = checkFlagsData[MWRecordFlags, uint32](header.flags)
    rc.deleted  = Deleted       in flags
    rc.disabled = DisabledInit  in flags
    rc.blocked  = Blocked       in flags
    rc.persrf   = PersistentRef in flags

proc parseRecordHeader* (fr: var string, rc: var MWRecord): MWRecordHeader {.deprecated.} = # parses first 12 'loose bytes'
    for _ in 1..4:
      result.name.add(readChar(fr))
    result.size  = readUint32(fr)
    result.dummy = readUint32(fr)
    result.flags = readUint32(fr)

    let flags = checkFlagsData[MWRecordFlags, uint32](result.flags)
    rc.deleted  = Deleted       in flags
    rc.disabled = DisabledInit  in flags
    rc.blocked  = Blocked       in flags
    rc.persrf   = PersistentRef in flags

proc getLength* (fr: var string): int = # to handle the commonly discarded 'loose bytes', usually containing lengths
    return int(readUint32(fr))

#[ TODO:
  Maybe we could, instead of returning, use `field: var [T]`?
  This way we could directly write into field and less copying would be made (boost on perf?)
  This would also make each `mwparsers` file less chunky, as instead of:

    let f = requiredField(...)
    something.field = f

  or worse, in case of optionals:

    let f = optionalField(...)
    if f.isSome:
      something.field = f

  We could simply do it in one, clean proc call, and Optional would no longer be an issue
  (you'd not have field overwritten in case the field is not found)
]#

proc requiredField* [T](fr: var string, name: string, entry: string): T = # general proc to handle required fields; should allow custom handling
    if readStr(fr, 4) != name: # consumes field name
        raise newException(ParseError, fmt"No {name} field found for {entry} entry.")
    let length = getLength(fr)
    block typeCheck:
        when T is uint8:   return readUint8(fr)
        elif T is uint16:  return readUint16(fr)
        elif T is uint32:  return readUint32(fr)
        elif T is uint64:  return readUint64(fr)
        elif T is int8:    return readInt8(fr)
        elif T is int32:   return readInt32(fr)
        elif T is float32: return readFloat32(fr)
        elif T is string:  return readStr(fr, length) # must be before zstring, since zstring also catches string
        elif T is zstring: return parseZString(fr)
        elif T is char:    return readChar(fr)
        elif T is rgb:     return readRGB(fr)
        elif T is array[32, char]: return read32Chars(fr)
        elif T is (int32, int32):  return (readInt32(fr), readInt32(fr))
        elif T is (string, int32): return (readStr(fr, length), readInt32(fr))
        else:                      raise newException(ParseError, fmt"Unsupported type for {name} field for {entry} entry: {T.type}")

proc optionalField* [T](fr: var string, name: string): T = # general proc to handle optional fields; should allow custom handling
    if len(fr) >= 4:
      if fr[0..3] == name:     # [0..3] is used for scouting without consumption
        discard readStr(fr, 4) # consumes field name
        let length = getLength(fr)
        block typeCheck:
            when T is uint8:   return readUint8(fr)
            elif T is uint16:  return readUint16(fr)
            elif T is uint32:  return readUint32(fr)
            elif T is uint64:  return readUint64(fr)
            elif T is int8:    return readInt8(fr)
            elif T is int32:   return readInt32(fr)
            elif T is float32: return readFloat32(fr)
            elif T is string:  return readStr(fr, length) # must be before zstring, since zstring also catches string
            elif T is zstring: return parseZString(fr)
            elif T is char:    return readChar(fr)
            elif T is rgb:     return readRGB(fr)
            elif T is array[32, char]: return read32Chars(fr)
            elif T is (int32, int32):  return (readInt32(fr), readInt32(fr))
            elif T is (string, int32): return (readStr(fr, length), readInt32(fr))
            else:                      raise newException(ParseError, fmt"Unsupported type for {name} field: {T.type}")

proc repeatableField* [T](fr: var string, name: string): seq[T] =
    while true:
      if len(fr) >= 4:
        if fr[0..3] != name:
          break
      else: break
      # if len >= 4 and fr[0..3] == name:
      result.add(optionalField[T](fr, name))

proc objectField* (fr: var string, name: string, dataobj: var MWRecordData, id: string = "[]"): bool = # checks whether object exists and has proper length available
    if readStr(fr, 4) != name: # consumes field name
        raise newException(ParseError, fmt"No {name} field found for {dataobj} entry: {id}")
    dataobj.size = getLength(fr)
    if len(fr) >= dataobj.size:
      return true
    raise newException(ParseError, fmt"Object size for {name} field found for {dataobj} object does not match. Object size: {dataobj.size}. Available bytes: {len(fr)}.")

proc optionalObjectField* (fr: var string, name: string, dataobj: var MWRecordData): bool =
    # use `if` as a condition that allows you to use a constructor
    if len(fr) >= 4:
      if fr[0..3] == name:
        discard readStr(fr, 4) # consumes field name
        dataobj.size = getLength(fr)
        if len(fr) >= dataobj.size:
          return true
    return false

proc repeatableObjectField* (fr: var string, name: string, length: var int): bool =
    # use `while` as a condition that allows you yo use a constructor | 'length' should be separate variable provided before loop and used later in constructor (ref: ALCH)
    if len(fr) >= 4:
      if fr[0..3] == name:
        discard readStr(fr, 4) # consumes field name
        length = getLength(fr)
        if len(fr) >= length:
          return true
    return false

proc optionalPairField* [T, Y](fr: var string, names: array[2, string]): (T, Y) =
    if len(fr) >= 4:
      for i, name in names.pairs:
        if fr[0..3] == name:
          case i:
            of 0: result[0] = optionalField[T](fr, name)
            of 1: result[1] = optionalField[Y](fr, name)

proc repeatablePairField* [T, Y](fr: var string, names: array[2, string]): seq[(T, Y)] =
    while true:
      if len(fr) >= 4:
        if fr[0..3] notin names:
          break
      else: break
      result.add(optionalPairField[T, Y](fr, names))

proc optionalTriadField* [T, Y, U](fr: var string, names: array[3, string]): (T, Y, U) =
    if len(fr) >= 4:
      for i, name in names.pairs:
        if fr[0..3] == name:
          case i:
            of 0: result[0] = optionalField[T](fr, name)
            of 1: result[1] = optionalField[Y](fr, name)
            of 2: result[2] = optionalField[U](fr, name)

proc repeatableTriadField* [T, Y, U](fr: var string, names: array[3, string]): seq[(T, Y, U)] =
    while true:
      if len(fr) >= 4:
        if fr[0..3] notin names:
          break
      else: break
      result.add(optionalTriadField[T, Y, U](fr, names))

proc processAIPackage* (fr: var string): ((int, MWAIPackageActivate),
                                          (int, MWAIPackageEscort),
                                          (int, MWAIPackageFollow),
                                          (int, MWAIPackageTravel),
                                          (int, MWAIPackageWander)) =
    # returns tuple[5] of tuples (int, AIPackage)
    # int value in each tuple is order by which they appear in record (-1 means package wasn't found)
    const keys = ["AI_A", "AI_E", "AI_F", "AI_T", "AI_W", "CNDT"]
    for o in result.fields: # sets each AIPackage as non-existent by default (will be overwritten later if found)
      o[0] = -1
    for i in 1..5:
      if len(fr) <= 4:
        break
      case fr[0..3]:
        of keys[0]:
           discard readStr(fr, 4) # consumes AI_A
           result[0] = (i, MWAIPackageActivate(name:    read32Chars(fr),
                                               unknown: readUint8(fr)))
        of keys[1]:
           discard readStr(fr, 4) # consumes AI_E
           result[1] = (i, MWAIPackageEscort(size:     getLength(fr),
                                             pos_x:    readFloat32(fr),
                                             pos_y:    readFloat32(fr),
                                             pos_z:    readFloat32(fr),
                                             duration: readUint16(fr),
                                             id:       read32Chars(fr),
                                             unknown:  readUint8(fr),
                                             unused:   readUint8(fr),
                                             cell:     optionalField[zstring](fr, "CNDT")))
        of keys[2]:
           discard readStr(fr, 4) # consumes AI_F
           result[2] = (i, MWAIPackageFollow(size:     getLength(fr),
                                             pos_x:    readFloat32(fr),
                                             pos_y:    readFloat32(fr),
                                             pos_z:    readFloat32(fr),
                                             duration: readUint16(fr),
                                             id:       read32Chars(fr),
                                             unknown:  readUint8(fr),
                                             unused:   readUint8(fr),
                                             cell:     optionalField[zstring](fr, "CNDT")))
        of keys[3]:
           discard readStr(fr, 4) # consumes AI_T
           result[3] = (i, MWAIPackageTravel(size:     getLength(fr),
                                             pos_x:    readFloat32(fr),
                                             pos_y:    readFloat32(fr),
                                             pos_z:    readFloat32(fr),
                                             unknown:  readUint8(fr),
                                             unused:   readUint8(fr)))
        of keys[4]:
           discard readStr(fr, 4) # consumes AI_W
           result[4] = (i, MWAIPackageWander(size:     getLength(fr),
                                             distance: readUint16(fr),
                                             duration: readUint16(fr),
                                             daytime:  readUint8(fr),
                                             idles:  (readUint8(fr), readUint8(fr),
                                                      readUint8(fr), readUint8(fr),
                                                      readUint8(fr), readUint8(fr),
                                                      readUint8(fr), readUint8(fr)),
                                             unknown: readUint8(fr)))
        of keys[5]: raise newException(ParseError, fmt"CNDT field appearing out of order in AIPackage!") # should not appear without 0-4 preceeding
        else: break