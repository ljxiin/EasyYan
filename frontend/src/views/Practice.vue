<template>
  <section v-if="!isSession" class="practice-page panel">
    <template v-if="mode === 'paper'">
      <div class="page-intro">
        <h2>按试卷刷题</h2>
        <p>选择试卷开始刷题，真题和模拟题全覆盖</p>
      </div>

      <div class="paper-tabs">
        <button
          v-for="tab in paperTabs"
          :key="tab"
          type="button"
          :class="{ active: activePaperTab === tab }"
          @click="activePaperTab = tab"
        >
          {{ tab }}
        </button>
        <RouterLink
          v-if="activePaperTab === '自定义组卷'"
          :to="{ name: 'customPaper' }"
          class="create-paper-button"
        >
          <el-icon><Plus /></el-icon>
          新增组卷
        </RouterLink>
        <el-date-picker
          v-model="selectedPaperYear"
          type="year"
          value-format="YYYY"
          format="YYYY 年"
          clearable
          placeholder="全部年份"
          popper-class="paper-year-popper"
          class="year-select"
          :class="{ 'with-create': activePaperTab === '自定义组卷' }"
        />
      </div>

      <div class="paper-head paper-grid">
        <span>试卷名称</span><span>题量</span><span>难度</span><span>操作</span>
      </div>
      <article v-for="paper in filteredPapers" :key="paper.name" class="paper-row paper-grid">
        <div class="paper-name">
          <strong>{{ paper.name }}</strong>
          <span class="paper-tag" :class="`tag-${paper.source}`">{{ paper.source }}</span>
          <small>{{ paper.year }}</small>
        </div>
        <span>{{ paper.count }} 题</span>
        <div class="stars">
          <el-icon v-for="n in 5" :key="n" :class="{ filled: n <= paper.difficulty }"><StarFilled /></el-icon>
        </div>
        <button type="button" class="outline-button" @click="startSession">开始刷题</button>
      </article>

      <footer class="paper-footer">
        <span>共 {{ filteredPapers.length }} 套试卷</span>
        <div class="pagination">
          <button class="page-size">10 条/页 <el-icon><ArrowDown /></el-icon></button>
          <button>‹</button><button class="active">1</button><button>2</button><button>3</button><button>4</button>
          <button>5</button><button>…</button><button>6</button><button>›</button>
        </div>
      </footer>
    </template>

    <template v-else-if="mode === 'chapter'">
      <div class="page-intro">
        <h2>按章节刷题</h2>
        <p>选择章节开始刷题，系统将根据章节内容智能组题</p>
      </div>
      <div class="chapter-list">
        <article v-for="chapter in chapters" :key="chapter.title" class="chapter-card">
          <div class="chapter-main" @click="chapter.open = !chapter.open">
            <el-icon class="chapter-arrow"><ArrowDown v-if="chapter.open" /><ArrowRight v-else /></el-icon>
            <strong>{{ chapter.title }}</strong>
            <div class="chapter-meta"><span>题量　{{ chapter.count }} 题</span><i></i><span>正确率 {{ chapter.rate }}%</span></div>
            <button type="button" class="outline-button" @click.stop="startSession">开始刷题</button>
          </div>
          <div v-if="chapter.open" class="chapter-sections">
            <div v-for="section in chapter.sections" :key="section.name" class="section-row">
              <span>{{ section.name }}</span>
              <div class="chapter-meta"><span>{{ section.count }} 题</span><i></i><span>正确率 {{ section.rate }}%</span></div>
              <button type="button" class="outline-button" @click="startSession">开始刷题</button>
            </div>
          </div>
        </article>
      </div>
    </template>

    <template v-else-if="mode === 'knowledge'">
      <div class="page-intro knowledge-intro">
        <div>
          <h2>按知识点刷题</h2>
          <p>选择知识点进行专项训练，系统将围绕考点智能推荐题目</p>
        </div>
        <button type="button" class="primary-button" @click="startSession">开始综合练习</button>
      </div>

      <div class="knowledge-toolbar">
        <div class="knowledge-search">
          <span>⌕</span>
          <input v-model="knowledgeSearch" type="text" placeholder="搜索知识点名称、章节或标签" />
        </div>
        <button
          v-for="filter in knowledgeDifficultyFilters"
          :key="filter"
          type="button"
          :class="{ active: activeKnowledgeDifficulty === filter }"
          @click="activeKnowledgeDifficulty = filter"
        >
          {{ filter }}
        </button>
      </div>

      <div class="knowledge-overview">
        <article v-for="card in knowledgeOverview" :key="card.label">
          <span>{{ card.label }}</span>
          <strong>{{ card.value }}</strong>
          <small>{{ card.note }}</small>
        </article>
      </div>

      <div class="knowledge-list">
        <article v-for="group in filteredKnowledgeGroups" :key="group.title" class="knowledge-card">
          <div class="knowledge-card-head">
            <div>
              <strong>{{ group.title }}</strong>
              <span>{{ group.desc }}</span>
            </div>
            <div class="knowledge-group-meta">
              <span>题量 {{ group.total }} 题</span>
              <i></i>
              <span>平均正确率 {{ group.rate }}%</span>
            </div>
          </div>
          <div class="knowledge-point-list">
            <div v-for="point in group.points" :key="point.name" class="knowledge-point-row">
              <div class="point-title">
                <span class="point-dot" :class="point.level"></span>
                <div>
                  <strong>{{ point.name }}</strong>
                  <small>{{ point.chapter }}</small>
                </div>
              </div>
              <div class="point-tags">
                <span>{{ point.type }}</span>
                <span :class="`difficulty-${point.level}`">{{ point.difficulty }}</span>
              </div>
              <div class="point-progress">
                <div class="progress-text"><span>掌握度</span><b>{{ point.mastery }}%</b></div>
                <el-progress :percentage="point.mastery" :show-text="false" :stroke-width="6" />
              </div>
              <div class="point-meta">
                <span>{{ point.count }} 题</span>
                <span>正确率 {{ point.rate }}%</span>
              </div>
              <button type="button" class="outline-button" @click="startSession">开始刷题</button>
            </div>
          </div>
        </article>
      </div>
    </template>

    <template v-else>
      <div class="page-intro question-list-intro">
        <div>
          <h2>{{ mode === 'favorite' ? '按收藏刷题' : '按错题刷题' }}</h2>
          <p>{{ mode === 'favorite' ? '集中练习已收藏的重点题目，巩固核心考点' : '重新练习历史错题，针对薄弱环节逐个击破' }}</p>
        </div>
        <button
          type="button"
          class="primary-button"
          :disabled="selectedQuestionIds.length === 0"
          @click="startSession"
        >
          {{ mode === 'favorite' ? '开始收藏练习' : '开始错题练习' }}
          <span v-if="selectedQuestionIds.length">（{{ selectedQuestionIds.length }}）</span>
        </button>
      </div>

      <div class="question-filter">
        <div class="question-summary">
          <strong>{{ filteredQuestions.length }}</strong>
          <span>{{ mode === 'favorite' ? '道收藏题目' : '道待复习错题' }}</span>
        </div>
        <button type="button" class="select-all-button" :class="{ active: allQuestionsSelected }" @click="toggleSelectAll">
          <span class="check-box" :class="{ checked: allQuestionsSelected, partial: someQuestionsSelected }">
            {{ allQuestionsSelected ? '✓' : someQuestionsSelected ? '−' : '' }}
          </span>
          全选
        </button>
        <div class="list-sort">最近更新 <el-icon><ArrowDown /></el-icon></div>
      </div>

      <div class="saved-question-list">
        <article v-for="(question, index) in filteredQuestions" :key="question.id" class="saved-question">
          <label class="question-checkbox" :aria-label="`选择第 ${index + 1} 题`">
            <input
              type="checkbox"
              :checked="selectedQuestionIds.includes(question.id)"
              @change="toggleQuestion(question.id)"
            />
            <span>✓</span>
          </label>
          <div class="question-number">{{ index + 1 }}</div>
          <div class="saved-question-body">
            <div class="saved-question-meta">
              <span class="question-type">{{ question.type }}</span>
              <span>{{ question.chapter }}</span>
              <span>难度：{{ question.difficulty }}</span>
              <span v-if="mode === 'mistake'" class="wrong-count">错过 {{ question.wrongCount }} 次</span>
              <span v-else>收藏于 {{ question.date }}</span>
            </div>
            <h3 v-html="renderLatex(question.title)"></h3>
            <div class="saved-tags">
              <span v-for="tag in question.tags" :key="tag">{{ tag }}</span>
            </div>
          </div>
          <div class="saved-question-actions">
            <button v-if="mode === 'favorite'" type="button" class="text-action" @click="removeFavoriteQuestion(question.id)">
              <el-icon><StarFilled /></el-icon>取消收藏
            </button>
            <button v-else type="button" class="text-action success-action" @click="markMistakeMastered(question.id)">
              <el-icon><CircleCheck /></el-icon>标记已掌握
            </button>
            <button type="button" class="outline-button" @click="startSession">开始练习</button>
          </div>
        </article>
      </div>

      <footer class="saved-list-footer">
        <span>共 {{ filteredQuestions.length }} 道题，已选择 {{ selectedQuestionIds.length }} 道</span>
        <div class="pagination">
          <button>‹</button><button class="active">1</button><button>2</button><button>3</button>
          <button>…</button><button>6</button><button>›</button>
          <button class="page-size">10 条/页 <el-icon><ArrowDown /></el-icon></button>
        </div>
      </footer>
    </template>
  </section>

  <section v-else class="session-page">
    <main class="session-main">
      <div class="session-titlebar">
        <button type="button" class="back-button" @click="backToPracticeHome"><el-icon><ArrowLeft /></el-icon>返回</button>
        <div>
          <h2>{{ sessionTitle }} <span>{{ sessionBadge }}</span></h2>
          <p>{{ sessionMeta }}</p>
        </div>
      </div>

      <article class="question-card panel">
        <div class="question-tools">
          <div class="question-index"><strong>1</strong><span>/ 22</span></div>
          <span class="type-tag">单选题</span><span class="score-note">（每题 4 分，共 32 分）</span>
          <div class="tool-buttons">
            <button><el-icon><Star /></el-icon>收藏</button><button><el-icon><EditPen /></el-icon>笔记</button><button><el-icon><Warning /></el-icon>纠错</button>
          </div>
        </div>

        <p
          class="question-text"
          v-html="renderLatex('设函数 $f(x)=\\frac{1-x^2}{1+x^2}$，则 $f^{\\prime}(0)=\\left(\\quad\\right)$。')"
        ></p>
        <div class="options">
          <button v-for="option in options" :key="option.key" :class="{ selected: selectedAnswer === option.key }" @click="selectedAnswer = option.key">
            <b>{{ option.key }}</b><span v-html="renderLatex(option.value)"></span>
          </button>
        </div>

        <div class="answer-panel">
          <div class="answer-title"><el-icon><CircleCheckFilled /></el-icon><strong>正确答案：</strong><span>C</span><button>⌄</button></div>
          <strong class="analysis-label">解析：</strong>
          <p>由商法则得</p>
          <div
            class="formula"
            v-html="renderLatex('$$f^{\\prime}(x)=\\frac{(1-x^2)^{\\prime}(1+x^2)-(1-x^2)(1+x^2)^{\\prime}}{(1+x^2)^2}=\\frac{-2x(1+x^2)-(1-x^2)2x}{(1+x^2)^2}=\\frac{-4x}{(1+x^2)^2}$$')"
          ></div>
          <p v-html="renderLatex('代入 $x=0$ 得 $f^{\\prime}(0)=0$。')"></p>
          <div class="knowledge-tags"><strong>考点标签：</strong><span>导数与微分</span><span>导数的基本公式</span><span>商法则</span><button>＋ 添加标签</button></div>
        </div>

        <footer class="question-footer">
          <button>‹　上一题</button><button><el-icon><Checked /></el-icon>标记本题</button><button>题目卡片　⌄</button>
          <button class="next-button">下一题　›</button>
        </footer>
      </article>
    </main>

    <aside class="question-nav panel">
      <div class="nav-title"><h3>题目导航</h3><span>⌃　收起</span></div>
      <p>共 {{ sessionQuestionCount }} 题</p>
      <div class="legend"><span><i class="answered"></i>已答</span><span><i></i>未答</span><span><i class="marked"></i>标记</span><span>☆ 收藏</span></div>
      <div class="number-grid">
        <button v-for="n in sessionQuestionCount" :key="n" :class="{ current: n === 1, answered: n === 2, marked: n === 3 || n === 13 }">{{ n }}</button>
      </div>
      <button class="more-button">⌄　展开更多</button>
    </aside>
  </section>
