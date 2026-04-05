# 时令果园 - 项目规格说明书

> 版本：v1.0 | 日期：2026-04-05 | 状态：需求冻结

---

## 一、项目概述

### 1.1 产品定位

**时令果园**是一款面向城市用户的采摘/种植指南 App，帮助用户了解：
- 当前时节（当月/当节气）当地可以采摘哪些水果
- 当前时节当地适合种植哪些果树
- 各种水果的种植方法、营养价值、注意事项

### 1.2 目标用户

- 城市居民，周末去郊区采摘
- 庭院/阳台果树种植爱好者
- 农产品电商选品参考

### 1.3 核心特点

- **离线优先**：预装全国基础数据，无需网络也能查询
- **气候区智能匹配**：选城市自动匹配气候区，展示本地相关水果
- **时令精准**：按月份+节气双重维度展示水果成熟期

### 1.4 与时令菜园的关系

| 对比项 | 时令菜园 | 时令果园 |
|--------|---------|---------|
| 定位 | 蔬菜种植指南 | 水果采摘/种植指南 |
| 数据规模 | ~60种蔬菜 | ~50种主流水果（初版） |
| 地域绑定 | 精确到市（364城市） | 精确到气候区（6个区域） |
| 用户菜园 | 已种蔬菜 | 已种果树 + 采收记录 |
| 离线包大小 | ~3MB | ~5MB（预估） |
| 架构 | Flutter + SQLite | Flutter + SQLite |

---

## 二、气候区与地域设计

### 2.1 六大气候区

采用简化的气候区划分，避免数据爆炸，同时保持地域准确性：

| 气候区 | 代码 | 覆盖省份 | 代表城市 |
|--------|------|---------|---------|
| 寒温带 | cold_temperate | 黑龙江、内蒙古东北部 | 哈尔滨、齐齐哈尔、漠河 |
| 温带 | temperate | 东北南部、华北、西北东部 | 北京、济南、郑州、西安、兰州 |
| 亚热带 | subtropical | 华中、华东、华南北部 | 上海、杭州、武汉、长沙、福州 |
| 热带 | tropical | 华南、海南、云南南部 | 广州、三亚、深圳、昆明、西双版纳 |
| 高原 | plateau | 四川西部、云南西北、西藏、青海 | 成都（西部）、丽江、拉萨、西宁 |
| 干旱区 | arid | 新疆、甘肃北部、内蒙古西部 | 乌鲁木齐、吐鲁番、库尔勒 |

### 2.2 城市→气候区映射

用户选择任意城市后，自动匹配到对应气候区，展示该区域的水果数据。

初版覆盖全国约 **200个地级市**，按以下规则映射：
- 直辖市：北京、上海、天津、重庆 → 按实际气候归入对应区
- 地级市：按所属省份+地理位置归入对应气候区

---

## 三、数据结构设计

### 3.1 数据库概览

| 表名 | 用途 | 记录数（初版） |
|------|------|--------------|
| `fruits` | 水果主数据 | ~50种 |
| `fruit_climate_zones` | 水果-气候区适配表 | 多对多 |
| `fruit_ripening_months` | 水果成熟月份 | ~50×12 |
| `fruit_planting_months` | 水果种植月份 | ~50×12 |
| `climate_zones` | 气候区基础数据 | 6条 |
| `cities` | 城市-气候区映射 | ~200条 |
| `seasonal_calendar` | 月度时令日历 | 72条（6区×12月） |
| `user_garden` | 用户果园（本地） | 用户数据 |
| `user_favorites` | 用户收藏 | 用户数据 |

### 3.2 表结构详解

#### fruits（水果主数据）

