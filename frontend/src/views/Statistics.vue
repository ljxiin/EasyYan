<template>
  <section class="statistics-page">
    <nav class="tabs">
      <button
        v-for="item in tabs"
        :key="item.key"
        type="button"
        :class="{ active: activeTab === item.key }"
        @click="switchTab(item.key)"
      >
        {{ item.label }}
      </button>
    </nav>

    <template v-if="activeTab === 'overview'">
      <MetricCards :items="overviewMetrics" />
      <div class="overview-grid">
        <ChartPanel class="trend-card" title="正确率趋势">
          <template #actions><PeriodSwitch v-model="accuracyPeriod" /></template>
          <EChart :option="accuracyTrend" />
        </ChartPanel>
        <ChartPanel class="mastery-card" title="题目掌握情况">
          <div class="donut-layout">
            <div class="donut"><EChart :option="masteryDonut" /><DonutCenter :value="String(profile.total)" label="总题数" /></div>
            <LegendList :items="masteryLegend" />
          </div>
        </ChartPanel>
        <DataPanel title="题型正确率">
          <div class="mini-table type-mini">
            <div class="table-head"><span>题型</span><span>刷题数</span><span>正确率</span></div>
            <div v-for="row in typeRows" :key="row.name" class="table-row">
              <strong>{{ row.name }}</strong><span>{{ row.count }}</span>
              <span>{{ row.rate }}% <i class="bar"><i :style="{ width: `${row.rate}%` }"></i></i></span>
            </div>
          </div>
        </DataPanel>
        <DataPanel title="知识点正确率 TOP10">
          <template #actions>
            <button type="button" class="detail-link" @click="knowledgeDialogVisible = true">查看全部知识点 ›</button>
          </template>
          <div class="ranking-list">
            <div v-for="(row, index) in knowledgeRows.slice(0, 10)" :key="row.name">
              <span>{{ index + 1 }}</span><strong>{{ row.name }}</strong>
              <i class="bar"><i :style="{ width: `${row.rate}%` }"></i></i><em>{{ row.rate }}%</em>
            </div>
          </div>
        </DataPanel>
        <ChartPanel title="每日刷题时长（小时）">
          <template #actions><PeriodSwitch v-model="durationPeriod" /></template>
          <EChart :option="durationBars" />
        </ChartPanel>
      </div>
    </template>

    <template v-else-if="activeTab === 'ability'">
      <div class="panel ability-summary">
        <div class="donut ability-donut">
          <EChart :option="abilityDonut" />
          <DonutCenter :value="abilityAverage" label="综合得分 /100" />
        </div>
        <div v-for="item in abilities" :key="item.name" class="ability-card">
          <span class="metric-icon" :style="{ color: item.color, background: `${item.color}18` }">
            <component :is="icons[item.icon]" />
          </span>
          <div><small>{{ item.name }}</small><strong>{{ item.score }} <em>/100</em></strong></div>
          <p>正确率　{{ item.rate }}%</p><p>较上期　<b :class="item.delta > 0 ? 'up' : 'down'">{{ item.delta > 0 ? '↑' : '↓' }} {{ Math.abs(item.delta) }}</b></p>
        </div>
      </div>
      <div class="two-charts ability-charts">
        <ChartPanel title="能力得分趋势"><template #actions><PeriodSwitch /></template><EChart :option="abilityTrend" /></ChartPanel>
        <ChartPanel title="能力雷达图"><EChart :option="radarOption" /></ChartPanel>
      </div>
      <DataPanel title="能力维度详情">
        <StandardTable :columns="abilityColumns" :rows="abilityTable" />
      </DataPanel>
    </template>

    <template v-else-if="activeTab === 'type'">
      <MetricCards :items="typeMetrics" />
      <div class="two-charts type-charts">
        <ChartPanel title="各题型正确率对比"><EChart :option="typeBars" /></ChartPanel>
        <ChartPanel title="各题型正确率趋势"><template #actions><PeriodSwitch /></template><EChart :option="typeTrend" /></ChartPanel>
      </div>
      <div class="type-bottom">
        <DataPanel title="题型详细数据"><StandardTable :columns="typeColumns" :rows="typeTable" /></DataPanel>
        <ChartPanel title="各题型刷题量占比">
          <div class="donut-layout fill"><div class="donut"><EChart :option="typeDonut" /><DonutCenter :value="String(profile.total)" label="总题数" /></div><LegendList :items="typeLegend" /></div>
        </ChartPanel>
      </div>
    </template>

    <template v-else-if="activeTab === 'knowledge'">
      <MetricCards :items="knowledgeMetrics" />
      <div class="knowledge-charts">
        <ChartPanel title="知识点掌握率分布"><template #actions><PeriodSwitch v-model="knowledgePeriod" /></template><EChart :option="knowledgeBars" /></ChartPanel>
        <ChartPanel title="知识点掌握情况占比">
          <div class="donut-layout fill"><div class="donut"><EChart :option="knowledgeDonut" /><DonutCenter :value="String(profile.knowledgeTotal)" label="知识点总数" /></div><LegendList :items="knowledgeLegend" /></div>
        </ChartPanel>
      </div>
      <DataPanel title="知识点掌握详情">
        <template #actions>
          <el-select
            v-model="selectedChapter"
            class="chapter-filter"
            placeholder="全部章节"
            filterable
            clearable
          >
            <el-option v-for="chapter in chapterOptions" :key="chapter" :label="chapter" :value="chapter" />
          </el-select>
          <el-input
            v-model="knowledgeKeyword"
            class="knowledge-search"
            placeholder="搜索知识点"
            clearable
          >
            <template #prefix><el-icon><Search /></el-icon></template>
          </el-input>
        </template>
        <StandardTable :columns="knowledgeColumns" :rows="knowledgeTable" />
        <div v-if="knowledgeTable.length === 0" class="table-empty">未找到符合条件的知识点</div>
        <Pagination :total="`共 ${filteredKnowledgePoints.length} 条`" :pages="String(Math.max(1, Math.ceil(filteredKnowledgePoints.length / 10)))" />
      </DataPanel>
    </template>

    <template v-else-if="activeTab === 'mistakes'">
      <MetricCards :items="mistakeMetrics" dense />
      <div class="mistake-charts">
        <ChartPanel title="错题数量趋势"><template #actions><PeriodSwitch v-model="mistakePeriod" /></template><EChart :option="mistakeTrend" /></ChartPanel>
        <ChartPanel title="错题来源分布"><div class="donut-layout fill"><div class="donut small"><EChart :option="mistakeSourceDonut" /><DonutCenter :value="String(profile.mistakes)" label="错题总数" /></div><LegendList :items="mistakeSourceLegend" /></div></ChartPanel>
        <ChartPanel title="错题掌握情况"><div class="donut-layout fill"><div class="donut small"><EChart :option="mistakeMasteryDonut" /><DonutCenter :value="String(profile.mistakes)" label="错题总数" /></div><LegendList :items="mistakeMasteryLegend" /></div></ChartPanel>
      </div>
      <div class="mistake-bottom">
        <DataPanel title="错题知识点 TOP10">
          <template #actions>
            <button type="button" class="detail-link" @click="mistakeKnowledgeDialogVisible = true">查看全部知识点 ›</button>
          </template>
          <StandardTable :columns="mistakeColumns" :rows="mistakeKnowledge" />
        </DataPanel>
        <DataPanel title="需要重点关注的错题">
          <template #actions>
            <button type="button" class="detail-link" @click="practiceAllMistakes">去练习</button>
          </template>
          <StandardTable :columns="focusColumns" :rows="focusMistakes" />
          <Pagination :total="`共 ${profile.mistakes-profile.eliminated} 条`" :pages="String(Math.ceil((profile.mistakes-profile.eliminated) / 10))" />
        </DataPanel>
      </div>
    </template>

    <template v-else>
      <MetricCards :items="recordMetrics" />
      <DataPanel class="records-panel">
        <template #title>
          <div class="record-filters">
            <button
              v-for="filter in recordFilters"
              :key="filter"
              type="button"
              :class="{ active: activeRecordFilter === filter }"
              @click="activeRecordFilter = filter"
            >
              {{ filter === '全部记录' ? filter : `${filter}刷题` }}
            </button>
          </div>
        </template>
        <StandardTable :columns="recordColumns" :rows="recordTable" />
        <Pagination :total="`共 ${recordTable.length} 条记录`" :pages="String(Math.max(1, Math.ceil(recordTable.length / 10)))" />
      </DataPanel>
    </template>

    <el-dialog
      v-model="knowledgeDialogVisible"
      title="全部考点正确率"
      width="840px"
      class="knowledge-dialog"
      destroy-on-close
    >
      <div class="dialog-summary">
        <span>共 {{ allKnowledgePoints.length }} 个考点</span>
        <span>平均正确率 <strong>{{ averageKnowledgeRate }}%</strong></span>
      </div>
      <div class="knowledge-detail-table">
        <div class="knowledge-detail-head">
          <span>排名</span><span>考点</span><span>所属科目</span><span>刷题数</span><span>正确率</span><span>操作</span>
        </div>
        <div v-for="(row, index) in allKnowledgePoints" :key="row.name" class="knowledge-detail-row">
          <span>{{ index + 1 }}</span>
          <strong>{{ row.name }}</strong>
          <span>{{ row.subject }}</span>
          <span>{{ row.count }} 题</span>
          <span class="detail-rate">
            <i class="bar"><i :style="{ width: `${row.rate}%` }"></i></i>
            <em>{{ row.rate }}%</em>
          </span>
          <span><button type="button" class="question-action" @click="openKnowledgeQuestionDetail(row, true)">查看详情</button></span>
        </div>
      </div>
    </el-dialog>

    <el-dialog
      v-model="questionDialogVisible"
      :title="`${selectedKnowledgeName} · 做题详情`"
      width="980px"
      class="question-detail-dialog"
      destroy-on-close
      @closed="resetQuestionDialogSource"
    >
      <div class="question-summary">
        <div><span>累计题目</span><strong>{{ knowledgeQuestionRows.length }}</strong><em>题</em></div>
        <div><span>累计作答</span><strong>{{ questionAttemptTotal }}</strong><em>次</em></div>
        <div><span>平均正确率</span><strong>{{ questionAverageRate }}</strong><em>%</em></div>
        <div><span>最近练习</span><strong class="summary-date">{{ knowledgeQuestionRows[0]?.lastDate }}</strong></div>
      </div>
      <div class="question-detail-table">
        <div class="question-detail-head">
          <span>题目</span><span>题型</span><span>最近结果</span><span>正确率</span><span>做题次数</span><span>最近作答</span><span>操作</span>
        </div>
        <div v-for="row in knowledgeQuestionRows" :key="row.id" class="question-detail-row">
          <div class="question-content">
            <i>{{ row.id }}</i>
            <strong>{{ row.question }}</strong>
          </div>
          <span>{{ row.type }}</span>
          <span><i class="result-tag" :class="row.correct ? 'correct' : 'incorrect'">{{ row.correct ? '正确' : '错误' }}</i></span>
          <span class="question-rate"><i class="bar"><i :style="{ width: `${row.rate}%` }"></i></i><em>{{ row.rate }}%</em></span>
          <span>{{ row.attempts }} 次</span>
          <span>{{ row.lastDate }}</span>
          <span><button type="button" class="question-action" @click="openSingleQuestionDetail(row)">查看详情</button></span>
        </div>
      </div>
      <template #footer>
        <button type="button" class="dialog-close-btn" @click="handleQuestionDialogBack">{{ questionDialogFromOverview ? '返回' : '关闭' }}</button>
        <button type="button" class="dialog-practice-btn" @click="practiceKnowledgePoint">练习该知识点</button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="mistakeKnowledgeDialogVisible"
      title="全部错题知识点"
      width="840px"
      class="knowledge-dialog"
      destroy-on-close
    >
      <div class="dialog-summary">
        <span>共 {{ allMistakeKnowledge.length }} 个知识点</span>
        <span>平均错题率 <strong>{{ averageMistakeRate }}%</strong></span>
      </div>
      <div class="knowledge-detail-table">
        <div class="knowledge-detail-head">
          <span>排名</span><span>知识点</span><span>所属科目</span><span>错题数</span><span>错题率</span><span>操作</span>
        </div>
        <div v-for="(row, index) in allMistakeKnowledge" :key="row.name" class="knowledge-detail-row">
          <span>{{ index + 1 }}</span>
          <strong>{{ row.name }}</strong>
          <span>{{ row.subject }}</span>
          <span>{{ row.count }} 题</span>
          <span class="detail-rate mistake-rate">
            <i class="bar"><i :style="{ width: `${row.rate}%` }"></i></i>
            <em>{{ row.rate }}%</em>
          </span>
          <span><button type="button" class="question-action" @click="openMistakeKnowledgeDetail(row)">查看详情</button></span>
        </div>
      </div>
    </el-dialog>

    <el-dialog
      v-model="mistakeQuestionDialogVisible"
      title="错题详情"
      width="720px"
      class="single-question-dialog"
      destroy-on-close
    >
      <div v-if="selectedMistakeQuestion" class="single-question-content">
        <div class="single-question-meta">
          <span>{{ selectedMistakeQuestion.point }}</span>
          <span>{{ selectedMistakeQuestion.times }}</span>
          <span>{{ selectedMistakeQuestion.date }}</span>
        </div>
        <section class="analysis-block">
          <h3>题目</h3>
          <p>{{ selectedMistakeQuestion.question }}</p>
        </section>
        <section class="analysis-block answer">
          <h3>答案</h3>
          <p>{{ selectedMistakeQuestion.answer }}</p>
        </section>
        <section class="analysis-block">
          <h3>解析</h3>
          <p>{{ selectedMistakeQuestion.analysis }}</p>
        </section>
      </div>
      <template #footer>
        <button type="button" class="dialog-close-btn" @click="mistakeQuestionDialogVisible = false">关闭</button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="recordDialogVisible"
      title="刷题情况详情"
      width="760px"
      class="record-detail-dialog"
      destroy-on-close
    >
      <div v-if="selectedRecord" class="record-detail-content">
        <div class="record-detail-title">
          <strong>{{ selectedRecord.content }}</strong>
          <span :class="selectedRecord.mode === '按章节' || selectedRecord.mode === '按知识点' ? 'green' : ''">{{ selectedRecord.mode }}</span>
        </div>
        <div class="record-summary-grid">
          <div><span>题目数量</span><strong>{{ selectedRecord.count }}</strong><em>题</em></div>
          <div><span>正确率</span><strong>{{ selectedRecord.rate }}</strong></div>
          <div><span>用时</span><strong>{{ selectedRecord.time }}</strong></div>
          <div><span>来源</span><strong>{{ selectedRecord.source }}</strong></div>
        </div>
        <div class="record-detail-list">
          <p><span>刷题时间</span><strong>{{ selectedRecord.date }}</strong></p>
          <p><span>刷题科目</span><strong>{{ profile.name }}</strong></p>
          <p><span>完成情况</span><strong>已完成 {{ selectedRecord.count }} 题，正确率 {{ selectedRecord.rate }}</strong></p>
          <p><span>薄弱提醒</span><strong>{{ selectedRecord.tip }}</strong></p>
        </div>
      </div>
      <template #footer>
        <button type="button" class="dialog-close-btn" @click="recordDialogVisible = false">关闭</button>
        <button v-if="selectedRecord" type="button" class="dialog-practice-btn" @click="repeatRecordPractice(selectedRecord)">再次练习</button>
      </template>
    </el-dialog>

    <el-dialog
      v-model="singleQuestionDialogVisible"
      title="题目详情"
      width="720px"
      class="single-question-dialog"
      append-to-body
      destroy-on-close
    >
      <div v-if="selectedQuestionRow" class="single-question-content">
        <div class="single-question-meta">
          <span>{{ selectedQuestionRow.id }}</span>
          <span>{{ selectedQuestionRow.type }}</span>
          <span>{{ selectedKnowledgeName }}</span>
        </div>
        <section class="analysis-block">
          <h3>题目</h3>
          <p>{{ selectedQuestionRow.question }}</p>
        </section>
        <section class="analysis-block answer">
          <h3>答案</h3>
          <p>{{ selectedQuestionRow.answer }}</p>
        </section>
        <section class="analysis-block">
          <h3>解析</h3>
          <p>{{ selectedQuestionRow.analysis }}</p>
        </section>
      </div>
      <template #footer>
        <button type="button" class="dialog-close-btn" @click="singleQuestionDialogVisible = false">关闭</button>
      </template>
    </el-dialog>
  </section>
