Sanmill 直棋应用程序开发白皮书
---------------------------------------------------------------------------

本文正在撰写中。请将关于它的任何意见反馈到 [Calcitem Sdudio](mailto:calcitem@outlook.com)。非常感谢您！

# 前言

本文描述了 Sanmill 直棋程序的设计，重点是核心算法设计。我们描述了一些受益于知识型方法的搜索方法的组合。

直棋是一个经典的 "两人零和、完全信息、非偶然" 的游戏。该程序使用最小搜索算法来搜索博弈树，并使用 Alpha-Beta 剪枝、MTD(f) 算法、迭代深化搜索和置换表来优化博弈树。通过对直棋游戏的研究和分析，在游戏算法上进行了大量的设计和优化。该程序已经达到了很高的智能水平。

为了提高性能，游戏算法引擎核心使用 C++ 编写，为了达到最好的可移植性，App 的 GUI 使用 Flutter 编写，平台通道用于在 Flutter UI 和游戏引擎之间传递信息。

代码总量约为 250,000 多行。游戏算法引擎是独立开发的，代码风格尽量模仿 Stockfish，只有在线程管理和 UCI 模块中借鉴了国际象棋引擎 Stockfish 的约 300 行代码。

使用 UCI 接口的目的是创建一个通用框架，其他直棋程序的开发者也可以参考使用。

# 概览

## 硬件需求

### Android 手机

1.5GHz 或更高的 CPU

1GB 或更高的内存

480x960 或更高的屏幕分辨率

Android 4.4 或更高的版本

### iOS 设备

iOS 12 以上版本。

### PC

Windows 10/11 均可支持从微软应用商店下载。单独打包运行的程序可以运行在 Windows 7 以上版本。

Qt 版已经推出。目前 GUI 存在一些 BUG，所以一般只用于算法改进后的自战，测试算法的效果。该版本支持加载完美的 AI 数据库。

## 开发环境

Android Studio 4.1.3

Visual Studio Community 2031

Flutter 3.3.x

Android SDK version 31.0

Android NDK version 21.1

## 编程语言

游戏引擎是用 C++ 编写的。Android 应用程序入口代码使用 Java 编写，iOS 入口代码使用 Objective-C 编写。

用户界面使用 Dart 编写，使用 Flutter 框架。

## 开发目的

为用户带来娱乐和放松，并推广这一经典的棋盘游戏。

## 功能

实现直棋游戏，支持人机对战、双人对战、机器对战三种模式，支持多种直棋规则变体，包括支持九子直棋、十二子直棋，支持棋盘是否有对角线，支持是否有 "飞子规则"，支持是否允许走封闭直棋等直棋规则变体。支持 UI 主要元素颜色的设置，支持难度等级的设置，AI 的下棋方式，是否播放音效，先手，支持走棋历史显示，统计数据显示。支持恢复默认设置。

在 Android 下，在程序意外崩溃的情况下，可以收集信息，经用户同意，可以调用 E-mail 客户端发送崩溃和诊断信息。其他平台则不具有此功能。

## 技术特点

该程序游戏引擎使用 MTD(f) 和 Alpha-Beta 剪枝等博弈树搜索算法来执行最佳搜索方法，通过着法排序、置换表和预取来提高性能，并通过迭代深化搜索方法来控制搜索时间。使用 Flutter 开发 UI 以提高可移植性。

# 直棋游戏

直棋，是流传于旧大陆一类两人传统棋类的总称，吃子方式是像方棋采用成型吃子，规则、棋名随各地略有不同，有最早纪录是公元一千四百年前的古罗马，通常棋盘为同心的数个正方形，并用直线或斜线将正方形方向相连面成。

直棋在中国各地流传开来，受到人们的喜爱，先后演变出 “三棋”、“成三棋”、“打三棋”、“连三”、“走城”、“龙棋”、“九子棋” 等许多变体。

游戏是在一个有 24 个点的棋盘上进行的，棋子可以放在那里。最初，棋盘是空的，两名棋手各持 9 个或 12 个棋子。拥有白色棋子的一方开始。