</template>

<script setup lang="ts">
import { computed, reactive, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import katex from 'katex'
import {
  ArrowDown, ArrowLeft, ArrowRight, Checked, CircleCheck, CircleCheckFilled, Download, EditPen,
  MagicStick, Plus, Star, StarFilled, Warning
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const isSession = computed(() => route.path === '/practice/session')
const mode = computed(() => {
  const value = String(route.query.mode || '')
  return ['chapter', 'knowledge', 'favorite', 'mistake'].includes(value) ? value : 'paper'
})
const activePaperTab = ref('全部试卷')
const selectedPaperYear = ref('')
const activeKnowledgeDifficulty = ref('全部难度')
const knowledgeSearch = ref('')
const selectedFavoriteIds = ref<number[]>([])
const selectedMistakeIds = ref<number[]>([])
const selectedAnswer = ref('C')
const paperTabs = ['全部试卷', '真题试卷', '模拟试卷', '自定义组卷']
const knowledgeDifficultyFilters = ['全部难度', '薄弱优先', '中等', '困难']
const options = [
  { key: 'A', value: '$-1$' }, { key: 'B', value: '$-2$' }, { key: 'C', value: '$0$' }, { key: 'D', value: '$2$' }
]
const subjectLabelMap: Record<string, string> = {
  calculus: '高等数学',
  'linear-algebra': '线性代数',
  probability: '概率统计'
}
const activePracticeSubject = computed(() => subjectLabelMap[String(route.query.subject || '')] || '高等数学')
const sessionKnowledge = computed(() => String(route.query.knowledge || '').trim())
const sessionSubject = computed(() => subjectLabelMap[String(route.query.subject || '')] || activePracticeSubject.value)
const sessionQuestionCount = computed(() => {
  const value = Number(route.query.count)
  return Number.isFinite(value) && value > 0 ? value : 22
})
const isKnowledgeSession = computed(() => route.query.mode === 'knowledge' && !!sessionKnowledge.value)
const isMistakeSession = computed(() => route.query.mode === 'mistake')
const isRecordSession = computed(() => route.query.mode === 'record')
const sessionTitle = computed(() => {
  if (isKnowledgeSession.value) return `${sessionKnowledge.value}专项练习`
  if (isMistakeSession.value) return '全部错题专项练习'
  if (isRecordSession.value) return '刷题记录再次练习'
  return '2024年考研数学（一）真题'
})
const sessionBadge = computed(() => isKnowledgeSession.value ? '知识点' : isMistakeSession.value ? '错题' : isRecordSession.value ? '再次练习' : '真题')
const sessionMeta = computed(() => {
  if (isMistakeSession.value) return `${sessionSubject.value}　|　全部错题　|　共 ${sessionQuestionCount.value} 题`
  if (isRecordSession.value) return `${sessionSubject.value}　|　历史记录复练　|　共 ${sessionQuestionCount.value} 题`
  if (!isKnowledgeSession.value) return '共 22 题　|　满分 150 分　|　考试时间 180 分钟'
  return `${sessionSubject.value}　|　${sessionKnowledge.value}　|　共 ${sessionQuestionCount.value} 题`
})
const papers = [
  { name: '2024年考研数学（一）真题', year: 2024, count: 22, difficulty: 4, source: '真题' },
  { name: '2023年考研数学（一）真题', year: 2023, count: 22, difficulty: 4, source: '真题' },
  { name: '2022年考研数学（一）真题', year: 2022, count: 22, difficulty: 4, source: '真题' },
  { name: '2021年考研数学（一）真题', year: 2021, count: 22, difficulty: 4, source: '真题' },
  { name: '2024年考研数学（一）模拟卷（一）', year: 2024, count: 22, difficulty: 3, source: '模拟' },
  { name: '2024年考研数学（一）模拟卷（二）', year: 2024, count: 22, difficulty: 3, source: '模拟' },
  { name: '2024年考研数学（一）模拟卷（三）', year: 2024, count: 22, difficulty: 3, source: '模拟' },
  { name: '2023年考研数学（一）模拟卷（一）', year: 2023, count: 22, difficulty: 3, source: '模拟' },
  { name: '高等数学综合练习卷（一）', year: 2026, count: 42, difficulty: 3, source: '自定义' },
  { name: '导数与微分专项训练卷', year: 2026, count: 30, difficulty: 3, source: '自定义' }
]

watch(
  () => route.query.tab,
  (tab) => {
    activePaperTab.value = tab === 'custom' ? '自定义组卷' : '全部试卷'
  },
  { immediate: true }
)

const filteredPapers = computed(() => papers.filter((paper) => {
  const matchesTab =
    activePaperTab.value === '全部试卷' ||
    (activePaperTab.value === '真题试卷' && paper.source === '真题') ||
    (activePaperTab.value === '模拟试卷' && paper.source === '模拟') ||
    (activePaperTab.value === '自定义组卷' && paper.source === '自定义')
  const matchesYear = !selectedPaperYear.value || String(paper.year) === selectedPaperYear.value
  return matchesTab && matchesYear
}))
const chapterGroups = reactive({
  高等数学: [
    {
      title: '第一章　函数、极限、连续', count: 102, rate: 78, open: true,
      sections: [
        { name: '1.1 函数', count: 18, rate: 81 }, { name: '1.2 极限', count: 35, rate: 76 },
        { name: '1.3 连续', count: 20, rate: 80 }, { name: '章末综合练习', count: 29, rate: 75 }
      ]
    },
    { title: '第二章　一元函数微分学', count: 120, rate: 73, open: false, sections: [] },
    { title: '第三章　一元函数积分学', count: 118, rate: 75, open: false, sections: [] },
    { title: '第四章　多元函数微分学', count: 96, rate: 72, open: false, sections: [] },
    { title: '第五章　多元函数积分学', count: 88, rate: 71, open: false, sections: [] },
    { title: '第六章　常微分方程', count: 87, rate: 74, open: false, sections: [] },
    { title: '第七章　向量代数与空间解析几何', count: 74, rate: 69, open: false, sections: [] },
    { title: '第八章　多元函数微分学应用', count: 60, rate: 70, open: false, sections: [] },
    { title: '第九章　二重积分', count: 41, rate: 68, open: false, sections: [] },
    { title: '第十章　无穷级数', count: 53, rate: 73, open: false, sections: [] },
    { title: '第十一章　微分方程与差分方程', count: 36, rate: 71, open: false, sections: [] }
  ],
  线性代数: [
    {
      title: '第一章　行列式', count: 74, rate: 82, open: true,
      sections: [
        { name: '1.1 二阶与三阶行列式', count: 16, rate: 86 }, { name: '1.2 n阶行列式', count: 22, rate: 80 },
        { name: '1.3 行列式的性质', count: 21, rate: 83 }, { name: '1.4 行列式按行列展开', count: 15, rate: 78 }
      ]
    },
    { title: '第二章　矩阵', count: 96, rate: 76, open: false, sections: [] },
    { title: '第三章　向量', count: 88, rate: 73, open: false, sections: [] },
    { title: '第四章　线性方程组', count: 84, rate: 71, open: false, sections: [] },
    { title: '第五章　矩阵的特征值与特征向量', count: 72, rate: 69, open: false, sections: [] },
    { title: '第六章　二次型', count: 56, rate: 68, open: false, sections: [] }
  ],
  概率统计: [
    {
      title: '第一章　随机事件和概率', count: 68, rate: 80, open: true,
      sections: [
        { name: '1.1 随机事件', count: 14, rate: 85 }, { name: '1.2 概率的定义与性质', count: 18, rate: 82 },
        { name: '1.3 条件概率与独立性', count: 24, rate: 76 }, { name: '章末综合练习', count: 12, rate: 79 }
      ]
    },
    { title: '第二章　随机变量及其分布', count: 92, rate: 74, open: false, sections: [] },
    { title: '第三章　多维随机变量及其分布', count: 76, rate: 70, open: false, sections: [] },
    { title: '第四章　随机变量的数字特征', count: 84, rate: 72, open: false, sections: [] },
    { title: '第五章　大数定律和中心极限定理', count: 48, rate: 69, open: false, sections: [] },
    { title: '第六章　数理统计的基本概念', count: 58, rate: 71, open: false, sections: [] },
    { title: '第七章　参数估计', count: 42, rate: 68, open: false, sections: [] }
  ]
})
const chapters = computed(() => chapterGroups[activePracticeSubject.value as keyof typeof chapterGroups])

const knowledgeGroups = [
  {
    subject: '高等数学',
    title: '函数、极限、连续',
    desc: '考研数学基础模块，高频考点集中在极限计算与连续性判断',
    total: 236,
    rate: 78,
    points: [
      { name: '函数的极限', chapter: '第一章 · 1.2 极限', type: '核心考点', difficulty: '中等', level: 'medium', mastery: 76, count: 58, rate: 81 },
      { name: '无穷小与无穷大', chapter: '第一章 · 1.4 无穷小与无穷大', type: '基础考点', difficulty: '简单', level: 'easy', mastery: 84, count: 41, rate: 86 },
      { name: '连续与间断点', chapter: '第一章 · 1.3 连续', type: '高频考点', difficulty: '中等', level: 'medium', mastery: 71, count: 72, rate: 78 }
    ]
  },
  {
    subject: '高等数学',
    title: '一元函数微分学',
    desc: '导数、微分及其应用，是选择题与解答题的重点来源',
    total: 312,
    rate: 74,
    points: [
      { name: '导数的概念', chapter: '第二章 · 2.1 导数概念', type: '核心考点', difficulty: '中等', level: 'medium', mastery: 69, count: 68, rate: 76 },
      { name: '导数的运算法则', chapter: '第二章 · 2.2 求导法则', type: '高频考点', difficulty: '中等', level: 'medium', mastery: 73, count: 86, rate: 79 },
      { name: '微分中值定理', chapter: '第二章 · 2.5 中值定理', type: '难点突破', difficulty: '困难', level: 'hard', mastery: 55, count: 52, rate: 64 }
    ]
  },
  {
    subject: '线性代数',
    title: '矩阵与行列式',
    desc: '覆盖矩阵运算、逆矩阵、行列式计算与矩阵秩相关题型',
    total: 188,
    rate: 76,
    points: [
      { name: '矩阵的逆', chapter: '第二章 · 矩阵', type: '核心考点', difficulty: '中等', level: 'medium', mastery: 74, count: 46, rate: 80 },
      { name: '行列式性质', chapter: '第一章 · 行列式', type: '基础考点', difficulty: '简单', level: 'easy', mastery: 82, count: 52, rate: 85 },
      { name: '矩阵的秩', chapter: '第三章 · 向量组', type: '高频考点', difficulty: '困难', level: 'hard', mastery: 58, count: 39, rate: 68 }
    ]
  },
  {
    subject: '概率统计',
    title: '随机变量及其分布',
    desc: '围绕分布函数、密度函数和常见分布展开专项训练',
    total: 164,
    rate: 72,
    points: [
      { name: '分布函数', chapter: '第二章 · 随机变量', type: '核心考点', difficulty: '中等', level: 'medium', mastery: 70, count: 38, rate: 75 },
      { name: '正态分布', chapter: '第二章 · 常见分布', type: '高频考点', difficulty: '中等', level: 'medium', mastery: 67, count: 45, rate: 72 },
      { name: '随机变量函数分布', chapter: '第二章 · 函数分布', type: '难点突破', difficulty: '困难', level: 'hard', mastery: 52, count: 31, rate: 62 }
    ]
  }
]

const filteredKnowledgeGroups = computed(() => {
  const keyword = knowledgeSearch.value.trim()
  return knowledgeGroups
    .filter((group) => group.subject === activePracticeSubject.value)
    .map((group) => ({
      ...group,
      points: group.points.filter((point) => {
        const matchesDifficulty =
          activeKnowledgeDifficulty.value === '全部难度' ||
          (activeKnowledgeDifficulty.value === '薄弱优先' && point.mastery < 70) ||
          point.difficulty === activeKnowledgeDifficulty.value
        const matchesKeyword =
          !keyword ||
          point.name.includes(keyword) ||
          point.chapter.includes(keyword) ||
          point.type.includes(keyword) ||
          group.title.includes(keyword)
        return matchesDifficulty && matchesKeyword
      })
    }))
    .filter((group) => group.points.length > 0)
})

const knowledgeOverview = computed(() => {
  const points = filteredKnowledgeGroups.value.flatMap((group) => group.points)
  const total = points.reduce((sum, point) => sum + point.count, 0)
  const weakCount = points.filter((point) => point.mastery < 70).length
  const avgRate = points.length
    ? Math.round(points.reduce((sum, point) => sum + point.rate, 0) / points.length)
    : 0
  return [
    { label: '可练题量', value: `${total} 题`, note: `${activePracticeSubject.value} 当前筛选` },
    { label: '知识点数', value: `${points.length} 个`, note: `薄弱知识点 ${weakCount} 个` },
    { label: '平均正确率', value: `${avgRate}%`, note: '根据近期练习统计' }
  ]
})

const favoriteQuestions = ref([
  {
    id: 1,
    type: '单选题',
    chapter: '高等数学 · 导数与微分',
    difficulty: '中等',
    date: '06-18',
    wrongCount: 0,
    title: '设函数 $f(x)=\\frac{1-x^2}{1+x^2}$，则 $f^{\\prime}(0)=\\left(\\quad\\right)$。',
    tags: ['导数与微分', '商法则']
  },
  {
    id: 2,
    type: '填空题',
    chapter: '高等数学 · 极限',
    difficulty: '困难',
    date: '06-15',
    wrongCount: 0,
    title: '计算极限 $\\displaystyle \\lim_{x\\to 0}\\frac{\\sin x-x\\cos x}{x^3}$。',
    tags: ['函数极限', '洛必达法则']
  },
  {
    id: 3,
    type: '单选题',
    chapter: '线性代数 · 矩阵',
    difficulty: '中等',
    date: '06-12',
    wrongCount: 0,
    title: '设 $A$ 为三阶矩阵，且 $|A|=2$，则 $|2A^{-1}|$ 等于 $\\left(\\quad\\right)$。',
    tags: ['矩阵的逆', '行列式']
  },
  {
    id: 4,
    type: '解答题',
    chapter: '概率统计 · 随机变量',
    difficulty: '困难',
    date: '06-08',
    wrongCount: 0,
    title: '设随机变量 $X$ 服从参数为 $\\lambda$ 的指数分布，求 $Y=e^{-X}$ 的概率密度。',
    tags: ['随机变量函数', '概率密度']
  }
])

const mistakeQuestions = ref([
  {
    id: 11,
    type: '单选题',
    chapter: '高等数学 · 定积分',
    difficulty: '中等',
    date: '',
    wrongCount: 3,
    title: '设 $f(x)$ 在 $[0,1]$ 上连续，则下列积分等式正确的是 $\\left(\\quad\\right)$。',
    tags: ['定积分性质', '积分中值定理']
  },
  {
    id: 12,
    type: '填空题',
    chapter: '高等数学 · 无穷级数',
    difficulty: '困难',
    date: '',
    wrongCount: 2,
    title: '判断级数 $\\displaystyle \\sum_{n=1}^{\\infty}\\frac{(-1)^{n-1}}{\\sqrt n}$ 的敛散性。',
    tags: ['交错级数', '条件收敛']
  },
  {
    id: 13,
    type: '单选题',
    chapter: '线性代数 · 特征值',
    difficulty: '中等',
    date: '',
    wrongCount: 2,
    title: '设矩阵 $A$ 与 $B$ 相似，则下列结论中不一定成立的是 $\\left(\\quad\\right)$。',
    tags: ['相似矩阵', '特征值']
  },
  {
    id: 14,
    type: '解答题',
    chapter: '概率统计 · 数字特征',
    difficulty: '困难',
    date: '',
    wrongCount: 1,
    title: '设 $X,Y$ 相互独立且均服从标准正态分布，求 $X^2+Y^2$ 的分布。',
    tags: ['卡方分布', '随机变量']
  },
  {
    id: 15,
    type: '单选题',
    chapter: '高等数学 · 多元函数',
    difficulty: '中等',
    date: '',
    wrongCount: 2,
    title: '函数 $z=x^2+xy+y^2$ 在点 $(1,1)$ 处沿方向 $l$ 的方向导数为 $\\left(\\quad\\right)$。',
    tags: ['方向导数', '梯度']
  }
])

const currentQuestionList = computed(() => mode.value === 'favorite' ? favoriteQuestions.value : mistakeQuestions.value)
const filteredQuestions = computed(() => {
  return currentQuestionList.value.filter((question) => question.chapter.startsWith(activePracticeSubject.value))
})
const selectedQuestionIds = computed(() => mode.value === 'favorite' ? selectedFavoriteIds.value : selectedMistakeIds.value)
const visibleQuestionIds = computed(() => filteredQuestions.value.map((question) => question.id))
const allQuestionsSelected = computed(() => {
  return visibleQuestionIds.value.length > 0 &&
    visibleQuestionIds.value.every((id) => selectedQuestionIds.value.includes(id))
})
const someQuestionsSelected = computed(() => {
  const selectedCount = visibleQuestionIds.value.filter((id) => selectedQuestionIds.value.includes(id)).length
  return selectedCount > 0 && selectedCount < visibleQuestionIds.value.length
})

function startSession() {
  router.push({ name: 'practiceSession' })
}

function backToPracticeHome() {
  if (isKnowledgeSession.value) router.push({ name: 'practice', query: { mode: 'knowledge' } })
  else if (isMistakeSession.value) router.push({ name: 'practice', query: { mode: 'mistake' } })
  else if (isRecordSession.value) router.push({ name: 'statistics', query: { tab: 'records' } })
  else router.push({ name: 'practice' })
}

function renderLatex(text: string) {
  return text
    .replace(/\$\$([\s\S]+?)\$\$/g, (_, formula: string) =>
      katex.renderToString(formula, {
        throwOnError: false,
        displayMode: true
      })
    )
    .replace(/\$([^$]+?)\$/g, (_, formula: string) =>
      katex.renderToString(formula, {
        throwOnError: false,
        displayMode: false
      })
    )
}

function updateSelectedQuestions(ids: number[]) {
  if (mode.value === 'favorite') selectedFavoriteIds.value = ids
  else selectedMistakeIds.value = ids
}

function removeSelectedQuestionId(id: number) {
  selectedFavoriteIds.value = selectedFavoriteIds.value.filter((item) => item !== id)
  selectedMistakeIds.value = selectedMistakeIds.value.filter((item) => item !== id)
}

function removeFavoriteQuestion(id: number) {
  favoriteQuestions.value = favoriteQuestions.value.filter((question) => question.id !== id)
  removeSelectedQuestionId(id)
}

function markMistakeMastered(id: number) {
  mistakeQuestions.value = mistakeQuestions.value.filter((question) => question.id !== id)
  removeSelectedQuestionId(id)
}

function toggleQuestion(id: number) {
  const selected = selectedQuestionIds.value
  updateSelectedQuestions(selected.includes(id) ? selected.filter((item) => item !== id) : [...selected, id])
}

function toggleSelectAll() {
  const selected = selectedQuestionIds.value
  if (allQuestionsSelected.value) {
    updateSelectedQuestions(selected.filter((id) => !visibleQuestionIds.value.includes(id)))
  } else {
    updateSelectedQuestions(Array.from(new Set([...selected, ...visibleQuestionIds.value])))
  }
}
</script>

<style scoped lang="scss">
.practice-page {
  min-height: calc(100vh - 112px);
  padding: 28px 28px 20px;
  box-shadow: none;
}

.page-intro {
  display: flex;
  align-items: baseline;
  gap: 25px;
}

.page-intro h2 {
  margin: 0;
  color: var(--ink);
  font-size: 21px;
}

.page-intro p {
  margin: 0;
  color: var(--muted);
  font-size: 14px;
}

.paper-tabs {
  display: flex;
  align-items: center;
  gap: 38px;
  height: 82px;
  border-bottom: 1px solid var(--line);
}

.paper-tabs button,
.subject-tabs button {
  position: relative;
  height: 100%;
  padding: 0;
  color: var(--ink);
  font: inherit;
  font-size: 15px;
  font-weight: 700;
  border: 0;
  background: transparent;
}

.paper-tabs button.active {
  color: var(--primary);
}

.paper-tabs button.active::after {
  position: absolute;
  right: 0;
  bottom: 0;
  left: 0;
  height: 2px;
  background: var(--primary);
  content: '';
}

.year-select {
  width: 142px !important;
  margin-left: auto;
}

.year-select.with-create {
  margin-left: 0;
}

.year-select :deep(.el-input__wrapper) {
  min-height: 36px;
  padding: 0 12px;
  border-radius: 6px;
  box-shadow: 0 0 0 1px var(--line) inset;
}

.year-select :deep(.el-input__inner) {
  color: var(--text);
  font-size: 14px;
}

.create-paper-button {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 7px;
  width: 108px;
  height: 36px !important;
  margin-left: auto;
  padding: 0 12px !important;
  color: #fff !important;
  font-size: 13px !important;
  border: 1px solid var(--primary) !important;
  border-radius: 6px;
  background: var(--primary) !important;
  text-decoration: none;
}

.create-paper-button::after {
  display: none;
}

.paper-grid {
  display: grid;
  grid-template-columns: minmax(420px, 1fr) 110px 150px 120px;
  align-items: center;
  column-gap: 16px;
}

.paper-head {
  height: 66px;
  padding: 0 22px;
  color: var(--muted);
  font-size: 13px;
}

.paper-row {
  min-height: 80px;
  padding: 0 22px;
  color: var(--text);
  font-size: 14px;
  border: 1px solid var(--line);
  border-bottom: 0;
}

.paper-row:first-of-type { border-radius: 7px 7px 0 0; }
.paper-row:nth-last-of-type(1) { border-bottom: 1px solid var(--line); border-radius: 0 0 7px 7px; }

.paper-name {
  display: grid;
  grid-template-columns: auto 1fr;
  gap: 7px 10px;
  align-items: center;
}

.paper-name strong { color: var(--ink); font-size: 16px; }
.paper-name small { grid-column: 1; color: var(--muted); font-size: 13px; }

.paper-tag {
  justify-self: start;
  padding: 3px 8px;
  color: var(--primary);
  font-size: 11px;
  background: var(--primary-soft);
  border-radius: 4px;
}

.paper-tag.tag-真题 { color: #2460e9; background: #edf3ff; }
.paper-tag.tag-模拟 { color: #15966a; background: #e9f9f2; }
.paper-tag.tag-自定义 { color: #8b52c7; background: #f4ecff; }

.stars { display: flex; color: #9aa9d4; }
.stars .filled { color: #ff9438; }

.outline-button {
  width: 102px;
  height: 38px;
  color: var(--primary);
  font: inherit;
  font-size: 14px;
  font-weight: 700;
  border: 1px solid #9eb5ff;
  border-radius: 6px;
  background: #fff;
}

.paper-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 18px;
  color: var(--text);
  font-size: 14px;
}

.pagination { display: flex; gap: 10px; }
.pagination button {
  min-width: 38px;
  height: 38px;
  color: var(--text);
  border: 1px solid var(--line);
  border-radius: 6px;
  background: #fff;
}
.pagination button.active { color: var(--primary); border-color: var(--primary); }
.pagination .page-size { display: flex; align-items: center; gap: 12px; width: 116px; padding: 0 12px; }

:global(.paper-year-popper) {
  z-index: 4200 !important;
}

.subject-tabs {
  display: flex;
  gap: 16px;
  height: 62px;
  align-items: center;
}

.knowledge-intro {
  justify-content: space-between;
  align-items: center;
}

.knowledge-intro > div {
  display: flex;
  align-items: baseline;
  gap: 25px;
}

.knowledge-subject-tabs {
  height: 58px;
}

.knowledge-toolbar {
  display: flex;
  align-items: center;
  gap: 12px;
  min-height: 62px;
  margin-bottom: 16px;
  padding: 0 2px;
}

.knowledge-search {
  display: flex;
  align-items: center;
  gap: 10px;
  flex: 1;
  height: 40px;
  padding: 0 14px;
  border: 1px solid var(--line);
  border-radius: 7px;
  background: #fff;
}

.knowledge-search span {
  color: #8c9ac5;
  font-size: 18px;
  line-height: 1;
}

.knowledge-search input {
  flex: 1;
  min-width: 0;
  color: var(--ink);
  font: inherit;
  font-size: 14px;
  border: 0;
  outline: 0;
  background: transparent;
}

.knowledge-search input::placeholder {
  color: #9aa7c9;
}

.knowledge-toolbar > button {
  height: 36px;
  padding: 0 14px;
  color: var(--text);
  font: inherit;
  font-size: 13px;
  border: 1px solid var(--line);
  border-radius: 6px;
  background: #fff;
}

.knowledge-toolbar > button.active {
  color: var(--primary);
  border-color: #9eb5ff;
  background: #f5f8ff;
}

.knowledge-overview {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
  margin-bottom: 18px;
}

.knowledge-overview article {
  min-height: 86px;
  padding: 17px 20px;
  border: 1px solid var(--line);
  border-radius: 8px;
  background: linear-gradient(135deg, #fff 0%, #f8fbff 100%);
}

.knowledge-overview span,
.knowledge-overview small {
  display: block;
  color: var(--muted);
  font-size: 12px;
}

.knowledge-overview strong {
  display: block;
  margin: 7px 0 5px;
  color: var(--ink);
  font-size: 24px;
}

.knowledge-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.knowledge-card {
  border: 1px solid var(--line);
  border-radius: 8px;
  background: #fff;
  overflow: hidden;
}

.knowledge-card-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 20px;
  min-height: 74px;
  padding: 0 22px;
  border-bottom: 1px solid var(--line);
  background: #fbfcff;
}

.knowledge-card-head strong {
  display: block;
  color: var(--ink);
  font-size: 16px;
}

.knowledge-card-head span {
  display: block;
  margin-top: 6px;
  color: var(--muted);
  font-size: 13px;
}

.knowledge-group-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  color: var(--text);
  white-space: nowrap;
}

.knowledge-group-meta i {
  width: 1px;
  height: 14px;
  background: var(--line);
}

.knowledge-group-meta span {
  margin: 0;
  color: var(--text);
}

.knowledge-point-list {
  padding: 0 22px;
}

.knowledge-point-row {
  display: grid;
  grid-template-columns: minmax(250px, 1fr) 190px 220px 150px 104px;
  align-items: center;
  gap: 18px;
  min-height: 88px;
  border-bottom: 1px solid var(--line);
}

.knowledge-point-row:last-child {
  border-bottom: 0;
}

.point-title {
  display: flex;
  align-items: center;
  gap: 13px;
}

.point-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--primary);
  box-shadow: 0 0 0 5px #eef3ff;
}

.point-dot.easy {
  background: #24b985;
  box-shadow: 0 0 0 5px #e9faf3;
}

.point-dot.hard {
  background: #ff5d65;
  box-shadow: 0 0 0 5px #fff0f1;
}

.point-title strong {
  display: block;
  color: var(--ink);
  font-size: 15px;
}

.point-title small {
  display: block;
  margin-top: 6px;
  color: var(--muted);
  font-size: 12px;
}

.point-tags {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.point-tags span {
  padding: 5px 9px;
  color: #3f6fb5;
  font-size: 12px;
  background: #edf5ff;
  border-radius: 5px;
}

.point-tags .difficulty-easy {
  color: #15966a;
  background: #e9f9f2;
}

.point-tags .difficulty-medium {
  color: #d98018;
  background: #fff4e5;
}

.point-tags .difficulty-hard {
  color: #e5484d;
  background: #fff0f1;
}

.point-progress {
  min-width: 0;
}

.progress-text {
  display: flex;
  justify-content: space-between;
  margin-bottom: 7px;
  color: var(--muted);
  font-size: 12px;
}

.progress-text b {
  color: var(--ink);
}

.point-progress :deep(.el-progress-bar__outer) {
  background: #eef2f8;
}

.point-progress :deep(.el-progress-bar__inner) {
  background: linear-gradient(90deg, #1f53ff, #36c7a2);
}

.point-meta {
  display: flex;
  flex-direction: column;
  gap: 7px;
  color: var(--text);
  font-size: 13px;
}

.question-list-intro {
  justify-content: space-between;
  align-items: center;
}

.question-list-intro > div {
  display: flex;
  align-items: baseline;
  gap: 25px;
}

.primary-button {
  height: 40px;
  padding: 0 20px;
  color: #fff;
  font: inherit;
  font-size: 14px;
  font-weight: 700;
  border: 1px solid var(--primary);
  border-radius: 6px;
  background: var(--primary);
}

.primary-button:disabled {
  cursor: not-allowed;
  border-color: #aebdf0;
  background: #aebdf0;
}

.question-filter {
  display: flex;
  align-items: center;
  gap: 12px;
  min-height: 78px;
  margin-top: 12px;
  border-bottom: 1px solid var(--line);
}

.question-summary {
  display: flex;
  align-items: baseline;
  gap: 6px;
  min-width: 150px;
}

.question-summary strong {
  color: var(--primary);
  font-size: 24px;
}

.question-summary span {
  color: var(--muted);
  font-size: 13px;
}

.question-filter > button {
  height: 34px;
  padding: 0 14px;
  color: var(--text);
  font: inherit;
  font-size: 13px;
  border: 1px solid transparent;
  border-radius: 5px;
  background: transparent;
}

.question-filter > button.active {
  color: var(--primary);
  border-color: #b5c5ff;
  background: #f6f8ff;
}

.question-filter > .select-all-button {
  display: flex;
  align-items: center;
  gap: 7px;
  margin-right: 8px;
  color: var(--text);
  border-color: var(--line);
  background: #fff;
}

.question-filter > .select-all-button.active {
  color: var(--primary);
  border-color: #9eb5ff;
}

.check-box {
  display: inline-grid;
  place-items: center;
  width: 15px;
  height: 15px;
  color: #fff;
  font-size: 11px;
  line-height: 1;
  border: 1px solid #bdc7df;
  border-radius: 3px;
}

.check-box.checked,
.check-box.partial {
  border-color: var(--primary);
  background: var(--primary);
}

.list-sort {
  display: flex;
  align-items: center;
  gap: 18px;
  height: 34px;
  margin-left: auto;
  padding: 0 12px;
  color: var(--text);
  font-size: 13px;
  border: 1px solid var(--line);
  border-radius: 5px;
}

.saved-question-list {
  border: 1px solid var(--line);
  border-radius: 7px;
  overflow: hidden;
}

.saved-question {
  display: grid;
  grid-template-columns: 20px 42px minmax(0, 1fr) 220px;
  gap: 16px;
  align-items: center;
  min-height: 128px;
  padding: 20px 22px;
  border-bottom: 1px solid var(--line);
}

.question-checkbox {
  position: relative;
  display: grid;
  place-items: center;
  width: 17px;
  height: 17px;
  cursor: pointer;
}

.question-checkbox input {
  position: absolute;
  width: 1px;
  height: 1px;
  opacity: 0;
}

.question-checkbox span {
  display: grid;
  place-items: center;
  width: 17px;
  height: 17px;
  color: transparent;
  font-size: 12px;
  border: 1px solid #bdc7df;
  border-radius: 3px;
  background: #fff;
}

.question-checkbox input:checked + span {
  color: #fff;
  border-color: var(--primary);
  background: var(--primary);
}

.saved-question:last-child {
  border-bottom: 0;
}

.question-number {
  display: grid;
  place-items: center;
  width: 38px;
  height: 38px;
  color: var(--primary);
  font-weight: 800;
  background: var(--primary-soft);
  border-radius: 6px;
}

.saved-question-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  color: var(--muted);
  font-size: 12px;
}

.question-type {
  padding: 4px 8px;
  color: #10a873;
  background: #e9faf3;
  border-radius: 4px;
}

.wrong-count {
  color: #f06b4f;
}

.saved-question h3 {
  margin: 12px 0;
  color: var(--ink);
  font-family: 'Times New Roman', 'Songti SC', serif;
  font-size: 17px;
  font-weight: 600;
}

.saved-tags {
  display: flex;
  gap: 8px;
}

.saved-tags span {
  padding: 4px 9px;
  color: #4773b8;
  font-size: 11px;
  background: #edf5ff;
  border-radius: 4px;
}

.saved-question-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 18px;
}

.text-action {
  display: flex;
  align-items: center;
  gap: 5px;
  padding: 0;
  color: var(--muted);
  font: inherit;
  font-size: 13px;
  border: 0;
  background: transparent;
}

.text-action .el-icon {
  color: #ff9b21;
}

.success-action .el-icon {
  color: var(--green);
}

.saved-list-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 72px;
  color: var(--text);
  font-size: 13px;
}

.subject-tabs button {
  width: 102px;
  height: 36px;
  border: 1px solid var(--line);
  border-radius: 5px;
}
.subject-tabs button.active { color: var(--primary); border-color: #9eb5ff; }

.chapter-list { display: flex; flex-direction: column; gap: 5px; }
.chapter-card { border: 1px solid var(--line); border-radius: 6px; overflow: hidden; }
.chapter-main, .section-row {
  display: grid;
  grid-template-columns: 30px minmax(360px, 1fr) 265px 104px;
  align-items: center;
  min-height: 51px;
  padding: 0 28px 0 15px;
}
.chapter-main { cursor: pointer; }
.chapter-main strong { color: var(--ink); font-size: 15px; }
.chapter-arrow { color: var(--ink); font-size: 17px; }
.chapter-meta { display: flex; justify-content: flex-end; gap: 20px; color: var(--muted); font-size: 13px; }
.chapter-meta i { width: 1px; height: 14px; background: var(--line); }
.chapter-main .outline-button, .section-row .outline-button { width: 86px; height: 31px; justify-self: end; }
.chapter-sections { padding-left: 22px; border-top: 1px solid var(--line); }
.section-row { grid-template-columns: minmax(390px, 1fr) 265px 104px; padding-left: 38px; border-bottom: 1px solid var(--line); }
.section-row:last-child { border-bottom: 0; }
.section-row > span { color: var(--text); font-size: 14px; }

.session-page {
  display: grid;
  grid-template-columns: minmax(720px, 1fr) 375px;
  gap: 24px;
  min-height: calc(100vh - 112px);
}

.session-titlebar {
  display: flex;
  align-items: center;
  gap: 14px;
  min-height: 82px;
}
.back-button, .paper-action {
  display: flex; align-items: center; gap: 7px; color: var(--text); font: inherit; font-size: 14px; border: 0; background: transparent;
}
.session-titlebar > div { flex: 1; }
.session-titlebar h2 { margin: 0 0 8px; color: var(--ink); font-size: 21px; }
.session-titlebar h2 span { margin-left: 8px; padding: 4px 8px; color: var(--primary); font-size: 11px; background: var(--primary-soft); border-radius: 4px; }
.session-titlebar p { margin: 0; color: var(--muted); font-size: 13px; }
.paper-action { height: 40px; padding: 0 15px; border: 1px solid var(--line); border-radius: 6px; background: #fff; }

.question-card { padding: 24px; box-shadow: none; }
.question-tools { display: flex; align-items: center; }
.question-index { display: flex; align-items: center; gap: 11px; }
.question-index strong { display: grid; place-items: center; width: 38px; height: 38px; color: var(--primary); font-size: 18px; background: #f4f7ff; border: 1px solid var(--line); border-radius: 6px; }
.question-index span { color: var(--text); font-weight: 700; }
.type-tag { margin-left: 28px; padding: 5px 10px; color: #10a873; font-size: 12px; background: #e9faf3; border-radius: 4px; }
.score-note { margin-left: 10px; color: var(--muted); font-size: 13px; }
.tool-buttons { display: flex; gap: 12px; margin-left: auto; }
.tool-buttons button { display: flex; align-items: center; gap: 7px; height: 38px; padding: 0 15px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 6px; background: #fff; }
.question-text { margin: 25px 0 28px; color: var(--ink); font-size: 20px; }
.question-text :deep(.katex) { font-size: 1.08em; }
.options { display: flex; flex-direction: column; gap: 12px; }
.options button { display: flex; align-items: center; gap: 18px; height: 55px; padding: 0 13px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 6px; background: #fff; }
.options b { display: grid; place-items: center; width: 34px; height: 34px; color: var(--ink); border: 1px solid var(--line); border-radius: 50%; }
.options button.selected { color: var(--primary); border-color: var(--primary); background: #f9fbff; }
.options button.selected b { color: #fff; border-color: var(--primary); background: var(--primary); }
.answer-panel { margin-top: 24px; padding: 18px 16px; background: #fbfcff; border-radius: 6px; }
.answer-title { display: flex; align-items: center; gap: 9px; color: #08a96d; }
.answer-title button { margin-left: auto; border: 0; background: transparent; }
.analysis-label { display: block; margin: 10px 0 5px 28px; color: #08a96d; }
.answer-panel p { margin: 7px 0 7px 28px; color: var(--text); font-size: 14px; }
.formula { margin: 4px 0 6px 28px; color: var(--ink); font-size: 17px; overflow-x: auto; }
.formula :deep(.katex-display) { margin: 0.45em 0; text-align: left; }
.formula :deep(.katex-display > .katex) { text-align: left; }
.knowledge-tags { display: flex; align-items: center; gap: 12px; margin: 20px 0 0 28px; font-size: 13px; }
.knowledge-tags span { padding: 6px 11px; color: #1e9e75; background: #eaf9f4; border-radius: 5px; }
.knowledge-tags span:nth-of-type(2) { color: #2d77c7; background: #edf6ff; }
.knowledge-tags button { height: 30px; color: var(--muted); border: 1px solid var(--line); border-radius: 5px; background: #fff; }
.question-footer { display: flex; gap: 24px; margin: 24px -24px -24px; padding: 22px 18px; border-top: 1px solid var(--line); }
.question-footer button { display: flex; align-items: center; gap: 7px; height: 46px; padding: 0 28px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 6px; background: #fff; }
.question-footer .next-button { margin-left: auto; color: #fff; border-color: var(--primary); background: var(--primary); }

.question-nav { padding: 24px 30px; box-shadow: none; }
.nav-title { display: flex; align-items: center; justify-content: space-between; }
.nav-title h3 { margin: 0; color: var(--ink); font-size: 20px; }
.nav-title span { color: var(--muted); font-size: 13px; }
.question-nav > p { margin: 34px 0 26px; color: var(--muted); }
.legend { display: flex; justify-content: space-between; color: var(--text); font-size: 13px; }
.legend span { display: flex; align-items: center; gap: 7px; }
.legend i { width: 13px; height: 13px; border: 1px solid var(--line); border-radius: 3px; }
.legend i.answered { border-color: var(--primary); background: var(--primary); }
.legend i.marked { border-color: #ff8e42; background: #ff8e42; }
.number-grid { display: grid; grid-template-columns: repeat(5, 1fr); gap: 26px 20px; margin-top: 42px; }
.number-grid button { position: relative; height: 54px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 6px; background: #fff; }
.number-grid button.current { color: #fff; border-color: var(--primary); background: var(--primary); box-shadow: 0 9px 16px rgba(31,83,255,.17); }
.number-grid button.answered { color: var(--primary); border-color: #8ea9ff; }
.number-grid button.marked { border-color: #ffae78; }
.more-button { display: block; margin: 42px auto 0; color: var(--primary); font: inherit; font-weight: 700; border: 0; background: transparent; }

@media (max-width: 1400px) {
  .session-page { grid-template-columns: minmax(690px, 1fr) 330px; }
  .paper-grid { grid-template-columns: minmax(360px, 1fr) 90px 130px 110px; }
}
</style>
