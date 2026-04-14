# Controlix Agent - Guide De Demarrage

Ce guide explique toutes les etapes pour utiliser l'agent Windows et l'application mobile.

## Prerequis

- Windows 10/11
- Python 64-bit 3.11+ installe
- PowerShell
- Le PC Windows et le telephone sur le meme reseau local

## 1. Installer Et Lancer L'agent

Ouvre PowerShell et execute:

```powershell
cd C:\Users\ellei\Documents\Downloads\controlix\agent
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Configure la cle secrete:

```powershell
Copy-Item .env.example .env
```

Ouvre `.env` et mets une vraie cle:

```env
CONTROLIX_SECRET_KEY=ta-cle-secrete-forte
CONTROLIX_HOST=0.0.0.0
CONTROLIX_PORT=8765
CONTROLIX_EXECUTION_TIMEOUT=90
CONTROLIX_MAX_LOG_ENTRIES=100
```

Lance l'agent:

```powershell
python run_agent.py
```

L'agent ecoute sur `http://0.0.0.0:8765`.

## 2. Trouver L'IP Du PC Windows

```powershell
ipconfig
```

Note l'adresse IPv4, par exemple `192.168.1.24`.

## 3. Lancer L'application Flutter

Depuis la racine du projet:

```powershell
cd C:\Users\ellei\Documents\Downloads\controlix
flutter pub get
flutter run
```

Sur l'ecran de connexion:

- IP: l'IPv4 du PC
- Cle secrete: la meme que `CONTROLIX_SECRET_KEY`
- Bouton: `Save & connect`

## 4. Utilisation

- Les taches sont stockees dans `agent/data/tasks.json`
- Tu peux creer, editer, supprimer des taches depuis le mobile
- Chaque tache execute un script PowerShell sur le PC
- L'historique d'execution est stocke localement sur le mobile

## 5. Tests Rapides Du Backend

```powershell
Invoke-RestMethod -Method Get `
  -Uri http://192.168.1.24:8765/health `
  -Headers @{ "X-Controlix-Key" = "ta-cle-secrete-forte" }
```

## 6. Construire Les .exe

Application Windows (Flutter):

```powershell
cd C:\Users\ellei\Documents\Downloads\controlix
powershell -ExecutionPolicy Bypass -File .\scripts\build_windows_client.ps1
```

Agent Windows:

```powershell
cd C:\Users\ellei\Documents\Downloads\controlix\agent
powershell -ExecutionPolicy Bypass -File .\build_agent.ps1
```

## 7. Erreurs Courantes

- `python --version` ouvre le Microsoft Store:
  installe Python 64-bit depuis python.org et desactive le alias Store.
- `flutter build windows` echoue:
  installe `Desktop development with C++` via Visual Studio Installer.
- Aucun acces depuis le mobile:
  verifie le pare-feu Windows et que le PC et le telephone sont sur le meme LAN.