```text
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

* 中盘阶段

当所有的棋子都放好后，玩家将棋子滑向任何相邻的空点。

* 残局阶段

当一个棋手只剩下三个棋子时，他可以跳一个棋子到任何空点。

在开局时，玩家交替放置。开局后，他们的棋子放在任何空位上。

当所有的棋子都放置完毕后，游戏进入中盘。在这里，玩家可以将自己的一颗棋子滑到相邻的空位上。如果在游戏过程中的任何时候，玩家成功地将自己的三颗棋子排列成一排 —— 这被称为“直”（或“成三”、“连线”） —— 他可以移除任何不属于磨盘的对手的棋子。

一旦玩家只剩下三颗棋子，终局就开始了。当轮到他时，有三个棋子的棋手可以将他的一个棋子跳到棋盘上的任何空位。

游戏结束的方式有以下几种。

* 拥有少于三个棋子的棋手输了。
* 无法下出合法棋步的棋手输了。
* 如果中盘或残局的局面被重复出现，则游戏为平局。

有两点在直棋爱好者中存在争议。第一个问题是，在开局时，有可能同时出现两个“成三”。那么，是否应该允许棋手去掉对方的一个或两个棋子呢？我们的实现支持这两种情况。第二点是关于要下的棋手刚刚关闭了一个磨，但对手的所有棋子也都在磨中的情况。这时他是否可以移走一颗棋子？在我们的实现中，这一规则是可以配置的。

# 设计意图

现在有各种不同的直棋游戏。最流行的品种 —— 九子标准直棋是平局。这个结果是由 [Palph Gasser](http://library.msri.org/books/Book29/files/gasser.pdf) 使用  Alpha-Beta  搜索和终盘数据库实现的。

逆向分析法被用来计算所有中盘和残局位置的数据库（大约 100 亿个不同位置）。这些局面被分成 28 个独立的数据库，其特点是棋盘上的棋子数量，即所有 3 个白棋对 3 个黑棋的局面，4-3、4-4...... 直到 9-9 的局面。

然后对开局阶段进行 18 层的 Alpha-Beta 搜索，找出初始位置（空棋盘）的价值。只需要 9-9、9-8 和 8-8 的数据库就可以确定对局是平局。

一些实现正在使用数据库来完善无敌的人工智能，例如。

[King Of Muehle](https://play.google.com/store/apps/details?id=com.game.kingofmills)

<http://muehle.jochen-hoenicke.de/>

<https://www.mad-weasel.de/morris.html>

因为数据库非常大，通常对于游戏规则，我们需要建立一个 80GB 的数据库，这个数据库只能在 PC 上使用，或者放在服务器上，通过 App 查询。因为数据库庞大，要建立所有规则变体的数据库是不现实的，所以本程序通常只支持九子直棋的标准规则。

支持各种规则变体是这个程序的特点。另一方面，在不使用庞大的数据库的情况下，我们希望利用先进的搜索算法和人类的知识，尽可能提高智能水平，可以细分难度等级，让玩家享受等级提升的乐趣。

另外，对于 PC 的 Qt 版本，我们已经支持使用 [九子直棋游戏 —— 完美的游戏电脑](ttps://www.mad-weasel.de/morris.html) 建立的数据库。不幸的是，这不是一个标准的九子直棋规则。它在大的方面遵循规则，但在一些小的规则上存在差异，我们认为这是原作者的疏忽导致的。应该指出的是，我们目前还没有得到标准规则的详细文本。我们只是通过与其他程序的比较来验证猜测规则的标准。而支持访问这个数据库的主要目的是评估人工智能算法的能力，通过对完美人工智能的平局率来衡量算法的有效性。其他标准规则的数据库暂时还没有开放源代码和接口，所以无法连接。

在未来，我们可能会使用建立完美人工智能数据库的算法来建立我们自己的数据库，但这需要服务器的成本来存储数据库。预计我们在短期内不会有这个计划。从中期来看，更可行的方式是通过终局数据库或 [NNUE](https://en.wikipedia.org/wiki/Efficiently_updatable_neural_network) 进行训练，以较低的成本继续提高智能水平。

我们正在分享和免费分发提供 Sanmill 计划所需的代码、工具和数据。我们这样做是因为我们相信开放软件和开放数据是取得快速进展的关键因素。我们的最终目标是汇集社区的力量，使 Sanmill 成为一个强大的程序，为全世界的直棋爱好者带来乐趣，特别是在欧洲、南非、中国和其他直棋游戏广泛传播的地方。

# 模块

## 算法引擎

引擎模块负责根据指定的位置和状态信息（如谁先下）搜索最佳棋步之一，并返回到用户界面模块。 它分为以下几个子模块。

1. 位棋盘

2. 局面评估 （又称“审局”）

3. 哈希表（已进行无锁化处理）

4. 直棋游戏逻辑

5. 着法生成器

6. 着法选择器

7. 配置管理

8. 规则管理

9. 最佳着法搜索

10. 线程管理

11. 置换表

12. 通用国际象棋接口 (UCI)

13. UCI 选项管理

## UI 前端

UI 模块。通过 Flutter 开发，Flutter 具有开发效率高、Android/iOS/Windows/Linux 多端 UI 一致、UI 美观、Native 性能相当的优势。

UI 模块分为以下几个模块。

直棋逻辑模块，基本上是把直棋逻辑模块的算法引擎翻译成 Dart 语言；具体分为游戏逻辑模块、直棋行为模块、位置管理模块、移动历史模块等。

引擎通信模块：负责与 C++ 编写的游戏引擎进行交互。

命令模块：用于管理和游戏引擎交互的命令队列。

配置管理：主要是 Hive 数据库管理。

绘制模块：包括棋盘绘制和棋子绘制。

服务模块：包括音频服务。

风格模块：包括主题风格、颜色风格。

页面模块：包括棋盘页面、侧边菜单页面、游戏设置页面、主题设置页面、规则设置页面、帮助页面、关于页面、许可页面以及各种 UI 组件。

多语言数据。包括英文和中文字符串文本资源。

# 算法设计

## 极小化极大算法

程序使用 Alpha-Beta 搜索算法的变种，要了解 Alpha-Beta 算法，就需要先了解 Minimax (极小化极大算法)。

计算机科学中最有趣的事情之一就是编写一个人机博弈的程序。有大量的例子，最出名的是编写一个国际象棋的博弈机器。但不管是什么游戏，程序趋向于遵循一个被称为 Minimax 算法，伴随着各种各样的子算法在一块。

Minimax 算法又名极小化极大算法，是一种找出失败的最大可能性中的最小值的算法。Minimax 算法常用于棋类等由两方较量的游戏和程序，这类程序由两个游戏者轮流，每次执行一个步骤。我们众所周知的五子棋、象棋等都属于这类程序，所以说 Minimax 算法是基于搜索的博弈算法的基础。该算法是一种零总和算法，即一方要在可选的选项中选择将其优势最大化的选择，而另一方则选择令对手优势最小化的方法。

Minimax 是一种悲观算法，即假设对手每一步都会将我方引入从当前看理论上价值最小的局面方向，即对手具有完美决策能力。因此我方的策略应该是选择那些对方所能达到的让我方最差情况中最好的，也就是让对方在完美决策下所对我造成的损失最小。

Minimax 不找理论最优解，因为理论最优解往往依赖于对手是否足够愚蠢，Minimax 中我方完全掌握主动，如果对方每一步决策都是完美的，则我方可以达到预计的最小损失局面，如果对方没有走出完美决策，则我方可能达到比预计的最悲观情况更好的结局。总之我方就是要在最坏情况中选择最好的。

一般解决博弈类问题的自然想法是将局面组织成一棵树，树的每一个节点表示一种局面，而父子关系表示由父局面经过一步可以到达子局面。Minimax 也不例外，它通过对以当前局面为根的局面树搜索来确定下一步的选择。而一切局面树搜索算法的核心都是对每个局面价值的评价。

### 实现

下面是 Minimax 的间接 [递归](https://www.chessprogramming.org/Recursion) [深度优先搜索](https://www.chessprogramming.org/Depth-First) 的伪代码。 为简单起见，省略了递归调用前后的 [make making](https://www.chessprogramming.org/Make_Move) 和 [unmaking](https://www.chessprogramming.org/Unmake_Move)。

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

## Alpha-Beta 剪枝

Alpha-Beta 剪枝是一种搜索算法，用以减少极小化极大算法（Minimax 算法）搜索树的节点数。这是一种对抗性搜索算法，主要应用于机器游玩的二人游戏（如井字棋、象棋、围棋）。当算法评估出某策略的后续走法比之前策略的还差时，就会停止计算该策略的后续发展。该算法和极小化极大算法所得结论相同，但剪去了不影响最终决定的分枝。

### 历史

Allen Newell和Herbert A. Simon在1958年，使用了John McCarthy所谓的“近似”Alpha-Beta 算法，此算法当时“应已重新改造过多次”。亚瑟·李·塞谬尔（Arthur Samuel）有一个早期版本，同时Richards、Hart、Levine和/或Edwards在美国分别独立发现了Alpha-Beta。McCarthy在1956年达特默思会议上提出了相似理念，并在1961年建议给他的一群学生，其中包括MIT的Alan Kotok。Alexander Brudno独立发现了Alpha-Beta算法，并在1963年发布成果。Donald Knuth和Ronald W. Moore在1975年优化了算法，Judea Pearl在1982年证明了其最优性。

### 对原版极小化极大算法的改进

Alpha-Beta 的优点是减少搜索树的分枝，将搜索时间用在“更有希望”的子树上，继而提升搜索深度。该算法和极小化极大算法一样，都是分支限界类算法。若节点搜索顺序达到最优化或近似最优化（将最佳选择排在各节点首位），则同样时间内搜索深度可达极小化极大算法的两倍多。

在（平均或恒定）分枝因子为b，搜索深度为d层的情况下，要评估的最大（即着法排序最差时）叶节点数目为O(b*b*...*b) = O(bd)——即和简单极小化极大搜索一样。若着法排序最优（即始终优先搜索最佳着法），则需要评估的最大叶节点数目按层数奇偶性，分别约为O(b*1*b*1*...*b)和O(b*1*b*1*...*1)（或O(bd/2) = O(√bd)）。其中层数为偶数时，搜索因子相当于减少了其平方根，等于能以同深度搜索两次。b*1*b*1*...意义为，对第一名玩家必须搜索全部着法找到最佳招式，但对于它们，只用将第二名玩家的最佳着法截断——Alpha-Beta 确保无需考虑第二名玩家的其他着法。但因节点生成顺序随机，实际需要评估的节点平均约为O(b3d/4)。

一般在 Alpha-Beta 中，子树会由先手方优势或后手方优势暂时占据主导。若招式排序错误，这一优势会多次切换，每次让效率下降。随着层数深入，局面数量会呈指数性增长，因此排序早期招式价值很大。尽管改善任意深度的排序，都以能指数性减少总搜索局面，但排序临近根节点深度的全部局面相对经济。在实践中，着法排序常由早期、小型搜索决定，如通过迭代加深。

算法使用两个值 alpha 和 beta，分别代表大分玩家放心的最高分，以及小分玩家放心的最低分。alpha 和 beta 的初始值分别为正负无穷大，即双玩家都以可能的最低分开始游戏。在选择某节点的特定分枝后，可能发生小分玩家放心的最小分小于大分玩家放心的最大分（beta <= alpha）。这种情况下，父节点不应选择这个节点，否则父节点分数会降低，因此该分枝的其他节点没有必要继续探索。

### 伪代码

下面为一有限可靠性版本的 Alpha-Beta 剪枝的伪代码：

```js
function alphabeta(node, depth, α, β, maximizingPlayer) // node = 结点，depth = 深度，maximizingPlayer = 大分玩家
    if depth = 0 or node 是叶子结点
            return 结点的评估值
        if maximizingPlayer
            v := -∞
            for 每个子结点
                v := max(v, alphabeta(child, depth - 1, α, β, FALSE)) // child = 子结点
                α := max(α, v)
                if β ≤ α
                    break // β 裁剪
            return v
        else
            v := ∞
            for 每个子结点
                v := min(v, alphabeta(child, depth - 1, α, β, TRUE))
                β := min(β, v)
                if β ≤ α
                    break // α 裁剪
            return v

