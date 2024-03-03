import std/strformat
import std/strutils
import std/os
import streams
import parse

# srcs: https://stackoverflow.com/questions/33107332/writing-reading-binary-file-in-nim
#       https://stackoverflow.com/questions/26845538/parsing-a-binary-file-what-is-a-modern-way
# uesp: https://en.uesp.net/wiki/Morrowind_Mod:Mod_File_Format
# dscd: https://discord.com/channels/210394599246659585/210894929868619778/1211364857169977344

var file = "Morrowind.esm"

if paramCount() > 0: # overwrites
  file = paramStr(1)

type
  RecordHeader = object
    # raw_bytes : array[byte]
    # version   : float32
    # flags     : uint32
    # # author    : char[32]
    # # descr     : char[256]
    # recs_left : uint32

  MWPlugin = object
    name*   : string
    master* : bool
    head*   : RecordHeader

proc `$`* (plugin: MWPlugin): string =
    result = fmt"""
    [{plugin.name}]
    Master: {plugin.master}
    """.unindent()

proc newRecordHeader(header_string: string): RecordHeader = #(ab: array[300, byte]): RecordHeader =
    discard

proc newMWPlugin* (path: string): MWPlugin =
    # - Reads .ESP file from path provided
    # - Returns ESPPlugin struct

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

    result.head = newRecordHeader(fr.read(300)) # 300 bytes after initial check

let test = newMWPlugin(file)
echo test