```sql
CREATE TABLE fruits (
  id TEXT PRIMARY KEY,           -- 唯一标识，如 "apple_red"
  name TEXT NOT NULL,             -- "红富士苹果"
  emoji TEXT,                    -- "🍎"
  alias TEXT,                    -- "富士苹果"
  category TEXT,                 -- 分类：落叶果树/常绿果树/热带果树/瓜果类
  south_north_type TEXT,          -- 产地类型：北方/南方/全国

  -- 种植参数
  maturity_days INTEGER,          -- 从种植到采收的总天数
  sunlight TEXT,                 -- 喜阳/耐阴/喜半阴
  min_temp INTEGER,               -- 最低耐受温度（℃）
  max_temp INTEGER,              -- 最高耐受温度（℃）
  optimal_temp_min INTEGER,       -- 最适生长温度下限
  optimal_temp_max INTEGER,       -- 最适生长温度上限

  -- 土壤要求
  soil_type TEXT,                -- 土质要求：沙壤土/黏土/壤土/通用
  ph_min REAL,                  -- 适宜pH下限
  ph_max REAL,                  -- 适宜pH上限
  drainage TEXT,                -- 排水要求：良好/一般/耐涝

  -- 肥料（JSON存储）
  fertilizer TEXT,               -- {"base":"腐熟有机肥","top":"花果期增施磷钾肥"}

  -- 种植要点（JSON存储）
  planting_notes TEXT,            -- {"seedling":"健壮苗","pruning":"冬季修剪","pollination":"部分品种需授粉"}

  -- 营养价值（JSON存储）
  nutritional_value TEXT,        -- {"calories":52,"vitamin_c":4,"fiber":2.4,"sugar":10,"potassium":107}
  benefits TEXT,                 -- "延缓衰老、降低胆固醇、补铁补血"
  contraindications TEXT,         -- "胃酸过多者不宜多食；糖尿病患者慎食"

  -- 口感/价格（用于采摘推荐）
  taste TEXT,                    -- "脆甜多汁、果香浓郁"
  price_range TEXT,              -- "10-30元/斤"（仅供参考）

  created_at INTEGER,
  updated_at INTEGER
);
```

#### fruit_climate_zones（水果-气候区适配）

```sql
CREATE TABLE fruit_climate_zones (
  fruit_id TEXT,
  climate_zone_code TEXT,         -- cold_temperate/temperate/subtropical/tropical/plateau/arid
  planting_note TEXT,             -- 气候区特定的种植备注，如"需防寒"

  PRIMARY KEY (fruit_id, climate_zone_code)
);
```

#### fruit_ripening_months（成熟采收月份）

```sql
CREATE TABLE fruit_ripening_months (
  fruit_id TEXT,
  month INTEGER,                  -- 1-12
  is_peak INTEGER,               -- 1=最佳采收期，0=可采收但非最佳
  description TEXT,              -- "6月底-7月初最佳"，"8月下旬-9月"

  PRIMARY KEY (fruit_id, month)
);
```

#### fruit_planting_months（种植月份）

```sql
CREATE TABLE fruit_planting_months (
  fruit_id TEXT,
  month INTEGER,
  climate_zone_code TEXT,         -- 某些水果种植月份因气候区而异
  method TEXT,                  -- 春播/秋播/全年可种
  note TEXT,                    -- "北方3-4月春播，南方可秋播"

  PRIMARY KEY (fruit_id, month, climate_zone_code)
);
```

#### climate_zones（气候区定义）

```sql
CREATE TABLE climate_zones (
  code TEXT PRIMARY KEY,         -- 如 "subtropical"
  name TEXT,                    -- "亚热带"
  name_short TEXT,              -- "华中/华东"
  provinces TEXT,               -- 包含省份的JSON数组
  description TEXT
);
```

#### cities（城市-气候区映射）

```sql
CREATE TABLE cities (
  id TEXT PRIMARY KEY,           -- 城市ID
  name TEXT NOT NULL,            -- "杭州"
  name_short TEXT,              -- "杭州市"（带市后缀，用于显示）
  province TEXT,                -- "浙江"
  climate_zone_code TEXT,        -- 所属气候区代码

  FOREIGN KEY (climate_zone_code) REFERENCES climate_zones(code)
);
```

#### seasonal_calendar（月度时令日历）

```sql
CREATE TABLE seasonal_calendar (
  month INTEGER,                -- 1-12
  climate_zone_code TEXT,         -- 气候区代码
  ripening_fruit_ids TEXT,        -- 当月成熟水果ID的JSON数组
  planting_fruit_ids TEXT,       -- 当月适合种植水果ID的JSON数组
  solar_terms TEXT,              -- 当月节气JSON数组，如["清明","谷雨"]

  PRIMARY KEY (month, climate_zone_code)
);
```

### 3.3 离线数据结构

