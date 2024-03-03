import flatty/binny

# yields fragment of string [0..i] then removes it
proc read* (s: var string, i: int): string =
    result    = s[0..i-1]
    s[0..i-1] = ""

# alias procs for flatty/binny, so you don't need to type 0 and v twice
proc readStr* (s: var string, v: int): string =
    return readStr(s.read(v), 0, v)