Calcitem Sanmill Development White Paper
---------------------------------------------------------------------------

This document is a work in progress. Please copy any comments about it to [Calcitem Sdudio](mailto:calcitem@outlook.com). Thank you very much!

# Introduction

This document describes the design of the Sanmill  Mill Game program, focusing on the core algorithm design. We describe the combination of some search methods that benefit from knowledge-based methods.

The mill is a classic "two-person zero-sum, full information, non-accidental" game. The program uses the minimax search algorithm to search the game tree and optimizes the game tree using Alpha-Beta pruning, MTD(f) algorithms, iteration deepening searches, and transposition tables. Through the research and analysis of Mill games, a lot of design and optimization has been carried out in the game algorithm. The program has reached a high level of intelligence. 

To improve performance, the game algorithm engine core is written using C++, the App’s GUI is written using Flutter, and the platform channel is used to deliver messages between Flutter UI and the game engine.  

The total amount of code is about 200,000+ lines. The game algorithm engine is developed independently. Only in the thread management and UCI module copied the chess engine Stockfish about 300 lines of code.

The purpose of using the UCI interface is to create a general framework, which can also be referenced and connected by other Mill Game developers, to facilitate the game AI engine competition.

# Overview

## Hardware environment

### Android phone

1.5GHz CPU or higher

1GB of RAM or higher

Screen resolution of 480x960 or more size

Android 4.1 or higher

### iOS phone

It is expected to support iOS in 2021Q3.

### PC

Flutter edition is developing. It is expected to release in the Microsoft Store in 2021Q2.

Qt edition is available. At present, there are some bugs in the GUI, so it is usually only used for self combat after the algorithm is improved to test the effect of the algorithm. This version supports loading a perfect AI database.

## Development environment

Android Studio 4.1.3
Visual Studio Community 2019
Flutter 2.0.x
Android SDK version 30.0
Android NDK version 21.1

## Programming Language

The game engine is written using C++. App entry code is written using Java, and the UI is written using Dart. 

## Development purposes

Bring entertainment and relaxation to users, and promote this classic board game. 

## Features
Implement the Mill game, support human-AI, human-human, AI-AI three combat modes, support a variety of Mill rule variants, including support Nine Men’s Morris, Twelve Men’s Morris, support the board whether there are diagonal lines, support whether "flying rule," support whether to allow to take closed Mill and other Mill rule variants. Support the setting of the main elements of the UI color, support the setting of difficulty level, AI's playing style, whether to play sound effects, first move, support move history display, statistical data display. Supports the restoration of default settings.  In the event of an unexpected program crash, information can be collected, and, with the user's permission, the E-mail client can be called to send crash and diagnostic information. 

## Technical characteristics

The program game engine uses game tree search algorithms such as MTD(f)and Alpha-Beta pruning to perform optimal search methods, improve performance through moves sorting, transposition tables, and prefetching, and control search duration by iteratively deepening search methods. Using Flutter to develop UI to improve portability. 

# The Mill Game

The Mill is one of the oldest games still played today. Boards have been found on many historic buildings throughout the world. The oldest (about 1400 BC) was carved into a roofing slate on a temple in Egypt. Others have been found as widely strewn as Ceylon, Troy, and Ireland.

The Mill has spread throughout China, by the people's favorite, has evolved "San Qi”, “San San Qi", "Cheng San Qi", "Da San Qi", "San Lian", "Qi San" and many other variants. 

The game is played on a board with 24 points where stones may be placed. Initially, the board is empty and each of the two players holds nine or twelve stones. The player with the white stones starts.

```
        X --- X --- X
        |     |     |
        | X - X - X |
        | |   |   | |
        | | X-X-X | |
        X-X-X   X-X-X
        | | X-X-X | |
        | |   |   | |
        | X - X - X |
        |     |     |
        X --- X --- X
        
        X --- X --- X
        |\    |    /|
        | X - X - X |
        | |\  |  /| |
        | | X-X-X | |
        X-X-X   X-X-X
        | | X-X-X | |
        | |/  |  \| |
        | X - X - X |
        |/    |    \|
        X --- X --- X        
```

Both players start with nine stones each.

The game goes through three phases:

* opening phase

Players alternately place stones on an empty point.

* midgame phase

When all stones are placed, players slide stones to any adjacent vacant point.

* endgame phase

When a player has only three stones left, she may jump a stone to any vacant point.


During the opening, players alternately place. After the opening. their stones on any vacant point.

When all stones have been placed, play proceeds to the midgame. Here a player may slide one of her stones to an adjacent vacant point. If at any time during the game a player succeeds in arranging three of her stones in a row - this is known as closing a mill - she may remove any opponent’s stone that is not part of a mill. 

As soon as a player has only three stones left, the endgame commences. When it is her turn, the player with three stones may jump one of her stones to any vacant point on the board.

The game ends in the following ways:

* A player who has less than three stones loses.
* A player who cannot make a legal move loses.
* If a midgame or endgame position is repeated, the game is a draw.

Two points are subject to debate among Mill enthusiasts. The first hinges on the observation that in the opening it is possible to close two mills simultaneously. Should the player then be allowed to remove one or two opponent’s stones? Our implementation supports both. The second point concerns positions where the player to move has just closed a mill, but all the opponent’s stones are also in mills. May she then remove a stone or not? In our implementation, this rule is configurable. 

# Design intention

