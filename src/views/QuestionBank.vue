<template>
  <section class="question-bank">
    <div class="stat-grid">
      <article v-for="(item, index) in questionStats" :key="item.label" class="panel stat-card">
        <span class="stat-symbol" :class="`tone-${index}`">{{ statSymbols[index] }}</span>
        <div>
          <p>{{ item.label }}</p>
          <strong :class="`tone-text-${index}`">{{ item.value }} <em>{{ item.unit }}</em></strong>
          <span :class="{ success: item.sub.includes('+') }">{{ item.sub }}</span>
        </div>
      </article>
    </div>

    <div class="filter-bar panel">
      <el-input
        v-model="searchKeyword"
        class="search-input"
        clearable
        placeholder="搜索题目内容（支持题号、关键词）"
        :prefix-icon="Search"
      />
      <el-select v-model="selectedType" placeholder="全部题型">
        <el-option label="全部题型" value="" />
        <el-option v-for="item in typeOptions" :key="item" :label="item" :value="item" />
      </el-select>
      <el-select v-model="selectedDifficulty" placeholder="全部难度">
        <el-option label="全部难度" value="" />
        <el-option v-for="item in difficultyOptions" :key="item" :label="item" :value="item" />
      </el-select>
      <el-select v-model="selectedTag" filterable clearable placeholder="全部标签">
        <el-option label="全部标签" value="" />
        <el-option v-for="item in tagOptions" :key="item" :label="item" :value="item" />
      </el-select>
      <el-button :icon="Delete" :disabled="!selectedVisibleCount" @click="confirmBatchDelete">
        批量删除
      </el-button>
      <el-button :icon="Upload" @click="goImport">导入题目</el-button>
      <el-button type="primary" :icon="Plus">添加题目</el-button>
    </div>

    <div class="main-grid">
      <aside class="panel chapter-panel">
        <h2>章节目录</h2>
        <p>共 15 章，532 个知识点</p>
        <div class="chapter-list">
          <div v-for="chapter in chapters" :key="chapter.title" class="chapter-block">
            <button
              class="chapter-head"
              :class="{ active: selectedChapterId === chapter.id }"
              type="button"
              @click="selectChapter(chapter.id)"
            >
              <el-icon class="expand-icon" @click.stop="toggleChapter(chapter.id)">
                <ArrowDown v-if="isExpanded(chapter.id)" />
                <ArrowRight v-else />
              </el-icon>
              <strong>{{ chapter.title }}</strong>
              <span class="count">{{ getChapterQuestionCount(chapter.id) }}</span>
            </button>
            <div v-if="chapter.children && isExpanded(chapter.id)" class="chapter-children">
              <button
                v-for="child in chapter.children"
                :key="child.name"
                class="child-row"
                :class="{ active: selectedChapterId === child.id }"
                type="button"
                @click="selectChapter(child.id)"
              >
                <span>{{ child.name }}</span>
                <em>{{ getChapterQuestionCount(child.id) }}</em>
              </button>
            </div>
          </div>
        </div>
        <footer>共 15 章</footer>
      </aside>

      <section class="panel question-panel">
        <div class="question-head">
          <div>
            <h2>{{ selectedChapterTitle }}</h2>
          </div>
        </div>

        <div class="table-head">
          <span class="select-cell">
            <el-checkbox
              :model-value="allVisibleSelected"
              :indeterminate="partiallySelected"
              :disabled="!filteredQuestionRows.length"
              aria-label="选择当前列表全部题目"
              @change="toggleVisibleSelection"
            />
          </span>
          <span>题目</span>
          <span>题型</span>
          <span>难度</span>
          <span>正确率</span>
          <span>操作</span>
        </div>

        <article v-for="row in filteredQuestionRows" :key="row.no" class="question-row">
          <div class="select-cell">
            <el-checkbox
              :model-value="selectedQuestionNos.includes(row.no)"
              :aria-label="`选择第 ${row.no} 题`"
              @change="(checked: string | number | boolean) => toggleQuestionSelection(row.no, Boolean(checked))"
            />
          </div>
          <div class="question-content">
            <div class="stem">
              <span class="tag-soft">{{ row.tag }}</span>
              <strong v-html="renderLatex(row.latexStem ?? row.stem)"></strong>
            </div>
            <div v-if="row.options" class="options">
              <span v-for="option in row.options" :key="option" v-html="renderLatex(option)"></span>
            </div>
            <div class="point-tags">
              <span>考点标签：</span>
              <el-tag v-for="tag in row.pointTags" :key="tag" size="small" effect="light">{{ tag }}</el-tag>
            </div>
          </div>
          <div class="type">{{ row.type }}</div>
          <div class="difficulty">
            <el-tag :type="row.difficultyType" effect="light">{{ row.difficulty }}</el-tag>
          </div>
          <div class="rate">{{ row.rate }}</div>
          <div class="actions">
            <button type="button" class="icon-action" title="收藏" @click="toggleFavorite(row.no)">
              <el-icon :class="{ favored: row.favored }"><StarFilled v-if="row.favored" /><Star v-else /></el-icon>
            </button>
            <button type="button" class="icon-action" title="编辑" @click="editQuestion(row.no)">
              <el-icon><EditPen /></el-icon>
            </button>
            <button type="button" class="icon-action danger-action" title="删除" @click="confirmDeleteQuestion(row.no)">
              <el-icon><Delete /></el-icon>
            </button>
          </div>
        </article>
      </section>
    </div>

    <div class="pagination">
      <div class="page-summary">
        <span>共 {{ selectedChapterCount }} 题</span>
        <el-select model-value="20 条/页" class="page-size">
          <el-option label="20 条/页" value="20 条/页" />
        </el-select>
      </div>
      <el-pagination layout="prev, pager, next" :total="selectedChapterCount" :page-size="20" />
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRouter } from 'vue-router'
import katex from 'katex'
import {
  ArrowDown,
  ArrowRight,
  Delete,
  EditPen,
  Plus,
  Search,
  Star,
  StarFilled,
  Upload
} from '@element-plus/icons-vue'
import { chapters, questionRows, questionStats } from '@/mock/questions'

