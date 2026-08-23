# ANSI SGR (Select Graphic Rendition) — vollständige Referenz

Diese Datei listet die gebräuchlichen SGR-Parameter (Textattribute, Farben, 256-Farben, TrueColor) und kurze Beispiele.

Grundlegende Parameter
- 0 : Reset / alle Attribute aus
- 1 : Fett / helle Darstellung (bold/bright)
- 2 : Schwach (faint)
- 3 : Kursiv (italic)
- 4 : Unterstrichen (underline)
- 5 : Blink (slow blink)
- 7 : Inverse / Swap foreground/background
- 8 : Versteckt (conceal)
- 9 : Durchgestrichen (strike)

Abschalten spezifischer Attribute
- 21/22 : Fett-Aus / normale Intensität
- 23 : Kursiv-Aus
- 24 : Unterstrich-Aus
- 25 : Blink-Aus
- 27 : Inverse-Aus
- 28 : Reveal (conceal aus)
- 29 : Strike-Aus

Standard-Farben (Vordergrund)
- 30 : Schwarz
- 31 : Rot
- 32 : Grün
- 33 : Gelb
- 34 : Blau
- 35 : Magenta
- 36 : Cyan
- 37 : Weiß

Standard-Hintergrundfarben
- 40–47 entsprechen den Vordergrundfarben für Hintergründe

Helle (Bright) Textfarben
- 90 : Hellschwarz (Bright Black / Grau)
- 91 : Hellrot
- 92 : Hellgrün
- 93 : Hellgelb
- 94 : Hellblau
- 95 : Hellmagenta
- 96 : Hellcyan
- 97 : Hellweiß

Helle Hintergrundfarben
- 100–107 entsprechen den hellen Hintergrundfarben

256-Farben (8-bit)
- Vordergrund: `ESC[38;5;<n>m` — `<n>` von 0–255
- Hintergrund: `ESC[48;5;<n>m`
- Werte 0–15: Standardfarben (inkl. Bright)
- Werte 16–231: 6×6×6 Farbwürfel
- Werte 232–255: Graustufen

TrueColor / 24-bit Farben
- Vordergrund: `ESC[38;2;<r>;<g>;<b>m` (0–255 für r,g,b)
- Hintergrund: `ESC[48;2;<r>;<g>;<b>m`

Beispiele
- `ESC[31mTextESC[0m` → roter Text
- `ESC[1;31mTextESC[0m` → fett/hell rot
- `ESC[38;5;202m` → 256-Farb-Code (orange-ähnlich)
- `ESC[38;2;255;100;0m` → echtes Orange (TrueColor)

Anmerkungen für Windows-Batch
- Windows 10+ (und neuere Terminals) unterstützen ANSI/VT-Sequenzen, wenn "Virtual Terminal Processing" aktiviert ist oder wenn Sie moderne Terminals wie Windows Terminal verwenden.
- In Batch-Dateien erzeugen Sie das ESC-Zeichen typischerweise so:
  ```bat
  for /F "delims=" %%A in ('"prompt $E & for %%B in (1) do rem"') do set "ESC=%%A"
  echo %ESC%[31mHallo%ESC%[0m
  ```
- Falls Ihr Terminal keine ANSI-Sequenzen unterstützt, werden die Escape-Zeichen sichtbar oder es passiert nichts. Alternativen: PowerShell `Write-Host -ForegroundColor`, oder aktivieren von VT-Processing per API.

Kurzreferenz-Tabelle (häufig genutzte Kombinationen)
- `ESC[0m`  Reset
- `ESC[1m`  Fett/Hell
- `ESC[4m`  Unterstrichen
- `ESC[7m`  Inverse
- `ESC[31m` Rot (Vordergrund)
- `ESC[32m` Grün
- `ESC[33m` Gelb
- `ESC[34m` Blau
- `ESC[35m` Magenta
- `ESC[36m` Cyan
- `ESC[37m` Weiß
- `ESC[90m` Hellgrau (bright black)

Wenn Sie möchten, kann ich auch eine kürzere "Cheat-sheet"-Version erstellen oder die Datei als `.txt`/.`csv` für einfachen Download exportieren.