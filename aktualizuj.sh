#!/bin/bash
# Vyrobí samostatnou verzi ukázkové stránky pro vlastní GitHub Pages.
#
# Zdroj je jediný: obsah/predstaveni.html v repozitáři Metodusu. Tenhle
# skript z něj udělá index.html, ve kterém nezůstane ani jeden odkaz ven ze
# souboru — to je celý smysl samostatného nasazení. Konkrétně:
#   • podpis.js a apps.js se vypustí (stránka si podpis dopíše sama do patičky
#     a bez katalogu skryje čísla v hlavičce — tohle umí odjakživa),
#   • favikona se vloží jako data URI, aby v záložce nechyběla,
#   • zmizí zmínka o Metodusu z <title> a z popisu, aby stránka nevybízela
#     k hledání nadřazeného webu.
#
# Použití:  ./aktualizuj.sh   (pak zkontrolovat a teprve ručně commitnout a pushnout)

set -e
cd "$(dirname "$0")"

ZDROJ="../metodus/obsah/predstaveni.html"
IKONA="../metodus/favicon.svg"

[ -f "$ZDROJ" ] || { echo "✘ Nenašel jsem zdroj: $ZDROJ"; exit 1; }
[ -f "$IKONA" ] || { echo "✘ Nenašel jsem favikonu: $IKONA"; exit 1; }

IKONA_B64=$(base64 -w0 "$IKONA")

python3 - "$ZDROJ" "$IKONA_B64" <<'PY'
import sys, re
zdroj, ikona = sys.argv[1], sys.argv[2]
s = open(zdroj, encoding='utf-8').read()

def vyhod(vzor, popis, povinne=True):
    global s
    novy, n = re.subn(vzor, '', s, flags=re.S)
    if povinne and not n:
        raise SystemExit('✘ Ve zdroji chybí ' + popis + ' – zkontroluj, jestli se stránka nezměnila.')
    s = novy

# komentář o sdílených skriptech + oba <script src="../…">
vyhod(r'  <!-- Sdílené skripty Metodusu.*?-->\n', 'komentář o sdílených skriptech')
vyhod(r'  <script src="\.\./podpis\.js" defer></script>\n', 'odkaz na podpis.js')
vyhod(r'<script src="\.\./apps\.js"></script>\n', 'odkaz na apps.js')

# favikony ze složky Metodusu -> jedna vložená v souboru
s = s.replace(
  '  <link rel="icon" href="../favicon.svg" type="image/svg+xml">\n'
  '  <link rel="alternate icon" href="../favicon.ico" sizes="16x16 32x32 48x48">\n',
  '  <link rel="icon" type="image/svg+xml" href="data:image/svg+xml;base64,' + ikona + '">\n', 1)

# název a popis bez odkazu na nadřazený web
s = s.replace('<title>Metodus – živé ukázky</title>', '<title>Živé ukázky – výuka v prohlížeči</title>', 1)
s = s.replace('content="Ukázková stránka Metodusu:', 'content="Živé ukázky výukových aplikací:', 1)

# hlavička souboru: ať je na první pohled vidět, že jde o vyrobenou kopii
s = s.replace('<!DOCTYPE html>\n',
  '<!DOCTYPE html>\n<!-- VYROBENO skriptem aktualizuj.sh ze souboru\n'
  '     metodus/obsah/predstaveni.html. Needitovat tady – úpravy dělej ve zdroji\n'
  '     a skript spusť znovu, jinak se o ně přijde. -->\n', 1)

open('index.html', 'w', encoding='utf-8').write(s)

zbyle = [c for c in re.findall(r'(?:src|href)="([^"#]+)"', s) if not c.startswith('data:')]
if zbyle:
    raise SystemExit('✘ V index.html zůstal odkaz ven: ' + ', '.join(zbyle))
print('✔ index.html vyroben, %.0f kB, žádný odkaz ven ze souboru' % (len(s.encode()) / 1024))
PY