const router = useRouter()
const selectedChapterId = ref('1.1')
const expandedChapterIds = ref(new Set(['chapter-1']))
const searchKeyword = ref('')
const selectedType = ref('')
const selectedDifficulty = ref('')
const selectedTag = ref('')
const selectedQuestionNos = ref<number[]>([])
const localQuestionRows = ref(questionRows.map((row) => ({ ...row })))

const statSymbols = ['Σ', '◆', '✓', '★', '!']
const typeOptions = ['单选题', '多选题', '填空题', '计算题', '应用题', '证明题']
const difficultyOptions = ['易', '中', '难']
const tagOptions = computed(() =>
  Array.from(new Set(localQuestionRows.value.flatMap((row) => row.pointTags))).sort((a, b) =>
    a.localeCompare(b, 'zh-CN')
  )
)

const flatChapters = computed(() =>
  chapters.flatMap((chapter) => [
    { id: chapter.id, title: chapter.title, count: chapter.count },
    ...(chapter.children?.map((child) => ({
      id: child.id,
      title: child.name,
      count: child.count
    })) ?? [])
  ])
)

const selectedChapter = computed(
  () => flatChapters.value.find((chapter) => chapter.id === selectedChapterId.value) ?? flatChapters.value[0]
)

const selectedChapterTitle = computed(() => selectedChapter.value?.title ?? '1.1  函数')
const selectedChapterCount = computed(() => filteredQuestionRows.value.length)
const selectedChapterFilterIds = computed(() => {
  const chapter = chapters.find((item) => item.id === selectedChapterId.value)
  return chapter?.children?.map((child) => child.id) ?? [selectedChapterId.value]
})

const chapterFilterMap = computed(() => {
  const map = new Map<string, string[]>()
  chapters.forEach((chapter) => {
    map.set(chapter.id, chapter.children?.map((child) => child.id) ?? [chapter.id])
    chapter.children?.forEach((child) => {
      map.set(child.id, [child.id])
    })
  })
  return map
})

