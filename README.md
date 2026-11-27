# NoteEdit++ 🚀
> Egy villámgyors, 100%-ban natív macOS szövegszerkesztő a legendás **Notepad++** mintájára.

A **NoteEdit++** modern **Swift 6** és **AppKit / SwiftUI** technológiára épül. Nem használ Electront, sem webes felületeket: közvetlen Apple Silicon (arm64) gépi kódra fordul, zéró indítási késleltetéssel és minimális memóriahasználattal működik.

---

## 🌟 Funkciók részletesen

### 1. Többlapos felület és Munkamenet-megőrzés
- **Notepad++ stílusú fülek**: Gyors váltás, új fül nyitása (`Cmd+N`), mentetlen módosítások vizuális jelzése (piros státuszpötty).
- **Session Snapshot & Recovery**: Kilépéskor nem kötelező elmenteni az új lapokat! A megnyitott és mentetlen lapok tartalma, kurzorpozíciója automatikusan visszaáll a következő indításkor (`~/Library/Application Support/NoteEditPlusPlus/session.json`).

### 2. Kétpaneles elrendezés (Dual View)
- A szerkesztőfelület vízszintesen két független nézetre osztható (`Cmd+Option+D` vagy Eszköztár gomb).
- Lehetővé teszi két fájl párhuzamos összehasonlítását vagy ugyanazon dokumentum két pontjának egyidejű vizsgálatát.

### 3. Munkaterület Fájlböngésző Oldalsáv (Sidebar)
- Teljes mappastruktúra bejárása és megjelenítése fa nézetben (`Cmd+Option+B`).
- Fájlok azonnali megnyitása a fülrendszerben.
- Integrált valós idejű fájlkereső és -szűrő sáv.

### 4. Sorszámozott szerkesztőfelület és Kódkezelés
- **LineNumberRulerView**: Nagy teljesítményű natív sorszámmargó.
- **Interaktív könyvjelzők**: Kattintás a margóra közvetlenül be- vagy kikapcsolja a kék könyvjelzőgömböt az adott soron!
- **Párhuzamos zárójelek kiemelése**: `()`, `[]`, `{}` párok azonnali kiemelése a kurzor mellett.
- **Ugrás a párjához**: `Cmd + B` azonnal a nyitó/csukó zárójelre ugrik.
- **Láthatatlan karakterek megjelenítése (¶)**: Szóközök (`·`), tabulátorok (`→`) és soremelések (`¬`) megjelenítése egy gombnyomással.

### 5. Könyvjelző rendszer (Bookmarks)
- Könyvjelző ki/be kapcsolása: `Cmd + M`
- Ugrás a következő könyvjelzőre: `Cmd + Option + ]`
- Ugrás az előző könyvjelzőre: `Cmd + Option + [`
- Könyvjelzőzött sorok másolása a vágólapra vagy törlése.

### 6. Erőteljes Keresés és Csere
- **Dokumentumon belüli kereső**: `Cmd + F` panel RegEx, Kis/Nagybetű, Egész szó és Körbefutó kereséssel.
- **Keresés Fájlokban (Find in Files)**: `Cmd + Shift + F`
  - Rekurzív keresés mappákban és almappákban.
  - Fájlkiterjesztés szűrés (pl. `*.swift,*.json`).
  - Találati fa: kattintásra a fájl automatikusan megnyílik a pontos sornál!

### 7. Dokumentumok összehasonlítása (Compare / Diff)
- Bármelyik két megnyitott lap összehasonlítása a beépített LCS diff algoritmussal.
- Hozzáadott (zöld), törölt (piros) és változatlan sorok vizuális kimutatása.

### 8. Sor- és Szövegműveletek
- **Sor duplikálása**: `Cmd + D`
- **Sor törlése**: `Cmd + Shift + K`
- **Sor mozgatása fel / le**: `Option + Up` / `Option + Down`
- **Sorok összefűzése**: `Cmd + J`
- **Sorok rendezése**: A -> Z, Z -> A és Numerikus rendezés.
- **Duplikált sorok és üres sorok törlése**.
- **Felesleges szóközök levágása**: sor végéről, elejéről vagy mindkettőről.
- **Kis/Nagybetű konverzió**: NAGYBETŰ (`Cmd+Shift+U`), kisbetű (`Cmd+U`), Címsor, Inverzió.
- **Tabulátorok <-> Szóközök konverzió**.
- **Dátum és idő beszúrása**.

### 9. Fejlesztői Eszközök (Developer Tools)
- **JSON formázó (Prettify)** és **tömörítő (Minify)**.
- **XML formázó**.
- **Base64 kódolás / dekódolás**.
- **URL kódolás / dekódolás**.
- **Hash generátor**: SHA-256 és MD5 számítás egy kattintásos vágólapra másolással.

### 10. Alsó Állapotsor és Kódolások
- Karakter- és sorszám: `length: X   lines: Y`
- Kurzor pozíció és kijelölés: `Ln: X   Col: Y   Sel: Z`
- **Sorvégződés-konverzió**: Windows (`CRLF`), Unix (`LF`) és Mac (`CR`).
- **Kódolások kezelése**: UTF-8, UTF-8 BOM, UTF-16 LE/BE, Windows-1250 (Közép-Európai ANSI), Windows-1252, ISO-8859-1.
- **Szintaxisválasztó**: Swift, Python, JS, TS, C/C++, JSON, XML, HTML, CSS, SQL, Shell, YAML, INI.

### 11. Témák és Beállítások
- **Notepad++ Classic (Világos)**
- **Notepad++ Dark (Sötét)**
- **Monokai**
- **Dracula**
- **Solarized Light & Solarized Dark**

---

## ⌨️ Gyorsbillentyűk összefoglalása

| Funkció | Gyorsbillentyű |
|---|---|
| Új dokumentum | `Cmd + N` |
| Megnyitás | `Cmd + O` |
| Mentés / Mentés másként | `Cmd + S` / `Cmd + Shift + S` |
| Összes mentése | `Cmd + Option + S` |
| Lap bezárása / Összes bezárása | `Cmd + W` / `Cmd + Shift + W` |
| Keresés és csere | `Cmd + F` |
| Keresés fájlokban | `Cmd + Shift + F` |
| Következő / Előző találat | `Cmd + G` / `Cmd + Shift + G` |
| Aktuális sor duplikálása | `Cmd + D` |
| Aktuális sor törlése | `Cmd + Shift + K` |
| Sor mozgatása fel / le | `Option + Up` / `Option + Down` |
| Sorok összefűzése | `Cmd + J` |
| Ugrás párhuzamos zárójelre | `Cmd + B` |
| Könyvjelző ki/be kapcsolása | `Cmd + M` |
| Következő / Előző könyvjelző | `Cmd + Option + ]` / `Cmd + Option + [` |
| Munkaterület sáv (Sidebar) ki/be | `Cmd + Option + B` |
| Kétpaneles elrendezés (Dual View) | `Cmd + Option + D` |
| NAGYBETŰS / kisbetűs | `Cmd + Shift + U` / `Cmd + U` |
| Nagyítás / Kicsinyítés / Reset | `Cmd + +` / `Cmd + -` / `Cmd + 0` |

---

## 🛠 Fordítás és Futtatás

### Alkalmazás indítása:
```bash
open NoteEdit++.app
```

### Újratelepítés / Építés:
```bash
./build_app.sh
```

### Egységtesztek futtatása (11 automatizált teszt):
```bash
swift test
```
