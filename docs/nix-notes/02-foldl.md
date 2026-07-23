# 02 · Nix 高阶函数：foldl' 与属性集合合并

> 从 `parseSystemConfigurations` 里的一句 `builtins.foldl'` 出发，搞懂 Nix 里的折叠、合并和 map-reduce 模式。

---

## Q1 · 这句话到底在干什么？

```nix
builtins.foldl' (acc: system: acc // generateSystemConfigs system) { } systemArchs
```

**一句话**：遍历一个架构列表，对每个架构生成该架构下的所有主机配置，然后把它们合并成一个大表。

### 输入（假设系统目录长这样）

```
systems/
├── aarch64-darwin/
│   └── mba/
└── x86_64-linux/
    ├── desktop/
    └── laptop/
```

### 输出

```nix
{
  mba     = { system = "aarch64-darwin"; hostname = "mba";     path = "..."; };
  desktop = { system = "x86_64-linux";   hostname = "desktop"; path = "..."; };
  laptop  = { system = "x86_64-linux";   hostname = "laptop";  path = "..."; };
}
```

一句话实现了"多级目录扫描 → 单层主机映射"的转换。

---

## Q2 · `foldl'` 和 `foldl` 是什么？

fold 的中文叫"折叠"。它是一个通用迭代器：给你一个初始值和一个列表，从左到右逐个用当前元素更新累积值，遍历完返回最终累积值。

```nix
builtins.foldl' f init list
# builtins.foldl  f init list   ← 惰性版本
```

| 参数 | 含义 |
|------|------|
| `f` | 二元函数：`累积值 → 当前元素 → 新累积值` |
| `init` | 初始累积值 |
| `list` | 要遍历的列表 |
| **返回值** | 遍历完所有元素后的累积值 |

### 类比：叠纸

你面前有一叠正方形纸（列表），每张纸上有一个数字（元素）。你想把所有数字加在一起。

```
操作:  把手中的数（累积值）和纸上数字相加，得到新的累积值
初始:  0（还没拿到纸，手里是 0）

第一张纸:  5  |  0 + 5 = 5
第二张纸:  3  |  5 + 3 = 8
第三张纸:  9  |  8 + 9 = 17

最终: 17
```

```nix
builtins.foldl' (acc: n: acc + n) 0 [5 3 9]
# → 17
```

### `foldl'` vs `foldl`：严格 vs 惰性

| | `foldl` | `foldl'` |
|---|---|---|
| 每步是否立即求值 | 否（堆叠 thunk） | 是（立即求值） |
| 处理大列表 | 可能栈溢出 | 安全 |
| 合并大 AttrSet 时用哪个 | ❌ | ✅ |

带 `'` 的版本是严格版本，一步一清，不会堆未求值表达式。本项目的合并操作都用了 `foldl'`，是 Nix 社区的惯用模式。

---

## Q3 · `acc: system: acc // generateSystemConfigs system` 的每一块是什么意思？

```nix
acc: system: acc // generateSystemConfigs system
│     │        │                │
│     │        │                └── 用当前 system 字符串生成该架构下的主机 AttrSet
│     │        └── 把新生成的配置合并到累积值上（右覆盖左）
│     └── 当前列表元素（字符串，如 "aarch64-darwin"）
└── 累积值（一轮轮迭代叠加后的 AttrSet）
```

**类型签名**：

```
acc    : AttrSet    -- 到当前元素为止累积的所有主机配置
system : String     -- 列表中的一个架构名
返回值 : AttrSet    -- 合并了当前元素后新的累积值
```

---

## Q4 · `//` 运算符是什么？

`//` 是 Nix 的属性集合合并运算符（update operator）。

```nix
a // b
```

- 返回一个**新** AttrSet，包含 `a` 和 `b` 的所有键
- **同名键时，`b` 的值覆盖 `a` 的值**（右优先）
- **浅合并**：不会递归合并嵌套属性

### 实例

```nix
{ x = 1; y = 2; } // { y = 99; z = 3; }
# → { x = 1; y = 99; z = 3; }

# y 被覆盖了，因为它在右边
```

在 foldl' 里：

```nix
acc // generateSystemConfigs system
# 把"新扫描到的主机"追加到"已累积的主机"后
# 不同架构下的主机名不应重复，覆盖不会造成问题
```

### 注意：浅合并陷阱

```nix
{ a = { x = 1; }; } // { a = { y = 2; }; }
# → { a = { y = 2; }; }    ← 内层的 {x = 1} 丢了！
```

`//` 只看第一层键。需要深层合并时用 `lib.recursiveUpdate`。

```nix
lib.recursiveUpdate { a = { x = 1; }; } { a = { y = 2; }; }
# → { a = { x = 1; y = 2; }; }
```

---

## Q5 · `generateSystemConfigs` 返回什么？

```nix
generateSystemConfigs = system:
  let
    systemPath = systemsPath + "/${system}";
    hosts = builtins.attrNames (builtins.readDir systemPath);
  in
  genAttrs hosts (hostname: {
    inherit system hostname;
    path = systemPath + "/${hostname}";
  });
```

当 `system = "aarch64-darwin"`：

1. `systemPath` = `"systems/aarch64-darwin"`
2. `builtins.readDir` 读目录 → `{ "mba" = "directory"; }`
3. `builtins.attrNames` 取键 → `["mba"]`
4. `genAttrs ["mba"] (hostname: { ... })` 构造：

