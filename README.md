# GTA6 助手（GTA6Helper）

GTA 6 攻略小工具：攻略文章（分类 + 搜索 + 详情）、进度清单（分组勾选 + 百分比）、点位列表、收藏，勾选与收藏保存在手机本地。界面用 iOS 26 Liquid Glass，卡片间距 12pt。

## 安装

到本仓库的 Releases 下载最新的 `GTA6Helper.ipa`，用 SideStore / AltStore 在 iPhone 上安装即可（未签名包，需通过 SideStore/AltStore 自签）。

## 构建

GitHub Actions（`.github/workflows/build.yml`）在 macos-26 上用 XcodeGen 生成工程并打包未签名 IPA，同时上传 artifact 并发布到 Release（tag `v1.0-<run_number>`）。图标在构建前由 `icon-1024.b64` 解码生成（原始图标为 `icon-1024.png`：粉紫落日渐变 + 白色 VI 字样，原创绘制，未使用 Rockstar 素材）。

## 数据更新（不用重新打包）

App 启动时从在线 JSON 拉取最新数据：

```
https://raw.githubusercontent.com/kar-liang/iconpack/master/data/gta6-guides.json
```

本仓库 `data/gta6-guides.json` 就是这份数据的源文件，同步到 iconpack 的 `data/` 下即可生效；拉取失败时先用上次缓存，再兜底到 App 内置快照（`Sources/GuidesData.swift`，内容与起始 JSON 一致）。

JSON 结构：`guides`（文章：id/title/category/summary/sections[heading/body/steps]）、`checklistGroups`（分组 + items[id/title/detail]）、`locations`（id/name/area/detail）、`version`、`updatedAt`。

## 内容说明

v1 是起始/框架内容，只写入可核实的事实：双主角 Lucia Caminos 与 Jason Duval、舞台为雷奥奈达州（Leonida）含罪恶城（Vice City）及官方公布过的其他区域。**没有**编造具体任务名、收集品数量或地图坐标；详细的任务流程、收集清单、点位细项在逐项核实后通过在线 JSON 补充，App 端无需改代码。
