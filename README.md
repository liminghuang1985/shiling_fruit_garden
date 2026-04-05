# 时令果园

> 基于气候区的水果采摘/种植指南 App

## 项目状态

🟡 **需求冻结** — SPEC.md 已完成，等待启动开发

## 文档

- [SPEC.md](./SPEC.md) — 完整需求 + 设计文档

## 快速概览

- **定位**：城市用户采摘指南 + 果树种植参考
- **架构**：Flutter + SQLite（离线优先）
- **核心数据**：50种水果 × 6个气候区 × 12个月

## 待办

- [ ] M1：数据建模 + 数据库搭建（50种水果数据）
- [ ] M2：核心页面 MVP
- [ ] M3：用户果园功能
- [ ] M4：城市选择器 + 气候区匹配
- [ ] M5：CI/CD 四平台构建

## 技术栈

- Flutter ^3.x
- Riverpod（状态管理）
- sqflite + sqflite_common_ffi
- 目标平台：iOS / Android / Windows / Mac / Web
