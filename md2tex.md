# skill.md — Markdown 转 Template-en.tex 转换指南

## 概述

本文档描述如何将标准 Markdown 语法手动或自动转换为 `template-en.tex` 模板所使用的 TeX 语法。

---

## 文档框架转换

### Markdown

```markdown
# 文章标题

2000年1月1日

正文内容……
```

### 对应 TeX

```tex
\input template.tex
\title {文章标题}
\date {2000\sp 年\sp 1\sp 月\sp 1\sp 日}

正文内容……

\bye
```

---

## 语法对照表

### 1. 章节标题


`## 章节名` 对应 `\s {章节名}`

`### 章节名` 对应 `\ss {章节名}`

`#### 章节名` 对应 `\sss {章节名}`


**Markdown：**
```markdown
## CPU 初始化
```

**TeX：**
```tex
\s {CPU 初始化}
```

---

### 2. 段落

**Markdown：**
```markdown
第一段内容。

第二段内容。
```

**TeX：**
```tex
第一段内容。

第二段内容。
```

---

### 3. 超链接


 `[文字](url)` 对应 `\href{url}{文字}`

**Markdown：**
```markdown
[Firecracker](https://firecracker-microvm.github.io/)
```

**TeX：**
```tex
\href{https://firecracker-microvm.github.io/}{Firecracker}
```

> ⚠️ 注意：Markdown 是 `[文字](url)`，TeX 是 `\href{url}{文字}`，**顺序相反**。

---

### 4. 行内代码


`` `代码` `` 对应 `{\itt 代码}` |

**Markdown：**
```markdown
使用 `ioctl` 调用 `KVM_CREATE_VM` 接口。
```

**TeX：**
```tex
使用 {\itt ioctl} 调用 {\itt KVM\_CREATE\_VM} 接口。
```

> ⚠️ TeX 中下划线 `_` 需转义为 `\_`。

---

### 5. 代码块

| Markdown | TeX |
|---|---|
| 开始：` ```语言 ` | `\bcode` |
| 结束：` ``` ` | `\|ecode` |
| 块内换段：空行 | `\|par \|par` |

对于代码中的`|`要转成`||`

**Markdown：**
````markdown
```c
struct kvm_regs regs;
ioctl(cpu_fd, KVM_GET_REGS, &regs);

regs.rip = 0x100000;
ioctl(cpu_fd, KVM_SET_REGS, &regs);
```
````

**TeX：**
```tex
\bcode
struct kvm_regs regs;
ioctl(cpu_fd, KVM_GET_REGS, &regs);
|par |par
regs.rip = 0x100000;
ioctl(cpu_fd, KVM_SET_REGS, &regs);
|ecode
```

---

### 6. 列表

对于无序列表

| Markdown | TeX |
|---|---|
| 列表开始（第一个 `- `之前） | `\bli` |
| 列表结束（最后一个条目之后） | `\eli` |
| `- 条目内容` | `\li 条目内容` |

**Markdown：**
```markdown
- `KVM_CREATE_VM`：创建虚拟机
- `KVM_CREATE_IRQCHIP`：创建中断芯片模拟
- `KVM_CREATE_PIT2`：创建时钟芯片模拟
```

**TeX：**
```tex
\bli
    \li {\itt KVM\_CREATE\_VM}：创建虚拟机
    \li {\itt KVM\_CREATE\_IRQCHIP}：创建中断芯片模拟
    \li {\itt KVM\_CREATE\_PIT2}：创建时钟芯片模拟
\eli
```

对于有序列表：

```tex
\bli
    \item{1. } {\itt KVM\_CREATE\_VM}：创建虚拟机
    \item{2. } {\itt KVM\_CREATE\_IRQCHIP}：创建中断芯片模拟
    \item{3. } {\itt KVM\_CREATE\_PIT2}：创建时钟芯片模拟
\eli
```

---

### 7. 图片

| Markdown | TeX |
|---|---|
| `![alt](文件名){宽度}` | `\img{文件名}{宽度比例}` |

**Markdown（约定写法）：**
```markdown
![](1.jpg)
```

**TeX：**
```tex
\img{1.jpg}{0.75}
```


---

### 8. 粗体 / 斜体

> 本模板未见 `\textbf` / `\textit` 的使用示例，建议：

| Markdown | TeX 建议写法 |
|---|---|
| `**粗体**` | `{\bf 粗体}` |
| `*斜体*` | `{\it 斜体}` |

---

## 特殊字符转义对照

在 TeX 中，以下字符具有特殊含义，从 Markdown 转换时需注意转义：

| 字符 | Markdown 中 | TeX 中需写作 |
|---|---|---|
| `_` | 直接使用 | `\_` |
| `&` | 直接使用 | `\&` |
| `%` | 直接使用 | `\%` |
| `#` | 标题标记 | `\#` |
| `$` | 直接使用 | `\$` |
| `{` | 直接使用 | `\{` |
| `}` | 直接使用 | `\}` |
| `~` | 直接使用 | `\~{}` |
| `^` | 直接使用 | `\^{}` |
| `\` | 直接使用 | `\textbackslash{}` |

---

## 完整转换示例

### 输入（Markdown）

````markdown
# 运行虚拟 CPU

本节主要涉及代码中的`vm_run`函数。

在运行虚拟 CPU 之前，需要先通过[KVM API](https://docs.kernel.org/virt/kvm/api.html)映射一段内存：

```c
mmap_size = ioctl(vm->kvm_fd, KVM_GET_VCPU_MMAP_SIZE, 0);
run = mmap(NULL, mmap_size, PROT_READ | PROT_WRITE,
           MAP_SHARED, vm->cpu_fd, 0);
```

CPU 退出的原因可能有：

- 虚拟机关机
- 虚拟机请求 IO
- 虚拟机请求 MMIO
````

### 输出（TeX）

```tex
\s {运行虚拟 CPU}

本节主要涉及代码中的\sp {\itt vm\_run}\sp 函数。

在运行虚拟 CPU 之前，需要先通过 \href{https://docs.kernel.org/virt/kvm/api.html}{KVM API} 映射一段内存：

\bcode
mmap_size = ioctl(vm->kvm_fd, KVM_GET_VCPU_MMAP_SIZE, 0);
run = mmap(NULL, mmap_size, PROT_READ || PROT_WRITE,
           MAP_SHARED, vm->cpu_fd, 0);
|ecode

CPU 退出的原因可能有：

\bli
    \li 虚拟机关机
    \li 虚拟机请求 IO
    \li 虚拟机请求 MMIO
\eli
```

---

## 转换检查清单

完成转换后，逐项核对：

- [ ] 文档头部包含 `\input template-en.tex`、`\title`、`\date`
- [ ] 文档末尾有 `\bye`
- [ ] 所有 `## 标题` 已转换为 `\s {标题}`
- [ ] 所有 `` `行内代码` `` 已转换为 `{\itt 内容}`，且 `_` 已转义
- [ ] 所有代码块已替换为 `\bcode ... |ecode`，块内空行替换为 `|par |par`
- [ ] 所有 `[文字](url)` 已转换为 `\href{url}{文字}`（注意顺序）
- [ ] 所有无序列表已包裹在 `\bli ... \eli` 中，条目替换为 `\li`
- [ ] 所有图片已转换为 `\img{文件名}{缩放比例}`，缩放比例已人工确认
- [ ] 特殊字符（`_`、`&`、`%` 等）已正确转义
- [ ] 中文英文之间，除非中文后面是标点，否则要插入\sp，例如 `这是English单词`变成`这是\sp English\sp 单词`