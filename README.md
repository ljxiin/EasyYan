# 考研数学刷题系统

基于 Vue 3 + TypeScript + Vite 的考研刷题后台系统原型工程。

## 技术栈

- Vue 3
- TypeScript
- Vite
- Element Plus
- ECharts
- Pinia
- Vue Router
- Axios
- KaTeX
- PDF.js

## 运行方式

当前环境需要先安装 Node.js 18+。

```bash
npm install
npm run dev
```

默认访问：

```text
http://127.0.0.1:5173
```

## 已完成

- Vue 工程初始化
- 基础布局 `BasicLayout`
- 左侧菜单 `Sidebar`
- 顶部栏 `AppHeader`
- 路由配置
- 首页 `Dashboard` 静态高保真 UI
- ECharts 图表组件封装
- 其他核心菜单路由占位

## 后续页面

下一步可继续按原型实现：

- 教材库与上传教材四步流程
- 习题库与导入题目流程
- 试卷库与导入试卷流程
- 刷题列表与刷题详情
- 统计分析多 Tabs
- 知识网络图谱
- 学习计划、笔记管理、设置
