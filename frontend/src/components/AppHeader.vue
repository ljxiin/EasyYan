<template>
  <header class="header" :class="{ 'practice-header': isPractice }">
    <template v-if="isPapers">
      <div class="paper-header-filters">
        <div class="paper-header-filter">
          <span class="filter-label">考试科目：</span>
          <el-select v-model="paperExamSubject" class="paper-header-select paper-exam-select">
            <el-option label="数学（一）" value="math1" />
          </el-select>
        </div>
        <div class="paper-header-filter">
          <span class="filter-label">刷题科目：</span>
          <el-select v-model="paperPracticeSubject" class="paper-header-select paper-practice-select" @change="changePaperSubject">
            <el-option label="高等数学" value="calculus" />
            <el-option label="线性代数" value="linear-algebra" />
            <el-option label="概率统计" value="probability" />
          </el-select>
        </div>
      </div>
    </template>
    <template v-else-if="isStatistics">
      <div class="statistics-filters">
        <div class="statistics-filter">
          <span class="filter-label">考试科目：</span>
          <el-select v-model="statisticsExam" class="statistics-select exam-select">
            <el-option label="数学（一）" value="math1" />
            <el-option label="数学（二）" value="math2" />
            <el-option label="数学（三）" value="math3" />
          </el-select>
        </div>
        <div class="statistics-filter">
          <span class="filter-label">刷题科目：</span>
          <el-select v-model="statisticsSubject" class="statistics-select practice-subject-select" @change="changeStatisticsSubject">
            <el-option label="高等数学" value="calculus" />
            <el-option label="线性代数" value="linear-algebra" />
            <el-option label="概率统计" value="probability" />
          </el-select>
        </div>
      </div>
    </template>
    <template v-else-if="isPractice && !isCustomPaper">
      <div class="practice-filters">
        <span class="filter-label">考试科目：</span>
        <el-select v-model="practiceSubject" class="practice-select subject-select">
          <el-option label="数学（一）" value="math1" />
          <el-option label="数学（二）" value="math2" />
          <el-option label="数学（三）" value="math3" />
        </el-select>
        <template v-if="showPracticeSubjectFilter">
          <span class="filter-label">刷题科目：</span>
          <el-select
            v-model="practiceQuestionSubject"
            class="practice-select practice-question-subject-select"
            @change="changePracticeSubject"
          >
            <el-option label="高等数学" value="calculus" />
            <el-option label="线性代数" value="linear-algebra" />
            <el-option label="概率统计" value="probability" />
          </el-select>
        </template>
        <div class="filter-label">刷题方式：</div>
        <el-select
          :model-value="practiceMode"
          class="practice-select mode-select"
          @change="changePracticeMode"
        >
          <el-option label="按试卷刷题" value="paper" />
          <el-option label="按章节刷题" value="chapter" />
          <el-option label="按知识点刷题" value="knowledge" />
          <el-option label="按收藏刷题" value="favorite" />
          <el-option label="按错题刷题" value="mistake" />
        </el-select>
      </div>
    </template>
    <h1 v-else>{{ title }}</h1>
    <div class="header-actions">
      <div v-if="isSession" class="timer-pill">
        <el-icon><Timer /></el-icon>
        <span>用时 00:23:45</span>
      </div>
      <button v-if="isSession" type="button" class="header-pill">
        <el-icon><VideoPause /></el-icon>
        <span>暂停</span>
      </button>
      <div class="user">
        <el-avatar :size="32">👨🏻‍🏫</el-avatar>
        <strong>奔跑的数学人</strong>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Bell, Calendar, Close, Message, Search, Setting, Timer, VideoPause } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const practiceSubject = ref('math1')
