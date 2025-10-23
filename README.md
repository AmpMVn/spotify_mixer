# Spotify Dance Mixer

Tenhle nástroj umí **poskládat jeden výsledný playlist** z více tvých playlistů podle jednoduchého vzoru (např. *bachata:3,kizomba:3*).  
**Nic se neprogramuje.** Všechno se nastavuje v **jednom souboru** `sources.yaml`.

> Funguje na **macOS, Windows i Linuxu**. Potřebuješ jen **Spotify účet** a **Python 3.10+**.

---

## 0) Co to přesně dělá? (v kostce)
- Máš kategorie (např. *bachata*, *kizomba*, *salsa*). Každá kategorie má **hlavní playlist** a může mít **fallback** playlisty.
- Nadefinuješ **vzor (pattern)**, třeba: `bachata:3,kizomba:3`. To znamená: 3 skladby bachata → 3 skladby kizomba → znovu dokola…
- Skript **neopakuje** skladby v rámci jednoho běhu. Když dojdou unikátní skladby, bere z fallbacků. Když už není odkud, skončí dřív.
- Výsledek uloží do tvého Spotify jako **jeden playlist** s názvem, který si zvolíš.

---

## 1) Co potřebuju předem
1) **Spotify účet** (běžný).  
2) **Spotify Developer aplikaci** (zdarma):
   - Jdi na **developer.spotify.com** → *Dashboard* → **Create app**.
   - V *Settings* přidej **Redirect URIs** (klidně všechny tři níže) a ulož:
     ```
     http://127.0.0.1:8080/callback
     http://127.0.0.1:8123/callback
     http://127.0.0.1:8888/callback
     ```
   - Zkopíruj si **Client ID** a **Client Secret** (vložíš do `sources.yaml`).
3) **Python 3.10+**
   - **macOS**: doporučuji `brew install python`
   - **Windows**: nainstaluj z python.org (při instalaci zaškrtni **Add Python to PATH**)

> Proč ty Redirect URIs? Spotify tě při přihlášení vrátí na tvůj počítač. Proto to `127.0.0.1` (místní adresa).

---

## 2) První spuštění

### macOS / Linux (s Makefile)
V terminálu ve složce projektu spusť:
```bash
make first-run
```
Co to udělá:
- Vytvoří **virtuální prostředí** (neplete se to do tvého systému).
- Nainstaluje potřebné balíčky.
- Pokud neexistuje, vytvoří **`sources.yaml`** ze šablony.
- Spustí mixer. Při prvním běhu se v prohlížeči zeptá na povolení (autorizaci).

### Windows – vyber si **jednu** z možností
> V repozitáři už jsou připravené soubory pro začátečníky: `first-run.cmd` a `run.cmd`.

**A) „Klikátko“ (doporučeno pro ne-IT)**  
1. Dvojklik na **`first-run.cmd`**  
   - Vytvoří venv, nainstaluje balíčky, zkopíruje šablonu **`sources.example.yaml` → `sources.yaml`**.  
   - Otevře se **Notepad** – vyplň `oauth.client_id`, `oauth.client_secret`, případně `oauth.redirect_uri`/`redirect_ports`, a playlisty v `categories`. Ulož a zavři.  
   - Okno tě vyzve stisknout klávesu → proběhne první spuštění a autorizace v prohlížeči.  
2. Příště stačí dvojklik na **`run.cmd`**.

**B) Příkazový řádek / PowerShell**  
```powershell
# vytvořit virtuální prostředí
py -3 -m venv venv

# aktivovat (PowerShell):
.env\Scripts\Activate.ps1
# (v CMD: venv\Scriptsctivate.bat)

# nainstalovat balíčky
pip install --upgrade pip
pip install -r requirements.txt

# připravit konfiguraci
copy sources.example.yaml sources.yaml
notepad .\sources.yaml

# spustit
python .\spotify_mixer.py
```

