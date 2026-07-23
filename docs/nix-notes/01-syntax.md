# 01 · Nix 语法：函数、let、inherit

> 记录于第一次阅读项目构建链时遇到的一系列困惑。

---

## Q1 · 一个文件开头 `{inputs}:{system}:let...in...`，层层叠叠的到底是啥？

这是**两个函数套在一起**，分两层调用。

```nix
{ inputs, self }:       # 第一层函数：吃 {inputs, self}
{ system, hostname }:   # 第二层函数：吃 {system, hostname}
let ... in ...          # 第二层的函数体
```

等价于：

```nix
第一层 = { inputs, self }:
  第二层 = { system, hostname }:
    let ... in ...;
```

### 为什么拆两层？

因为 `inputs` 和 `self` 是**环境参数**—整个 flake 共享，只需传一次；`system`、`hostname` 是**构建参数**—每个主机不同，每次调用都传。

```nix
# 第一步：绑定环境，得到一个还在等 {system, hostname} 的函数
mkDarwin = import ./mk-darwin.nix { inputs = ...; self = ...; };

# 第二步：传入构建参数，真正执行
mkDarwin { system = "aarch64-darwin"; hostname = "mba"; };
```

### 类比

拿日常语言类比：

```javascript
// 一个"造问候语"的工厂
const greeter = (greeting) => (name) => `${greeting}, ${name}!`;

const sayHi = greeter("你好");   // 第一层：绑定问候语
sayHi("arrake");                 // 第二层：绑定名字
// "你好, arrake!"
```

Nix 里一样：

```nix
greeter = { greeting }: { name }: "${greeting}, ${name}!";

sayHi = greeter { greeting = "你好"; };
sayHi { name = "arrake"; }
# "你好, arrake!"
```

---

## Q2 · 为什么 `mkDarwin` 好像被调用了两次？一次在 `default.nix`，一次在 `configs.nix`？

因为 `mkDarwin` 是一个**两层函数**，每次调用只喂饱一层。

### `lib/system/default.nix`

```nix
{ inputs, self }:
{
  mkDarwin = import ./mk-darwin.nix { inherit inputs self; };
  #          ↑ import 读出函数, {inputs,self} 喂饱第一层
  #          mkDarwin 现在 = {system, hostname, ...}: let...in...
}
```

### `flake/configs.nix`

```nix
self.lib.system.mkDarwin {
  system = "aarch64-darwin";
  hostname = "mba";
  username = "arrake";
}
#  ↑ 再喂第二层，执行函数体
```

流程：

```
default.nix:  import + {inputs, self} → 返回内层函数
configs.nix:  再传 {system, hostname} → 执行 let...in → 得到完整配置
```

### 这个模式叫"柯里化"（currying）

> 把一个多参数函数拆成一系列单参数函数，每次调用延迟一步，直到所有参数到齐才真执行。

不拆的话，每次都要把所有参数一口气传齐：

```nix
(import ./mk-darwin.nix) { inputs; self; system; hostname; username; }
```

拆开的好处：环境和目标不混在一起，清晰且可复用。

---

## Q3 · `import ./file.nix { args }` 是在做什么？

两步合成一步。

```nix
# 其实等价于：
func = import ./mk-darwin.nix;   # 1. import 读文件，得到里面写的函数
func { inputs = ...; self = ...; } # 2. 调用这个函数
```

```nix
# 写成一步：
import ./mk-darwin.nix { inputs = ...; self = ...; }
```

文件内容 -> 读为表达式 -> 如果是函数就直接调用。Nix 里 `import` 的结果可以是任何值：函数、字符串、attrset，取决于文件里写了什么。

---

## Q4 · `inherit` 到底在干什么？写全了不是更清楚吗？

语法糖，省去重复。

```nix
# 这两行完全等价
inherit system hostname;
system = system; hostname = hostname;
```

Nix 里经常出现"当前作用域有个变量，要在 attrset 里放一个同名属性"，`inherit` 就是为这种情况设计的。不写 `inherit`，代码里会充满 `x = x; y = y;`，噪音很大。

### 跨源 inherit