const practiceQuestionSubject = ref('calculus')
const statisticsExam = ref('math1')
const statisticsSubject = ref('calculus')
const paperExamSubject = ref('math1')
const paperPracticeSubject = ref('calculus')
const isPractice = computed(() => route.path.startsWith('/practice'))
const isStatistics = computed(() => route.path.startsWith('/statistics'))
const isPapers = computed(() => route.path === '/papers')
const isCustomPaper = computed(() => Boolean(route.meta.customPaper))
const isSession = computed(() => route.path === '/practice/session')
const practiceMode = computed(() => {
  const mode = String(route.query.mode || '')
  return ['chapter', 'knowledge', 'favorite', 'mistake'].includes(mode) ? mode : 'paper'
})
const showPracticeSubjectFilter = computed(() => ['chapter', 'knowledge', 'favorite', 'mistake'].includes(practiceMode.value))
const title = computed(() => {
  if (route.path.startsWith('/papers/import') && route.query.mode === 'edit') return '试卷库　/　修改试卷'
  if (route.path.startsWith('/questions/create') && route.query.mode === 'edit') return '习题库 / 编辑习题库'
  if (route.path.startsWith('/questions/create')) return '习题库 / 新建习题库'
  return route.meta.title || '首页 / 学习概览'
})

watch(
  () => route.query.subject,
  value => {
    const subject = String(value || 'calculus')
    statisticsSubject.value = ['calculus', 'linear-algebra', 'probability'].includes(subject) ? subject : 'calculus'
    practiceQuestionSubject.value = ['calculus', 'linear-algebra', 'probability'].includes(subject) ? subject : 'calculus'
  },
  { immediate: true }
)

watch(
  () => route.query.paperSubject,
  value => {
    const subject = String(value || 'calculus')
    paperPracticeSubject.value = ['calculus', 'linear-algebra', 'probability'].includes(subject) ? subject : 'calculus'
  },
  { immediate: true }
)

function changePracticeMode(value: string) {
  const subject = value === 'paper' ? undefined : practiceQuestionSubject.value
  router.push({ name: 'practice', query: { mode: value, subject } })
}

function changePracticeSubject(value: string) {
  router.replace({ query: { ...route.query, subject: value === 'calculus' ? undefined : value } })
}

function changeStatisticsSubject(value: string) {
  router.replace({ query: { ...route.query, subject: value === 'calculus' ? undefined : value } })
}

function changePaperSubject(value: string) {
  router.replace({ query: { ...route.query, paperSubject: value === 'calculus' ? undefined : value } })
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

.statistics-filters {
  display: flex;
  align-items: center;
  gap: 20px;
  flex: 1;
}

.statistics-filter {
  display: flex;
  align-items: center;
  gap: 10px;
}

.paper-header-filters {
  display: flex;
  align-items: center;
  gap: 34px;
  flex: 1;
}

.paper-header-filter {
  display: flex;
  align-items: center;
  gap: 12px;
}

.paper-header-select {
  flex: 0 0 auto;
}

.paper-exam-select {
  width: 180px;
}

.paper-practice-select {
  width: 180px;
}

.statistics-select {
  flex: 0 0 auto;
}

.exam-select {
  width: 136px;
}

.practice-subject-select {
  width: 132px;
}

.statistics-select :deep(.el-select__wrapper) {
  min-height: 40px;
  padding: 0 13px;
  border-radius: 7px;
  box-shadow: 0 0 0 1px var(--line) inset;
}

.paper-header-select :deep(.el-select__wrapper) {
  min-height: 44px;
  padding: 0 16px;
  border-radius: 8px;
  box-shadow: 0 0 0 1px #dbe3f2 inset;
}

.statistics-select :deep(.el-select__selected-item) {
  color: var(--ink);
  font-size: 14px;
  font-weight: 700;
}

.paper-header-select :deep(.el-select__selected-item) {
  color: var(--ink);
  font-size: 15px;
  font-weight: 800;
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

.practice-question-subject-select {
  width: 132px;
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
  margin-left: auto;
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

.statistics-filters + h1,
.header:has(.statistics-filters) h1 {
  display: none;
}

.header:has(.statistics-filters) .search {
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
