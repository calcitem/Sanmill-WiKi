Calcitem Sanmill 开发白皮书
---------------------------------------------------------------------------

本文件是一项正在进行的工作。请将关于它的任何意见复制到 [Calcitem Sdudio](mailto:calcitem@outlook.com)。非常感谢您！

# Introduction

本文描述了 Sanmill Mill Game 程序的设计，重点是核心算法设计。我们描述了一些受益于知识型方法的搜索方法的组合。

磨坊是一个经典的 "两人零和、完全信息、非偶然" 的游戏。该程序使用最小搜索算法来搜索游戏树，并使用 Alpha-Beta 修剪、MTD (f) 算法、迭代深化搜索和换位表来优化游戏树。通过对米尔游戏的研究和分析，在游戏算法上进行了大量的设计和优化。该程序已经达到了很高的智能水平。

为了提高性能，游戏算法引擎核心使用 C++ 编写，App 的 GUI 使用 Flutter 编写，平台通道用于在 Flutter UI 和游戏引擎之间传递信息。

代码总量约为 200,000 多行。游戏算法引擎是独立开发的。只有在线程管理和 UCI 模块中复制了国际象棋引擎 Stockfish 的约 300 行代码。

使用 UCI 接口的目的是创建一个通用框架，其他 Mill Game 的开发者也可以参考和连接，以促进游戏 AI 引擎的竞争。

# Overview

## Hardware environment

### Android phone

1.5GHz CPU or higher

1GB of RAM or higher

Screen resolution of 480x960 or more size

Android 4.2 or higher

### iOS phone

It is expected to support iOS in 2021Q3.

### PC

Flutter 版正在开发中。预计将在 2021 年第二季度在微软商店发布。

Qt 版已经推出。目前 GUI 存在一些 BUG，所以一般只用于算法改进后的自战，测试算法的效果。该版本支持加载完美的 AI 数据库。

## Development environment

Android Studio 4.1.3
Visual Studio Community 2019
Flutter 2.0.x
Android SDK version 30.0
Android NDK version 21.1

## Programming Language

游戏引擎是用 C++ 编写的。应用程序入口代码使用 Java 编写，用户界面使用 Dart 编写。

## Development purposes

为用户带来娱乐和放松，并推广这一经典的棋盘游戏。

## Features

实现米尔游戏，支持人 - AI、人 - 人、AI-AI 三种战斗模式，支持多种米尔规则变体，包括支持九人莫里斯、十二人莫里斯，支持棋盘是否有对角线，支持是否有 "飞行规则"，支持是否允许走封闭米尔等米尔规则变体。支持 UI 主要元素颜色的设置，支持难度等级的设置，AI 的下棋方式，是否播放音效，先手，支持走棋历史显示，统计数据显示。支持恢复默认设置。 在程序意外崩溃的情况下，可以收集信息，经用户同意，可以调用 E-mail 客户端发送崩溃和诊断信息。

## Technical characteristics

该程序游戏引擎使用 MTD (f) 和 Alpha-Beta 修剪等游戏树搜索算法来执行最佳搜索方法，通过移动排序、换位表和预取来提高性能，并通过迭代深化搜索方法来控制搜索时间。使用 Flutter 开发 UI 以提高可移植性。

# The Mill Game

磨坊是今天仍在进行的最古老的游戏之一。世界各地的许多历史建筑上都发现了棋盘。最古老的（约公元前 1400 年）被刻在埃及一座寺庙的屋顶石板上。其他的也被发现散落在锡兰、特洛伊和爱尔兰等地。

磨盘在中国各地流传开来，受到人们的喜爱，先后演变出 "三七"、"三七"、"程三七"、"大三七"、"三联"、"七三" 等许多变体。

游戏是在一个有 24 个点的棋盘上进行的，棋子可以放在那里。最初，棋盘是空的，两名棋手各持 9 个或 12 个棋子。拥有白色棋子的一方开始。

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

双方开始时各有九颗棋子。

游戏要经过三个阶段。

* 开局阶段

玩家交替将棋子放在一个空点上。

* 游戏中期阶段

当所有的棋子都放好后，玩家将棋子滑向任何相邻的空点。

* 终局阶段

当一个棋手只剩下三个棋子时，她可以跳一个棋子到任何空点。

在开局时，玩家交替放置。开局后，他们的棋子放在任何空位上。

当所有的棋子都放置完毕后，游戏进入中盘。在这里，玩家可以将自己的一颗棋子滑到相邻的空位上。如果在游戏过程中的任何时候，玩家成功地将自己的三颗棋子排列成一排 -- 这被称为关闭磨盘 -- 她可以移除任何不属于磨盘的对手的棋子。

一旦玩家只剩下三颗棋子，终局就开始了。当轮到她时，有三个棋子的棋手可以将她的一个棋子跳到棋盘上的任何空位。

游戏结束的方式有以下几种。

* 拥有少于三个棋子的棋手输了。
* 无法下出合法棋步的棋手输了。
* 如果中盘或尾盘的局面被重复出现，则游戏为平局。

有两点在米尔爱好者中存在争议。第一个问题是，在开局时，有可能同时关闭两个磨盘。那么，是否应该允许棋手去掉对方的一个或两个棋子呢？我们的实现支持这两种情况。第二点是关于要下的棋手刚刚关闭了一个磨，但对手的所有棋子也都在磨中的情况。这时她是否可以移走一颗棋子？在我们的实现中，这一规则是可以配置的。

# Design intention

