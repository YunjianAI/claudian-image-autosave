# Claudian 图片自动保存 Patch

> 给 Obsidian 内置 AI 助手 Claudian 加一个能力：你发进会话的每张图（截图粘贴 / 拖拽），自动按会话存进 vault，事后随时找得回。全程零操作。

## 问题

Claudian 默认**不保存**你粘进会话的图片，图直接喂给模型、用完即弃。最难受的场景：你配置完一个东西、截图发给它让它写 SOP，等回头想引用那张图，发现**根本找不回来**了。

## 效果

照常截图粘贴，vault 里就自动多出按会话归档的图：

```
99.对话图片/
  └─ 2026-06-01 你的会话标题-a1b2c3/        ← 每个会话一个文件夹
        ├─ 20260601-184500-paste-image.png
        └─ 20260601-190012-drop-截图.png
```

| 装之前 | 装之后 |
|--------|--------|
| 粘进会话的图用完即弃，事后找不回 | 每张图自动落盘，按会话 + 时间归档 |
| 想给历史对话补 SOP 配图，没图可用 | 去对应会话文件夹直接拿 |

- 截图粘贴、拖拽**都存**，你不用多做任何动作
- 只存**发进 Claudian 会话**的图，不碰你别的剪贴板截图
- 按**会话**分文件夹，用会话 id 短码锚定（标题后来被改了也不散）

## 使用方法

### 前提条件
- 一个装了 Claudian 插件的 Obsidian（本 patch 基于 Claudian **2.0.1** 编译）
- Windows（脚本是 PowerShell；其他系统可手动用包里的 `main.js` 替换插件目录的同名文件）

### 安装
1. 关掉 Obsidian。
2. 在本目录打开 PowerShell，运行（把路径换成你自己的 vault 根目录）：
   ```powershell
   ./install.ps1 -VaultPath "D:\你的\ObsidianVault"
   ```
   脚本会先把当前 `main.js` 备份成 `main.js.bak-before-image-autosave-时间戳`，再装入新的。
3. 重启 Obsidian（或 Ctrl+P → Reload app）。
4. 搞定！在 Claudian 会话里粘张截图，去 vault 的 `99.对话图片/` 看，那张图已经按会话归好档了。

## 还原

不想要了，运行：
```powershell
./uninstall.ps1 -VaultPath "D:\你的\ObsidianVault"
```
自动还原到最近一次备份的 `main.js`，重启 Obsidian 生效。

## 常见问题

**Q：会把我所有剪贴板截图都偷偷存下来吗？**
不会。只存你真正粘进 / 拖进 Claudian 会话输入框的图，跟会话无关的截图一概不碰。

**Q：图存在哪、怎么命名？**
`99.对话图片/<日期 会话标题-会话id短码>/<时间戳-来源-原名>.png`。来源是 `paste`（粘贴）或 `drop`（拖拽）。

**Q：会话标题后来被自动重命名，图会散到两个夹吗？**
不会。文件夹用会话 id 短码做锚，同一会话的图永远进同一个文件夹，标题变了也认得出。

**Q：装了会动我的 Claudian 版本吗？**
会固定到 2.0.1（插件 id 仍是 `claudian`，会话和设置都不受影响）。没升最新版是有意的，避免新版插件 id 变更搞乱你的数据。

**Q：和 claudian-tab-title-patch 冲突吗？**
本 patch 整体替换 `main.js`，会盖掉 tab-title-patch。装完本 patch 后**重跑一次** tab-title-patch 即可，两个叠加不打架。

## 工作原理

- 改了 Claudian 源码两处（基于 [YishenTu/claudian](https://github.com/YishenTu/claudian) 2.0.1，MIT）：
  - `ImageContext.ts`：图片的唯一入口 `addImageFromFile`（粘贴、拖拽都汇到这）落盘时调 `persistToVault`，用 `vault.adapter.writeBinary` 写图。
  - `Tab.ts`：实例化时把 `app` 和会话 id 回调传进去。
- 按会话分文件夹：先扫 `99.对话图片/` 找以同一会话 id 短码结尾的文件夹复用，没有才读 `.claudian/sessions/<id>.meta.json` 拿标题新建。
- fire-and-forget：存图失败绝不影响正常发图（只在控制台记一条 error）。

## 已知边缘点（老实说）

- 图在**粘进输入框那一刻**就落盘，所以粘了又删会残留一张（改成「发送时才存」可以根治，暂未做）。
- 文件名只带时间戳，事后跨会话翻文件夹只能按时间排序，要精确「这张图对应哪一步」得靠当时的对话上下文（建议做 SOP 趁热在同一会话里做）。

## 文件说明

```
claudian-image-autosave/
├─ main.js          # Claudian 2.0.1 + 图片落盘，编译产物
├─ install.ps1      # 一键安装（先自动备份原 main.js）
├─ uninstall.ps1    # 一键还原
├─ README.md
└─ LICENSE
```

## License

MIT。基于开源项目 [YishenTu/claudian](https://github.com/YishenTu/claudian)（MIT）编译改造，仅新增「会话图片自动落盘」一个功能。

---

by 云间 · @云间AI手册
