package input;

final KEY_CODE_TO_STRING: Map<Int, String> = [
	0 => "Unknown", 1 => "Back", // Android
	3 => "Cancel", 6 => "Help", 8 => "BKSP", 9 => "Tab", 12 => "Clear", 13 => "Return", 16 => "Shift", 17 => "Control",
	18 => "Alt", 19 => "Pause", 20 => "CapsLock", 21 => "Kana / Hangul", 22 => "Eisu", 23 => "Junja", 24 => "Final", 25 => "Hanja / Kanji", 27 => "ESC",
	28 => "Convert", 29 => "NonConvert", 30 => "Accept", 31 => "ModeChange", 32 => "Space", 33 => "PageUp", 34 => "PageDown", 35 => "End", 36 => "Home",
	37 => "Left", 38 => "Up", 39 => "Right", 40 => "Down", 41 => "Select", 42 => "Print", 43 => "Execute", 44 => "PrintScreen", 45 => "Insert",
	46 => "Delete", 48 => "Zero", 49 => "One", 50 => "Two", 51 => "Three", 52 => "Four", 53 => "Five", 54 => "Six", 55 => "Seven", 56 => "Eight",
	57 => "Nine", 58 => "Colon", 59 => "Semicolon", 60 => "LessThan", 61 => "Equals", 62 => "GreaterThan", 63 => "QuestionMark", 64 => "At", 65 => "A",
	66 => "B", 67 => "C", 68 => "D", 69 => "E", 70 => "F", 71 => "G", 72 => "H", 73 => "I", 74 => "J", 75 => "K", 76 => "L", 77 => "M", 78 => "N", 79 => "O",
	80 => "P", 81 => "Q", 82 => "R", 83 => "S", 84 => "T", 85 => "U", 86 => "V", 87 => "W", 88 => "X", 89 => "Y", 90 => "Z", 91 => "Win", 93 => "ContextMenu",
	95 => "Sleep", 96 => "Num0", 97 => "Num1", 98 => "Num2", 99 => "Num3", 100 => "Num4", 101 => "Num5", 102 => "Num6", 103 => "Num7", 104 => "Num8",
	105 => "Num9", 106 => "Multiply", 107 => "Add", 108 => "Separator", 109 => "Subtract", 110 => "Decimal", 111 => "Divide", 112 => "F1", 113 => "F2",
	114 => "F3", 115 => "F4", 116 => "F5", 117 => "F6", 118 => "F7", 119 => "F8", 120 => "F9", 121 => "F10", 122 => "F11", 123 => "F12", 124 => "F13",
	125 => "F14", 126 => "F15", 127 => "F16", 128 => "F17", 129 => "F18", 130 => "F19", 131 => "F20", 132 => "F21", 133 => "F22", 134 => "F23", 135 => "F24",
	144 => "NumLock", 145 => "ScrollLock", 146 => "WinOemFjJisho", 147 => "WinOemFjMasshou", 148 => "WinOemFjTouroku", 149 => "WinOemFjLoya",
	150 => "WinOemFjRoya", 160 => "Circumflex", 161 => "Exclamation", 162 => "DoubleQuote", 163 => "Hash", 164 => "Dollar", 165 => "Percent",
	166 => "Ampersand", 167 => "Underscore", 168 => "OpenParen", 169 => "CloseParen", 170 => "Asterisk", 171 => "Plus", 172 => "Pipe", 173 => "HyphenMinus",
	174 => "OpenCurlyBracket", 175 => "CloseCurlyBracket", 176 => "Tilde", 181 => "VolumeMute", 182 => "VolumeDown", 183 => "VolumeUp", 188 => "Comma",
	190 => "Period", 191 => "Slash", 192 => "BackQuote", 219 => "OpenBracket", 220 => "BackSlash", 221 => "CloseBracket", 222 => "Quote", 224 => "Meta",
	225 => "AltGr", 227 => "WinIcoHelp", 228 => "WinIco00", 230 => "WinIcoClear", 233 => "WinOemReset", 234 => "WinOemJump", 235 => "WinOemPA1",
	236 => "WinOemPA2", 237 => "WinOemPA3", 238 => "WinOemWSCTRL", 239 => "WinOemCUSEL", 240 => "WinOemATTN", 241 => "WinOemFinish", 242 => "WinOemCopy",
	243 => "WinOemAuto", 244 => "WinOemENLW", 245 => "WinOemBackTab", 246 => "ATTN", 247 => "CRSEL", 248 => "EXSEL", 249 => "EREOF", 250 => "Play",
	251 => "Zoom", 253 => "PA1", 254 => "WinOemClear",
];
