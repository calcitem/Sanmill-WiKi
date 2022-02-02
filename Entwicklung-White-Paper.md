Calcitem Sanmill Entwicklung White Paper
---------------------------------------------------------------------------

Dieses Dokument ist ein "work in progress". Bitte senden Sie alle Kommentare dazu an [Calcitem Sdudio](mailto:calcitem@outlook.com). Herzlichen Dank!

# Einleitung

Dieses Dokument beschreibt das Design des Programms Sanmill Mill Game, wobei der Schwerpunkt auf dem Design des Kernalgorithmus liegt. Wir beschreiben die Kombination einiger Suchmethoden, die von wissensbasierten Methoden profitieren.

Mill ist ein klassisches "Zwei-Personen-Nullsummenspiel, volle Information, nicht zufällig". Das Programm verwendet den Minimax-Suchalgorithmus, um den Spielbaum zu durchsuchen und optimiert den Spielbaum mithilfe von Alpha-Beta-Beschneidung, MTD(f)-Algorithmen, Iterationsvertiefung und Transpositionstabellen. Durch die Erforschung und Analyse von Mühle-Spielen wurden im Spielalgorithmus viele Entwürfe und Optimierungen durchgeführt, das Programm hat ein hohes Maß an Intelligenz erreicht. 

Um die Leistung zu verbessern, wurde der Kern der Spielalgorithmus-Engine in C++ geschrieben, die GUI der App in Flutter, und der Plattformkanal wird verwendet, um Nachrichten zwischen der Flutter-UI und der Spiel-Engine zu übertragen.  

Der Gesamtumfang des Codes beträgt etwa 200.000+ Zeilen. Die Spielalgorithmus-Engine wird unabhängig entwickelt. Nur im Thread-Management- und UCI-Modul hat die Schachengine Stockfish etwa 300 Zeilen Code kopiert.

Der Zweck der Verwendung der UCI-Schnittstelle ist es, ein allgemeines Framework zu schaffen, das auch von anderen Mill-Game-Entwicklern referenziert und angeschlossen werden kann, um den Wettbewerb der Spiele-KI-Engine zu erleichtern.

## Übersicht

## Hardware-Umgebung

### Android-Telefon

1.5GHz CPU oder höher

1GB RAM oder höher

Bildschirmauflösung von 480x960 oder mehr Größe

Android 4.2 oder höher

### iOS-Telefon

Es wird erwartet, dass iOS im Jahr 2021Q3 unterstützt wird.

### PC

Die Flutter-Edition befindet sich in der Entwicklung. Sie wird voraussichtlich im Microsoft Store im Jahr 2021Q2 veröffentlicht.

Die Qt-Edition ist verfügbar. Derzeit gibt es einige Bugs in der GUI, daher wird sie normalerweise nur für den Selbstkampf verwendet, nachdem der Algorithmus verbessert wurde, um die Wirkung des Algorithmus zu testen. Diese Version unterstützt das Laden der perfekten KI-Datenbank.

## Entwicklungsumgebung

Android Studio 4.1.3
Visual Studio Gemeinschaft 2019
Flutter 2.0.x
Android SDK Version 30.0
Android NDK Version 21.1

## Programmiersprache

Die Spiel-Engine ist in C++ geschrieben. Der Code für die App-Eingabe ist in Java geschrieben, und die Benutzeroberfläche ist in Dart geschrieben. 

## Entwicklungszwecke

Den Benutzern Unterhaltung und Entspannung zu bieten und dieses klassische Brettspiel zu fördern. 

## Funktionen
Implementieren Sie das Mühle-Spiel, unterstützen Sie die drei Kampfmodi Mensch-KI, Mensch-Mensch und KI-KI, unterstützen Sie eine Vielzahl von Mühle-Regel-Varianten, einschließlich der Unterstützung von Nine Men's Morris, Twelve Men's Morris, unterstützen Sie das Brett, ob es diagonale Linien gibt, unterstützen Sie die "fliegende Regel", unterstützen Sie, ob Sie die geschlossene Mühle und andere Mühle-Regel-Varianten nehmen dürfen. Unterstützt die Einstellung der Hauptelemente der UI-Farbe, unterstützt die Einstellung des Schwierigkeitsgrades, des Spielstils der KI, ob Soundeffekte abgespielt werden sollen, des ersten Zuges, unterstützt die Anzeige des Zugverlaufs, die Anzeige statistischer Daten. Unterstützt die Wiederherstellung der Standardeinstellungen.  Im Falle eines unerwarteten Programmabsturzes können Informationen gesammelt werden und, mit Erlaubnis des Benutzers, kann der E-Mail-Client aufgerufen werden, um Absturz- und Diagnoseinformationen zu senden. 

## Technische Merkmale

Die Programm-Spiel-Engine verwendet Spielbaum-Suchalgorithmen wie MTD(f)und Alpha-Beta Pruning, um optimale Suchmethoden durchzuführen, die Leistung durch Zugsortierung, Transpositionstabellen und Prefetching zu verbessern und die Suchdauer durch iterative Vertiefung der Suchmethoden zu kontrollieren. Verwendung von Flutter zur Entwicklung der Benutzeroberfläche, um die Portabilität zu verbessern. 

# Das Mühle-Spiel

Die Mühle ist eines der ältesten Spiele, die heute noch gespielt werden. Spielbretter wurden an vielen historischen Gebäuden auf der ganzen Welt gefunden. Das älteste (ca. 1400 v. Chr.) wurde in einen Dachschiefer eines Tempels in Ägypten eingeritzt gefunden. Andere wurden so weit verstreut wie Ceylon, Troja und Irland gefunden.

Die Mühle hat sich in ganz China verbreitet, durch die Beliebtheit des Volkes haben sich "San Qi", "San San Qi", "Cheng San Qi", "Da San Qi", "San Lian", "Qi San" und viele andere Varianten entwickelt. 

Das Spiel wird auf einem Brett mit 24 Punkten gespielt, auf dem Steine platziert werden können. Zu Beginn ist das Brett leer und jeder der beiden Spieler hält neun oder zwölf Steine. Der Spieler mit den weißen Steinen beginnt.

```
        X --- X --- X
        | | |
        | X - X - X |
        | | | | |
        | | X-X-X | |
        X-X-X-X X-X-X
        | | X-X-X | |
        | | | | |
        | X - X - X |
        | | |
        X --- X --- X
        
        X --- X --- X
        |\ | /|
        | X - X - X |
        | |\ | /| |
        | | X-X-X | |
        X-X-X X-X-X
        | | X-X-X | |
        | |/ | \| |
        | X - X - X |
        |/ | \|
        X --- X --- X        
```

Beide Spieler beginnen mit je neun Steinen.

Das Spiel durchläuft drei Phasen:

* Eröffnungsphase

Die Spieler legen abwechselnd Steine auf einen leeren Punkt.

* Midgame-Phase

Nachdem alle Steine platziert sind, schieben die Spieler Steine auf einen beliebigen benachbarten freien Punkt.
* Endspielphase

Wenn eine Spielerin nur noch drei Steine hat, darf sie einen Stein auf einen beliebigen freien Punkt schieben.


Während der Eröffnung legen die Spieler abwechselnd. Nach der Eröffnung. ihre Steine auf einen beliebigen freien Punkt.

Nachdem alle Steine platziert wurden, geht das Spiel in die Mittelspielphase über. Hier darf ein Spieler einen seiner Steine auf einen benachbarten freien Punkt schieben. Gelingt es einer Spielerin zu irgendeinem Zeitpunkt des Spiels, drei ihrer Steine in einer Reihe anzuordnen - dies wird als Schließen einer Mühle bezeichnet - darf sie jeden gegnerischen Stein, der nicht Teil einer Mühle ist, entfernen. 

Sobald eine Spielerin nur noch drei Steine hat, beginnt das Endspiel. Wenn sie am Zug ist, darf die Spielerin mit drei Steinen einen ihrer Steine auf einen beliebigen freien Punkt auf dem Brett springen lassen.

Das Spiel endet auf folgende Arten:

* Ein Spieler, der weniger als drei Steine hat, verliert.
* Ein Spieler, der keinen legalen Zug machen kann, verliert.
* Wenn eine Mittelspiel- oder Endspielstellung wiederholt wird, ist die Partie unentschieden.

Zwei Punkte sind unter Mühle-Enthusiasten umstritten. Der erste hängt mit der Beobachtung zusammen, dass es in der Eröffnung möglich ist, zwei Mühlen gleichzeitig zu schließen. Soll der Spieler dann einen oder zwei gegnerische Steine entfernen dürfen? Unsere Implementierung unterstützt beides. Der zweite Punkt betrifft Positionen, in denen der zu ziehende Spieler gerade eine Mühle geschlossen hat, aber alle gegnerischen Steine ebenfalls in Mühlen stehen. Darf sie dann einen Stein entfernen oder nicht? In unserer Implementierung ist diese Regel konfigurierbar. 

# Gestaltungsabsicht

Es gibt verschiedene Varianten von Mühle, die gespielt werden. Die beliebteste Variante - Nine Men's Morris - ist ein Unentschieden. Dieses Ergebnis wurde mit einer Kombination aus Alpha-Beta-Suche und Endspieldatenbanken von [Palph Gasser](http://library.msri.org/books/Book29/files/gasser.pdf) erreicht. 

Die Retrograde Analyse wurde verwendet, um Datenbanken für alle Mittel- und Endspielpositionen zu berechnen (etwa 10 Milliarden verschiedene Positionen). Diese Stellungen wurden in 28 separate Datenbanken aufgeteilt, die durch die Anzahl der Steine auf dem Brett charakterisiert sind, d.h. alle Stellungen mit 3 weißen Steinen gegen 3 schwarze Steine, die 4-3, 4-4 ... bis hin zu 9-9 Stellungen.

Eine 18-fache Alpha-Beta-Suche für die Eröffnungsphase fand dann den Wert der Ausgangsstellung (das leere Brett). Nur die Datenbanken 9-9, 9-8 und 8-8 wurden benötigt, um festzustellen, dass die Partie remis ist.

Es gibt einige Implementierungen, die Datenbanken verwenden, um eine unschlagbare KI zu perfektionieren, wie z. B.:

