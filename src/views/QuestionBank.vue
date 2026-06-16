<template>
  <section class="question-bank">
    <div class="toolbar">
      <div></div>
      <el-button :icon="Upload" @click="goImport">导入题目</el-button>
      <el-button type="primary" :icon="Plus">添加题目</el-button>
    </div>

    <div class="stat-grid">
      <article v-for="item in questionStats" :key="item.label" class="panel stat-card">
        <p>{{ item.label }}</p>
        <strong>{{ item.value }} <em>{{ item.unit }}</em></strong>
        <span :class="{ success: item.sub.includes('+') }">{{ item.sub }}</span>
      </article>
    </div>

    <div class="filter-bar panel">
      <el-input class="search-input" placeholder="搜索题目内容（支持题号、关键词）" :prefix-icon="Search" />
      <el-select model-value="高等数学（第七版）上册">
        <el-option label="高等数学（第七版）上册" value="高等数学（第七版）上册" />
      </el-select>
      <el-select model-value="全部章节">
        <el-option label="全部章节" value="全部章节" />
      </el-select>
      <el-select model-value="全部题型">
        <el-option label="全部题型" value="全部题型" />
      </el-select>
      <el-select model-value="全部难度">
        <el-option label="全部难度" value="全部难度" />
      </el-select>
      <el-select model-value="全部标签">
        <el-option label="全部标签" value="全部标签" />
      </el-select>
      <el-button :icon="Filter">更多筛选</el-button>
      <div class="view-switch">
        <el-icon><Operation /></el-icon>
        <span class="active"><List /></span>
      </div>
    </div>

    <div class="main-grid">
      <aside class="panel chapter-panel">
        <h2>章节目录</h2>
        <p>共 15 章，532 个知识点</p>
        <div class="chapter-list">
          <div v-for="chapter in chapters" :key="chapter.title" class="chapter-block">
            <div class="chapter-head">
              <el-icon><ArrowDown v-if="chapter.open" /><ArrowRight v-else /></el-icon>
              <strong>{{ chapter.title }}</strong>
              <el-icon class="collapse"><ArrowUp v-if="chapter.open" /></el-icon>
              <span v-if="chapter.count" class="count">{{ chapter.count }}</span>
            </div>
            <div v-if="chapter.children" class="chapter-children">
              <div
                v-for="child in chapter.children"
                :key="child.name"
                class="child-row"
                :class="{ active: child.active }"
              >
                <span>{{ child.name }}</span>
                <em>{{ child.count }}</em>
              </div>
            </div>
          </div>
        </div>
        <footer>共 15 章</footer>
      </aside>

      <section class="panel question-panel">
        <div class="question-head">
          <div>
            <h2>1.1　函数</h2>
            <p>共 256 题</p>
          </div>
          <div class="sort">
            <span>默认排序</span>
            <el-icon><Sort /></el-icon>
            <el-icon><Setting /></el-icon>
          </div>
        </div>

        <div class="table-head">
          <span>题目</span>
          <span>题型</span>
          <span>难度</span>
          <span>正确率</span>
          <span>操作</span>
        </div>

        <article v-for="row in questionRows" :key="row.no" class="question-row">
          <div class="no">{{ row.no }}</div>
          <div class="question-content">
            <div class="stem">
              <span class="tag-soft">{{ row.tag }}</span>
              <strong>{{ row.stem }}</strong>
            </div>
            <div v-if="row.options" class="options">
              <span v-for="option in row.options" :key="option">{{ option }}</span>
            </div>
          </div>
          <div class="type">{{ row.type }}</div>
          <el-tag :type="row.difficultyType" effect="light">{{ row.difficulty }}</el-tag>
          <div class="rate">{{ row.rate }}</div>
          <div class="actions">
            <el-icon :class="{ favored: row.favored }"><StarFilled v-if="row.favored" /><Star v-else /></el-icon>
            <el-icon><EditPen /></el-icon>
            <el-icon><MoreFilled /></el-icon>
          </div>
        </article>
      </section>
    </div>

    <div class="pagination">
      <span>共 256 题</span>
      <el-pagination layout="prev, pager, next" :total="256" :page-size="20" />
      <el-select model-value="20 条/页" class="page-size">
        <el-option label="20 条/页" value="20 条/页" />
      </el-select>
    </div>
  </section>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'
