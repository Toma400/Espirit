import flatty/binny
import std/strutils
import std/parseutils

# yields fragment of string [0..i] then removes it
proc read* (s: var string, i: int): string =
    result    = s[0..i-1]
    s[0..i-1] = ""

# alias procs for flatty/binny, so you don't need to type 0 and v twice
proc readStr* (s: var string, v: int): string =
    return readStr(s.read(v), 0, v)

proc readChar* (s: var string): char =
    return readStr(s.read(1), 0, 1)[0]

proc readUint64* (s: var string, v: int = 8): uint64 =
    return readUint64(s.read(v), 0)

proc readUint32* (s: var string, v: int = 4): uint32 =
    return readUint32(s.read(v), 0)

proc readUint16* (s: var string, v: int = 2): uint16 =
    return readUint16(s.read(v), 0)

proc readUint8* (s: var string, v: int = 1): uint8 =
    return readUint8(s.read(v), 0)

proc readFloat32* (s: var string, v: int = 4): float32 =
    return readFloat32(s.read(v), 0)