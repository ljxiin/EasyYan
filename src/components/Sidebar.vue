<template>
  <aside class="sidebar">
    <div class="brand">
      <span class="brand-mark">UR</span>
      <strong>考研数学刷题系统</strong>
    </div>

    <nav class="nav">
      <RouterLink
        v-for="item in menuRoutes"
        :key="item.name"
        :to="item.path"
        class="nav-item"
        :class="{ active: isActive(item.path) }"
      >
        <component :is="icons[item.icon]" class="nav-icon" />
        <span>{{ item.title }}</span>
      </RouterLink>
    </nav>

    <div class="study-card panel">
      <p class="study-title">学习概况</p>
      <div class="study-metric">
        <span>累计学习</span>
        <strong>128</strong><em>天</em>
      </div>
      <div class="study-row">
        <div>
          <span>连续学习</span>
          <strong>15</strong><em>天</em>
        </div>
        <div>
          <span>今日学习</span>
          <strong>68</strong><em>分钟</em>
        </div>
      </div>
      <el-button type="primary" class="checkin" :icon="Calendar">打卡学习</el-button>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import * as ElementIcons from '@element-plus/icons-vue'
import { Calendar } from '@element-plus/icons-vue'
import { menuRoutes } from '@/router'

const route = useRoute()
const icons = ElementIcons as Record<string, unknown>
const currentPath = computed(() => route.path)

function isActive(path: string) {
  return path === '/' ? currentPath.value === '/' : currentPath.value.startsWith(path)
}
</script>

<style scoped lang="scss">
.sidebar {
  position: sticky;
  top: 0;
  width: 238px;
  height: 100vh;
  padding: 18px 16px;
  background: var(--surface);
  border-right: 1px solid var(--line);
}

.brand {
  display: flex;
  align-items: center;
  gap: 12px;
  height: 36px;
  color: var(--ink);
  font-size: 18px;
}

.brand-mark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  color: #fff;
  font-size: 13px;
  font-weight: 800;
  background: var(--primary);
  border-radius: 7px;
  box-shadow: 0 10px 18px rgba(31, 83, 255, 0.22);
}

.nav {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-top: 28px;
}

.nav-item {
  display: flex;
  align-items: center;
  gap: 13px;
  height: 46px;
  padding: 0 10px;
  color: var(--text);
  font-size: 16px;
  font-weight: 650;
  border-radius: 8px;
  transition: 0.18s ease;
}

.nav-item:hover,
.nav-item.active {
  color: var(--primary);
  background: var(--primary-soft);
}

.nav-icon {
  width: 22px;
  height: 22px;
}

.study-card {
  position: absolute;
  right: 16px;
  bottom: 18px;
  left: 16px;
  padding: 16px;
}

.study-title {
  margin: 0 0 14px;
  font-size: 14px;
  font-weight: 800;
}

.study-metric,
.study-row {
  padding-bottom: 14px;
  border-bottom: 1px solid var(--line);
}

.study-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  padding-top: 14px;
}

.study-metric span,
.study-row span {
  display: block;
  color: var(--muted);
  font-size: 12px;
}

.study-metric strong,
.study-row strong {
  display: inline-block;
  margin-top: 7px;
  color: var(--ink);
  font-size: 22px;
}

.study-metric em,
.study-row em {
  margin-left: 4px;
  color: var(--text);
  font-size: 12px;
  font-style: normal;
}

.checkin {
  width: 100%;
  height: 50px;
  margin-top: 16px;
  color: var(--primary);
  background: var(--primary-soft);
  border-color: transparent;
}
</style>
