<template>
  <section class="library-page">
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
        v-model="keyword"
        class="search-input"
        clearable
        placeholder="搜索习题库名称、作者、来源..."
        :prefix-icon="Search"
      />
      <el-select v-model="filters.subject" placeholder="全部科目">
        <el-option label="全部科目" value="" />
        <el-option label="高等数学" value="高等数学" />
        <el-option label="线性代数" value="线性代数" />
        <el-option label="概率论与数理统计" value="概率论与数理统计" />
        <el-option label="数学分析" value="数学分析" />
      </el-select>
      <el-select v-model="filters.source" placeholder="全部来源">
        <el-option label="全部来源" value="" />
        <el-option label="教材配套" value="教材配套" />
        <el-option label="教辅资料" value="教辅资料" />
        <el-option label="真题汇编" value="真题汇编" />
      </el-select>
      <el-select v-model="filters.difficulty" placeholder="全部难度">
        <el-option label="全部难度" value="" />
        <el-option label="简单" value="简单" />
        <el-option label="中等" value="中等" />
        <el-option label="困难" value="困难" />
      </el-select>
      <el-select v-model="filters.tag" placeholder="全部标签">
        <el-option label="全部标签" value="" />
        <el-option v-for="tag in tagOptions" :key="tag" :label="tag" :value="tag" />
      </el-select>
      <el-button @click="resetFilters">重置</el-button>
      <el-button type="primary" :icon="Plus" @click="createLibrary">新建习题库</el-button>
    </div>

    <section class="panel library-table">
      <div class="table-head">
        <span>习题库名称</span>
        <span>科目</span>
        <span>来源</span>
        <span>题目数量</span>
        <span>知识点数量</span>
        <span>难度</span>
        <span>标签</span>
        <span>创建时间</span>
        <span>操作</span>
      </div>

      <article v-for="item in filteredLibraries" :key="item.id" class="table-row">
        <div class="library-info">
          <div class="cover" :class="`cover-${item.tone}`">
            <span>{{ item.coverTitle }}</span>
          </div>
          <div>
            <h3>{{ item.name }}</h3>
            <p>{{ item.author }}</p>
            <el-tag size="small" effect="light">{{ item.mode }}</el-tag>
          </div>
        </div>
        <strong>{{ item.subject }}</strong>
        <strong>{{ item.source }}</strong>
        <span>{{ item.questionCount.toLocaleString() }}</span>
        <span>{{ item.pointCount }}</span>
        <el-tag :type="item.difficultyType" effect="light">{{ item.difficulty }}</el-tag>
        <div class="tag-list">
          <el-tag v-for="tag in item.tags.slice(0, 2)" :key="tag" size="small" effect="plain">{{ tag }}</el-tag>
          <span v-if="item.tags.length > 2" class="more-tag">+{{ item.tags.length - 2 }}</span>
        </div>
        <span>{{ item.createdAt }}</span>
        <div class="actions">
          <button type="button" class="icon-action" title="详情" @click="goDetail(item.id)">
            <el-icon><FolderOpened /></el-icon>
          </button>
          <button type="button" class="icon-action" title="编辑" @click="editLibrary(item.name)">
            <el-icon><EditPen /></el-icon>
          </button>
          <button type="button" class="icon-action danger-action" title="删除" @click="deleteLibrary(item.name)">
            <el-icon><Delete /></el-icon>
          </button>
        </div>
      </article>

      <footer class="table-footer">
        <span>共 {{ filteredLibraries.length }} 个习题库</span>
        <div class="pager">
          <el-select model-value="10条/页" class="page-size">
            <el-option label="10条/页" value="10条/页" />
          </el-select>
          <el-pagination layout="prev, pager, next, jumper" :page-size="10" :total="filteredLibraries.length" />
        </div>
      </footer>
    </section>
  </section>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { ElMessage } from 'element-plus'
import { Delete, EditPen, FolderOpened, Plus, Search } from '@element-plus/icons-vue'
import { useRouter } from 'vue-router'
import { questionStats } from '@/mock/questions'

const router = useRouter()
const keyword = ref('')
const filters = reactive({
  subject: '',
  source: '',
  difficulty: '',
  tag: ''
})

const statSymbols = ['Σ', '◆', '✓', '★', '!']
const libraries = ref([
  {
    id: 1,
    name: '高等数学习题全解（同济第七版）',
    author: '同济大学数学系 编',
    subject: '高等数学',
    source: '教材配套',
    questionCount: 2856,
    pointCount: 98,
    difficulty: '中等',
    difficultyType: 'warning',
    tags: ['同济版', '基础题', '同步练习', '考研'],
    createdAt: '2024-05-12 10:23',
    mode: '同步练习',
    tone: 'blue',
    coverTitle: '高等数学'
  },
  {
    id: 2,
    name: '线性代数习题精选',
    author: '李永乐 编',
    subject: '线性代数',
    source: '教辅资料',
    questionCount: 1256,
    pointCount: 68,
    difficulty: '中等',
    difficultyType: 'warning',
    tags: ['考研', '真题', '专题训练'],
    createdAt: '2024-05-10 15:30',
    mode: '专题训练',
    tone: 'green',
    coverTitle: '线性代数'
  },
  {
    id: 3,
    name: '概率论与数理统计习题集',
    author: '盛骤 谢式千 潘承毅 编',
    subject: '概率论与数理统计',
    source: '教材配套',
    questionCount: 1852,
    pointCount: 72,
    difficulty: '中等',
    difficultyType: 'warning',
    tags: ['浙大版', '基础题', '同步练习', '概率'],
    createdAt: '2024-05-08 09:15',
    mode: '同步练习',
    tone: 'purple',
    coverTitle: '概率统计'
  },
  {
    id: 4,
    name: '数学分析习题精讲精练',
    author: '华东师范大学数学系 编',
    subject: '数学分析',
    source: '教辅资料',
    questionCount: 2136,
    pointCount: 85,
    difficulty: '困难',
    difficultyType: 'danger',
    tags: ['考研', '提高题', '专题训练'],
    createdAt: '2024-04-28 11:20',
    mode: '专题训练',
    tone: 'orange',
    coverTitle: '数学分析'
  },
  {
    id: 5,
    name: '高等代数习题精解',
    author: '吴赣昌 编',
    subject: '高等代数',
    source: '教材配套',
    questionCount: 1048,
    pointCount: 45,
    difficulty: '简单',
    difficultyType: 'success',
    tags: ['北大版', '基础题'],
    createdAt: '2024-04-20 16:40',
    mode: '同步练习',
    tone: 'teal',
    coverTitle: '高等代数'
  },
  {
    id: 6,
    name: '历年考研数学真题分类汇编（数学一）',
    author: '张宇 编',
    subject: '高等数学',
    source: '真题汇编',
    questionCount: 3420,
    pointCount: 120,
    difficulty: '困难',
    difficultyType: 'danger',
    tags: ['真题', '考研', '分类训练', '数学一'],
    createdAt: '2024-04-15 20:18',
    mode: '真题汇编',
    tone: 'blue',
    coverTitle: '真题汇编'
  }
])

