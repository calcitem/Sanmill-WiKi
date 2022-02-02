Calcitem Sanmill fejlesztési fehér könyv
---------------------------------------------------------------------------

Ez a dokumentum egy folyamatban lévő munka. Kérjük, hogy az ezzel kapcsolatos észrevételeket másolja a [Calcitem Sdudio](mailto:calcitem@outlook.com) címre. Köszönjük szépen!

# Bevezetés

Ez a dokumentum a Sanmill Mill Game program tervezését írja le, az algoritmus alaptervezésére összpontosítva. Leírjuk néhány olyan keresési módszer kombinációját, amelyek a tudásalapú módszerek előnyeit élvezik.

A Mill egy klasszikus "kétszemélyes zéróösszegű, teljes információval rendelkező, nem véletlenszerű" játék. A program a minimax keresési algoritmust használja a játékfa keresésére, és a játékfát Alfa-Béta metszéssel, MTD(f) algoritmusokkal, iterációs mélyítésű keresésekkel és transzpozíciós táblázatokkal optimalizálja. A Mill játékok kutatása és elemzése révén sok tervezést és optimalizálást végeztek a játék algoritmusában, a program magas szintű intelligenciát ért el. 

A teljesítmény javítása érdekében a játék algoritmus motor magja C++ használatával íródott, az alkalmazás grafikus felülete Flutter használatával íródott, és a platformcsatornát a Flutter UI és a játékmotor közötti üzenetek továbbítására használják.  

A kód teljes mennyisége körülbelül 200 000+ sor. A játék algoritmus motorját önállóan fejlesztjük. Csak a szálkezelő és UCI modulban másolt a sakkmotor Stockfish körülbelül 300 sornyi kódot.

Az UCI interfész használatának célja egy általános keretrendszer létrehozása, amelyre más Mill Game fejlesztők is hivatkozhatnak és csatlakozhatnak, hogy megkönnyítsék a játék AI motor versenyét.

# Áttekintés

## Hardveres környezet

### Android telefon

1,5 GHz-es vagy magasabb CPU

1 GB RAM vagy annál nagyobb

480x960 vagy nagyobb méretű képernyőfelbontás

Android 4.2 vagy újabb verzió

### iOS telefon

Várhatóan 2021Q3-ban támogatja az iOS-t.

### PC

A Flutter kiadás fejlesztés alatt áll. Várhatóan 2021Q2-ben jelenik meg a Microsoft Store-ban.

Qt kiadás már elérhető. Jelenleg van néhány hiba a GUI-ban, ezért általában csak az algoritmus javítása után használják önharcra, hogy teszteljék az algoritmus hatását. Ez a verzió támogatja a tökéletes AI adatbázis betöltését.

## Fejlesztési környezet

Android Studio 4.1.3
Visual Studio Community 2019
Flutter 2.0.x
Android SDK 30.0 verzió
Android NDK 21.1 verzió

## Programozási nyelv

A játékmotor C++ nyelven íródott. Az alkalmazás belépési kódja Java, a felhasználói felület pedig Dart használatával íródott. 

## Fejlesztési célok

Szórakozást és kikapcsolódást nyújtani a felhasználóknak, és népszerűsíteni ezt a klasszikus társasjátékot. 

## Jellemzők
Végrehajtani a Mill játék, támogatja az ember-AI, ember-ember, AI-AI három harci módot, támogatja a különböző Mill szabály változatok, beleértve a támogatást Kilenc férfi Morris, Tizenkét férfi Morris, támogatja a tábla, hogy vannak-e átlós vonalak, támogatja, hogy "repülő szabály", támogatja, hogy lehetővé teszi, hogy zárt Mill és más Mill szabály változatok. Támogatja az UI színének fő elemeinek beállítását, támogatja a nehézségi szint, az AI játékstílusának beállítását, a hanghatások lejátszását, az első lépés, a lépéselőzmények megjelenítésének támogatását, a statisztikai adatok megjelenítését. Támogatja az alapértelmezett beállítások visszaállítását.  A program váratlan összeomlása esetén információkat lehet gyűjteni, és a felhasználó engedélyével az e-mail kliens hívható az összeomlással kapcsolatos és diagnosztikai információk küldésére. 

## Műszaki jellemzők

A program játékmotorja játékfa keresési algoritmusokat használ, mint például az MTD(f)-et és az Alpha-Beta metszést az optimális keresési módszerek elvégzésére, a teljesítmény javítására a lépések rendezésével, az áthelyező táblázatokkal és az előhívással, valamint a keresési időtartam szabályozására a keresési módszerek iteratív elmélyítésével. A Flutter használata a felhasználói felület fejlesztéséhez a hordozhatóság javítása érdekében. 

# The Mill Game

A Malom az egyik legrégebbi, ma is játszott játék. Táblákat találtak a világ számos történelmi épületén. A legrégebbi (i. e. 1400 körül) egy egyiptomi templom tetőfedő palába vésve került elő. Másokat olyan szétszórtan találtak, mint Ceylon, Trója és Írország.

A malom egész Kínában elterjedt, a nép kedvence által kialakult "San Qi", "San San Qi", "Cheng San Qi", "Da San Qi", "San Lian", "Qi San" és sok más változat. 

A játékot egy 24 pontból álló táblán játsszák, ahová köveket lehet elhelyezni. Kezdetben a tábla üres, és mindkét játékosnak kilenc vagy tizenkét köve van. A fehér kövekkel rendelkező játékos kezd.

```
        X --- X --- X --- X
        
        | X - X - X |
        | | | | |
        | | | X-X-X | |
        X-X-X-X X-X-X-X
        | | X-X-X-X | |
        | | | | |
        | X - X - X - X |
        | | |
        X --- X --- X --- X
        
        X --- X --- X --- X
        |\ | /|
        | X - X - X |
        | |\ | /| |
        | | | X-X-X | |
        X-X-X-X X-X-X-X
        | | X-X-X | |
        | |/ | \| |
        | X - X - X |
        |/ | \|
        X --- X --- X --- X        
```

Mindkét játékos kilenc kővel kezd.

A játék három fázison megy keresztül:

* nyitó fázis

A játékosok felváltva rakják a köveket egy üres pontra.

* középjáték fázis

Miután minden követ elhelyeztek, a játékosok a köveket bármelyik szomszédos üres pontra csúsztatják.
* végjáték fázis

Amikor egy játékosnak már csak három köve van, egy követ bármelyik üres pontra ugorhat.


A megnyitás során a játékosok felváltva rakják le a köveket. A megnyitás után. a köveiket bármelyik üres pontra.

Miután minden követ elhelyeztek, a játék a középjátékra folytatódik. Itt egy játékos az egyik kövét egy szomszédos üres pontra csúsztathatja. Ha a játék során egy játékosnak bármikor sikerül három kövét egymás után elhelyeznie - ezt nevezzük malomzárnak -, eltávolíthatja az ellenfél bármelyik kövét, amely nem része a malomnak. 

Amint a játékosnak már csak három köve maradt, kezdődik a végjáték. Amikor ő van soron, a három kővel rendelkező játékos átugorhatja egyik kövét a tábla bármelyik üres pontjára.

A játék a következő módon ér véget:

* Az a játékos, akinek kevesebb mint három köve van, veszít.
* Az a játékos, aki nem tud legális lépést tenni, veszít.
* Ha egy középjáték vagy végjáték állás megismétlődik, a játszma döntetlen.

A malomrajongók között két pontról folyik vita. Az első azon a megfigyelésen alapul, hogy a megnyitásban lehetséges egyszerre két malmot lezárni. Engedélyezni kell-e ilyenkor a játékosnak, hogy eltávolítsa az ellenfél egy vagy két kövét? A mi megvalósításunk mindkettőt támogatja. A második pont azokra az állásokra vonatkozik, amikor a lépő játékos éppen bezárt egy malmot, de az ellenfél összes köve szintén malomban van. Ilyenkor eltávolíthat-e egy követ vagy sem? A mi implementációnkban ez a szabály konfigurálható. 

# Tervezési szándék