const filteredQuestionRows = computed(() => {
  const ids = selectedChapterFilterIds.value
  const keyword = searchKeyword.value.trim().toLowerCase()
  return localQuestionRows.value.filter((row) => {
    const matchChapter = ids.includes(row.chapterId)
    const matchType = !selectedType.value || row.tag === selectedType.value || row.type === selectedType.value
    const matchDifficulty = !selectedDifficulty.value || row.difficulty === selectedDifficulty.value
    const matchTag = !selectedTag.value || row.pointTags.includes(selectedTag.value)
    const searchable = [
      row.no,
      row.stem,
      row.latexStem,
      row.tag,
      row.type,
      row.difficulty,
      row.rate,
      row.options?.join(' '),
      row.pointTags.join(' ')
    ]
      .filter(Boolean)
      .join(' ')
      .toLowerCase()
    const matchKeyword = !keyword || searchable.includes(keyword)
    return matchChapter && matchType && matchDifficulty && matchTag && matchKeyword
  })
})

const visibleQuestionNos = computed(() => filteredQuestionRows.value.map((row) => row.no))
const selectedVisibleCount = computed(
  () => visibleQuestionNos.value.filter((no) => selectedQuestionNos.value.includes(no)).length
)
const allVisibleSelected = computed(
  () => visibleQuestionNos.value.length > 0 && selectedVisibleCount.value === visibleQuestionNos.value.length
)
const partiallySelected = computed(
  () => selectedVisibleCount.value > 0 && selectedVisibleCount.value < visibleQuestionNos.value.length
)

function goImport() {
  router.push('/questions/import')
}

function selectChapter(chapterId: string) {
  selectedChapterId.value = chapterId
}

function isExpanded(chapterId: string) {
  return expandedChapterIds.value.has(chapterId)
}

function toggleChapter(chapterId: string) {
  const next = new Set(expandedChapterIds.value)
  if (next.has(chapterId)) {
    next.delete(chapterId)
  } else {
    next.add(chapterId)
  }
  expandedChapterIds.value = next
}

function getChapterQuestionCount(chapterId: string) {
  const ids = chapterFilterMap.value.get(chapterId) ?? [chapterId]
  return localQuestionRows.value.filter((row) => ids.includes(row.chapterId)).length
}

function renderLatex(text: string) {
  return text.replace(/\$(.+?)\$/g, (_, formula: string) =>
    katex.renderToString(formula, {
      throwOnError: false,
      displayMode: false
    })
  )
}

function toggleQuestionSelection(no: number, checked: boolean) {
  if (checked) {
    selectedQuestionNos.value = Array.from(new Set([...selectedQuestionNos.value, no]))
    return
  }
  selectedQuestionNos.value = selectedQuestionNos.value.filter((item) => item !== no)
}

function toggleVisibleSelection(checked: string | number | boolean) {
  const visible = visibleQuestionNos.value
  if (Boolean(checked)) {
    selectedQuestionNos.value = Array.from(new Set([...selectedQuestionNos.value, ...visible]))
    return
  }
  selectedQuestionNos.value = selectedQuestionNos.value.filter((no) => !visible.includes(no))
}

function toggleFavorite(no: number) {
  const row = localQuestionRows.value.find((item) => item.no === no)
  if (!row) return
  row.favored = !row.favored
  ElMessage.success(row.favored ? '已收藏题目' : '已取消收藏')
}

function editQuestion(no: number) {
  ElMessage.info(`编辑第 ${no} 题`)
}

