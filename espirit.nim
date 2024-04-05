import mwparsers/mwstat
import mwparsers/mwmisc
import mwparsers/mwingr
import mwparsers/mwcont
import std/strformat
import std/strutils
import std/os
import formats
import records
import streams
import tables
import parse

export tables
export records

# srcs: https://stackoverflow.com/questions/33107332/writing-reading-binary-file-in-nim
#       https://stackoverflow.com/questions/26845538/parsing-a-binary-file-what-is-a-modern-way
# uesp: https://en.uesp.net/wiki/Morrowind_Mod:Mod_File_Format
# dscd: https://discord.com/channels/210394599246659585/210894929868619778/1211364857169977344

type
  RecordHeader = object
    bytestr* : string

  MWPlugin = object
    name*   : string
    master* : bool
    head*   : RecordHeader
    deps*   : OrderedTable[string, uint64] # esm dependencies as [.esm file, bytes size]
    # Plugin regular records
    clot*   : seq[MWCloth]      # clothes (see `MWCloth` in records.nim for reference)
    misc*   : seq[MWMisc]       # misc items (see `MWMisc` in records.nim for reference)
    stat*   : seq[MWStatic]     # statics (see `MWStatic` in records.nim for reference)
    cont*   : seq[MWContainer]  # containers (see `MWContainer` in records.nim for reference)
    ingr*   : seq[MWIngredient] # ingredients (see `MWIngredient` in records.nim for reference)
    book*   : seq[MWBook]       # books (see `MWBook` in records.nim for reference)

proc `$`* (plugin: MWPlugin): string =
    var deps = ""
    for k, _ in plugin.deps:
      deps.add("\n" & "* " & k)
    result = fmt"""
    [{plugin.name}]
    Dependencies: {deps}

    Data:
    * statics:     {plugin.stat.len}
    * containers:  {plugin.cont.len}
    * miscs:       {plugin.misc.len}
    * clothes:     {plugin.clot.len}
    * ingredients: {plugin.ingr.len}
    * books:       {plugin.book.len}
    """.unindent()

proc newRecordHeader(header_string: string): RecordHeader =
    result.bytestr = header_string

proc newMWPlugin* (path: string): MWPlugin =
    let fs : FileStream = newFileStream(path)
    var fr : string     = fs.readAll()        # file read: string here == seq[bytes]

    if readStr(fr, 4) != "TES3": # initial .esp check
      raise newException(ParseError, "File scanned does not follow correct Morrowind .esp/.esm plugin record format.")
    close(fs)

    if endswith(toLowerAscii(path), ".esp"):
      result.name   = path.replace(".esp", "")
      result.master = false
    elif endsWith(toLowerAscii(path), ".esm"):
      result.name   = path.replace(".esm", "")
      result.master = true
    else: raise newException(ParseError, "Cannot verify master file. Make sure the file scanned is of .esp/.esm format.")

    discard readStr(fr, 12) # loose bytes
    if readStr(fr, 4) != "HEDR": # check for header
      raise newException(ParseError, "File header not found.")
    discard readStr(fr, 4) # loose bytes

    result.head = newRecordHeader(fr.read(300)) # 300 bytes after initial check (w/o TES3 header)

    # records
    while fr.len > 0:
      let rec_type = readStr(fr, 4)
      case rec_type:
        of "MAST": parseMAST(fr, result.deps)
        of "CLOT": result.clot.add(parseCLOT(fr))
        of "STAT": result.stat.add(parseSTAT(fr))
        of "MISC": result.misc.add(parseMISC(fr))
        of "INGR": result.ingr.add(parseINGR(fr))
        of "CONT": result.cont.add(parseCONT(fr))
        of "BOOK": break
        else:
          break