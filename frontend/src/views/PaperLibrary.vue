<template>
  <section class="paper-page">
    <div class="summary-grid">
      <article v-for="card in summaryCards" :key="card.label" class="panel summary-card">
        <span class="summary-icon" :class="card.tone"><el-icon><component :is="card.icon" /></el-icon></span>
        <div>
          <p>{{ card.label }}</p>
          <strong>{{ card.value }} <small>{{ card.unit }}</small></strong>
          <template v-if="card.recent">
            <b>{{ card.recent }}</b>
            <em>今天 14:30</em>
          </template>
        </div>
      </article>
    </div>

    <div class="filters">
      <el-select v-model="filters.source" placeholder="全部来源"><el-option label="全部来源" value="" /><el-option label="自建" value="自建" /><el-option label="教育部考试中心" value="教育部考试中心" /></el-select>
      <el-select v-model="filters.year" placeholder="全部年份"><el-option label="全部年份" value="" /><el-option v-for="year in ['2024','2023','2022','2021','2020','2018']" :key="year" :label="year" :value="year" /></el-select>
      <el-select v-model="filters.difficulty" placeholder="全部难度"><el-option label="全部难度" value="" /><el-option label="简单" value="简单" /><el-option label="中等" value="中等" /><el-option label="较难" value="较难" /></el-select>
      <el-select v-model="filters.type" placeholder="全部类型"><el-option label="全部类型" value="" /><el-option label="真题" value="真题" /><el-option label="模拟卷" value="模拟卷" /></el-select>
      <el-select v-model="filters.favorite" placeholder="全部收藏"><el-option label="全部收藏" value="" /><el-option label="已收藏" value="favorite" /><el-option label="未收藏" value="normal" /></el-select>
      <el-input v-model="keyword" class="keyword-input" placeholder="请输入关键词" />
      <el-button @click="reset">重置</el-button>
      <el-button :icon="Delete" :disabled="!selectedPaperIds.length" @click="confirmBatchDelete">批量删除</el-button>
      <el-button type="primary" :icon="Plus" @click="startImport">导入试卷</el-button>
    </div>

    <section class="panel paper-table">
      <div class="paper-row paper-head">
        <span><el-checkbox :model-value="allVisibleSelected" :indeterminate="partiallySelected" @change="toggleAllVisible" /></span><span>试卷名称</span><span>来源 ↕</span><span>年份 ↕</span><span>题量 ↕</span><span>难度 ↕</span><span>正确率 ↕</span><span>练习进度 ↕</span><span>操作</span>
      </div>
      <div v-for="paper in filteredPapers" :key="paper.id" class="paper-row">
        <span><el-checkbox :model-value="selectedPaperIds.includes(paper.id)" @change="(checked: string | number | boolean) => togglePaper(paper.id, Boolean(checked))" /></span>
        <div class="paper-name">
          <button class="favorite-button" :class="{ favorite: paper.favorite }" :aria-label="paper.favorite ? '取消收藏' : '收藏试卷'" @click="toggleFavorite(paper)">
            <el-icon><StarFilled v-if="paper.favorite" /><Star v-else /></el-icon>
          </button>
          <strong>{{ paper.name }}</strong>
        </div>
        <strong>{{ paper.source }}</strong>
        <span>{{ paper.year }}</span>
        <span>{{ paper.count }}</span>
        <span><i class="difficulty" :class="paper.difficulty">{{ paper.difficulty }}</i></span>
        <span :class="accuracyClass(paper.accuracy)">{{ paper.accuracy || '-' }}<template v-if="paper.accuracy">%</template></span>
        <div class="progress-cell"><span>{{ paper.done }}/{{ paper.count }}</span><i><b :style="{ width: `${paper.done / paper.count * 100}%` }"></b></i></div>
        <div class="row-actions">
          <button @click="practice(paper.name)"><el-icon><VideoPlay /></el-icon>练习</button>
          <button @click="editPaper(paper)"><el-icon><EditPen /></el-icon>编辑</button>
          <button class="delete-action" @click="confirmDeletePaper(paper.id, paper.name)"><el-icon><Delete /></el-icon>删除</button>
        </div>
      </div>
      <footer>
        <span>共 {{ filteredPapers.length }} 份试卷</span>
        <el-select model-value="10 条/页"><el-option label="10 条/页" value="10 条/页" /></el-select>
        <el-pagination v-model:current-page="page" layout="prev, pager, next" :total="filteredPapers.length" :page-size="10" />
      </footer>
    </section>
  </section>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Delete, Document, EditPen, Plus, Star, StarFilled, Tickets, VideoPlay } from '@element-plus/icons-vue'
import { usePaperImportStore } from '@/stores/paperImport'