> Poznámka: pokud PowerShell blokuje aktivaci venv, spusť jednou:  
> `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

---

## 3) Co je v `sources.yaml` a co tam vyplnit
`sources.yaml` obsahuje **všechno**: přihlášení do Spotify (OAuth), název cílového playlistu, vzor (pattern), počet skladeb, kategorie a playlisty.

### Minimální kostra
> Všude, kde je `YOUR_CLIENT_ID`/`YOUR_CLIENT_SECRET`, vlož údaje z Developer Dashboardu.  
> Redirect URI **musí** být stejný jako v appce.

```yaml
oauth:
  client_id: "YOUR_CLIENT_ID"
  client_secret: "YOUR_CLIENT_SECRET"
  redirect_uri: "http://127.0.0.1:8080/callback"  # Přesně jako v appce!
  # Volitelné – skript si vybere první volný port z tohoto seznamu:
  redirect_ports:
    - 8080
    - 8123
    - 8888

mix:
  playlist_name: "Mix: Bachata(3) • Kizomba(3)"  # název výsledného playlistu
  public: false                                  # má být playlist veřejný?
  pattern: "bachata:3,kizomba:3"                 # vzor: NAZEV_KATEGORIE:POCET, oddělené čárkou
  target_length: 200                             # kolik skladeb se má pokusit poskládat
  overwrite: true                                # true = přepsat playlist; false = jen přidat navrch

categories:
  bachata:
    main:
      - "https://open.spotify.com/playlist/..."   # sem vlož link na hlavní bachata playlist
    fallbacks:
      - "https://open.spotify.com/playlist/..."   # sem fallbacky (libovolně, mohou být i prázdné)
  kizomba:
    main:
      - "https://open.spotify.com/playlist/..."
    fallbacks: []
```

**Jak získám odkaz na playlist?**  
V Spotify (web/desktop/mobil) → u playlistu klikni na `…` → **Share** → **Copy link**.

> **Důležité:** v YAML **používej mezery, ne tabulátor**. Každá úroveň o 2 mezery je přehledná a bezpečná.

---

## 4) Jak to potom spustím
### macOS / Linux
```bash
make run
```
### Windows
- Dvojklik na **`run.cmd`**, **nebo**  
- v PowerShellu: `python .\spotify_mixer.py`

- Při **prvním** spuštění tě to přesměruje do prohlížeče, kde povolíš přístup (jednou za zařízení/uživatele).
- **Příště už se tě to ptát nebude**, dokud nesmažeš cache nebo nezměníš oprávnění.

---

## 5) Příklady (snadno přepsatelné)

### A) Jen bachata + kizomba, střídání 3 a 3
```yaml
mix:
  pattern: "bachata:3,kizomba:3"
  target_length: 200
```

### B) Kizomba + salsa, v poměru 2 : 1
```yaml
mix:
  pattern: "kizomba:2,salsa:1"
  target_length: 180
```

### C) Tři libovolné žánry 1:1:1 (např. zouk, ukiz, tango)
```yaml
mix:
  pattern: "zouk:1,ukiz:1,tango:1"
  target_length: 150
