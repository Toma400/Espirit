import std/tables
import strutils
import records
import parse

proc parseMAST* (fr: var string, tabl: var OrderedTable[string, uint64]) =
    #[ Parses single MAST key of .esm/.esp files and adds it to `tabl` ]#
    discard readStr(fr, 4) # loose bytes
    var mast_name = parseZString(fr)

    if readStr(fr, 4) != "DATA":
      raise newException(ParseError, "No byte length found for master file: " & mast_name)
    discard readStr(fr, 4) # loose bytes

    tabl[mast_name] = readUint64(fr, 4)

    discard readStr(fr, 4) # loose bytes