```nix
inherit (lib) mkIf mkEnableOption;
# 等价
mkIf = lib.mkIf;
mkEnableOption = lib.mkEnableOption;
```

从 `lib` 里挑几个想用的，直接拿进来用短名。

### 注意：调用方 vs 定义方

`inherit` 在**调用方**和**定义方**都出现，但含义一致：

```nix
# 调用方：组装参数 attrset
common.mkSpecialArgs {
  inherit system hostname username extendedLib;
  # 等价 { system = system; hostname = hostname; ... }
}

# 定义方：构造返回值 attrset
{
  inherit inputs self system hostname username;
  # 等价 { inputs = inputs; self = self; ... }
}
```

运行时的"继承源"就是当前作用域中的同名变量，跟位置无关。

---

## Q5 · `?` 和 `...` 在参数里是什么意思？

### `?` — 可选参数，带默认值

```nix
{ modules ? [ ] }:
```

调用方不传 `modules`，自动当成 `[ ]`（空列表）。传了就覆盖默认值。

### `...` — "多余的参数别报错"

```nix
{ system, hostname, ... }:
```

如果没写 `...`，调用方多传了 `username`、`inputs` 等字段，Nix 直接报 unknown attribute。加上 `...` 就表示"我只需要这三个，别的无视"。

实际项目中函数签名经常写成：

```nix
{ system, hostname, username, modules ? [ ], ... }:
```

意思是：`system`/`hostname`/`username` 必传；`modules` 可选，默认空列表；传别的不报错。

---

## Q6 · `let ... in` 为什么要拆成两部分？不能直接写 `x = 1; x + 2` 吗？

不能，因为 Nix **没有语句，只有表达式**。

### 语句 vs 表达式

```javascript
// JavaScript 有语句
let x = 1;          // 语句：做一件事
let y = x + 2;      // 语句：再做一件事
return y;           // 语句：返回
```

```nix
# Nix 一切都是表达式
let
  x = 1;            # 绑定名字到值
in
  x + 2             # in 后面的表达式的值 = 整个 let 的值
```

`let` 只负责起名字，**不执行任何事**；`in` 后面的表达式才是整段代码的产出物。一段 Nix 代码的最终结果永远是**一个值**，来自 `in`。

### 所以 `let` 就是给中间值起名

```nix
# 没有 let
(3 + 5) * (3 + 5) + 10       # 重复写了两遍 (3+5)

# 有 let
let sum = 3 + 5; in sum * sum + 10   # 干净的
```

#### 后面可以引用前面

```nix
let
  name = "arrake";
  greeting = "Hello, ${name}";   # 引用了上一行的 name
in
  greeting
# "Hello, arrake"
```

### 实际项目中的 let

```nix
let
  common = import ./common.nix { inherit inputs self; };     # 导入共享逻辑
  extendedLib = common.mkExtendedLib self;                   # 构造扩展 lib
  matchingHomes = common.mkHomeConfigs { inherit system hostname; };  # 过滤匹配的 home 配置
  specialArgs = common.mkSpecialArgs {                       # 组装 specialArgs
    inherit system hostname username extendedLib;
  };
in
  inputs.nix-darwin.lib.darwinSystem { ... }   # ← 最终产出物
```

`let` 里定义了四个中间变量，名字越来越具体，最后一行 `in` 拼出最终配置。读的时候从上往下看 is 看懂每一步在准备什么，然后看 `in` 就知道最终要产出什么。

---

## 收尾 · 跟命令式语言比，Nix 最根本的差别是什么？

| 命令式语言（JS/Python/Bash） | Nix |
|---|---|
| 代码是一串**语句**，依次执行 | 代码是一个**表达式**，最终求值为一个值 |
| `let x = 1;` 是一条赋值语句 | `let x = 1; in x + 2` 是表达式，值是 3 |
| 可以在任何地方写 `return` | 没有 `return`，`in` 后面的就是结果 |
| 函数体里可以写多行语句 | 函数体就是一个表达式 |
| 变量可以重新赋值 | 绑定后不可变 |

所以看到一个 Nix 文件，问自己一个问题：**"这个文件的最终值是什么？"**——`in` 会告诉你答案。
