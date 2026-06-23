<template>
  <header class="header" :class="{ 'practice-header': isPractice }">
    <template v-if="isStatistics">
      <div class="statistics-subject">
        <span>刷题科目：</span>
        <strong>数学（一）</strong>
        <el-icon><ArrowDown /></el-icon>
      </div>
    </template>
    <template v-else-if="isPractice && !isCustomPaper">
      <div class="practice-filters">
        <span class="filter-label">刷题科目：</span>
        <el-select v-model="practiceSubject" class="practice-select subject-select">
          <el-option label="数学（一）" value="math1" />
          <el-option label="数学（二）" value="math2" />
          <el-option label="数学（三）" value="math3" />
        </el-select>
        <div class="filter-label">刷题方式：</div>
        <el-select
          :model-value="practiceMode"
          class="practice-select mode-select"
          @change="changePracticeMode"
        >
          <el-option label="按试卷刷题" value="paper" />
          <el-option label="按章节刷题" value="chapter" />
          <el-option label="按收藏刷题" value="favorite" />
          <el-option label="按错题刷题" value="mistake" />
        </el-select>
      </div>
    </template>
    <h1 v-else>{{ title }}</h1>
    <div class="header-actions">
      <template v-if="isStatistics">
        <button type="button" class="date-pill">
          <el-icon><Calendar /></el-icon>
          <span>2024-04-01&nbsp; ~ &nbsp;2024-05-31</span>
          <el-icon class="close"><Close /></el-icon>
        </button>
        <button type="button" class="header-pill">
          <el-icon><Filter /></el-icon><span>筛选</span>
        </button>
        <button type="button" class="header-pill">
          <el-icon><Setting /></el-icon><span>设置</span>
        </button>
      </template>
      <div v-if="!isPractice && !isCustomPaper" class="search">
        <el-icon><Search /></el-icon>
        <span>搜索题目、考点、教材等...</span>
        <kbd>⌘ K</kbd>
      </div>
      <div v-if="isSession" class="timer-pill">
        <el-icon><Timer /></el-icon>
        <span>用时 00:23:45</span>
      </div>
      <button v-if="isSession" type="button" class="header-pill">
        <el-icon><VideoPause /></el-icon>
        <span>暂停</span>
      </button>
      <button v-if="isPractice && !isCustomPaper" type="button" class="header-pill">
        <el-icon><Setting /></el-icon>
        <span>设置</span>
      </button>
      <el-badge :value="12" class="notice">
        <el-icon><Bell /></el-icon>
      </el-badge>
      <el-icon class="mail"><Message /></el-icon>
      <div class="user">
        <el-avatar :size="32">👨🏻‍🏫</el-avatar>
        <strong>奔跑的数学人</strong>
        <span>Lv.5</span>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ArrowDown, Bell, Calendar, Close, Filter, Message, Search, Setting, Timer, VideoPause } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const practiceSubject = ref('math1')
const isPractice = computed(() => route.path.startsWith('/practice'))
const isStatistics = computed(() => route.path.startsWith('/statistics'))
const isCustomPaper = computed(() => Boolean(route.meta.customPaper))
const isSession = computed(() => route.path === '/practice/session')
const practiceMode = computed(() => {
  const mode = String(route.query.mode || '')
  return ['chapter', 'favorite', 'mistake'].includes(mode) ? mode : 'paper'
})
const title = computed(() => {
  if (route.path.startsWith('/papers/import') && route.query.mode === 'edit') return '试卷库　/　修改试卷'
  return route.meta.title || '首页 / 学习概览'
})

function changePracticeMode(value: string) {
  router.push({ name: 'practice', query: { mode: value } })
}
</script>

<style scoped lang="scss">
.header {
  display: flex;
  align-items: center;
  height: 70px;
  padding: 0 28px;
  background: var(--surface);
  border-bottom: 1px solid var(--line);
}

.practice-header {
  height: 72px;
  padding: 0 34px;
}

.practice-filters {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
}

.statistics-subject {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 230px;
  height: 42px;
  padding: 0 14px;
  color: var(--ink);
  font-size: 14px;
  border: 1px solid var(--line);
  border-radius: 7px;
}

.statistics-subject strong {
  flex: 1;
}

.statistics-subject .el-icon {
  color: var(--text);
  font-size: 13px;
}

.filter-label {
  color: var(--ink);
  font-size: 14px;
  font-weight: 700;
  white-space: nowrap;
}

.practice-select {
  flex: 0 0 auto;
}

.subject-select {
  width: 150px;
}

.mode-select {
  width: 152px;
}

.practice-select :deep(.el-select__wrapper) {
  min-height: 42px;
  padding: 0 14px;
  border-radius: 7px;
  box-shadow: 0 0 0 1px var(--line) inset;
}

.practice-select :deep(.el-select__selected-item) {
  color: var(--ink);
  font-size: 14px;
  font-weight: 700;
}

.timer-pill,
.header-pill,
.date-pill {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 40px;
  padding: 0 17px;
  color: var(--ink);
  font: inherit;
  font-size: 14px;
  font-weight: 700;
  border: 1px solid var(--line);
  border-radius: 22px;
  background: #fff;
}

.date-pill {
  gap: 10px;
  padding: 0 16px;
}

.date-pill .el-icon:first-child {
  color: var(--primary);
  font-size: 18px;
}

.date-pill .close {
  margin-left: 4px;
  color: var(--text);
  font-size: 14px;
}

.timer-pill .el-icon {
  color: var(--primary);
  font-size: 19px;
}

h1 {
  flex: 1;
  margin: 0;
  color: var(--ink);
  font-size: 20px;
  font-weight: 800;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 18px;
}

.search {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 360px;
  height: 38px;
  padding: 0 12px;
  color: var(--muted);
  font-size: 14px;
  border: 1px solid var(--line);
  border-radius: 20px;
}

.statistics-subject + h1,
.header:has(.statistics-subject) h1 {
  display: none;
}

.header:has(.statistics-subject) .search {
  display: none;
}

.search span {
  flex: 1;
}

kbd {
  padding: 2px 7px;
  color: var(--muted);
  font-family: inherit;
  font-size: 12px;
  background: #f1f4fb;
  border-radius: 6px;
}

.notice,
.mail {
  color: var(--text);
  font-size: 22px;
}

.user {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--ink);
  font-size: 13px;
}

.user span {
  padding: 2px 7px;
  color: #fff;
  font-size: 11px;
  background: var(--primary);
  border-radius: 10px;
}

.user :deep(.el-avatar) {
  font-size: 19px;
  background: #eef1f7;
}
</style>