```
assets/
├── data/
│   ├── fruits.json              # 水果主数据（~50种）
│   ├── climate_zones.json       # 6个气候区定义
│   ├── cities.json              # ~200个城市映射
│   └── seasonal_calendar.json    # 72条月度日历
└── assets.json                  # Flutter assets 配置
```

**数据文件大小预估**：压缩后约 3-5MB

---

## 四、产品功能设计

### 4.1 底部导航（5个Tab）

| 序号 | Tab名称 | 图标 | 功能定位 |
|------|---------|------|---------|
| 0 | 首页 | 🏠 | 城市选择 + 当月采收 + 当月可种 |
| 1 | 我的果园 | 🌳 | 用户已种果树 + 采收记录 |
| 2 | 时令日历 | 📅 | 12个月横向滑动，按月展示 |
| 3 | 水果库 | 🍇 | 全部水果，列表/网格，筛选排序 |
| 4 | 设置 | ⚙️ | 城市切换、离线数据管理 |

### 4.2 首页

**顶部**：
- 城市选择器（点击弹出城市选择列表）
- 当前气候区标签

**主体**：
- 当月节气卡片
- **当季采收**（横向滑动卡片，优先展示 is_peak=1 的水果）
- **当月可种**（横向滑动卡片）

**城市选择**：
- 省份分组 → 城市列表
- 搜索框（支持拼音/城市名搜索）

### 4.3 时令日历

- 横向 Tab：1月～12月
- 每个月两个区块：**当月成熟** + **当月可种**
- 列表样式：emoji + 名称 + 最佳/一般标签
- 筛选：全部 / 仅最佳采收期 / 可种植

### 4.4 水果库

- 列表/网格视图切换
- 字母排序
- 按分类筛选：全部 / 落叶果树 / 常绿果树 / 热带果树 / 瓜果类
- 按产地筛选：全部 / 北方 / 南方 / 全国
- 搜索：按名称/别名搜索

**列表项**：
- emoji + 水果名 + 成熟月份 + 气候区标签

**点击进入详情页**

### 4.5 水果详情页

**头部卡片**：
- 大emoji + 水果名
- 别名、分类标签
- 产地/气候区适配

**基本信息**：
- 成熟周期（种植→采收天数）
- 成熟月份（当月是否成熟，高亮显示）

**环境要求**：
- 光照：喜阳/耐阴
- 温度：最低~最高℃，最适~
- 土壤：土质 + pH范围 + 排水

**肥料建议**：
- 底肥 + 追肥方案

**营养价值**：
- 热量、维生素C、膳食纤维、钾等具体数值
- 主要功效
- 食用禁忌

**种植要点**：
- 育苗/修剪/授粉/病虫害等注意事项

**底部操作**：
- 收藏（加入我的果园）
- 分享

### 4.6 我的果园

- 用户收藏/已种水果列表
- 每种水果可标记：已种 / 已采收 / 已移除
- 采收记录：记录采收时间、重量、评分
- 空状态引导去水果库添加

### 4.7 设置

- 当前城市（点击切换）
- 离线数据管理：下载/更新各省数据
- 清除缓存
- 关于

---

## 五、技术架构

### 5.1 技术栈

| 层次 | 技术 | 说明 |
|------|------|------|
| 框架 | Flutter ^3.x | 跨平台（iOS/Android/Windows/Mac/Web） |
| 状态管理 | Riverpod | Provider替代方案 |
| 本地数据库 | sqflite + sqflite_common_ffi | 移动端用sqflite，桌面端用ffi |
| 离线存储 | path_provider | 获取各平台存储路径 |
| 推送通知 | flutter_local_notifications | 采收提醒（可选） |
| 数据格式 | JSON | 预置数据用JSON，运行时用SQLite |

### 5.2 项目结构（Clean Architecture）

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   │   ├── app_constants.dart     # 预置城市/水果数据常量
│   │   └── enums.dart             # 枚举定义
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── date_utils.dart
├── data/
│   ├── datasources/
│   │   ├── fruit_local_datasource.dart
│   │   ├── climate_zone_local_datasource.dart
│   │   ├── city_local_datasource.dart
│   │   └── user_garden_local_datasource.dart
│   ├── models/
│   │   ├── fruit_model.dart
│   │   ├── climate_zone_model.dart
│   │   ├── city_model.dart
│   │   └── user_garden_model.dart
│   └── repositories/
│       ├── fruit_repository_impl.dart
│       └── user_garden_repository_impl.dart
├── domain/
│   ├── entities/
│   ├── repositories/     # 接口定义
│   └── usecases/
└── presentation/
    ├── pages/
    │   ├── home_page.dart
    │   ├── city_selection_page.dart
    │   ├── seasonal_calendar_page.dart
    │   ├── fruit_library_page.dart
    │   ├── fruit_detail_page.dart
    │   ├── my_garden_page.dart
    │   └── settings_page.dart
    ├── widgets/
    └── providers/
        ├── fruit_providers.dart
        ├── city_provider.dart
        └── garden_provider.dart