(* 初始调用 *)
alphabeta(origin, depth, -∞, +∞, TRUE) // origin = 初始结点
```

在这个有限可靠性的 Alpha-Beta 中，当 v 超出调用参数α和β构成的集合时（v < α或v > β），alphabeta 函数返回值 v。而与此相对，强化的有限可靠性 Alpha-Beta 限制函数返回在 α 与 β 包括范围中的值。

## **Negamax** 算法

负极大值搜索是极大极小值搜索的一个变体，用于搜索二人零和游戏。

这个算法简化了极大极小值搜索，原理是基于以下事实：`max(a, b) = −min(−a, −b)`。准确地说，一个着法对玩家 A 的估值，等于其对玩家 B 的估值的相反数。因此，当前玩家要搜索的是一个 使其估值的相反数最大化 的着法——其后继的着法分数必须由对方评估——这句话无论对于当前是A还是B都适用，这也意味着，同一个过程可以无论对 A 还是 B 都适用。所以，负极大值是对极大极小值算法的简化，不需要对 A 返回极大值而对 B 返回极小值。

不要和 NegaScout 算法弄混，这个算法是对于 Alpha-Beta 剪枝算法的一个巧妙应用，用于快速计算极大极小值或者负极大值，发现于 1980 年代——注意 Alpha-Beta 剪枝算法本身的目标就是通过放弃搜索无用路径，加快计算极大极小值或者负极大值。

很多的对抗性搜索算法是基于负极大值算法。

### 基本的负极大值算法

负极大值算法和极大极小值算法使用的是同样的搜索树，每一个节点包括根节点代表了双人游戏中的一个游戏状态——比如棋盘上的一种布局。节点到子节点的转移则代表了当前玩家的一种可能的着法。

负极大值搜索的目标是找到作为根节点的当前玩家的估值。下面的伪代码展示了负极大值算法的基础逻辑，所搜索的最大深度作为参数传入。

```js
function negamax(node, depth, color)
   if depth = 0 or node is a terminal node
        return color * the heuristic value of node

    bestValue := −∞
    foreach child of node
        v := −negamax(child, depth − 1, −color)
        bestValue := max( bestValue, v )
    return bestValue

// 玩家 A 的初始调用
rootNegamaxValue := negamax(rootNode, depth, 1)
rootMinimaxValue := rootNegamaxValue

// 玩家 B 的初始调用
rootNegamaxValue := negamax(rootNode, depth, -1)
rootMinimaxValue := -rootNegamaxValue
```

根节点的分数是从某一个子节点的值直接继承过来，被选中的最佳分数子节点也就代表了这一步的最佳着法。虽然这段伪代码只返回了 bestValue 作为最佳分数，但是实践中需要为根节点同时返回分数和最佳着法。在基础的负极大值算法中，根节点只有最佳分数和非根节点相关，非根节点的最佳着法不需要保存或者返回。

有一点比较容易迷惑的是当前节点的估值是如何计算的，在上面的伪代码里，这个值是始终以玩家A的角度给出，其 color 值是1——换句话说，估值高意味着局面对A更有利，这种设计是和通常的极大极小值算法一致的。估值结果不一定和节点的返回值——bestValue——保持一致，因为还要在 negamax 函数中乘以 color 参数，节点的返回值——bestValue——是从当前玩家的角度给出的估值。

负极大值的得分和极大极小值算法里当前玩家为A时的估值是一样的，即把玩家A作为极大值玩家。负极大值算法会搜索所有子节点以寻找最大值。对于玩家B层的节点，极大极小分数正好是负极大值分数的相反数，玩家B就相当于极大极小值里的极小层。

还有另外一种变体是省略 color 参数，如果省略的话，估值函数必须以当前玩家的视角返回估值（也就是估值函数必须知道当前玩家是谁，对A和对B的返回值是相反数）

### 带 Alpha-Beta 剪枝的负极大值算法

对极大极小值算法的优化也可以一样用于负极大值算法，如同在极大极小值算法中的作用一样，AlphaBeta 剪枝能减少负极大值算法所搜索的节点数。

以下伪代码展示了一个带有 AlphaBeta 剪枝的负极大值算法：

```js
function negamax(node, depth, α, β, color)
    if depth = 0 or node is a terminal node
        return color * the heuristic value of node

    childNodes := GenerateMoves(node)
    childNodes := OrderMoves(childNodes)
    bestValue := −∞
    foreach child in childNodes
        v := −negamax(child, depth − 1, −β, −α, −color)
        bestValue := max( bestValue, v )
        α := max( α, v )
        if α ≥ β
            break
    return bestValue

