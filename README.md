# 🛠️ Sauro's Tools

Una mod di utilità, Quality of Life (QoL) e strumenti per **The Binding of Isaac: Repentance / Repentance+**, creata da **Bohsauro**.

---

## ✨ Funzionalità Quality of Life (QoL)

### 🚪 1. Treasure Room Sempre Adiacente (Piano 1)
- All'inizio di ogni run o quando resetti tenendo premuto **R**, la mappa viene verificata all'istante: la prima stanza del tesoro è **sempre garantita adiacente** alla stanza iniziale di spawn (basta varcare una delle porte laterali, superiori o inferiori).
- Non perdi più tempo a camminare per mezza mappa alla ricerca della Treasure Room.

### ⭐ 2. Filtro Qualità Minima Oggetto (Rank / Tier)
- Quando entri nella prima Treasure Room, se l'oggetto generato ha una qualità inferiore al rank impostato, la mod lo **rerolla automaticamente** estraendo dal pool del tesoro un oggetto di qualità pari o superiore!
- **Default:** **Rank 3+** (garantisce solo oggetti forti di Tier 3 o godly di Tier 4, come Brimstone, Sacred Heart, C Section, Polyphemus, Magic Mushroom, Cricket's Head, ecc.).
- Elimina la frustrazione di resettare decine di volte per trovare un oggetto decente.

---

## ⚙️ Configurazione in Gioco (Mod Config Menu)

Premendo il tasto **L** (o **F10**) durante la partita per aprire **Mod Config Menu Pure**, troverai la sezione dedicata **Sauro's Tools** con due schede:

### Scheda `Treasure QoL`
- **Adjacent Treasure (Floor 1)**: `[ON / OFF]` *(Default: ON)*
- **Min Item Quality**: `[OFF / Rank 1+ / Rank 2+ / Rank 3+ / Rank 4 Only]` *(Default: Rank 3+)*
- **Quality Scope**: `[Floor 1 Only / All Floors]` *(Default: Floor 1 Only)*

### Scheda `General`
- **Startup Message**: `[ON / OFF]`
- **Debug Mode**: `[ON / OFF]` *(mostra i log dettagliati di reseed e reroll nella console)*

---

## ⚡ Comandi da Console (Debug Console)

Premi il tasto tilde (**`~`** o **`\`**) per aprire la console di gioco:

| Comando | Descrizione |
|---|---|
| `st help` | Mostra l'elenco dei comandi disponibili |
| `st info` | Visualizza la versione e lo stato della mod |
| `st heal` | Ripristina al massimo la salute del giocatore |
| `st charge` | Ricarica completamente l'oggetto attivo nello slot primario |
| `st clear` | Elimina tutti i nemici vulnerabili nella stanza corrente |
| `st coins [n]` | Aggiunge monete (default: 10) |
| `st bombs [n]` | Aggiunge bombe (default: 5) |
| `st keys [n]` | Aggiunge chiavi (default: 5) |

---

## 🚀 Ricaricamento Rapido durante lo Sviluppo

Per applicare le modifiche senza riavviare il gioco, digita in console:
```text
luamod sauros_tools
```