A malomnak különböző variációit játsszák. A legnépszerűbb változat - a Kilenc ember Morris - döntetlen. Ezt az eredményt az alfa-béta keresés és a végjáték-adatbázisok kombinációjával érte el [Palph Gasser](http://library.msri.org/books/Book29/files/gasser.pdf). 

A retrográd analízist az összes közép- és végjáték-állás (kb. 10 milliárd különböző állás) adatbázisainak kiszámításához használták. Ezeket a pozíciókat 28 különálló adatbázisra osztottuk, amelyeket a táblán lévő kövek száma jellemez, azaz az összes 3 fehér kő a 3 fekete kő ellen, a 4-3, 4-4 ... pozíciók, egészen a 9-9 pozíciókig.

Ezután a nyitási fázis 18 rétegű alfa-béta keresése megtalálta a kiindulási pozíció (az üres tábla) értékét. Csak a 9-9, 9-8 és 8-8 adatbázisok voltak szükségesek ahhoz, hogy megállapítsuk, hogy a játszma döntetlen.

Vannak olyan adatbázisokat használó implementációk, amelyek a verhetetlen mesterséges intelligencia tökéletesítésére szolgálnak, pl:

[King Of Muehle](https://play.google.com/store/apps/details?id=com.game.kingofmills)

http://muehle.jochen-hoenicke.de/

https://www.mad-weasel.de/morris.html

Mivel az adatbázis nagyon nagy, általában egy játékszabályhoz 80GB-os adatbázist kell építeni, ami csak PC-n használható, vagy az adatbázist a szerverre kell tenni és App-on keresztül lekérdezni. Mivel az adatbázis hatalmas, irreális az összes szabályváltozatot tartalmazó adatbázis létrehozása, ezért egy ilyen program általában csak a Nine Men's Morris standard szabályait támogatja.

A különböző szabályváltozatok támogatása a program jellemzője. Másrészt, abban az esetben, ha nem használunk hatalmas adatbázist, reméljük, hogy fejlett keresési algoritmus és emberi tudás segítségével a lehető legnagyobb mértékben javíthatjuk az intelligencia szintjét, és feloszthatjuk a nehézségi szintet, így a játékosok élvezhetik a szintlépés örömét.

Ezen kívül a PC-s Qt verzióhoz már támogatjuk a [Kilenc ember Morris játéka - A tökéletes játszó számítógép](https://www.mad-weasel.de/morris.html) által épített adatbázis használatát. Sajnos ez nem egy szabványos szabály. Nagy vonalakban követi a szabályokat, de néhány apró szabályban eltérések vannak. Meg kell jegyezni, hogy jelenleg nem rendelkezünk a standard szabályok részletes szövegével. A kitalálási szabályok szabványosságát csak más programokkal való összehasonlítással ellenőrizzük. És az adatbázishoz való hozzáférés támogatásának fő célja az AI algoritmus képességének értékelése, és az algoritmus hatásának mérése a tökéletes AI-val szembeni döntetlen arány alapján. A többi szabványos szabály adatbázisa egyelőre nem nyitott a forráskód és az interfész számára, így nem lehet csatlakoztatni.

A jövőben felhasználhatjuk a tökéletes AI adatbázis építésének algoritmusát a saját adatbázisunk létrehozásához, de ehhez az adatbázis tárolására szolgáló szerver költségei szükségesek. Nem várható, hogy rövid távon rendelkezni fogunk ezzel a tervvel. Középtávon a megvalósíthatóbb út a végjáték-adatbázison vagy [NNUE](https://en.wikipedia.org/wiki/Efficiently_updatable_neural_network) keresztül történő képzés, és az intelligencia szintjének további javítása alacsonyabb költségek mellett.

Megosztjuk és szabadon terjesztjük a Sanmill programhoz szükséges kódot, eszközöket és adatokat. Azért tesszük ezt, mert meggyőződésünk, hogy a nyílt szoftver és a nyílt adatok kulcsfontosságú összetevői a gyors fejlődésnek. Végső célunk, hogy egyesítsük a közösség erejét, és a Sanmillt egy olyan hatékony programmá tegyük, amely a világ minden táján, különösen Európában, Dél-Afrikában, Kínában és más olyan helyeken, ahol a malomjátékok széles körben elterjedtek, szórakozást nyújt a malomrajongóknak.

# Komponensek

## Algoritmus motor

A motor modul felelős azért, hogy a megadott pozíció és az állapotinformációk, például az, hogy ki játszik először, alapján megkeresse az egyik legjobb lépést, amelyet vissza kell küldeni az UI modulnak.  A következő almodulokra oszlik:

1. Bitboard

2. Kiértékelés

3. Hashtábla (feloldva).

4. Malomjáték logika

5. Mozgásgenerátor

6. Mozgásválasztó

7. Konfigurációkezelés

8. Szabálykezelés

9. Legjobb lépés keresése

10. Szálkezelés

11. Áthelyezési táblázat

12. Univerzális sakk interfész (UCI)

13. UCI opciók kezelése

## UI frontend

UI modul: A Flutter fejlesztéssel a Flutter előnyei a nagy fejlesztési hatékonyság, az Android/iOS kettős végű UI konzisztencia, a gyönyörű UI és a hasonló Native teljesítmény. 

Az UI modul a következő modulokra bomlik:

Mill Logic modul, alapvetően a Mill logikai modul Dart nyelvre lefordított algoritmus motorja; Speciálisan játék logikai modulra, Mill viselkedési modulra, pozíciókezelő modulra, lépéselőzmény modulra és így tovább.

Engine kommunikációs modul: a C++ nyelven írt játékmotorral való interakcióért felelős.

Parancsmodul: a kezelésért és a játékmotorral való interakcióért felelős parancssor;

Konfigurációkezelés: beleértve a memórián belüli konfigurációt és a Flash konfigurációkezelést;

Rajzoló modul: beleértve a tábla rajzolását és a figurák rajzolását;

Szolgáltatási modul: beleértve az audio szolgáltatásokat;

Stílus modul: beleértve a téma stílusát, színstílust;

Oldalmodulok: beleértve a táblaoldalakat, oldalmenüoldalakat, játékbeállítási oldalakat, témabeállítási oldalakat, szabálybeállítási oldalakat, súgóoldalakat, Rólunk oldalakat, licencoldalakat és különböző UI-komponenseket;

Többnyelvű adatok: Tartalmazza az angol és kínai karakterláncú szöveges erőforrásokat.

# Algoritmus tervezés

## Minimax

**Minimax**, egy algoritmus, amelyet egy [nullszaldós](https://www.chessprogramming.org/Score) játékban egy bizonyos számú lépés után a [pontszám](https://en.wikipedia.org/wiki/Zero-sum) meghatározására használnak, a legjobb játékkal egy [kiértékelő](https://www.chessprogramming.org/Evaluation) függvény szerint. Az algoritmus a következőképpen magyarázható: Egy [egylépéses](https://www.chessprogramming.org/Ply) keresésben, ahol csak az egy hosszúságú lépéssorozatokat vizsgáljuk, a lépő fél (max játékos) egyszerűen megnézheti az [értékelés](https://www.chessprogramming.org/Evaluation) értékét, miután kijátszotta az összes lehetséges [lépést](https://www.chessprogramming.org/Moves). A legjobb kiértékelésű lépés kerül kiválasztásra. De a két [lépésből álló](https://www.chessprogramming.org/Ply) keresésnél, amikor az ellenfél is lép, a dolgok bonyolultabbá válnak. Az ellenfél (min játékos) is azt a lépést választja, amelyik a legjobb értékelést kapja. Ezért az egyes lépések pontszáma most az ellenfél által elérhető legrosszabb pontszám.

### Előzmények

[Jaap van den Herik](https://www.chessprogramming.org/Jaap_van_den_Herik) szakdolgozatában (1983) részletesen ismertetjük a témával kapcsolatos ismert publikációkat. Arra a következtetésre jut, hogy bár általában [John von Neumann](https://www.chessprogramming.org/John_von_Neumann) nevéhez szokták kötni ezt a fogalmat ([1928](https://www.chessprogramming.org/Timeline#1928)) , a [primacy](https://en.wikipedia.org/wiki/Primacy_of_mind) valószínűleg [Émile Borel](https://www.chessprogramming.org/Mathematician#Borel) nevéhez fűződik. Elképzelhető továbbá az az állítás is, hogy az elsőnek járó elismerés [Charles Babbage](https://www.chessprogramming.org/Mathematician#Babbage) nevéhez fűződik. A Von Neumann által meghatározott eredeti minimax [játék végi pozíciók](https://www.chessprogramming.org/Terminal_Node) pontos értékein alapul, míg a [Norbert Wiener](https://www.chessprogramming.org/Norbert_Wiener) által javasolt minimax keresés [heurisztikus értékeléseken](https://www.chessprogramming.org/Evaluation) alapul, néhány lépéssel távolabbi, a játék végétől távolabbi pozíciókból.

### Végrehajtás

Az alábbiakban egy indirekt [rekurzív](https://www.chessprogramming.org/Recursion) [mélység-első keresés](https://www.chessprogramming.org/Depth-First) pszeudokódját mutatjuk be. Az áttekinthetőség kedvéért a rekurzív hívás előtti és utáni [lépéskészítés](https://www.chessprogramming.org/Make_Move) és [lépésfeladás](https://www.chessprogramming.org/Unmake_Move) elhagyva.

```c
int maxi( int depth ) {
    if ( depth == 0 ) return evaluate();
    int max = -oo;
    for ( all moves) {
        score = mini( depth - 1 );
        if( score > max )
            max = score;
    }
    return max;
}

int mini( int depth ) {
    if ( depth == 0 ) return -evaluate();
    int min = +oo;
    for ( all moves) {
        score = maxi( depth - 1 );
        if( score < min )
            min = score;
    }
    return min;
}
```

## Alfa-béta metszés

Az **Alfa-Béta** algoritmus (Alpha-Beta Pruning, Alpha-Beta Heuristic) a [minimax](https://www.chessprogramming.org/Minimax) keresési algoritmus jelentős továbbfejlesztése, amely kiküszöböli a [játékfa](https://www.chessprogramming.org/Search_Tree) nagy részének keresését az [branch-and-bound](https://en.wikipedia.org/wiki/Branch_and_bound) technika alkalmazásával. Figyelemre méltó, hogy mindezt anélkül teszi, hogy egy jobb [lépés](https://www.chessprogramming.org/Moves) figyelmen kívül hagyásának lehetősége nélkül. Ha valaki már talált egy elég jó lépést, és alternatívákat keres, **egy** [cáfolat](https://www.chessprogramming.org/Refutation_Move) elég ahhoz, hogy elkerülje azt. Nem kell még erősebb cáfolatokat keresni. Az algoritmus két értéket tart fenn, [alfa](https://www.chessprogramming.org/Alpha) és [béta](https://www.chessprogramming.org/Beta). Ezek jelentik a minimális pontszámot, amelyet a maximalizáló játékosnak biztosítanak, illetve a maximális pontszámot, amelyet a minimalizáló játékosnak biztosítanak. 

### Hogyan működik

Tegyük fel, hogy Fehér lép, és 2 [depth](https://www.chessprogramming.org/Depth) értékig keresünk (azaz Fehér összes lépését és Fekete összes válaszát figyelembe vesszük). Először is válasszuk ki Fehér egyik lehetséges lépését - nevezzük ezt az 1-es lehetséges lépésnek. Megvizsgáljuk ezt a lépést és a fekete minden lehetséges válaszát erre a lépésre. Ezen elemzés után megállapítjuk, hogy az 1. lehetséges lépés végrehajtásának eredménye egy páros állás. Ezután továbblépünk, és megvizsgáljuk fehér egy másik lehetséges lépését (2. lehetséges lépés). Amikor megvizsgáljuk fekete első lehetséges ellenlépését, felfedezzük, hogy ennek kijátszása azt eredményezi, hogy fekete egy figurát nyer! Ebben a helyzetben nyugodtan figyelmen kívül hagyhatjuk fekete összes többi lehetséges válaszát a 2. lehetséges lépésre, mert már tudjuk, hogy az 1. lehetséges lépés jobb. Tényleg nem érdekel minket *pontosan*, hogy a 2. lehetséges lépés mennyivel rosszabb. Lehet, hogy egy másik lehetséges válasz megnyer egy figurát, de ez nem számít, mert tudjuk, hogy az 1. lehetséges lépéssel *legalább* egy kiegyenlített játékot érhetünk el. Az 1. lehetséges lépés teljes elemzése adott egy [alsó korlátot] (https://www.chessprogramming.org/Lower_Bound). Tudjuk, hogy legalább ezt elérhetjük, így minden egyértelműen rosszabbat figyelmen kívül hagyhatunk.

A helyzet azonban még bonyolultabbá válik, ha a keresés [mélysége](https://www.chessprogramming.org/Depth) 3 vagy annál nagyobb, mert most már mindkét játékos hozhat a játékfát befolyásoló döntéseket. Most már egy [alsó korlátot](https://www.chessprogramming.org/Lower_Bound) és egy [felső korlátot](https://www.chessprogramming.org/Upper_Bound) is fenn kell tartanunk (ezeket [alfának](https://www.chessprogramming.org/Alpha) és [bétának](https://www.chessprogramming.org/Beta) nevezzük). Azért tartunk fenn alsó korlátot, mert ha egy lépés túl rossz, akkor nem vesszük figyelembe. De egy felső korlátot is fenn kell tartanunk, mert ha egy 3. mélységű vagy magasabb lépés túl jó folytatáshoz vezet, a másik játékos nem fogja megengedni, mert volt egy jobb lépés feljebb a játékfán, amit kijátszhatott volna, hogy elkerülje ezt a helyzetet. Az egyik játékos alsó határa a másik játékos felső határa.

### Takarékosság

Az alfa-béta megtakarítása jelentős lehet. Ha egy standard minimax keresési fa **x** [csomópontok](https://www.chessprogramming.org/Node), akkor egy jól megírt programban az alfa-béta fa csomópontjainak száma közel lehet **x** négyzetgyökéhez. Az azonban, hogy ténylegesen hány csomópontot vághatunk le, attól függ, hogy mennyire jól rendezett a játékfánk. Ha mindig a lehető legjobb lépést keresi először, akkor a legtöbb csomópontot kiiktatja. Persze nem mindig tudjuk, hogy mi a legjobb lépés, különben nem kellene keresnünk. Fordítva, ha mindig a rosszabb lépéseket keresnénk a jobb lépések előtt, akkor egyáltalán nem tudnánk a fa egyetlen részét sem levágni! Emiatt a jó [lépésrendezés] (https://www.chessprogramming.org/Move_Ordering) nagyon fontos, és egy jó sakkprogram megírása során sok erőfeszítést igényel. Amint arra [Levin](https://www.chessprogramming.org/Michael_Levin#Theorem) 1961-ben rámutatott, állandóan **b** lépést feltételezve minden meglátogatott csomópontra és **n** keresési mélységet, az alfa-béta maximális levélszám a minimaxnak felel meg, **b** ^ **n**. Ha mindig a legjobb lépést tekintjük elsőnek, akkor ez **b** ^ [ceil(n/2)](https://en.wikipedia.org/wiki/Floor_and_ceiling_functions) plusz **b** ^ [floor(n/2)](https://en.wikipedia.org/wiki/Floor_and_ceiling_functions) mínusz egy. A [levelek](https://www.chessprogramming.org/Leaf_Node) minimális száma a következő táblázatban látható, amely a [páratlan-páratlan hatást](https://www.chessprogramming.org/Odd-Even_Effect) is szemlélteti:

## **Negamax** keresés

Általában az egyszerűség kedvéért a [Negamax](https://www.chessprogramming.org/Negamax) algoritmust használjuk. Ez azt jelenti, hogy egy pozíció kiértékelése az ellenfél szempontjából egyenértékű a kiértékelés negációjával. Ennek oka a sakkozás zéróösszegű tulajdonsága: az egyik fél győzelme a másik fél vesztesége.

A **Negamax** keresés a [minimax](https://en.wikipedia.org/wiki/Minimax) keresés egy olyan változata, amely a [kétjátékos játék](https://en.wikipedia.org/wiki/Two-player_game) [nullaösszegű](https://en.wikipedia.org/wiki/Zero-sum_(Játékelmélet)) tulajdonságára támaszkodik.

Ez az algoritmus arra a tényre támaszkodik, hogy ![{\displaystyle \max(a,b)=-\min(-a,-b)}](https://wikimedia.org/api/rest_v1/media/math/render/svg/e64fb74b232e7412ce1967d786e07fd56b08296f) a [minimax](https://en.wikipedia.org/wiki/Minimax) algoritmus végrehajtásának egyszerűsítése érdekében. Pontosabban, egy ilyen játékban egy pozíció értéke A játékos számára a B játékos számára az érték negációja. Így a lépésben lévő játékos olyan lépést keres, amely maximalizálja a lépésből eredő érték negációját: ezt az utódpozíciót definíció szerint az ellenfélnek értékelnie kell. Az előző mondat érvelése attól függetlenül működik, hogy A vagy B van lépésen. Ez azt jelenti, hogy egyetlen eljárás használható mindkét pozíció értékelésére. Ez egy kódolási egyszerűsítés a minimaxhoz képest, amely megköveteli, hogy A a maximális értékű utódot, míg B a minimális értékű utódot választja.

Nem tévesztendő össze a [negascout](https://en.wikipedia.org/wiki/Negascout) algoritmussal, amely az 1980-as években felfedezett [alfa-béta metszés](https://en.wikipedia.org/wiki/Alpha-beta_pruning) okos felhasználásával gyorsan kiszámítja a minimax vagy negamax értéket. Megjegyzendő, hogy az alfa-béta metszés maga is egy módszer egy pozíció minimax vagy negamax értékének gyors kiszámítására azáltal, hogy elkerüljük bizonyos érdektelen pozíciók keresését.

A legtöbb [adversarial search](https://en.wikipedia.org/wiki/Adversarial_search) motor a negamax keresés valamilyen formáját használja.

### Negamax alapalgoritmus

A NegaMax ugyanazokon a [játékfákon](https://en.wikipedia.org/wiki/Game_tree) dolgozik, mint a minimax keresési algoritmus. A fa minden egyes csomópontja és gyökércsomópontja egy kétfős játék játékállapotai (például a játéktábla konfigurációja). A gyermekcsomópontokba történő átmenetek az adott csomópontból játszani készülő játékos számára elérhető lépéseket jelentik.

A negamax keresés célja a gyökércsomópontban játszó játékos számára a csomópont pontszámértékének megtalálása. Az alábbi [pszeudokód](https://en.wikipedia.org/wiki/Pseudocode) a negamax alapalgoritmust mutatja, a maximális keresési mélység konfigurálható határértékével:

```
függvény negamax(node, depth, color) a következő
    ha a mélység = 0 vagy a csomópont egy terminális csomópont, akkor
        visszaadja a color × a csomópont heurisztikus értékét
    érték := -∞
    a csomópont minden egyes gyermekére do
        value := max(value, negamax(child, depth - 1, -color))
    return -érték
```

```
(* Kezdeti hívás az A játékos gyökércsomópontjára *)
negamax(rootNode, depth, 1)
```

```
(* A B játékos gyökércsomópontjának kezdeti hívása *)
negamax(rootNode, depth, -1)
```

A gyökércsomópont a pontszámát az egyik közvetlen gyermekcsomópontjától örökli. A gyökércsomópont legjobb pontszámát végső soron meghatározó gyermekcsomópont egyben a legjobb kijátszható lépést is jelenti. Bár a bemutatott negamax függvény csak a csomópont legjobb pontszámát adja vissza, a gyakorlati negamax implementációk megtartják és visszaadják a gyökércsomópont legjobb lépését és legjobb pontszámát is. A nem gyökércsomópontok esetében csak a csomópont legjobb pontszáma lényeges. A csomópont legjobb lépését pedig nem szükséges megtartani és visszaadni a nem gyökércsomópontok esetében.

Ami zavaró lehet, az az aktuális csomópont heurisztikus értékének kiszámítása. Ebben a megvalósításban ezt az értéket mindig az A játékos szemszögéből számoljuk ki, akinek a színértéke egy. Más szóval a magasabb heurisztikus értékek mindig az A játékos számára kedvezőbb helyzeteket jelentenek. Ez ugyanaz a viselkedés, mint a normál [minimax](https://en.wikipedia.org/wiki/Minimax) algoritmus esetében. A heurisztikus érték nem feltétlenül egyezik meg egy csomópont visszatérési értékével a negamax és a szín paraméter által történő értéknegáció miatt. A negamax csomópont visszatérési értéke a csomópont aktuális játékosának szempontjából egy heurisztikus pontszám.

A negamax pontszámok megfelelnek a minimax pontszámoknak azoknál a csomópontoknál, ahol A játékos éppen játszani készül, és ahol A játékos a minimax ekvivalensben a maximalizáló játékos. A Negamax mindig a maximális értéket keresi az összes csomópontra. Ezért a B játékos csomópontjai esetében a minimax pontszám a negamax pontszámának negációja. A B játékos a minimalizáló játékos a minimax ekvivalensben.

A negamax implementációk változatai elhagyhatják a szín paramétert. Ebben az esetben a heurisztikus kiértékelő függvénynek a csomópont aktuális játékosának szemszögéből kell értékeket visszaadnia.

### Negamax alfa-béta metszéssel

A [minimax](https://en.wikipedia.org/wiki/Minimax) algoritmus-optimalizálásai a Negamaxra is ugyanúgy alkalmazhatók. Az [alfa-béta metszés](https://en.wikipedia.org/wiki/Alpha-beta_pruning) a minimax algoritmushoz hasonló módon csökkentheti a keresési fában a negamax algoritmus által kiértékelt csomópontok számát.

A mélységkorlátozott negamax keresés pszeudokódja alfa-béta metszéssel a következő:

```c
a negamax(node, depth, α, β, color) függvény a következő
    ha a mélység = 0 vagy a csomópont egy terminális csomópont, akkor
        visszaadja a színt × a csomópont heurisztikus értékét.

    childNodes := generateMoves(node)
    childNodes := orderMoves(childNodes)
    érték := -∞
    foreach child in childNodes do
        value := max(value, -negamax(child, depth - 1, -β, -α, -color))
        α := max(α, érték)
        if α ≥ β then
            break (* cut-off *)
    return value
```

```c
(* A játékos A gyökércsomópontjának kezdeti hívása *)
negamax(rootNode, depth, -∞, +∞, 1)
```

Az alfa (α) és a béta (β) a gyermekcsomópontok értékeinek alsó és felső határát jelenti egy adott fa mélységénél. A negamax a gyökércsomópont α és β argumentumait a lehető legalacsonyabb és legmagasabb értékre állítja. Más keresőalgoritmusok, mint például a [negascout](https://en.wikipedia.org/wiki/Negascout) és az [MTD-f](https://en.wikipedia.org/wiki/MTD-f), a fakeresés teljesítményének további javítása érdekében α-t és β-t alternatív értékekkel inicializálhatják.

Amikor a negamax egy alfa/béta tartományon kívüli gyermekcsomópont értékkel találkozik, a negamax keresés leáll, ezáltal a játékfa egyes részeit kivonja a felfedezésből. A levágások a csomópont visszatérési értéke alapján implicit módon történnek. A kiindulási α és β tartományon belül talált csomópontérték a csomópont pontos (vagy igaz) értéke. Ez az érték megegyezik azzal az eredménnyel, amelyet a negamax alapalgoritmus adna vissza, a levágások és α és β korlátok nélkül. Ha egy csomópont visszatérési értéke a tartományon kívül esik, akkor az érték a csomópont pontos értékének felső (ha az érték ≤ α) vagy alsó (ha az érték ≥ β) korlátját jelenti. Az alfa-béta metszés végül elveti az értékhatárokat tartalmazó eredményeket. Az ilyen értékek nem járulnak hozzá és nem befolyásolják a gyökércsomópontban lévő negamax értéket.

Ez az álkód az alfa-béta metszés fail-soft változatát mutatja. A fail-soft soha nem adja vissza α vagy β értékét közvetlenül a csomópontban. Így egy csomópont értéke kívül eshet a negamax függvényhívással beállított kezdeti α és β tartományhatárokon. Ezzel szemben a fail-hard alfa-béta metszés mindig az α és β tartományba korlátozza a csomópontértéket.

Ez az implementáció opcionális mozgási sorrendet is mutat a [foreach ciklus](https://en.wikipedia.org/wiki/Foreach_loop) előtt, amely a gyermek csomópontokat értékeli. A mozgatásrendezés az alfa-béta metszés optimalizálása, amely megpróbálja kitalálni a legvalószínűbb gyermek csomópontokat, amelyek a csomópont pontszámát adják. Az algoritmus először ezeket a gyermekcsomópontokat keresi meg. A jó tippek eredménye, hogy korábban és gyakrabban fordulnak elő alfa/béta levágások, ezáltal további játékfaágakat és megmaradt gyermekcsomópontokat metszünk ki a keresési fából.

### Negamax alfa-béta metszéssel és transzpozíciós táblázatokkal

A [transzpozíciós táblázatok](https://en.wikipedia.org/wiki/Transposition_table) szelektíven [memoizálja](https://en.wikipedia.org/wiki/Memoization) a játékfa csomópontjainak értékeit. A *Transzpozíció* kifejezés arra utal, hogy egy adott játéktábla-helyzetet többféleképpen is el lehet érni eltérő játéklépés-sorozatokkal.

Amikor a negamax a játékfán keresgél, és többször találkozik ugyanazzal a csomóponttal, egy transzpozíciós tábla visszaadhatja a csomópont korábban kiszámított értékét, kihagyva a csomópont értékének esetlegesen hosszadalmas és kétszeres újraszámítását. A Negamax teljesítménye különösen olyan játékfák esetében javul, amelyekben sok közös útvonal vezet egy adott csomóponthoz.

Az alfa/béta metszéssel a negamaxot transzpozíciós táblázattal bővítő pszeudo kód a következő:

```c
függvény negamax(node, depth, α, β, color) a következő
    alphaOrig := α

    (* Transzpozíciós táblázat keresése; a node a ttEntry keresési kulcsa *)
    ttEntry := transpositionTableLookup(node)
    ha ttEntry érvényes és ttEntry.depth ≥ depth akkor
        ha ttEntry.flag = EXACT akkor
            return ttEntry.value
        else if ttEntry.flag = LOWERBOUND then
            α := max(α, ttEntry.value)
        else if ttEntry.flag = UPPERBOUND then
            β := min(β, ttEntry.value)

        ha α ≥ β akkor
            return ttEntry.value

    ha depth = 0 vagy a csomópont terminális csomópont, akkor
        return color × a csomópont heurisztikus értéke

    childNodes := generateMoves(node)
    childNodes := orderMoves(childNodes)
    value := -∞
    for each child in childNodes do
        value := max(value, -negamax(child, depth - 1, -β, -α, -color))
        α := max(α, érték)
        ha α ≥ β akkor
            break

    (* Transzpozíciós tábla tárolása; a node a ttEntry keresőkulcsa *)
    ttEntry.value := érték
    if value ≤ alphaOrig then
        ttEntry.flag := UPPERBOUND
    else if value ≥ β then
        ttEntry.flag := LOWERBOUND
    else
        ttEntry.flag := EXACT
    ttEntry.depth := depth	
    transpositionTableStore(node, ttEntry)

    visszatérési érték
```

```
(* Kezdeti hívás az A játékos gyökércsomópontjához *)
negamax(rootNode, depth, -∞, +∞, 1)
```

Az alfa/béta metszés és a maximális keresési mélység korlátozása a negamaxban a játékfa csomópontjainak részleges, pontatlan és teljesen kihagyott kiértékelését eredményezheti. Ez megnehezíti a negamax transzpozíciós táblázat optimalizálását. Nem elegendő csak a csomópont *értékét* követni a táblázatban, mert az *érték* nem biztos, hogy a csomópont valódi értéke. A kódnak ezért meg kell őriznie és vissza kell állítania az *érték* és az alfa/béta paraméterek, valamint a keresési mélység kapcsolatát minden egyes transzpozíciós tábla bejegyzéshez.

A transzpozíciós táblázatok jellemzően veszteségesek, és a táblázatokban szereplő egyes játékfacsomópontok korábbi értékeit kihagyják vagy felülírják. Erre azért van szükség, mert a negamax által meglátogatott csomópontok száma gyakran messze meghaladja az átültetési táblázat méretét. Az elveszett vagy kihagyott táblázatbejegyzések nem kritikusak, és nem befolyásolják a negamax eredményét. Azonban az elveszett bejegyzések miatt a negamaxnak gyakrabban kell újraszámolnia bizonyos játékfacsomópontok értékeit, ami befolyásolja a teljesítményt.

### Végrehajtás

A Sanmillben az alapvető végrehajtás a következő:

```c
    for (int i = 0; i < moveCount; i++) {
        ss.push(*(pos));
        const Color before = pos->sideToMove;
        Move move = mp. moves[i]. move;
        pos->do_move(move);
        const Color after = pos->sideToMove;

        If (after != before) {
            value = -search(pos, ss, depth - 1 + epsilon, 
                            originDepth, -beta, -alpha, bestMove);
        } else {
            value = search(pos, ss, depth - 1 + epsilon, 
                           originDepth, alpha, beta, bestMove);
        }

        pos->undo_move(ss);
    
        if (value >= bestValue) {
            bestValue = érték;
    
            if (value > alpha) {
                if (depth == originDepth) {
                    bestMove = move;
                }
    
                break;
            }
        }
    }
```

> **Note**
>
> Mivel a malomban előfordulhat olyan állapot, hogy az egyik fél lezárja a malmot, majd folytatja az ellenfél bábujának elvételét, ahelyett, hogy átváltana a másik oldalra, a páratlan és páros rétegek nem feltétlenül oszlanak meg szigorúan a játék két oldalán, így meg kell határozni, hogy az iterációs folyamat után változik-e az oldal, és ezután dönteni, hogy az ellenkező számot vesszük-e el.   

## MTD(f) keresési algoritmus

Az MTD(f) egy 1994-ben Aske Plaat, Jonathan Schaeffer, Wim Pijls és Arie de Bruin által kifejlesztett minimax keresési algoritmus. Versenyminőségű sakk, dáma és Othello programokkal végzett kísérletek azt mutatják, hogy ez egy rendkívül hatékony minimax algoritmus. Az MTD(f) név az MTD(n,f) (Memory-enhanced Test Driver with n node and value f) rövidítése. Ez az alfa-béta metszési algoritmus alternatívája.

### Eredet

Az MTD(f)-t először az Albertai Egyetem technikai jelentésében írták le, amelynek szerzői Aske Plaat, Jonathan Schaeffer, Wim Pijls és Arie de Bruin voltak,[2] és amely később elnyerte az ICCA Novag 1994/1995 legjobb számítógépes sakk publikációjának díját. Az MTD(f) algoritmus az SSS* algoritmus, a George Stockman által 1979-ben feltalált legjobb-első keresési algoritmus megértésére irányuló kutatásból született. Kiderült, hogy az SSS* egyenértékű az alfa-béta hívások sorozatával, feltéve, hogy az alfa-béta olyan tárolókat használ, mint például egy jól működő transzpozíciós táblázat.

Az MTD(f) név a Memory-enhanced Test Driver (memóriával bővített tesztprogram) rövidítése, utalva Judea Pearl Test algoritmusára, amely zéróablakos keresést végez. Az MTD(f) részletes leírása Aske Plaat 1996-os doktori disszertációjában található.

### Nulla ablakos keresések

Az MTD(f) úgy éri el a hatékonyságát, hogy csak nulla ablakos alfa-béta kereséseket végez, "jó" korlát (változó béta) mellett. A NegaScoutban a keresést széles keresési ablakkal hívjuk meg, mint az AlphaBeta(root, -INFINITY, +INFINITY, depth), így a visszatérési érték az alfa és a béta értéke között van egy hívás során. Az MTD(f) esetén az AlphaBeta magas vagy alacsony értéket hibázik, és a minimax érték alsó vagy felső korlátját adja vissza. A zéróablakos hívások több levágást okoznak, de kevesebb információt adnak vissza - csak egy korlátot a minimax értékre. A minimax érték megtalálásához az MTD(f) többször is meghívja az AlphaBeta-t, konvergál hozzá, és végül megtalálja a pontos értéket. A keresési fa korábban keresett részeit egy áthelyező tábla tárolja és hívja elő a memóriában, hogy csökkentse a keresési fa egyes részeinek újbóli feltárásával járó többletköltséget.

### Kód

```c
Value MTDF(Position *pos, Sanmill::Stack<Position> &ss, Value firstguess,
           Depth depth, Depth originDepth, Move &bestMove)
{
    Value g = firstguess;
    Value lowerbound = -VALUE_INFINITE;
    Value upperbound = VALUE_INFINITE;
    Value beta;

    while (lowerbound < upperbound) {
        if (g == lowerbound) {
            béta = g + VALUE_MTDF_WINDOW;
        } else {
            béta = g;
        }
    
        g = search(pos, ss, depth, 
                   originDepth, béta - VALUE_MTDF_WINDOW, 
                   beta, bestMove);

        if (g < béta) {
            upperbound = g; // fail low
        } else {
            lowerbound = g; // fail high
        }
    }
    
    return g;
}
```

`fistguess`

Első tipp a legjobb értékre. Minél jobb, annál gyorsabban konvergál az algoritmus. Az első hívásnál lehet 0.

`depth`

A ciklus mélysége. Az [iteratív mélységű mélység-első keresés](https://en.wikipedia.org/wiki/Iterative_deepening_depth-first_search) úgy végezhető el, hogy az `MTDF()` többször hívjuk meg az `d` inkrementálásával, és az `f`-ben megadjuk a legjobb előző eredményt.

### Teljesítmény

A NegaScout rekurzívan hívja meg a nulla ablakos kereséseket. Az MTD(f) a fa gyökerétől hívja meg a nullaablakos kereséseket. Az MTD(f) algoritmus implementációi a gyakorlatban hatékonyabbnak bizonyultak (kevesebb csomópontot keresnek), mint más keresőalgoritmusok (pl. NegaScout) olyan játékokban, mint a sakk, a dáma és az Othello. Ahhoz, hogy az olyan keresőalgoritmusok, mint a NegaScout vagy az MTD(f) hatékonyan működjenek, az átültetési táblának jól kell működnie. Ellenkező esetben, például hash-ütközés esetén egy részfa újra kiterjeszkedik. Ha az MTD(f)-t olyan programokban használjuk, amelyekben kifejezett páratlan-páros hatás jelentkezik, ahol a gyökérnél a pontszám páros keresési mélység esetén magasabb, páratlan keresési mélység esetén pedig alacsonyabb, akkor célszerű külön f értékeket használni, hogy a keresést a lehető legközelebb kezdjük a minimax értékhez. Ellenkező esetben a keresés több iterációra lenne szükség ahhoz, hogy a minimax értékhez konvergáljon, különösen a finom szemcsés értékelési függvények esetében.

A zéróablakos keresések hamarabb elérik a határértéket, mint a szélesablakos keresések. Ezért hatékonyabbak, de bizonyos értelemben kevésbé elnézőek is, mint a széles ablakú keresések. Mivel az MTD(f) csak zéróablakos kereséseket használ, míg az Alpha-Beta és a NegaScout széles ablakos kereséseket is, az MTD(f) hatékonyabb. A szélesebb keresési ablakok azonban megbocsátóbbak a nagy páratlan/páratlan ingadozásokkal és finom kiértékelési függvényekkel rendelkező motorok számára. Emiatt néhány sakkmotor nem állt át az MTD(f)-re. Az olyan versenyminőségű programokkal végzett tesztekben, mint a Chinook (dáma), Phoenix (sakk) és Keyano (Othello), az MTD(f) algoritmus minden más keresési algoritmust felülmúlt.

A legújabb algoritmusok, mint például a Best Node Search (Legjobb csomópont keresés), a javaslat szerint felülmúlják az MTD(f) teljesítményét.  

## Iteratív elmélyítő mélység-első keresés

Az informatikában az iteratív mélyítő keresés, pontosabban az iteratív mélyítő mélység-első keresés (IDS vagy IDDFS) egy olyan állapottér/gráf keresési stratégia, amelyben a mélység-első keresés mélységkorlátozott változata ismételten lefut, növekvő mélységhatárokkal, amíg a célt meg nem találjuk. Az IDDFS optimális, mint a szélesség-első keresés, de sokkal kevesebb memóriát használ; minden egyes iterációban a keresési fa csomópontjait ugyanabban a sorrendben keresi fel, mint a mélység-első keresés, de a csomópontok első meglátogatásának kumulatív sorrendje ténylegesen szélesség-első.

### Algoritmus irányított gráfokhoz

```c
IDDFS(root) függvény
    for depth 0 és ∞ között do
        found, remaining ← DLS(root, depth)
        if found ≠ null then
            return found
        else if not remaining then
            return null

függvény DLS(node, depth) is
    if depth = 0 then
        if node is a goal then
            return (node, true)
        else
            return (null, true) (Nem található, de lehetnek gyermekei)

    else if depth > 0 then
        any_remaining ← false
        foreach child of node do
            found, remaining ← DLS(gyermek, depth-1)
            if found ≠ null then
                return (found, true)   
            if remaining then
                any_remaining ← true (Legalább egy csomópontot találtunk a mélységben, hagyjuk, hogy az IDDFS mélyítsen).
        return (null, any_remaining)
```

Ha a célcsomópontot megtaláltuk, akkor **DLS** a rekurziót további iterációk nélkül visszaadja. Ellenkező esetben, ha legalább egy csomópont létezik az adott mélységi szinten, a *maradó* jelző hagyja, hogy az **IDDFS** folytassa.

A [2-tuples](https://en.wikipedia.org/wiki/Tuple) hasznos visszatérési értékként jelzi az **IDDFS**-nek, hogy folytassa a mélyítést vagy álljon le, ha a fa mélysége és a céltagság *a priori* ismeretlen. Egy másik megoldás a [sentinel values](https://en.wikipedia.org/wiki/Sentinel_value) értékeket használhatná a *nem talált* vagy a *maradó szint* eredmények ábrázolására.

### Tulajdonságok

Az IDDFS egyesíti a mélység-első keresés helytakarékosságát és a szélesség-első keresés teljességét (ha az elágazási tényező véges). Ha létezik megoldás, akkor a legkevesebb ívvel rendelkező megoldási utat keresi.

Mivel az iteratív mélységi keresés többször is meglátogatja az állapotokat, pazarlásnak tűnhet, de kiderül, hogy nem is olyan költséges, mivel egy fában a csomópontok többsége az alsó szinten van, így nem sokat számít, ha a felső szinteket többször is meglátogatjuk.

Az IDDFS fő előnye a játékfakeresésben az, hogy a korábbi keresések általában javítják az általánosan használt heurisztikákat, például a gyilkos heurisztikát és az alfa-béta metszést, így a végső mélységi keresésnél pontosabb becslés történhet a különböző csomópontok pontszámára, és a keresés gyorsabban befejeződik, mivel jobb sorrendben történik. Az alfa-béta metszés például akkor a leghatékonyabb, ha először a legjobb lépéseket keresi.

A második előny az algoritmus reakciókészsége. Mivel a korai iterációk kis d értékeket használnak, rendkívül gyorsan végrehajtódnak. Ez lehetővé teszi, hogy az algoritmus szinte azonnal korai jelzéseket adjon az eredményről, majd a d növekedésével finomításokat végezzen. Interaktív környezetben, például egy sakkozó programban használva ez a lehetőség lehetővé teszi, hogy a program bármikor játszhasson az eddig elvégzett keresés során talált aktuális legjobb lépéssel. Ez úgy fogalmazható meg, hogy a keresőmag minden egyes mélységével a megoldás egyre jobb közelítését produkálja, bár az egyes lépéseknél végzett munka rekurzív. Ez nem lehetséges a hagyományos mélység-első keresésnél, amely nem hoz közbenső eredményeket.

> **Jegyzet**
>
> Az egyik elmélet szerint a kis felsorolási mélységtől a nagy felsorolási mélységig a játékfát teljes egészében átkutatjuk, és a csomópontok általános sorrendjét sekély kereséssel kapjuk meg, amit heurisztikus információként használunk fel a mély átjárásnál, ami fokozza az Alpha-Béta metszés hatását.  Mivel azonban a következőkben említett Mill move rendezés az Alpha-Beta metszés hatásának felgyorsítására nagyon jelentős, így ez a módszer nem túl hatékony, ezért a programot nem használják. 

## Mozgásrendezés

Ahhoz, hogy az [alfa-béta](https://www.chessprogramming.org/Alpha-Beta) algoritmus jól teljesítsen, először a [legjobb lépéseket](https://www.chessprogramming.org/Best_Move) kell megkeresni. Ez különösen igaz a [PV-csomópontok](https://www.chessprogramming.org/Node_Types#PV) és a várható [vágott csomópontok](https://www.chessprogramming.org/Node_Types#CUT) esetében. A cél az, hogy közel kerüljünk a minimális fához. Másrészt - a Cut-csomópontoknál - a legjobb lépés nem mindig a legolcsóbb cáfolat, lásd például [enhanced transposition cutoff](https://www.chessprogramming.org/Enhanced_Transposition_Cutoff). **A legfontosabb** egy [iteratív elmélyítés](https://www.chessprogramming.org/Iterative_Deepening) kereten belül az, hogy az előző [iteráció](https://www.chessprogramming.org/Iteration) [fő variációját](https://www.chessprogramming.org/Principal_Variation) próbáljuk meg a következő iteráció baloldali útjaként, amit alkalmazhatunk explicit [háromszög PV-táblázat](https://www.chessprogramming.org/Triangular_PV-Table) vagy implicit [transzpozíciós táblázat](https://www.chessprogramming.org/Transposition_Table) segítségével.

 ### Tipikus lépéssorrend

A [lépésgenerálás](https://www.chessprogramming.org/Move_Generation) után a sakkprogramok a hozzárendelt lépéspontszámokkal általában nem a teljes [lépéslistát](https://www.chessprogramming.org/Move_List) rendezik, hanem minden egyes lépés lehívásakor [kiválasztási rendezést](https://en.wikipedia.org/wiki/Selection_sort) végeznek. Kivételt képeznek a [Gyökér](https://www.chessprogramming.org/Root) és a távolabbi [PV-csomópontok](https://www.chessprogramming.org/Node_Types#PV), amelyek bizonyos távolságban vannak a látóhatártól, ahol további erőfeszítéseket lehet tenni a lépések pontozására és rendezésére. Teljesítőképességi okokból sok program megpróbálja megspórolni a [lépésgenerálást](https://www.chessprogramming.org/Move_Generation) a várható [Cut-Node-oknál](https://www.chessprogramming.org/Node_Types#CUT) történő elfogások vagy nem elfogások esetén, de először a hash-move-ot vagy a killer-t próbálja ki, ha azok ebben az állásban legálisnak bizonyulnak.

A Sanmillben a lépés kihasználja az emberi tudást, és a sorrend a következőképpen áll:

1. Lehet, hogy a saját oldalán, hogy lezárja több malom;

2. megakadályozhatja, hogy az ellenfél több malmot zárjon;

3. Amennyire csak lehetséges, a másik oldal a tiltott ponttal szomszédos, mert a tiltott pont a mozgási fázisban üres lesz;

4. Vegye az ellenfél bábu és a saját bábu csak zárja malmok;

5. Vegyük az ellenfél bábuját és a saját bábu szomszédos;

6.	Prioritás, hogy vegye az ellenfél képességét, hogy erősen mozog, azaz szomszédos az üres számok száma;
   Ezen túlmenően, a következő módszerrel próbálják választani, hogy csökkentse az elsőbbséget:
   
7. Ha a másik fél bábu és a másik fél három egymást követő szomszédos, próbálja meg nem venni;

8.	Ha a másik fél a vevő bábu és a saját bábu nem szomszédos, inkább ne vegye;

* Ha a módszer azonos prioritású, vegye figyelembe a következő tényezőket:

* Ossza fel a sakktábla számolását fontos pontokra, és rangsorolja a magas prioritású pontokat. Minél több pont szomszédos, annál magasabb a prioritás. 

* Ha a prioritás azonos, akkor a konfigurációtól függően alapértelmezés szerint használjon véletlenszerű rendezést, hogy megakadályozza, hogy az emberek újra és újra ugyanazon a győztes úton nyerjenek, javítva ezzel a játszhatóságot. 

A malmi lépésválogatás a Move Picker modulban van megvalósítva. 

## Értékelés

**Értékelés**, egy [heurisztikus függvény](https://en.wikipedia.org/wiki/Heuristic_(computer_science)) egy [pozíció](https://www.chessprogramming.org/Chess_Position) [relatív értékének](https://www.chessprogramming.org/Score), azaz a győzelem esélyének meghatározására. Ha minden sorban a játszma végéig látnánk, akkor az értékelésnek csak -1 (veszteség), 0 (döntetlen) és 1 (győzelem) értékei lennének, és a motornak csak az 1. mélységig kellene keresnie, hogy a legjobb lépést kapja. A gyakorlatban azonban nem ismerjük egy pozíció pontos értékét, ezért közelítést kell tennünk, amelynek fő célja az állások összehasonlítása, és a motornak most mélyen kell keresnie, és meg kell találnia a legmagasabb pontszámú pozíciót egy adott időszakon belül.

Az utóbbi időben két fő módja van az értékelés felépítésének: hagyományos és többrétegű [neurális hálózatok](https://www.chessprogramming.org/Neural_Networks). Ez az oldal a hagyományos módszerre összpontosít, figyelembe véve a **a két fél közötti bábuk számának különbségét** explicit jellemzőit. 

A kezdő sakkozók ezt maguknak a [bábuknak](https://www.chessprogramming.org/Pieces) az [értékéből](https://www.chessprogramming.org/Point_Value) kiindulva tanulják meg. A számítógépes kiértékelő függvények szintén az [anyagi egyensúly](https://www.chessprogramming.org/Material) értékét használják a legjelentősebb szempontként, majd további szempontokkal egészítik ki. 

### Hol kezdjük

Az első dolog, amit egy értékelő függvény megírásakor mérlegelni kell, hogy hogyan értékeljünk egy lépést a [Minimax](https://www.chessprogramming.org/Minimax) vagy az elterjedtebb [NegaMax](https://www.chessprogramming.org/Negamax) keretrendszerben. Míg a Minimax általában a fehér oldalt a max-játékoshoz, a feketét pedig a min-játékoshoz társítja, és mindig a fehér oldal szempontjából értékel, addig a NegaMax a [lépő oldal](https://www.chessprogramming.org/Side_to_move) tekintetében szimmetrikus értékelést igényel. Láthatjuk, hogy nem önmagában a lépést kell értékelni - hanem a lépés eredményét (azaz a tábla pozícióértékelését a lépés eredményeként). 

### Side to move relative

Ahhoz, hogy a [NegaMax](https://www.chessprogramming.org/Negamax) működjön, fontos, hogy az értékelt oldalhoz képest adja vissza a pontszámot. Vegyünk például egy egyszerű kiértékelést, amely csak az [anyag](https://www.chessprogramming.org/Material) és a [mozgékonyság](https://www.chessprogramming.org/Mobility) értékeket veszi figyelembe:

```c
materialScore = 5 * (wPiece-bPiece)

mobilityScore = mobilityWt * (wMobility-bMobility) [Jelenleg nem implementált]
```

*a [mozgatandó oldalhoz viszonyított pontszám visszaadása](https://www.chessprogramming.org/Side_to_move) (who2Move = +1 fehérnek, -1 feketének):*

```
Eval = (materialScore + mobilityScore) * who2Move
```

A pozíciókiértékelést az Evaluation modul valósítja meg. 

## Áthelyezési táblázat

A **Transposition Table**, amelyet először [Greenblatt](https://www.chessprogramming.org/Richard_Greenblatt) [Mac Hack VI](https://www.chessprogramming.org/Mac_Hack#HashTable) programjában használtak, egy olyan adatbázis, amely a korábban elvégzett keresések eredményeit tárolja. Ez egy módja annak, hogy a [sakkfa](https://www.chessprogramming.org/Search_Tree) keresési terét nagymértékben csökkentsük, kevés negatív hatással.  A programok a [nyers erő](https://www.chessprogramming.org/Brute-Force) keresés során újra és újra találkoznak ugyanazokkal a [pozíciókkal](https://www.chessprogramming.org/Chess_Position), de különböző [lépéssorozatokból](https://www.chessprogramming.org/Moves), amit [transzpozíciónak](https://www.chessprogramming.org/Transposition) nevezünk. A transzpozíció (és a [cáfolat](https://www.chessprogramming.org/Refutation_Table)) táblázatok a [dinamikus programozásból](https://www.chessprogramming.org/Dynamic_Programming) származó technikák, amely kifejezést [Richard E. Bellman](https://www.chessprogramming.org/Richard_E._Bellman) alkotta meg az 1950-es években, amikor a programozás tervezést jelentett, és a dinamikus programozást többlépcsős folyamatok optimális tervezésére találták ki.

### Hogyan működik

Amikor a keresés egy [transzpozícióval](https://www.chessprogramming.org/Transposition) találkozik, előnyös, ha "emlékszik" arra, hogy mit határoztak meg a pozíció legutóbbi vizsgálatakor, ahelyett, hogy a teljes keresést újra elvégezné. Ezért a sakkprogramok rendelkeznek egy transzpozíciós táblával, amely egy nagy [hash-tábla](https://www.chessprogramming.org/Hash_Table), amely információkat tárol a korábban keresett pozíciókról, arról, hogy milyen mélységben kerestük őket, és hogy mire következtettünk velük kapcsolatban. Még ha a kapcsolódó transzpozíciós tábla bejegyzésének [mélysége](https://www.chessprogramming.org/Depth) (vázlat) nem is elég nagy, vagy nem tartalmazza a megfelelő határértéket egy cutoffhoz, egy [legjobb](https://www.chessprogramming.org/Best_Move) (vagy elég jó) lépés egy korábbi keresésből javíthatja a [lépésrendezést](https://www.chessprogramming.org/Move_Ordering), és keresési időt takaríthat meg. Ez különösen igaz egy [iteratív elmélyítés](https://www.chessprogramming.org/Iterative_Deepening) keretrendszerben, ahol az előző iterációkból értékes táblázat találatokat nyerünk.

### Hash függvények

A [Hash függvények](https://en.wikipedia.org/wiki/Hash_function) a sakkpozíciókat szinte egyedi, skaláris aláírásra alakítják át, lehetővé téve a gyors indexszámítást, valamint a tárolt pozíciók helytakarékos ellenőrzését.

- [Zobrist Hashing](https://www.chessprogramming.org/Zobrist_Hashing)
- [BCH Hashing](https://www.chessprogramming.org/BCH_Hashing)

Mind az elterjedtebb Zobrist hashing, mind a BCH hashing gyors hash-függvényeket használ, hogy a sakkpozíciók egyfajta [Gödel-számaként](https://en.wikipedia.org/wiki/Gödel_number) hash-kulcsokat vagy aláírásokat adjon, manapság jellemzően [64 bites](https://www.chessprogramming.org/Quad_Word) széles, Mill esetében 32 bites is elég. Ezek [inkrementálisan frissülnek](https://www.chessprogramming.org/Incremental_Updates) a [make](https://www.chessprogramming.org/Make_Move) és [unmake lépés](https://www.chessprogramming.org/Unmake_Move) során vagy saját-inverz [exkluzív vagy](https://www.chessprogramming.org/General_Setwise_Operations#ExclusiveOr) vagy összeadással versus kivonással.

### Címszámítás

Az index nem a teljes hash-kulcson alapul, mert ez általában 64 vagy 32 bites szám, és a jelenlegi hardverkorlátozások mellett egyetlen hash-tábla sem lehet elég nagy ahhoz, hogy ezt befogadja. Ezért a cím vagy az index kiszámításához [modulo](https://en.wikipedia.org/wiki/Modulo_operator) számú bejegyzésre van szükség, a kettő hatványa méretű táblázatokhoz a hash-kulcs alsó része, amelyet egy 'és'-utasítással megfelelően maszkolunk.

### Ütközések

A [szürjektív](https://en.wikipedia.org/wiki/Surjection) leképezés a pozíciókról az aláírásra és egy még sűrűbb indextartományra **ütközésekkel** jár, különböző pozíciók osztoznak ugyanazon bejegyzéseken, két különböző okból, remélhetőleg ritka kétértelmű kulcsok (1. típusú hibák), vagy rendszeresen kétértelmű indexek (2. típusú hibák).

### Milyen információk tárolódnak

Általában a következő információk kerülnek tárolásra a [search](https://www.chessprogramming.org/Search) által meghatározott módon:

- [Zobrist-](https://www.chessprogramming.org/Zobrist_Hashing) vagy [BCH-key](https://www.chessprogramming.org/BCH_Hashing), hogy megnézzük, hogy a pozíció a megfelelő-e a keresés során.
- [Best-](https://www.chessprogramming.org/Best_Move) vagy [Cáfoló lépés](https://www.chessprogramming.org/Refutation_Move) [jelenleg nem valósul meg].
- [Mélység](https://www.chessprogramming.org/Depth) (tervezet)
- [Score](https://www.chessprogramming.org/Score), *vagy *az [Integrated Bound and Value](https://www.chessprogramming.org/Integrated_Bounds_and_Values) *vagy másképp *az [Integrated Bound and Value](https://www.chessprogramming.org/Integrated_Bounds_and_Values) segítségével
- [Csomópont típusa](https://www.chessprogramming.org/Node_Types)

- [Age](https://www.chessprogramming.org/Transposition_Table#Aging) annak meghatározására szolgál, hogy a játék során mikor kell felülírni a korábbi pozíciók kereséséből származó bejegyzéseket.

### A táblázat bejegyzési típusai

Az [alfa-béta keresés](https://www.chessprogramming.org/Alpha-Beta) során általában nem találjuk meg egy pozíció pontos értékét. De örülünk, ha tudjuk, hogy az érték vagy túl alacsony, vagy túl magas ahhoz, hogy további kereséssel foglalkozzunk. Ha megvan a pontos érték, akkor azt természetesen eltároljuk az áthelyezési táblázatban. De ha a pozíciónk értéke vagy elég magas ahhoz, hogy beállítsuk az alsó korlátot, vagy elég alacsony ahhoz, hogy beállítsuk a felső korlátot, akkor jó, ha ezt az információt is tároljuk. Tehát az átültetési táblázat minden egyes bejegyzését azonosítjuk a [csomópont típusa](https://www.chessprogramming.org/Node_Types), gyakran nevezzük [pontos](https://www.chessprogramming.org/Exact_Score), [alsó](https://www.chessprogramming.org/Lower_Bound)- vagy [felső korlát](https://www.chessprogramming.org/Upper_Bound) értéknek.

### Helyettesítő stratégiák

Mivel az átültetési táblában korlátozott számú bejegyzés van, és mivel a modern sakkprogramokban ezek nagyon gyorsan megtelhetnek, szükség van egy olyan sémára, amellyel a program eldöntheti, hogy mely bejegyzéseket lenne a legértékesebb megtartani, azaz egy csere-sémára. A csere sémák az indexütközés megoldására szolgálnak, amikor a program olyan pozíciót próbál tárolni a táblázat olyan helyére, amelyben már van egy másik bejegyzés. A helyettesítési sémáknak két ellentétes megfontolása van:

- A nagy mélységig keresett bejegyzések több munkát takarítanak meg egy tábla találatonként, mint az alacsony mélységig keresett bejegyzések.
- A fa leveleihez közelebb eső bejegyzéseket nagyobb valószínűséggel keressük többször, így a rájuk vonatkozó táblázat találatok száma magasabb lesz. A nemrégiben keresett bejegyzéseket is nagyobb valószínűséggel keresik újra.
- A legtöbb jól működő csere stratégia e megfontolások kombinációját használja.

### Végrehajtás

A játékfában sok csomópontot különböző utakon érünk el, de a pozíciójuk pontosan ugyanaz, és ha a csomópontok a játékfával azonos szinten vannak, akkor a pontszámok is megegyeznek.  Az alfa-béta keresés során a Program egy transzpozíciós táblázatot használ a hierarchia, a pontszámok és az értéktípusok elmentésére a keresett csomópont pozíciójához. A későbbi játékfa-keresés során először keresse meg az átültetési táblázatot, ha a megfelelő pozíciót már rögzítette, és a rekord és a keresett csomópont szintje megegyezik vagy közelebb van a levélcsomóponthoz, akkor közvetlenül válassza ki az átültetési táblázatot a megfelelő pontszám rögzítéséhez; Ellenkező esetben a pozícióhoz tartozó hierarchia, pontszám és értéktípus információk az átültetési táblázatba kerülnek. Az alfa-béta keresés során a játékfa egy csomópontja három eset valamelyikében fordul elő: 

* BOUND_UPPER
 a csomópont pontszáma ismeretlen, de nagyobb vagy egyenlő a Bétával; 

* BOUND_LOWER
  a csomópont pontszáma ismeretlen, de kisebb vagy egyenlő az alfával; 

* BOUND_EXACT
  a csomópont pontszáma ismert, alfa <- a csomópont pontszáma <-béta, ami a pontos érték. 

A `BOUND_EXACT` típus, az aktuális csomópont pontos pontszámaként letétbe helyezhető az átviteli táblázatban, a `BOUND_UPPER`, `BOUND_LOWER` megfelelő határértékek még mindig segíthetnek a további metszésben, de az átviteli táblázatba is betehető, így az átviteli táblázat rekordjainak szükségük van egy flagre az értéktípus, azaz a pontos érték, vagy az 1) eset felső határa, vagy a 2) eset alsó határa ábrázolásához. A keresés során ellenőrizze, hogy a transzpozíciós táblázatban elmentett eredmények közvetlenül az aktuális csomópont értékét képviselik-e, vagy az aktuális csomópont alfa-béta metszést eredményez, és ha nem, folytassa a csomópont keresését. A transzpozíciós táblákban való keresés mielőbbi megvalósítása érdekében a transzpozíciós táblát TT hash-táblatömbként kell kialakítani, és az `TT(kulcs)` tömbelem a megfelelő hierarchiát, pontszámot és értéktípust tárolja a pozíciókulcs alatt.  Egy pozícióra vonatkozó információ alapján gyorsan megtalálja a megfelelő rekordokat a Hash-táblában.  A Zobrist Hash-módszer segítségével építsünk egy 32 bites véletlen számokból álló tömböt, `Key psq` , `PIECE_TYPE_NB` és `SQUARE_NB`, a `PieceType` típusú darabok 32 bites véletlen értékével a tábla `(x, y)` koordinátáiban.    A táblán jelenlévő összes bábutípus véletlen számától eltérni, illetve az eredményeket a 32 bites változó kulcsában elmentve a pozíció jellemzője kapható. Így amikor egy 1 típusú bábu `(x1, y1)`-ről `(x2, y2)`-re mozog, egyszerűen a következőket kell tennünk az aktuális `BoardKey` értékre:

1) A mozgatandó bábut eltávolítjuk a tábláról, a kulcs `psq(type1) x1`, ("bitkülönbséget vagy műveletet jelent, ugyanúgy, mint alább"; 

2) Ha a célkoordináták között vannak más típusú darabok, amelyeket szintén eltávolítunk, a kulcs `psq` . 

3) Helyezzük a célkoordinátákba az áthelyezett darabokat, kulcs s, psq s, type1 s x2 s y2.  A disszidens vagy műveletek nagyon gyorsan végzik a számítógépen belül, ami felgyorsítja a számítógép számításait. 

A kulcs értéke ugyanaz a pozíció, a megfelelő malomsor eltérő lehet, ezért definiáljon a3 2 bites oldalkonstansot, amikor a vonal oldali átalakítás, a kulcs és az oldal vagy.

Mivel a darabszám, hogy egy fél jelenleg ugyanazon a pozícióban különböző, azt más pozíciónak kell tekinteni, a probléma megoldása érdekében a program azt a módszert használja, hogy a 32 bites kulcs magas két bitjét használja az aktuális pozícióban felvehető gyermekek számának tárolására. 

A fent említett MTD(f) algoritmus a keresés során fokozatosan közelít a keresett értékhez, és sok csomópontot többször is meg lehet keresni. Ezért a Program ezt a Hash-alapú transzpozíciós táblát használja arra, hogy a keresett csomópontokat a memóriában tartsa, így azok az újbóli kereséskor közvetlenül kivehetők, és elkerülhető az újbóli keresés. 

## Előhívás

Fontos teljesítménynövelést használ a Program a szükséges adatoknak a processzorhoz közeli gyorsítótárba helyezésével. az előhívás (prefetching) jelentősen csökkentheti az adatok eléréséhez szükséges időt. A legtöbb modern processzor háromféle memóriával rendelkezik:

- Az 1. szintű gyorsítótárazás jellemzően az egyciklusú hozzáférést támogatja.
- A másodlagos gyorsítótár támogatja a kétciklusú hozzáférést
- A rendszermemória támogatja a hosszabb elérési időt

A hozzáférési késleltetés minimalizálása és ezáltal a teljesítmény javítása érdekében érdemes az adatokat a legközelebbi memóriában tartani. Ennek a feladatnak a manuális elvégzését előkúszásnak nevezzük. A GCC támogatja az adatok manuális előretörését a beépített `__builtin_prefetch` függvényen keresztül.  

A program az alfa-béta keresési fázisban a rekurzív hívás mélyebb keresés, az első módszer generátor által generált generátor végrehajtása a pozíciója kulcsfontosságú kézi pre-crawl, javítja a teljesítményt.

A GCC-ben az adat-előhívás keretrendszere támogatja a különböző célok képességeit. A GCC-n belüli optimalizációk, amelyek az adatok előretöltésével járnak, a vonatkozó információkat átadják a célspecifikus előretöltés-támogatásnak, amely vagy kihasználja, vagy figyelmen kívül hagyja azokat. A GCC célprogramok adatelőhívás-támogatásáról szóló információkat eredetileg a GCC `prefetch` RTL-mintájának operandusainak meghatározásához gyűjtöttük össze, de továbbra is hasznosak lehetnek azok számára, akik új előhívás-optimalizációkat adnak hozzá.

## Bitboardok

A **Bitboardok**, más néven bitkészletek vagy bitmaps, vagy még inkább **Square Sets**, többek között arra szolgálnak, hogy egy sakkprogramon belül a [táblát](https://www.chessprogramming.org/Chessboard) **tábla-centrikus** módon ábrázolják. A bittáblák lényegében [véges halmazok](https://en.wikipedia.org/wiki/Finite_set), amelyek legfeljebb [64](https://en.wikipedia.org/wiki/64_(szám))-ból állnak. [elemek](https://en.wikipedia.org/wiki/Element_(matematika)) - a [sakktábla](https://www.chessprogramming.org/Chessboard) összes [négyzete](https://www.chessprogramming.org/Squares), négyzetenként egy [bit](https://www.chessprogramming.org/Bit). Más, nagyobb táblaméretű [játékok](https://www.chessprogramming.org/Games) is használhatnak halmazonkénti ábrázolást, de a klasszikus sakknak megvan az az előnye, hogy egy [64 bites szó](https://www.chessprogramming.org/Quad_Word) vagy regiszter lefedi az egész táblát. Még inkább bittábla-barát a [Dáma](https://www.chessprogramming.org/Checkers) 32 bites bittáblával és kevesebb [bábu-típussal](https://www.chessprogramming.org/Pieces#PieceTypeCoding), mint a sakk.

### A készletek táblája

A [tábla ábrázolásához](https://www.chessprogramming.org/Board_Representation) általában minden [bábu-típushoz](https://www.chessprogramming.org/Pieces#PieceTypeCoding) és [színhez](https://www.chessprogramming.org/Color) szükségünk van egy bittáblára - valószínűleg egy osztály vagy struktúra belsejében, vagy egy [tömb](https://www.chessprogramming.org/Array) bittáblákból álló [tömbként](https://www.chessprogramming.org/Array) egy pozíció objektum részeként. Egy bit egy bit táblán belül azt jelenti, hogy az adott bábu-típusú bábu létezik egy adott négyzetben - egy az egyhez a bit-pozíció által társítva.

- [Térleképezési megfontolások](https://www.chessprogramming.org/Square_Mapping_Considerations)
- [Standard tábla-definíció](https://www.chessprogramming.org/Bitboard_Board-Definition)

### Bitboard alapjai

Természetesen a bitboardok nem csak a darabok létezéséről szólnak - ez egy általános célú, **halmazszerű** adatstruktúra, amely egy 64 bites regiszterbe illeszkedik. Egy bitboard például olyan dolgokat reprezentálhat, mint támadó- és védekező készletek, mozgó-célhalmazok és így tovább.

### Bitboard-történelem

A [bitkészletek](https://www.chessprogramming.org/Mikhail_R._Shura-Bura#Bitsets) általános megközelítését [Mikhail R. Shura-Bura](https://www.chessprogramming.org/Mikhail_R._Shura-Bura) javasolta 1952-ben. Úgy tűnik, hogy a bittáblás módszert egy társasjáték lebonyolítására szintén 1952-ben találta fel [Christopher Strachey](https://www.chessprogramming.org/Christopher_Strachey), aki a [Ferranti Mark 1](https://www.chessprogramming.org/Ferranti_Mark_1) dámajáték programjában a fehér, fekete és király bittáblákat használta, majd az 1950-es évek közepén [Arthur Samuel](https://www.chessprogramming.org/Arthur_Samuel) is a dámajáték programjában. A számítógépes sakkban a bittáblákat először [Georgy Adelson-Velsky](https://www.chessprogramming.org/Georgy_Adelson-Velsky) és társai írták le 1967-ben, újranyomtatva 1970-ben. Bitboardokat használtak a [Kaissa](https://www.chessprogramming.org/Kaissa) és a [Chess](https://www.chessprogramming.org/Chess_(Program)) programban. A [Robert Hyatt](https://www.chessprogramming.org/Robert_Hyatt) és [Peter Gillgasch](https://www.chessprogramming.org/Peter_Gillgasch) által [Ernst A. Heinz](https://www.chessprogramming.org/Ernst_A._Heinz) közreműködésével a 90-es években feltalált és publikált [Rotated Bitboards](https://www.chessprogramming.org/Rotated_Bitboards) újabb mérföldkő volt a bitboardok történetében. [Steffan Westcott](https://www.chessprogramming.org/Steffan_Westcott) újításait, amelyek 32 bites [x86](https://www.chessprogramming.org/X86) processzorokon túl drágák voltak, újra kellene gondolni [x86-64](https://www.chessprogramming.org/X86-64) és [SIMD utasítások](https://www.chessprogramming.org/SIMD_and_SWAR_Techniques) figyelembevételével. A gyors 64 bites szorzás megjelenésével és a gyorsabb [memóriával](https://www.chessprogramming.org/Memory) együtt a [Lasse Hansen](https://www.chessprogramming.org/Lasse_Hansen) által javasolt és [Pradu Kannan](https://www.chessprogramming.org/Pradu_Kannan) által továbbfejlesztett [Magic Bitboards](https://www.chessprogramming.org/Magic_Bitboards) meghaladta a Rotatedet.

### Elemzés

A bitboardok használata számos vitát váltott ki a költségeikről és előnyeikről. A legfontosabb megfontolandó szempontok a következők:

- A bittáblák nagy információsűrűségűek lehetnek.
- Az egyszeresen feltöltött vagy akár üres bitboardok alacsony információsűrűséggel rendelkeznek.
- A bittáblák gyengék az olyan kérdések megválaszolásában, mint például, hogy melyik bábu található az x mezőn, ha van ilyen. Az egyik ok, amiért érdemes megtartani egy redundáns [postaláda](https://www.chessprogramming.org/Mailbox) tábla reprezentációt, némi további [frissítés](https://www.chessprogramming.org/Incremental_Updates) költséggel a [make](https://www.chessprogramming.org/Make_Move)/[unmake](https://www.chessprogramming.org/Unmake_Move) során.
- A bittáblák minden négyzetre párhuzamosan tudnak működni bitenkénti utasításokkal. Ez az egyik fő érv, amelyet a bitboardok támogatói használnak, mivel ez lehetővé teszi a [kiértékelés](https://www.chessprogramming.org/Evaluation) rugalmasságát.
- A bitboardok meglehetősen hátrányosak a 32 bites processzorokon, mivel minden bitenkénti számítást két vagy több utasításra kell bontani. Mivel a legtöbb modern processzor ma már 64 bites, ez a szempont némileg csökken.
- A bitboardok gyakran támaszkodnak a [bit-twiddling](https://www.chessprogramming.org/Bit-Twiddling) és különböző optimalizálási trükkökre és bizonyos hardverarchitektúrákra vonatkozó speciális utasításokra, mint például a [bitscan](https://www.chessprogramming.org/BitScan) és a [population count](https://www.chessprogramming.org/Population_Count). Az optimális kódhoz gépfüggő [fejlécfájlok](http://en.wikipedia.org/wiki/Header_file) szükségesek [C](https://www.chessprogramming.org/C)/[C++](https://www.chessprogramming.org/Cpp) nyelven. A hordozható kód valószínűleg nem minden processzoron optimális.
- A bit táblákon végzett egyes műveletek kevésbé általánosak, pl. a váltások. Ez további kódterhelést igényel.

### Megvalósítás

A tábla reprezentációs módja fontos probléma, az általános módszer egy kétdimenziós tömböt használ a tábla reprezentálására, egy pozíciót gyakran egy bájttal reprezentálnak, de az általános malomosztály minden egyes pozíciója az állapotnak jóval kevesebb, mint 256 bájt. Sok Mill-osztály esetében a bittáblák hatékony módot jelentenek a helytakarékosságra és a teljesítmény javítására. 

Röviden, a bit tábla egy bit egy olyan táblában, amely néhány bitet használ.  Ebben a programban a 32 bitből 24 bitből egy alacsony, 32 bitet használó Mill tábla képviseletére, a bitek több helyen történő felhasználásával a tömbműveletek helyettesítésére a teljesítmény javítása érdekében. 

# Jövőbeli munka

A jövőbeli munka lehetőségei közé tartoznak:

- Hint és elemzés.
- Mobilitás kiértékelése, különösen a Nine Men's Morris esetében.
- Az értékelési súly beállításának támogatása, továbbá az önképzés támogatása a legjobb súly megtalálása érdekében.
- További AI stílusok, például áldozathozatal.
- Adatbázis megnyitása.
- Végjáték-tanulás.
- Több szabályváltozat támogatása. 
- Standard szabályokkal való ellenőrzés.
- Több lokalizáció.
- Hatékonyan frissíthető neurális hálózat
- Online adatbázis.
- Egyéb optimalizálások.

# Hivatkozások

https://www.chessprogramming.org/Minimax

https://www.chessprogramming.org/Alpha-Beta

https://en.wikipedia.org/wiki/Negamax

https://en.wikipedia.org/wiki/MTD-f

https://www.chessprogramming.org/Move_Ordering

https://www.chessprogramming.org/Transposition_Table

https://www.chessprogramming.org/Evaluation

https://www.chessprogramming.org/Bitboards

https://gcc.gnu.org/projects/prefetch.html

http://library.msri.org/books/Book29/files/gasser.pdf

https://www.ics.uci.edu/~eppstein/cgt/morris.html

http://muehlespiel.eu/images/pdf/WMD_Spielregeln.pdf