// 玩家 A 的初始调用
rootNegamaxValue := negamax(rootNode, depth, −∞, +∞, 1)
```

α(α) 和 β(β) 代表在给定的树深下子节点值的下限和上限。Negamax 将根节点的参数 α 和 β 设置为可能的最低和最高值。其他搜索算法，如 alpha(α) 和 beta(β) 分别代表了搜索树的某个层级中的节点估值下界和上界。负极大值算法初始设置根节点的 α 和 β 为理论最小值和理论最大值，其他的算法中——比如上面提到的 NegaScout 或者 MTD-f，可能会设置一个更精确的值以优化搜索性能。

当算法检测到一个超过 [α,β] 之外的值时，会切断这个子树——上面伪代码第12行的 **break** ——，因此就可以不搜索这一支子树。剪枝完全基于节点的返回值——bestValue。一个节点如果返回了其初始 α 和 β 范围内的值，说明返回的是准确值，这个值就作为算法要返回的值，不需要剪枝和边界限制。如果一个节点返回值超出了这个范围，那么这个值代表了节点估值的上界(如果 value ≤ α) 或者下界 (如果 value ≥ β)。AlphaBeta 剪枝最后会丢弃任何超出范围的值，因为这些值对于最终的搜索结果没有影响。

### 带 Alpha-Beta 剪枝以及置换表的负极大值算法

[置换表](https://en.wikipedia.org/wiki/Transposition_table) 有选择地 [记忆化](https://en.wikipedia.org/wiki/Memoization) 对局树中的节点的值。*转位* 是一个术语，指一个给定的棋盘位置可以通过不同的棋步序列以多种方式达到。

当 negamax 搜索对局树并多次遇到同一节点时，置换表可以返回该节点先前计算出的数值，从而跳过对该节点数值潜在的冗长和重复的计算。Negamax 的性能提高了，特别是对于有许多路径共同导致一个特定节点的博弈树。

在 negamax 中加入转置表功能的伪代码如下：α/β 剪枝。

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

```js
(* 玩家 A 的初始调用 *)
negamax (rootNode, depth, −∞, +∞, 1)
```

negamax 中的 Alpha-Beta 剪枝和最大搜索深度限制可能会导致博弈树中的部分、不精确和完全跳过的节点评估。这使得为 negamax 增加置换表优化变得复杂。在表中只跟踪节点的值是不够的，因为*值*可能不是节点的真实值。因此，代码必须保留和恢复*value* 与 alpha/beta 参数的关系以及每个转置表项的搜索深度。

转置表通常是有损的，会省略或覆盖其表中某些博弈树节点的先前值。这是必要的，因为 negamax 访问的节点数量往往远远超过转置表的大小。丢失或省略的表项是非关键性的，不会影响 negamax 的结果。然而，丢失的条目可能需要 negamax 更频繁地重新计算某些博弈树节点的值，从而影响性能。

### 实现

在 Sanmill 中，关键的实现代码如下所示:

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
> 因为直棋可能会出现一方成三后继续吃对方的棋子，而不是换成另一方的状态，所以奇数层和偶数层可能不会被严格划分为对局的两方，所以有必要在迭代过程后确定一方是否发生变化，然后决定是否取反。

## 主要变例搜索 (PVS)

在 Alpha-Beta 剪枝算法中，因为存在剪枝，搜索过程并不完整，所以剪枝算法所得到的估值不一定是准确值。通过分析可知，对于函数调用：

```js
value = alpha_beta(alpha, beta);
```

当 `alpha < value < beta` 时，此估值一定是准确值；此搜索节点就称为 PV（Principal Variation，主要变例）节点。当 `value ≤ alpha`时，此估值将不是准确值，而只是估值上限；此搜索节点就称为 alpha 节点。当 `value ≥ beta` 时，此估值也不是准确值，而只是估值下限；这一搜索节点就称为 beta 节点。

由此可看出，α-β剪枝算法重点关注的是(alpha, beta)区间，它也称为搜索窗口。相对于 alpha 节点和 beta 节点而言，程序搜索PV节点的过程是比较费时的。如果把搜索窗口的宽度减小，发生剪枝的可能性就会加大，程序搜索的时间也会短些。特别是当窗口宽度减为零，即搜索窗口为 (t-1, t) 时，这就成了零宽窗口（也称为极小窗口）。这种零宽窗口的搜索结果只有二种，要么是估值在窗口之下的 alpha 节点，要么是估值在窗口之上的 beta 节点。利用零宽窗口搜索一分为二的特点，可以很方便地判别估值的取值范围。因为零宽窗口搜索不会出现 PV 节点，这种判别过程非常高效，所以它广泛应用于各种优化的 α-β 剪枝算法中。

主要变例搜索（Principal Variation Search，简称 PVS）算法就是一种采用零宽窗口技术、针对PV节点进行优化的剪枝算法，也称为极小窗口搜索（Minimal Window Search）算法。Tony Marsland 和 Murray Campbell（1982）首先提出了PVS算法，其后Alexander Reinefeld（1983）也提出了相类似的 NegaScout 算法，并证明其正确性。

下面我们来看看 PVS 算法是怎样进行优化的。在前面所介绍的 α-β 剪枝算法中，每下完一步棋，我们总是采用以下形式进行递归搜索：

```js
value = -alpha_beta(-beta, -alpha);
```

而对于PVS算法，它首先假设之前已经找到最佳估值（其值为alpha），然后应用零宽窗口搜索，以便快速判别此假设的正确性：

```js
value = -alpha_beta(-alpha-1, -alpha);
```

如果零宽窗口搜索的结果是 `value ≤ alpha`，那么表明之前的假设是正确的，即这步棋不会有更好的估值，程序将直接舍弃这步棋。在这种情况下，由于采用了零宽窗口搜索，搜索时间将大大缩短。

但是如果零宽窗口搜索的结果表明之前的假设是错误的，那么还需要重新进行一次常规窗口的搜索。在这种情况下，PVS 算法实际上多进行了一次零宽窗口搜索。但由于零宽窗口搜索耗时相对较少，而出现前一种情况的概率一般较大，额外进行一次零宽窗口搜索所花费的代价还是值得的。PVS 算法的代码如下：

```js
int pvs(int alpha, int beta, int depth, int pass = 0){
    // 当前最佳分值，预设为负无穷大
    int best_value = -INF_VALUE;
    // 尝试每个下棋位置
    for (int pos = A1; pos <= H8; ++pos) {
        // 试着下这步棋，如果棋步合法
        if (make_move(pos)) {
            int value;
            // 如果到达预定的搜索深度，直接给出局面估值
            if (depth <= 1) value = -evaluation();
            // 如果尚未找到有效节点……
            else if (best_value == -INF_VALUE
                // ……或者零宽窗口搜索表明存在更好的结果……
                || (value = -pvs(-alpha-1, -alpha, depth-1, 0)) > alpha
                // ……且不会引发剪枝
                && (alpha = value) < beta) {
                    // 进行常规窗口搜索
                    value = -pvs(-beta, -alpha, depth-1, 0);
            }
            // 撤消棋步
            undo_move(pos);
            // 如果这步棋引发剪枝
            if (value >= beta) {
                // 立即返回当前最佳结果
                return value;
            }
            // 如果这步棋更好
            if (value > best_value) {
                // 保存更好的结果
                best_value = value;
                // 更新估值下限
                if (value > alpha) alpha = value;
            }
        }
    }
    // 如果没有合法棋步
    if (best_value == -INF_VALUE) {
        // 如果上一步棋也是跳步，表明对局结束
        if (pass) {
            // 直接给出精确比分
            best_value = get_score();
        // 否则这步棋跳步
        } else {
            make_pass();
            // 递归搜索，并标明该跳步
            best_value = -pvs(-beta, -alpha, depth, 1);
            // 撤消跳步
            undo_pass();
        }
    }
    // 返回最佳结果
    return best_value;
}
```

由于 PVS 算法的高效性是建立在已找到最佳估值的假设之上，因此在尚未找到有效节点时，只需进行常规窗口搜索。

一般来说，PVS算法的总体速度会比常规α-β剪枝算法快一些。如果将 PVS 算法与着法排序、散列表等优化技术相结合，算法的高效性将得到更充分的体现。

## MTD(f) 算法

前面已经介绍过，零宽窗口搜索（也称为极小窗口搜索）的结果只有二种，要么估值在窗口之上，要么估值在窗口之下。因此当我们对某段区间进行搜索时，可以选取区间上的一点进行零宽窗口搜索试探，利用其结果一分为二的特点，缩小估值的取值区间。在确定新的估值区间后，我们还可以再次进行试探。通过反复试探，就可以不断地缩小搜索范围，最终找到局面估值。

在选择每一次的试探值时，通常的想法是采用二分法，即每次都选择估值区间的中点进行试探。采用二分法的效率确实比较高，但是荷兰计算机科学家Aske Plaat经研究发现，在多次搜索试探过程中，局面估值往往会出现在前一次搜索的返回值附近，而机械地选取中点做为新的试探值并不是最高效的。于是他提出了一种选取前一次搜索返回值做为新试探值的MTD算法（Memory-enhanced Test Driver，缓存增强试探法）——MTD(f)。MTD(f)算法的代码如下：

```js
int mtd(int alpha, int beta, int depth, int test) {
    int best_value;
    do {
        // 进行零宽窗口试探
        best_value = alpha_beta(test-1, test, depth, 0);
        // 如果是alpha节点
        if (best_value < test) {
            // 更新估值上限，并将此做为新的试探值
            test = beta = best_value;
        // 否则是beta节点
        } else {
            // 更新估值下限
            alpha = best_value;
            // 新的试探值
            test = best_value + 1;
        }
    } while (alpha < beta);
    return best_value;
}
```

MTD(f)算法十分简捷，却又十分高效。但由于MTD(f)算法需要对同一局面多次进行搜索，因此必须采用散列表，否则无法体现其高效性，这也是MTD算法名称中缓存增强（Memory-enhanced）的含义所在。实践表明，在同样应用散列表的情况下，MTD(f)算法的搜索速度一般会比PVS算法略快些，MTD(f)算法的高效性已经得到普遍认可。

在应用MTD(f)算法时，需要一个初始试探值，一般可以简单地选取初始搜索区间的中点，当然也可以根据具体情况选择对搜索更有利的值。由于该算法必须采用散列表，散列表的性能对于整体算法的效率也是至关重要的。另外，估值的取值范围大小，也会影响MTD(f)算法的搜索速度。一般来说，估值越粗略（即取值范围较小），搜索速度会越快；这是由于试探的次数较少所致。

如果算法还涉及最佳棋步的求解，那么最佳棋步的取舍问题应引起注意。虽然MTD(f)每进行一次零宽窗口试探，都会得到一个新的最佳棋步，但对于alpha节点（best_value < test时），我们所得到的“最佳棋步”只是满足估值上限的棋步，而非真正最佳的棋步。因此，我们应丢弃这种虚假的最佳棋步，而保留上一次搜索结果。

### 相关代码

在 Sanmill 中，相关代码如下：

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
            upperbound = g;     //fail low
        } else {
            lowerbound = g;     //fail high
        }
    }

    return g;
}
```

首先，猜测最佳值。越好，算法收敛得越快。第一次调用时可以是 0。

