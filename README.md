# Claudian 图片自动保存 patch（基于 2.0.1）

## 这个 patch 干什么

Claudian 默认不保存你粘贴 / 拖进会话的图片（直接喂给模型、用完即弃，事后找不回，这是它的设计）。

这个 patch 在 Claudian 的图片入口加了一段：**你发进会话的每张图（截图粘贴 + 拖拽），自动按会话存到 vault 的 `99.对话图片/<日期 会话标题-会话id短码>/` 子文件夹**，文件名带时间戳。你零额外操作、照常截图粘贴；事后按「会话名 + 日期」找那个文件夹即可。

按会话分文件夹的规则：用**会话 id 短码做稳定锚**（同一会话的图始终进同一夹，哪怕标题后来变了），标题从会话 meta 读取做可读名。如果你在会话还没自动命名时就粘了第一张图，那个夹会叫 `日期 未命名会话-id短码`，之后该会话的图都进它。

## 基于哪个版本

基于你当前装的 **Claudian 2.0.1** 源码编译（插件 id 仍是 `claudian`，不升级、不动其他任何行为），只加了「图片落盘」这一件事。会话历史 / settings 都不受影响。

> 没升到最新 2.0.20 是有意的：2.0.12 把插件 id 改成了 `realclaudian`，升级会触发数据迁移、搞乱你的会话历史和 tab-title-patch，不值得。

## 怎么装

1. 先关掉 Obsidian（或装完再重启）。
2. 在本目录打开 PowerShell，运行（把路径换成你自己的 vault 根目录）：
   ```powershell
   ./install.ps1 -VaultPath "D:\你的\ObsidianVault"
   ```
   脚本会先把当前 `main.js` 备份成 `main.js.bak-before-image-autosave-时间戳`，再装入新的。
3. 重启 Obsidian（或 Ctrl+P → Reload app）。
4. **验证**：在 Claudian 会话里粘贴一张截图，去 vault 的 `99.对话图片/` 看有没有自动冒出按会话分的子文件夹、图在里头（文件名形如 `20260601-181500-paste-image.png`）。

> ⚠️ 这个 main.js 是从 Claudian **2.0.1** 编译的。装上会把你的 Claudian 固定到 2.0.1（id 仍是 `claudian`，会话/设置不受影响）。不想要随时 `./uninstall.ps1 -VaultPath "..."` 还原。

## ⚠️ 如果你装过 claudian-tab-title-patch

本 patch 整体替换 main.js，会覆盖掉 tab-title-patch 的改动（tab 标题会变回纯数字）。
解决：装完本 patch、重启确认图片落盘 OK 之后，**再跑一次 claudian-tab-title-patch 的一键安装**。两个 patch 叠加（tab-title-patch 在新 main.js 上改 renderBadge，不影响图片落盘）。

## 不想要了怎么还原

运行 `./uninstall.ps1`，自动还原到最近一次备份的 main.js，重启 Obsidian 生效。

## 技术细节（给未来的自己 / AI）

- 源码改了两处（基于 `YishenTu/claudian` 2.0.1，MIT）：
  - `src/features/chat/ui/ImageContext.ts`：图片唯一入口 `addImageFromFile`（粘贴 + 拖拽都汇到这）成功后调 `persistToVault`，用 `app.vault.adapter.writeBinary` 把图落盘；构造函数加 `app` 参数。
  - `src/features/chat/tabs/Tab.ts`：实例化 `ImageContextManager` 时把 `plugin.app` 传进去。
- 存储结构 `99.对话图片/<日期 标题-会话id短码>/<时间戳-来源(paste/drop)-原名.png>`。`resolveSessionFolder` 先扫已有子夹按 id 短码复用，否则读 `.claudian/sessions/<会话id>.meta.json` 拿 title 新建。会话 id 由 Tab.ts 经 `() => tab.conversationId` 回调传入。
- fire-and-forget：存图失败不影响正常发图（静默记 `console.error`）。
- 编译坑留底：WSL 的 node 18 编不了（依赖 `builtin-modules` 用了 node 22 的 `with {type:'json'}` 语法），把那行临时改回 `assert` 即可用 node 18 编过。
- 作者：云间 + Claude。
