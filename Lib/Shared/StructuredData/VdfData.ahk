class VdfData extends StructuredDataBase {
    FromString(ByRef src, args*) {
		static q := Chr(34)
		static letters := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
		static numbers := "1234567890"
		returnData := Map()
		key := ""
		is_key := true
		tree := []
		stack := [tree]
		next := letters . numbers
		pos := 0
		
		while ((ch := SubStr(src, ++pos, 1)) != "") {
			if InStr(" `t`n`r", ch) {
				continue
			}
				
			if !InStr(next, ch, true) {
				testArr := StrSplit(SubStr(src, 1, pos), "`n")				
				ln := testArr.Length
				col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

				msg := Format("{}: line {} col {} (char {})"
				,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
				: (next == "\")     ? "Invalid \escape"
				: (next == q)       ? "Expecting object key enclosed in double quotes"
				: (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
				: (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
				: (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
				: [ "Expecting value (string, number, true, false, null, map, or array)"
					, ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
				, ln, col, pos)

				throw OperationFailedException.new(msg, -1, ch)
			}
			
			obj := stack[1]
			is_array := (Type(obj) == "Array")
			
			if (ch == "{") {
				val := Map()
				obj[key] := val
				stack.InsertAt(1, val)
				is_key := true
				next := q . "}"
			} else if (ch == "}") {
				stack.RemoveAt(1)
				next := (stack[1] == tree) ? "" : "}" . q
				is_key := true
			} else if (is_key) {
				key := SubStr(src, pos, i := RegExMatch(src, "[\s]|$",, pos)-pos)
				next := q
				is_key := false
				pos += i-1
			} else {
				if (ch == q) { ; string
					i := pos

					while i := InStr(src, q,, i + 1) {
						val := StrReplace(SubStr(src, pos + 1, i - pos - 1), "\\", "\u005C")

						if (SubStr(val, -1) != "\") {
							break
						}
					}

					; @todo rewrite for clarity
					if (!i ? (pos--, next := "'") : 0) {
						continue
					}

					pos := i

					val := StrReplace(val, "\/", "/")
					val := StrReplace(val, "\" . q, q)
					val := StrReplace(val, "\b", "`b")
					val := StrReplace(val, "\f", "`f")
					val := StrReplace(val, "\n", "`n")
					val := StrReplace(val, "\r", "`r")
					val := StrReplace(val, "\t", "`t")

					i := 0

					while i := InStr(val, "\",, i+1) {
						if ((SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0) {
							continue 2
						}
					}
				}

				if (is_array) {
					obj.Push(val)
				} else {
					obj[key] := val
				}
				
				is_key := true
				next := "}" . q
			}
		}

		this.obj := tree[1]
		return this.obj
	}

	ToString(args*) {
        throw MethodNotImplementedException.new("StructuredDataBase", "ToString")
    }
}