```nix
{
  mba = {
    system = "aarch64-darwin";
    hostname = "mba";
    path = "systems/aarch64-darwin/mba";
  };
}
```

当 `system = "x86_64-linux"`：

```nix
{
  desktop = { system = "x86_64-linux"; hostname = "desktop"; path = "..."; };
  laptop  = { system = "x86_64-linux"; hostname = "laptop";  path = "..."; };
}
```

---

## Q6 · 完整运行过程一步一步是怎么走的？

**`systemArchs` = `["aarch64-darwin", "x86_64-linux"]`**

### 第 0 步：初始累积值

```
acc = {}
```

### 第 1 次迭代：`system = "aarch64-darwin"`

```
acc    = {}                          ← 上一步
system = "aarch64-darwin"            ← 列表[0]

generateSystemConfigs "aarch64-darwin"
  = { mba = { system="aarch64-darwin"; hostname="mba"; path="..."; }; }

acc // ...
  = {} // { mba = {...} }
  = { mba = {...} }                  ← 新的累积值
```

### 第 2 次迭代：`system = "x86_64-linux"`

```
acc    = { mba = {...} }             ← 上一步
system = "x86_64-linux"              ← 列表[1]

generateSystemConfigs "x86_64-linux"
  = { desktop = {...}; laptop = {...}; }

acc // ...
  = { mba = {...}; } // { desktop = {...}; laptop = {...}; }
  = { mba = {...}; desktop = {...}; laptop = {...}; }
```

### 遍历完毕，返回最终结果

```nix
{
  mba     = { system = "aarch64-darwin"; hostname = "mba";     path = "..."; };
  desktop = { system = "x86_64-linux";   hostname = "desktop"; path = "..."; };
  laptop  = { system = "x86_64-linux";   hostname = "laptop";  path = "..."; };
}
```

---

## Q7 · `mergeAttrs` 跟 foldl' 有什么关系？

项目里本来就有一个 `mergeAttrs`，内部也用 `foldl'`：

```nix
mergeAttrs = attrsList: lib.foldl' (acc: attrs: acc // attrs) { } attrsList;
```

实际上，`parseSystemConfigurations` 的 foldl' 就是 mergeAttrs 的等价展开：

```nix
# 原写法：
builtins.foldl' (acc: system: acc // generateSystemConfigs system) {} systemArchs

# 等价于：
mergeAttrs (map generateSystemConfigs systemArchs)
# map 把每个架构字符串变成 AttrSet，mergeAttrs 把它们合并
```

两种写法语义等价。foldl' 写法省掉了中间列表，一步到位。

---

## Q8 · `foldl'` 还能怎么用？

### 求和

```nix
builtins.foldl' (acc: n: acc + n) 0 [1 2 3 4 5]
# → 15
```

### 拼接列表

```nix
builtins.foldl' (acc: x: acc ++ [x * 2]) [] [1 2 3]
# → [2 4 6]
```

### 合并多层配置

```nix
# 把 sources 目录下的所有 JSON 文件读出来，翻译成 Nix attrs，合并
builtins.foldl' (acc: file:
  acc // builtins.fromJSON (builtins.readFile file)
) {} nixFiles
```

---

## Q9 · `genAttrs` 是干什么的？

用 `genAttrs` 把一个列表变成 AttrSet，键=列表元素，值=你指定的函数结果。

```nix
genAttrs ["a" "b" "c"] (name: "value_of_${name}")
# → { a = "value_of_a"; b = "value_of_b"; c = "value_of_c"; }
```

在 `generateSystemConfigs` 里：

```nix
hosts = ["mba", "imac"];   # 两个主机名

genAttrs hosts (hostname: { ... })
# → {
#     mba = { system = "..."; hostname = "mba"; path = "..."; };
#     imac = { system = "..."; hostname = "imac"; path = "..."; };
#   }
```

`genAttrs` 是 `map` 的 AttrSet 版本：列表 in → AttrSet out。

---

## Q10 · `foldl'` vs 循环 vs map — Nix 里该用哪个？

| 场景 | 用什么 |
|------|--------|
| 遍历列表，逐步累积一个值 | `foldl'` |
| 遍历列表，逐个转换 → 同长度的列表 | `map` |
| 遍历列表，取键组成 AttrSet | `genAttrs` + `foldl'` |
| 遍历 AttrSet，保留结构 | `mapAttrs` |
| 遍历 AttrSet，按键过滤 | `filterAttrs` |

Nix **没有** `for` 循环（它是声明式语言），一切迭代都用这些高阶函数表达。

## 速查卡

| 语法 | 说明 |
|------|------|
| `builtins.foldl' f init list` | 严格左折叠，每步立即求值 |
| `builtins.foldl f init list` | 惰性左折叠（合并大 AttrSet 时避免） |
| `a // b` | 属性集浅合并，右覆盖左 |
| `lib.recursiveUpdate a b` | 属性集深合并 |
| `genAttrs ["a" "b"] (n: v)` | 列表 → AttrSet 映射 |
| `mergeAttrs [a b c]` | 合并 AttrSet 列表（等价 `foldl' (acc: x: acc//x) {}`） |