现在有各种不同的莫里斯游戏。最流行的品种 -- 九人制莫里斯是平局。这个结果是由 [Palph Gasser](http://library.msri.org/books/Book29/files/gasser.pdf) 使用 α-β 搜索和尾盘数据库实现的。

逆向分析法被用来计算所有中盘和尾盘位置的数据库（大约 100 亿个不同位置）。这些局面被分成 28 个独立的数据库，其特点是棋盘上的棋子数量，即所有 3 个白石对 3 个黑石的局面，4-3、4-4...... 直到 9-9 的局面。

然后对开局阶段进行 18 层的阿尔法 - 贝塔搜索，找出初始位置（空棋盘）的价值。只需要 9-9、9-8 和 8-8 的数据库就可以确定对局是平局。

一些实现正在使用数据库来完善不可战胜的人工智能，例如。

[King Of Muehle](https://play.google.com/store/apps/details?id=com.game.kingofmills)

<http://muehle.jochen-hoenicke.de/>

<https://www.mad-weasel.de/morris.html>

因为数据库非常大，通常对于游戏规则，我们需要建立一个 80GB 的数据库，这个数据库只能在 PC 上使用，或者放在服务器上，通过 App 查询。因为数据库庞大，要建立所有规则变体的数据库是不现实的，所以本程序通常只支持九宫格莫里斯的标准规则。

支持各种规则变体是这个程序的特点。另一方面，在不使用庞大的数据库的情况下，我们希望利用先进的搜索算法和人类的知识，尽可能提高智能水平，可以细分难度等级，让玩家享受等级提升的乐趣。

另外，对于 PC 的 Qt 版本，我们已经支持使用 [九人莫里斯游戏 -- 完美的游戏电脑]（<https://www.mad-weasel.de/morris.html）建立的数据库。不幸的是，这不是一个标准的规则。它在大的方面遵循规则，但在一些小的规则上存在差异。应该指出的是，我们目前还没有得到标准规则的详细文本。我们只是通过与其他程序的比较来验证猜测规则的标准。而支持访问这个数据库的主要目的是评估人工智能算法的能力，通过对完美人工智能的平局率来衡量算法的有效性。其他标准规则的数据库暂时还没有开放源代码和接口，所以无法连接。>

在未来，我们可能会使用建立完美人工智能数据库的算法来建立我们自己的数据库，但这需要服务器的成本来存储数据库。预计我们在短期内不会有这个计划。从中期来看，更可行的方式是通过终局数据库或 [NNUE](https://en.wikipedia.org/wiki/Efficiently_updatable_neural_network) 进行训练，以较低的成本继续提高智能水平。

我们正在分享和免费分发提供 Sanmill 计划所需的代码、工具和数据。我们这样做是因为我们相信开放软件和开放数据是取得快速进展的关键因素。我们的最终目标是汇集社区的力量，使 Sanmill 成为一个强大的程序，为全世界的磨坊爱好者带来乐趣，特别是在欧洲、南非、中国和其他磨坊游戏广泛传播的地方。

# Components

## Algorithm engine

引擎模块负责根据指定的位置和状态信息（如谁先下）搜索最佳棋步之一，并返回到用户界面模块。 它分为以下几个子模块。

1. 位子板

2. 2. 评估

3. 哈希表（已解锁）。

4. 磨坊游戏逻辑

5. 移动生成器

6. 移动选择器

7. 配置管理

8. 规则管理

9. 最佳动作搜索

10. 线程管理

11. 转位表

12. 通用国际象棋接口 (UCI)

13. UCI 选项管理

## UI frontend

UI 模块。通过 Flutter 开发，Flutter 具有开发效率高、Android/iOS 双端 UI 一致、UI 美观、Native 性能相当的优势。

UI 模块分为以下几个模块。

Mill Logic 模块，基本上是把 Mill 逻辑模块的算法引擎翻译成 Dart 语言；具体分为游戏逻辑模块、Mill 行为模块、位置管理模块、移动历史模块等。

引擎通信模块：负责与 C++ 编写的游戏引擎进行交互。

命令模块：用于管理和游戏引擎交互的命令队列。

配置管理：包括内存配置和 Flash 配置管理。

绘制模块：包括棋盘绘制和棋子绘制。

服务模块：包括音频服务。

风格模块：包括主题风格、颜色风格。

页面模块：包括棋盘页面、侧边菜单页面、游戏设置页面、主题设置页面、规则设置页面、帮助页面、关于页面、许可页面以及各种 UI 组件。

多语言数据。包括英文和中文字符串文本资源。

# Algorithm design

## Minimax

**Minimax**，是一种用于在一定数量的棋步之后确定 [零和](https://en.wikipedia.org/wiki/Zero-sum) 游戏中的 [分数](https://www.chessprogramming.org/Score) 的算法，根据 [评估](https://www.chessprogramming.org/Evaluation) 函数确定最佳棋步。该算法可以这样解释。在 [单倍](https://www.chessprogramming.org/Ply) 搜索中，只检查长度为 1 的棋步序列，要下棋的一方（最大棋手）在下完所有可能的 [棋步](https://www.chessprogramming.org/Moves) 后，可以简单地看一下 [评价](https://www.chessprogramming.org/Evaluation)。选择具有最佳评价的那步棋。但是对于双 [层](https://www.chessprogramming.org/Ply) 搜索来说，当对手也在下棋时，事情就变得更加复杂。对手（min player）也会选择获得最佳分数的那一步。因此，现在每一步棋的分数是对手能做的最差的分数。

### History

[Jaap van den Herik 的](https://www.chessprogramming.org/Jaap_van_den_Herik) 论文 (1983 年) 详细介绍了关于该主题的已知出版物。它的结论是，尽管 [约翰 - 冯 - 诺依曼](https://www.chessprogramming.org/John_von_Neumann) 通常与该概念有关 ([1928](https://www.chessprogramming.org/Timeline#1928))，但 [首要性](https://en.wikipedia.org/wiki/Primacy_of_mind) 可能属于 [埃米尔 - 博莱尔](https://www.chessprogramming.org/Mathematician#Borel)。此外，有一种可以想象的说法是，首先应该归功于 [Charles Babbage](https://www.chessprogramming.org/Mathematician#Babbage)。冯 - 诺依曼定义的原始最小值是基于 [游戏终端位置](https://www.chessprogramming.org/Terminal_Node) 的精确值，而 [诺伯特 - 维纳](https://www.chessprogramming.org/Norbert_Wiener) 建议的最小值搜索是基于几步远的位置的 [启发式评估](https://www.chessprogramming.org/Evaluation)，而且远离游戏的终点。

### Implementation

Below the pseudo code for an indirect [recursive](https://www.chessprogramming.org/Recursion) [depth-first search](https://www.chessprogramming.org/Depth-First). For clarity [move making](https://www.chessprogramming.org/Make_Move) and [unmaking](https://www.chessprogramming.org/Unmake_Move) before and after the recursive call is omitted.

```c
int maxi ( int depth ) {
    if ( depth == 0 ) return evaluate ();
    int max = -oo;
    for ( all moves) {
        score = mini ( depth - 1 );
        if ( score > max )
            max = score;
    }
    return max;
}

int mini ( int depth ) {
    if ( depth == 0 ) return -evaluate ();
    int min = +oo;
    for ( all moves) {
        score = maxi ( depth - 1 );
        if ( score < min )
            min = score;
    }
    return min;
}
```

## Alpha-Beta Pruning

Alpha-Beta** 算法（Alpha-Beta Pruning，Alpha-Beta Heuristic）是对 [minimax](https://www.chessprogramming.org/Minimax) 搜索算法的一个重要改进，它消除了应用 [分支和约束](https://en.wikipedia.org/wiki/Branch_and_bound) 技术搜索 [游戏树](https://www.chessprogramming.org/Search_Tree) 的大部分的需要。值得注意的是，它在做到这一点的同时，没有忽略任何可能的更好的 [棋](https://www.chessprogramming.org/Moves)。如果一个人已经找到了一个相当好的棋，并且在寻找替代品，那么 *** 一个 [反驳](https://www.chessprogramming.org/Refutation_Move) 就足以避免它。没有必要去寻找更强的反驳。该算法保持两个值，[α](https://www.chessprogramming.org/Alpha) 和 [β](https://www.chessprogramming.org/Beta)。它们代表了保证最大化玩家的最小分数和保证最小化玩家的最大分数。

### How it works

假设轮到白方下棋，而我们正在搜索 [深度](https://www.chessprogramming.org/Depth) 为 2（也就是说，我们考虑白方的所有棋步，以及黑方对每步棋的所有回应）。首先，我们从白方的可能棋步中挑选一步 -- 姑且称之为可能棋步 #1。我们考虑这步棋以及黑方对这步棋的所有可能回应。经过这样的分析，我们确定下第 1 步可能的棋是一个平局。然后，我们继续考虑白方的另一步可能的棋（可能的第 2 步棋）。当我们考虑黑方的第一步可能的反击棋时，我们发现下这步棋会导致黑方赢得一个棋子！这时我们可以安全地忽略白方的另一步棋。在这种情况下，我们可以安全地忽略黑方对可能的第 2 步棋的所有其他可能回应，因为我们已经知道可能的第 1 步棋更好。我们真的不关心 *确切地* 可能的第 2 步棋有多差。也许另一种可能的回应会赢得一块棋，但这并不重要，因为我们知道通过下第 1 步棋，我们至少可以实现 ** 平局。对可能的第 1 步棋的全面分析给了我们一个 [下限](https://www.chessprogramming.org/Lower_Bound)。我们知道我们至少可以做到这一点，所以任何明显更差的东西都可以被忽略掉。

然而，当我们的搜索 [深度](https://www.chessprogramming.org/Depth) 达到 3 或更大时，情况变得更加复杂，因为现在双方都可以做出影响对局树的选择。现在我们必须维持一个 [下限](https://www.chessprogramming.org/Lower_Bound) 和一个 [上限](https://www.chessprogramming.org/Upper_Bound)（称为 [Alpha](https://www.chessprogramming.org/Alpha) 和 [Beta](https://www.chessprogramming.org/Beta)）。我们保持一个下限，因为如果一个动作太糟糕，我们就不考虑它。但是我们也必须保持一个上界，因为如果深度为 3 或更高的棋步导致一个太好的继续，另一个棋手就不会允许它，因为在对局树的更高位置有一个更好的棋步，他可以下它来避免这种情况。一个棋手的下限就是另一个棋手的上限。

### Savings

阿尔法 - 贝塔的节省可以是相当大的。如果一个标准的最小搜索树有 **x**[节点](https://www.chessprogramming.org/Node)，在一个写得很好的程序中，alpha-beta 树的节点数可以接近 **x** 的平方根。然而，你实际上能砍掉多少个节点，取决于你的游戏树的有序程度。如果你总是先搜索可能的最佳棋步，你就会消除大部分的节点。当然，我们并不总是知道什么是最好的棋，否则我们就不必首先搜索。反过来说，如果我们总是在更好的棋步之前搜索更坏的棋步，我们就根本无法切割树的任何部分了！这就是为什么好的 [棋步排序] 会让我们在搜索时更容易找到。由于这个原因，好的 [棋步排序](https://www.chessprogramming.org/Move_Ordering) 是非常重要的，也是编写一个好的国际象棋程序的很多努力的重点。正如 [Levin](https://www.chessprogramming.org/Michael_Levin#Theorem) 在 1961 年所指出的，假设每个被访问的节点不断有 **b** 步，搜索深度为 **n**，α-β 的最大叶数相当于最小值，**b** ^ **n**。考虑到总是先走最好的一步，它是 **b** ^ [ceil (n/2)](https://en.wikipedia.org/wiki/Floor_and_ceiling_functions) 加上 **b** ^ [floor (n/2)](https://en.wikipedia.org/wiki/Floor_and_ceiling_functions) 减一。最小的 [叶子](https://www.chessprogramming.org/Leaf_Node) 数目显示在下表中，它也显示了 [奇偶效应](https://www.chessprogramming.org/Odd-Even_Effect)。

## **Negamax** search

通常为了简单起见，使用 [Negamax](https://www.chessprogramming.org/Negamax) 算法。这意味着对一个局面的评价等同于从对手的角度对评价的否定。这是因为国际象棋的零和属性：一方的胜利就是另一方的损失。

**Negamax** 搜索是 [minimax](https://en.wikipedia.org/wiki/Minimax) 搜索的一种变体形式，它依赖于 [双人游戏](https://en.wikipedia.org/wiki/Zero-sum_(Game_theory)) 的 [零和] 属性。

这种算法依靠的是！[{{displaystyle \max (a,b)=-\min (-a,-b)}](https://wikimedia.org/api/rest_v1/media/math/render/svg/e64fb74b232e7412ce1967d786e07fd56b08296f) 这一事实来简化 [minimax](https://en.wikipedia.org/wiki/Minimax) 算法的实现。更确切地说，在这样的博弈中，一个位置对棋手 A 的价值是对棋手 B 的价值的否定。因此，下棋的棋手寻找的是使下棋产生的价值的否定值最大化的棋步：根据定义，这个后继位置必须已经被对手所重视。无论 A 或 B 是在下棋，前一句的推理都是有效的。这意味着可以用一个程序来为两个位置估值。这是对最小化的编码简化，最小化要求 A 选择具有最大价值的后手，而 B 选择具有最小价值的后手。

它不应与 [negascout](https://en.wikipedia.org/wiki/Negascout) 相混淆，后者是一种通过巧妙地使用 1980 年代发现的 [alpha-beta 修剪](https://en.wikipedia.org/wiki/Alpha-beta_pruning) 来快速计算最小值或最大值的算法。请注意，α-β 修剪本身就是一种通过避免搜索某些不感兴趣的位置来快速计算位置的最小值或最大值的方法。

大多数 [对抗性搜索](https://en.wikipedia.org/wiki/Adversarial_search) 引擎都使用某种形式的 negamax 搜索进行编码。

### Negamax based algorithm

NegaMax 在与 minimax 搜索算法使用的相同的 [游戏树](https://en.wikipedia.org/wiki/Game_tree) 上操作。树上的每个节点和根节点都是一个双人游戏的游戏状态（如游戏板配置）。向子节点的转换代表了即将从给定节点开始下棋的棋手可以使用的棋步。

negamax 搜索的目标是为正在根节点下棋的棋手找到节点得分值。下面的 [伪代码](https://en.wikipedia.org/wiki/Pseudocode) 显示了 negamax 的基本算法，对最大搜索深度有一个可配置的限制。

```
function negamax (node, depth, color) is
    if depth = 0 or node is a terminal node then
        return color × the heuristic value of node
    value := −∞
    for each child of node do
        value := max (value, negamax (child, depth − 1, −color))
    return −value
```

```
(* Initial call for Player A's root node *)
negamax (rootNode, depth, 1)
```

```
(* Initial call for Player B's root node *)
negamax (rootNode, depth, −1)
```

根节点从它的一个直接子节点继承它的分数。最终设定根节点最佳分数的子节点也代表了最佳棋步。尽管所示的 negamax 函数只返回节点的最佳得分，但实际的 negamax 实现会保留并返回根节点的最佳棋步和最佳得分。对于非根节点来说，只有节点的最佳分数是必不可少的。而对于非根节点来说，节点的最佳棋步没有必要保留或返回。

可能令人困惑的是，当前节点的启发式价值是如何计算的。在这个实现中，这个值总是从棋手 A 的角度来计算，其颜色值为 1。换句话说，更高的启发式数值总是代表对玩家 A 更有利的情况。这与正常的 [minimax](https://en.wikipedia.org/wiki/Minimax) 算法的行为相同。由于 negamax 和颜色参数的价值否定，启发式值不一定与节点的返回值相同。negamax 节点的返回值是一个启发式分数，从该节点当前玩家的角度来看。

Negamax 分数与棋手 A 即将下棋的节点的 minimax 分数相匹配，而棋手 A 是 minimax 等价物中的最大化棋手。Negamax 总是为其所有节点寻找最大值。因此，对于棋手 B 的节点，最小化分数是其 negamax 分数的否定值。在最小化等价物中，玩家 B 是最小化玩家。

negamax 实现中的变体可能会省略颜色参数。在这种情况下，启发式评估函数必须从节点当前玩家的角度返回数值。

### Negamax with alpha-beta pruning

针对 [minimax](https://en.wikipedia.org/wiki/Minimax) 的算法优化也同样适用于 Negamax。[Alpha-beta 修剪](https://en.wikipedia.org/wiki/Alpha-beta_pruning) 可以减少 negamax 算法在搜索树中评估的节点数量，就像它在 minimax 算法中的使用一样。

深度有限的 negamax 搜索与 alpha-beta 修剪的伪代码如下。

```c
function negamax (node, depth, α, β, color) is
    if depth = 0 or node is a terminal node then
        return color × the heuristic value of the node

    childNodes := generateMoves (node)
    childNodes := orderMoves (childNodes)
    value := −∞
    foreach child in childNodes do
        value := max (value, −negamax (child, depth − 1, −β, −α, −color))
        α := max (α, value)
        if α ≥ β then
            break (* cut-off *)
    return value
```

```c
(* Initial call for Player A's root node *)
negamax (rootNode, depth, −∞, +∞, 1)
```

α(α) 和 β(β) 代表在给定的树深下子节点值的下限和上限。Negamax 将根节点的参数 α 和 β 设置为可能的最低和最高值。其他搜索算法，如 [negascout](https://en.wikipedia.org/wiki/Negascout) 和 [MTD-f](https://en.wikipedia.org/wiki/MTD-f)，可以用替代值初始化 α 和 β，以进一步提高树搜索性能。

当 negamax 遇到一个超出 α/β 范围的子节点值时，negamax 搜索就会切断，从而将游戏树的部分内容从探索中剪除。切断是根据节点的返回值隐含的。在其初始 α 和 β 的范围内发现的节点值是该节点的精确（或真实）值。这个值与 negamax 基础算法所返回的结果相同，没有截断和任何 α 和 β 的限制。如果一个节点的返回值超出了范围，那么这个值就代表了该节点精确值的上限（如果值≤α）或下限（如果值≥β）。阿尔法 - 贝塔修剪最终会丢弃任何数值约束的结果。这些值不会对其根节点的 negamax 值产生影响。

这个伪代码显示了 α-beta 剪枝的失败 - 软化变体。Fail-soft 从不直接返回 α 或 β 作为节点值。因此，一个节点的值可能会超出 negamax 函数调用所设定的初始 α 和 β 的范围界限。相比之下，失败的硬性 α-β 修剪总是将节点值限制在 α 和 β 的范围内。

这个实现还显示了在评估子节点的 [foreach 循环](https://en.wikipedia.org/wiki/Foreach_loop) 之前的可选移动排序。移动排序是对 α-β 修剪的一种优化，它试图猜测最可能产生节点得分的子节点。该算法首先搜索这些子节点。良好猜测的结果是更早、更频繁地发生 α/β 截断，从而从搜索树上修剪出额外的游戏树分支和剩余的子节点。

### Negamax with alpha-beta pruning and transposition tables

[转位表](https://en.wikipedia.org/wiki/Transposition_table) 有选择地 [记忆化](https://en.wikipedia.org/wiki/Memoization) 对局树中的节点的值。*转位* 是一个术语，指一个给定的棋盘位置可以通过不同的棋步序列以多种方式达到。

当 negamax 搜索对局树并多次遇到同一节点时，转位表可以返回该节点先前计算出的数值，从而跳过对该节点数值潜在的冗长和重复的计算。Negamax 的性能提高了，特别是对于有许多路径共同导致一个特定节点的游戏树。

在 negamax 中加入转置表功能的伪代码如下：α/β 修剪。

```c
function negamax (node, depth, α, β, color) is
    alphaOrig := α

    (* Transposition Table Lookup; node is the lookup key for ttEntry *)
    ttEntry := transpositionTableLookup (node)
    if ttEntry is valid and ttEntry.depth ≥ depth then
        if ttEntry.flag = EXACT then
            return ttEntry.value
        else if ttEntry.flag = LOWERBOUND then
            α := max (α, ttEntry.value)
        else if ttEntry.flag = UPPERBOUND then
            β := min (β, ttEntry.value)

        if α ≥ β then
            return ttEntry.value

    if depth = 0 or node is a terminal node then
        return color × the heuristic value of the node

    childNodes := generateMoves (node)
    childNodes := orderMoves (childNodes)
    value := −∞
    for each child in childNodes do
        value := max (value, −negamax (child, depth − 1, −β, −α, −color))
        α := max (α, value)
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
    transpositionTableStore (node, ttEntry)

    return value
```

```
(* Initial call for Player A's root node *)
negamax (rootNode, depth, −∞, +∞, 1)
```

negamax 中的 Alpha/beta 修剪和最大搜索深度限制可能会导致游戏树中的部分、不精确和完全跳过的节点评估。这使得为 negamax 增加换位表优化变得复杂。在表中只跟踪节点的 *值是不够的，因为* 值 *可能不是节点的真实值。因此，代码必须保留和恢复* value * 与 alpha/beta 参数的关系以及每个转置表项的搜索深度。

转置表通常是有损的，会省略或覆盖其表中某些游戏树节点的先前值。这是必要的，因为 negamax 访问的节点数量往往远远超过转置表的大小。丢失或省略的表项是非关键性的，不会影响 negamax 的结果。然而，丢失的条目可能需要 negamax 更频繁地重新计算某些游戏树节点的值，从而影响性能。

### Implementation

In Sanmill, the principal implementation is as follows:

```c
    for (int i = 0;  i < moveCount;  i++) {
        ss.push (*(pos));
        const Color before = pos->sideToMove;
        Move move = mp. moves [i]. move;
        pos->do_move (move);
        const Color after = pos->sideToMove;

        If (after != before) {
            value = -search (pos, ss, depth - 1 + epsilon, 
                            originDepth, -beta, -alpha, bestMove);
        } else {
            value = search (pos, ss, depth - 1 + epsilon, 
                           originDepth, alpha, beta, bestMove);
        }

        pos->undo_move (ss);
    
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

> **注意**
>
> 因为米尔可能会出现一方关闭米尔后继续取对方的棋子，而不是换成另一方的状态，所以奇数层和偶数层可能不会被严格划分为对局的两方，所以有必要在迭代过程后确定一方是否发生变化，然后决定是否取反数。  

## MTD (f) search algorithm

MTD (f) 是由 Aske Plaat、Jonathan Schaeffer、Wim Pijls 和 Arie de Bruin 于 1994 年开发的一种最小化搜索算法。在锦标赛质量的国际象棋、跳棋和黑白棋程序上的实验表明，它是一种高效的最小化算法。MTD (f) 这个名字是 MTD (n,f)（内存增强的测试驱动器，节点为 n，数值为 f）的缩写。它是阿尔法 - 贝塔修剪算法的一个替代方案。

### Origin

MTD (f) 最早是在阿尔伯塔大学的技术报告中描述的，该报告由 Aske Plaat, Jonathan Schaeffer, Wim Pijls 和 Arie de Bruin 撰写，[2] 后来获得了 ICCA Novag 的 1994/1995 年度最佳计算机棋类出版物奖。MTD (f) 算法是在理解 SSS *算法的研究工作中产生的，SSS* 算法是乔治 - 斯托克曼在 1979 年发明的一种最佳优先搜索算法。人们发现 SSS * 等同于一系列的 alpha-beta 调用，只要 alpha-beta 使用存储，比如一个功能良好的转置表。

MTD (f) 这个名字代表了 Memory-enhanced Test Driver，指的是 Judea Pearl 的测试算法，该算法执行零窗口搜索。MTD (f) 在 Aske Plaat 的 1996 年博士论文中被深入描述。

### Zero-window searches

MTD (f) 通过只执行零窗口的 α-β 搜索来获得其效率，并有一个 "好的" 边界（可变 β）。在 NegaScout 中，搜索被调用时有一个宽的搜索窗口，如 AlphaBeta (root, -INFINITY, +INFINITY, depth)，所以返回值在一次调用中位于 α 和 β 的值之间。在 MTD (f) 中，AlphaBeta 会在高位或低位失败，分别返回一个最小值的下限或上限。零窗口调用会导致更多的截断，但返回的信息更少 -- 只有一个关于最小值的约束。为了找到最小值，MTD (f) 多次调用 AlphaBeta，向它收敛，最终找到精确的值。转置表在内存中存储和检索以前搜索过的树的部分，以减少重新探索搜索树的部分的开销。

### Code

```c
Value MTDF (Position *pos, Sanmill::Stack<Position> &ss, Value firstguess,
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
    
        g = search (pos, ss, depth, 
                   originDepth, beta - VALUE_MTDF_WINDOW, 
                   beta,  bestMove);

        if (g < beta) {
            upperbound = g;     //fail low
        } else {
            lowerbound = g;     //fail high
        }
    }
    
    return g;
}
```

`首先猜测`。

首先，猜测最佳值。越好，算法收敛得越快。第一次调用时可以是 0。

` 深度

循环的深度。可以通过多次调用 `MTDF ()` 来完成 [迭代深化深度优先搜索](https://en.wikipedia.org/wiki/Iterative_deepening_depth-first_search)，增加 `d` 并在 `f` 中提供之前的最佳结果。

### Performance

NegaScout 递归地调用零窗口搜索。MTD (f) 从树的根部开始调用零窗口搜索。在象棋、跳棋和黑白棋等游戏中，MTD (f) 算法的实现在实践中比其他搜索算法（如 NegaScout）更有效率（搜索更少的节点）。为了使 NegaScout 或 MTD (f) 等搜索算法有效地执行，转置表必须运作良好。否则，例如，当发生哈希碰撞时，子树将被重新扩展。当 MTD (f) 被用在有明显的奇偶效应的程序中时，即根部的得分在偶数搜索深度中较高，而在奇数搜索深度中较低，建议使用单独的 f 值来开始搜索，尽可能接近最小值。否则，搜索将需要更多的迭代来收敛于最小值，特别是对于细粒度的评价函数。

零窗口搜索比宽窗口搜索更快达到截止点。因此，它们比宽窗口搜索更有效率，但在某种意义上，也更不容易被原谅。因为 MTD（f）只使用零窗口搜索，而 Alpha-Beta 和 NegaScout 也使用宽窗口搜索，所以 MTD（f）更有效率。然而，较宽的搜索窗口对于具有较大的奇数 / 偶数波动和细粒度评估功能的引擎来说是比较宽容的。由于这个原因，一些国际象棋引擎还没有改用 MTD (f)。在对 Chinook（跳棋）、Phoenix（国际象棋）和 Keyano（黑白棋）等锦标赛质量的程序的测试中，MTD（f）算法的表现超过了所有其他搜索算法。

最近的算法，如最佳节点搜索，被建议超过 MTD (f)。

## Iterative deepening depth-first search

在计算机科学中，迭代深化搜索，或者更具体地说，迭代深化深度优先搜索（IDS 或 IDDFS）是一种状态空间 / 图搜索策略，其中深度限制版的深度优先搜索以不断增加的深度限制反复运行，直到找到目标。IDDFS 与宽度优先搜索一样是最优的，但使用的内存要少得多；在每次迭代中，它以深度优先搜索的相同顺序访问搜索树中的节点，但节点首先被访问的累积顺序实际上是宽度优先的。

### Algorithm for directed graphs

```c
function IDDFS (root) is
    for depth from 0 to ∞ do
        found, remaining ← DLS (root, depth)
        if found ≠ null then
            return found
        else if not remaining then
            return null

function DLS (node, depth) is
    if depth = 0 then
        if node is a goal then
            return (node, true)
        else
            return (null, true)    (Not found, but may have children)

    else if depth > 0 then
        any_remaining ← false
        foreach child of node do
            found, remaining ← DLS (child, depth−1)
            if found ≠ null then
                return (found, true)   
            if remaining then
                any_remaining ← true    (At least one node found at depth, let IDDFS deepen)
        return (null, any_remaining)
```

如果找到了目标节点，那么 **DLS** 就会解除递归，不再继续迭代。否则，如果至少有一个节点存在于这个深度，*remaining* 标志将让 **IDDFS** 继续。

[2-tuples](https://en.wikipedia.org/wiki/Tuple) 作为返回值是非常有用的，在树的深度和目标成员是未知的情况下，可以向 **IDDFS** 发出继续深化或停止的信号。另一个解决方案可以使用 [sentinel values](https://en.wikipedia.org/wiki/Sentinel_value) 代替，以表示 *未找到* 或 *剩余级别* 的结果。

### Properties

IDDFS 结合了深度优先搜索的空间效率和广度优先搜索的完整性（当分支因子是有限的）。如果存在一个解决方案，它将找到一个具有最少弧的解决方案路径。

由于迭代深化多次访问状态，看起来很浪费，但事实证明成本并不高，因为在一棵树上，大多数节点都在底层，所以即使上层被多次访问也没有多大关系。

IDDFS 在游戏中进行树形搜索的主要优点是，早期的搜索往往会改进常用的启发式方法，如杀手启发式和 alpha-beta 修剪，这样就可以在最后的深度搜索中对各种节点的得分进行更准确的估计，而且搜索完成得更快，因为它的顺序更好。例如，α-β 修剪如果先搜索最佳棋步，则效率最高。

第二个优点是算法的响应性。由于早期迭代使用小的 d 值，它们的执行速度极快。这使得该算法几乎可以立即提供早期的结果指示，然后随着 d 的增加进行完善。当在交互式环境中使用时，例如在国际象棋程序中，这种设施允许程序在任何时候使用它迄今完成的搜索中发现的当前最佳棋步进行游戏。这可以被表述为搜索核心的每一个深度都会曲折地产生一个更好的解决方案的近似值，尽管每一步的工作都是递归的。这在传统的深度优先搜索中是不可能的，它不会产生中间结果。

> **注意**
>
> 有一种理论认为，从小的枚举深度到大的枚举深度，对游戏树进行完全搜索，通过浅层搜索得到节点的一般排序，作为深层遍历的启发式信息，这样可以增强 Alpha-Beta 修剪的效果。 但是，由于下面提到的 Mill 移动排序对加速 Alpha-Beta 修剪的效果已经非常明显，所以这种方法效果不大，所以该方案没有使用。

## Move Ordering

为了使 [α-β](https://www.chessprogramming.org/Alpha-Beta) 算法表现良好，需要首先搜索 [最佳动作](https://www.chessprogramming.org/Best_Move)。这对于 [PV - 节点](https://www.chessprogramming.org/Node_Types#PV) 和预期的 [Cut - 节点](https://www.chessprogramming.org/Node_Types#CUT) 尤其如此。我们的目标是接近最小树。另一方面 -- 在 Cut-nodes-- 最好的行动并不总是最便宜的反驳，例如见 [增强的转置切断](https://www.chessprogramming.org/Enhanced_Transposition_Cutoff)。**在 [迭代深化](https://www.chessprogramming.org/Iterative_Deepening) 框架内，最** 重要的是尝试将前一次 [迭代](https://www.chessprogramming.org/Iteration) 的 [主要变体](https://www.chessprogramming.org/Principal_Variation) 作为下一次迭代的最左路径，这可以通过明确的 [三角 PV 表](https://www.chessprogramming.org/Triangular_PV-Table) 或隐含的 [转置表](https://www.chessprogramming.org/Transposition_Table) 来应用。

### Typical move ordering

在 [棋步生成](https://www.chessprogramming.org/Move_Generation) 和指定的棋步分数之后，国际象棋程序通常不会对整个 [棋步列表](https://www.chessprogramming.org/Move_List) 进行排序，而是在每次取到棋步时进行 [选择排序](https://en.wikipedia.org/wiki/Selection_sort)。例外的情况是 [根](https://www.chessprogramming.org/Root) 和与地平线有一定距离的更远的 [PV - 节点](https://www.chessprogramming.org/Node_Types#PV)，在那里我们可以应用额外的努力来对棋步进行评分和排序。出于性能方面的考虑，许多程序试图在预期的 [Cut-Nodes](https://www.chessprogramming.org/Node_Types#CUT) 处保存捕获或不捕获的 [棋步生成](https://www.chessprogramming.org/Move_Generation)，而是先尝试哈希棋或杀手，如果它们在这个位置被证明是合法的。

在 Sanmill 中，这步棋利用了人类的知识，排序包括如下。

1. 可以使己方关闭更多的磨盘。

2. 可以阻止对方关闭更多的磨。

3. 尽可能让对方的落子与禁点相邻，因为禁点在移动阶段会变空。

4. 以对方的棋子和自己的棋子正好合磨。

5. 取对方的棋子和自己的棋子相邻。

6. 优先取对手的移动能力强，即相邻的空数。
   此外，还将尝试用以下方法来选择降低优先权。

7. 如果取对方的棋子和对方的三个连续邻位，尽量不取。

8. 如果对方取的棋子与自己的棋子不相邻，宁可不取。

* 如果方法的优先级相同，则考虑以下因素。

* 将棋盘上的点数分成重要的点，优先考虑高优先级的点。相邻的点越多，优先级越高。

* 如果优先级相同，根据配置，默认使用随机排序，以防止人类在同一条曲折的道路上一再获胜，提高可玩性。

磨盘棋的排序是在移动选手模块中实现的。

## Evaluation

**评价**，一个 [启发式函数](https://en.wikipedia.org/wiki/Heuristic_(computer_science)) 来确定一个 [位置](https://www.chessprogramming.org/Score) 的 [相对价值]，也就是获胜的机会。如果我们在每一行都能看到对局的结束，那么评估将只有 - 1（输）、0（平）和 1（赢）的值，而引擎应该只搜索到深度 1 以获得最佳棋步。然而，在实践中，我们不知道一个位置的确切数值，所以我们必须做一个近似值，主要目的是比较位置，引擎现在必须深入搜索，在给定的时间内找到最高分的位置。

最近，有两种主要的方法来建立评价：传统和多层 [神经网络](https://www.chessprogramming.org/Neural_Networks)。本页重点介绍传统方式，考虑到 **双方棋子数量差异的明确特征**。

初学的棋手从 [棋子](https://www.chessprogramming.org/Point_Value) 本身的 [价值](https://www.chessprogramming.org/Pieces) 开始学习这样做。计算机评估功能也使用 [物质平衡](https://www.chessprogramming.org/Material) 的价值作为最重要的方面，然后再加上其他考虑。

### 从哪儿开始

编写评估函数时首先要考虑的是如何在 [Minimax](https://www.chessprogramming.org/Minimax) 或更常见的 [NegaMax](https://www.chessprogramming.org) 中得分 /Negamax) 框架。 虽然 Minimax 通常将白方与最大玩家相关联，将黑色与最小玩家相关联，并且始终从白方的角度进行评估，但 NegaMax 需要对 [要移动的一侧] 进行不对称评估（<https://www.chessprogramming.org/Side_to_move）。> 我们可以看到，不能对移动本身进行评分，而是对移动的结果进行评分（即，对棋盘的位置评估作为移动的结果）。

### Side to move relative

为了让 [NegaMax](https://www.chessprogramming.org/Negamax) 发挥作用，返回相对于被评估方的分数很重要。 例如，考虑一个简单的评估，它只考虑 [material](https://www.chessprogramming.org/Material) 和 [mobility](https://www.chessprogramming.org/Mobility)：

```c
materialScore = 5  * (wPiece-bPiece)

mobilityScore = mobilityWt * (wMobility-bMobility) [Currently not implemented]
```

* 返回相对于 [side to move](https://www.chessprogramming.org/Side_to_move) 的分数（who2Move = +1 表示白色，-1 表示黑色）：*

```
Eval  = (materialScore + mobilityScore) * who2Move
```

位置评估在评估模块中实现。

## Transposition Table

**换位表**，首先用于 [Greenblatt 的](https://www.chessprogramming.org/Richard_Greenblatt) 程序 [Mac Hack VI](https://www.chessprogramming.org/Mac_Hack#HashTable)，是 存储先前执行的搜索结果的数据库。 这是一种大大减少 [国际象棋树](https://www.chessprogramming.org/Search_Tree) 搜索空间的方法，几乎没有负面影响。 这些程序在 [蛮力](https://www.chessprogramming.org/Brute-Force) 搜索过程中，一次又一次地遇到相同的 [位置](https://www.chessprogramming.org/Chess_Position)， 但来自不同的 [moves](https://www.chessprogramming.org/Moves) 序列，这被称为 [transposition](https://www.chessprogramming.org/Transposition)。 换位（和 [反驳](https://www.chessprogramming.org/Refutation_Table)）表是源自 [动态规划](https://www.chessprogramming.org/Dynamic_Programming) 的技术，该术语由 [Richard E . Bellman](https://www.chessprogramming.org/Richard_E._Bellman) 在 1950 年代，当编程意味着规划时，动态规划被设想为优化规划多阶段过程。

### How it works

当搜索遇到 [transposition](https://www.chessprogramming.org/Transposition) 时，“记住” 上次检查位置时确定的内容是有益的，而不是重新进行整个搜索。 出于这个原因，国际象棋程序有一个换位表，这是一个很大的 [哈希表](https://www.chessprogramming.org/Hash_Table)，存储有关先前搜索的位置、搜索深度以及我们得出的结论的信息 他们。 即使相关转置表条目的 [depth](https://www.chessprogramming.org/Depth) (draft) 不够大，或者不包含截止的右边界，[best](https ://www.chessprogramming.org/Best_Move）（或足够好）从以前的搜索移动可以改善 [移动顺序]（<https://www.chessprogramming.org/Move_Ordering），并节省搜索时间。> 在 [迭代深化](https://www.chessprogramming.org/Iterative_Deepening) 框架内尤其如此，在该框架中，人们从之前的迭代中获得了有价值的表格命中率。

### Hash functions

[哈希函数](https://en.wikipedia.org/wiki/Hash_function) 将国际象棋位置转换为几乎唯一的标量签名，允许快速索引计算以及存储位置的节省空间验证。

* [Zobrist 哈希](https://www.chessprogramming.org/Zobrist_Hashing)
* [BCH 哈希](https://www.chessprogramming.org/BCH_Hashing)

更常见的 Zobrist 哈希和 BCH 哈希都使用快速哈希函数，以提供哈希键或签名作为一种 [哥德尔数](https://en.wikipedia.org/wiki/Gödel_number) 的国际象棋位置，今天 通常 [64 位](https://www.chessprogramming.org/Quad_Word) 宽，对于 Mill，32 位就足够了。 它们在 [make](https://www.chessprogramming.org/Make_Move) 和 [unmake move](https://www.chessprogramming. org/Unmake_Move) 通过自逆 [exclusive or](https://www.chessprogramming.org/General_Setwise_Operations#ExclusiveOr) 或通过加法与减法。

### Address Calculation

索引不是基于整个哈希键，因为这通常是 64 位或 32 位数字，并且由于当前的硬件限制，没有足够大的哈希表来容纳它。 因此计算地址或索引需要签名 [modulo](https://en.wikipedia.org/wiki/Modulo_operator) 条目数，对于两个大小表的幂，哈希键的下部，由一个 'and'- 指令相应地。

### Collisions

[surjective](https://en.wikipedia.org/wiki/Surjection) 从位置到签名的映射以及更密集的索引范围意味着 **碰撞**，不同的位置共享相同的条目，对于两个不同的 原因，希望是罕见的歧义键（类型 1 错误），或经常歧义的索引（类型 2 错误）。

### What Information is Stored

通常，根据 [搜索](https://www.chessprogramming.org/Search) 确定存储以下信息：

* [Zobrist-](https://www.chessprogramming.org/Zobrist_Hashing) 或 [BCH-key](https://www.chessprogramming.org/BCH_Hashing)，在探测时查看位置是否正确
* [Best-](https://www.chessprogramming.org/Best_Move) 或 [Refutation move](https://www.chessprogramming.org/Refutation_Move) [目前未实施]
* [深度](https://www.chessprogramming.org/Depth)（草案）
* [Score](https://www.chessprogramming.org/Score)，*或者* [Integrated Bound and Value](https://www.chessprogramming.org/Integrated_Bounds_and_Values) *或者以其他方式*
* [节点类型](https://www.chessprogramming.org/Node_Types)

* [Age](https://www.chessprogramming.org/Transposition_Table#Aging) 用于确定何时覆盖游戏期间搜索先前位置的条目。

### Table Entry Types

在 [alpha-beta 搜索](https://www.chessprogramming.org/Alpha-Beta) 中，我们通常找不到位置的确切值。 但我们很高兴地知道，该值要么太低要么太高，我们不必担心进一步搜索。 当然，如果我们有确切的值，我们会将其存储在转置表中。 但是，如果我们的位置值足够高以设置下限，或者足够低以设置上限，那么也最好存储该信息。 因此，转置表中的每个条目都用 [节点类型](https://www.chessprogramming.org/Node_Types) 标识，通常称为 [精确](https://www.chessprogramming.org/Exact_Score) , [下限](https://www.chessprogramming.org/Lower_Bound)- 或 [上限](https://www.chessprogramming.org/Upper_Bound)。

### Replacement Strategies

因为换位表中的条目数量有限，并且因为在现代国际象棋程序中它们可以很快填满，所以有必要制定一个方案让程序可以决定哪些条目最有价值保留，即 置换方案。 当程序试图将一个位置存储在已经有不同条目的表槽中时，替换方案用于解决索引冲突。 替代方案有两个相反的考虑因素：

* 搜索到高深度的条目比搜索到低深度的条目在每次表格命中时节省更多的工作。
* 靠近树叶的条目更有可能被多次搜索，从而使它们的表命中率更高。 此外，最近搜索过的条目更有可能被再次搜索。
* 大多数表现良好的替代策略都综合考虑了这些因素。

### Implementation

在博弈树中，很多节点到达的路径不同，但位置相同，如果节点与博弈树处于同一层级，则得分相同。 在 Alpha-Beta 搜索期间，程序使用换位表来保存搜索到的节点位置的层次结构、分数和值类型。 在后续的博弈树查找中，首先查找转置表，如果发现对应的位置已经被记录，并且记录的对应层级与查找节点层级相同或接近叶子节点，则直接选择 换位表记录相应的分数； 否则，该位置的层次结构、分数和值类型信息将添加到转置表中。 在 Alpha-Beta 搜索过程中，博弈树的一个节点出现在以下三种情况之一：

* BOUND_UPPER
  节点得分未知但大于或等于 Beta；

* BOUND_LOWER
   节点得分未知，但小于或等于 alpha；

* BOUND_EXACT
   节点得分已知，alpha <- 节点得分 <-beta，这是精确值。

`BOUND_EXACT` 类型，可以作为当前节点的准确分数存放在转置表中，`BOUND_UPPER`、`BOUND_LOWER` 对应的边界值仍然可以帮助进一步剪枝，也可以放入转置表中，所以记录 转置表需要一个 flag 来表示值类型，即精确值，或者 case 1) 的上边界，或者 case 2) 的下边界。 查找时，检查转置表中保存的结果是否直接代表当前节点的值或使当前节点产生 alpha-Beta 剪枝，如果不是，则继续查找该节点。 为了尽快实现换位表查找，必须将换位表设计为哈希表数组 TT，数组元素 TT (key) 存储 position key 下对应的 hierarchy、score、value type。 根据某个位置的信息，快速在 Hash 表中找到对应的记录。 使用 Zobrist Hash 方法，构造一个 32 位随机数数组，`Key psq`、`PIECE_TYPE_NB` 和 `SQUARE_NB`，其中 `PieceType` 类型棋子的 32 位随机值是内侧坐标 `(x , y)`。 与棋盘上出现的所有类型棋子的随机数不同，或者通过将结果保存在 32 位可变密钥中，获得该位置的特征。 因此，当 type1 的一块从 “(x1, y1)” 移动到 “(x2, y2)” 时，只需对当前的 “BoardKey” 值执行以下操作：

1）要移动的棋子从棋盘上移除，key 为 `psq (type1) x1`，（“代表位差或运算，下同”；

2）如果目标坐标有其他类型类型的碎片，也被删除，关键是 `psq`。

3）将移动的棋子放入目标坐标，key s，psq s，type1 s x2 s y2。 异或操作都在计算机内部进行得非常快，从而加快了计算机的计算速度。

键值是相同的位置，Mill 对应的行可能不同，所以定义 a3 2 位边常量，行边转换时，键和边或。

因为一方在同一个位置当前可以拿的棋子数量不同，应该算一个不同的位置，为了解决这个问题，程序采用了用 32 位密钥的高两位存储的方法 在当前位置可以带走的孩子的数量。

前面提到的 MTD (f) 算法在搜索过程中逐渐逼近你要找的值，很多节点可能会被搜索多次。 因此，本程序使用这种基于 Hash 的转置表将搜索到的节点保存在内存中，以便再次搜索时直接取出，避免重新搜索。

## Prefetching

程序使用一个重要的性能改进来缓存靠近处理器的必要数据。 预取可以显着减少访问数据所需的时间。 大多数现代处理器具有三种类型的内存：

・一级缓存通常支持单周期访问
・二级缓存支持双周期访问
・系统内存支持更长的访问时间

为了最大限度地减少访问延迟并从而提高性能，最好将数据保存在最近的内存中。 手动执行此任务称为预抓取。 GCC 通过内置函数__builtin_prefetch 支持手动预抓取数据。

该程序在 Alpha-Beta 搜索阶段递归调用更深的搜索，通过执行关键位置手动预抓取生成的第一个方法生成器，提高了性能。

GCC 中的数据预取框架支持各种目标的功能。 GCC 中涉及预取数据的优化将相关信息传递给目标特定的预取支持，后者可以利用它或忽略它。 此处关于 GCC 目标中的数据预取支持的信息最初是作为输入来收集的，用于确定 GCC 的 “预取” RTL 模式的操作数，但可能继续对那些添加新预取优化的人有用。

## Bitboards

**Bitboards**，也称为 bitsets 或 bitmaps，或更好的 **Square Sets**，是用于表示国际象棋程序中的 [棋盘](https://www.chessprogramming.org/Chessboard) 的其他事物 **以作品为中心** 的方式。 位板本质上是 [有限集](https://en.wikipedia.org/wiki/Finite_set) 最多 [64](https://en.wikipedia.org/wiki/64_(number)) [元素](https://en.wikipedia.org/wiki/Element_(mathematics)) - [棋盘](https://www .chessprogramming.org/Chessboard），每格一 [bit](https://www.chessprogramming.org/Bit)。 其他具有更大棋盘尺寸的棋盘 [游戏](https://www.chessprogramming.org/Games) 也可以使用集合表示，但经典国际象棋的优点是一个 [64 位字](https://www.chessprogramming.org/Quad_Word）或寄存器覆盖整个棋盘。 比国际象棋更友好的是 [Checkers](https://www.chessprogramming.org/Checkers)，具有 32 位位板和更少的 [棋子类型](https://www.chessprogramming.org/Pieces#PieceTypeCoding) .

### The Board of Sets

为了 [代表棋盘](https://www.chessprogramming.org/Board_Representation)，我们通常需要为每个 [piece-type](https://www.chessprogramming.org/Pieces#PieceTypeCoding) 和 [color] (<https://www.chessprogramming.org/Color>) - 可能封装在一个类或结构中，或者作为位板的 [数组](https://www.chessprogramming.org/Array) 作为位置对象的一部分。 位板内的一位意味着在某个方块上存在这种棋子类型的棋子 - 由位位置一对一关联。

* [方形映射注意事项](https://www.chessprogramming.org/Square_Mapping_Considerations)
* [标准棋盘定义](https://www.chessprogramming.org/Bitboard_Board-Definition)

### Bitboard Basics

当然，位板不仅仅是关于片段的存在 —— 它是一种通用的、**set-wise** 数据结构，适合一个 64 位寄存器。 例如，位板可以表示攻击和防御集、移动目标集等内容。

### Bitboard-History

[bitsets](https://www.chessprogramming.org/Mikhail_R._Shura-Bura#Bitsets) 的一般方法是由 [Mikhail R. Shura-Bura](https://www.chessprogramming.org/Mikhail_R. _Shura-Bura）于 1952 年举行棋盘游戏的位板方法似乎也是在 1952 年由 [Christopher Strachey](https://www.chessprogramming.org/Christopher_Strachey) 在他的游戏中使用白色、黑色和国王位板发明的 [Ferranti Mark 1](https://www.chessprogramming.org/Ferranti_Mark_1) 的跳棋程序，以及 50 年代中期由 [Arthur Samuel](https://www.chessprogramming.org/Arthur_Samuel) 在他的跳棋程序中编写的程序 程序也是如此。 在计算机国际象棋中，位棋盘首先由 [Georgy Adelson-Velsky](https://www.chessprogramming.org/Georgy_Adelson-Velsky) 等人描述。 1967 年，1970 年重印。[Kaissa](https://www.chessprogramming.org/Kaissa) 和 [Chess](https://www.chessprogramming.org/Chess_(Program)) 中使用了位板。 [Rotated Bitboards](https://www.chessprogramming.org/Rotated_Bitboards) 由 [Robert Hyatt](https://www.chessprogramming.org/Robert_Hyatt) 和 [Peter Gillgasch](https://www.chessprogramming.org/Peter_Gillgasch) 与 [Ernst A. Heinz](https://www.chessprogramming.org/Ernst_A._Heinz) 在 90 年代是位板历史上的又一个里程碑。 [Steffan Westcott](https://www.chessprogramming.org/Steffan_Westcott) 的创新，在 32 位 [x86](https://www.chessprogramming.org/X86) 处理器上过于昂贵，应该用 [x86- 64](https://www.chessprogramming.org/X86-64) 和 [SIMD 指令](https://www.chessprogramming.org/SIMD_and_SWAR_Techniques)。 随着快速 64 位乘法的出现以及更快的 [内存](https://www.chessprogramming.org/Memory)，[Magic Bitboards](https://www.chessprogramming.org/Magic_Bitboards) 由 [Lasse Hansen](https://www.chessprogramming.org/Lasse_Hansen) 和 [Pradu Kannan](https://www.chessprogramming.org/Pradu_Kannan) 的改进已经超越了 Rotated。

### Analysis

位板的使用引发了许多关于其成本和收益的讨论。 需要考虑的要点是：

* 位板可以具有高信息密度。
* 单个填充甚至空位板的信息密度较低。
* 位板在回答诸如 x 方块上有什么棋子之类的问题时表现不佳。 在 [制作](https ://www.chessprogramming.org/Make_Move)/[unmake](https://www.chessprogramming.org/Unmake_Move)。
* 位板可以使用按位指令并行操作所有方块。 这是位板支持者使用的主要论点之一，因为它允许 [评估](https://www.chessprogramming.org/Evaluation) 具有灵活性。
* 位板在 32 位处理器上有相当大的缺陷，因为每个按位计算必须分成两条或更多条指令。 由于大多数现代处理器现在都是 64 位的，因此这一点有所减弱。
* Bitboards 通常依赖于 [bit-twiddling](https://www.chessprogramming.org/Bit-Twiddling) 以及针对某些硬件架构的各种优化技巧和特殊指令，例如 [bitscan](https://www.chessprogramming .org/BitScan) 和 [人口计数](https://www.chessprogramming.org/Population_Count)。 最佳代码需要 [C](https://www.chessprogramming.org/C)/[C++](https://www.chessprogramming.org/Cpp）。 可移植代码可能并非对所有处理器都是最佳的。
* 位板上的一些操作不太通用，f.i. 转移。 这需要额外的代码开销。

### Implementation

棋盘的表示方法是一个重要的问题，一般的方法是用一个二维数组来表示棋盘，一个位置往往用一个字节来表示，但是在一般的 Mill 类中，每个位置的状态远远少于 256. 对于许多 Mill 类，位板是节省空间和提高性能的有效方法。

简而言之，位板是使用几个位的板中的一个位。 在这个程序中，用 32 位的低 24 位来表示一个 Millboard，在多个地方用位来代替数组运算来提高性能。

# Future work

未来工作的可能性包括：

* 提示和分析。
* 机动性评估，尤其是九人莫里斯。
* 支持评估权重设置，进一步支持自我训练寻找最佳权重。
* 更多 AI 风格，例如牺牲。
* 打开数据库。
* 残局学习。
* 支持更多规则变体。
* 检查标准规则。
* 更多本地化。
* 高效可更新的神经网络
* 在线数据库。
* 其他优化。

# References

<https://www.chessprogramming.org/Minimax>

<https://www.chessprogramming.org/Alpha-Beta>

<https://en.wikipedia.org/wiki/Negamax>

<https://en.wikipedia.org/wiki/MTD-f>

<https://www.chessprogramming.org/Move_Ordering>

<https://www.chessprogramming.org/Transposition_Table>

<https://www.chessprogramming.org/Evaluation>

<https://www.chessprogramming.org/Bitboards>

<https://gcc.gnu.org/projects/prefetch.html>

<http://library.msri.org/books/Book29/files/gasser.pdf>

<https://www.ics.uci.edu/~eppstein/cgt/morris.html>

<http://muehlespiel.eu/images/pdf/WMD_Spielregeln.pdf>