[King Of Muehle](https://play.google.com/store/apps/details?id=com.game.kingofmills)

http://muehle.jochen-hoenicke.de/

https://www.mad-weasel.de/morris.html

Da die Datenbank sehr groß ist, müssen wir normalerweise für eine Spielregel eine 80-GB-Datenbank erstellen, die nur auf dem PC verwendet werden kann, oder die Datenbank auf den Server legen und per App abfragen. Da die Datenbank sehr groß ist, ist es unrealistisch, eine Datenbank mit allen Regelvarianten zu erstellen, daher unterstützt diese Art von Programm normalerweise nur die Standardregeln von Nine Men's Morris.

Die Unterstützung für eine Vielzahl von Regelvarianten ist die Besonderheit dieses Programms. Auf der anderen Seite, wenn keine riesige Datenbank verwendet wird, hoffen wir, einen fortgeschrittenen Suchalgorithmus und menschliches Wissen zu verwenden, um das Niveau der Intelligenz so weit wie möglich zu verbessern, und können den Schwierigkeitsgrad unterteilen, so dass die Spieler das Vergnügen des Levelaufstiegs genießen können.

Außerdem unterstützen wir für die PC-Version von Qt bereits die Verwendung der Datenbank, die von [Nine Men's Morris Game - The perfect playing computer] (https://www.mad-weasel.de/morris.html) erstellt wurde. Leider handelt es sich dabei nicht um eine Standardregel. Sie folgt den Regeln in großen Aspekten, aber es gibt Unterschiede in einigen kleinen Regeln. Es sollte darauf hingewiesen werden, dass wir den detaillierten Text der Standardregeln zur Zeit nicht haben. Wir überprüfen nur den Standard der Tippregeln durch Vergleich mit anderen Programmen. Und der Hauptzweck des Zugriffs auf diese Datenbank ist es, die Fähigkeit des KI-Algorithmus zu bewerten und den Effekt des Algorithmus anhand der Ziehungsrate im Vergleich zur perfekten KI zu messen. Die Datenbank der anderen Standardregeln ist vorerst nicht für den Quellcode und die Schnittstelle offen, so dass sie nicht angeschlossen werden kann.

In der Zukunft können wir den Algorithmus zum Aufbau einer perfekten KI-Datenbank verwenden, um unsere eigene Datenbank zu erstellen, aber dies erfordert die Kosten für den Server zum Speichern der Datenbank. Es ist nicht zu erwarten, dass wir diesen Plan kurzfristig umsetzen werden. Mittelfristig ist der praktikablere Weg, durch die Endspieldatenbank oder [NNUE](https://en.wikipedia.org/wiki/Efficiently_updatable_neural_network) zu trainieren und das Intelligenzniveau mit geringeren Kosten weiter zu verbessern.

Wir stellen den Code, die Tools und die Daten, die für die Bereitstellung des Sanmill-Programms benötigt werden, zur Verfügung und verteilen sie frei. Wir tun dies, weil wir davon überzeugt sind, dass offene Software und offene Daten die wichtigsten Zutaten sind, um schnelle Fortschritte zu erzielen. Unser ultimatives Ziel ist es, die Stärke der Community zu bündeln und Sanmill zu einem mächtigen Programm zu machen, das Mühlenfans auf der ganzen Welt Spaß bringt, besonders in Europa, Südafrika, China und anderen Orten, wo Mühlespiele weit verbreitet sind.

# Komponenten

## Algorithmus-Engine

Das Engine-Modul ist für die Suche nach einem der besten Züge verantwortlich, die an das UI-Modul zurückgegeben werden, basierend auf der angegebenen Position und der Statusinformation, z. B. wer zuerst spielt.  Es ist in die folgenden Untermodule unterteilt:

1. Bitbrett

2. Auswertung

3. Hash-Tabelle (unverriegelt).

4. Mühle Spiellogik

5. Zuggenerator

6. Zug-Picker

7. Konfigurationsverwaltung

8. Regel-Verwaltung

9. Best-Move-Suche

10. Thread-Verwaltung

11. Transpositionstabelle

12. Universal Chess Interface (UCI)

13. UCI-Optionen-Verwaltung

## UI-Frontend

UI-Modul: Die Entwicklung mit Flutter bietet die Vorteile einer hohen Entwicklungseffizienz, der Konsistenz der Android/iOS-Benutzeroberfläche, einer schönen Benutzeroberfläche und einer vergleichbaren Native-Performance. 

Das UI-Modul gliedert sich in die folgenden Module:

Mühlenlogikmodul, im Grunde die Algorithmus-Engine des Mühlenlogikmoduls, die in die Dart-Sprache übersetzt wurde; speziell unterteilt in Spiellogikmodul, Mühlenverhaltensmodul, Positionsverwaltungsmodul, Zugverlaufsmodul und so weiter.

Engine-Kommunikationsmodul: verantwortlich für die Interaktion mit der in C++ geschriebenen Spiel-Engine.

Befehlsmodul: Befehlswarteschlange zur Verwaltung und Interaktion mit der Spiel-Engine;

Konfigurationsmanagement: einschließlich In-Memory-Konfiguration und Flash-Konfigurationsmanagement;

Zeichenmodul: einschließlich Brettzeichnung und Figurenzeichnung;

Servicemodul: einschließlich Audiodienste;

Stil-Modul: einschließlich Themen-Stil, Farb-Stil;

Seitenmodule: einschließlich Spielbrettseiten, Seiten des Seitenmenüs, Spieleinstellungsseiten, Themeneinstellungsseiten, Regeleinstellungsseiten, Hilfeseiten, Über-Seiten, Lizenzseiten und verschiedene UI-Komponenten;

Mehrsprachige Daten: Enthält englische und chinesische String-Text-Ressourcen.

## Algorithmusentwurf

## Minimax

**Minimax**, ein Algorithmus, der verwendet wird, um den [Punktestand](https://www.chessprogramming.org/Score) in einem [Nullsummen](https://en.wikipedia.org/wiki/Zero-sum) Spiel nach einer bestimmten Anzahl von Zügen zu bestimmen, mit bestem Spiel gemäß einer [Auswertungs](https://www.chessprogramming.org/Evaluation) Funktion. Der Algorithmus kann wie folgt erklärt werden: Bei einer [einlagigen](https://www.chessprogramming.org/Ply) Suche, bei der nur Zugfolgen mit der Länge eins untersucht werden, kann die zu ziehende Seite (Max-Spieler) einfach auf die [Bewertung](https://www.chessprogramming.org/Evaluation) schauen, nachdem sie alle möglichen [Züge](https://www.chessprogramming.org/Moves) gespielt hat. Der Zug mit der besten Bewertung wird gewählt. Aber bei einer Suche mit zwei [Zügen](https://www.chessprogramming.org/Ply), wenn der Gegner auch zieht, werden die Dinge komplizierter. Der Gegner (Min-Spieler) wählt ebenfalls den Zug, der die beste Bewertung erhält. Daher ist die Bewertung jedes Zuges nun die Bewertung des schlechtesten, den der Gegner machen kann.

### Geschichte

Die Dissertation von [Jaap van den Herik](https://www.chessprogramming.org/Jaap_van_den_Herik) (1983) enthält eine detaillierte Darstellung der bekannten Veröffentlichungen zu diesem Thema. Sie kommt zu dem Schluss, dass, obwohl [John von Neumann](https://www.chessprogramming.org/John_von_Neumann) gewöhnlich mit diesem Konzept in Verbindung gebracht wird ([1928](https://www.chessprogramming.org/Timeline#1928)), [Primat](https://en.wikipedia.org/wiki/Primacy_of_mind) wahrscheinlich zu [Émile Borel](https://www.chessprogramming.org/Mathematician#Borel) gehört. Weiterhin ist es denkbar, dass der erste Verdienst [Charles Babbage](https://www.chessprogramming.org/Mathematician#Babbage) zukommt. Die ursprüngliche Minimax, wie sie von Von Neumann definiert wurde, basiert auf exakten Werten aus [Spiel-Endpositionen](https://www.chessprogramming.org/Terminal_Node), während die von [Norbert Wiener](https://www.chessprogramming.org/Norbert_Wiener) vorgeschlagene Minimax-Suche auf [heuristischen Auswertungen](https://www.chessprogramming.org/Evaluation) aus Positionen basiert, die einige Züge entfernt sind und weit vom Spielende entfernt sind.

### Implementierung

Nachfolgend der Pseudocode für eine indirekte [rekursive](https://www.chessprogramming.org/Recursion) [depth-first search](https://www.chessprogramming.org/Depth-First). Der Übersichtlichkeit halber wird das [move making](https://www.chessprogramming.org/Make_Move) und [unmaking](https://www.chessprogramming.org/Unmake_Move) vor und nach dem rekursiven Aufruf weggelassen.

```c
int maxi( int Tiefe ) {
    if ( depth == 0 ) return evaluate();
    int max = -oo;
    for ( alle Züge) {
        score = mini( depth - 1 );
        if( punkte > max )
            max = punkte;
    }
    return max;
}

int mini( int Tiefe ) {
    if ( depth == 0 ) return -evaluate();
    int min = +oo;
    for ( alle Züge) {
        score = maxi( depth - 1 );
        if( punkte < min )
            min = punkte;
    }
    return min;
}
```

## Alpha-Beta Pruning

Der **Alpha-Beta**-Algorithmus (Alpha-Beta Pruning, Alpha-Beta Heuristik) ist eine signifikante Erweiterung des [minimax](https://www.chessprogramming.org/Minimax) Suchalgorithmus, die es überflüssig macht, große Teile des [Spielbaums](https://www.chessprogramming.org/Search_Tree) unter Anwendung einer [branch-and-bound](https://en.wikipedia.org/wiki/Branch_and_bound) Technik zu durchsuchen. Bemerkenswerterweise tut er dies, ohne dass man einen besseren [Zug](https://www.chessprogramming.org/Moves) übersehen könnte. Wenn man bereits einen recht guten Zug gefunden hat und nach Alternativen sucht, genügt **eine** [Widerlegung](https://www.chessprogramming.org/Refutation_Move), um ihn zu vermeiden. Man braucht nicht nach noch stärkeren Widerlegungen zu suchen. Der Algorithmus verwaltet zwei Werte, [alpha](https://www.chessprogramming.org/Alpha) und [beta](https://www.chessprogramming.org/Beta). Sie repräsentieren die minimale Punktzahl, die dem maximierenden Spieler zugesichert wird, bzw. die maximale Punktzahl, die dem minimierenden Spieler zugesichert wird. 

### Wie funktioniert das?

Angenommen, Weiß ist am Zug, und wir suchen bis zu einer [Tiefe](https://www.chessprogramming.org/Depth) von 2 (d. h. wir betrachten alle Züge von Weiß und alle Reaktionen von Schwarz auf jeden dieser Züge). Zuerst wählen wir einen der möglichen Züge von Weiß aus - nennen wir diesen möglichen Zug #1. Wir betrachten diesen Zug und jede mögliche Antwort von Schwarz auf diesen Zug. Nach dieser Analyse stellen wir fest, dass das Ergebnis des möglichen Zuges 1 eine ausgeglichene Stellung ist. Dann gehen wir weiter und betrachten einen anderen möglichen Zug von Weiß (Möglicher Zug 2). Wenn wir den ersten möglichen Gegenzug von Schwarz betrachten, stellen wir fest, dass Schwarz dadurch eine Figur gewinnt! In dieser Situation können wir alle anderen möglichen Reaktionen von Schwarz auf den möglichen Zug 2 getrost ignorieren, da wir bereits wissen, dass der mögliche Zug 1 besser ist. Es ist uns wirklich egal, *genau* wie viel schlechter der mögliche Zug #2 ist. Vielleicht gewinnt eine andere mögliche Antwort eine Figur, aber das spielt keine Rolle, weil wir wissen, dass wir *mindestens* ein ausgeglichenes Spiel erreichen können, indem wir den möglichen Zug 1 spielen. Die vollständige Analyse von Möglicher Zug 1 hat uns eine [untere Grenze](https://www.chessprogramming.org/Lower_Bound) gegeben. Wir wissen, dass wir mindestens das erreichen können, also kann alles, was deutlich schlechter ist, ignoriert werden.

Die Situation wird jedoch noch komplizierter, wenn wir zu einer Such-[Tiefe](https://www.chessprogramming.org/Depth) von 3 oder größer übergehen, weil jetzt beide Spieler Entscheidungen treffen können, die den Spielbaum beeinflussen. Jetzt müssen wir sowohl eine [untere Schranke](https://www.chessprogramming.org/Lower_Bound) als auch eine [obere Schranke](https://www.chessprogramming.org/Upper_Bound) einhalten (genannt [Alpha](https://www.chessprogramming.org/Alpha) und [Beta](https://www.chessprogramming.org/Beta).) Wir halten eine untere Grenze ein, denn wenn ein Zug zu schlecht ist, ziehen wir ihn nicht in Betracht. Aber wir müssen auch eine obere Schranke einhalten, denn wenn ein Zug auf Tiefe 3 oder höher zu einer Fortsetzung führt, die zu gut ist, wird der andere Spieler ihn nicht zulassen, weil es einen besseren Zug weiter oben im Spielbaum gab, den er hätte spielen können, um diese Situation zu vermeiden. Die untere Grenze des einen Spielers ist die obere Grenze des anderen Spielers.

### Ersparnis

Die Einsparungen von alpha beta können beträchtlich sein. Wenn ein Standard-Minimax-Suchbaum **x** [Knoten](https://www.chessprogramming.org/Node) hat, kann ein Alpha-Beta-Baum in einem gut geschriebenen Programm eine Knotenanzahl nahe der Quadratwurzel von **x** haben. Wie viele Knoten Sie tatsächlich abschneiden können, hängt jedoch davon ab, wie gut geordnet Ihr Spielbaum ist. Wenn Sie immer zuerst den bestmöglichen Zug suchen, eliminieren Sie die meisten Knoten. Natürlich wissen wir nicht immer, was der beste Zug ist, sonst bräuchten wir gar nicht erst zu suchen. Umgekehrt, wenn wir immer die schlechteren Züge vor den besseren Zügen suchen würden, könnten wir überhaupt keinen Teil des Baumes abschneiden! Aus diesem Grund ist eine gute [Zugreihenfolge](https://www.chessprogramming.org/Move_Ordering) sehr wichtig und steht im Mittelpunkt eines Großteils der Bemühungen beim Schreiben eines guten Schachprogramms. Wie von [Levin](https://www.chessprogramming.org/Michael_Levin#Theorem) 1961 aufgezeigt, ist unter der Annahme von konstant **b** Zügen für jeden besuchten Knoten und einer Suchtiefe von **n** die maximale Anzahl von Blättern in alpha-beta äquivalent zu minimax, **b** ^ **n**. Unter der Annahme, dass immer der beste Zug zuerst kommt, ist sie **b** ^ [ceil(n/2)](https://en.wikipedia.org/wiki/Floor_and_ceiling_functions) plus **b** ^ [floor(n/2)](https://en.wikipedia.org/wiki/Floor_and_ceiling_functions) minus eins. Die minimale Anzahl der [Blätter](https://www.chessprogramming.org/Leaf_Node) ist in der folgenden Tabelle dargestellt, die auch den [ungerade-gerade-Effekt](https://www.chessprogramming.org/Odd-Even_Effect) demonstriert:

## **Negamax**-Suche

Üblicherweise wird der Einfachheit halber der [Negamax](https://www.chessprogramming.org/Negamax) Algorithmus verwendet. Das bedeutet, dass die Bewertung einer Stellung gleichbedeutend mit der Negation der Bewertung aus Sicht des Gegners ist. Der Grund dafür ist die Nullsummeneigenschaft des Schachs: Der Gewinn der einen Seite ist der Verlust der anderen Seite.

**Negamax**-Suche ist eine abgewandelte Form der [Minimax](https://en.wikipedia.org/wiki/Minimax)-Suche, die sich auf die [Nullsummen](https://en.wikipedia.org/wiki/Zero-sum_(Game_theory))-Eigenschaft eines [Zwei-Personen-Spiels](https://en.wikipedia.org/wiki/Two-player_game) stützt.

Dieser Algorithmus stützt sich auf die Tatsache, dass ![{\displaystyle \max(a,b)=-\min(-a,-b)}](https://wikimedia.org/api/rest_v1/media/math/render/svg/e64fb74b232e7412ce1967d786e07fd56b08296f), um die Implementierung des [minimax](https://en.wikipedia.org/wiki/Minimax) Algorithmus zu vereinfachen. Genauer gesagt ist der Wert einer Stellung für Spieler A in einem solchen Spiel die Negation des Wertes für Spieler B. Der Spieler am Zug sucht also nach einem Zug, der die Negation des aus dem Zug resultierenden Wertes maximiert: diese Nachfolgeposition muss per Definition vom Gegner bewertet worden sein. Die Argumentation des vorherigen Satzes funktioniert unabhängig davon, ob A oder B am Zug ist. Das bedeutet, dass eine einzige Prozedur verwendet werden kann, um beide Stellungen zu bewerten. Dies ist eine Vereinfachung der Kodierung gegenüber Minimax, das verlangt, dass A den Zug mit dem maximal bewerteten Nachfolger auswählt, während B den Zug mit dem minimal bewerteten Nachfolger auswählt.

Es sollte nicht mit [negascout](https://en.wikipedia.org/wiki/Negascout) verwechselt werden, einem Algorithmus zur schnellen Berechnung des Minimax- oder Negamax-Wertes durch geschickte Verwendung von [alpha-beta pruning](https://en.wikipedia.org/wiki/Alpha-beta_pruning), der in den 1980er Jahren entdeckt wurde. Beachten Sie, dass Alpha-Beta-Beschneidung selbst eine Möglichkeit ist, den Minimax- oder Negamax-Wert einer Position schnell zu berechnen, indem die Suche nach bestimmten uninteressanten Positionen vermieden wird.

Die meisten [adversarial search](https://en.wikipedia.org/wiki/Adversarial_search) Engines sind mit einer Form der Negamax-Suche codiert.

### Negamax-Basisalgorithmus

NegaMax arbeitet mit denselben [Spielbäumen](https://en.wikipedia.org/wiki/Game_tree), die auch für den Minimax-Suchalgorithmus verwendet werden. Jeder Knoten und der Wurzelknoten im Baum sind Spielzustände (z. B. die Spielbrettkonfiguration) eines Zwei-Spieler-Spiels. Übergänge zu untergeordneten Knoten stellen Züge dar, die einem Spieler zur Verfügung stehen, der von einem bestimmten Knoten aus spielen will.

Das Ziel der Negamax-Suche ist es, den Punktwert des Knotens für den Spieler zu finden, der gerade am Wurzelknoten spielt. Der [Pseudocode](https://en.wikipedia.org/wiki/Pseudocode) unten zeigt den Negamax-Basisalgorithmus, mit einer konfigurierbaren Grenze für die maximale Suchtiefe:

```
Funktion negamax(Knoten, Tiefe, Farbe) ist
    wenn Tiefe = 0 oder Knoten ein Endknoten ist, dann
        Farbe × den heuristischen Wert des Knotens zurückgeben
    Wert := -∞
    für jedes Kind des Knotens do
        value := max(value, negamax(child, depth - 1, -color))
    return -Wert
```

```
(* Erster Aufruf für den Wurzelknoten von Spieler A *)
negamax(WurzelKnoten, Tiefe, 1)
```

```
(* Initialer Aufruf für den Wurzelknoten von Spieler B *)
negamax(rootNode, Tiefe, -1)
```

Der Wurzelknoten erbt seine Punktzahl von einem seiner unmittelbaren Kindknoten. Der Kindknoten, der letztendlich die beste Punktzahl des Wurzelknotens festlegt, stellt auch den besten Zug dar, der zu spielen ist. Obwohl die gezeigte negamax-Funktion nur die beste Punktzahl des Knotens zurückgibt, werden praktische negamax-Implementierungen sowohl den besten Zug als auch die beste Punktzahl für den Wurzelknoten beibehalten und zurückgeben. Bei Nicht-Wurzelknoten ist nur die beste Punktzahl des Knotens wichtig. Und der beste Zug eines Knotens muss für Nicht-Wurzelknoten weder aufbewahrt noch zurückgegeben werden.

Was verwirrend sein kann, ist, wie der heuristische Wert des aktuellen Knotens berechnet wird. In dieser Implementierung wird dieser Wert immer aus der Sicht von Spieler A berechnet, dessen Farbwert eins ist. Mit anderen Worten: Höhere heuristische Werte stellen immer Situationen dar, die für Spieler A günstiger sind. Dies ist das gleiche Verhalten wie beim normalen [minimax](https://en.wikipedia.org/wiki/Minimax) Algorithmus. Der heuristische Wert ist nicht notwendigerweise mit dem Rückgabewert eines Knotens identisch, da der Wert durch negamax und den Farbparameter negiert wird. Der Rückgabewert des negamax-Knotens ist ein heuristischer Wert aus der Sicht des aktuellen Spielers des Knotens.

Negamax-Punkte entsprechen Minimax-Punkten für Knoten, bei denen Spieler A im Begriff ist, zu spielen, und bei denen Spieler A der maximierende Spieler im Minimax-Äquivalent ist. Negamax sucht immer nach dem maximalen Wert für alle seine Knoten. Daher ist für Knoten von Spieler B der Minimax-Score eine Negation seines Negamax-Scores. Spieler B ist der minimierende Spieler im Minimax-Äquivalent.

Variationen in Negamax-Implementierungen können den Farbparameter weglassen. In diesem Fall muss die heuristische Bewertungsfunktion Werte aus der Sicht des aktuellen Spielers des Knotens zurückgeben.

### Negamax mit Alpha-Beta-Beschneidung

Algorithmus-Optimierungen für [minimax](https://en.wikipedia.org/wiki/Minimax) sind auch für Negamax gleichermaßen anwendbar. Mit [Alpha-Beta-Pruning](https://en.wikipedia.org/wiki/Alpha-beta_pruning) kann die Anzahl der Knoten, die der Negamax-Algorithmus in einem Suchbaum auswertet, in ähnlicher Weise wie beim Minimax-Algorithmus verringert werden.

Es folgt der Pseudocode für die tiefenbegrenzte Negamax-Suche mit Alpha-Beta-Beschneidung:

```c
Funktion negamax(Knoten, Tiefe, α, β, Farbe) ist
    wenn Tiefe = 0 oder Knoten ein terminaler Knoten ist, dann
        return color × der heuristische Wert des Knotens

    childNodes := generateMoves(node)
    childNodes := orderMoves(childNodes)
    Wert := -∞
    foreach child in childNodes do
        value := max(value, -negamax(child, depth - 1, -β, -α, -color))
        α := max(α, Wert)
        if α ≥ β then
            break (* cut-off *)
    Wert zurückgeben
```

```c
(* Initialer Aufruf für den Wurzelknoten von Spieler A *)
negamax(rootNode, depth, -∞, +∞, 1)
```

Alpha (α) und Beta (β) stellen untere und obere Grenzen für Werte von Kindknoten in einer bestimmten Baumtiefe dar. Negamax setzt die Argumente α und β für den Wurzelknoten auf den niedrigsten und höchsten möglichen Wert. Andere Suchalgorithmen, wie [negascout](https://en.wikipedia.org/wiki/Negascout) und [MTD-f](https://en.wikipedia.org/wiki/MTD-f), können α und β mit alternativen Werten initialisieren, um die Leistung der Baumsuche weiter zu verbessern.

Wenn negamax auf einen Kindknotenwert außerhalb eines Alpha/Beta-Bereichs stößt, schneidet die negamax-Suche ab, wodurch Teile des Spielbaums von der Erkundung ausgeschlossen werden. Die Abtrennungen sind implizit und basieren auf dem Knotenrückgabewert. Ein Knotenwert, der innerhalb des Bereichs seiner ursprünglichen α und β gefunden wird, ist der exakte (oder wahre) Wert des Knotens. Dieser Wert ist identisch mit dem Ergebnis, das der Negamax-Basisalgorithmus ohne Cut Offs und ohne α- und β-Grenzen zurückgeben würde. Wenn der Rückgabewert eines Knotens außerhalb des Bereichs liegt, dann stellt der Wert eine obere (wenn Wert ≤ α) oder untere (wenn Wert ≥ β) Grenze für den exakten Wert des Knotens dar. Das Alpha-Beta-Pruning verwirft schließlich alle Ergebnisse mit Wertgrenzen. Solche Werte tragen nicht zum Negamax-Wert an seinem Wurzelknoten bei und beeinflussen ihn auch nicht.

Dieser Pseudocode zeigt die Fail-Soft-Variante des Alpha-Beta-Prunings. Fail-soft gibt niemals α oder β direkt als Knotenwert zurück. Daher kann ein Knotenwert außerhalb der anfänglichen α- und β-Bereichsgrenzen liegen, die mit einem negamax-Funktionsaufruf festgelegt wurden. Im Gegensatz dazu begrenzt das fail-hard Alpha-Beta Pruning einen Knotenwert immer im Bereich von α und β.

Diese Implementierung zeigt auch eine optionale Verschiebungsreihenfolge vor der [foreach-Schleife](https://en.wikipedia.org/wiki/Foreach_loop), die Kindknoten auswertet. Move-Ordering ist eine Optimierung für Alpha-Beta-Pruning, die versucht, die wahrscheinlichsten Kindknoten zu erraten, die den Wert des Knotens ergeben. Der Algorithmus durchsucht zuerst diese Kindknoten. Das Ergebnis von guten Vermutungen ist, dass früher und häufiger Alpha/Beta-Abschneidungen auftreten, wodurch zusätzliche Spielbaumzweige und verbleibende Kindknoten aus dem Suchbaum beschnitten werden.

### Negamax mit Alpha-Beta-Beschneidung und Transpositionstabellen

Mit [Transpositionstabellen](https://en.wikipedia.org/wiki/Transposition_table) werden die Werte von Knoten im Spielbaum selektiv [memoisiert](https://en.wikipedia.org/wiki/Memoization). *Transposition* ist ein Begriff, der darauf hinweist, dass eine gegebene Spielbrettposition auf mehr als eine Weise mit unterschiedlichen Spielzugfolgen erreicht werden kann.

Wenn Negamax den Spielbaum durchsucht und dabei mehrfach auf denselben Knoten stößt, kann eine Transpositionstabelle einen zuvor berechneten Wert des Knotens zurückgeben und so eine möglicherweise langwierige und doppelte Neuberechnung des Knotenwerts überspringen. Die Leistung von Negamax verbessert sich besonders bei Spielbäumen mit vielen gemeinsamen Pfaden, die zu einem bestimmten Knoten führen.

Der Pseudo-Code, der die Funktionen der Transpositionstabelle zu Negamax mit Alpha/Beta Pruning hinzufügt, lautet wie folgt:

```c
Funktion negamax(Knoten, Tiefe, α, β, Farbe) ist
    alphaOrig := α

    (* Transposition Table Lookup; node ist der Lookup-Schlüssel für ttEntry *)
    ttEntry := transpositionTableLookup(node)
    wenn ttEntry gültig ist und ttEntry.depth ≥ depth dann
        if ttEntry.flag = EXACT then
            return ttEntry.value
        else if ttEntry.flag = LOWERBOUND then
            α := max(α, ttEntry.value)
        else if ttEntry.flag = UPPERBOUND then
            β := min(β, ttEntry.value)

        wenn α ≥ β dann
            return ttEntry.value

    wenn Tiefe = 0 oder Knoten ein Endknoten ist, dann
        return color × der heuristische Wert des Knotens

    childNodes := generateMoves(Knoten)
    childNodes := orderMoves(childNodes)
    value := -∞
    for each child in childNodes do
        value := max(value, -negamax(child, depth - 1, -β, -α, -color))
        α := max(α, Wert)
        wenn α ≥ β dann
            break

    (* Transpositionstabelle speichern; node ist der Nachschlageschlüssel für ttEntry *)
    ttEntry.value := value
    if value ≤ alphaOrig then
        ttEntry.flag := UPPERBOUND
    sonst wenn Wert ≥ β dann
        ttEntry.flag := LOWERBOUND
    sonst
        ttEntry.flag := EXACT
    ttEntry.depth := Tiefe	
    transpositionTableStore(Knoten, ttEntry)

    Rückgabewert
```

```
(* Initialer Aufruf für den Wurzelknoten von Spieler A *)
negamax(rootNode, depth, -∞, +∞, 1)
```

Alpha/Beta-Beschneidung und Beschränkungen der maximalen Suchtiefe in negamax können dazu führen, dass Knoten in einem Spielbaum teilweise, ungenau oder ganz übersprungen ausgewertet werden. Dies erschwert das Hinzufügen von Transpositionstabellen-Optimierungen für negamax. Es ist unzureichend, nur den *Wert* des Knotens in der Tabelle zu verfolgen, da *Wert* möglicherweise nicht der wahre Wert des Knotens ist. Der Code muss daher die Beziehung von *Wert* mit Alpha/Beta-Parametern und der Suchtiefe für jeden Transpositionstabelleneintrag erhalten und wiederherstellen.

Transpositionstabellen sind typischerweise verlustbehaftet und lassen frühere Werte bestimmter Spielbaumknoten in ihren Tabellen aus oder überschreiben sie. Dies ist notwendig, da die Anzahl der Knoten, die negamax besucht, oft die Größe der Transpositionstabelle weit übersteigt. Verlorene oder ausgelassene Tabelleneinträge sind unkritisch und beeinflussen das negamax Ergebnis nicht. Verlorene Einträge können jedoch dazu führen, dass negamax bestimmte Werte der Spielbaumknoten häufiger neu berechnen muss, was die Performance beeinträchtigt.

### Implementierung

In Sanmill sieht die grundsätzliche Implementierung wie folgt aus:

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
        } sonst {
            value = search(pos, ss, depth - 1 + epsilon, 
                           originDepth, alpha, beta, bestMove);
        }

        pos->undo_move(ss);
    
        if (Wert >= bestValue) {
            bestValue = Wert;
    
            wenn (Wert > alpha) {
                if (depth == originDepth) {
                    bestMove = move;
                }
    
                break;
            }
        }
    }
```

> **Hinweis**
>
> Da es bei Mühle einen Zustand geben kann, bei dem eine Seite eine Mühle schließt und dann weiter die gegnerische Figur nimmt, anstatt auf die andere Seite zu wechseln, sind die ungeraden und geraden Lagen möglicherweise nicht streng in die beiden Seiten des Spiels unterteilt, so dass es notwendig ist, zu bestimmen, ob die Seite nach dem Iterationsprozess wechselt, und dann zu entscheiden, ob die andere Zahl genommen werden soll.   

## MTD(f)-Suchalgorithmus

MTD(f) ist ein Minimax-Suchalgorithmus, der 1994 von Aske Plaat, Jonathan Schaeffer, Wim Pijls und Arie de Bruin entwickelt wurde. Experimente mit Schach-, Dame- und Othello-Programmen in Turnierqualität zeigen, dass es sich um einen hocheffizienten Minimax-Algorithmus handelt. Der Name MTD(f) ist eine Abkürzung für MTD(n,f) (Memory-enhanced Test Driver with node n and value f). Er ist eine Alternative zum Alpha-Beta Pruning-Algorithmus.

### Ursprung

MTD(f) wurde erstmals in einem technischen Bericht der University of Alberta beschrieben, der von Aske Plaat, Jonathan Schaeffer, Wim Pijls und Arie de Bruin verfasst wurde,[2] der später den ICCA Novag Award für die beste Computerschach-Publikation für 1994/1995 erhielt. Der Algorithmus MTD(f) entstand aus einer Forschungsarbeit zum Verständnis des SSS*-Algorithmus, einem Best-First-Suchalgorithmus, der 1979 von George Stockman erfunden wurde. Es wurde festgestellt, dass SSS* äquivalent zu einer Reihe von Alpha-Beta-Aufrufen ist, vorausgesetzt, dass Alpha-Beta einen Speicher verwendet, z. B. eine gut funktionierende Transpositionstabelle.

Der Name MTD(f) steht für Memory-enhanced Test Driver und bezieht sich auf den Test-Algorithmus von Judea Pearl, der Zero-Window-Suchen durchführt. MTD(f) wird in der Dissertation von Aske Plaat von 1996 ausführlich beschrieben.

### Null-Fenster-Suchen

MTD(f) erzielt seine Effizienz, indem es nur Null-Fenster-Alpha-Beta-Suchen mit einer "guten" Begrenzung (variables Beta) durchführt. In NegaScout wird die Suche mit einem breiten Suchfenster aufgerufen, wie in AlphaBeta(root, -INFINITY, +INFINITY, depth), so dass der Rückgabewert in einem Aufruf zwischen dem Wert von Alpha und Beta liegt. In MTD(f) schlägt AlphaBeta hoch oder niedrig fehl und gibt eine untere bzw. obere Grenze des Minimax-Wertes zurück. Null-Fenster-Aufrufe verursachen mehr Abschneidungen, geben aber weniger Informationen zurück - nur eine Begrenzung auf den Minimax-Wert. Um den Minimax-Wert zu finden, ruft MTD(f) AlphaBeta mehrmals auf, konvergiert zu ihm und findet schließlich den exakten Wert. Eine Transpositionstabelle speichert und ruft die zuvor durchsuchten Teile des Baums im Speicher ab, um den Overhead beim erneuten Durchsuchen von Teilen des Suchbaums zu reduzieren.

### Code

```c
Wert MTDF(Position *pos, Sanmill::Stack<Position> &ss, Wert firstguess,
           Depth depth, Depth originDepth, Move &bestMove)
{
    Wert g = firstguess;
    Wert lowerbound = -VALUE_INFINITE;
    Wert upperbound = VALUE_INFINITE;
    Wert beta;

    while (untere Grenze < obere Grenze) {
        if (g == Untergrenze) {
            beta = g + VALUE_MTDF_WINDOW;
        } sonst {
            beta = g;
        }
    
        g = search(pos, ss, depth, 
                   originDepth, beta - VALUE_MTDF_WINDOW, 
                   beta, bestMove);

        if (g < beta) {
            upperbound = g; // fail low
        } sonst {
            lowerbound = g; // fail high
        }
    }
    
    return g;
}
```

fistguess`

Erste Vermutung für den besten Wert. Je besser, desto schneller konvergiert der Algorithmus. Kann beim ersten Aufruf 0 sein.

`Tiefe`

Tiefe der Schleife für. Eine [iterative vertiefende Tiefensuche](https://en.wikipedia.org/wiki/Iterative_deepening_depth-first_search) könnte durch mehrfachen Aufruf von `MTDF()` mit inkrementierendem `d` und Bereitstellung des besten vorherigen Ergebnisses in `f` erfolgen.

### Leistung

NegaScout ruft die Null-Fenster-Suche rekursiv auf. MTD(f) ruft die Null-Fenster-Suchen von der Wurzel des Baums aus auf. Implementierungen des MTD(f)-Algorithmus haben sich in der Praxis als effizienter (suchen weniger Knoten) als andere Suchalgorithmen (z. B. NegaScout) in Spielen wie Schach, Dame und Othello erwiesen. Damit Suchalgorithmen wie NegaScout oder MTD(f) effizient arbeiten können, muss die Transpositionstabelle gut funktionieren. Andernfalls wird, z. B. bei einer Hash-Kollision, ein Teilbaum neu expandiert. Wenn MTD(f) in Programmen verwendet wird, die unter einem ausgeprägten Ungerade-Gerade-Effekt leiden, bei dem die Punktzahl an der Wurzel bei geraden Suchtiefen höher und bei ungeraden Suchtiefen niedriger ist, ist es ratsam, separate Werte für f zu verwenden, um die Suche so nahe wie möglich am Minimax-Wert zu beginnen. Andernfalls würde die Suche mehr Iterationen benötigen, um auf den Minimax-Wert zu konvergieren, insbesondere bei feinkörnigen Bewertungsfunktionen.

Null-Fenster-Suchen erreichen einen Cut-Off früher als Wide-Window-Suchen. Sie sind daher effizienter, aber in gewissem Sinne auch weniger fehlerverzeihend als Wide-Window-Suchen. Da MTD(f) nur Zero-Window-Suchen verwendet, während Alpha-Beta und NegaScout auch Wide-Window-Suchen verwenden, ist MTD(f) effizienter. Allerdings sind breitere Suchfenster verzeihender für Engines mit großen ungeraden/geraden Schwankungen und feinkörnigen Bewertungsfunktionen. Aus diesem Grund haben einige Schachengines nicht auf MTD(f) umgestellt. In Tests mit Programmen in Turnierqualität wie Chinook (Dame), Phoenix (Schach) und Keyano (Othello) schnitt der MTD(f)-Algorithmus besser ab als alle anderen Suchalgorithmen.

Es wird vorgeschlagen, dass neuere Algorithmen wie Best Node Search MTD(f) übertreffen.  

## Iterative vertiefende Deep-First-Suche

In der Informatik ist die iterative Vertiefungssuche oder genauer gesagt die iterative vertiefende Tiefensuche (IDS oder IDDFS) eine Zustandsraum/Graphen-Suchstrategie, bei der eine tiefenbegrenzte Version der Tiefensuche wiederholt mit zunehmenden Tiefengrenzen ausgeführt wird, bis das Ziel gefunden ist. IDDFS ist optimal wie die Breadth-First-Suche, verbraucht aber viel weniger Speicher; bei jeder Iteration werden die Knoten im Suchbaum in der gleichen Reihenfolge wie bei der Depth-First-Suche besucht, aber die kumulative Reihenfolge, in der die Knoten zuerst besucht werden, ist effektiv breadth-first.

### Algorithmus für gerichtete Graphen

```c
Funktion IDDFS(root) ist
    für Tiefe von 0 bis ∞ do
        gefunden, verbleibend ← DLS(Wurzel, Tiefe)
        wenn gefunden ≠ null dann
            return gefunden
        else if not remaining then
            return null

Funktion DLS(Knoten, Tiefe) ist
    wenn Tiefe = 0, dann
        wenn Knoten ein Ziel ist, dann
            return (Knoten, wahr)
        sonst
            return (null, true) (Nicht gefunden, kann aber Kinder haben)

    else if depth > 0 then
        beliebig_verbleibend ← false
        foreach Kind von Knoten do
            gefunden, verbleibend ← DLS(Kind, Tiefe-1)
            if gefunden ≠ null then
                return (gefunden, wahr)   
            if verbleibend then
                any_remaining ← true (Mindestens ein Knoten in Tiefe gefunden, IDDFS vertiefen lassen)
        return (null, any_remaining)
```

Wenn der Zielknoten gefunden wird, dann wickelt **DLS** die Rekursion ab und kehrt ohne weitere Iterationen zurück. Andernfalls, wenn mindestens ein Knoten auf dieser Tiefenstufe existiert, lässt das Flag *remaining* **IDDFS** fortfahren.

2-Tupel](https://en.wikipedia.org/wiki/Tuple) sind als Rückgabewert nützlich, um **IDDFS** zu signalisieren, mit der Vertiefung fortzufahren oder aufzuhören, falls die Baumtiefe und die Zielzugehörigkeit *a priori* unbekannt sind. Eine andere Lösung könnte stattdessen [Sentinel-Werte](https://en.wikipedia.org/wiki/Sentinel_value) verwenden, um *nicht gefundene* oder *verbleibende Ebene* Ergebnisse darzustellen.

### Eigenschaften

IDDFS kombiniert die Raumeffizienz der Deep-First-Suche mit der Vollständigkeit der Breadth-First-Suche (wenn der Verzweigungsfaktor endlich ist). Wenn eine Lösung existiert, wird ein Lösungsweg mit den wenigsten Bögen gefunden.

Da die iterative Vertiefung Zustände mehrfach besucht, mag es verschwenderisch erscheinen, aber es stellt sich heraus, dass es nicht so kostspielig ist, da sich in einem Baum die meisten Knoten in der unteren Ebene befinden, so dass es nicht viel ausmacht, wenn die oberen Ebenen mehrfach besucht werden.

Der Hauptvorteil von IDDFS bei der Suche in einem Spielbaum besteht darin, dass durch die früheren Suchen die häufig verwendeten Heuristiken wie die Killer-Heuristik und das Alpha-Beta-Pruning verbessert werden, so dass eine genauere Schätzung der Punktzahl der verschiedenen Knoten bei der abschließenden Tiefensuche erfolgen kann und die Suche schneller abgeschlossen wird, da sie in einer besseren Reihenfolge durchgeführt wird. Beispielsweise ist das Alpha-Beta Pruning am effizientesten, wenn es die besten Züge zuerst durchsucht.

Ein zweiter Vorteil ist die Reaktionsfähigkeit des Algorithmus. Da frühe Iterationen kleine Werte für d verwenden, werden sie extrem schnell ausgeführt. Dies ermöglicht dem Algorithmus, frühe Hinweise auf das Ergebnis fast sofort zu liefern, gefolgt von Verfeinerungen, wenn d zunimmt. In einer interaktiven Umgebung, wie z. B. in einem Schachprogramm, erlaubt diese Möglichkeit dem Programm, jederzeit mit dem aktuell besten Zug zu spielen, der in der bisher durchgeführten Suche gefunden wurde. Dies kann so ausgedrückt werden, dass jede Tiefe des Suchkerns kursiv eine bessere Annäherung an die Lösung erzeugt, obwohl die bei jedem Schritt geleistete Arbeit rekursiv ist. Dies ist bei einer traditionellen Deep-First-Suche nicht möglich, da diese keine Zwischenergebnisse erzeugt.

> **Hinweis**
>
> Eine Theorie besagt, dass von kleiner zu großer Aufzählungstiefe der Spielbaum vollständig durchsucht wird und die allgemeine Ordnung der Knoten durch flache Suche erhalten wird, die als heuristische Information für die tiefe Traversierung verwendet wird, was den Effekt des Alpha-Beta Pruning verstärkt.  Da jedoch die nachfolgend erwähnte Mill-Bewegung-Sortierung zur Beschleunigung des Alpha-Beta-Beschneidungseffekts sehr signifikant ist, ist diese Methode nicht sehr effektiv, so dass das Programm nicht verwendet wird. 

## Move Ordering

Damit der [Alpha-Beta](https://www.chessprogramming.org/Alpha-Beta)-Algorithmus gut funktioniert, müssen die [besten Züge](https://www.chessprogramming.org/Best_Move) zuerst gesucht werden. Dies gilt insbesondere für [PV-Knoten](https://www.chessprogramming.org/Node_Types#PV) und erwartete [Schnittknoten](https://www.chessprogramming.org/Node_Types#CUT). Das Ziel ist es, sich dem minimalen Baum anzunähern. Andererseits ist - bei Cut-Knoten - der beste Zug nicht immer die billigste Widerlegung, siehe zum Beispiel [enhanced transposition cutoff](https://www.chessprogramming.org/Enhanced_Transposition_Cutoff). **Im Rahmen einer [iterativen Vertiefung](https://www.chessprogramming.org/Iterative_Deepening) ist es am wichtigsten, die [Hauptvariante](https://www.chessprogramming.org/Principal_Variation) der vorherigen [Iteration](https://www.chessprogramming.org/Iteration) als linken Pfad für die nächste Iteration auszuprobieren, was durch eine explizite [dreieckige PV-Tabelle](https://www.chessprogramming.org/Triangular_PV-Table) oder implizit durch die [Transpositionstabelle](https://www.chessprogramming.org/Transposition_Table) erfolgen kann.

 ### Typische Zugreihenfolge

Nach der [Zuggenerierung](https://www.chessprogramming.org/Move_Generation) mit zugewiesenen Zugwerten sortieren Schachprogramme normalerweise nicht die gesamte [Zugliste](https://www.chessprogramming.org/Move_List), sondern führen bei jedem Zugabruf eine [Auswahlsortierung](https://en.wikipedia.org/wiki/Selection_sort) durch. Ausnahmen sind die [Wurzel](https://www.chessprogramming.org/Root) und weitere [PV-Knoten](https://www.chessprogramming.org/Node_Types#PV) mit einigem Abstand zum Horizont, wo man zusätzlichen Aufwand für die Bewertung und Sortierung der Züge betreiben kann. Aus Leistungsgründen versuchen viele Programme, sich die [Zuggenerierung](https://www.chessprogramming.org/Move_Generation) von Fesselungen oder Nicht-Fesselungen an erwarteten [Cut-Nodes](https://www.chessprogramming.org/Node_Types#CUT) zu sparen, sondern versuchen zuerst den Hash-Zug oder Killer, wenn sie in dieser Stellung als legal erwiesen sind.

In Sanmill nutzt der Zug das menschliche Wissen, und die Reihenfolge ist wie folgt:

1. Kann die eigene Seite dazu bringen, mehr Mühlen zu schließen;

2. kann den Gegner daran hindern, mehr Mühlen zu schließen;

3. Soweit möglich, ist die andere Seite des Abwurfs benachbart zum verbotenen Punkt, weil der verbotene Punkt in der Zugphase leer wird;

4. Nehmen Sie die gegnerische Figur und die eigene Figur schließen gerade Mühlen;

5. Nehmen Sie die gegnerische Figur und die eigene Figur angrenzend;

6.	Priorität zu nehmen gegnerische Fähigkeit, stark zu bewegen, das heißt, angrenzend an die Anzahl der leeren Zahlen;
   Darüber hinaus wird versucht, die folgende Methode zu wählen, um die Priorität zu senken:
   
7. Wenn Sie die gegnerische Figur und die drei aufeinanderfolgenden angrenzenden der anderen Seite nehmen, versuchen Sie nicht zu nehmen;

8.	Wenn die andere Seite der nehmenden Figur und ihre eigene Figur nicht benachbart ist, nehmen Sie lieber nicht;

* Wenn die Methode die gleiche Priorität hat, berücksichtigen Sie die folgenden Faktoren:

* Teilen Sie die Schachbrettanzahl in wichtige Punkte auf und priorisieren Sie Punkte mit hoher Priorität. Je mehr Punkte nebeneinander liegen, desto höher ist die Priorität. 

* Verwenden Sie bei gleicher Priorität standardmäßig eine zufällige Sortierung, abhängig von der Konfiguration, um zu verhindern, dass Menschen immer wieder auf der gleichen Gewinnstraße gewinnen, was die Spielbarkeit verbessert. 

Die Zugsortierung ist im Modul "Move Picker" implementiert. 

## Auswertung

**Evaluation**, eine [heuristische Funktion](https://en.wikipedia.org/wiki/Heuristic_(computer_science)) zur Bestimmung des [relativen Wertes](https://www.chessprogramming.org/Score) einer [Stellung](https://www.chessprogramming.org/Chess_Position), d. h. der Gewinnchancen. Wenn wir in jeder Zeile bis zum Ende der Partie sehen könnten, hätte die Auswertung nur die Werte -1 (Verlust), 0 (Remis) und 1 (Gewinn), und die Engine sollte nur bis zur Tiefe 1 suchen, um den besten Zug zu erhalten. In der Praxis kennen wir jedoch den genauen Wert einer Stellung nicht, also müssen wir eine Annäherung vornehmen, deren Hauptzweck der Vergleich von Stellungen ist, und die Engine muss nun tief suchen und die Stellung mit der höchsten Punktzahl innerhalb eines bestimmten Zeitraums finden.

In letzter Zeit gibt es zwei Hauptwege, um eine Auswertung zu erstellen: traditionell und mehrschichtige [neuronale Netzwerke](https://www.chessprogramming.org/Neural_Networks). Diese Seite konzentriert sich auf den traditionellen Weg, der explizite Merkmale wie **die Differenz in der Anzahl der Figuren zwischen den beiden Seiten** berücksichtigt. 

Anfängliche Schachspieler lernen, dies ausgehend vom [Wert](https://www.chessprogramming.org/Point_Value) der [Figuren](https://www.chessprogramming.org/Pieces) selbst zu tun. Computer-Bewertungsfunktionen verwenden ebenfalls den Wert der [Materialbilanz](https://www.chessprogramming.org/Material) als wichtigsten Aspekt und fügen dann andere Überlegungen hinzu. 

### Wo soll man anfangen?

Die erste Überlegung beim Schreiben einer Bewertungsfunktion ist, wie ein Zug im Rahmen von [Minimax](https://www.chessprogramming.org/Minimax) oder dem gebräuchlicheren [NegaMax](https://www.chessprogramming.org/Negamax) bewertet werden soll. Während Minimax normalerweise die weiße Seite mit dem Max-Spieler und Schwarz mit dem Min-Spieler assoziiert und immer vom weißen Standpunkt aus bewertet, verlangt NegaMax eine symmetrische Bewertung in Bezug auf die [zu ziehende Seite](https://www.chessprogramming.org/Side_to_move). Wir sehen, dass man nicht den Zug an sich bewerten muss - sondern das Ergebnis des Zuges (d.h. eine positionelle Bewertung des Brettes als Ergebnis des Zuges). 

### Seite zum Zug relativ

Damit [NegaMax](https://www.chessprogramming.org/Negamax) funktioniert, ist es wichtig, die Bewertung relativ zur ausgewerteten Seite zurückzugeben. Betrachten Sie zum Beispiel eine einfache Auswertung, die nur [Material](https://www.chessprogramming.org/Material) und [Mobilität](https://www.chessprogramming.org/Mobility) berücksichtigt:

```c
materialScore = 5 * (wPiece-bPiece)

mobilityScore = mobilityWt * (wMobility-bMobility) [Derzeit nicht implementiert]
```

*Rückgabe der Punktzahl relativ zur [zu bewegenden Seite](https://www.chessprogramming.org/Side_to_move) (who2Move = +1 für Weiß, -1 für Schwarz): ````

```
Eval = (materialScore + mobilityScore) * who2Move
```

Die Positionsauswertung ist im Modul Evaluation implementiert. 

## Transpositionstabelle

Eine **Transpositionstabelle**, die erstmals in [Greenblatts](https://www.chessprogramming.org/Richard_Greenblatt) Programm [Mac Hack VI](https://www.chessprogramming.org/Mac_Hack#HashTable) verwendet wurde, ist eine Datenbank, die Ergebnisse von zuvor durchgeführten Suchen speichert. Es ist eine Möglichkeit, den Suchraum eines [Schachbaums](https://www.chessprogramming.org/Search_Tree) mit geringen negativen Auswirkungen stark zu reduzieren.  Die Programme stoßen bei ihrer [Brute-Force](https://www.chessprogramming.org/Brute-Force)-Suche immer wieder auf dieselben [Stellungen](https://www.chessprogramming.org/Chess_Position), aber aus unterschiedlichen Sequenzen von [Zügen](https://www.chessprogramming.org/Moves), was als [Transposition](https://www.chessprogramming.org/Transposition) bezeichnet wird. Transpositionstabellen (und [Widerlegungstabellen](https://www.chessprogramming.org/Refutation_Table)) sind Techniken, die von der [dynamischen Programmierung](https://www.chessprogramming.org/Dynamic_Programming) abgeleitet sind, einem Begriff, der von [Richard E. Bellman](https://www.chessprogramming.org/Richard_E._Bellman) in den 1950er Jahren geprägt wurde, als Programmieren noch Planung bedeutete und die dynamische Programmierung dazu gedacht war, mehrstufige Prozesse optimal zu planen.

### Wie funktioniert es?

Wenn die Suche auf eine [Transposition](https://www.chessprogramming.org/Transposition) stößt, ist es vorteilhaft, sich zu "merken", was bei der letzten Untersuchung der Stellung ermittelt wurde, anstatt die gesamte Suche noch einmal zu wiederholen. Aus diesem Grund haben Schachprogramme eine Transpositionstabelle, die eine große [Hash-Tabelle](https://www.chessprogramming.org/Hash_Table) ist, in der Informationen über die zuvor untersuchten Positionen gespeichert sind, wie tief sie durchsucht wurden und was wir über sie herausgefunden haben. Selbst wenn die [Tiefe](https://www.chessprogramming.org/Depth) (Entwurf) des zugehörigen Transpositionstabelleneintrags nicht groß genug ist oder nicht die richtige Grenze für einen Cutoff enthält, kann ein [bester](https://www.chessprogramming.org/Best_Move) (oder gut genug) Zug aus einer früheren Suche die [Zugreihenfolge](https://www.chessprogramming.org/Move_Ordering) verbessern und Suchzeit sparen. Dies gilt insbesondere im Rahmen einer [iterativen Vertiefung](https://www.chessprogramming.org/Iterative_Deepening), wo man wertvolle Tabellentreffer aus früheren Iterationen gewinnt.

### Hash-Funktionen

[Hash-Funktionen](https://en.wikipedia.org/wiki/Hash_function) konvertieren Schachpositionen in eine nahezu eindeutige, skalare Signatur, die sowohl eine schnelle Indexberechnung als auch eine platzsparende Überprüfung der gespeicherten Positionen ermöglicht.

- [Zobrist Hashing](https://www.chessprogramming.org/Zobrist_Hashing)
- [BCH-Hashing](https://www.chessprogramming.org/BCH_Hashing)

Sowohl das gebräuchlichere Zobrist-Hashing als auch das BCH-Hashing verwenden schnelle Hash-Funktionen, um Hash-Schlüssel oder Signaturen als eine Art [Gödel-Zahl](https://en.wikipedia.org/wiki/Gödel_number) von Schachpositionen bereitzustellen, heute typischerweise [64-bit](https://www.chessprogramming.org/Quad_Word) breit, für Mill reichen 32-bit. Sie werden [inkrementell](https://www.chessprogramming.org/Incremental_Updates) während [make](https://www.chessprogramming.org/Make_Move) und [unmake move](https://www.chessprogramming.org/Unmake_Move) entweder durch own-inverse [exclusive or](https://www.chessprogramming.org/General_Setwise_Operations#ExclusiveOr) oder durch Addition versus Subtraktion aktualisiert.

### Adressberechnung

Der Index basiert nicht auf dem gesamten Hash-Schlüssel, da dieser in der Regel eine 64-Bit- oder 32-Bit-Zahl ist und bei den derzeitigen Hardwarebeschränkungen keine Hash-Tabelle groß genug sein kann, um ihn unterzubringen. Daher erfordert die Berechnung der Adresse oder des Indexes eine Signatur [modulo](https://en.wikipedia.org/wiki/Modulo_operator) Anzahl von Einträgen, für Tabellen der Größe einer Zweierpotenz, den unteren Teil des Hash-Schlüssels, maskiert durch eine 'und'-Anweisung entsprechend.

### Kollisionen

Die [surjektive](https://en.wikipedia.org/wiki/Surjection) Abbildung von Positionen auf eine Signatur und ein noch dichterer Indexbereich impliziert **Kollisionen**, verschiedene Positionen teilen sich gleiche Einträge, aus zwei verschiedenen Gründen, hoffentlich seltene mehrdeutige Schlüssel (Typ-1-Fehler), oder regelmäßig mehrdeutige Indizes (Typ-2-Fehler).

### Welche Informationen werden gespeichert

Typischerweise werden die folgenden Informationen gespeichert, wie durch die [Suche](https://www.chessprogramming.org/Search) bestimmt:

- [Zobrist-](https://www.chessprogramming.org/Zobrist_Hashing) oder [BCH-Schlüssel](https://www.chessprogramming.org/BCH_Hashing), um beim Sondieren zu schauen, ob die Position die richtige ist
- [Best-](https://www.chessprogramming.org/Best_Move) oder [Refutation move](https://www.chessprogramming.org/Refutation_Move) [derzeit nicht implementiert]
- [Depth](https://www.chessprogramming.org/Depth) (Entwurf)
- [Score](https://www.chessprogramming.org/Score), *entweder mit* [Integrated Bound and Value](https://www.chessprogramming.org/Integrated_Bounds_and_Values) *oder sonst mit*
- [Typ des Knotens](https://www.chessprogramming.org/Node_Types)

- [Alter](https://www.chessprogramming.org/Transposition_Table#Aging) wird verwendet, um zu bestimmen, wann Einträge aus der Suche nach vorherigen Positionen während des Spiels überschrieben werden sollen.

### Tabelleneintragstypen

Bei einer [Alpha-Beta-Suche](https://www.chessprogramming.org/Alpha-Beta) finden wir normalerweise nicht den genauen Wert einer Position. Aber wir sind froh, wenn wir wissen, dass der Wert entweder zu niedrig oder zu hoch ist, als dass wir uns mit der Suche weiter beschäftigen müssten. Wenn wir den exakten Wert haben, speichern wir diesen natürlich in der Transpositionstabelle. Aber wenn der Wert unserer Position entweder hoch genug ist, um die untere Grenze zu setzen, oder niedrig genug, um die obere Grenze zu setzen, ist es gut, auch diese Information zu speichern. So wird jeder Eintrag in der Transpositionstabelle mit dem [Typ des Knotens](https://www.chessprogramming.org/Node_Types) identifiziert, oft auch als [exakt](https://www.chessprogramming.org/Exact_Score), [untere](https://www.chessprogramming.org/Lower_Bound)- oder [obere Grenze](https://www.chessprogramming.org/Upper_Bound) bezeichnet.

### Ersetzungs-Strategien

Da es eine begrenzte Anzahl von Einträgen in einer Transpositionstabelle gibt und diese sich in modernen Schachprogrammen sehr schnell füllen kann, ist es notwendig, ein Schema zu haben, mit dem das Programm entscheiden kann, welche Einträge am wertvollsten zu behalten sind, d.h. ein Ersetzungsschema. Ersetzungsschemata werden verwendet, um eine Indexkollision zu lösen, wenn ein Programm versucht, eine Position in einem Tabellenplatz zu speichern, in dem sich bereits ein anderer Eintrag befindet. Es gibt zwei gegensätzliche Überlegungen zu Ersetzungsschemata:

- Einträge, die in einer hohen Tiefe gesucht wurden, sparen mehr Arbeit pro Tabellentreffer als solche, die in einer geringen Tiefe gesucht wurden.
- Einträge, die näher an den Blättern des Baums liegen, werden mit größerer Wahrscheinlichkeit mehrfach durchsucht, so dass die Tabellentreffer bei ihnen höher sind. Außerdem ist es wahrscheinlicher, dass Einträge, die kürzlich durchsucht wurden, erneut durchsucht werden.
- Die meisten gut funktionierenden Ersetzungsstrategien verwenden eine Mischung aus diesen Überlegungen.

### Implementierung

Im Spielbaum werden viele Knoten über unterschiedliche Pfade erreicht, aber die Position ist genau die gleiche.  Während der Alpha-Beta-Suche verwendet das Programm eine Transpositionstabelle, um die Hierarchie, die Punktzahlen und die Wertetypen für die gesuchte Knotenposition zu speichern. Bei der anschließenden Suche im Spielbaum suchen Sie zuerst nach der Transpositionstabelle, wenn Sie feststellen, dass die entsprechende Position aufgezeichnet wurde und die entsprechende Ebene des Datensatzes und die Ebene des Suchknotens gleich oder näher am Blattknoten sind, dann wählen Sie direkt die Transpositionstabelle aus, um die entsprechende Punktzahl aufzuzeichnen; andernfalls werden die Hierarchie-, Punktzahl- und Wertetypinformationen für die Position zur Transpositionstabelle hinzugefügt. Während der Alpha-Beta-Suche tritt ein Knoten des Spielbaums in einem von drei Fällen auf: 

* BOUND_UPPER
 der Knotenwert ist unbekannt, aber größer oder gleich Beta; 

* BOUND_LOWER
  der Knotenpunktwert ist unbekannt, aber kleiner oder gleich Alpha; 

* BOUND_EXACT
  der Knotenpunktwert ist bekannt, alpha <- der Knotenpunktwert <-beta, das ist der genaue Wert. 

Der Typ `BOUND_EXACT` kann als exakte Punktzahl des aktuellen Knotens in der Transpositionstabelle hinterlegt werden, `BOUND_UPPER`, `BOUND_LOWER` entsprechende Begrenzungswerte können für das weitere Pruning noch helfen, aber auch in der Transpositionstabelle hinterlegt werden, so dass die Datensätze der Transpositionstabelle ein Flag benötigen, um den Wertetyp darzustellen, d.h. den exakten Wert, oder die obere Grenze von Fall 1), oder Fall 2) der unteren Begrenzung. Während der Suche ist zu prüfen, ob die gespeicherten Ergebnisse in der Transpositionstabelle direkt den Wert des aktuellen Knotens repräsentieren oder den aktuellen Knoten zu einer Alpha-Beta-Beschneidung veranlassen, und wenn nicht, ist die Suche nach dem Knoten fortzusetzen. Um Nachschlagen in Transpositionstabellen so schnell wie möglich zu realisieren, muss die Transpositionstabelle als Hash-Tabellen-Array TT ausgeführt werden, und das Array-Element `TT(key)` speichert die entsprechende Hierarchie, den Score und den Wertetyp unter dem Positionsschlüssel.  Basierend auf Informationen über eine Position, finden Sie schnell die entsprechenden Datensätze in der Hash-Tabelle.  Konstruieren Sie unter Verwendung der Zobrist-Hash-Methode ein Array mit 32-Bit-Zufallszahlen, `Schlüssel psq` , `Stück_TYPE_NB` und `SQUARE_NB`, mit einem 32-Bit-Zufallswert für Stücke des Typs `StückTyp` in Brettkoordinaten `(x, y)`.    Zur Unterscheidung von den Zufallszahlen aller auf dem Brett vorhandenen Spielsteintypen oder durch Speicherung der Ergebnisse in der 32-Bit-Variablen key erhält man ein Merkmal der Position. Wenn also ein Stein des Typs1 von `(x1, y1)` nach `(x2, y2)` bewegt wird, wird für den aktuellen `BoardKey`-Wert einfach Folgendes getan

1) Der zu bewegende Stein wird vom Brett entfernt, der Schlüssel ist `psq(type1) x1`, ("stellt eine Bit-Differenz oder Operation dar, wie unten"; 

2) Wenn die Zielkoordinaten Steine des anderen Typs haben, die ebenfalls entfernt werden, ist der Schlüssel `psq` . 

3) Setzen Sie die verschobenen Stücke in die Zielkoordinaten, Schlüssel s, psq s, Typ1 s x2 s y2.  Dissident oder Operationen werden im Computer sehr schnell ausgeführt, was die Berechnungen des Computers beschleunigt. 

Der Schlüsselwert ist die gleiche Position, die entsprechende Zeile der Mühle kann unterschiedlich sein, so definieren a3 2-Bit-Seite konstant, wenn die Zeile Seite Umwandlung, den Schlüssel und Seite oder.

Da die Anzahl der Stücke, die eine Partei kann derzeit in der gleichen Position unterschiedlich ist, sollte es als eine andere Position, um dieses Problem zu lösen, verwendet das Programm die Methode der Verwendung der hohen zwei Bits von 32-Bit-Schlüssel, um die Anzahl der Kinder, die in der aktuellen Position genommen werden können, zu speichern. 

Der oben erwähnte MTD(f)-Algorithmus nähert sich im Suchprozess allmählich dem gesuchten Wert, und viele Knoten werden möglicherweise mehrfach durchsucht. Daher verwendet das Programm diese Hash-basierte Transpositionstabelle, um gesuchte Knoten im Speicher zu halten, damit sie bei einer erneuten Suche direkt entnommen werden können und eine erneute Suche vermieden wird. 

## Prefetching

Eine wichtige Leistungsverbesserung nutzt das Programm, um die benötigten Daten in der Nähe des Prozessors zwischenzuspeichern. Durch Prefetching kann die Zugriffszeit auf Daten erheblich reduziert werden. Die meisten modernen Prozessoren haben drei Arten von Speicher:

- Der Level-1-Cache unterstützt typischerweise den Single-Cycle-Zugriff
- Der sekundäre Cache unterstützt den Zwei-Zyklus-Zugriff
- Der Systemspeicher unterstützt längere Zugriffszeiten

Um die Zugriffslatenz zu minimieren und damit die Leistung zu verbessern, ist es eine gute Idee, die Daten im nächstgelegenen Speicher zu halten. Die manuelle Durchführung dieser Aufgabe wird als Pre-Crawling bezeichnet. Der GCC unterstützt das manuelle Pre-Crawling von Daten durch die eingebaute Funktion `__builtin_prefetch` .  

Das Programm in der Alpha-Beta-Suchphase des rekursiven Aufrufs zu einer tieferen Suche, der erste Methodengenerator, der durch die Ausführung der Position des Schlüssels manuelles Pre-Crawling erzeugt wird, verbessert die Leistung.

Das Framework für Daten-Prefetch in GCC unterstützt die Fähigkeiten einer Vielzahl von Zielen. Optimierungen innerhalb des GCC, die das Prefetching von Daten beinhalten, geben relevante Informationen an die zielspezifische Prefetch-Unterstützung weiter, die diese entweder nutzen oder ignorieren kann. Die hier aufgeführten Informationen über die Daten-Prefetch-Unterstützung in GCC-Targets wurden ursprünglich als Input für die Bestimmung der Operanden für GCCs "Prefetch"-RTL-Muster gesammelt, könnten aber auch weiterhin für diejenigen nützlich sein, die neue Prefetch-Optimierungen hinzufügen.

## Bitboards

**Bitboards**, auch Bitsets oder Bitmaps genannt, oder besser **Square Sets**, werden unter anderem verwendet, um das [Brett](https://www.chessprogramming.org/Chessboard) innerhalb eines Schachprogramms in einer **stückzentrierten** Weise darzustellen. Bitbretter, sind im Wesentlichen, [endliche Mengen](https://en.wikipedia.org/wiki/Finite_set) von bis zu [64](https://en.wikipedia.org/wiki/64_(Zahl)) [Elementen](https://en.wikipedia.org/wiki/Element_(Mathematik)) - alle [Quadrate](https://www.chessprogramming.org/Squares) eines [Schachbretts](https://www.chessprogramming.org/Chessboard), ein [Bit](https://www.chessprogramming.org/Bit) pro Quadrat. Andere [Brettspiele](https://www.chessprogramming.org/Games) mit größeren Brettern können ebenfalls mengenmäßige Darstellungen verwenden, aber das klassische Schach hat den Vorteil, dass ein [64-Bit-Wort](https://www.chessprogramming.org/Quad_Word) oder Register das gesamte Brett abdeckt. Noch bitbrettfreundlicher ist [Checkers](https://www.chessprogramming.org/Checkers) mit 32-Bit-Bitbrettern und weniger [Figuren-Typen](https://www.chessprogramming.org/Pieces#PieceTypeCoding) als Schach.

### Das Brett der Mengen

Um [das Brett](https://www.chessprogramming.org/Board_Representation) zu repräsentieren, benötigen wir typischerweise ein Bitboard für jeden [Figuren-Typ](https://www.chessprogramming.org/Pieces#PieceTypeCoding) und jede [Farbe](https://www.chessprogramming.org/Color) - wahrscheinlich gekapselt in einer Klasse oder Struktur, oder als [Array](https://www.chessprogramming.org/Array) von Bitboards als Teil eines Positionsobjekts. Ein Ein-Bit innerhalb eines Bitboards impliziert die Existenz eines Stücks dieses Stück-Typs auf einem bestimmten Quadrat - eins zu eins assoziiert durch die Bit-Position.

- [Square Mapping Considerations](https://www.chessprogramming.org/Square_Mapping_Considerations)
- [Standard-Board-Definition](https://www.chessprogramming.org/Bitboard_Board-Definition)

### Bitboard-Grundlagen

Natürlich geht es bei Bitboards nicht nur um das Vorhandensein von Stücken - es handelt sich um eine universelle, **satzweise** Datenstruktur, die in ein 64-Bit-Register passt. Eine Bitplatine kann zum Beispiel Dinge wie Angriffs- und Verteidigungssätze, Zug-Ziel-Sätze und so weiter darstellen.

### Bitboard-Geschichte

Der allgemeine Ansatz von [Bitsets](https://www.chessprogramming.org/Mikhail_R._Shura-Bura#Bitsets) wurde 1952 von [Mikhail R. Shura-Bura](https://www.chessprogramming.org/Mikhail_R._Shura-Bura) vorgeschlagen. Die Bitboard-Methode zur Durchführung eines Brettspiels scheint ebenfalls 1952 von [Christopher Strachey](https://www.chessprogramming.org/Christopher_Strachey) erfunden worden zu sein, der Bitboards für Weiß, Schwarz und König in seinem Schachprogramm für den [Ferranti Mark 1](https://www.chessprogramming.org/Ferranti_Mark_1) verwendete, und Mitte der 1950er Jahre auch von [Arthur Samuel](https://www.chessprogramming.org/Arthur_Samuel) in seinem Schachprogramm. Im Computerschach wurden Bitboards erstmals von [Georgy Adelson-Velsky](https://www.chessprogramming.org/Georgy_Adelson-Velsky) et al. 1967 beschrieben, nachgedruckt 1970. Bitboards wurden in [Kaissa](https://www.chessprogramming.org/Kaissa) und in [Chess](https://www.chessprogramming.org/Chess_(Programm)) verwendet. Die Erfindung und Veröffentlichung von [Rotated Bitboards](https://www.chessprogramming.org/Rotated_Bitboards) durch [Robert Hyatt](https://www.chessprogramming.org/Robert_Hyatt) und [Peter Gillgasch](https://www.chessprogramming.org/Peter_Gillgasch) mit [Ernst A. Heinz](https://www.chessprogramming.org/Ernst_A._Heinz) in den 90er Jahren war ein weiterer Meilenstein in der Geschichte der Bitboards. Die Innovationen von [Steffan Westcott](https://www.chessprogramming.org/Steffan_Westcott), die auf 32-Bit-[x86](https://www.chessprogramming.org/X86) Prozessoren zu teuer waren, sollten mit Blick auf [x86-64](https://www.chessprogramming.org/X86-64) und [SIMD-Befehle](https://www.chessprogramming.org/SIMD_and_SWAR_Techniques) wieder aufgegriffen werden. Mit dem Aufkommen der schnellen 64-Bit-Multiplikation zusammen mit schnellerem [Speicher](https://www.chessprogramming.org/Memory) haben die [Magic Bitboards](https://www.chessprogramming.org/Magic_Bitboards), wie sie von [Lasse Hansen](https://www.chessprogramming.org/Lasse_Hansen) vorgeschlagen und von [Pradu Kannan](https://www.chessprogramming.org/Pradu_Kannan) verfeinert wurden, das Rotieren übertroffen.

### Analyse

Die Verwendung von Bitboards hat zahlreiche Diskussionen über deren Kosten und Nutzen ausgelöst. Die wichtigsten zu berücksichtigenden Punkte sind:

- Bitboards können eine hohe Informationsdichte haben.
- Einzelne bestückte oder sogar leere Bitboards haben eine geringe Informationsdichte.
- Bitboards sind schwach bei der Beantwortung von Fragen wie, welche Figur, wenn überhaupt, auf Feld x steht. Ein Grund, eine redundante [mailbox](https://www.chessprogramming.org/Mailbox) Board-Darstellung mit einigen zusätzlichen [update](https://www.chessprogramming.org/Incremental_Updates) Kosten während [make](https://www.chessprogramming.org/Make_Move)/[unmake](https://www.chessprogramming.org/Unmake_Move) zu behalten.
- Bitboards können mit bitweisen Anweisungen auf allen Quadraten parallel operieren. Dies ist eines der Hauptargumente der Befürworter von Bitboards, weil es eine Flexibilität bei der [Auswertung](https://www.chessprogramming.org/Evaluation) ermöglicht.
- Bitboards sind auf 32-Bit-Prozessoren eher gehandicapt, da jede bitweise Berechnung in zwei oder mehr Anweisungen aufgeteilt werden muss. Da die meisten modernen Prozessoren jetzt 64 Bit haben, ist dieser Punkt etwas abgeschwächt.
- Bitboards verlassen sich oft auf [bit-twiddling](https://www.chessprogramming.org/Bit-Twiddling) und verschiedene Optimierungstricks und spezielle Anweisungen für bestimmte Hardwarearchitekturen, wie [bitscan](https://www.chessprogramming.org/BitScan) und [population count](https://www.chessprogramming.org/Population_Count). Optimaler Code erfordert maschinenabhängige [header-files](http://en.wikipedia.org/wiki/Header_file) in [C](https://www.chessprogramming.org/C)/[C++](https://www.chessprogramming.org/Cpp). Portabler Code ist wahrscheinlich nicht für alle Prozessoren optimal.
- Einige Operationen auf Bitbrettern sind weniger allgemein, z. B. Verschiebungen. Dies erfordert zusätzlichen Code-Overhead.

### Implementierung

Die Darstellungsmethode der Platine ist ein wichtiges Problem, die allgemeine Methode verwendet ein zweidimensionales Array, um die Platine zu repräsentieren, eine Position wird oft durch ein Byte dargestellt, aber die allgemeine Mill-Klasse jede Position des Zustands ist weit weniger als 256. Für viele Mill-Klassen sind Bitboards ein effektiver Weg, um Platz zu sparen und die Leistung zu verbessern. 

Kurz gesagt, eine Bitplatine ist ein Bit in einer Platine, die einige Bits verwendet.  In diesem Programm werden nur 24 Bits von 32 Bits verwendet, um eine Mill-Platine darzustellen, wobei Bits an mehreren Stellen verwendet werden, um Array-Operationen zu ersetzen und die Leistung zu verbessern. 

# Zukünftige Arbeit

Zu den Möglichkeiten für zukünftige Arbeiten gehören:

- Tippen und Analysieren.
- Mobilitätsauswertung, insbesondere für Nine Men's Morris.
- Unterstützung bei der Einstellung des Bewertungsgewichts, außerdem Unterstützung beim Selbsttraining, um das beste Gewicht zu finden.
- Mehr KI-Stile, wie z. B. Opfer.
- Eröffnungsdatenbank.
- Endspiel-Lernen.
- Unterstützung von mehr Regelvarianten. 
- Prüfen mit Standardregeln.
- Mehr Lokalisierung.
- Effizient aktualisierbares neuronales Netz
- Online-Datenbank.
- Weitere Optimierungen.

# Referenzen

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