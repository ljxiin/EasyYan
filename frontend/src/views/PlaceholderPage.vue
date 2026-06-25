<template>
  <section class="panel page-placeholder">
    <h1>{{ title }}</h1>
    <p>{{ description }}</p>
    <div class="quick-cards">
      <article v-for="item in cards" :key="item.title" class="quick-card">
        <el-icon><component :is="item.icon" /></el-icon>
        <div>
          <strong>{{ item.title }}</strong>
          <span>{{ item.text }}</span>
        </div>
      </article>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { Calendar, Document, EditPen, Histogram, Reading, Setting } from '@element-plus/icons-vue'

const route = useRoute()
const title = computed(() => String(route.meta.title || '功能页面'))
const description = computed(() => `「${title.value}」路由已接入，后续将按原型图继续完善静态高保真页面。`)

const cards = [
  { title: 'Mock 数据', text: '先使用前端本地数据，不接真实后端。', icon: Document },
  { title: '统一组件', text: '复用侧边栏、顶部栏、卡片和表格样式。', icon: Reading },
  { title: '后续扩展', text: '页面会继续接入 Element Plus、ECharts、KaTeX。', icon: Histogram },
  { title: '学习流转', text: '保持和原型一致的上传、导入、刷题流程。', icon: Calendar },
  { title: '笔记体验', text: '笔记模块将支持 Markdown 与 LaTeX 内容。', icon: EditPen },
  { title: '系统设置', text: '账号、通知、显示、数据管理统一承载。', icon: Setting }
]
</script>

<style scoped lang="scss">
.page-placeholder p {
  margin: 0;
  color: var(--muted);
  font-size: 16px;
}

.quick-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-top: 30px;
}

.quick-card {
  display: flex;
  gap: 14px;
  min-height: 112px;
  padding: 20px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: #fbfcff;
}

.quick-card .el-icon {
  width: 42px;
  height: 42px;
  color: var(--primary);
  font-size: 24px;
  background: var(--primary-soft);
  border-radius: 10px;
}

.quick-card strong {
  display: block;
  margin-bottom: 8px;
  color: var(--ink);
  font-size: 16px;
}

.quick-card span {
  color: var(--muted);
  line-height: 1.6;
}
</style>