There are different variations of Mill being played. The most popular variety - Nine Men’s Morris is a draw. This result was achieved using alpha-beta search and endgame databases by [Palph Gasser](http://library.msri.org/books/Book29/files/gasser.pdf). 

Retrograde Analysis was used to compute databases for all mid and endgame positions (about 10 billion different positions). These positions were split into 28 separate databases characterized by the number of stones on the board i.e. all the 3 Whitestone against 3 Black stone positions, the 4-3, 4-4 ... up to 9-9 positions.

An 18 ply alpha-beta search for the opening phase then found the value of the initial position (the empty board). Only the 9-9, 9-8, and 8-8 databases were needed to establish that the game is a draw.

Some implements are using the database to perfect unbeatable AI, such as:

[King Of Muehle](https://play.google.com/store/apps/details?id=com.game.kingofmills)

http://muehle.jochen-hoenicke.de/

https://www.mad-weasel.de/morris.html

Because the database is very large, usually for game rules, we need to build an 80GB database, which can only be used on PC or put the server and query through App. Because the database is huge, it is unrealistic to build a database of all rule variants, so this program usually only supports Nine Men's Morris of standard rules.

Support for a variety of rule variants is the feature of this program. On the other hand, in the case of not using a huge database, we hope to use advanced search algorithms and human knowledge to improve the level of intelligence as much as possible and can subdivide the difficulty level, so that players can enjoy the pleasure of level promotion.

In addition, for PC's Qt version, we already support using the database built by [Nine Men's Morris Game - The perfect playing computer](https://www.mad-weasel.de/morris.html). Unfortunately, it is not a standard rule. It follows the rules in large aspects, but there are differences in some small rules. It should be pointed out that we have not got the detailed text of the standard rules at present. We just verify the standard of the guessing rules by comparing it with other programs. And the main purpose of support access to this database is to evaluate the ability of the AI algorithm, and to measure the effectiveness of the algorithm by the draw rate against perfect AI. The database of other standard rules is not open to source code and interface for the time being, so it cannot be connected.

In the future, we may use the algorithm of building a perfect AI database to build our own database, but this requires the cost of the server to store the database. It is not expected that we will have this plan in the short term. In the medium term, the more feasible way is to train through an endgame database or [NNUE](https://en.wikipedia.org/wiki/Efficiently_updatable_neural_network) and continue to improve the level of intelligence at a lower cost.

We are sharing and freely distributing the code, tools, and data needed to deliver the Sanmill program. We do this because we are convinced that open software and open data are key ingredients to make rapid progress. Our ultimate goal is to bring together the strength of the community and make Sanmill a powerful program to bring fun to mill fans worldwide, especially in Europe, South Africa, China, and other places where mill games are widely spread.

# Components

## Algorithm engine

The engine module is responsible for searching for one of the best moves to return to the UI module based on the specified position and the status information such as who plays first.  It is divided into the following sub-modules:

1. Bitboard

2. Evaluation

3. Hash table (unlocked).

4. Mill game logic

5. Move generator

6. Move picker

7. Configuration management

8. Rule management

9. Best move searching

10. Thread management

11. Transposition table

12. Universal Chess Interface (UCI)

13. UCI options management

## UI frontend

UI module: With Flutter development, Flutter has the advantages of high development efficiency, Android/iOS dual-ended UI consistency, beautiful UI, and comparable Native performance. 

The UI module is broken down into the following modules:

Mill Logic module, basically the algorithm engine of the Mill logic module translated into the Dart language; Specifically divided into game logic module, Mill behavior module, position management module, move history module, and so on.

Engine communication module: responsible for interacting with the game engine written by C++.

Command module: command queue for management and game engine interaction;

Configuration management: including in-memory configuration and Flash configuration management;

Drawing module: including board drawing and piece drawing;

Service module: including audio services;

Style module: including theme style, color style;

Page modules: including board pages, side menu pages, game settings pages, theme  settings pages, rule settings pages, help pages, About pages, license pages, and various UI components;

Multilingual data: Includes English and Chinese string text resources.

# Algorithm design

## Minimax

**Minimax**, an algorithm used to determine the [score](https://www.chessprogramming.org/Score) in a [zero-sum](https://en.wikipedia.org/wiki/Zero-sum) game after a certain number of moves, with the best play according to an [evaluation](https://www.chessprogramming.org/Evaluation) function. The algorithm can be explained like this: In a [one-ply](https://www.chessprogramming.org/Ply) search, where only move sequences with length one are examined, the side to move (max player) can simply look at the [evaluation](https://www.chessprogramming.org/Evaluation) after playing all possible [moves](https://www.chessprogramming.org/Moves). The move with the best evaluation is chosen. But for a two-[ply](https://www.chessprogramming.org/Ply) search, when the opponent also moves, things become more complicated. The opponent (min player) also chooses the move that gets the best score. Therefore, the score of each move is now the score of the worst that the opponent can do.

### History

[Jaap van den Herik's](https://www.chessprogramming.org/Jaap_van_den_Herik) thesis (1983)  contains a detailed account of the known publications on that topic. It concludes that although [John von Neumann](https://www.chessprogramming.org/John_von_Neumann) is usually associated with that concept ([1928](https://www.chessprogramming.org/Timeline#1928))  , [primacy](https://en.wikipedia.org/wiki/Primacy_of_mind) probably belongs to [Émile Borel](https://www.chessprogramming.org/Mathematician#Borel). Further, there is a conceivable claim that the first to credit should go to [Charles Babbage](https://www.chessprogramming.org/Mathematician#Babbage). The original minimax as defined by Von Neumann is based on exact values from [game-terminal positions](https://www.chessprogramming.org/Terminal_Node), whereas the minimax search suggested by [Norbert Wiener](https://www.chessprogramming.org/Norbert_Wiener) is based on [heuristic evaluations](https://www.chessprogramming.org/Evaluation) from positions a few moves distant, and far from the end of the game.

### Implementation

Below the pseudo code for an indirect [recursive](https://www.chessprogramming.org/Recursion) [depth-first search](https://www.chessprogramming.org/Depth-First). For clarity [move making](https://www.chessprogramming.org/Make_Move) and [unmaking](https://www.chessprogramming.org/Unmake_Move) before and after the recursive call is omitted.

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

## Alpha-Beta Pruning

The **Alpha-Beta** algorithm (Alpha-Beta Pruning, Alpha-Beta Heuristic) is a significant enhancement to the [minimax](https://www.chessprogramming.org/Minimax) search algorithm that eliminates the need to search large portions of the [game tree](https://www.chessprogramming.org/Search_Tree) applying a [branch-and-bound](https://en.wikipedia.org/wiki/Branch_and_bound) technique. Remarkably, it does this without any potential of overlooking a better [move](https://www.chessprogramming.org/Moves). If one already has found a quite good move and search for alternatives, **one** [refutation](https://www.chessprogramming.org/Refutation_Move) is enough to avoid it. No need to look for even stronger refutations. The algorithm maintains two values, [alpha](https://www.chessprogramming.org/Alpha) and [beta](https://www.chessprogramming.org/Beta). They represent the minimum score that the maximizing player is assured of and the maximum score that the minimizing player is assured of. 

### How it works

Say it is White's turn to move, and we are searching to a [depth](https://www.chessprogramming.org/Depth) of 2 (that is, we consider all of White's moves, and all of Black's responses to each of those moves.) First, we pick one of White's possible moves - let's call this Possible Move #1. We consider this move and every possible response to this move by black. After this analysis, we determine that making Possible Move #1 is an even position. Then, we move on and consider another of White's possible moves (Possible Move #2.) When we consider the first possible counter-move by black, we discover that playing this results in black winning a piece! In this situation, we can safely ignore all of Black's other possible responses to Possible Move #2 because we already know that Possible Move #1 is better. We really don't care *exactly* how much worse Possible Move #2 is. Maybe another possible response wins a Piece, but it doesn't matter because we know that we can achieve *at least* an even game by playing Possible Move #1. The full analysis of Possible Move #1 gave us a [lower bound](https://www.chessprogramming.org/Lower_Bound). We know that we can achieve at least that, so anything that is clearly worse can be ignored.

The situation becomes even more complicated, however, when we go to a search [depth](https://www.chessprogramming.org/Depth) of 3 or greater because now both players can make choices affecting the game tree. Now we have to maintain both a [lower bound](https://www.chessprogramming.org/Lower_Bound) and an [upper bound](https://www.chessprogramming.org/Upper_Bound) (called [Alpha](https://www.chessprogramming.org/Alpha) and [Beta](https://www.chessprogramming.org/Beta).) We maintain a lower bound because if a move is too bad we don't consider it. But we also have to maintain an upper bound because if a move at depth 3 or higher leads to a continuation that is too good, the other player won't allow it, because there was a better move higher up on the game tree that he could have played to avoid this situation. One player's lower bound is the other player's upper bound.

### Savings

The savings of alpha-beta can be considerable. If a standard minimax search tree has **x** [nodes](https://www.chessprogramming.org/Node), an alpha-beta tree in a well-written program can have a node count close to the square-root of **x**. How many nodes you can actually cut, however, depends on how well ordered your game tree is. If you always search for the best possible move first, you eliminate most of the nodes. Of course, we don't always know what the best move is, or we wouldn't have to search in the first place. Conversely, if we always searched worse moves before the better moves, we wouldn't be able to cut any part of the tree at all! For this reason, good [move ordering](https://www.chessprogramming.org/Move_Ordering) is very important and is the focus of a lot of the effort of writing a good chess program. As pointed out by [Levin](https://www.chessprogramming.org/Michael_Levin#Theorem) in 1961, assuming constantly **b** moves for each node visited and search depth **n**, the maximal number of leaves in alpha-beta is equivalent to minimax, **b** ^ **n**. Considering always the best move first, it is **b** ^ [ceil(n/2)](https://en.wikipedia.org/wiki/Floor_and_ceiling_functions) plus **b** ^ [floor(n/2)](https://en.wikipedia.org/wiki/Floor_and_ceiling_functions) minus one. The minimal number of [leaves](https://www.chessprogramming.org/Leaf_Node) is shown in the following table which also demonstrates the [odd-even effect](https://www.chessprogramming.org/Odd-Even_Effect):

## **Negamax** search

Usually, the [Negamax](https://www.chessprogramming.org/Negamax) algorithm is used for simplicity. This means that the evaluation of a position is equivalent to the negation of the evaluation from the opponent's viewpoint. This is because of the zero-sum property of chess: one side's win is the other side's loss.

**Negamax** search is a variant form of [minimax](https://en.wikipedia.org/wiki/Minimax) search that relies on the [zero-sum](https://en.wikipedia.org/wiki/Zero-sum_(Game_theory)) property of a [two-player game](https://en.wikipedia.org/wiki/Two-player_game).

This algorithm relies on the fact that ![{\displaystyle \max(a,b)=-\min(-a,-b)}](https://wikimedia.org/api/rest_v1/media/math/render/svg/e64fb74b232e7412ce1967d786e07fd56b08296f) to simplify the implementation of the [minimax](https://en.wikipedia.org/wiki/Minimax) algorithm. More precisely, the value of a position to player A in such a game is the negation of the value to player B. Thus, the player on move looks for a move that maximizes the negation of the value resulting from the move: this successor position must by definition have been valued by the opponent. The reasoning of the previous sentence works regardless of whether A or B is on move. This means that a single procedure can be used to value both positions. This is a coding simplification over minimax, which requires that A selects the move with the maximum-valued successor while B selects the move with the minimum-valued successor.

It should not be confused with [negascout](https://en.wikipedia.org/wiki/Negascout), an algorithm to compute the minimax or negamax value quickly by clever use of [alpha-beta pruning](https://en.wikipedia.org/wiki/Alpha-beta_pruning) discovered in the 1980s. Note that alpha-beta pruning is itself a way to compute the minimax or negamax value of a position quickly by avoiding the search of certain uninteresting positions.

Most [adversarial search](https://en.wikipedia.org/wiki/Adversarial_search) engines are coded using some form of negamax search.

### Negamax based algorithm

NegaMax operates on the same [game trees](https://en.wikipedia.org/wiki/Game_tree) as those used with the minimax search algorithm. Each node and root node in the tree are game states (such as game board configuration) of a two-player game. Transitions to child nodes represent moves available to a player who's about to play from a given node.

The negamax search objective is to find the node score value for the player who is playing at the root node. The [pseudocode](https://en.wikipedia.org/wiki/Pseudocode) below shows the negamax base algorithm, with a configurable limit for the maximum search depth:

```
function negamax(node, depth, color) is
    if depth = 0 or node is a terminal node then
        return color × the heuristic value of node
    value := −∞
    for each child of node do
        value := max(value, negamax(child, depth − 1, −color))
    return −value
```

```
(* Initial call for Player A's root node *)
negamax(rootNode, depth, 1)
```

```
(* Initial call for Player B's root node *)
negamax(rootNode, depth, −1)
```

The root node inherits its score from one of its immediate child nodes. The child node that ultimately sets the root node's best score also represents the best move to play. Although the negamax function shown only returns the node's best score, practical negamax implementations will retain and return both the best move and best score for the root node. Only the node's best score is essential with non-root nodes. And a node's best move isn't necessary to retain nor return for non-root nodes.

What can be confusing is how the heuristic value of the current node is calculated. In this implementation, this value is always calculated from the point of view of player A, whose color value is one. In other words, higher heuristic values always represent situations more favorable for player A. This is the same behavior as the normal [minimax](https://en.wikipedia.org/wiki/Minimax) algorithm. The heuristic value is not necessarily the same as a node's return value due to value negation by negamax and the color parameter. The negamax node's return value is a heuristic score from the point of view of the node's current player.

Negamax scores match minimax scores for nodes where player A is about to play, and where player A is the maximizing player in the minimax equivalent. Negamax always searches for the maximum value for all its nodes. Hence for player B nodes, the minimax score is a negation of its negamax score. Player B is the minimizing player in the minimax equivalent.

Variations in negamax implementations may omit the color parameter. In this case, the heuristic evaluation function must return values from the point of view of the node's current player.

### Negamax with alpha-beta pruning

Algorithm optimizations for [minimax](https://en.wikipedia.org/wiki/Minimax) are also equally applicable for Negamax. [Alpha-beta pruning](https://en.wikipedia.org/wiki/Alpha-beta_pruning) can decrease the number of nodes the negamax algorithm evaluates in a search tree like its use with the minimax algorithm.

The pseudocode for depth-limited negamax search with alpha-beta pruning follows:

```c
function negamax(node, depth, α, β, color) is
    if depth = 0 or node is a terminal node then
        return color × the heuristic value of the node

    childNodes := generateMoves(node)
    childNodes := orderMoves(childNodes)
    value := −∞
    foreach child in childNodes do
        value := max(value, −negamax(child, depth − 1, −β, −α, −color))
        α := max(α, value)
        if α ≥ β then
            break (* cut-off *)
    return value
```

```c
(* Initial call for Player A's root node *)
negamax(rootNode, depth, −∞, +∞, 1)
```

Alpha (α) and beta (β) represent lower and upper bounds for child node values at a given tree depth. Negamax sets the arguments α and β for the root node to the lowest and highest values possible. Other search algorithms, such as [negascout](https://en.wikipedia.org/wiki/Negascout) and [MTD-f](https://en.wikipedia.org/wiki/MTD-f), may initialize α and β with alternate values to further improve tree search performance.

When negamax encounters a child node value outside an alpha/beta range, the negamax search cuts off thereby pruning portions of the game tree from exploration. Cut-offs are implicit based on the node return value. A node value found within the range of its initial α and β is the node's exact (or true) value. This value is identical to the result the negamax base algorithm would return, without cut-offs and any α and β bounds. If a node return value is out of range, then the value represents an upper (if value ≤ α) or lower (if value ≥ β) bound for the node's exact value. Alpha-beta pruning eventually discards any value-bound results. Such values do not contribute nor affect the negamax value at its root node.

This pseudocode shows the fail-soft variation of alpha-beta pruning. Fail-soft never returns α or β directly as a node value. Thus, a node value may be outside the initial α and β range bounds set with a negamax function call. In contrast, fail-hard alpha-beta pruning always limits a node value in the range of α and β.

This implementation also shows optional move ordering before the [foreach loop](https://en.wikipedia.org/wiki/Foreach_loop) that evaluates child nodes. Move ordering is an optimization for alpha-beta pruning that attempts to guess the most probable child nodes that yield the node's score. The algorithm searches those child nodes first. The result of good guesses is earlier and more frequent alpha/beta cut-offs occur, thereby pruning additional game tree branches and remaining child nodes from the search tree.

### Negamax with alpha-beta pruning and transposition tables

[Transposition tables](https://en.wikipedia.org/wiki/Transposition_table) selectively [memoize](https://en.wikipedia.org/wiki/Memoization) the values of nodes in the game tree. *Transposition* is a term reference that a given game board position can be reached in more than one way with differing game move sequences.

When negamax searches the game tree and encounters the same node multiple times, a transposition table can return a previously computed value of the node, skipping potentially lengthy and duplicate re-computation of the node's value. Negamax performance improves particularly for game trees with many paths that lead to a given node in common.

The pseudo-code that adds transposition table functions to negamax with alpha/beta pruning is given as follows:

```c
function negamax(node, depth, α, β, color) is
    alphaOrig := α

    (* Transposition Table Lookup; node is the lookup key for ttEntry *)
    ttEntry := transpositionTableLookup(node)
    if ttEntry is valid and ttEntry.depth ≥ depth then
        if ttEntry.flag = EXACT then
            return ttEntry.value
        else if ttEntry.flag = LOWERBOUND then
            α := max(α, ttEntry.value)
        else if ttEntry.flag = UPPERBOUND then
            β := min(β, ttEntry.value)

        if α ≥ β then
            return ttEntry.value

    if depth = 0 or node is a terminal node then
        return color × the heuristic value of the node

    childNodes := generateMoves(node)
    childNodes := orderMoves(childNodes)
    value := −∞
    for each child in childNodes do
        value := max(value, −negamax(child, depth − 1, −β, −α, −color))
        α := max(α, value)
        if α ≥ β then
            break

    (* Transposition Table Store; node is the lookup key for ttEntry *)
    ttEntry.value := value
    if value ≤ alphaOrig then
        ttEntry.flag := UPPERBOUND
    else if value ≥ β then
        ttEntry.flag := LOWERBOUND
    else
        ttEntry.flag := EXACT
    ttEntry.depth := depth	
    transpositionTableStore(node, ttEntry)

    return value
```

```
(* Initial call for Player A's root node *)
negamax(rootNode, depth, −∞, +∞, 1)
```

Alpha/beta pruning and maximum search depth constraints in negamax can result in partial, inexact, and entirely skipped evaluation of nodes in a game tree. This complicates adding transposition table optimizations for negamax. It is insufficient to track only the node's *value* in the table, because *value* may not be the node's true value. The code therefore must preserve and restore the relationship of *value* with alpha/beta parameters and the search depth for each transposition table entry.

Transposition tables are typically lossy and will omit or overwrite previous values of certain game tree nodes in their tables. This is necessary since the number of nodes negamax visits often far exceeds the transposition table size. Lost or omitted table entries are non-critical and will not affect the negamax result. However, lost entries may require negamax to re-compute certain game tree node values more frequently, thus affecting performance.

### Implementation

In Sanmill, the principal implementation is as follows:

```c
    for (int i = 0;  i < moveCount;  i++) {
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
            bestValue = value;
    
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
> Because Mill may have a status where one side closes a Mill and then continues to take the opponent's piece, rather than changing to the other side, the odd and even layers may not be strictly divided into the two sides of the game, so it is necessary to determine whether the side changes after the iteration process and then decide whether to take the opposite number.   

## MTD(f) search algorithm

MTD(f) is a minimax search algorithm developed in 1994 by Aske Plaat, Jonathan Schaeffer, Wim Pijls, and Arie de Bruin. Experiments with tournament-quality chess, checkers, and Othello programs show it to be a highly efficient minimax algorithm. The name MTD(f) is an abbreviation for MTD(n,f) (Memory-enhanced Test Driver with node n and value f). It is an alternative to the alpha-beta pruning algorithm.

### Origin

MTD(f) was first described in a University of Alberta Technical Report authored by Aske Plaat, Jonathan Schaeffer, Wim Pijls, and Arie de Bruin,[2] which would later receive the ICCA Novag Best Computer Chess Publication award for 1994/1995. The algorithm MTD(f) was created out of a research effort to understand the SSS* algorithm, a best-first search algorithm invented by George Stockman in 1979. SSS* was found to be equivalent to a series of alpha-beta calls, provided that alpha-beta used storage, such as a well-functioning transposition table.

The name MTD(f) stands for Memory-enhanced Test Driver, referencing Judea Pearl's Test algorithm, which performs Zero-Window Searches. MTD(f) is described in depth in Aske Plaat's 1996 Ph.D. thesis.

### Zero-window searches

MTD(f) derives its efficiency by only performing zero-window alpha-beta searches, with a "good" bound (variable beta). In NegaScout, the search is called with a wide search window, as in AlphaBeta(root, −INFINITY, +INFINITY, depth), so the return value lies between the value of alpha and beta in one call. In MTD(f), AlphaBeta fails high or low, returning a lower bound or an upper bound on the minimax value, respectively. Zero-window calls cause more cutoffs but return less information - only a bound on the minimax value. To find the minimax value, MTD(f) calls AlphaBeta many times, converging towards it and eventually finding the exact value. A transposition table stores and retrieves the previously searched portions of the tree in memory to reduce the overhead of re-exploring parts of the search tree.

### Code

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
            beta = g + VALUE_MTDF_WINDOW;
        } else {
            beta = g;
        }
    
        g = search(pos, ss, depth, 
                   originDepth, beta - VALUE_MTDF_WINDOW, 
                   beta,  bestMove);

        if (g < beta) {
            upperbound = g;     // fail low
        } else {
            lowerbound = g;     // fail high
        }
    }
    
    return g;
}
```

`firstguess`

First, guess for the best value. The better the quicker the algorithm converges. Could be 0 for the first call.

`depth`

Depth to loop for. An [iterative deepening depth-first search](https://en.wikipedia.org/wiki/Iterative_deepening_depth-first_search) could be done by calling `MTDF()` multiple times with incrementing `d` and providing the best previous result in `f`.

### Performance

NegaScout calls the zero-window searches recursively. MTD(f) calls the zero-window searches from the root of the tree. Implementations of the MTD(f) algorithm are more efficient (search fewer nodes) in practice than other search algorithms (e.g. NegaScout) in games such as chess, checkers, and Othello. For search algorithms such as NegaScout or MTD(f) to perform efficiently, the transposition table must work well. Otherwise, for example, when a hash-collision occurs, a subtree will be re-expanded. When MTD(f) is used in programs suffering from a pronounced odd-even effect, where the score at the root is higher for even search depths and lower for odd search depths, it is advisable to use separate values for f to start the search as close as possible to the minimax value. Otherwise, the search would take more iterations to converge on the minimax value, especially for fine-grained evaluation functions.

Zero-window searches hit a cut-off sooner than wide-window searches. They are therefore more efficient, but, in some sense, also less forgiving, than wide-window searches. Because MTD(f) only uses zero-window searches, while Alpha-Beta and NegaScout also use wide window searches, MTD(f) is more efficient. However, wider search windows are more forgiving for engines with large odd/even swings and fine-grained evaluation functions. For this reason, some chess engines have not switched to MTD(f). In tests with tournament-quality programs such as Chinook (checkers), Phoenix (chess), and Keyano (Othello), the MTD(f) algorithm outperformed all other search algorithms.

Recent algorithms like Best Node Search are suggested to outperform MTD(f).  

## Iterative deepening depth-first search

In computer science, iterative deepening search, or more specifically iterative deepening depth-first search (IDS or IDDFS) is a state-space/graph search strategy in which a depth-limited version of depth-first search is run repeatedly with increasing depth limits until the goal is found. IDDFS is optimal like breadth-first search, but uses much less memory; at each iteration, it visits the nodes in the search tree in the same order as depth-first search, but the cumulative order in which nodes are first visited is effectively breadth-first.

### Algorithm for directed graphs

```c
function IDDFS(root) is
    for depth from 0 to ∞ do
        found, remaining ← DLS(root, depth)
        if found ≠ null then
            return found
        else if not remaining then
            return null

function DLS(node, depth) is
    if depth = 0 then
        if node is a goal then
            return (node, true)
        else
            return (null, true)    (Not found, but may have children)

    else if depth > 0 then
        any_remaining ← false
        foreach child of node do
            found, remaining ← DLS(child, depth−1)
            if found ≠ null then
                return (found, true)   
            if remaining then
                any_remaining ← true    (At least one node found at depth, let IDDFS deepen)
        return (null, any_remaining)
```

If the goal node is found, then **DLS** unwinds the recursion returning with no further iterations. Otherwise, if at least one node exists at that level of depth, the *remaining* flag will let **IDDFS** continue.

[2-tuples](https://en.wikipedia.org/wiki/Tuple) are useful as return value to signal **IDDFS** to continue deepening or stop, in case tree depth and goal membership are unknown *a priori*. Another solution could use [sentinel values](https://en.wikipedia.org/wiki/Sentinel_value) instead to represent *not found* or *remaining level* results.

### Properties

IDDFS combines depth-first search's space-efficiency and breadth-first search's completeness (when the branching factor is finite). If a solution exists, it will find a solution path with the fewest arcs.

Since iterative deepening visits states multiple times, it may seem wasteful, but it turns out to be not so costly, since in a tree most of the nodes are in the bottom level, so it does not matter much if the upper levels are visited multiple times.

The main advantage of IDDFS in-game tree searching is that the earlier searches tend to improve the commonly used heuristics, such as the killer heuristic and alpha-beta pruning, so that a more accurate estimate of the score of various nodes at the final depth search can occur, and the search completes more quickly since it is done in better order. For example, alpha-beta pruning is most efficient if it searches for the best moves first.

A second advantage is the responsiveness of the algorithm. Because early iterations use small values for d, they execute extremely quickly. This allows the algorithm to supply early indications of the result almost immediately, followed by refinements as d increases. When used in an interactive setting, such as in a chess-playing program, this facility allows the program to play at any time with the current best move found in the search it has completed so far. This can be phrased as each depth of the search core cursively producing a better approximation of the solution, though the work done at each step is recursive. This is not possible with a traditional depth-first search, which does not produce intermediate results.

> **Note**
>
> One theory is that from small to large enumeration depth, the game tree is repletely searched, and the general ordering of nodes is obtained through shallow search, which is used as heuristic information for deep traversal, which enhances the effect of Alpha-Beta pruning.  However, because the following mentioned Mill moves to sort to accelerate Alpha-Beta pruning effect has been very significant, so this method is not very effective, so the program is not used. 

## Move Ordering

For the [alpha-beta](https://www.chessprogramming.org/Alpha-Beta) algorithm to perform well, the [best moves](https://www.chessprogramming.org/Best_Move) need to be searched first. This is especially true for [PV-nodes](https://www.chessprogramming.org/Node_Types#PV) and expected [Cut-nodes](https://www.chessprogramming.org/Node_Types#CUT). The goal is to become close to the minimal tree. On the other hand - at Cut-nodes - the best move is not always the cheapest refutation, see for instance [enhanced transposition cut off](https://www.chessprogramming.org/Enhanced_Transposition_Cutoff). **Most** important inside an [iterative deepening](https://www.chessprogramming.org/Iterative_Deepening) framework is to try the [principal variation](https://www.chessprogramming.org/Principal_Variation) of the previous [iteration](https://www.chessprogramming.org/Iteration) as the leftmost path for the next iteration, which might be applied by an explicit [triangular PV-table](https://www.chessprogramming.org/Triangular_PV-Table) or implicit by the [transposition table](https://www.chessprogramming.org/Transposition_Table).

 ### Typical move ordering

After [move generation](https://www.chessprogramming.org/Move_Generation) with assigned move-scores, chess programs usually don't sort the whole [move list](https://www.chessprogramming.org/Move_List) but perform a [selection sort](https://en.wikipedia.org/wiki/Selection_sort) each time a move is fetched. Exceptions are the [Root](https://www.chessprogramming.org/Root) and further [PV-Nodes](https://www.chessprogramming.org/Node_Types#PV) with some distance to the horizon, where one may apply additional effort to score and sort moves. For performance reasons, a lot of programs try to save the [move generation](https://www.chessprogramming.org/Move_Generation) of captures or non-captures at expected [Cut-Nodes](https://www.chessprogramming.org/Node_Types#CUT) but try the hash-move or killer first, if they are proved legal in this position.

In Sanmill, the move  leverages human knowledge, and ordering consists as follows:

1. Can make their own side to close more mills;

2. can prevent the opponent from closing more mills;

3. As far as possible, the other side of the drop is adjacent to the banned point, because the banned point will become empty in the moving phase;

4. Take opponent's piece and his own piece just close mills;

5. Take opponent's piece and their own piece's adjacent;

6.	Priority to take opponent's ability to move strong, that is, adjacent to the number of empty numbers;
   In addition, the following method will be tried to choose to lower the priority:
   
7. If you take the other side's piece and the other side's three consecutive adjacents, try not to take;

8.	If the other side of the taking piece and their own piece is not adjacent, prefer not to take;

* If the method has the same priority, consider the following factors:

* Divide the checkerboard count into important points and prioritize high-priority points. The more points adjacent, the higher the priority. 

* If the priority is the same, use random sorting by default, depending on the configuration, to prevent humans from winning again and again on the same winding road, improving playability. 

Mill move sorting is implemented in the Move Picker module. 

## Evaluation

**Evaluation**, a [heuristic function](https://en.wikipedia.org/wiki/Heuristic_(computer_science)) to determine the [relative value](https://www.chessprogramming.org/Score) of a [position](https://www.chessprogramming.org/Chess_Position), i.e. the chances of winning. If we could see to the end of the game in every line, the evaluation would only have values of -1 (loss), 0  (draw), and 1 (win), and the engine should search to depth 1 only to get the best move. In practice, however, we do not know the exact value of a position, so we must make an approximation with the main purpose is to compare positions, and the engine now must search deeply and find the highest score position within a given period.

Recently, there are two main ways to build an evaluation: traditional and multi-layer [neural networks](https://www.chessprogramming.org/Neural_Networks). This page focuses on the traditional way considering explicit features of  **the difference in the number of pieces between the two sides**. 

Beginning chess players learn to do this starting with the [value](https://www.chessprogramming.org/Point_Value) of the [pieces](https://www.chessprogramming.org/Pieces) themselves. Computer evaluation functions also use the value of the [material balance](https://www.chessprogramming.org/Material) as the most significant aspect and then add other considerations. 

### Where to Start

The first thing to consider when writing an evaluation function is how to score a move in [Minimax](https://www.chessprogramming.org/Minimax) or the more common [NegaMax](https://www.chessprogramming.org/Negamax) framework. While Minimax usually associates the white side with the max-player and black with the min-player and always evaluates from the white point of view, NegaMax requires asymmetric evaluation with the [side to move](https://www.chessprogramming.org/Side_to_move). We can see that one must not score the move per se – but the result of the move (i.e. a positional evaluation of the board as a result of the move). 

### Side to move relative

In order for [NegaMax](https://www.chessprogramming.org/Negamax) to work, it is important to return the score relative to the side being evaluated. For example, consider a simple evaluation, which considers  only [material](https://www.chessprogramming.org/Material) and [mobility](https://www.chessprogramming.org/Mobility):

```c
materialScore = 5  * (wPiece-bPiece)

mobilityScore = mobilityWt * (wMobility-bMobility) [Currently not implemented]
```

*return the score relative to the [side to move](https://www.chessprogramming.org/Side_to_move) (who2Move = +1 for white, -1 for black):*

```
Eval  = (materialScore + mobilityScore) * who2Move
```

The position evaluation is implemented in the Evaluation module. 

## Transposition Table

A **Transposition Table**, first used in [Greenblatt's](https://www.chessprogramming.org/Richard_Greenblatt) program [Mac Hack VI](https://www.chessprogramming.org/Mac_Hack#HashTable), is a database that stores results of previously performed searches. It is a way to greatly reduce the search space of a [chess tree](https://www.chessprogramming.org/Search_Tree) with little negative impact.  The programs, during their [brute-force](https://www.chessprogramming.org/Brute-Force) search, encounter the same [positions](https://www.chessprogramming.org/Chess_Position) again and again, but from different sequences of [moves](https://www.chessprogramming.org/Moves), which is called a [transposition](https://www.chessprogramming.org/Transposition). Transposition (and [refutation](https://www.chessprogramming.org/Refutation_Table)) tables are techniques derived from [dynamic programming](https://www.chessprogramming.org/Dynamic_Programming), a term coined by [Richard E. Bellman](https://www.chessprogramming.org/Richard_E._Bellman) in the 1950s when programming meant planning, and dynamic programming was conceived to optimally plan multistage processes.

### How it works

When the search encounters a [transposition](https://www.chessprogramming.org/Transposition), it is beneficial to 'remember' what was determined last time the position was examined, rather than redoing the entire search again. For this reason, chess programs have a transposition table, which is a large [hash table](https://www.chessprogramming.org/Hash_Table) storing information about positions previously searched, how deeply they were searched, and what we concluded about them. Even if the [depth](https://www.chessprogramming.org/Depth) (draft) of the related transposition table entry is not big enough, or does not contain the right bound for a cutoff, a [best](https://www.chessprogramming.org/Best_Move) (or good enough) move from a previous search can improve [move ordering](https://www.chessprogramming.org/Move_Ordering), and save search time. This is especially true inside an [iterative deepening](https://www.chessprogramming.org/Iterative_Deepening) framework, where one gains valuable table hits from previous iterations.

### Hash functions

[Hash functions](https://en.wikipedia.org/wiki/Hash_function) convert chess positions into an almost unique, scalar signature, allowing fast index calculation as well as space-saving verification of stored positions.

- [Zobrist Hashing](https://www.chessprogramming.org/Zobrist_Hashing)
- [BCH Hashing](https://www.chessprogramming.org/BCH_Hashing)

Both, the more common Zobrist hashing as well BCH hashing use fast hash functions, to provide hash keys or signatures as a kind of [Gödel number](https://en.wikipedia.org/wiki/Gödel_number) of chess positions, today typically [64-bit](https://www.chessprogramming.org/Quad_Word) wide, for Mill, 32-bit is enough. They are [updated incrementally](https://www.chessprogramming.org/Incremental_Updates) during [make](https://www.chessprogramming.org/Make_Move) and [unmake move](https://www.chessprogramming.org/Unmake_Move) by either own-inverse [exclusive or](https://www.chessprogramming.org/General_Setwise_Operations#ExclusiveOr) or by addition versus subtraction.

### Address Calculation

The index is not based on the entire hash key because this is usually a 64-bit or 32-bit number, and with current hardware limitations, no hash table can be large enough to accommodate it. Therefore to calculate the address or index requires signature [modulo](https://en.wikipedia.org/wiki/Modulo_operator) number of entries, for the power of two sized tables, the lower part of the hash key, masked by an 'and'-instruction accordantly.

### Collisions

The [surjective](https://en.wikipedia.org/wiki/Surjection) mapping from positions to a signature and an, even more, denser index range implies **collisions**, different positions share same entries, for two different reasons, hopefully, rare ambiguous keys (type-1 errors), or regularly ambiguous indices (type-2 errors).

### What Information is Stored

Typically, the following information is stored as determined by the [search](https://www.chessprogramming.org/Search) :

- [Zobrist-](https://www.chessprogramming.org/Zobrist_Hashing) or [BCH-key](https://www.chessprogramming.org/BCH_Hashing), to look whether the position is the right one while probing
- [Best-](https://www.chessprogramming.org/Best_Move) or [Refutation move](https://www.chessprogramming.org/Refutation_Move) [currently not implement]
- [Depth](https://www.chessprogramming.org/Depth) (draft)
- [Score](https://www.chessprogramming.org/Score), *either with* [Integrated Bound and Value](https://www.chessprogramming.org/Integrated_Bounds_and_Values) *or otherwise with*
- [Type of Node](https://www.chessprogramming.org/Node_Types)

- [Age](https://www.chessprogramming.org/Transposition_Table#Aging) is used to determine when to overwrite entries from searching previous positions during the game.

### Table Entry Types

In an [alpha-beta search](https://www.chessprogramming.org/Alpha-Beta), we usually do not find the exact value of a position. But we are happy to know that the value is either too low or too high for us to be concerned with searching any further. If we have the exact value, of course, we store that in the transposition table. But if the value of our position is either high enough to set the lower bound, or low enough to set the upper bound, it is good to store that information also. So each entry in the transposition table is identified with the [type of node](https://www.chessprogramming.org/Node_Types), often referred to as [exact](https://www.chessprogramming.org/Exact_Score), [lower](https://www.chessprogramming.org/Lower_Bound)- or [upper bound](https://www.chessprogramming.org/Upper_Bound).

### Replacement Strategies

Because there are a limited number of entries in a transposition table, and because in modern chess programs they can fill up very quickly, it is necessary to have a scheme by which the program can decide which entries would be most valuable to keep, i.e. a replacement scheme. Replacement schemes are used to solve an index collision when a program attempts to store a position in a table slot that already has a different entry in it. There are two opposing considerations to replacement schemes:

- Entries that were searched to a high depth save more work per table hit than those searched to a low depth.
- Entries that are closer to the leaves of the tree are more likely to be searched multiple times, making the table hits of them higher. Also, entries that were searched recently are more likely to be searched again.
- Most well-performing replacement strategies use a mix of these considerations.

### Implementation

In the game tree, many nodes are reached by different paths, but the position is the same, and if the nodes are at the same level as the game tree, the scores are the same.  During the Alpha-Beta search, the Program uses a transposition table to save the hierarchy, scores, and value types for the searched node position. In the subsequent game tree search, first look for the transposition table, if you find the corresponding position has been recorded, and the corresponding level of the record and the search node level is the same or closer to the leaf node, then directly select the transposition table to record the corresponding score; Otherwise, the hierarchy, score, and value type information for the position is added to the transposition table. During the Alpha-Beta search, one node of the game tree occurs in one of three cases: 

* BOUND_UPPER
 the node score is unknown but greater than or equal to Beta; 

* BOUND_LOWER
  the node score is unknown, but is less than or equal to alpha; 

* BOUND_EXACT
  the node score is known, alpha  <- the node score <-beta, which is the exact value. 

`BOUND_EXACT` type, can be deposited as the exact score of the current node in the transposition table,  `BOUND_UPPER`, `BOUND_LOWER` corresponding boundary values can still help for further pruning, but also put it into the transposition table, so the records of the transposition table need a flag to represent the value type, that is, the exact value, or the upper boundary of case 1), or case 2) of the lower boundary. During the search, check that the saved results in the transposition table directly represent the value of the current node or cause the current node to produce alpha-Beta pruning, and if not, continue the search for the node. To implement lookups in transposition tables as soon as possible, the transposition table must be designed as a hash table array TT, and the array element `TT(key)` stores the corresponding hierarchy, score, and value type under the position key.  Based on information about a position, quickly find the corresponding records in the Hash table.  Using the Zobrist Hash method, construct an array of 32-bit random numbers, `Key psq`, `PIECE_TYPE_NB`, and `SQUARE_NB`, with a 32-bit random value for pieces of the `PieceType` type inboard coordinates `(x, y)`.    To differ from the random numbers of all types of pieces present on the board, or, by saving the results in the 32-bit  variable key, a feature of the position is obtained. Thus, when a piece of type1 moves from `(x1, y1)` to `(x2, y2)`, simply do the following for the current `BoardKey` value:

1) The piece to be moved removed from the board, the key  is  `psq(type1) x1`, ("represents a bit difference or operation, the same as below"; 

2) If the destination coordinates have pieces of the other type type type, which are also removed, the key is  `psq`. 

3) Place the moving pieces into the destination coordinates, key s, psq s, type1 s x2 s y2.  Dissidents or operations are performed very quickly within the computer, which speeds up the computer's calculations. 

The key value is the same position, the corresponding line of Mill may be different, so define a3 2-bit side constant, when the line side conversion, the key, and side or.

Because the number of pieces that a party can currently take in the same position is different, it should be considered a different position, to solve this problem, the program uses the method using the high two bits of the 32-bit key to store the number of children that can be taken in the current position. 

The aforementioned MTD(f) algorithm gradually approaches the value you are looking for in the search process, and many nodes may be searched multiple times. Therefore, the Program uses this Hash-based transposition table to keep searched nodes in memory so that they can be taken out directly when searching again and avoid re-searching. 

## Prefetching

An important performance improvement is used by the program to cache the necessary data close to the processor. prefetching can significantly reduce the time it takes to access data. Most modern processors have three types of memory:

​     •	Level 1 caching typically supports single-cycle access
​     •	The secondary cache supports two-cycle access
​     •	System memory supports longer access times

To minimize access latency and thus improve performance, it's a good idea to keep your data in the nearest memory. Manually performing this task is called pre-crawling. The GCC supports manual pre-crawling of data through the built-in function `__builtin_prefetch`.  

The program in the Alpha-Beta search phase of the recursive call to a deeper search, the first method generator generated by the execution of the position of key manual pre-crawl, improves performance.

The framework for data prefetch in GCC supports the capabilities of a variety of targets. Optimizations within GCC that involve prefetching data pass relevant information to the target-specific prefetch support, which can either take advantage of it or ignore it. The information here about data prefetch support in GCC targets was originally gathered as input for determining the operands to GCC's `prefetch` RTL pattern but might continue to be useful to those adding new prefetch optimizations.

## Bitboards

**Bitboards**,also called bitsets or bitmaps, or better **Square Sets**, are among other things used to represent the [board](https://www.chessprogramming.org/Chessboard) inside a chess program in a **piece centric** manner. Bitboards, are in essence, [finite sets](https://en.wikipedia.org/wiki/Finite_set) of up to [64](https://en.wikipedia.org/wiki/64_(number)) [elements](https://en.wikipedia.org/wiki/Element_(mathematics)) - all the [squares](https://www.chessprogramming.org/Squares) of a [chessboard](https://www.chessprogramming.org/Chessboard), one [bit](https://www.chessprogramming.org/Bit) per square. Other board [games](https://www.chessprogramming.org/Games) with greater board sizes may be use set-wise representations as well, but classical chess has the advantage that one [64-bit word](https://www.chessprogramming.org/Quad_Word) or register covers the whole board. Even more bitboard friendly is [Checkers](https://www.chessprogramming.org/Checkers) with 32-bit bitboards and less [piece-types](https://www.chessprogramming.org/Pieces#PieceTypeCoding) than chess.

### The Board of Sets

To [represent the board](https://www.chessprogramming.org/Board_Representation) we typically need one bitboard for each [piece-type](https://www.chessprogramming.org/Pieces#PieceTypeCoding) and [color](https://www.chessprogramming.org/Color) - likely encapsulated inside a class or structure, or as an [array](https://www.chessprogramming.org/Array) of bitboards as part of a position object. A one-bit inside a bitboard implies the existence of a piece of this piece-type on a certain square - one to one associated by the bit-position.

- [Square Mapping Considerations](https://www.chessprogramming.org/Square_Mapping_Considerations)
- [Standard Board-Definition](https://www.chessprogramming.org/Bitboard_Board-Definition)

### Bitboard Basics

Of course, bitboards are not only about the existence of pieces - it is a general-purpose, **set-wise** data structure fitting in one 64-bit register. For example, a bitboard can represent things like an attack- and defend sets, move-target sets, and so on.

### Bitboard-History

The general approach of [bitsets](https://www.chessprogramming.org/Mikhail_R._Shura-Bura#Bitsets) was proposed by [Mikhail R. Shura-Bura](https://www.chessprogramming.org/Mikhail_R._Shura-Bura) in 1952. The bitboard method for holding a board game appears to have been invented also in 1952 by [Christopher Strachey](https://www.chessprogramming.org/Christopher_Strachey) using White, Black and King bitboards in his checker's program for the [Ferranti Mark 1](https://www.chessprogramming.org/Ferranti_Mark_1), and in the mid-1950s by [Arthur Samuel](https://www.chessprogramming.org/Arthur_Samuel) in his checker's program as well. In computer chess, bitboards were first described by [Georgy Adelson-Velsky](https://www.chessprogramming.org/Georgy_Adelson-Velsky) et al. in 1967, reprinted 1970. Bitboards were used in [Kaissa](https://www.chessprogramming.org/Kaissa) and in [Chess](https://www.chessprogramming.org/Chess_(Program)). The invention and publication of [Rotated Bitboards](https://www.chessprogramming.org/Rotated_Bitboards) by [Robert Hyatt](https://www.chessprogramming.org/Robert_Hyatt) and [Peter Gillgasch](https://www.chessprogramming.org/Peter_Gillgasch) with [Ernst A. Heinz](https://www.chessprogramming.org/Ernst_A._Heinz) in the 90s was another milestone in the history of bitboards. [Steffan Westcott's](https://www.chessprogramming.org/Steffan_Westcott) innovations, too expensive on 32-bit [x86](https://www.chessprogramming.org/X86) processors, should be revisited with [x86-64](https://www.chessprogramming.org/X86-64) and [SIMD instructions](https://www.chessprogramming.org/SIMD_and_SWAR_Techniques) in mind. With the advent of fast 64-bit multiplication along with faster [memory](https://www.chessprogramming.org/Memory), [Magic Bitboards](https://www.chessprogramming.org/Magic_Bitboards) as proposed by [Lasse Hansen](https://www.chessprogramming.org/Lasse_Hansen) and refined by [Pradu Kannan](https://www.chessprogramming.org/Pradu_Kannan) have surpassed Rotated.

### Analysis

The use of bitboards has spawned numerous discussions about their costs and benefits. The major points to consider are:

- Bitboards can have a high information density.
- Single populated or even empty Bitboards have a low information density.
- Bitboards are weak in answering questions like what piece if any resides on square x. One reason to keep a redundant [mailbox](https://www.chessprogramming.org/Mailbox) board representation with some additional [update](https://www.chessprogramming.org/Incremental_Updates) costs during [make](https://www.chessprogramming.org/Make_Move)/[unmake](https://www.chessprogramming.org/Unmake_Move).
- Bitboards can operate on all squares in parallel using bitwise instructions. This is one of the main arguments used by proponents of bitboards because it allows for flexibility in [evaluation](https://www.chessprogramming.org/Evaluation).
- Bitboards are rather handicapped on 32-bit processors, as each bitwise computation must be split into two or more instructions. As most modern processors are now 64 bit, this point is somewhat diminished.
- Bitboards often rely on [bit-twiddling](https://www.chessprogramming.org/Bit-Twiddling) and various optimization tricks and special instructions for certain hardware architectures, such as [bitscan](https://www.chessprogramming.org/BitScan) and [population count](https://www.chessprogramming.org/Population_Count). Optimal code requires machine dependent [header-files](http://en.wikipedia.org/wiki/Header_file) in [C](https://www.chessprogramming.org/C)/[C++](https://www.chessprogramming.org/Cpp). Portable code is likely not optimal for all processors.
- Some operations on bitboards are less general, f.i. shifts. This requires additional code overhead.

### Implementation

The representation method of the board is an important problem, the general method uses a two-dimensional array to represent the board, a position is often represented by a byte, but in the general Mill class, each position of the state is far less than 256. For many Mill classes, bitboards are an effective way to save space and improve performance. 

In short, a bit board is one bit in a board that uses a few bits.  In this program, using a low of 24 bits of 32 bits to represent a Millboard, using bits in multiple places to replace array operations to improve performance. 

# Future work

Possibilities for future work include:

- Hint and analyzing.
- Mobility evaluation, especially for Nine Men's Morris.
- Support evaluation weight setting, further, support self-training to find the best weight.
- More AI styles, such as sacrifice.
- Opening database.
- Endgame learning.
- Support more Rule variants. 
- Check with standard rules.
- More localization.
- Efficiently updatable neural network
- Online database.
- Other optimizations.

# References

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