const route = useRoute()
const router = useRouter()
const paperImportStore = usePaperImportStore()
const keyword = ref('')
const page = ref(1)
const selectedPaperIds = ref<number[]>([])
const filters = reactive({ source: '', year: '', difficulty: '', type: '', favorite: '' })
const papers = ref([
  ['高等数学模拟试卷（一）','高等数学','自建','2024',22,'中等',78,20,true,'blue'],
  ['线性代数真题（2018）','线性代数','教育部考试中心','2018',18,'中等',65,0,false,'green'],
  ['概率论与数理统计模拟卷','概率论与数理统计','自建','2024',20,'较难',0,0,false,'purple'],
  ['高等数学真题（2023）','高等数学','教育部考试中心','2023',22,'较难',72,22,false,'blue'],
  ['线性代数模拟试卷（二）','线性代数','自建','2024',18,'简单',0,0,false,'green'],
  ['概率论与数理统计真题（2022）','概率论与数理统计','教育部考试中心','2022',20,'中等',68,15,false,'purple'],
  ['高等数学模拟试卷（二）','高等数学','自建','2024',22,'中等',0,0,false,'blue'],
  ['线性代数真题（2021）','线性代数','教育部考试中心','2021',18,'较难',59,8,false,'green'],
  ['概率论与数理统计模拟卷（二）','概率论与数理统计','自建','2024',20,'简单',0,0,false,'purple'],
  ['高等数学真题（2020）','高等数学','教育部考试中心','2020',22,'较难',61,10,false,'blue']
].map(([name,subject,source,year,count,difficulty,accuracy,done,favorite,subjectTone], index) => ({
  id: index + 1, name, subject, source, year, count, difficulty, accuracy, done, favorite, subjectTone,
  type: String(name).includes('真题') ? '真题' : '模拟卷'
})) as Array<any>)
const totalPaperCount = computed(() => 118 + papers.value.length)
const summaryCards = computed(() => [
  { label: '全部试卷', value: totalPaperCount.value, unit: '份', icon: Document, tone: 'blue' },
  { label: '已练习', value: 45, unit: '份', icon: Tickets, tone: 'green' },
  { label: '收藏', value: 17 + papers.value.filter((paper) => paper.favorite).length, unit: '份', icon: Document, tone: 'orange' },
  { label: '最近练习', value: '', unit: '', icon: Tickets, tone: 'purple', recent: '高数模拟卷（2024）' }
])
const paperSubjectMap: Record<string, string> = {
  calculus: '高等数学',
  'linear-algebra': '线性代数',
  probability: '概率论与数理统计'
}
const selectedPaperSubject = computed(() => paperSubjectMap[String(route.query.paperSubject || 'calculus')] || '高等数学')

const filteredPapers = computed(() => papers.value.filter((paper) =>
  (!keyword.value || paper.name.includes(keyword.value)) &&
  paper.subject === selectedPaperSubject.value &&
  (!filters.source || paper.source === filters.source) &&
  (!filters.year || paper.year === filters.year) &&
  (!filters.difficulty || paper.difficulty === filters.difficulty) &&
  (!filters.type || paper.type === filters.type) &&
  (!filters.favorite || (filters.favorite === 'favorite' ? paper.favorite : !paper.favorite))
))
const allVisibleSelected = computed(() => filteredPapers.value.length > 0 && filteredPapers.value.every((paper) => selectedPaperIds.value.includes(paper.id)))
const partiallySelected = computed(() => !allVisibleSelected.value && filteredPapers.value.some((paper) => selectedPaperIds.value.includes(paper.id)))

