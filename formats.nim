import std/tables
import parse

proc parseMAST* (fr: var string, tabl: var OrderedTable[string, uint64]) =
    #[ Parses single MAST key of .esm/.esp files and adds it to `tabl` ]#
    discard readStr(fr, 4) # loose bytes
    var mast_name = ""
    while true:
      let o = readChar(fr)
      if o != '\0':
        mast_name.add(o)
      else: break
    if readStr(fr, 4) != "DATA":
      raise newException(Exception, "No byte length found for master file: " & mast_name)
    discard readStr(fr, 4) # loose bytes

    tabl[mast_name] = readUint64(fr, 4)