循环的深度。可以通过多次调用 `MTDF ()` 来完成 [迭代深化深度优先搜索](https://en.wikipedia.org/wiki/Iterative_deepening_depth-first_search)，增加 `d` 并在 `f` 中提供之前的最佳结果。

### 算法性能

NegaScout 递归地调用零窗口搜索。MTD(f) 从树的根部开始调用零窗口搜索。在象棋、跳棋和黑白棋等游戏中，MTD(f) 算法的实现在实践中比其他搜索算法（如 NegaScout）更有效率（搜索更少的节点）。为了使 NegaScout 或 MTD(f) 等搜索算法有效地执行，转置表必须运作良好。否则，例如，当发生哈希碰撞时，子树将被重新扩展。当 MTD(f) 被用在有明显的奇偶效应的程序中时，即根部的得分在偶数搜索深度中较高，而在奇数搜索深度中较低，建议使用单独的 f 值来开始搜索，尽可能接近最小值。否则，搜索将需要更多的迭代来收敛于最小值，特别是对于细粒度的评价函数。

零窗口搜索比宽窗口搜索更快达到截止点。因此，它们比宽窗口搜索更有效率，但在某种意义上，也更不容易被原谅。因为 MTD（f）只使用零窗口搜索，而 Alpha-Beta 和 NegaScout 也使用宽窗口搜索，所以 MTD（f）更有效率。然而，较宽的搜索窗口对于具有较大的奇数 / 偶数波动和细粒度评估功能的引擎来说是比较宽容的。由于这个原因，一些国际象棋引擎还没有改用 MTD(f)。在对 Chinook（跳棋）、Phoenix（国际象棋）和 Keyano（黑白棋）等锦标赛质量的程序的测试中，MTD（f）算法的表现超过了所有其他搜索算法。

最近的算法，如最佳节点搜索，被建议超过 MTD(f)。

## 迭代加深搜索

一般来说，程序搜索得越深，程序的棋力就越强。如果搜索深度足于算到终盘，就能得到真正的最佳棋步和精确比分。但是随着搜索深度的增加，搜索所花费的时间也将急剧上升。而在现实下棋或比赛中，时间往往是有限的。比如在常规黑白棋比赛中，一般限定每一方的总用时为20分钟。由于受到时间的制约，程序的搜索深度无法事先确定，而需要在下棋过程中动态地进行调整。为此，程序在下每步棋时，可以根据己方剩余时间的多少，合理分配当前这步棋的思考时间。但由于程序软硬件环境的不同和局面的不断变化，搜索深度和搜索时间之间没有一成不变的关系，搜索深度仍然无法确定。前面所介绍的固定深度的搜索已无法适用，这时可以采用迭代加深搜索（Iterative Deepening Search）。迭代加深搜索的代码如下：

```js
    // 如果进一步搜索的深度未超过剩余空位数
    while (++depth <= n_empty) {
        // 进一步搜索
        value = alpha_beta(-INF_VALUE, INF_VALUE, depth);
        // 如果超时
        if (TIME_OUT) break;
    }
```

为了保存所搜索到的最佳棋步结果，引入了全局变量 result。

```js
// 无穷大分值
#define INF_VALUE 10000
// 初始搜索深度
#define MIN_DEPTH 4
// 测试是否超时
#define TIME_OUT (stop_clock && clock() >= stop_clock)
// 最佳棋步结果
static int result;
// 搜索终止时刻
static int stop_clock;

int alpha_beta(int alpha, int beta, int depth, int pass = 0){
    // 当前最佳棋步
    int best_move = PASS;
    // 当前最佳分值，预设为负无穷大
    int best_value = -INF_VALUE;
    // 尝试每个下棋位置
    for (int pos = A1; pos <= H8; ++pos) {
        // 试着下这步棋，如果棋步合法
        if (make_move(pos)) {
            int value;
            // 如果到达预定的搜索深度，直接给出局面估值
            if (dept <= 1) value = -evaluation();
            // 否则，对所形成的局面进行递归搜索
            else value = -alpha_beta(-beta, -alpha, depth - 1);
            // 撤消棋步
            undo_move(pos);
            // 如果超时
            if (TIME_OUT) return -INF_VALUE;
            // 如果这步棋引发剪枝
            if (value >= beta) {
                // 立即返回当前最佳结果
                result = pos;
                return value;
            }
            // 如果这步棋更好
            if (value > best_value) {
                // 保存更好的结果
                best_move = pos;
                best_value = value;
                // 更新估值下限
                if (value > alpha) alpha = value;
            }
        }
    }
    // 如果没有合法棋步
    if (best_value == -INF_VALUE) {
        // 如果上一步棋也是跳步，表明对局结束
        if (pass) {
            // 直接给出精确比分
            best_value = get_score();
        // 否则这步棋跳步
        } else {
            make_pass();
            // 递归搜索，并标明该跳步
            best_value = -alpha_beta(-beta, -alpha, depth, 1);
            // 撤消跳步
            undo_pass();
        }
    }
    // 返回最佳结果
    result = best_move;
    return best_value;
}

int ids(int time_remain){
    // 开始时刻
    int start_clock = clock();
    // 初始搜索深度
    int depth = MIN_DEPTH;
    // 初始搜索不限时，以确保得到一个正确的棋步
    stop_clock = 0;
    // 进行搜索深度
    int best_value = alpha_beta(-INF_VALUE, INF_VALUE, depth);
    int best_move = result;
    // 如果进一增加搜索深度步搜索的深度未超过剩余空位数
    while (++depth <= n_empty) {
        // 根据已进行的搜索情况重新调整搜索终止时刻
        stop_clock = start_clock + (clock_t)(time_remain * (CLOCKS_PER_SEC / 1000.) - (clock() - start_clock)) / ((n_empty - depth + 2) / 2);
        // 进行常规的剪枝算法
        int value = alpha_beta(-INF_VALUE, INF_VALUE, depth);
        // 如果超时
        if (TIME_OUT) break;
        // 更新最佳结果
        best_move = result;
        best_value = value;
    }
    // 返回最佳结果
    result = best_move;
    return best_value;
}
```

迭代加深搜索的思路十分简单，先从很浅的搜索深度（比如初始搜索深度为1）开始进行搜索，然后逐渐加深搜索深度进行下一轮搜索，直至时间用完为止。这样就可以做到有多少时间，就搜索多少深度。当然，上面这段代码只是个示意，在实际应用中，alpha_beta()内部也应进行超时判断。如果在某一深度的搜索过程中时间用完，搜索应立即中止，以免因等待本轮搜索结束而造成时间耗尽。

你也许会注意到，只有最后一轮搜索才是真正需要的，在这之前的搜索似乎都是在浪费时间。事实上，程序的搜索深度每增加一层，搜索时间往往成倍增长。程序大部分的时间将花在最后一轮搜索上，之前的搜索时间基本可以忽略。而且，迭代加深搜索还可以与散列表结合使用，这样较浅度搜索的结果将保存在散列表中，可对更深度搜索起一定的指导作用。如果采用MTD(f)算法，前一次搜索的结果还可以做为更深一层搜索的初始试探值：

```js
int deepening() {
    int value = 0;
    // 初始搜索深度
    int depth = 1;
    do {
        // 进行常规的MTD(f)算法
        value = mtd(value, depth);
        // 增加搜索深度
        depth++;
    // 直到时间用完
    } while (!time_out) ;
    return value;
}
```

实践表明，迭代加深搜索所花费的时间只比固定深度的搜索略微多一点；更重要的是，这种算法可以适用于信赖时间进行搜索的场合。

在对每步棋思考时间的分配上，也有不少文章可做。例如前面所提到的，当某一深度的搜索在进行中发生超时，这一轮搜索将强行中止。由于搜索过程不完整，其结果往往需丢弃，这就难免会造成一定的浪费。一个解决此问题的思路是，虽然每一轮搜索所需的时间无法预先确定，但搜索过程还是有一定规律可循的。根据前几轮搜索的情况，可以大致预测出本轮搜索的时间。如果预测表明，剩余时间已经不足于完成本轮的搜索，那么就不再继续进行本轮搜索，而把剩余的时间留给下一步棋。

> **注意**
>
> 有一种理论认为，从小的枚举深度到大的枚举深度，对博弈树进行完全搜索，通过浅层搜索得到节点的一般排序，作为深层遍历的启发式信息，这样可以增强 Alpha-Beta 剪枝的效果。 但是，由于下面提到的直棋着法排序对加速 Alpha-Beta 剪枝的效果已经非常明显，所以这种方法效果不大，所以该方案没有使用。

## 着法排序

为了使 [ Alpha-Beta ](https://www.chessprogramming.org/Alpha-Beta) 算法表现良好，需要首先搜索 [最佳着法](https://www.chessprogramming.org/Best_Move)。这对于 [PV - 节点](https://www.chessprogramming.org/Node_Types#PV) 和预期的 [Cut - 节点](https://www.chessprogramming.org/Node_Types#CUT) 尤其如此。我们的目标是接近最小树。另一方面 -- 在 Cut-nodes-- 最好的行动并不总是最便宜的反驳，例如见 [增强的转置切断](https://www.chessprogramming.org/Enhanced_Transposition_Cutoff)。**在 [迭代深化](https://www.chessprogramming.org/Iterative_Deepening) 框架内，最** 重要的是尝试将前一次 [迭代](https://www.chessprogramming.org/Iteration) 的 [主要变体](https://www.chessprogramming.org/Principal_Variation) 作为下一次迭代的最左路径，这可以通过明确的 [三角 PV 表](https://www.chessprogramming.org/Triangular_PV-Table) 或隐含的 [转置表](https://www.chessprogramming.org/Transposition_Table) 来应用。

### 典型的着法排序

在 [棋步生成](https://www.chessprogramming.org/Move_Generation) 和指定的棋步分数之后，国际象棋程序通常不会对整个 [棋步列表](https://www.chessprogramming.org/Move_List) 进行排序，而是在每次取到棋步时进行 [选择排序](https://en.wikipedia.org/wiki/Selection_sort)。例外的情况是 [根](https://www.chessprogramming.org/Root) 和与地平线有一定距离的更远的 [PV - 节点](https://www.chessprogramming.org/Node_Types#PV)，在那里我们可以应用额外的努力来对棋步进行评分和排序。出于性能方面的考虑，许多程序试图在预期的 [Cut-Nodes](https://www.chessprogramming.org/Node_Types#CUT) 处保存捕获或不捕获的 [棋步生成](https://www.chessprogramming.org/Move_Generation)，而是先尝试哈希棋或杀手，如果它们在这个位置被证明是合法的。

在 Sanmill 中，这步棋利用了人类的知识，排序包括如下。

1. 可以使己方成更多的三。

2. 可以阻止对方成更多的三。

3. 尽可能让对方的落子与禁点相邻，因为禁点在移动阶段会变空。

4. 以对方的棋子和自己的棋子正好连线。

5. 吃掉对方和自己的棋子相邻的棋子。

6. 优先吃掉对手的移动能力强，即相邻的空点多的棋子。

7. 如果吃掉对方的棋子和对方的三个连续邻位，尽量不吃。

8. 如果对方吃的棋子与自己的棋子不相邻，宁可不吃。

如果着法的优先级相同，则考虑以下因素：

* 将棋盘上的点数分成重要的点，优先考虑高优先级的点。相邻的点越多，优先级越高。

* 如果优先级相同，根据配置，默认使用随机排序，以防止人类在同一条曲折的道路上一再获胜，提高可玩性。

直棋的排序是在着法选择模块中实现的。

## 局面评估

**评价**，一个 [启发式函数](https://en.wikipedia.org/wiki/Heuristic_(computer_science)) 来确定一个 [位置](https://www.chessprogramming.org/Score) 的 [相对价值]，也就是获胜的机会。如果我们在每一行都能看到对局的结束，那么评估将只有 - 1（输）、0（平）和 1（赢）的值，而引擎应该只搜索到深度 1 以获得最佳棋步。然而，在实践中，我们不知道一个位置的确切数值，所以我们必须做一个近似值，主要目的是比较位置，引擎现在必须深入搜索，在给定的时间内找到最高分的位置。

最近，有两种主要的方法来建立评价：传统和多层 [神经网络](https://www.chessprogramming.org/Neural_Networks)。后者正在开发中，本页先重点介绍传统方式，考虑到 **双方棋子数量差异的明确特征**。

初学的棋手从 [棋子](https://www.chessprogramming.org/Point_Value) 本身的 [价值](https://www.chessprogramming.org/Pieces) 开始学习这样做。计算机评估功能也使用 [物质平衡](https://www.chessprogramming.org/Material) 的价值作为最重要的方面，然后再加上其他考虑。

### 从哪儿开始

编写评估函数时首先要考虑的是如何在 [Minimax](https://www.chessprogramming.org/Minimax) 或更常见的 [NegaMax](https://www.chessprogramming.org) 中得分 /Negamax) 框架。 虽然 Minimax 通常将白方与最大玩家相关联，将黑色与最小玩家相关联，并且始终从白方的角度进行评估，但 NegaMax 需要对 [要移动的一侧] 进行不对称评估（<https://www.chessprogramming.org/Side_to_move）。> 我们可以看到，不能对移动本身进行评分，而是对移动的结果进行评分（即，对棋盘的位置评估作为移动的结果）。

### 评估函数

为了让 [NegaMax](https://www.chessprogramming.org/Negamax) 发挥作用，返回相对于被评估方的分数很重要。 例如，考虑一个简单的评估，它只考虑 [material](https://www.chessprogramming.org/Material) 和 [mobility](https://www.chessprogramming.org/Mobility)：

```c
materialScore = 5  * (wPiece-bPiece)

mobilityScore = mobilityWt * (wMobility-bMobility)
```

* 返回相对于 [side to move](https://www.chessprogramming.org/Side_to_move) 的分数（who2Move = +1 表示白色，-1 表示黑色）：*

```
Eval  = (materialScore + mobilityScore) * who2Move
```

位置评估在评估模块中实现。

## 置换表

许多博弈树搜索算法不是靠一次搜索完成的，如渴望搜索。当再次搜索同一个博弈树时，如果能把以前搜索的信息加以利用，无疑将提高搜索效率，保存以前搜索信息主要使用置换表。

置换表（Translation Table，TT）的原理是采用哈希表技术将已搜索的结点的局面特征、估值和其他相关信息记录下来，如果待搜索的结点的局面特征在哈希表中已经有记录，在满足相关条件时，就可以直接利用置换表中的结果。

对一个结点进行估值时，应先查找置换表，置换表命中失败，再对该结点进行搜索。置换表在使用时要及时更新，当计算出一个结点的估值时，应立即将这个结点的相关信息保存到置换表。为了加快处理速度，一般不采用再散列技术，一旦在写入置换表的时候发生冲突，直接覆盖相关的数据项，只要保证在读取操作时避免读取到错误数据即可，因此置换表的设计应使得发生冲突的概率很小。

置换表一般容量很大，以尽量保存庞大的博弈树各结点信息，并且应实现快速访问，因此多用哈希表技术来具体实现。与一般哈希表不同的是，这里的哈希表一般不使用再散列技术，在哈希冲突很少时，不去进行再散列，能有效加快处理速度，如果出现写冲突，直接覆盖，只要在读访问时不使用错误数据即可。

置换表中的一个数据项应包含详细信息说明对应博弈树的何种结点，该结点的搜索评估值，以及评估值对应的搜索深度等。其中评估值一般还可以分成两部分，分别保存该结点的上限值和下限值，比如渴望搜索和空窗探测等，多数时候是得到一个结点的上限值或下限值就剪枝返回，这种值同样有利用价值。如果得到了某结点的准确评估值，可以将上限值和下限值保存成一样来表示。置换表在使用时一般要及时更新。置换表技术在当今机器博弈领域已经是广为使用的技术，对搜索速度有明显的提高。机器博弈中的博弈树往往是非常庞大的，Alpha-Beta 搜索由于一般情况下是边生成结点边搜索，并不需要保存整个博弈树，内存开销并不大。如果置换表用来保存博弈树已经搜索过的全部结点信息，内存开销将是巨大的。从剪枝效率的角度考虑，由于博弈树顶层的剪枝对剪枝效率具有决定性的影响，因此，即使置换表只保存较顶层的博弈树结点信息，仍然能够明显地提高剪枝效率。

对于置换表的使用，还有一种情况需要特别指出，博弈树最末层结点在很多情况下保存到置换表中，并没有作用，这一点容易被很多人所忽视，导致置换表使用上的浪费，也降低了搜索速度。置换表不仅仅是提高重复搜索的效率，还能有效地解决博弈图的搜索。

### 算法流程

首先，确定哈希函数，将结点对应局面映射为一个哈希值，这个哈希值通常为一个 32 位的整数，根据这个值计算出哈希地址。一种快速而简单的方法就是将这个哈希值对置换表的长度取余数，作为待访问的哈希表元素的地址。

其次，哈希函数可能产生地址冲突，即不同的哈希值映射到了同一地址，上述 32 位的哈希值是不安全的。置换表中的数据项，还应必须包含一个唯一标识局面特征的校验值，这个校验值通常是一个 64 位的整数，从理论上来说，64 位整数也有可能发生冲突，但这个概率极小，在实际中可以忽略不计。使用哈希函数通过哈希值找到置换表数据项的地址之后，再验证该数据项的校验值和待搜索结点对应的局面的特征值是否一致，只有二者一致，才认为查找命中。

再次，对于 PV 结点、All 结点和 Cut 结点，后两种情况并非对应结点的精确估值。因此置换表置换表中的数据项，不仅要记录对应结点的估值结果，还应同时记录这个估值的类型，究竟是一个精确值，还是一个上界值或者下界值。

最后，结点的估值结果与搜索深度有关，搜索深度越深，估值越准确。故置换表中的数据项，还应记录结点对应的搜索深度。如果下次搜索到的局面 A，在置换表中找到了同样的局面 A'，如果 A 对应的搜索深度为Depth，置换表中 A'对应的搜索深度为 Depth'，显然只有当 Depth' ≥ Depth 时，才能直接使用置换表中 A'的估值信息，但如果 Depth > Depth'，则置换表中对应结点的估值信息就没有意义了，因为需要再向前搜索几步才能得到一个更准确的值。

因此，置换表中的一个数据项至少应包含如下数据：结点局面的 64 位校验值、搜索深度、估值以及估值的类型。

### Zobrist 哈希方法

一种高效的生成一个特定局面下的 32 位哈希值和 64 位校验值方法就是 Zobrist 哈希方法：创建一个 64 位数组 `Z[type][pos]`，其值为 type 类型的棋子在棋盘坐标 pos 的一个 64 位随机整数。对棋盘上存在的所有的棋子的随机数求异或，结果保存在 64 位变量 BoardKey 内，就得到了该局面的一个校验值。这样，类型为 type1 的棋子从 pos1 移动到 pos2 时，只要将当前的 BoardKey 值作如下操作：

（1）将要移动的棋子从棋盘上去除，`BoardKey = BoardKey ^ Z[type1][pos1]`，(“^”表示按位异或运算，下同)；
（2）如果目的位置有对方类型为 type2 的棋子被吃掉，也将其去除，`BoardKey= BoardKey ^ Z[type2][pos2]`；
（3）将移动后的棋子置入目的坐标，`BoardKey = BoardKey ^ Z[type1][pos2]`。

使用 Zobrist 哈希方法构造一个局面下的 32 位哈希值的方法与构造 64 位校验值的方法是一样的，只需将 64 位的整型变量改为 32 位即可。Zobrist 哈希方法使结点哈希值的产生可以随着着法的执行或撤销逐步进行。

置换表的长度（所包含的数据项数量）也是需要考虑的因素。置换表越长，发生地址冲突的概率越小，从而能保存更多的局面信息，置换表命中率越高，算法性能越好。在国际象棋计算机博弈中，置换表的长度每增加 1 倍，命中率约提高 7%。但置换表的长度也并非越大越好，一旦置换表的长度超过物理内存的承受能力，导致使用了硬盘中的虚拟内存，性能反而下降的很快。

置换表数据的更新有两种策略，即深度优先和随时替换。深度优先策略不比较校验值，写入置换表的数据对应的搜索深度大于置换表相应数据项的深度，才能替换原有数据；始终替换策略注重实时性，对新估值的局面信息不作任何判断，立即更新置换表中对应的数据项。

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

在 [Alpha-Beta 搜索](https://www.chessprogramming.org/Alpha-Beta) 中，我们通常找不到位置的确切值。 但我们很高兴地知道，该值要么太低要么太高，我们不必担心进一步搜索。 当然，如果我们有确切的值，我们会将其存储在转置表中。 但是，如果我们的位置值足够高以设置下限，或者足够低以设置上限，那么也最好存储该信息。 因此，转置表中的每个条目都用 [节点类型](https://www.chessprogramming.org/Node_Types) 标识，通常称为 [精确](https://www.chessprogramming.org/Exact_Score) , [下限](https://www.chessprogramming.org/Lower_Bound)- 或 [上限](https://www.chessprogramming.org/Upper_Bound)。

### 替换策略

由于几步以前搜索的结果对本步搜索来说依然具有一定的可信度，因此不必在每次搜索之前都清空置换表，而是保持这些数据作为以后搜索的信息!但数据的可信程度随着棋局的演变不断降低，而置换表的容量是有限的，相对于几近无穷的棋局，当出现重复局面时，需要确定究竟哪些局面该存入置换表中。目前对于单置换表策略，主要有深度优先和随时替换两种。

**深度优先**

该策略的基本思想：置换表中原有数据距离叶子节点越远，即深度越深，说明置换表的可信程度越高。在写入哈希表时，如果置换表中已经有了该存储项，且写入数据的搜索深度大于哈希表内已存储数据的深度，则替换掉原有数据；否则说明可信度不高，不进行任何操作。读出时也做相同处理，只有存储数据的深度大于当前搜索深度时，数据才是可信的!由于该策略着重于原有数据的利用，导致了一些最新的信息因为搜索深度的问题而无法保留。

**随时替换**

该策略的基本思想：置换表中原有数据一般都只有较小的搜索子树，并且原有的搜索深度一般小于后来产生的搜索深度，因而用新产生的棋局信息不做任何判断立即更换置换表中原有数据。该策略具有很好的实时性，但却导致了表中具有较高深度的数据大量丢失。

在 Sanmill 中，使用的是深度优先替换策略。

### 实现

在博弈树中，很多节点到达的路径不同，但位置相同，如果节点与博弈树处于同一层级，则得分相同。 在 Alpha-Beta 搜索期间，程序使用置换表来保存搜索到的节点位置的层次结构、分数和值类型。 在后续的博弈树查找中，首先查找转置表，如果发现对应的位置已经被记录，并且记录的对应层级与查找节点层级相同或接近叶子节点，则直接选择 置换表记录相应的分数； 否则，该位置的层次结构、分数和值类型信息将添加到转置表中。 在 Alpha-Beta 搜索过程中，博弈树的一个节点出现在以下三种情况之一：

* BOUND_UPPER
  节点得分未知但大于或等于 Beta；

* BOUND_LOWER
   节点得分未知，但小于或等于 alpha；

* BOUND_EXACT
   节点得分已知，alpha <- 节点得分 <-beta，这是精确值。

`BOUND_EXACT` 类型，可以作为当前节点的准确分数存放在转置表中，`BOUND_UPPER`、`BOUND_LOWER` 对应的边界值仍然可以帮助进一步剪枝，也可以放入转置表中，所以记录 转置表需要一个 flag 来表示值类型，即精确值，或者 case 1) 的上边界，或者 case 2) 的下边界。 查找时，检查转置表中保存的结果是否直接代表当前节点的值或使当前节点产生 alpha-Beta 剪枝，如果不是，则继续查找该节点。 为了尽快实现置换表查找，必须将置换表设计为哈希表数组 TT，数组元素 TT (key) 存储 position key 下对应的 hierarchy、score、value type。 根据某个位置的信息，快速在 Hash 表中找到对应的记录。 使用 Zobrist Hash 方法，构造一个 32 位随机数数组，`Key psq`、`PIECE_TYPE_NB` 和 `SQUARE_NB`，其中 `PieceType` 类型棋子的 32 位随机值是内侧坐标 `(x , y)`。 与棋盘上出现的所有类型棋子的随机数不同，或者通过将结果保存在 32 位可变密钥中，获得该位置的特征。 因此，当 type1 的一块从 “(x1, y1)” 移动到 “(x2, y2)” 时，只需对当前的 “BoardKey” 值执行以下操作：

1）要移动的棋子从棋盘上移除，key 为 `psq (type1) x1`，（“代表位差或运算，下同”；

2）如果目标坐标有其他类型类型的碎片，也被删除，关键是 `psq`。

3）将移动的棋子放入目标坐标，key s，psq s，type1 s x2 s y2。 异或操作都在计算机内部进行得非常快，从而加快了计算机的计算速度。

键值是相同的位置，直棋对应的行可能不同，所以定义 a3 2 位边常量，行边转换时，键和边或。

因为一方在同一个位置当前可以拿的棋子数量不同，应该算一个不同的位置，为了解决这个问题，程序采用了用 32 位密钥的高两位存储的方法 在当前位置可以带走的孩子的数量。

前面提到的 MTD(f) 算法在搜索过程中逐渐逼近你要找的值，很多节点可能会被搜索多次。 因此，本程序使用这种基于 Hash 的转置表将搜索到的节点保存在内存中，以便再次搜索时直接取出，避免重新搜索。

## 预取

程序使用一个重要的性能改进来缓存靠近处理器的必要数据。 预取可以显着减少访问数据所需的时间。 大多数现代处理器具有三种类型的内存：

* 一级缓存通常支持单周期访问
* 二级缓存支持双周期访问
* 系统内存支持更长的访问时间

为了最大限度地减少访问延迟并从而提高性能，最好将数据保存在最近的内存中。 手动执行此任务称为预抓取。 GCC 通过内置函数`__builtin_prefetch` 支持手动预抓取数据。

该程序在 Alpha-Beta 搜索阶段递归调用更深的搜索，通过执行关键位置手动预抓取生成的第一个方法生成器，提高了性能。

GCC 中的数据预取框架支持各种目标的功能。 GCC 中涉及预取数据的优化将相关信息传递给目标特定的预取支持，后者可以利用它或忽略它。 此处关于 GCC 目标中的数据预取支持的信息最初是作为输入来收集的，用于确定 GCC 的 “预取” RTL 模式的操作数，但可能继续对那些添加新预取优化的人有用。

## 位棋盘

**Bitboards**，也称为 bitsets 或 bitmaps，或更好的 **Square Sets**，是用于表示国际象棋程序中的 [棋盘](https://www.chessprogramming.org/Chessboard) 的其他事物 **以作品为中心** 的方式。 位棋盘本质上是 [有限集](https://en.wikipedia.org/wiki/Finite_set) 最多 [64](https://en.wikipedia.org/wiki/64_(number)) [元素](https://en.wikipedia.org/wiki/Element_(mathematics)) - [棋盘](https://www.chessprogramming.org/Chessboard)，每格一 [bit](https://www.chessprogramming.org/Bit)。 其他具有更大棋盘尺寸的棋盘 [游戏](https://www.chessprogramming.org/Games) 也可以使用集合表示，但经典国际象棋的优点是一个 [64 位字](https://www.chessprogramming.org/Quad_Word) 或寄存器覆盖整个棋盘。 比国际象棋更友好的是 [Checkers](https://www.chessprogramming.org/Checkers)，具有 32 位位棋盘和更少的 [棋子类型](https://www.chessprogramming.org/Pieces#PieceTypeCoding) .

### 位棋盘数组

为了 [代表棋盘](https://www.chessprogramming.org/Board_Representation)，我们通常需要为每个 [piece-type](https://www.chessprogramming.org/Pieces#PieceTypeCoding) 和 [color](https://www.chessprogramming.org/Color) - 可能封装在一个类或结构中，或者作为位棋盘的 [数组](https://www.chessprogramming.org/Array) 作为位置对象的一部分。 位棋盘内的一位意味着在某个方块上存在这种棋子类型的棋子 - 由位位置一对一关联。

* [方形映射注意事项](https://www.chessprogramming.org/Square_Mapping_Considerations)
* [标准棋盘定义](https://www.chessprogramming.org/Bitboard_Board-Definition)

### 位棋盘基础

当然，位棋盘不仅仅是关于片段的存在 —— 它是一种通用的、**set-wise** 数据结构，适合一个 64 位寄存器。 例如，位棋盘可以表示攻击和防御集、移动目标集等内容。

### 位棋盘的历史

[bitsets](https://www.chessprogramming.org/Mikhail_R._Shura-Bura#Bitsets) 的一般方法是由 [Mikhail R. Shura-Bura](https://www.chessprogramming.org/Mikhail_R._Shura-Bura) 于 1952 年举行棋盘游戏的位棋盘方法似乎也是在 1952 年由 [Christopher Strachey](https://www.chessprogramming.org/Christopher_Strachey) 在他的游戏中使用白色、黑色和国王位棋盘发明的 [Ferranti Mark 1](https://www.chessprogramming.org/Ferranti_Mark_1) 的跳棋程序，以及 50 年代中期由 [Arthur Samuel](https://www.chessprogramming.org/Arthur_Samuel) 在他的跳棋程序中编写的程序 程序也是如此。 在计算机国际象棋中，位棋盘首先由 [Georgy Adelson-Velsky](https://www.chessprogramming.org/Georgy_Adelson-Velsky) 等人描述。 1967 年，1970 年重印。[Kaissa](https://www.chessprogramming.org/Kaissa) 和 [Chess](https://www.chessprogramming.org/Chess_(Program)) 中使用了位棋盘。 [Rotated Bitboards](https://www.chessprogramming.org/Rotated_Bitboards) 由 [Robert Hyatt](https://www.chessprogramming.org/Robert_Hyatt) 和 [Peter Gillgasch](https://www.chessprogramming.org/Peter_Gillgasch) 与 [Ernst A. Heinz](https://www.chessprogramming.org/Ernst_A._Heinz) 在 90 年代是位棋盘历史上的又一个里程碑。 [Steffan Westcott](https://www.chessprogramming.org/Steffan_Westcott) 的创新，在 32 位 [x86](https://www.chessprogramming.org/X86) 处理器上过于昂贵，应该用 [x86- 64](https://www.chessprogramming.org/X86-64) 和 [SIMD 指令](https://www.chessprogramming.org/SIMD_and_SWAR_Techniques)。 随着快速 64 位乘法的出现以及更快的 [内存](https://www.chessprogramming.org/Memory)，[Magic Bitboards](https://www.chessprogramming.org/Magic_Bitboards) 由 [Lasse Hansen](https://www.chessprogramming.org/Lasse_Hansen) 和 [Pradu Kannan](https://www.chessprogramming.org/Pradu_Kannan) 的改进已经超越了 Rotated。

### 分析

位棋盘的使用引发了许多关于其成本和收益的讨论。 需要考虑的要点是：

* 位棋盘可以具有高信息密度。
* 单个填充甚至空位棋盘的信息密度较低。
* 位棋盘在回答诸如 x 方块上有什么棋子之类的问题时表现不佳。 在 [制作](https://www.chessprogramming.org/Make_Move)/[unmake](https://www.chessprogramming.org/Unmake_Move)。
* 位棋盘可以使用按位指令并行操作所有方块。 这是位棋盘支持者使用的主要论点之一，因为它允许 [评估](https://www.chessprogramming.org/Evaluation) 具有灵活性。
* 位棋盘在 32 位处理器上有相当大的缺陷，因为每个按位计算必须分成两条或更多条指令。 由于大多数现代处理器现在都是 64 位的，因此这一点有所减弱。
* Bitboards 通常依赖于 [bit-twiddling](https://www.chessprogramming.org/Bit-Twiddling) 以及针对某些硬件架构的各种优化技巧和特殊指令，例如 [bitscan](https://www.chessprogramming .org/BitScan) 和 [人口计数](https://www.chessprogramming.org/Population_Count)。 最佳代码需要 [C](https://www.chessprogramming.org/C)/[C++](https://www.chessprogramming.org/Cpp）。 可移植代码可能并非对所有处理器都是最佳的。
* 位棋盘上的一些操作不太通用，f.i. 转移。 这需要额外的代码开销。

### 实现

棋盘的表示方法是一个重要的问题，一般的方法是用一个二维数组来表示棋盘，一个位置往往用一个字节来表示，但是在一般的 直棋 类中，每个位置的状态远远少于 256. 对于许多 直棋 类，位棋盘是节省空间和提高性能的有效方法。

简而言之，位棋盘是使用几个位的板中的一个位。 在这个程序中，用 32 位的低 24 位来表示一个直棋的位棋盘，在多个地方用位来代替数组运算来提高性能。

# 未来的工作

未来工作的可能性包括：

* 提示和分析。
* 使用机器学习的方式调整局面评估函数的权重。
* 更多 AI 风格。
* 打开数据库。
* 残局学习。
* 支持更多规则变体。
* 支持 NNUE 神经网络
* 在线数据库。
* 其他优化。

# 参考

<https://blog.csdn.net/zkybeck_ck/article/details/45644471>

<https://www.chessprogramming.org/Minimax>

<https://zh.wikipedia.org/wiki/%E6%9E%81%E5%B0%8F%E5%8C%96%E6%9E%81%E5%A4%A7%E7%AE%97%E6%B3%95>

<https://www.chessprogramming.org/Alpha-Beta>

<https://zh.m.wikipedia.org/zh-hans/Alpha-beta%E5%89%AA%E6%9E%9D>

<https://en.wikipedia.org/wiki/Negamax>

<https://flyingsnow-hu.github.io/brokenslips/ai/2017/04/24/negamax.html>

<http://soongsky.com/othello/computer/pvs.php#zero_wnd>

<https://en.wikipedia.org/wiki/MTD-f>

<http://soongsky.com/othello/computer/mtdf.php>

<http://soongsky.com/othello/computer/ids.php>

<https://www.chessprogramming.org/Move_Ordering>

<https://www.chessprogramming.org/Transposition_Table>

<https://baike.baidu.com/item/%E7%BD%AE%E6%8D%A2%E8%A1%A8/19480039>

<https://www.chessprogramming.org/Evaluation>

<https://www.chessprogramming.org/Bitboards>

<https://gcc.gnu.org/projects/prefetch.html>

<http://library.msri.org/books/Book29/files/gasser.pdf>

<https://www.ics.uci.edu/~eppstein/cgt/morris.html>

<http://muehlespiel.eu/images/pdf/WMD_Spielregeln.pdf>
