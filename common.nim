# [ COMMON ] #
# Collect common procedures that will be used in future Espirit versions
# to ensure better code practices & readability
import strformat
import records
import parse

type
  zstring* = string # used only to differentiate between MW's string and zstring for [T] handling

proc parseRecordHeader* (fr: var string, nm: string): MWRecordHeader = # parses first 12 'loose bytes'
    # TODO: skips first 4 bytes as they are used in -espirit.nim-
    # for _ in 1..4:
    #   result.name.add(readChar(fr))
    result.name  = nm # remove the argument and this bind (replace by iterator above) once the whole system migrates
    result.size  = readUint32(fr)
    result.dummy = readUint32(fr)
    result.flags = readUint32(fr)

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
        else:              discard

proc optionalField* [T](fr: var string, name: string): T = # general proc to handle optional fields; should allow custom handling
    if len(fr) >= 4:
      if fr[0..3] == name:
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
            else:              discard