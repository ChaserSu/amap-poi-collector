# 高德 POI 数据采集器（桌面 GUI）

基于高德 Web API v5 的 POI 全量采集桌面应用，Electron 打包，**所有请求由本机直接发出，不经过任何第三方服务器**。

> ⚠️ **本项目只是 [ChaserSu/amap-poi-search](https://github.com/ChaserSu/amap-poi-search) 技能（Skill）的图形化界面，且只实现了它的部分功能。**
> 核心采集算法（四叉树网格、边界剪枝、extensions=all 全字段、同店清洗）均移植自该技能的 Python 脚本，GUI 版没有命令行版能力完整。遇到 bug 或需要新功能时，**建议安装该技能，让 AI 直接读源码帮你修/扩展，个人也不建议你为了使用图形化界面长期使用该版本**。

## amap-poi-search 技能（强烈建议）

技能是这套工具的"完整能力"的来源，AI可以根据你的需求加功能，修bug。TRAE CN 安装方式：

```bash
mkdir -p ~/.trae-cn/skills
git clone https://github.com/ChaserSu/amap-poi-search.git ~/.trae-cn/skills/amap-poi-search
```

重启 TRAE 后，在对话里描述需求即可，GUI仅仅作为快速演示，展示原理。

### GUI 版与技能版的功能对照

| 能力 | Skill（Python，完整版） | 本项目（GUI） |
|---|---|---|
| 按行政区（省/市/区县）全量采集 | ✅ | ✅ |
| 四叉树递归突破单参 200 条上限 | ✅ | ✅ |
| `extensions=all` 全字段导出 CSV | ✅ | ✅（28 列） |
| 真实边界剪枝 + 境内点过滤 | ✅ | ✅ |
| 官方域名 / 中转站切换 | ✅（环境变量） | ✅（界面切换） |
| 地图边界/网格/点位可视化 | ❌ | ✅ |
| **圆心 + 半径（circle）模式** | ✅ | ❌ 未实现 |
| 项目关键字精确定位 / 距离计算 | ✅ | ❌ |
| 断点续传（页级落盘缓存） | ✅ | ❌（停止后需重采） |
| 接口版本 | v3 | **v5**（`/v5/place/polygon`） |

## 简介

- **行政区全量采集**：选省/市/区县（支持名称或 adcode 搜索），自动拉取真实行政边界，四叉树切格递归抓取，满 200 条的格子自动四分，无盲区、无重叠
- **域名自由切换**：高德官方 `restapi.amap.com`、预置中转站、自定义域名；API Key 只保存在本机（localStorage）
- **全字段结果**：电话、特色标签、人均消费、评分、周/今日营业时间、商圈、别名、停车场类型、入口坐标、图片 URL 等，导出 UTF-8 BOM 的 CSV（Excel 直接打开不乱码）
- **采集控制**：开始 / 暂停 / 继续 / 停止，失败格自动重试 3 轮，可选同店清洗（同名同址、同名同本地号码去重）
- **可视化**：Leaflet + 高德瓦片，实时显示边界、分裂网格、叶子网格与 POI 点位；结果表点击行可定位到地图

## 下载安装

到 [Releases](https://github.com/ChaserSu/amap-poi-collector/releases/latest) 下载对应平台的产物：

- **Windows x64**：`*.win-x64-portable.exe`，单文件免安装，双击运行
- **macOS（Apple Silicon）**：`*-mac-arm64.zip`，解压得到 `.app`
- **macOS（Intel）**：`*-mac-x64.zip`，解压得到 `.app`

应用未做代码签名：Windows 遇到 SmartScreen 选「更多信息 → 仍要运行」；macOS 在 app 上**右键 → 打开**确认一次即可。

## 使用流程

1. 选择接口域名，填入对应 Key（官方域名需在[高德控制台](https://console.amap.com)申请「**Web服务**」类型 Key；中转站使用其配套 Key，二者不可混用），可点「连接测试」验证
2. 搜索/选择目标行政区，点「拉取行政区真实边界」
3. 勾选 POI 类别（默认餐饮、购物、生活服务，可展开选到中类），可选填一个关键词
4. 点「开始采集」，地图与日志实时展示进度；完成后下载 CSV

## 本地开发

```bash
npm install                 # 国内网络建议：
                            # ELECTRON_MIRROR=https://npmmirror.com/mirrors/electron/ npm install
npm start                   # 开发模式运行

npm run dist:win            # Windows x64 portable
npm run dist:mac            # macOS arm64 + x64（产物为未封装的 .app，用 ditto 打 zip）
```

纯网页部分也可直接用任意静态服务器打开 `index.html`（官方与中转站均允许浏览器跨域直连）。

## 说明

- POI 数据 © 高德地图；区划编码表与 POI 分类码来自高德官方下载页
- 同一参数高德最多返回 200 条，全量完全依赖网格递归，请求量与区域内 POI 密度正相关，请注意配额
- 本工具仅用于合法合规的数据查询与个人分析
