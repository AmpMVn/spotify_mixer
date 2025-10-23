
SHELL := /bin/bash

# Cílové soubory
SRC_YAML      := sources.yaml
SRC_YAML_EX   := sources.example.yaml
CACHE_FILE    := .cache-spotify-mixer

# Detekce platformy (jen kvůli "open" editoru)
UNAME_S := $(shell uname -s)

# Základní nástroje
PY      ?= python3
VENV    ?= venv
PYTHON  := $(VENV)/bin/python
PIP     := $(VENV)/bin/pip

.PHONY: help
help:
	@echo ""
	@echo "Jednoduché příkazy:"
	@echo "  make first-run    -> vše nastaví a spustí (pro úplné začátečníky)"
	@echo "  make run          -> spustí mixer (po prvním nastavení)"
	@echo "  make open-config  -> otevře sources.yaml v editoru"
	@echo "  make auth-reset   -> vymaže lokální přihlášení (znovu se autorizuješ)"
	@echo "  make clean        -> smaže cache"
	@echo "  make distclean    -> smaže venv + cache"
	@echo ""

.PHONY: first-run
first-run: check-python ensure-sources venv install run
	@echo ""
	@echo "První běh hotov."

.PHONY: check-python
check-python:
	@command -v $(PY) >/dev/null 2>&1 || { echo >&2 "Nenalezen python3. Na macOS nainstaluj: brew install python"; exit 1; }

$(VENV)/bin/activate: | check-python
	@$(PY) -m venv $(VENV)
	@echo "Vytvořeno virtuální prostředí: $(VENV)"

.PHONY: venv
venv: $(VENV)/bin/activate

.venv.stamp: requirements.txt | $(VENV)/bin/activate
	@$(PIP) install -r requirements.txt
	@touch .venv.stamp
	@echo "Závislosti nainstalovány."

.PHONY: install
install: .venv.stamp

.PHONY: ensure-sources
ensure-sources:
	@test -f $(SRC_YAML) || (cp $(SRC_YAML_EX) $(SRC_YAML) && echo "Vytvořil jsem $(SRC_YAML) ze šablony. Otevři ho a doplň údaje.")
	@grep -q "YOUR_CLIENT_ID" $(SRC_YAML) && echo "*** POZOR: Ještě musíš vyplnit OAuth údaje v '$(SRC_YAML)' (client_id/client_secret)." || true

.PHONY: run
run: .venv.stamp
	@$(PYTHON) spotify_mixer.py

# Vynucení režimů přepis/přidávání bez editace YAML (dočasné přepnutí není v YAML-only verzi doporučeno).
# Pokud chceš změnit chování, uprav 'mix.overwrite' v sources.yaml.
.PHONY: run-append run-overwrite
run-append: .venv.stamp
	@echo "Tip: uprav 'mix.overwrite: false' v sources.yaml a použij 'make run'."
run-overwrite: .venv.stamp
	@echo "Tip: uprav 'mix.overwrite: true' v sources.yaml a použij 'make run'."

.PHONY: open-config
open-config:
ifeq ($(UNAME_S),Darwin)
	@open -e $(SRC_YAML)
else
	@xdg-open $(SRC_YAML) >/dev/null 2>&1 || { echo "Otevři prosím soubor '$(SRC_YAML)' v libovolném editoru."; }
endif

.PHONY: auth-reset clean distclean
auth-reset:
	@rm -f $(CACHE_FILE)
	@echo "Smazán $(CACHE_FILE). Příští běh znovu vyžádá přihlášení (autorizaci)."

clean:
	@rm -rf __pycache__ $(CACHE_FILE)
	@echo "Cache smazána."

distclean: clean
	@rm -rf $(VENV) .venv.stamp
	@echo "Odstraněno virtuální prostředí."
