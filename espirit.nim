import std/strformat
import std/strutils
import std/os
import formats
import records
import streams
import tables
import parse

export tables

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
    clot*   : seq[MWCloth] # clothes (see `MWCloth` in records.nim for reference)

proc `$`* (plugin: MWPlugin): string =
    result = fmt"""
    [{plugin.name}]
    Master: {plugin.master}
    """.unindent()
proc `$`* (record: MWCloth): string =
    result = fmt"""
    ID:    {record.id}
    Name:  {record.name}
    Model: {record.model}
    Icon:  {record.icon}
    =====
      Kind:   {record.data.kind}
      Weight: {record.data.weight}
      Value:  {record.data.value}
    =====
    """

proc newRecordHeader(header_string: string): RecordHeader =
    result.bytestr = header_string

proc newMWPlugin* (path: string): MWPlugin =
    let fs : FileStream = newFileStream(path)
    var fr : string     = fs.readAll()        # file read: string here == seq[bytes]

    if readStr(fr, 4) != "TES3": # initial .esp check
      raise newException(Exception, "File scanned does not follow correct Morrowind .esp/.esm plugin record format.")
    close(fs)

    if endswith(toLowerAscii(path), ".esp"):
      result.name   = path.replace(".esp", "")
      result.master = false
    elif endsWith(toLowerAscii(path), ".esm"):
      result.name   = path.replace(".esm", "")
      result.master = true
    else: raise newException(Exception, "Cannot verify master file. Make sure the file scanned is of .esp/.esm format.")

    discard readStr(fr, 12) # loose bytes
    if readStr(fr, 4) != "HEDR": # check for header
      raise newException(Exception, "File header not found.")
    discard readStr(fr, 4) # loose bytes

    result.head = newRecordHeader(fr.read(300)) # 300 bytes after initial check (w/o TES3 header)

    # records
    while fr.len > 0:
      let rec_type = readStr(fr, 4)
      case rec_type:
        of "MAST": parseMAST(fr, result.deps)
        of "CLOT": result.clot.add(parseCLOT(fr))
        else:
          break

      if fr.len >= 4:
        discard readStr(fr, 4) # loose bytes