async function confirmDeleteQuestion(no: number) {
  try {
    await ElMessageBox.confirm(`确认删除第 ${no} 题吗？删除后不可恢复。`, '删除题目', {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    deleteQuestion(no)
  } catch {
    ElMessage.info('已取消删除')
  }
}

async function confirmBatchDelete() {
  const selectedSet = new Set(selectedQuestionNos.value)
  const deleteNos = visibleQuestionNos.value.filter((no) => selectedSet.has(no))
  if (!deleteNos.length) {
    ElMessage.warning('请先勾选要删除的题目')
    return
  }

  try {
    await ElMessageBox.confirm(`确认删除已勾选的 ${deleteNos.length} 道题目吗？删除后不可恢复。`, '批量删除题目', {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    localQuestionRows.value = localQuestionRows.value.filter((item) => !deleteNos.includes(item.no))
    selectedQuestionNos.value = selectedQuestionNos.value.filter((no) => !deleteNos.includes(no))
    ElMessage.success(`已删除 ${deleteNos.length} 道题目`)
  } catch {
    ElMessage.info('已取消删除')
  }
}

function deleteQuestion(no: number) {
  localQuestionRows.value = localQuestionRows.value.filter((item) => item.no !== no)
  selectedQuestionNos.value = selectedQuestionNos.value.filter((item) => item !== no)
  ElMessage.success(`已删除第 ${no} 题`)
}
</script>

<style scoped lang="scss">
.question-bank {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.stat-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 14px;
}

.stat-card {
  display: flex;
  gap: 16px;
  align-items: center;
  height: 132px;
  padding: 26px 30px;
}

.stat-symbol {
  display: inline-flex;
  flex: 0 0 42px;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  font-size: 22px;
  font-weight: 900;
  border-radius: 12px;
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
  font-size: 28px;
  font-weight: 900;
}

.stat-card em {
  color: currentColor;
  font-size: 13px;
  font-style: normal;
}

.tone-0,
.tone-0 + div .tone-text-0 {
  color: #1f53ff;
}

.tone-0 {
  background: #edf2ff;
}

.tone-1,
.tone-1 + div .tone-text-1 {
  color: #18b979;
}

.tone-1 {
  background: #e9f8f1;
}

.tone-2,
.tone-2 + div .tone-text-2 {
  color: #ff9b21;
}

.tone-2 {
  background: #fff3e2;
}

.tone-3,
.tone-3 + div .tone-text-3 {
  color: #8e5bff;
}

.tone-3 {
  background: #f1ebff;
}

.tone-4,
.tone-4 + div .tone-text-4 {
  color: #ff5b63;
}

.tone-4 {
  background: #ffeff1;
}

.filter-bar {
  display: grid;
  grid-template-columns: minmax(300px, 1fr) 130px 120px minmax(180px, 220px) 116px 116px 116px;
  gap: 12px;
  align-items: center;
  padding: 14px 12px;
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
  width: 100%;
  min-height: 34px;
  padding: 0;
  color: var(--ink);
  font: inherit;
  font-weight: 800;
  text-align: left;
  background: transparent;
  border: 0;
  border-radius: 7px;
}

.chapter-head:hover,
.chapter-head.active {
  color: var(--primary);
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
  width: 100%;
  min-height: 34px;
  padding: 0 8px 0 28px;
  color: var(--text);
  font: inherit;
  text-align: left;
  background: transparent;
  border: 0;
  border-radius: 7px;
}

.child-row:hover,
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
  padding: 16px 20px 10px;
}

.table-head {
  display: grid;
  grid-template-columns: 42px minmax(360px, 1fr) 120px 110px 110px 150px;
  align-items: center;
  padding: 12px 20px;
  color: var(--muted);
  background: #fbfcff;
  border-top: 1px solid var(--line);
  border-bottom: 1px solid var(--line);
  font-weight: 700;
}

.question-row {
  display: grid;
  grid-template-columns: 42px minmax(360px, 1fr) 120px 110px 110px 150px;
  align-items: center;
  min-height: 112px;
  padding: 0 20px;
  border-bottom: 1px solid var(--line);
}

.select-cell {
  display: flex;
  align-items: center;
  justify-content: center;
}

.stem {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--ink);
}

.stem strong {
  font-weight: 700;
  line-height: 1.8;
}

.options {
  display: flex;
  gap: 48px;
  margin-top: 16px;
  color: var(--ink);
  font-weight: 700;
}

.point-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  align-items: center;
  margin-top: 12px;
  color: var(--muted);
  font-size: 13px;
}

.type,
.rate {
  color: var(--ink);
  font-weight: 700;
}

.difficulty,
.type,
.rate {
  display: flex;
  align-items: center;
  min-height: 34px;
}

.actions {
  display: flex;
  gap: 12px;
  align-items: center;
  color: #66739f;
  font-size: 20px;
}

.icon-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  padding: 0;
  color: #66739f;
  font: inherit;
  background: transparent;
  border: 0;
  border-radius: 6px;
  transition: 0.16s ease;
}

.icon-action:hover {
  color: var(--primary);
  background: var(--primary-soft);
}

.danger-action:hover {
  color: var(--red);
  background: rgba(255, 91, 99, 0.1);
}

.favored {
  color: #f5a400;
}

.pagination {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 18px;
  color: var(--text);
}

.page-summary {
  display: flex;
  align-items: center;
  gap: 12px;
}

.page-size {
  width: 112px;
}
</style>