```

> Jména v `pattern` **musí sedět** s názvy v `categories` (malými písmeny).

---

## 6) Jak fungují fallbacky (náhradní playlisty)
- Každá kategorie může mít **více fallback** playlistů.
- Skript bere **nejdřív z hlavního** `main`. Když dojdou unikátní skladby, pokračuje z `fallbacks`.
- **Duplicitní** skladby v rámci jednoho běhu **nepřidá**.
- Když dojdou všechny zdroje dřív než `target_length`, **skončí dřív** (nevynucuje se plná délka).

---

## 7) Časté problémy a okamžité rady (FAQ)

### „Invalid redirect URI“
- V **Developer Dashboardu** musí být **přesně** stejný Redirect URI, jaký je v `sources.yaml` → `oauth.redirect_uri` (včetně portu a `/callback`).  
- Tip: přidej si (a **ulož!**) rovnou **8080, 8123, 8888**. V `redirect_ports` je můžeš nechat a skript si vybere **první volný** (ale každý z nich **musí** být whitelisted).

### „Address already in use“ (port je obsazený)
- Něco už používá například `8080`.  
- Řešení 1: do `oauth.redirect_ports` dej víc portů (8080,8123,8888) – skript si vezme volný.  
- Řešení 2 (rychlá diagnostika na macOS/Linux):
  ```bash
  lsof -nP -iTCP:8080 | grep LISTEN
  ```
  Na Windows (CMD):
  ```bat
  netstat -ano | findstr :8080
  taskkill /PID <PID> /F
  ```

### „YAML error“ / „Parser error“
- **Nepoužívej tabulátory**. Vždy mezery. Stačí 2 mezery na úroveň.
- Každý seznam piš **pomlčkami**:
  ```yaml
  fallbacks:
    - "http://..."
    - "http://..."
  ```

### „Nechci přepisovat, jen přidat navrch“
- V `sources.yaml` změň `mix.overwrite: false` a ulož.  
- Potom `make run` (macOS/Linux) nebo `python .\spotify_mixer.py` / dvojklik na `run.cmd` (Windows) přidá nové skladby za ty stávající.

### „Chci úplně nový playlist s jiným názvem“
- Změň `mix.playlist_name` (třeba „Páteční Mix“) a ulož. Při dalším běhu se vytvoří/aktualizuje ten název.

### „Na Windows se neotevře prohlížeč“
- Zkopíruj URL z konzole do prohlížeče ručně. Po přihlášení tě Spotify přesměruje zpět a skript pokračuje.

---

## 8) Užitečné příkazy
### macOS / Linux
```bash
make first-run     # kompletní první nastavení a spuštění
make run           # běžné spuštění
make open-config   # otevře sources.yaml v editoru (TextEdit na macOS)
make clean         # smaže cache
make distclean     # smaže i virtuální prostředí (když chceš „od nuly“)
```
### Windows
**Klikátko:** dvojklik na `run.cmd`  
**Příkazový řádek:**  
```powershell
py -3 -m venv venv
.env\Scripts\Activate.ps1
pip install -r requirements.txt
python .\spotify_mixer.py
```

---

## 9) Rychlá kontrola, že vše sedí
- [ ] `oauth.client_id` a `oauth.client_secret` vyplněné z Dashboardu
- [ ] `oauth.redirect_uri` přidaný **stejně** v Dashboardu (a **uložený**)
- [ ] máš vyplněné `categories` (aspoň jednu), v `main` máš **platné** playlisty
- [ ] `mix.pattern` odpovídá názvům kategorií
- [ ] `make run` / `python .\spotify_mixer.py` / dvojklik na `run.cmd` proběhne bez chyby a playlist je v účtu

---

## 10) Tipy pro praxi
- Udělej si **víc variant** `sources.yaml` (např. `bk.yaml` pro bachata+kizomba, `ks.yaml` pro kizomba+salsa). Před spuštěním si jen přejmenuj požadovaný soubor na `sources.yaml`.  
- Pro větší akce zmenši `target_length`, ať se výsledek postaví i při menším množství zdrojových skladeb.

---

**Hotovo.** Otevři `sources.yaml`, vyplň údaje, a spusť `make run` (macOS/Linux) nebo klikni na `run.cmd` / zadej `python .\spotify_mixer.py` (Windows).  
Když něco nejde, koukni do sekce „Časté problémy“, nebo napiš a pošlu fix na míru. 🎶🕺💃

---

## License
This project is released under the **PolyForm Noncommercial License 1.0.0** (SPDX: PolyForm-Noncommercial-1.0.0).  
You can use, copy, modify, and share it **for noncommercial purposes**.  
For full terms, see the `LICENSE.md` file or visit the PolyForm site.