</template>

<script setup lang="ts">
import { computed, defineComponent, h, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import * as ElementIcons from '@element-plus/icons-vue'
import { Search } from '@element-plus/icons-vue'
import type { EChartsOption } from 'echarts'
import EChart from '@/components/EChart.vue'

type TabKey = 'overview' | 'ability' | 'type' | 'knowledge' | 'mistakes' | 'records'
type PeriodKey = '7d' | '30d' | '1y'
type Metric = { label: string; value: string; unit?: string; delta: string; positive?: boolean; icon: string; color: string }
type Column = { key: string; label: string; width?: string; type?: string }
type RecordFilter = '全部记录' | '按试卷' | '按章节' | '按知识点' | '按收藏' | '按错题'
type RecordRow = {
  id: string;
  subject: SubjectKey;
  date: string;
  mode: Exclude<RecordFilter, '全部记录'>;
  content: string;
  count: number;
  rate: string;
  time: string;
  source: string;
  tip: string;
}

const route = useRoute()
const router = useRouter()
const icons = ElementIcons as Record<string, unknown>
const tabs: { key: TabKey; label: string }[] = [
  { key: 'overview', label: '整体概览' }, { key: 'ability', label: '能力分析' }, { key: 'type', label: '题型分析' },
  { key: 'knowledge', label: '知识点分析' }, { key: 'mistakes', label: '错题分析' }, { key: 'records', label: '刷题记录' }
]
const activeTab = computed<TabKey>(() => tabs.some(t => t.key === route.query.tab) ? route.query.tab as TabKey : 'overview')
const selectedSubject = computed(() => {
  const value = String(route.query.subject || 'calculus')
  return ['calculus', 'linear-algebra', 'probability'].includes(value) ? value as SubjectKey : 'calculus'
})
const accuracyPeriod = ref<PeriodKey>('30d')
const durationPeriod = ref<PeriodKey>('7d')
const knowledgePeriod = ref<PeriodKey>('30d')
const mistakePeriod = ref<PeriodKey>('30d')
const knowledgeDialogVisible = ref(false)
const questionDialogVisible = ref(false)
const questionDialogFromOverview = ref(false)
const questionDialogReturnTarget = ref<'knowledge' | 'mistake' | ''>('')
const mistakeKnowledgeDialogVisible = ref(false)
const mistakeQuestionDialogVisible = ref(false)
const singleQuestionDialogVisible = ref(false)
const recordDialogVisible = ref(false)
const selectedKnowledgeName = ref('')
const selectedQuestionRow = ref<ReturnType<typeof buildKnowledgeQuestionRows>[number] | null>(null)
const selectedMistakeQuestion = ref<ReturnType<typeof buildFocusMistakes>[number] | null>(null)
const selectedRecord = ref<RecordRow | null>(null)
const selectedChapter = ref('')
const knowledgeKeyword = ref('')
const recordFilters: RecordFilter[] = ['全部记录', '按试卷', '按章节', '按知识点', '按收藏', '按错题']
const activeRecordFilter = ref<RecordFilter>('全部记录')
const generatedRecords = ref<RecordRow[]>(loadGeneratedRecords())
function switchTab(tab: TabKey) {
  router.replace({ query: { ...route.query, tab: tab === 'overview' ? undefined : tab } })
}

const palette = ['#2f6bff', '#16ba78', '#ff9b21', '#8d59f6', '#ff6268']
const metric = (label: string, value: string, unit: string, delta: string, icon: string, color: string, positive = true): Metric => ({ label, value, unit, delta, icon, color, positive })
type SubjectKey = 'calculus' | 'linear-algebra' | 'probability'
const subjectProfiles: Record<SubjectKey, {
  name: string; total: number; correct: number; rate: number; hours: number; streak: number;
  knowledgeTotal: number; mastered: number; weak: number; mistakes: number; eliminated: number; sessions: number
}> = {
  calculus: { name:'高等数学', total:856, correct:617, rate:72, hours:38.6, streak:16, knowledgeTotal:128, mastered:52, weak:34, mistakes:186, eliminated:116, sessions:48 },
  'linear-algebra': { name:'线性代数', total:438, correct:334, rate:76.3, hours:19.8, streak:12, knowledgeTotal:62, mastered:31, weak:14, mistakes:104, eliminated:72, sessions:27 },
  probability: { name:'概率统计', total:326, correct:218, rate:66.9, hours:15.4, streak:9, knowledgeTotal:48, mastered:18, weak:17, mistakes:108, eliminated:61, sessions:21 }
}
const profile = computed(() => subjectProfiles[selectedSubject.value])
const overviewMetrics = computed(() => [
  metric('刷题总数', String(profile.value.total), '题', '↑ 12.5%', 'Calendar', palette[0]),
  metric('正确题数', String(profile.value.correct), '题', '↑ 8.3%', 'CircleCheckFilled', palette[1]),
  metric('正确率', profile.value.rate.toFixed(1), '%', selectedSubject.value === 'probability' ? '↓ 1.4%' : '↑ 2.1%', 'Aim', palette[2], selectedSubject.value !== 'probability'),
  metric('刷题时长', profile.value.hours.toFixed(1), '小时', '↑ 5.6%', 'PieChart', palette[3]),
  metric('连续刷题天数', String(profile.value.streak), '天', '↑ 3 天', 'Calendar', palette[0])
])
const typeMetrics = computed(() => [
  metric('题型总数', '5', '种', '——', 'Document', palette[0]), metric('正确题数', String(profile.value.correct), '题', '↑ 8.3%', 'CircleCheckFilled', palette[1]),
  metric('正确率', profile.value.rate.toFixed(1), '%', '↑ 2.1%', 'Aim', palette[2]), metric('平均得分率', profile.value.rate.toFixed(1), '%', '↑ 2.1%', 'PieChart', palette[3]),
  metric('平均用时', (profile.value.hours * 60 / profile.value.total).toFixed(2), '分钟', '↑ 5.4%', 'Timer', palette[0])
])
const knowledgeMetrics = computed(() => [
  metric('知识点总数', String(profile.value.knowledgeTotal), '个', '↑ 8 个', 'Tickets', palette[0]), metric('已掌握知识点', String(profile.value.mastered), '个', '↑ 6 个', 'CircleCheckFilled', palette[1]),
  metric('掌握率', (profile.value.mastered / profile.value.knowledgeTotal * 100).toFixed(1), '%', '↑ 2.8%', 'PieChart', palette[2]), metric('薄弱知识点', String(profile.value.weak), '个', '↓ 5 个', 'PieChart', palette[3], false),
  metric('平均用时', (profile.value.hours * 60 / profile.value.total).toFixed(2), '分钟', '↑ 0.18 分钟', 'Timer', palette[0])
])
const mistakeMetrics = computed(() => [
  metric('错题总数', String(profile.value.mistakes), '题', '↓ 18题', 'Histogram', '#ff6268', false), metric('错题率', (100-profile.value.rate).toFixed(1), '%', '↓ 3.2%', 'Aim', palette[2], false),
  metric('错题重做率', (profile.value.eliminated/profile.value.mistakes*100).toFixed(1), '%', '↑ 8.7%', 'Calendar', palette[3]), metric('已消灭错题', String(profile.value.eliminated), '题', '↑ 16 题', 'Tickets', palette[1]),
  metric('仍未掌握错题', String(profile.value.mistakes-profile.value.eliminated), '题', '↓ 7 题', 'CircleCheck', palette[0], false), metric('平均重做时长', selectedSubject.value === 'calculus' ? '2.15' : selectedSubject.value === 'linear-algebra' ? '1.82' : '2.06', '分钟', '↑ 0.22 分钟', 'PieChart', '#5b8def')
])
const recordMetrics = computed(() => [
  metric('刷题次数', String(profile.value.sessions), '次', '↑ 6 次', 'Document', palette[0]), metric('刷题题数', String(profile.value.total), '题', '↑ 88 题', 'CircleCheckFilled', palette[1]),
  metric('正确率', profile.value.rate.toFixed(1), '%', '↑ 3.2%', 'Aim', palette[2]), metric('累计用时', profile.value.hours.toFixed(1), '小时', '↑ 4.8 小时', 'PieChart', palette[3]),
  metric('连续刷题天数', String(profile.value.streak), '天', '↑ 3 天', 'Calendar', '#20aeb0')
])

const dates = ['05-02','05-05','05-08','05-11','05-14','05-17','05-20','05-23','05-26','05-29','05-31']
const baseGrid = { left: 42, right: 18, top: 32, bottom: 32 }
const axis = { axisLine: { lineStyle: { color: '#e7ecf7' } }, axisTick: { show: false }, axisLabel: { color: '#536187', fontSize: 11 }, splitLine: { lineStyle: { color: '#edf1f8' } } }
const lineSeries = (name: string, data: number[], color: string) => ({ name, type: 'line' as const, smooth: true, symbol: 'circle', symbolSize: 6, data, lineStyle: { width: 2, color }, itemStyle: { color: '#fff', borderColor: color, borderWidth: 2 }, areaStyle: { color: color + '10' } })
const accuracyData: Record<PeriodKey, { labels: string[]; values: number[] }> = {
  '7d': { labels: ['05-25','05-26','05-27','05-28','05-29','05-30','05-31'], values: [68,71,66,75,72,76,74] },
  '30d': { labels: ['05-02','05-05','05-08','05-11','05-14','05-17','05-20','05-23','05-26','05-29','05-31'], values: [64,58,56,66,54,57,55,61,66,69,72] },
  '1y': { labels: ['2023-06','2023-07','2023-08','2023-09','2023-10','2023-11','2023-12','2024-01','2024-02','2024-03','2024-04','2024-05'], values: [51,54,57,55,60,62,64,61,66,68,70,72] }
}
const durationData: Record<PeriodKey, { labels: string[]; values: number[] }> = {
  '7d': { labels: ['05-25','05-26','05-27','05-28','05-29','05-30','05-31'], values: [2.1,1.8,2.6,3.2,2.3,1.9,2.7] },
  '30d': { labels: ['05-02','05-05','05-08','05-11','05-14','05-17','05-20','05-23','05-26','05-29','05-31'], values: [1.6,2.1,1.8,2.4,2.2,2.8,2.5,3.1,2.3,2.7,2.9] },
  '1y': { labels: ['2023-06','2023-07','2023-08','2023-09','2023-10','2023-11','2023-12','2024-01','2024-02','2024-03','2024-04','2024-05'], values: [18.4,21.2,24.8,22.5,27.1,29.6,31.8,28.9,33.5,35.2,36.7,38.6] }
}
const accuracyTrend = computed<EChartsOption>(() => {
  const data = accuracyData[accuracyPeriod.value]
  const offset = profile.value.rate - 72
  return { grid: baseGrid, tooltip: { trigger: 'axis' }, xAxis: { type: 'category', data: data.labels, ...axis }, yAxis: { ...axis, type: 'value', min: 0, max: 100, axisLabel: { color: '#536187', fontSize: 11, formatter: '{value}%' } }, series: [lineSeries('正确率', data.values.map(value => Math.max(20, Math.min(96, Number((value + offset).toFixed(1))))), palette[0])] }
})
const durationBars = computed<EChartsOption>(() => {
  const data = durationData[durationPeriod.value]
  const yearly = durationPeriod.value === '1y'
  const factor = profile.value.hours / 38.6
  const values = data.values.map(value => Number((value * factor).toFixed(1)))
  return { grid: baseGrid, xAxis: { type: 'category', data: data.labels, ...axis }, yAxis: { ...axis, type: 'value', max: yearly ? 45 : 4, axisLabel: { color: '#536187', fontSize: 11, formatter: '{value}h' } }, series: [{ type: 'bar', data: values, barMaxWidth: 30, itemStyle: { color: '#7da1f7', borderRadius: [4,4,0,0] }, label: { show: true, position: 'top', color: '#0d1b50', fontSize: 10 } }] }
})
function donut(data: { name: string; value: number; color: string }[]): EChartsOption { return { color: data.map(i => i.color), series: [{ type: 'pie', radius: ['57%','78%'], center: ['50%','50%'], avoidLabelOverlap: false, label: { show: false }, data }] } }
const masteryCounts = computed(() => {
  const total = profile.value.total
  return [Math.round(total*.258), Math.round(total*.463), Math.round(total*.178), total-Math.round(total*.258)-Math.round(total*.463)-Math.round(total*.178)]
})
const masteryLegend = computed(() => [
  { color: palette[1], label: '完全掌握', value: `${masteryCounts.value[0]}题（25.8%）` },{ color: palette[0], label: '基本掌握', value: `${masteryCounts.value[1]}题（46.3%）` },
  { color: palette[2], label: '未掌握', value: `${masteryCounts.value[2]}题（17.8%）` },{ color: palette[3], label: '不熟悉', value: `${masteryCounts.value[3]}题（10.1%）` }
])
const masteryDonut = computed(() => donut(masteryLegend.value.map((item, index) => ({ name: item.label, value: masteryCounts.value[index], color: item.color }))))
const typeRowsBySubject: Record<SubjectKey, {name:string;count:number;rate:number}[]> = {
  calculus: [{name:'选择题',count:312,rate:78.5},{name:'填空题',count:216,rate:71.8},{name:'计算题',count:184,rate:68.5},{name:'证明题',count:94,rate:62.3},{name:'应用题',count:50,rate:70}],
  'linear-algebra': [{name:'选择题',count:168,rate:82.1},{name:'填空题',count:104,rate:78.8},{name:'计算题',count:96,rate:74.2},{name:'证明题',count:42,rate:69.0},{name:'应用题',count:28,rate:71.4}],
  probability: [{name:'选择题',count:126,rate:72.2},{name:'填空题',count:78,rate:67.9},{name:'计算题',count:72,rate:63.9},{name:'证明题',count:26,rate:57.7},{name:'应用题',count:24,rate:62.5}]
}
const typeRows = computed(() => typeRowsBySubject[selectedSubject.value])
const knowledgePointSource: Record<SubjectKey, [string,string,number,number][]> = {
  calculus: [['极限的四则运算','高等数学',48,92],['导数的概念','高等数学',42,88.5],['中值定理','高等数学',38,85.6],['一元函数积分学','高等数学',56,83.2],['不定积分','高等数学',35,81.3],['微分中值定理','高等数学',32,78.6],['函数的连续性','高等数学',44,75.4],['定积分的几何应用','高等数学',29,72.6],['偏导数与全微分','高等数学',36,69.2],['二元函数极值','高等数学',25,66.8]],
  'linear-algebra': [['矩阵的运算','线性代数',41,88.4],['行列式计算','线性代数',39,85.7],['向量组的线性相关性','线性代数',28,82.6],['线性方程组','线性代数',31,80.3],['特征值与特征向量','线性代数',27,77.9],['矩阵的秩','线性代数',26,75.6],['相似矩阵','线性代数',23,73.4],['二次型','线性代数',21,70.8],['正交矩阵','线性代数',18,68.5],['线性空间','线性代数',16,65.9]],
  probability: [['随机事件与概率','概率统计',34,79.2],['随机变量及其分布','概率统计',30,76.5],['数字特征','概率统计',24,73.8],['大数定律与中心极限定理','概率统计',19,70.6],['参数估计','概率统计',18,68.2],['条件概率','概率统计',27,66.7],['二维随机变量','概率统计',22,64.5],['常见概率分布','概率统计',25,62.8],['假设检验','概率统计',17,59.6],['区间估计','概率统计',15,56.9]]
}
const chapterNames: Record<SubjectKey, string[]> = {
  calculus: ['第一章　函数、极限与连续','第二章　一元函数微分学','第三章　一元函数积分学','第四章　多元函数微分学','第五章　重积分与曲线积分'],
  'linear-algebra': ['第一章　行列式','第二章　矩阵','第三章　向量组','第四章　线性方程组','第五章　特征值与二次型'],
  probability: ['第一章　随机事件与概率','第二章　随机变量及其分布','第三章　多维随机变量','第四章　数字特征与极限定理','第五章　数理统计']
}
const allKnowledgePoints = computed(() => knowledgePointSource[selectedSubject.value].map(([name, subject, count, rate], index) => ({
  name, subject, count, rate, chapter: chapterNames[selectedSubject.value][Math.min(4, Math.floor(index / 2))]
})))
const averageKnowledgeRate = computed(() =>
  (allKnowledgePoints.value.reduce((sum, item) => sum + item.rate, 0) / allKnowledgePoints.value.length).toFixed(1)
)
const knowledgeRows = computed(() => allKnowledgePoints.value.slice(0, 10))
const chapterOptions = computed(() => [...new Set(allKnowledgePoints.value.map(item => item.chapter))])
const filteredKnowledgePoints = computed(() => {
  const keyword = knowledgeKeyword.value.trim().toLowerCase()
  return allKnowledgePoints.value.filter(item => {
    const chapterMatched = !selectedChapter.value || item.chapter === selectedChapter.value
    const keywordMatched = !keyword || item.name.toLowerCase().includes(keyword)
    return chapterMatched && keywordMatched
  })
})

watch(selectedSubject, () => {
  selectedChapter.value = ''
  knowledgeKeyword.value = ''
})

const baseAbilities = [
  { name:'计算能力',score:78.5,rate:78.2,delta:6.3,color:palette[0],icon:'DataAnalysis' },{ name:'逻辑推理能力',score:74.2,rate:74,delta:4.8,color:'#2fb886',icon:'Warning' },
  { name:'概念理解能力',score:68.7,rate:68.1,delta:-2.1,color:palette[2],icon:'Opportunity' },{ name:'综合应用能力',score:70.8,rate:70.3,delta:1.5,color:palette[3],icon:'Checked' },
  { name:'解题策略能力',score:69.6,rate:69.2,delta:-1.8,color:palette[4],icon:'Aim' }
]
const abilities = computed(() => {
  const offset = profile.value.rate - 72
  return baseAbilities.map((item,index) => ({ ...item, score:Number((item.score+offset+(selectedSubject.value==='linear-algebra'&&index===1?3:0)).toFixed(1)), rate:Number((item.rate+offset).toFixed(1)) }))
})
const abilityAverage = computed(() => (abilities.value.reduce((sum,item)=>sum+item.score,0)/abilities.value.length).toFixed(1))
const abilityDonut = computed(() => donut(abilities.value.map(a => ({ name:a.name, value:a.score, color:a.color }))))
const abilityTrend = computed<EChartsOption>(() => ({ color: palette, legend: { top: 0, textStyle:{fontSize:10} }, grid:{...baseGrid,top:45}, xAxis:{type:'category',data:dates,...axis}, yAxis:{type:'value',min:0,max:100,...axis}, series: abilities.value.map((a,i)=>lineSeries(a.name,[78,82,74,72,81,73,76,70,78,74,79],a.color)).map((s,i)=>({...s,data:(s.data as number[]).map(v=>Number((v-i*7+(profile.value.rate-72)).toFixed(1)))})) }))
const radarOption = computed<EChartsOption>(() => ({ radar:{ indicator:abilities.value.map(a=>({name:a.name,max:100})), radius:'66%', splitNumber:4, axisName:{color:'#17245c'} }, series:[{type:'radar',data:[{value:abilities.value.map(a=>a.score),areaStyle:{color:'#5790ff33'},lineStyle:{color:'#5790ff'},itemStyle:{color:'#5790ff'}}]}] }))
const abilityColumns: Column[] = [{key:'name',label:'能力维度'},{key:'desc',label:'能力描述',width:'30%'},{key:'score',label:'得分 /100',type:'progress'},{key:'rate',label:'正确率'},{key:'count',label:'刷题量'},{key:'delta',label:'较上期变化',type:'delta'},{key:'level',label:'水平',type:'tag'}]
const abilityTable = computed(() => abilities.value.map((a,i)=>({name:a.name,desc:['对数学运算、公式变形、求导积分等计算的掌握程度','分析条件、推导结论、证明等逻辑思维能力','对数学概念、定理、性质的理解和掌握程度','将知识综合运用解决综合性问题的能力','选择合适方法、优化解题步骤的策略能力'][i],score:a.score,rate:a.rate+'%',count:Math.round(profile.value.total*[.36,.33,.29,.23,.2][i])+' 题',delta:(a.delta>0?'↑ ':'↓ ')+Math.abs(a.delta),level:i<2?'良好':'中等'})))

const typeBars = computed<EChartsOption>(() => ({ grid:baseGrid,xAxis:{type:'category',data:typeRows.value.map(i=>i.name),...axis},yAxis:{...axis,type:'value',max:100,axisLabel:{color:'#536187',fontSize:11,formatter:'{value}%'}},series:[{type:'bar',data:typeRows.value.map(i=>i.rate),barWidth:28,itemStyle:{color:palette[0]},label:{show:true,position:'top',formatter:'{c}%'}}] }))
const typeTrend = computed<EChartsOption>(() => ({ color:palette,legend:{top:0},grid:{...baseGrid,top:48},xAxis:{type:'category',data:dates,...axis},yAxis:{...axis,type:'value',max:100,axisLabel:{color:'#536187',fontSize:11,formatter:'{value}%'}},series:typeRows.value.map((r,i)=>lineSeries(r.name,[74,78,70,69,78,70,68,72,67,70,76],palette[i])).map((s,i)=>({...s,data:(s.data as number[]).map(v=>Number((v-i*8+(profile.value.rate-72)).toFixed(1)))})) }))
const typeLegend = computed(() => typeRows.value.map((r,i)=>({color:palette[i],label:r.name,value:`${r.count}题（${(r.count/profile.value.total*100).toFixed(1)}%）`})))
const typeDonut = computed(() => donut(typeRows.value.map((r,i)=>({name:r.name,value:r.count,color:palette[i]}))))
const typeColumns: Column[] = [{key:'name',label:'题型'},{key:'count',label:'刷题量'},{key:'correct',label:'正确题数'},{key:'rate',label:'正确率'},{key:'score',label:'平均得分率'},{key:'time',label:'平均用时'},{key:'delta',label:'较上期变化',type:'delta'}]
const typeTable = computed(() => typeRows.value.map((r,i)=>({name:r.name,count:r.count,correct:Math.round(r.count*r.rate/100),rate:r.rate+'%',score:r.rate+'%',time:[1.02,1.18,1.56,2.35,1.81][i]+' 分钟',delta:(i<2||i===4?'↑ ':'↓ ')+[6.3,4.8,2.9,4.2,1.6][i]+'%'})))

const knowledgeDistribution = computed(() => {
  const total = profile.value.knowledgeTotal
  const ratios: Record<PeriodKey, number[]> = {
    '7d': [.31, .23, .24, .15],
    '30d': [.14, .2, .26, .29],
    '1y': [.18, .18, .24, .3]
  }
  const counts = ratios[knowledgePeriod.value].map(ratio => Math.round(total * ratio))
  return [...counts, Math.max(0, total - counts.reduce((sum, item) => sum + item, 0))]
})
const knowledgeLegend = computed(() => [
  {color:palette[1],label:'完全掌握（80%~100%）',value:`${knowledgeDistribution.value[4]}个`},{color:'#4f83ee',label:'较好掌握（60%~80%）',value:`${knowledgeDistribution.value[3]}个`},
  {color:palette[2],label:'一般掌握（40%~60%）',value:`${knowledgeDistribution.value[2]}个`},{color:palette[3],label:'较弱掌握（20%~40%）',value:`${knowledgeDistribution.value[1]}个`},{color:'#6473ea',label:'非常薄弱（0~20%）',value:`${knowledgeDistribution.value[0]}个`}
])
const knowledgeDonut = computed(() => donut(knowledgeLegend.value.map((r,i)=>({name:r.label,value:[4,3,2,1,0].map(index=>knowledgeDistribution.value[index])[i],color:r.color}))))
const knowledgeBars = computed<EChartsOption>(() => ({ grid:baseGrid,xAxis:{type:'category',data:['0~20%','20%~40%','40%~60%','60%~80%','80%~100%'],...axis},yAxis:{...axis,type:'value',max:50,axisLabel:{color:'#536187',fontSize:11,formatter:'{value}%'}},series:[{type:'bar',barWidth:34,data:knowledgeDistribution.value.map(v=>({value:Number((v/profile.value.knowledgeTotal*100).toFixed(1)),label:{show:true,position:'top',formatter:`${v}个`}})),itemStyle:{color:'#80a3f5',borderRadius:[4,4,0,0]}}] }))
const knowledgeColumns: Column[] = [{key:'name',label:'知识点',width:'21%'},{key:'chapter',label:'所属章节',width:'22%'},{key:'count',label:'刷题量'},{key:'rate',label:'正确率'},{key:'mastery',label:'掌握率',type:'progress'},{key:'time',label:'平均用时'},{key:'delta',label:'较上期变化',type:'delta'},{key:'action',label:'操作',type:'knowledgeAction'}]
const knowledgeTable = computed(() => filteredKnowledgePoints.value.slice(0,10).map((item,i)=>({
  name:'›　'+item.name, knowledgeName:item.name, chapter:item.chapter, count:item.count, rate:item.rate+'%', mastery:Math.round(item.rate),
  time:[1.12,1.05,1.38,1.08,1.56,1.67,2.05,1.46,1.32,1.84][i]+' 分钟',
  delta:(i<2||i===3?'↑ ':'↓ ')+[8,5,3,10,6,7,9,4,2,5][i]+'%', action:'查看详情'
})))

const questionTemplates: Record<SubjectKey, { question: string; answer: string; analysis: string }[]> = {
  calculus: [
    { question:'求下列函数在指定点处的极限', answer:'极限存在，结果为 2。', analysis:'先判断分子分母在指定点是否同趋于 0，再用等价无穷小或因式分解约去公共因子，最后代入求值。' },
    { question:'判断函数在给定区间上的连续性', answer:'函数在区间内连续，端点按单侧连续判断。', analysis:'分别检查定义域、初等函数复合连续性以及分段点左右极限是否等于函数值。' },
    { question:'计算函数的一阶导数', answer:'导函数为 f′(x)=2x+1。', analysis:'按照和差、乘积与复合函数求导规则逐项处理，注意外层函数与内层函数的链式关系。' },
    { question:'求曲线在指定点处的切线方程', answer:'切线方程为 y-y₀=f′(x₀)(x-x₀)。', analysis:'先求导得到切线斜率，再代入指定点坐标写出点斜式方程。' },
    { question:'计算不定积分并验证结果', answer:'原函数为 F(x)+C。', analysis:'优先识别基本积分公式，若出现复合结构，使用换元法化简后积分，再求导验证。' },
    { question:'利用定积分求平面图形面积', answer:'面积为上下函数差的定积分。', analysis:'先求交点确定积分区间，再按“上函数减下函数”建立定积分。' },
    { question:'求多元函数的偏导数', answer:'对 x、y 的偏导分别按单变量求导得到。', analysis:'求某一变量偏导时，将其他变量视为常数，逐项使用幂函数和乘积求导规则。' },
    { question:'讨论函数极值并求极值点', answer:'驻点中满足极值判别条件的点为极值点。', analysis:'先令一阶导数为 0 求驻点，再用二阶导数或符号变化判断极值类型。' }
  ],
  'linear-algebra': [
    { question:'计算给定矩阵的行列式', answer:'行列式的值为 -6。', analysis:'使用初等行变换化为上三角矩阵，记录换行和倍乘对行列式值的影响。' },
    { question:'求矩阵的逆矩阵', answer:'逆矩阵为 A⁻¹。', analysis:'将 A 与单位矩阵拼成增广矩阵，通过初等行变换把左侧化为单位矩阵，右侧即逆矩阵。' },
    { question:'判断向量组的线性相关性', answer:'该向量组线性相关。', analysis:'把向量作为列向量组成矩阵，比较矩阵秩与向量个数；秩小于个数则线性相关。' },
    { question:'求矩阵的秩', answer:'矩阵的秩为 3。', analysis:'通过初等行变换化为阶梯形矩阵，非零行的个数就是矩阵的秩。' },
    { question:'解非齐次线性方程组', answer:'通解为一个特解加齐次方程组基础解系的线性组合。', analysis:'先判断系数矩阵与增广矩阵秩是否相等，再求特解和对应齐次解。' },
    { question:'求矩阵的特征值', answer:'特征值为 λ₁、λ₂、λ₃。', analysis:'由 |λE-A|=0 建立特征方程，求出全部根即为特征值。' },
    { question:'求特征向量并判断可对角化性', answer:'当线性无关特征向量个数等于矩阵阶数时可对角化。', analysis:'对每个特征值求解 (A-λE)x=0，统计基础解系维数并判断。' },
    { question:'将二次型化为标准形', answer:'标准形为若干平方项的线性组合。', analysis:'可使用配方法或正交变换，目标是消去交叉项并保留惯性指数。' }
  ],
  probability: [
    { question:'计算随机事件的概率', answer:'事件概率为 0.36。', analysis:'先明确样本空间与目标事件，若事件互斥可直接相加，若独立则使用乘法公式。' },
    { question:'利用条件概率公式求解', answer:'条件概率为 P(A|B)=P(AB)/P(B)。', analysis:'确定条件事件 B 且 P(B)>0，再把同时发生的概率除以条件事件概率。' },
    { question:'求随机变量的分布函数', answer:'分布函数 F(x)=P(X≤x)。', analysis:'按随机变量取值范围分段讨论，累加或积分得到不超过 x 的概率。' },
    { question:'计算数学期望和方差', answer:'期望为 E(X)，方差为 D(X)=E(X²)-[E(X)]²。', analysis:'离散型用求和，连续型用积分，方差建议用二阶矩公式简化计算。' },
    { question:'求二维随机变量的边缘分布', answer:'边缘分布由联合分布对另一变量求和或积分得到。', analysis:'固定一个变量，把另一个变量在全部取值范围内消去即可。' },
    { question:'判断随机变量的独立性', answer:'若联合分布等于边缘分布乘积，则相互独立。', analysis:'逐点或在定义域内验证 f(x,y)=fX(x)fY(y)，不成立则不独立。' },
    { question:'利用中心极限定理估计概率', answer:'标准化后用正态分布表近似。', analysis:'把样本和或均值标准化为 Z 变量，再查询标准正态分布概率。' },
    { question:'计算总体参数的置信区间', answer:'置信区间为点估计 ± 临界值 × 标准误。', analysis:'根据方差是否已知和样本量大小选择 Z 分布或 t 分布临界值。' }
  ]
}
function buildKnowledgeQuestionRows() {
  const baseRate = allKnowledgePoints.value.find(item => item.name === selectedKnowledgeName.value)?.rate || profile.value.rate
  return questionTemplates[selectedSubject.value].map((question, index) => {
    const rate = Math.max(20, Math.min(98, Number((baseRate + [4,-9,2,-15,6,-5,1,-12][index]).toFixed(1))))
    return {
      id: `Q${String(index + 1).padStart(3, '0')}`,
      question: question.question,
      answer: question.answer,
      analysis: question.analysis,
      type: ['选择题','填空题','计算题','选择题','计算题','证明题','填空题','应用题'][index],
      correct: index % 3 !== 1,
      rate,
      attempts: [3,5,2,4,3,6,2,4][index],
      lastDate: ['2024-05-31','2024-05-30','2024-05-29','2024-05-28','2024-05-27','2024-05-25','2024-05-23','2024-05-21'][index]
    }
  })
}
const knowledgeQuestionRows = computed(() => {
  return buildKnowledgeQuestionRows()
})
const questionAttemptTotal = computed(() => knowledgeQuestionRows.value.reduce((sum, row) => sum + row.attempts, 0))
const questionAverageRate = computed(() => (knowledgeQuestionRows.value.reduce((sum, row) => sum + row.rate, 0) / knowledgeQuestionRows.value.length).toFixed(1))

function openKnowledgeQuestionDetail(row: Record<string, unknown>, fromOverview = false) {
  selectedKnowledgeName.value = String(row.knowledgeName || row.name || '').trim()
  selectedQuestionRow.value = null
  questionDialogFromOverview.value = fromOverview
  questionDialogReturnTarget.value = fromOverview ? 'knowledge' : ''
  if (fromOverview) knowledgeDialogVisible.value = false
  questionDialogVisible.value = true
}

function handleQuestionDialogBack() {
  questionDialogVisible.value = false
  selectedQuestionRow.value = null
  if (questionDialogFromOverview.value) {
    if (questionDialogReturnTarget.value === 'mistake') mistakeKnowledgeDialogVisible.value = true
    else knowledgeDialogVisible.value = true
    questionDialogFromOverview.value = false
    questionDialogReturnTarget.value = ''
  }
}

function resetQuestionDialogSource() {
  if (!knowledgeDialogVisible.value && !mistakeKnowledgeDialogVisible.value) {
    questionDialogFromOverview.value = false
    questionDialogReturnTarget.value = ''
  }
}

function openSingleQuestionDetail(row: ReturnType<typeof buildKnowledgeQuestionRows>[number]) {
  selectedQuestionRow.value = row
  singleQuestionDialogVisible.value = true
}

function practiceKnowledgePoint() {
  router.push({
    name: 'practiceSession',
    query: {
      mode: 'knowledge',
      subject: selectedSubject.value,
      knowledge: selectedKnowledgeName.value,
      count: String(knowledgeQuestionRows.value.length)
    }
  })
}

const mistakeTrendData: Record<PeriodKey, { labels: string[]; values: number[] }> = {
  '7d': { labels: ['05-25','05-26','05-27','05-28','05-29','05-30','05-31'], values: [17,23,19,21,24,24,25] },
  '30d': { labels: dates, values: [22,18,20,16,15,20,13,17,23,20,25] },
  '1y': { labels: ['2023-06','2023-07','2023-08','2023-09','2023-10','2023-11','2023-12','2024-01','2024-02','2024-03','2024-04','2024-05'], values: [36,34,32,31,29,27,25,24,22,21,19,18] }
}
const mistakeTrend = computed<EChartsOption>(() => {
  const data = mistakeTrendData[mistakePeriod.value]
  const factor = profile.value.mistakes / 186
  const values = data.values.map(value => Math.max(1, Number((value * factor).toFixed(1))))
  return { grid:baseGrid,xAxis:{type:'category',data:data.labels,...axis},yAxis:{type:'value',max:mistakePeriod.value === '1y' ? 45 : 40,...axis},series:[lineSeries('错题数',values,'#ff6268')] }
})
const mistakeSourceCounts = computed(() => [Math.round(profile.value.mistakes*.55),Math.round(profile.value.mistakes*.34),profile.value.mistakes-Math.round(profile.value.mistakes*.55)-Math.round(profile.value.mistakes*.34)])
const mistakeSourceLegend = computed(() => [{color:palette[0],label:'按试卷刷题',value:`${mistakeSourceCounts.value[0]}题（55%）`},{color:'#ff7743',label:'按章节刷题',value:`${mistakeSourceCounts.value[1]}题（34%）`},{color:palette[2],label:'错题重做',value:`${mistakeSourceCounts.value[2]}题（11%）`}])
const mistakeSourceDonut = computed(() => donut(mistakeSourceLegend.value.map((r,i)=>({name:r.label,value:mistakeSourceCounts.value[i],color:r.color}))))
const mistakeMasteryLegend = computed(() => [{color:palette[1],label:'已掌握',value:`${profile.value.eliminated}题（${(profile.value.eliminated/profile.value.mistakes*100).toFixed(1)}%）`},{color:palette[4],label:'未掌握',value:`${profile.value.mistakes-profile.value.eliminated}题（${((profile.value.mistakes-profile.value.eliminated)/profile.value.mistakes*100).toFixed(1)}%）`}])
const mistakeMasteryDonut = computed(() => donut([{name:'已掌握',value:profile.value.eliminated,color:palette[1]},{name:'未掌握',value:profile.value.mistakes-profile.value.eliminated,color:palette[4]}]))
const mistakeColumns: Column[] = [{key:'rank',label:''},{key:'name',label:'知识点',width:'38%'},{key:'count',label:'错题数'},{key:'rate',label:'错题率',type:'progress'},{key:'delta',label:'较上期变化',type:'delta'}]
const allMistakeKnowledge = computed(() => allKnowledgePoints.value.map((r,i)=>({
  rank:i+1,
  name:r.name,
  subject:r.subject,
  count:Math.max(3,Math.round((100-r.rate)*.75)),
  rate:Number((100-r.rate).toFixed(1)),
  delta:(i%3===0?'↑ ':'↓ ')+[6.3,5.1,2.4,3.2,1.6,2.1,1.8,.9,1.2,1][i]+'%'
})))
const averageMistakeRate = computed(() =>
  (allMistakeKnowledge.value.reduce((sum, item) => sum + item.rate, 0) / allMistakeKnowledge.value.length).toFixed(1)
)
const mistakeKnowledge = computed(() => allMistakeKnowledge.value.slice(0, 10))
const focusColumns: Column[] = [{key:'question',label:'题目',width:'40%'},{key:'point',label:'所属知识点',type:'tag'},{key:'times',label:'错题次数'},{key:'date',label:'最近错题时间'},{key:'action',label:'操作',type:'mistakeAction'}]
const mistakeQuestions: Record<SubjectKey,string[]> = {
  calculus:['设函数 f(x)=sin x/x，求极限…','设 f(x)=x³-3x+1，求 f′(x).','若 f(x) 在 (a,b) 上可导…','计算 ∫ sin²x dx.','设 z=xy+x²y²，求偏导…','求曲线 y=x³ 在点处切线…'],
  'linear-algebra':['计算三阶行列式的值…','求矩阵 A 的逆矩阵…','判断向量组是否线性相关…','求齐次线性方程组基础解系…','求矩阵的特征值与特征向量…','将二次型化为标准形…'],
  probability:['已知事件 A、B，求条件概率…','求随机变量 X 的分布函数…','计算二维随机变量的边缘分布…','求随机变量的数学期望与方差…','利用中心极限定理求近似概率…','求总体参数的置信区间…']
}
function buildFocusMistakes() {
  return mistakeQuestions[selectedSubject.value].map((q,i)=>({
    question:q,
    point:knowledgeRows.value[i].name,
    times:i<3?'3次':'2次',
    date:['2024-05-29','2024-05-28','2024-05-25','2024-05-27','2024-05-24','2024-05-23'][i],
    answer:['极限为 1。','f′(x)=3x²-3。','应先使用拉格朗日中值定理。','结果为 x/2-sin2x/4+C。','∂z/∂x=y+2xy²，∂z/∂y=x+2x²y。','切线方程由导数斜率代入点斜式得到。'][i],
    analysis:['该题容易错在直接代入得到 0/0 后停止，应使用等价无穷小或洛必达法则。','多项式逐项求导即可，常见错误是常数项和一次项符号处理不稳。','先验证可导与连续条件，再根据题干目标选择中值定理形式。','使用恒等式 sin²x=(1-cos2x)/2 后积分，能避免换元复杂化。','求偏导时另一个变量视作常数，交叉项需要按乘积中的常数因子保留。','先求导得到指定点斜率，再代入点坐标写出直线方程。'][i],
    action:'查看详情'
  }))
}
const focusMistakes = computed(() => buildFocusMistakes())

function openMistakeQuestionDetail(row: ReturnType<typeof buildFocusMistakes>[number]) {
  selectedMistakeQuestion.value = row
  mistakeQuestionDialogVisible.value = true
}

function openMistakeKnowledgeDetail(row: Record<string, unknown>) {
  selectedKnowledgeName.value = String(row.name || '').trim()
  selectedQuestionRow.value = null
  questionDialogFromOverview.value = true
  questionDialogReturnTarget.value = 'mistake'
  mistakeKnowledgeDialogVisible.value = false
  questionDialogVisible.value = true
}

function practiceAllMistakes() {
  router.push({
    name: 'practiceSession',
    query: {
      mode: 'mistake',
      subject: selectedSubject.value,
      count: String(profile.value.mistakes - profile.value.eliminated)
    }
  })
}

const recordColumns: Column[] = [{key:'date',label:'刷题时间',width:'13%'},{key:'mode',label:'刷题方式',type:'mode'},{key:'content',label:'内容',width:'27%'},{key:'count',label:'题数'},{key:'rate',label:'正确率',type:'rate'},{key:'time',label:'用时'},{key:'source',label:'来源'},{key:'action',label:'操作',type:'recordActions'}]
const calculusRecords = [
 ['2024-05-31 20:15','按试卷','2024年全国硕士研究生招生考试数学（一）试题',33,'78.8%','1.28 小时','真题试卷'],
 ['2024-05-31 09:30','按章节','一元函数微分学 / 导数的概念',20,'85.0%','32 分钟','章节练习'],
 ['2024-05-30 21:10','按知识点','线性代数 / 矩阵 / 矩阵的运算',25,'68.0%','45 分钟','知识点练习'],
 ['2024-05-30 14:20','按试卷','数学（一）模拟试卷（五）',35,'71.4%','1.15 小时','模拟试卷'],
 ['2024-05-29 19:45','按收藏','收藏夹 / 不定积分重点题',18,'77.8%','28 分钟','收藏练习'],
 ['2024-05-29 10:05','按错题','错题集 / 随机事件与概率',22,'63.6%','35 分钟','错题重练'],
 ['2024-05-28 22:30','按试卷','数学（一）模拟试卷（四）',34,'64.7%','1.02 小时','模拟试卷'],
 ['2024-05-28 16:40','按知识点','多元函数微分学 / 偏导数与全微分',20,'80.0%','30 分钟','知识点练习'],
 ['2024-05-27 20:00','按章节','空间解析几何 / 平面与直线',15,'86.7%','22 分钟','章节练习'],
 ['2024-05-27 09:15','按收藏','收藏夹 / 2023真题易错题',33,'69.7%','1.20 小时','收藏练习']
] as [string, Exclude<RecordFilter, '全部记录'>, string, number, string, string, string][]
const recordContent: Record<SubjectKey,string[]> = {
  calculus: calculusRecords.map(row => String(row[2])),
  'linear-algebra':['线性代数 / 行列式与矩阵运算','线性代数 / 向量组的线性相关性','线性代数 / 线性方程组','线性代数专项模拟卷（一）','线性代数 / 特征值与特征向量','线性代数 / 二次型','线性代数专项模拟卷（二）','线性代数 / 矩阵的秩','线性代数 / 相似矩阵','线性代数真题训练'],
  probability:['概率统计 / 随机事件与概率','概率统计 / 随机变量及其分布','概率统计 / 数字特征','概率统计专项模拟卷（一）','概率统计 / 二维随机变量','概率统计 / 大数定律','概率统计专项模拟卷（二）','概率统计 / 参数估计','概率统计 / 假设检验','概率统计真题训练']
}
const recordTips: Record<Exclude<RecordFilter, '全部记录'>, string> = {
  '按试卷': '建议复盘整套试卷中的中低正确率题型，优先补齐综合题节奏。',
  '按章节': '本次章节练习完成度较好，可继续巩固相邻章节知识点。',
  '按知识点': '建议围绕该知识点继续做 5-8 道同类题，稳定解题路径。',
  '按收藏': '收藏题复练暴露出部分思路遗忘，可加入每日回顾计划。',
  '按错题': '错题重练仍有波动，建议先看解析再进行同类题强化。'
}
const baseRecordTable = computed<RecordRow[]>(() => calculusRecords.map((row,index)=>({
  id:`base-${selectedSubject.value}-${index}`,
  subject:selectedSubject.value,
  date:row[0],
  mode:row[1],
  content:recordContent[selectedSubject.value][index],
  count:selectedSubject.value==='calculus'?row[3]:Math.max(10,Math.round(Number(row[3])*(selectedSubject.value==='linear-algebra'?.65:.52))),
  rate:index%3===0?(profile.value.rate-3).toFixed(1)+'%':(profile.value.rate+(index%4)*2).toFixed(1)+'%',
  time:selectedSubject.value==='calculus'?row[5]:`${Math.max(18,Math.round(Number(row[3])*2.1))} 分钟`,
  source:row[6],
  tip:recordTips[row[1]]
})))
const recordTable = computed(() => {
  const rows = [...generatedRecords.value.filter(row => row.subject === selectedSubject.value), ...baseRecordTable.value]
  return activeRecordFilter.value === '全部记录' ? rows : rows.filter(row => row.mode === activeRecordFilter.value)
})

function openRecordDetail(row: RecordRow) {
  selectedRecord.value = row
  recordDialogVisible.value = true
}

function repeatRecordPractice(row: RecordRow) {
  const nextIndex = generatedRecords.value.length + 1
  const nextRate = Math.min(98, parseFloat(row.rate) + 2.4).toFixed(1)
  const nextRecord: RecordRow = {
    ...row,
    id:`repeat-${selectedSubject.value}-${Date.now()}-${nextIndex}`,
    date:`刚刚 ${String(nextIndex).padStart(2, '0')}`,
    rate:`${nextRate}%`,
    source:`${row.source} · 再次练习`,
    tip:'已根据本次再次练习生成新记录，可继续查看详情或筛选复盘。'
  }
  generatedRecords.value = [nextRecord, ...generatedRecords.value]
  saveGeneratedRecords()
  recordDialogVisible.value = false
  router.push({
    name:'practiceSession',
    query:{
      mode:row.mode === '按错题' ? 'mistake' : row.mode === '按知识点' ? 'knowledge' : 'record',
      subject:selectedSubject.value,
      count:String(row.count),
      record:row.id
    }
  })
}

function loadGeneratedRecords(): RecordRow[] {
  try {
    const raw = window.sessionStorage.getItem('easy-yan-stat-records')
    return raw ? JSON.parse(raw) as RecordRow[] : []
  } catch {
    return []
  }
}

function saveGeneratedRecords() {
  window.sessionStorage.setItem('easy-yan-stat-records', JSON.stringify(generatedRecords.value))
}

const ChartPanel = defineComponent({ props:{title:String}, setup(props,{slots}) { return()=>h('article',{class:'panel chart-panel'},[h('div',{class:'panel-head'},[h('h2',props.title),slots.actions?.()]),h('div',{class:'chart-body'},slots.default?.())]) } })
const DataPanel = defineComponent({ props:{title:String,link:String}, setup(props,{slots}) { return()=>h('article',{class:'panel data-panel'},[h('div',{class:'panel-head'},[slots.title?.()||h('h2',props.title),h('div',{class:'head-actions'},[slots.actions?.(),props.link?h('a',{class:'link'},props.link+' ›'):null])]),slots.default?.()]) } })
const DonutCenter = defineComponent({ props:{value:String,label:String}, setup:p=>()=>h('div',{class:'donut-center'},[h('strong',p.value),h('span',p.label)]) })
const LegendList = defineComponent({ props:{items:{type:Array,required:true}}, setup:p=>()=>h('div',{class:'legend-list'},(p.items as any[]).map(i=>h('div',[h('i',{style:{background:i.color}}),h('span',i.label),h('strong',i.value)]))) })
const PeriodSwitch = defineComponent({
  props: { modelValue: { type: String, default: '30d' } },
  emits: ['update:modelValue'],
  setup: (props, { emit }) => () => h('div', { class: 'period-switch' }, [
    ['7d', '近7天'], ['30d', '近30天'], ['1y', '近1年']
  ].map(([value, label]) => h('button', {
    type: 'button',
    class: { active: props.modelValue === value },
    onClick: () => emit('update:modelValue', value)
  }, label)))
})
const MetricCards = defineComponent({ props:{items:{type:Array,required:true},dense:Boolean}, setup:p=>()=>h('div',{class:['metric-grid',p.dense?'dense':'']},(p.items as Metric[]).map(item=>h('article',{class:'panel metric-card'},[h('span',{class:'metric-icon',style:{color:item.color,background:item.color+'18'}},[h(icons[item.icon] as any)]),h('div',[h('small',item.label),h('strong',[item.value,h('em',item.unit)]),h('p',['较上期　',h('b',{class:item.positive?'up':'down'},item.delta)])])])) ) })
const StandardTable = defineComponent({
  props: { columns: { type: Array, required: true }, rows: { type: Array, required: true } },
  setup: p => () => h('div', { class: 'standard-table' }, [
    h('div', { class: 'standard-head' }, (p.columns as Column[]).map(c =>
      h('span', { style: { width: c.width } }, c.label)
    )),
    ...(p.rows as any[]).map(row =>
      h('div', { class: 'standard-row' }, (p.columns as Column[]).map(c =>
        h('span', { style: { width: c.width }, class: `cell-${c.type || 'text'}` }, renderCell(row[c.key], c.type, row))
      ))
    )
  ])
})
function renderCell(value:any,type?:string,row?:Record<string,unknown>) {
  if(type==='progress') return [h('i',{class:'bar'},[h('i',{style:{width:`${parseFloat(value)}%`}})]),h('em',typeof value==='number'?value+'%':value)]
  if(type==='delta') return h('b',{class:String(value).includes('↑')?'up':'down'},value)
  if(type==='tag') return h('i',{class:'table-tag'},value)
  if(type==='mode') return h('i',{class:['table-tag','mode-tag',modeTagClass(String(value))]},value)
  if(type==='link') return h('a',{class:'link'},value)
  if(type==='knowledgeAction') return h('button',{type:'button',class:'table-link-button',onClick:()=>openKnowledgeQuestionDetail(row || {})},value)
  if(type==='mistakeAction') return h('button',{type:'button',class:'table-link-button',onClick:()=>openMistakeQuestionDetail(row as ReturnType<typeof buildFocusMistakes>[number])},value)
  if(type==='recordActions') return h('span',{class:'table-actions'},[
    h('button',{type:'button',class:'table-action-button detail',onClick:()=>openRecordDetail(row as RecordRow)},'查看详情'),
    h('button',{type:'button',class:'table-action-button repeat',onClick:()=>repeatRecordPractice(row as RecordRow)},'再次练习')
  ])
  if(type==='rate') return h('b',{class:parseFloat(value)>=75?'up':'warning'},value)
  if(type==='actions') return h('span',{class:'table-actions'},value)
  if(type==='spark') return h('i',{class:'spark'},value)
  return String(value)
}
function modeTagClass(value: string) {
  return {
    '按试卷':'paper',
    '按章节':'chapter',
    '按知识点':'knowledge',
    '按收藏':'favorite',
    '按错题':'mistake'
  }[value] || 'default'
}
const Pagination = defineComponent({ props:{total:String,pages:String}, setup:p=>()=>h('div',{class:'pagination'},[h('span',p.total),h('div',[h('button',{class:'page-size'},'10 条/页　⌄'),h('button','‹'),h('button',{class:'active'},'1'),h('button','2'),h('button','3'),h('button','4'),h('button','5'),h('span','…'),h('button',p.pages),h('button','›')])]) })
</script>

<style lang="scss">
.statistics-page { color:var(--text); }
.statistics-page > h1 { margin:0 0 8px; color:var(--ink); font-size:22px; }
.tabs { display:flex; gap:28px; height:48px; margin-bottom:16px; border-bottom:1px solid var(--line); }
.tabs button { position:relative; padding:0 6px; color:var(--ink); font:inherit; font-weight:650; border:0; background:none; }
.tabs button.active { color:var(--primary); }
.tabs button.active::after { position:absolute; right:0; bottom:-1px; left:0; height:2px; content:''; background:var(--primary); }
.subheading { margin:0 0 12px; color:var(--ink); font-size:16px; }
.metric-grid { display:grid; grid-template-columns:repeat(5,1fr); gap:14px; margin-bottom:14px; }
.metric-grid.dense { grid-template-columns:repeat(6,1fr); }
.metric-card { display:flex; align-items:center; gap:14px; min-width:0; height:118px; padding:18px; box-shadow:none; }
.metric-grid.dense .metric-card { padding:14px; }
.metric-icon { display:inline-flex; align-items:center; justify-content:center; flex:none; width:46px; height:46px; border-radius:50%; font-size:25px; }
.metric-card small,.ability-card small { color:var(--text); font-size:12px; }
.metric-card strong,.ability-card strong { display:block; margin:7px 0 5px; color:#111; font-size:24px; line-height:1; }
.metric-card em,.ability-card em { margin-left:3px; color:var(--text); font-size:12px; font-style:normal; }
.metric-card p,.ability-card p { margin:0; font-size:12px; }
.up { color:#00ad63!important; }.down { color:#ff3038!important; }.warning { color:#ff8a00!important; }
.overview-grid { display:grid; grid-template-columns:1.4fr .68fr .98fr; grid-template-rows:272px 350px; gap:14px; }
.trend-card { grid-column:span 2; }
.chart-panel,.data-panel { min-width:0; overflow:hidden; padding:16px; box-shadow:none; }
.panel-head { display:flex; align-items:center; min-height:24px; margin-bottom:8px; }
.panel-head h2 { flex:1; margin:0; color:var(--ink); font-size:15px; }
.head-actions { display:flex; align-items:center; gap:12px; margin-left:auto; }
.detail-link { padding:0; color:var(--primary); font:inherit; font-size:12px; font-weight:700; border:0; background:none; }
.chart-body { position:relative; height:calc(100% - 32px); min-height:160px; }
.period-switch { display:flex; }
.period-switch button,.select-btn { height:28px; padding:0 12px; color:var(--text); font:inherit; font-size:12px; border:1px solid var(--line); background:#fff; }
.period-switch button:first-child { border-radius:5px 0 0 5px; }.period-switch button:last-child { border-radius:0 5px 5px 0; }
.period-switch button.active { color:var(--primary); border-color:#7ba0ff; }
.donut-layout { display:flex; align-items:center; justify-content:center; gap:28px; height:100%; }
.donut-layout.fill { height:calc(100% - 4px); }
.donut { position:relative; flex:none; width:190px; height:190px; }.donut.small { width:155px; height:155px; }
.donut-center { position:absolute; inset:0; display:flex; flex-direction:column; align-items:center; justify-content:center; pointer-events:none; }
.donut-center strong { color:#111; font-size:26px; }.donut-center span { color:var(--muted); font-size:12px; text-align:center; white-space:pre-line; }
.legend-list { display:flex; flex-direction:column; gap:20px; min-width:190px; }
.legend-list div { display:grid; grid-template-columns:8px 1fr auto; align-items:center; gap:8px; font-size:12px; }
.legend-list i { width:8px; height:8px; border-radius:50%; }.legend-list strong { color:var(--ink); font-weight:500; }
.mini-table,.ranking-list { font-size:12px; }.table-head,.table-row { display:grid; grid-template-columns:1.2fr .7fr 1.4fr; align-items:center; min-height:38px; }
.table-head { color:var(--muted); }.table-row strong { color:var(--ink); }
.bar { display:inline-block; width:72px; height:4px; margin-left:10px; overflow:hidden; vertical-align:middle; background:#e8ecf5; border-radius:3px; }
.bar i { display:block; height:100%; background:#3673ff; border-radius:3px; }
.ranking-list > div { display:grid; grid-template-columns:20px 1fr 70px 42px; align-items:center; min-height:27px; gap:6px; }
.ranking-list strong { overflow:hidden; color:var(--ink); font-weight:500; text-overflow:ellipsis; white-space:nowrap; }.ranking-list em { color:var(--ink); font-style:normal; text-align:right; }
.page-note { margin:18px 0 0; color:#7684b0; font-size:12px; text-align:center; }
.ability-summary { display:grid; grid-template-columns:220px repeat(5,1fr); align-items:center; gap:18px; min-height:220px; padding:20px; box-shadow:none; }
.ability-donut { justify-self:center; }
.ability-card { display:grid; grid-template-columns:48px 1fr; gap:10px; min-height:150px; padding:18px; border:1px solid var(--line); border-radius:8px; }
.ability-card p { grid-column:span 2; padding-left:4px; }
.two-charts { display:grid; grid-template-columns:1.6fr .9fr; gap:14px; height:270px; margin:14px 0; }
.standard-table { width:100%; font-size:12px; }
.standard-head,.standard-row { display:flex; align-items:center; min-height:39px; border-bottom:1px solid #edf0f7; }
.standard-head { color:var(--muted); }.standard-row { color:var(--ink); }
.standard-head > span,.standard-row > span { flex:1; min-width:0; padding:0 10px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
.cell-progress { display:flex; align-items:center; gap:6px; }.cell-progress .bar { margin:0; }.cell-progress em { font-style:normal; }
.table-link-button { padding:0; color:var(--primary); font:inherit; font-size:12px; font-weight:700; border:0; background:none; }
.table-tag { display:inline-flex; width:max-content; max-width:100%; height:24px; align-items:center; padding:0 8px; color:#ff5260; font-style:normal; background:#fff0f2; border-radius:4px; }
.table-tag.green { color:#0bac67; background:#eaf9f1; }.spark { color:#16ba78; font-size:18px; font-style:normal; letter-spacing:1px; }
.table-actions { display:inline-flex; align-items:center; gap:8px; color:#33458b; font-size:11px; }
.table-action-button { height:26px; padding:0 10px; color:var(--primary); font:inherit; font-size:12px; border:1px solid #cfe0ff; border-radius:999px; background:#f5f8ff; transition:.16s ease; }
.table-action-button:hover { border-color:#7ba0ff; background:#edf4ff; transform:translateY(-1px); }
.table-action-button.repeat { color:#0aa466; border-color:#bdebd8; background:#f0fbf6; }
.table-action-button.repeat:hover { border-color:#70d7ad; background:#e7f8f0; }
.type-charts { grid-template-columns:.9fr 1.1fr; height:295px; }
.type-bottom { display:grid; grid-template-columns:1.45fr .9fr; gap:14px; height:305px; }
.knowledge-charts { display:grid; grid-template-columns:1.25fr 1fr; gap:14px; height:275px; margin-bottom:14px; }
.table-search { width:180px; height:30px; padding:7px 10px; color:var(--muted); font-size:12px; border:1px solid var(--line); border-radius:5px; }
.table-search.wide { width:270px; }.select-btn { border-radius:5px; }
.chapter-filter { width:190px; }
.knowledge-search { width:210px; }
.chapter-filter .el-select__wrapper,.knowledge-search .el-input__wrapper { min-height:32px; border-radius:6px; box-shadow:0 0 0 1px var(--line) inset; }
.chapter-filter .el-select__selected-item,.knowledge-search .el-input__inner { color:var(--ink); font-size:12px; }
.table-empty { display:flex; align-items:center; justify-content:center; height:100px; color:var(--muted); font-size:13px; border-bottom:1px solid var(--line); }
.pagination { display:flex; align-items:center; justify-content:space-between; padding-top:16px; color:#425187; font-size:12px; }
.pagination > div { display:flex; align-items:center; gap:8px; }.pagination button { min-width:34px; height:32px; color:var(--ink); border:1px solid var(--line); border-radius:5px; background:#fff; }
.pagination button.active { color:var(--primary); border-color:#6d94ff; }.pagination .page-size { width:92px; margin-right:10px; }
.mistake-charts { display:grid; grid-template-columns:1.2fr .8fr .9fr; gap:14px; height:235px; margin-bottom:14px; }
.mistake-bottom { display:grid; grid-template-columns:.95fr 1.25fr; gap:14px; height:410px; }
.record-filters { display:flex; gap:8px; flex-wrap:wrap; }.record-filters button,.export-btn { height:34px; padding:0 16px; color:var(--text); font:inherit; font-size:12px; border:1px solid var(--line); border-radius:5px; background:#fff; }
.record-filters button.active { color:var(--primary); border-color:#7ba0ff; }.export-btn { color:var(--primary); }
.records-panel .standard-row,.records-panel .standard-head { min-height:51px; }
.records-panel { padding:12px; }
.mode-tag { border-radius:999px; }
.mode-tag.paper { color:#245df5; background:#eef4ff; }
.mode-tag.chapter { color:#0b9f61; background:#eaf8f1; }
.mode-tag.knowledge { color:#7b4cf1; background:#f3efff; }
.mode-tag.favorite { color:#f08a00; background:#fff5e6; }
.mode-tag.mistake { color:#f0525c; background:#fff0f1; }
.record-detail-dialog .el-dialog__header { margin-right:0; padding:20px 24px 14px; border-bottom:1px solid var(--line); }
.record-detail-dialog .el-dialog__title { color:var(--ink); font-size:18px; font-weight:800; }
.record-detail-dialog .el-dialog__body { padding:18px 24px 8px; }
.record-detail-dialog .el-dialog__footer { padding:14px 24px 20px; border-top:1px solid var(--line); }
.record-detail-title { display:flex; align-items:center; justify-content:space-between; gap:12px; margin-bottom:14px; }
.record-detail-title strong { color:var(--ink); font-size:16px; }
.record-detail-title span { flex:none; height:24px; padding:0 10px; color:var(--primary); font-size:12px; line-height:24px; border-radius:999px; background:#eef4ff; }
.record-detail-title span.green { color:#0b9f61; background:#eaf8f1; }
.record-summary-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:10px; margin-bottom:14px; }
.record-summary-grid div { padding:12px 14px; border:1px solid #e8edfa; border-radius:8px; background:#f8faff; }
.record-summary-grid span { display:block; margin-bottom:8px; color:var(--muted); font-size:12px; }
.record-summary-grid strong { color:var(--ink); font-size:18px; }
.record-summary-grid em { margin-left:3px; color:var(--text); font-size:12px; font-style:normal; }
.record-detail-list { border:1px solid var(--line); border-radius:8px; overflow:hidden; }
.record-detail-list p { display:grid; grid-template-columns:96px 1fr; gap:12px; margin:0; padding:12px 14px; border-bottom:1px solid #edf0f7; font-size:13px; }
.record-detail-list p:last-child { border-bottom:0; }
.record-detail-list span { color:var(--muted); }
.record-detail-list strong { color:var(--ink); font-weight:600; }
.knowledge-dialog .el-dialog__header { margin-right:0; padding:20px 24px 14px; border-bottom:1px solid var(--line); }
.knowledge-dialog .el-dialog__title { color:var(--ink); font-size:18px; font-weight:800; }
.knowledge-dialog .el-dialog__body { padding:16px 24px 24px; }
.dialog-summary { display:flex; justify-content:space-between; margin-bottom:12px; color:var(--muted); font-size:13px; }
.dialog-summary strong { color:var(--primary); font-size:15px; }
.knowledge-detail-table { max-height:530px; overflow:auto; border:1px solid var(--line); border-radius:7px; }
.knowledge-detail-head,.knowledge-detail-row { display:grid; grid-template-columns:58px 1.5fr .9fr 82px 150px 74px; align-items:center; min-height:42px; padding:0 14px; border-bottom:1px solid #edf0f7; font-size:12px; column-gap:8px; }
.knowledge-detail-head { position:sticky; top:0; z-index:1; color:var(--muted); background:#f8faff; }
.knowledge-detail-row:last-child { border-bottom:0; }
.knowledge-detail-row strong { overflow:hidden; color:var(--ink); text-overflow:ellipsis; white-space:nowrap; }
.detail-rate { display:flex; align-items:center; justify-content:space-between; }
.detail-rate .bar { width:82px; margin:0; }
.detail-rate.mistake-rate .bar i { background:#ff6268; }
.detail-rate em { color:var(--ink); font-style:normal; }
.question-detail-dialog .el-dialog__header { margin-right:0; padding:20px 24px 14px; border-bottom:1px solid var(--line); }
.question-detail-dialog .el-dialog__title { color:var(--ink); font-size:18px; font-weight:800; }
.question-detail-dialog .el-dialog__body { padding:18px 24px 8px; }
.question-detail-dialog .el-dialog__footer { padding:14px 24px 20px; border-top:1px solid var(--line); }
.question-summary { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:16px; }
.question-summary > div { min-height:72px; padding:13px 16px; background:#f7f9ff; border:1px solid #e8edfa; border-radius:7px; }
.question-summary span { display:block; margin-bottom:8px; color:var(--muted); font-size:12px; }
.question-summary strong { color:var(--ink); font-size:22px; }
.question-summary em { margin-left:4px; color:var(--text); font-size:12px; font-style:normal; }
.question-summary .summary-date { font-size:16px; }
.question-detail-table { max-height:465px; overflow:auto; border:1px solid var(--line); border-radius:7px; }
.question-detail-head,.question-detail-row { display:grid; grid-template-columns:minmax(285px,2.5fr) .65fr .7fr 1.1fr .7fr .9fr .7fr; align-items:center; min-height:48px; padding:0 14px; border-bottom:1px solid #edf0f7; column-gap:8px; font-size:12px; }
.question-detail-head { position:sticky; top:0; z-index:1; min-height:40px; color:var(--muted); background:#f8faff; }
.question-detail-row:last-child { border-bottom:0; }
.question-content { display:flex; align-items:center; gap:9px; min-width:0; }
.question-content > i { flex:none; color:var(--muted); font-size:11px; font-style:normal; }
.question-content strong { overflow:hidden; color:var(--ink); font-weight:600; text-overflow:ellipsis; white-space:nowrap; }
.result-tag { display:inline-flex; align-items:center; height:22px; padding:0 8px; font-size:11px; font-style:normal; border-radius:4px; }
.result-tag.correct { color:#0aa466; background:#e9f8f1; }
.result-tag.incorrect { color:#f0525c; background:#fff0f1; }
.question-rate { display:flex; align-items:center; gap:7px; }
.question-rate .bar { width:58px; margin:0; }
.question-rate em { color:var(--ink); font-style:normal; }
.question-action { padding:0; color:var(--primary); font:inherit; font-size:12px; border:0; background:none; }
.dialog-close-btn,.dialog-practice-btn { height:34px; padding:0 18px; font:inherit; font-size:13px; border-radius:6px; }
.dialog-close-btn { color:var(--text); border:1px solid var(--line); background:#fff; }
.dialog-practice-btn { margin-left:10px; color:#fff; border:1px solid var(--primary); background:var(--primary); }
.single-question-dialog .el-dialog__header { margin-right:0; padding:20px 24px 14px; border-bottom:1px solid var(--line); }
.single-question-dialog .el-dialog__title { color:var(--ink); font-size:18px; font-weight:800; }
.single-question-dialog .el-dialog__body { padding:18px 24px 8px; }
.single-question-dialog .el-dialog__footer { padding:14px 24px 20px; border-top:1px solid var(--line); }
.single-question-meta { display:flex; gap:8px; margin-bottom:14px; }
.single-question-meta span { height:24px; padding:0 10px; color:var(--primary); font-size:12px; line-height:24px; background:#eef3ff; border-radius:999px; }
.analysis-block { padding:14px 16px; margin-bottom:12px; border:1px solid #e8edfa; border-radius:8px; background:#fbfcff; }
.analysis-block h3 { margin:0 0 8px; color:var(--ink); font-size:14px; }
.analysis-block p { margin:0; color:var(--text); line-height:1.8; }
.analysis-block.answer { background:#f7fbff; }
@media (max-width:1400px) {
  .metric-card { padding:12px; gap:9px; }.metric-icon { width:40px;height:40px }.metric-card strong { font-size:20px; }
  .ability-summary { grid-template-columns:180px repeat(5,1fr);gap:10px }.ability-card { padding:12px; }
}
</style>