const tagOptions = computed(() => Array.from(new Set(libraries.value.flatMap((item) => item.tags))))

const filteredLibraries = computed(() => {
  const text = keyword.value.trim().toLowerCase()
  return libraries.value.filter((item) => {
    const searchable = [item.name, item.author, item.subject, item.source, item.difficulty, item.tags.join(' ')]
      .join(' ')
      .toLowerCase()
    return (
      (!text || searchable.includes(text)) &&
      (!filters.subject || item.subject === filters.subject) &&
      (!filters.source || item.source === filters.source) &&
      (!filters.difficulty || item.difficulty === filters.difficulty) &&
      (!filters.tag || item.tags.includes(filters.tag))
    )
  })
})

function resetFilters() {
  keyword.value = ''
  filters.subject = ''
  filters.source = ''
  filters.difficulty = ''
  filters.tag = ''
}

function goDetail(id: number) {
  router.push({ name: 'questionDetail', query: { libraryId: id } })
}

function createLibrary() {
  router.push({ name: 'questionLibraryCreate' })
}

function editLibrary(name: string) {
  ElMessage.info(`编辑：${name}`)
}

function deleteLibrary(name: string) {
  ElMessage.warning(`删除：${name}`)
}
</script>

<style scoped lang="scss">
.library-page {
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
  color: #ff7a00;
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
  color: #ff3d68;
}

.tone-4 {
  background: #ffeff1;
}

.filter-bar {
  display: grid;
  grid-template-columns: minmax(360px, 1fr) repeat(4, 160px) 78px 138px;
  gap: 12px;
  align-items: center;
  padding: 14px 16px;
}

.library-table {
  overflow: hidden;
}

.table-head,
.table-row {
  display: grid;
  grid-template-columns: minmax(320px, 1.9fr) 130px 130px 110px 120px 90px minmax(170px, 1fr) 170px 150px;
  gap: 12px;
  align-items: center;
}

.table-head {
  min-height: 54px;
  padding: 0 22px;
  color: var(--muted);
  font-size: 14px;
  font-weight: 800;
  background: #fbfcff;
  border-bottom: 1px solid var(--line);
}

.table-row {
  min-height: 104px;
  padding: 16px 22px;
  color: var(--ink);
  border-bottom: 1px solid var(--line);
}

.table-row > strong {
  font-size: 14px;
}

.library-info {
  display: flex;
  align-items: center;
  gap: 14px;
  min-width: 0;
}

.cover {
  display: flex;
  flex: 0 0 52px;
  align-items: flex-end;
  justify-content: center;
  width: 52px;
  height: 68px;
  padding: 8px 5px;
  color: #fff;
  font-size: 11px;
  font-weight: 900;
  line-height: 1.2;
  text-align: center;
  border-radius: 4px;
  box-shadow: 0 10px 18px rgba(31, 83, 255, 0.12);
}

.cover-blue {
  background: linear-gradient(150deg, #0d54d9, #55a0ff);
}

.cover-green,
.cover-teal {
  background: linear-gradient(150deg, #0aa58c, #30d5a7);
}

.cover-purple {
  background: linear-gradient(150deg, #7537d9, #b67cff);
}

.cover-orange {
  background: linear-gradient(150deg, #f06a00, #ffb45c);
}

.library-info h3 {
  margin: 0 0 6px;
  color: var(--ink);
  font-size: 16px;
  font-weight: 850;
}

.library-info p {
  margin: 0 0 7px;
  color: var(--muted);
  font-size: 13px;
}

.tag-list,
.actions,
.table-footer,
.pager {
  display: flex;
  align-items: center;
}

.tag-list {
  gap: 7px;
  flex-wrap: wrap;
}

.more-tag {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 28px;
  height: 22px;
  padding: 0 7px;
  color: var(--text);
  font-size: 12px;
  font-weight: 800;
  background: #eef2fb;
  border-radius: 12px;
}

.actions {
  gap: 10px;
  color: #65729c;
  font-size: 18px;
}

.icon-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  padding: 0;
  color: #65729c;
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

.table-footer {
  justify-content: space-between;
  min-height: 58px;
  padding: 0 22px;
  color: var(--text);
}

.pager {
  gap: 18px;
}

.page-size {
  width: 128px;
}
</style>