function reset() { Object.assign(filters, { source: '', year: '', difficulty: '', type: '', favorite: '' }); keyword.value = '' }
function accuracyClass(value: number) { return value >= 70 ? 'accuracy good' : value ? 'accuracy medium' : 'accuracy' }
function practice(name: string) { ElMessage.success(`开始练习：${name}`) }
function startImport() {
  paperImportStore.startImport()
  router.push('/papers/import')
}
function editPaper(paper: any) {
  paperImportStore.startEdit(paper)
  router.push({
    path: '/papers/import/parse',
    query: {
      mode: 'edit',
      paperId: String(paper.id),
      name: paper.name,
      subject: paper.subject,
      source: paper.source,
      year: paper.year,
      type: paper.type
    }
  })
}
function toggleFavorite(paper: any) {
  paper.favorite = !paper.favorite
  ElMessage.success(paper.favorite ? '已收藏试卷' : '已取消收藏')
}
function togglePaper(id: number, checked: boolean) {
  selectedPaperIds.value = checked
    ? Array.from(new Set([...selectedPaperIds.value, id]))
    : selectedPaperIds.value.filter((paperId) => paperId !== id)
}
function toggleAllVisible(checked: string | number | boolean) {
  const visibleIds = filteredPapers.value.map((paper) => paper.id)
  selectedPaperIds.value = checked
    ? Array.from(new Set([...selectedPaperIds.value, ...visibleIds]))
    : selectedPaperIds.value.filter((id) => !visibleIds.includes(id))
}
async function confirmDeletePaper(id: number, name: string) {
  try {
    await ElMessageBox.confirm(`删除后将无法恢复，确认删除试卷“${name}”吗？`, '删除试卷', {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'warning'
    })
    papers.value = papers.value.filter((paper) => paper.id !== id)
    selectedPaperIds.value = selectedPaperIds.value.filter((paperId) => paperId !== id)
    ElMessage.success('试卷已删除')
  } catch {}
}
async function confirmBatchDelete() {
  const count = selectedPaperIds.value.length
  if (!count) return
  try {
    await ElMessageBox.confirm(`已选择 ${count} 份试卷，删除后将无法恢复，确认批量删除吗？`, '批量删除试卷', {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'warning'
    })
    const selectedIds = new Set(selectedPaperIds.value)
    papers.value = papers.value.filter((paper) => !selectedIds.has(paper.id))
    selectedPaperIds.value = []
    ElMessage.success(`已删除 ${count} 份试卷`)
  } catch {}
}
</script>

<style scoped lang="scss">
.paper-page{display:flex;flex-direction:column;gap:20px}.summary-grid{display:grid;grid-template-columns:repeat(3,1fr) 1.4fr;gap:16px}.summary-card{height:116px;padding:24px;display:flex;align-items:center;gap:18px}.summary-icon{width:54px;height:54px;border-radius:13px;display:grid;place-items:center;font-size:26px}.summary-icon.blue{color:#2858ff;background:#edf2ff}.summary-icon.green{color:#19b777;background:#e7f8f0}.summary-icon.orange{color:#ff8a13;background:#fff1df}.summary-icon.purple{color:#8b4df5;background:#f1e9ff}.summary-card p{margin:0 0 8px;color:#27335e;font-weight:700}.summary-card strong{font-size:24px;color:var(--ink)}.summary-card small{font-size:13px}.summary-card b,.summary-card em{display:block;color:var(--ink);font-style:normal}.summary-card em{margin-top:6px;color:var(--muted);font-size:13px}.filters{display:grid;grid-template-columns:repeat(5,minmax(112px,1fr)) minmax(170px,1.2fr) 68px 104px 116px;gap:10px}.keyword-input{min-width:0}.paper-table{overflow:hidden}.paper-row{display:grid;grid-template-columns:34px minmax(300px,1.8fr) 150px 76px 76px 90px 90px 140px 190px;align-items:center;gap:10px;min-height:61px;padding:0 16px;border-bottom:1px solid var(--line);font-size:13px}.paper-head{min-height:50px;background:#fbfcff;color:#5f6c91;font-weight:700}.paper-name{display:flex;align-items:center;gap:18px;min-width:0}.paper-name strong{color:var(--ink);white-space:nowrap}.favorite-button{display:grid;flex:none;place-items:center;width:20px;height:24px;padding:0;color:#7a86aa;font-size:19px;background:transparent;border:0;transition:.16s ease}.favorite-button:hover{color:#ff9a15;transform:scale(1.08)}.favorite-button.favorite{color:#ff9a15}.difficulty{display:inline-flex;padding:4px 9px;border-radius:4px;font-style:normal;white-space:nowrap}.difficulty.中等{color:#f08a00;background:#fff1dc}.difficulty.较难{color:#ff5260;background:#ffeaec}.difficulty.简单{color:#179b6c;background:#e5f7ef}.accuracy.good{color:#11aa70}.accuracy.medium{color:#ff7800}.progress-cell span{display:block;margin-bottom:7px}.progress-cell i{display:block;width:96px;height:4px;background:#e7eaf3;border-radius:3px}.progress-cell b{display:block;height:100%;background:#2c55f5;border-radius:3px}.row-actions{display:flex;gap:13px}.row-actions button{display:flex;align-items:center;gap:5px;padding:0;color:#33416e;background:transparent;border:0;white-space:nowrap}.row-actions button:hover{color:var(--primary)}.row-actions .delete-action:hover{color:var(--red)}footer{height:66px;padding:0 16px;display:grid;grid-template-columns:1fr 120px auto;align-items:center;gap:20px;color:#58658e;font-size:13px}footer .el-select{width:110px}@media(max-width:1500px){.filters{grid-template-columns:repeat(5,minmax(100px,1fr)) minmax(140px,1.15fr) 64px 96px 108px;gap:8px}.paper-row{grid-template-columns:30px minmax(260px,1.7fr) 128px 62px 62px 78px 76px 118px 178px}}
</style>