assets/
└── data/
    ├── fruits.json
    ├── climate_zones.json
    ├── cities.json
    └── seasonal_calendar.json
```

### 5.3 数据流

```
用户选择城市
    ↓
CityProvider 存储当前城市 + 匹配气候区
    ↓
首页加载当月水果（查 seasonal_calendar + fruits）
    ↓
水果详情（按ID查 fruits + fruit_ripening_months）
    ↓
我的果园（本地SQLite，读写 user_garden）
```

---

## 六、数据收集计划（最难的部分）

### 6.1 初版目标：50种主流水果

| 分类 | 水果数量 | 代表品种 |
|------|---------|---------|
| 落叶果树 | 20种 | 苹果、红富士、梨、桃、樱桃、葡萄、柿子、枣、杏、李、山楂 |
| 柑橘类 | 8种 | 橙子、橘子、柚子、柠檬、丑橘、金桔 |
| 热带果树 | 10种 | 香蕉、芒果、菠萝、荔枝、龙眼、火龙果、榴莲、山竹、椰子、番石榴 |
| 瓜果类 | 7种 | 西瓜、哈密瓜、甜瓜、香瓜、木瓜 |
| 浆果类 | 5种 | 草莓、蓝莓、桑葚、葡萄（鲜食）、猕猴桃 |

### 6.2 数据来源优先级

1. **FAO农业生产数据**：基础种植参数
2. **中国农业农村部**：品种信息、产地分布
3. **权威农业网站**：种植技术、注意事项
4. **Wikipedia**：营养成分（参考，需核实）

### 6.3 数据质量标准

- 种植参数（温度/pH/肥料）：需有农业院校或官方背书
- 营养价值：参考《中国食物成分表》
- 成熟月份：按主流产区/品种标注，允许因品种/地区差异浮动

---

## 七、里程碑计划

| 阶段 | 内容 | 产出 |
|------|------|------|
| **M1** | 数据建模 + 数据库搭建 | 50种水果数据录入SQLite |
| **M2** | 核心页面：首页、时令日历、水果库、详情页 | 可演示MVP |
| **M3** | 用户果园、收藏功能 | 完整交互体验 |
| **M4** | 城市选择器 + 气候区匹配逻辑 | 地域智能化 |
| **M5** | CI/CD搭建（Windows/Mac/Android/iOS） | 四平台构建 |

---

## 八、验收标准

### M2（MVP）验收

1. ✅ 50种水果数据正确录入SQLite
2. ✅ 首页正确显示当前城市对应的气候区
3. ✅ 首页正确展示当月成熟+当月可种水果
4. ✅ 时令日历12个月切换正常
5. ✅ 水果库列表/网格切换、筛选、搜索正常
6. ✅ 水果详情页展示完整种植+营养信息
7. ✅ `flutter build web` 成功
8. ✅ `flutter analyze` 无 error

---

## 附录：水果数据字段对照表

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| name | string | 水果名称 | "红富士苹果" |
| emoji | string | emoji图标 | "🍎" |
| category | enum | 分类 | 落叶果树 |
| climate_zones | string[] | 适配气候区 | ["temperate","cold_temperate"] |
| maturity_days | int | 成熟天数 | 180 |
| sunlight | enum | 光照需求 | 喜阳 |
| min_temp / max_temp | int | 温度范围 | -20 / 35 |
| soil_type | enum | 土质 | 沙壤土 |
| ph_min / ph_max | float | pH范围 | 6.0 / 7.5 |
| nutritional_value | JSON | 营养成分 | {"vitamin_c":4,"fiber":2.4} |
| benefits | string | 功效 | "延缓衰老、补铁补血" |
| contraindications | string | 禁忌 | "糖尿病患者慎食" |
