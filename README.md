# Živé ukázky – samostatné nasazení

Jedna stránka se sedmi živými ukázkami výukových aplikací. Nasazuje se
**mimo hlavní web**, do vlastního repozitáře a vlastního GitHub Pages, aby
odmazávání adresního řádku nevedlo na Metodus ani na hlavní rozcestník:

```
https://lavionus.github.io/metodus-ukazka/   ← ukázka
https://lavionus.github.io/                  ← 404, odtud se nikam nedostaneš
```

(Hlavní web běží na `lavionus.github.io/site/`, Metodus na
`lavionus.github.io/metodus/`. Ani jednu z těch cest nemá návštěvník ukázky jak
uhodnout. Repozitáře na profilu GitHubu ale veřejné zůstávají – kdo bude cíleně
hledat, najde je; tohle řeší až vlastní doména.)

## Jak se stránka aktualizuje

Zdroj je **jediný**: `obsah/predstaveni.html` v repozitáři Metodusu
(`../metodus/`).
Zdejší `index.html` je z něj vyrobená kopie – needituj ji, přepíše se.

Obvykle není potřeba nic dělat ručně: `upload.sh` v repozitáři hlavního webu
nahrává všechny tři weby naráz a tenhle skript si spustí sám. Samostatně:

```bash
./aktualizuj.sh     # vyrobí index.html ze zdroje a ověří, že nevede nikam ven
git add -A && git commit -m "Aktualizace ukázky" && git push
```

`aktualizuj.sh` ze zdroje vypustí odkazy na `podpis.js` a `apps.js`, vloží
favikonu jako data URI a upraví `<title>` i popis tak, aby nevybízely
k hledání nadřazeného webu. Na konci zkontroluje, že v souboru nezůstal
jediný odkaz ven – jinak skončí chybou. Stránka je pak opravdu jeden soubor:
model buňky i všechny ukázky jsou uvnitř.

## První nasazení

```bash
gh repo create Lavionus/metodus-ukazka --public --source=. --push
gh api -X POST repos/Lavionus/metodus-ukazka/pages -f build_type=legacy \
  -f 'source[branch]=main' -f 'source[path]=/'
```

Bez `gh`: založit repozitář na githubu, `git remote add origin …`,
`git push -u origin main`, pak *Settings → Pages → Deploy from a branch →
main / (root)*. První nasazení bývá k dispozici do minuty.