import {
  ArrowDown,
  ArrowRight,
  ArrowUp,
  EditPen,
  Filter,
  List,
  MoreFilled,
  Operation,
  Plus,
  Search,
  Setting,
  Sort,
  Star,
  StarFilled,
  Upload
} from '@element-plus/icons-vue'
import { chapters, questionRows, questionStats } from '@/mock/questions'

const router = useRouter()
function goImport() {
  router.push('/questions/import')
}
</script>

<style scoped lang="scss">
.question-bank {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.toolbar {
  display: grid;
  grid-template-columns: 1fr auto auto;
  gap: 12px;
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 14px;
}

.stat-card {
  height: 132px;
  padding: 26px 30px;
}

.stat-card p,
.stat-card span {
  margin: 0;
  color: var(--muted);
  font-size: 14px;
}

.stat-card strong {
  display: block;
  margin: 10px 0 8px;
  color: var(--ink);
  font-size: 28px;
  font-weight: 900;
}

.stat-card em {
  color: var(--text);
  font-size: 13px;
  font-style: normal;
}

.filter-bar {
  display: grid;
  grid-template-columns: 300px 210px 120px 120px 120px 120px auto 86px;
  gap: 12px;
  align-items: center;
  padding: 14px 12px;
}

.view-switch {
  display: flex;
  justify-content: flex-end;
  gap: 16px;
  color: var(--muted);
  font-size: 22px;
}

.view-switch .active {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  color: var(--primary);
  border: 1px solid #b6c5ff;
  border-radius: 8px;
}

.main-grid {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 16px;
}

.chapter-panel {
  min-height: 580px;
  padding: 20px 18px;
}

.chapter-panel h2,
.question-head h2 {
  margin: 0;
  color: var(--ink);
  font-size: 18px;
  font-weight: 850;
}

.chapter-panel p,
.question-head p {
  margin: 8px 0 20px;
  color: var(--muted);
}

.chapter-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.chapter-head {
  display: flex;
  align-items: center;
  gap: 10px;
  min-height: 34px;
  color: var(--ink);
  font-weight: 800;
}

.chapter-head .collapse {
  margin-left: auto;
}

.count,
.child-row em {
  margin-left: auto;
  padding: 3px 8px;
  color: var(--text);
  font-style: normal;
  background: #f0f3fb;
  border-radius: 8px;
}

.chapter-children {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-top: 6px;
}

.child-row {
  display: flex;
  align-items: center;
  min-height: 34px;
  padding: 0 8px 0 28px;
  color: var(--text);
  border-radius: 7px;
}

.child-row.active {
  color: var(--primary);
  background: var(--primary-soft);
}

.chapter-panel footer {
  margin-top: 28px;
  color: var(--muted);
}

.question-panel {
  overflow: hidden;
}

.question-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 20px 12px;
}

.sort {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--text);
  font-weight: 700;
}

.table-head {
  display: grid;
  grid-template-columns: 1fr 120px 110px 110px 150px;
  padding: 14px 56px;
  color: var(--muted);
  background: #fbfcff;
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  font-weight: 700;
}

.question-row {
  display: grid;
  grid-template-columns: 42px 1fr 120px 110px 110px 150px;
  align-items: center;
  min-height: 88px;
  padding: 0 20px;
  border-bottom: 1px solid var(--line);
}

.no {
  color: var(--ink);
  font-weight: 800;
}

.stem {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--ink);
}

.stem strong {
  font-weight: 700;
}

.options {
  display: flex;
  gap: 48px;
  margin-top: 16px;
  color: var(--ink);
  font-weight: 700;
}

.type,
.rate {
  color: var(--ink);
  font-weight: 700;
}

.actions {
  display: flex;
  gap: 20px;
  align-items: center;
  color: #66739f;
  font-size: 20px;
}

.favored {
  color: #f5a400;
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 18px;
  color: var(--text);
}

.page-size {
  width: 112px;
}
</style>
