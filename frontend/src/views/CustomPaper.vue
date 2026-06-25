<template>
  <section class="custom-paper-page">
    <header class="flow-header">
      <div class="stepper">
        <div v-for="item in flowSteps" :key="item.routeStep" class="step" :class="{ active: visualStep === item.displayStep, done: visualStep > item.displayStep }">
          <span><el-icon v-if="visualStep > item.displayStep"><Check /></el-icon><template v-else>{{ item.displayStep }}</template></span>
          <strong>{{ item.title }}</strong>
          <i v-if="item.displayStep < flowSteps.length"></i>
        </div>
      </div>
      <div class="flow-actions">
        <button v-if="step === 1" @click="backToPractice">取消</button>
        <button v-else @click="previousStep">上一步</button>
        <button class="primary" @click="nextStep">{{ nextButtonText }}</button>
      </div>
    </header>

    <div v-if="step === 1" class="settings-layout">
      <main class="column">
        <section class="paper-card info-card">
          <h2>试卷信息</h2>
          <div class="info-columns">
            <div class="form-column">
              <label>
                <span>试卷名称 <em>*</em></span>
                <div class="field input-field"><input v-model="form.name" maxlength="50" /><small>{{ form.name.length }}/50</small></div>
              </label>
              <label>
                <span>试卷科目 <em>*</em></span>
                <select v-model="form.subject" class="field native-select">
                  <option>高等数学</option><option>线性代数</option><option>概率论与数理统计</option>
                </select>
              </label>
              <label>
                <span>试卷难度</span>
                <div class="difficulty-buttons">
                  <button v-for="item in difficulties" :key="item" :class="{ active: form.difficulty === item }" @click="form.difficulty = item">{{ item }}</button>
                </div>
              </label>
              <label>
                <span>试卷用途</span>
                <select v-model="form.purpose" class="field native-select">
                  <option>阶段练习</option><option>课后作业</option><option>模拟考试</option><option>查漏补缺</option>
                </select>
              </label>
              <label class="description">
                <span>试卷描述</span>
                <div class="textarea"><textarea v-model="form.description" maxlength="200"></textarea><small>{{ form.description.length }}/200</small></div>
              </label>
            </div>
            <div class="form-column compact">
              <label><span>试卷总分</span><div class="readonly-score"><strong>{{ totalTypeScore }}</strong></div><b>分</b></label>
              <label><span>考试时长 <em>*</em></span><div class="counter"><button @click="adjustFormNumber('duration', -10)">−</button><strong>{{ form.duration }}</strong><button @click="adjustFormNumber('duration', 10)">＋</button></div><b>分钟</b></label>
              <label class="check-line"><span>抽题去重</span><div><input v-model="form.deduplicate" type="checkbox" /> 同一道题在本卷中不重复出现</div></label>
              <label class="check-line"><span>允许知识点重复</span><div><input v-model="form.allowRepeatedPoint" type="checkbox" /> 同一知识点可出现多次　ⓘ</div></label>
            </div>
          </div>
        </section>

        <section class="paper-card type-card">
          <div class="card-title"><h2>题型设置</h2><button @click="addQuestionType">＋ 添加题型</button></div>
          <div class="type-head"><span>题型</span><span>题量</span><span>每题分值</span><span>小计分值</span><span>抽取科目</span><span>操作</span></div>
          <div v-for="(row, index) in typeRows" :key="row.name" class="type-row">
            <strong>⠿　{{ row.name }}</strong>
            <div class="mini-counter"><button @click="adjustType(index, 'count', -1)">−</button><b>{{ row.count }}</b><button @click="adjustType(index, 'count', 1)">＋</button></div>
            <div class="mini-counter"><button @click="adjustType(index, 'score', -1)">−</button><b>{{ row.score }}</b><button @click="adjustType(index, 'score', 1)">＋</button></div>
            <strong>{{ row.total }} 分</strong>
            <div class="scope-tags"><button v-for="tag in row.tags" :key="tag" @click="removeScopeTag(index, tag)">{{ tag }} ×</button></div>
            <span class="row-actions">
              <button class="range-action" @click="openRangeDialog(index)">抽题范围设置</button>
              <button class="delete-action" @click="deleteQuestionType(index)">删除题型</button>
            </span>
          </div>
          <footer><span>总题量：　<strong>{{ totalQuestionCount }}</strong> 题</span><span>总分值：　<strong>{{ totalTypeScore }}</strong> 分</span><button @click="resetTypeSettings">重置设置</button></footer>
        </section>

      </main>

      <aside class="column">
        <StructurePanel />
        <section class="paper-card note-card">
          <h2>组卷规则说明</h2>
          <p>• 系统将根据您的设置，从题库中随机抽取符合条件的题目</p>
          <p>• 抽题完成后，您可以在预览阶段进行题目调整</p>
          <p>• 最终试卷将在确认后生成到试卷库中</p>
        </section>
        <section class="paper-card note-card warm">
          <h2>💡 温馨提示</h2>
          <p>• 建议单类题量控制在 20~60 题之间</p>
          <p>• 试卷难度和知识点分布建议合理搭配</p>
          <p>• 您可以在预览阶段替换不合适的题目</p>
        </section>
      </aside>
    </div>

    <div v-if="rangeDialogVisible" class="dialog-mask" @click.self="closeRangeDialog">
      <section class="range-dialog">
        <header>
          <div><h2>抽题范围设置</h2><p>根据需求设置抽题范围和策略，系统将基于所选条件智能抽题</p></div>
          <button class="dialog-close" @click="closeRangeDialog">×</button>
        </header>
        <div class="range-dialog-body">
          <aside class="range-side">
            <section>
              <h3>组卷模式　ⓘ</h3>
              <label>
                <input v-model="rangeMode" value="智能组卷" type="radio" />
                <span><strong>智能组卷（推荐）</strong><small>基于考研命题规律和知识权重，智能分配题量</small></span>
              </label>
              <label>
                <input v-model="rangeMode" value="自定义组卷" type="radio" />
                <span><strong>自定义组卷</strong><small>自定义范围和题量，灵活配置抽题条件</small></span>
              </label>
            </section>
            <section>
              <h3>题目来源　ⓘ</h3>
              <label v-for="source in rangeSources" :key="source.name">
                <input v-model="source.checked" type="checkbox" />
                <span><strong>{{ source.name }}</strong></span><b>{{ source.count }} 题</b>
              </label>
            </section>
            <section>
              <h3>命题策略　ⓘ</h3>
              <label v-for="strategy in rangeStrategies" :key="strategy.name">
                <input v-model="rangeStrategy" :value="strategy.name" type="radio" />
                <span><strong>{{ strategy.name }} <em v-if="strategy.recommended">推荐</em></strong><small>{{ strategy.desc }}</small></span>
              </label>
            </section>
          </aside>

          <main class="range-main">
            <div class="range-subject-picker">
              <strong>选择科目（可多选）</strong>
              <button
                v-for="subject in rangeSubjectOptions"
                :key="subject"
                :class="{ selected: selectedRangeSubjects.includes(subject), active: activeRangeSubject === subject }"
                @click="selectRangeSubject(subject)"
              >
                <span>{{ subject === '高等数学' ? 'f(x)' : subject === '线性代数' ? 'Aₓ₋ᵦ' : '∿' }}</span>
                <b>{{ subject }}</b>
                <i>{{ selectedRangeSubjects.includes(subject) ? '✓' : '+' }}</i>
              </button>
            </div>
            <h3>抽题策略　ⓘ</h3>
            <div class="strategy-cards">
              <button v-for="item in activeExtractionStrategies" :key="item.name" :class="{ active: activeExtractionStrategy === item.name }" @click="setExtractionStrategy(item.name)">
                <strong>{{ item.name }}</strong><small>{{ item.desc }}</small>
              </button>
            </div>
            <p class="strategy-tip">ⓘ　当前配置：{{ activeRangeSubject }} · {{ activeExtractionStrategy }}，系统将按该科目的题库结构分配题量</p>

            <section class="chapter-allocation">
              <div class="allocation-head"><span>{{ allocationLabel }}</span><span>重要度</span><span>题库数量</span><span>抽取题量</span><span>占比</span><span>操作</span></div>
              <div v-for="chapter in activeAllocationRows" :key="chapter.name" class="allocation-row">
                <strong>{{ chapter.name }}</strong>
                <span class="importance">{{ '★'.repeat(chapter.stars) }}<i>{{ '★'.repeat(5 - chapter.stars) }}</i></span>
                <span>{{ chapter.libraryCount }} 题</span>
                <div class="allocation-counter"><button @click="chapter.count = Math.max(0, chapter.count - 1)">−</button><b>{{ chapter.count }}</b><button @click="chapter.count += 1">＋</button></div>
                <div class="allocation-rate"><span>{{ chapter.rate }}%</span><i><b :style="{ width: `${chapter.rate * 3}px` }"></b></i></div>
                <button class="suggest-button" @click="applyChapterSuggestion(chapter)">应用建议</button>
              </div>
              <div v-if="addingAllocationRow" class="allocation-row draft-row">
                <div class="draft-selector">
                  <el-date-picker
                    v-if="activeExtractionStrategy === '按真题年份抽题'"
                    v-model="allocationDraft.year"
                    type="year"
                    value-format="YYYY"
                    placeholder="选择真题年份"
                    popper-class="allocation-picker-popper"
                    @change="applyDraftYear"
                  />
                  <el-select
                    v-else
                    v-model="allocationDraft.name"
                    filterable
                    clearable
                    :placeholder="`搜索并选择${allocationLabel}`"
                    popper-class="allocation-picker-popper"
                    @change="applyDraftOption"
                  >
                    <el-option
                      v-for="option in availableAllocationOptions"
                      :key="option.name"
                      :label="option.name"
                      :value="option.name"
                    />
                  </el-select>
                </div>
                <span class="importance">{{ allocationDraft.name ? '★'.repeat(allocationDraft.stars) : '—' }}<i v-if="allocationDraft.name">{{ '★'.repeat(5 - allocationDraft.stars) }}</i></span>
                <span>{{ allocationDraft.name ? `${allocationDraft.libraryCount} 题` : '—' }}</span>
                <div class="allocation-counter"><button @click="allocationDraft.count = Math.max(0, allocationDraft.count - 1)">−</button><b>{{ allocationDraft.count }}</b><button @click="allocationDraft.count += 1">＋</button></div>
                <div class="allocation-rate"><span>{{ allocationDraft.rate }}%</span><i><b :style="{ width: `${allocationDraft.rate * 3}px` }"></b></i></div>
                <div class="draft-actions"><button :disabled="!allocationDraft.name" @click="confirmAllocationDraft">确认</button><button @click="cancelAllocationDraft">取消</button></div>
              </div>
              <footer><button @click="startAddAllocation">＋ 添加{{ allocationLabel }}</button><span>当前科目：　<strong>{{ activeSubjectQuestions }} 题</strong></span><span>全部科目：　<strong>{{ totalAllocatedQuestions }} 题</strong></span></footer>
            </section>

            <div class="range-bottom-cards">
              <section>
                <h3>难度比例设置　ⓘ</h3>
                <div v-for="item in aggregateDifficulties" :key="item.name" class="range-difficulty-row">
                  <span>{{ item.name }}</span><i><b :style="{ width: `${item.rate}%`, background: item.color }"></b></i><span>{{ item.rate }}%</span><div><button @click="adjustAggregateDifficulty(item.name, -1)">−</button><b>{{ item.count }}</b><button @click="adjustAggregateDifficulty(item.name, 1)">＋</button></div>
                </div>
              </section>
              <section class="result-preview">
                <h3>预计抽题结果　ⓘ</h3>
                <div class="result-block metric-block">
                  <span>可抽题总量</span>
                  <strong>{{ totalAvailableQuestions.toLocaleString() }} <small>题</small></strong>
                  <small>{{ selectedRangeSubjects.length }} 个科目范围内</small>
                </div>
                <div class="result-block metric-block">
                  <span>预计生成题量</span>
                  <strong>{{ totalAllocatedQuestions }} <small>题</small></strong>
                  <small>所选科目合计</small>
                </div>
                <div class="result-block difficulty-block">
                  <strong>难度分布</strong>
                  <ul><li v-for="item in aggregateDifficulties" :key="item.name"><i :style="{ background: item.color }"></i><span>{{ item.name }}</span><b>{{ item.count }} 题</b><em>{{ item.rate }}%</em></li></ul>
                </div>
              </section>
            </div>
          </main>
        </div>
        <footer>
          <button class="footer-cancel" @click="closeRangeDialog">取消</button>
          <button @click="resetRangeSettings">重置</button>
          <button class="primary" @click="saveRangeSettings">保存设置</button>
        </footer>
      </section>
    </div>

    <div v-if="step === 2" class="preview-layout">
      <main class="column">
        <section class="paper-card summary-strip">
          <span>试卷名称：　<strong>高等数学综合练习卷（一）</strong></span>
          <span>试卷总分：　<strong>{{ totalTypeScore }} 分</strong></span>
          <span>预计时长：　<strong>120 分钟</strong></span>
          <span>题目数量：　<strong>42 题</strong></span>
        </section>
        <section class="paper-card preview-tabs">
          <button
            v-for="tab in previewTypeTabs"
            :key="tab.value"
            :class="{ active: activePreviewType === tab.value }"
            @click="activePreviewType = tab.value"
          >
            {{ tab.label }} ({{ tab.count }})
          </button>
        </section>
        <section class="paper-card questions-table">
          <div class="question-head"><span>题号</span><span>题目内容</span><span>题型</span><span>难度</span><span>分值</span><span>操作</span></div>
          <article v-for="question in filteredPreviewQuestions" :key="question.id" class="preview-question">
            <span class="question-id">{{ question.id }}</span>
            <div>
              <div class="question-labels">
                <span class="point-tag">知识点：{{ question.point }}</span>
                <span class="source-tag">来源：{{ question.source }}</span>
              </div>
              <p v-html="renderLatex(question.content)"></p>
            </div>
            <span class="soft-tag">{{ question.type }}</span>
            <span class="difficulty-tag" :class="question.level">{{ question.difficulty }}</span>
            <span>{{ question.score }} 分</span>
            <button class="preview-delete" @click="deletePreviewQuestion(question.id)">删除</button>
          </article>
          <div v-if="filteredPreviewQuestions.length === 0" class="preview-empty">当前题型暂无题目</div>
          <footer><span>共 42 题</span><div class="pagination"><button>10条/页⌄</button><button>‹</button><button class="active">1</button><button>2</button><button>3</button><button>4</button><button>5</button><button>…</button><button>›</button><span>前往　<input value="1" />　页</span></div></footer>
        </section>
      </main>
      <aside class="column">
        <StructurePanel />
        <section class="paper-card difficulty-card">
          <h2>难度分布</h2>
          <div v-for="item in difficultyRows" :key="item.name" class="difficulty-row">
            <span>{{ item.name }}</span><i><b :style="{ width: item.width, background: item.color }"></b></i><span>{{ item.count }} 题 ({{ item.rate }})</span>
          </div>
        </section>
        <KnowledgePanel />
      </aside>
    </div>

    <div v-if="step === 3" class="complete-layout">
      <main>
        <section class="paper-card success-card">
          <div class="success-icon"><el-icon><Check /></el-icon></div>
          <h2>组卷完成！</h2>
          <p>试卷已成功创建，可在 <strong>按试卷刷题-自定义组卷</strong> 中查看和管理</p>
          <div><button @click="backToPractice">返回刷题</button><button @click="router.push({ name: 'customPaper' })">继续组卷</button><button class="primary" @click="viewCreatedPaper">查看试卷</button></div>
        </section>
        <div class="complete-cards">
          <section class="paper-card paper-info">
            <h2>试卷信息</h2>
            <p><span>试卷名称：</span><strong>高等数学综合练习卷（一）</strong></p><p><span>试卷科目：</span><strong>高等数学</strong></p>
            <p><span>试卷难度：</span><strong>中等</strong></p><p><span>试卷用途：</span><strong>阶段练习</strong></p>
            <p><span>试卷描述：</span><strong>用于第一阶段学习后的综合检测</strong></p><p><span>创建时间：</span><strong>2024-05-12 11:30:25</strong></p>
            <p><span>创建人：</span><strong>奔跑的数学人</strong></p>
          </section>
          <StructurePanel />
        </div>
      </main>
      <aside><KnowledgePanel :long="true" /></aside>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, defineComponent, h, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import katex from 'katex'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Check } from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const step = computed(() => Number(route.meta.step || 1))
const flowSteps = [
  { routeStep: 1, displayStep: 1, title: '基本信息' },
  { routeStep: 2, displayStep: 2, title: '题目预览' },
  { routeStep: 3, displayStep: 3, title: '完成组卷' }
]
const visualStep = computed(() => step.value)
const nextButtonText = computed(() => {
  if (step.value === 1) return '下一步：题目预览'
  if (step.value === 2) return '下一步：完成组卷'
  return '完成并保存'
})
const difficulties = ['不限', '简单', '中等', '困难']
const form = reactive({
  name: '高等数学综合练习卷（一）',
  subject: '高等数学',
  difficulty: '中等',
  purpose: '阶段练习',
  description: '用于第一阶段学习后的综合检测',
  duration: 120,
  deduplicate: true,
  allowRepeatedPoint: true,
  subjectRange: '全部科目',
  bookRange: '全部教材',
  chapterRange: '全部章节',
  pointRange: '全部知识点',
  tagRange: '全部标签'
})
const defaultTypeRows = [
  { name: '单选题', count: 20, score: 2, total: 40, tags: ['高等数学'] },
  { name: '多选题', count: 10, score: 3, total: 30, tags: ['高等数学'] },
  { name: '填空题', count: 10, score: 2, total: 20, tags: ['高等数学'] },
  { name: '解答题', count: 2, score: 5, total: 10, tags: ['高等数学'] }
]
const typeRows = reactive(defaultTypeRows.map((row) => ({ ...row, tags: [...row.tags] })))
const excludedQuestionCount = ref(0)
const totalQuestionCount = computed(() => typeRows.reduce((sum, row) => sum + row.count, 0))
const totalTypeScore = computed(() => typeRows.reduce((sum, row) => sum + row.total, 0))
const rangeDialogVisible = ref(false)
const activeRangeIndex = ref(-1)
const activeRangeType = computed(() => typeRows[activeRangeIndex.value])
type RangeSubjectConfig = {
  book: string
  chapter: string
  point: string
  tag: string
  source: string
}
type TypeRangeSetting = {
  subjects: string[]
  configs: Record<string, RangeSubjectConfig>
}
const rangeSubjectOptions = ['高等数学', '线性代数', '概率统计']
const selectedRangeSubjects = ref<string[]>(['高等数学'])
const activeRangeSubject = ref('高等数学')
const rangeSubjectConfigs = reactive<Record<string, RangeSubjectConfig>>({
  高等数学: createDefaultRangeConfig(),
  线性代数: createDefaultRangeConfig(),
  概率统计: createDefaultRangeConfig()
})
const typeRangeSettings = reactive<Record<string, TypeRangeSetting>>({})
const rangeMode = ref('智能组卷')
const rangeSources = reactive([
  { name: '教材例题', count: '2,156', checked: true },
  { name: '教材课后习题', count: '3,284', checked: true },
  { name: '习题库', count: '12,568', checked: true },
  { name: '真题试卷', count: '8,742', checked: true },
  { name: '模拟试卷', count: '6,321', checked: true }
])
const rangeStrategy = ref('按考研权重')
const rangeStrategies = [
  { name: '按考研权重', desc: '按考研真题考频和重要度分配题量', recommended: true },
  { name: '平均抽题', desc: '各知识点/章节平均分配题量' },
  { name: '薄弱知识点优先', desc: '根据学习数据，优先抽取薄弱知识点' },
  { name: '错题优先', desc: '优先抽取历史错题，强化巩固' },
  { name: '强化训练', desc: '高难度题目占比提升，强化突破' },
  { name: '冲刺模式', desc: '接近考真题命题趋势抽题' }
]
type AllocationRow = { name: string; stars: number; libraryCount: number; count: number; rate: number }
type DifficultyRow = { name: string; rate: number; count: number; color: string }
const subjectExtractionStrategies = reactive<Record<string, string>>({
  高等数学: '按章节抽题',
  线性代数: '按章节抽题',
  概率统计: '按章节抽题'
})
const subjectAllocations = reactive<Record<string, Record<string, AllocationRow[]>>>({
  高等数学: {
    按章节抽题: [
      { name: '第一章　函数与极限', stars: 5, libraryCount: 236, count: 10, rate: 12 },
      { name: '第二章　导数与微分', stars: 5, libraryCount: 312, count: 15, rate: 18 },
      { name: '第三章　中值定理与导数应用', stars: 4, libraryCount: 128, count: 6, rate: 7 },
      { name: '第四章　不定积分', stars: 4, libraryCount: 186, count: 8, rate: 10 },
      { name: '第五章　定积分及其应用', stars: 5, libraryCount: 420, count: 20, rate: 24 }
    ],
    按知识点抽题: [
      { name: '函数极限与连续', stars: 5, libraryCount: 188, count: 12, rate: 22 },
      { name: '一元函数微分学', stars: 5, libraryCount: 246, count: 16, rate: 30 },
      { name: '一元函数积分学', stars: 5, libraryCount: 272, count: 15, rate: 28 },
      { name: '多元函数微积分', stars: 4, libraryCount: 196, count: 10, rate: 20 }
    ],
    按真题年份抽题: [
      { name: '2025 年真题', stars: 5, libraryCount: 22, count: 6, rate: 25 },
      { name: '2024 年真题', stars: 5, libraryCount: 22, count: 6, rate: 25 },
      { name: '2023 年真题', stars: 4, libraryCount: 22, count: 6, rate: 25 },
      { name: '2022 年真题', stars: 4, libraryCount: 22, count: 6, rate: 25 }
    ]
  },
  线性代数: {
    按章节抽题: [
      { name: '第一章　行列式', stars: 4, libraryCount: 132, count: 5, rate: 20 },
      { name: '第二章　矩阵及其运算', stars: 5, libraryCount: 196, count: 8, rate: 32 },
      { name: '第三章　向量组', stars: 5, libraryCount: 168, count: 6, rate: 24 },
      { name: '第四章　线性方程组', stars: 5, libraryCount: 154, count: 6, rate: 24 }
    ],
    按知识点抽题: [
      { name: '行列式计算', stars: 4, libraryCount: 98, count: 5, rate: 20 },
      { name: '矩阵的秩与逆', stars: 5, libraryCount: 164, count: 8, rate: 32 },
      { name: '线性相关性', stars: 5, libraryCount: 142, count: 6, rate: 24 },
      { name: '特征值与二次型', stars: 5, libraryCount: 176, count: 6, rate: 24 }
    ],
    按真题年份抽题: [
      { name: '2025 年线代真题', stars: 5, libraryCount: 6, count: 2, rate: 25 },
      { name: '2024 年线代真题', stars: 5, libraryCount: 6, count: 2, rate: 25 },
      { name: '2023 年线代真题', stars: 4, libraryCount: 6, count: 2, rate: 25 },
      { name: '2022 年线代真题', stars: 4, libraryCount: 6, count: 2, rate: 25 }
    ]
  },
  概率统计: {
    按章节抽题: [
      { name: '第一章　随机事件与概率', stars: 4, libraryCount: 118, count: 4, rate: 20 },
      { name: '第二章　随机变量及其分布', stars: 5, libraryCount: 186, count: 7, rate: 35 },
      { name: '第三章　多维随机变量', stars: 5, libraryCount: 146, count: 5, rate: 25 },
      { name: '第四章　数字特征', stars: 4, libraryCount: 124, count: 4, rate: 20 }
    ],
    按知识点抽题: [
      { name: '条件概率与独立性', stars: 4, libraryCount: 92, count: 4, rate: 20 },
      { name: '常见概率分布', stars: 5, libraryCount: 158, count: 7, rate: 35 },
      { name: '随机变量函数分布', stars: 5, libraryCount: 126, count: 5, rate: 25 },
      { name: '期望与方差', stars: 4, libraryCount: 108, count: 4, rate: 20 }
    ],
    按真题年份抽题: [
      { name: '2025 年概率真题', stars: 5, libraryCount: 6, count: 2, rate: 25 },
      { name: '2024 年概率真题', stars: 5, libraryCount: 6, count: 2, rate: 25 },
      { name: '2023 年概率真题', stars: 4, libraryCount: 6, count: 2, rate: 25 },
      { name: '2022 年概率真题', stars: 4, libraryCount: 6, count: 2, rate: 25 }
    ]
  }
})
const subjectDifficulties = reactive<Record<string, DifficultyRow[]>>({
  高等数学: [{ name: '简单', rate: 20, count: 11, color: '#20bf8f' }, { name: '中等', rate: 60, count: 32, color: '#ff9d00' }, { name: '困难', rate: 20, count: 11, color: '#ff375f' }],
  线性代数: [{ name: '简单', rate: 24, count: 6, color: '#20bf8f' }, { name: '中等', rate: 60, count: 15, color: '#ff9d00' }, { name: '困难', rate: 16, count: 4, color: '#ff375f' }],
  概率统计: [{ name: '简单', rate: 20, count: 4, color: '#20bf8f' }, { name: '中等', rate: 60, count: 12, color: '#ff9d00' }, { name: '困难', rate: 20, count: 4, color: '#ff375f' }]
})
const subjectAvailableCounts: Record<string, number> = { 高等数学: 18420, 线性代数: 7860, 概率统计: 6791 }
const activeExtractionStrategies = computed(() => [
  { name: '按章节抽题', desc: `按${activeRangeSubject.value}教材章节配置题量` },
  { name: '按知识点抽题', desc: `按${activeRangeSubject.value}核心知识点配置题量` },
  { name: '按真题年份抽题', desc: `按${activeRangeSubject.value}真题年份范围配置` }
])
const activeExtractionStrategy = computed(() => subjectExtractionStrategies[activeRangeSubject.value])
const activeAllocationRows = computed(() => subjectAllocations[activeRangeSubject.value][activeExtractionStrategy.value])
const allocationLabel = computed(() => activeExtractionStrategy.value === '按章节抽题' ? '章节' : activeExtractionStrategy.value === '按知识点抽题' ? '知识点' : '真题年份')
const activeSubjectQuestions = computed(() => activeAllocationRows.value.reduce((sum, item) => sum + item.count, 0))
const totalAllocatedQuestions = computed(() => selectedRangeSubjects.value.reduce((sum, subject) => {
  const strategy = subjectExtractionStrategies[subject]
  return sum + subjectAllocations[subject][strategy].reduce((total, item) => total + item.count, 0)
}, 0))
const totalAvailableQuestions = computed(() => selectedRangeSubjects.value.reduce((sum, subject) => sum + subjectAvailableCounts[subject], 0))
const aggregateDifficulties = computed(() => ['简单', '中等', '困难'].map((name) => {
  const rows = selectedRangeSubjects.value.map((subject) => subjectDifficulties[subject].find((item) => item.name === name)!)
  const count = rows.reduce((sum, item) => sum + item.count, 0)
  const total = rows.reduce((sum, item) => sum + item.count, 0)
  const overall = selectedRangeSubjects.value.reduce((sum, subject) => sum + subjectDifficulties[subject].reduce((s, item) => s + item.count, 0), 0)
  return { name, count, rate: overall ? Math.round(total / overall * 100) : 0, color: rows[0]?.color || '#20bf8f' }
}))
const addingAllocationRow = ref(false)
const allocationDraft = reactive({
  name: '',
  year: '',
  stars: 0,
  libraryCount: 0,
  count: 0,
  rate: 0
})
const allocationOptionCatalog: Record<string, Record<string, Array<{ name: string; stars: number; libraryCount: number; rate: number }>>> = {
  高等数学: {
    章节: [
      { name: '第六章　微分方程', stars: 3, libraryCount: 96, rate: 8 },
      { name: '第七章　向量代数与空间解析几何', stars: 3, libraryCount: 82, rate: 7 },
      { name: '第八章　多元函数微分学', stars: 4, libraryCount: 120, rate: 10 },
      { name: '第九章　重积分', stars: 4, libraryCount: 108, rate: 9 }
    ],
    知识点: [
      { name: '洛必达法则', stars: 5, libraryCount: 126, rate: 12 },
      { name: '泰勒公式', stars: 5, libraryCount: 114, rate: 11 },
      { name: '曲线积分', stars: 4, libraryCount: 88, rate: 8 },
      { name: '无穷级数', stars: 4, libraryCount: 102, rate: 10 }
    ]
  },
  线性代数: {
    章节: [
      { name: '第五章　特征值与特征向量', stars: 5, libraryCount: 176, rate: 25 },
      { name: '第六章　二次型', stars: 4, libraryCount: 128, rate: 18 }
    ],
    知识点: [
      { name: '矩阵相似', stars: 5, libraryCount: 138, rate: 22 },
      { name: '正交变换', stars: 4, libraryCount: 96, rate: 15 },
      { name: '线性方程组', stars: 5, libraryCount: 154, rate: 24 }
    ]
  },
  概率统计: {
    章节: [
      { name: '第五章　大数定律与中心极限定理', stars: 5, libraryCount: 112, rate: 20 },
      { name: '第六章　数理统计基本概念', stars: 4, libraryCount: 94, rate: 16 }
    ],
    知识点: [
      { name: '中心极限定理', stars: 5, libraryCount: 106, rate: 20 },
      { name: '参数估计', stars: 4, libraryCount: 92, rate: 16 },
      { name: '假设检验', stars: 4, libraryCount: 84, rate: 14 }
    ]
  }
}
const availableAllocationOptions = computed(() => {
  const type = activeExtractionStrategy.value === '按章节抽题' ? '章节' : '知识点'
  const options = [
    ...activeAllocationRows.value.map((item) => ({
      name: item.name,
      stars: item.stars,
      libraryCount: item.libraryCount,
      rate: item.rate
    })),
    ...(allocationOptionCatalog[activeRangeSubject.value]?.[type] || [])
  ]
  return Array.from(new Map(options.map((item) => [item.name, item])).values())
})
const previewQuestions = ref([
  { id: 1, point: '函数的极限', source: '同济高等数学第七版', content: '设函数 $f(x)=\\frac{1-\\cos x}{x^2}\\ (x\\ne0),\\ f(0)=a$，若 $f(x)$ 在 $x=0$ 处连续，则 $a=\\left(\\quad\\right)$。', type: '单选题', difficulty: '中等', level: 'medium', score: 2 },
  { id: 2, point: '导数的概念', source: '考研数学真题题库', content: '设函数 $y=f(x)$ 在点 $x=x_0$ 处可导，且 $f^{\\prime}(x_0)=2$，则 $\\lim_{\\Delta x\\to0}\\frac{f(x_0+\\Delta x)-f(x_0)}{\\Delta x}=\\left(\\quad\\right)$。', type: '单选题', difficulty: '中等', level: 'medium', score: 2 },
  { id: 3, point: '导数的运算法则', source: '2024年数学一真题试卷', content: '设 $u(x),v(x)$ 在区间 $I$ 上可导，下列等式正确的有 $\\left(\\quad\\right)$。<br>$A.\\ (u+v)^{\\prime}=u^{\\prime}+v^{\\prime}\\qquad B.\\ (uv)^{\\prime}=u^{\\prime}v+uv^{\\prime}$', type: '多选题', difficulty: '中等', level: 'medium', score: 3 },
  { id: 4, point: '定积分的概念', source: '高等数学习题库', content: '设 $f(x)$ 在 $[a,b]$ 上连续，则 $\\int_a^b f(x)\\,dx$ 与原函数 $F(x)$ 的关系为 $\\left(\\quad\\right)$。', type: '单选题', difficulty: '简单', level: 'easy', score: 2 },
  { id: 5, point: '微分中值定理', source: '张宇高数十八讲', content: '若函数 $f(x)$ 在闭区间 $[a,b]$ 上连续，在开区间 $(a,b)$ 内可导，则至少存在一点 $\\xi\\in(a,b)$，使得 $f^{\\prime}(\\xi)=\\frac{f(b)-f(a)}{b-a}$。', type: '单选题', difficulty: '困难', level: 'hard', score: 2 },
  { id: 6, point: '不定积分', source: '同济高等数学课后习题', content: '计算不定积分 $\\int \\frac{1}{1+x^2}\\,dx=$ ________。', type: '填空题', difficulty: '简单', level: 'easy', score: 2 },
  { id: 7, point: '定积分应用', source: '考研数学模拟题库', content: '求曲线 $y=x^2$ 与直线 $y=x$ 所围图形的面积。', type: '解答题', difficulty: '中等', level: 'medium', score: 5 }
])
const activePreviewType = ref('全部题目')
const previewTypeValues = ['全部题目', '单选题', '多选题', '填空题', '解答题']
const previewTypeTabs = computed(() => previewTypeValues.map((value) => ({
  value,
  label: value,
  count: value === '全部题目'
    ? previewQuestions.value.length
    : previewQuestions.value.filter((question) => question.type === value).length
})))
const filteredPreviewQuestions = computed(() => activePreviewType.value === '全部题目'
  ? previewQuestions.value
  : previewQuestions.value.filter((question) => question.type === activePreviewType.value))
const difficultyRows = [
  { name: '简单', count: 8, rate: '19%', width: '42%', color: '#29c69a' },
  { name: '中等', count: 26, rate: '62%', width: '88%', color: '#ff9d13' },
  { name: '困难', count: 8, rate: '19%', width: '42%', color: '#ff4545' }
]
const knowledge = ['函数的极限', '导数的概念', '导数的运算法则', '不定积分', '定积分及其应用', '微分中值定理', '洛必达法则', '微分及其应用', '定积分的计算方法', '积分中值定理', '无穷级数', '泰勒公式', '曲线的切线与法线', '常微分方程初步', '二重积分', '曲线积分', '向量代数与空间解析几何', '曲面积分', '反常积分', '微分方程应用']

function backToPractice() {
  router.push({ name: 'practice', query: { mode: 'paper' } })
}
function viewCreatedPaper() {
  router.push({ name: 'practice', query: { mode: 'paper', tab: 'custom' } })
}
function nextStep() {
  if (step.value === 1) {
    if (!form.name.trim()) {
      ElMessage.warning('请输入试卷名称')
      return
    }
    router.push({ name: 'customPaperPreview' })
  }
  else if (step.value === 2) router.push({ name: 'customPaperComplete' })
  else viewCreatedPaper()
}
function previousStep() {
  router.push({ name: step.value === 3 ? 'customPaperPreview' : 'customPaper' })
}
function renderLatex(text: string) {
  return text.replace(/\$([^$]+?)\$/g, (_, formula: string) => katex.renderToString(formula, { throwOnError: false }))
}
async function deletePreviewQuestion(id: number) {
  try {
    await ElMessageBox.confirm(
      `确定要从当前试卷中删除第 ${id} 题吗？删除后可重新组卷补充题目。`,
      '确认删除题目',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'danger-confirm-button',
        distinguishCancelAndClose: true
      }
    )
  } catch {
    return
  }
  previewQuestions.value = previewQuestions.value.filter((question) => question.id !== id)
  ElMessage.success('题目已从试卷中删除')
}
function adjustFormNumber(field: 'duration', delta: number) {
  const minimum = 10
  form[field] = Math.max(minimum, form[field] + delta)
}
function adjustType(index: number, field: 'count' | 'score', delta: number) {
  const row = typeRows[index]
  if (!row) return
  row[field] = Math.max(field === 'count' ? 0 : 1, row[field] + delta)
  row.total = row.count * row.score
}
function addQuestionType() {
  const available = ['判断题', '计算题', '证明题'].find((name) => !typeRows.some((row) => row.name === name))
  if (!available) {
    ElMessage.info('可添加的题型已全部加入')
    return
  }
  typeRows.push({ name: available, count: 5, score: 2, total: 10, tags: ['高等数学'] })
  ElMessage.success(`已添加${available}`)
}
function editQuestionType(name: string) {
  ElMessage.info(`已打开“${name}”设置`)
}
function deleteQuestionType(index: number) {
  if (typeRows.length <= 1) {
    ElMessage.warning('至少保留一种题型')
    return
  }
  const [removed] = typeRows.splice(index, 1)
  ElMessage.success(`已删除${removed?.name || '题型'}`)
}
function removeScopeTag(index: number, tag: string) {
  const row = typeRows[index]
  if (!row) return
  row.tags = row.tags.filter((item) => item !== tag)
}
function resetTypeSettings() {
  typeRows.splice(0, typeRows.length, ...defaultTypeRows.map((row) => ({ ...row, tags: [...row.tags] })))
  ElMessage.success('题型设置已重置')
}
function chooseExcludedQuestions() {
  excludedQuestionCount.value = excludedQuestionCount.value ? 0 : 3
  ElMessage.success(excludedQuestionCount.value ? '已选择 3 道排除题目' : '已清空排除题目')
}
function openRangeDialog(index: number) {
  activeRangeIndex.value = index
  const row = typeRows[index]
  const saved = row ? typeRangeSettings[row.name] : undefined
  selectedRangeSubjects.value = saved?.subjects.length ? [...saved.subjects] : ['高等数学']
  activeRangeSubject.value = selectedRangeSubjects.value[0] || '高等数学'
  rangeSubjectOptions.forEach((subject) => {
    Object.assign(rangeSubjectConfigs[subject], saved?.configs[subject] || createDefaultRangeConfig())
  })
  rangeDialogVisible.value = true
}
function closeRangeDialog() {
  rangeDialogVisible.value = false
  activeRangeIndex.value = -1
}
function saveRangeSettings() {
  const row = activeRangeType.value
  if (!row) return
  const configs = Object.fromEntries(
    selectedRangeSubjects.value.map((subject) => [subject, { ...rangeSubjectConfigs[subject] }])
  )
  typeRangeSettings[row.name] = {
    subjects: [...selectedRangeSubjects.value],
    configs
  }
  row.tags = selectedRangeSubjects.value.length > 2
    ? [...selectedRangeSubjects.value.slice(0, 2), `+${selectedRangeSubjects.value.length - 2}`]
    : [...selectedRangeSubjects.value]
  ElMessage.success(`“${row.name}”抽题范围已保存`)
  closeRangeDialog()
}
function createDefaultRangeConfig(): RangeSubjectConfig {
  return {
    book: '全部教材',
    chapter: '全部章节',
    point: '全部知识点',
    tag: '全部标签',
    source: '全部来源'
  }
}
function selectRangeSubject(subject: string) {
  if (selectedRangeSubjects.value.includes(subject)) {
    if (activeRangeSubject.value !== subject) {
      activeRangeSubject.value = subject
    } else if (selectedRangeSubjects.value.length > 1) {
      selectedRangeSubjects.value = selectedRangeSubjects.value.filter((item) => item !== subject)
      activeRangeSubject.value = selectedRangeSubjects.value[0]
    }
  } else {
    selectedRangeSubjects.value = [...selectedRangeSubjects.value, subject]
    activeRangeSubject.value = subject
  }
}
function setExtractionStrategy(strategy: string) {
  subjectExtractionStrategies[activeRangeSubject.value] = strategy
  cancelAllocationDraft()
}
function getRangeOptions(subject: string) {
  if (subject === '线性代数') {
    return {
      books: ['全部教材', '同济线性代数第七版', '李永乐线性代数辅导讲义', '历年真题'],
      chapters: ['全部章节', '第一章 行列式', '第二章 矩阵及其运算', '第三章 向量组'],
      points: ['全部知识点', '行列式', '矩阵的秩', '线性相关性', '特征值与特征向量']
    }
  }
  if (subject === '概率统计') {
    return {
      books: ['全部教材', '浙大概率论第四版', '王式安概率论辅导讲义', '历年真题'],
      chapters: ['全部章节', '第一章 随机事件与概率', '第二章 随机变量', '第三章 多维随机变量'],
      points: ['全部知识点', '条件概率', '随机变量分布', '数字特征', '参数估计']
    }
  }
  return {
    books: ['全部教材', '同济高等数学第七版', '张宇高数18讲', '历年真题'],
    chapters: ['全部章节', '第一章 函数与极限', '第二章 导数与微分', '第三章 微分中值定理'],
    points: ['全部知识点', '函数的极限', '导数的概念', '定积分', '微分方程']
  }
}
function applyChapterSuggestion(chapter: { count: number; rate: number }) {
  chapter.count = Math.max(1, Math.round(activeSubjectQuestions.value * chapter.rate / 100))
  ElMessage({
    message: '已应用建议题量',
    type: 'success',
    zIndex: 5000
  })
}
function adjustAggregateDifficulty(name: string, delta: number) {
  const activeRow = subjectDifficulties[activeRangeSubject.value].find((item) => item.name === name)
  if (activeRow) activeRow.count = Math.max(0, activeRow.count + delta)
}
function resetRangeSettings() {
  rangeMode.value = '智能组卷'
  rangeStrategy.value = '按考研权重'
  rangeSubjectOptions.forEach((subject) => { subjectExtractionStrategies[subject] = '按章节抽题' })
  rangeSources.forEach((item) => { item.checked = true })
  cancelAllocationDraft()
  ElMessage.success('抽题范围设置已重置')
}
function startAddAllocation() {
  Object.assign(allocationDraft, { name: '', year: '', stars: 0, libraryCount: 0, count: 0, rate: 0 })
  addingAllocationRow.value = true
}
function applyDraftOption(name: string) {
  const option = availableAllocationOptions.value.find((item) => item.name === name)
  if (!option) return
  const suggestedCount = Math.max(1, Math.round(activeSubjectQuestions.value * option.rate / 100))
  Object.assign(allocationDraft, {
    name: option.name,
    stars: option.stars,
    libraryCount: option.libraryCount,
    rate: option.rate,
    count: suggestedCount
  })
}
function applyDraftYear(year: string) {
  if (!year) return
  const numericYear = Number(year)
  const newestYear = 2026
  const distance = Math.max(0, newestYear - numericYear)
  const stars = Math.max(3, 5 - Math.floor(distance / 3))
  const libraryCount = activeRangeSubject.value === '高等数学' ? 22 : 6
  const rate = 25
  Object.assign(allocationDraft, {
    name: `${year} 年${activeRangeSubject.value}真题`,
    stars,
    libraryCount,
    rate,
    count: Math.max(1, Math.round(activeSubjectQuestions.value * rate / 100))
  })
}
function confirmAllocationDraft() {
  if (!allocationDraft.name) return
  if (activeAllocationRows.value.some((item) => item.name === allocationDraft.name)) {
    ElMessage({ message: `${allocationDraft.name} 已在当前列表中`, type: 'warning', zIndex: 5000 })
    return
  }
  activeAllocationRows.value.push({
    name: allocationDraft.name,
    stars: allocationDraft.stars,
    libraryCount: allocationDraft.libraryCount,
    count: allocationDraft.count,
    rate: allocationDraft.rate
  })
  ElMessage({ message: `已添加${allocationLabel.value}：${allocationDraft.name}`, type: 'success', zIndex: 5000 })
  cancelAllocationDraft()
}
function cancelAllocationDraft() {
  addingAllocationRow.value = false
  Object.assign(allocationDraft, { name: '', year: '', stars: 0, libraryCount: 0, count: 0, rate: 0 })
}

const Donut = defineComponent({
  setup: () => () => h('div', { class: 'donut' }, [h('div', { class: 'donut-hole' }, [h('strong', String(totalQuestionCount.value)), h('span', '总题数')])])
})
const StructurePanel = defineComponent({
  setup: () => () => h('section', { class: 'paper-card structure-card' }, [
    h('h2', '试卷结构预览'),
    h('div', { class: 'structure-top' }, [h(Donut), h('div', { class: 'structure-stats' }, [h('p', ['总分：', h('strong', `${totalTypeScore.value} 分`)]), h('p', ['总题量：', h('strong', `${totalQuestionCount.value} 题`)]), h('p', ['预计时长：', h('strong', `${form.duration} 分钟`)])])]),
    h('div', { class: 'structure-list' }, typeRows.map((row, index) => h('p', [h('i', { class: `dot dot-${index}` }), h('span', `${row.name}（${row.count}题）`), h('strong', `${row.total} 分`)])))
  ])
})
const KnowledgePanel = defineComponent({
  props: { long: Boolean },
  setup: (props) => () => h('section', { class: ['paper-card', 'knowledge-card', { long: props.long }] }, [
    h('h2', '知识点覆盖 TOP10'),
    h('div', { class: 'knowledge-head' }, [h('span', '知识点'), h('span', '题量'), h('span', '占比')]),
    ...knowledge.slice(0, props.long ? 20 : 5).map((name, index) => h('p', [h('span', `${index + 1}.　${name}`), h('span', `${Math.max(1, 12 - index * 2)}题`), h('span', `${Math.max(2, 28 - index * 4)}%`)])),
    !props.long ? h('span', '…') : null
  ])
})
</script>

<style scoped lang="scss">
.custom-paper-page { color: var(--text); }
.flow-header { display: flex; align-items: center; height: 66px; margin: -14px -24px 18px; padding: 0 28px; background: #fff; border-bottom: 1px solid var(--line); }
.stepper { display: flex; align-items: center; justify-content: center; flex: 1; }
.step { display: flex; align-items: center; color: var(--ink); }
.step > span { display: grid; place-items: center; width: 34px; height: 34px; border: 1px solid #cbd6f1; border-radius: 50%; }
.step strong { margin-left: 12px; font-size: 15px; }.step i { width: 78px; height: 1px; margin: 0 18px; background: #cad7fa; }
.step.active > span { color: #fff; border-color: var(--primary); background: var(--primary); box-shadow: 0 8px 16px rgba(31,83,255,.2); }
.step.active strong, .step.done strong, .step.done > span { color: var(--primary); }
.flow-actions { display: flex; gap: 14px; }
.flow-actions button, .success-card button { height: 38px; padding: 0 22px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 5px; background: #fff; }
.flow-actions .primary, .success-card .primary { color: #fff; border-color: var(--primary); background: var(--primary); }
.settings-layout, .question-settings-layout, .preview-layout, .complete-layout { display: grid; grid-template-columns: minmax(0, 1fr) 345px; gap: 18px; }
.column { display: flex; flex-direction: column; gap: 16px; }
.paper-card { background: #fff; border: 1px solid var(--line); border-radius: 7px; }
.paper-card h2 { margin: 0; color: var(--ink); font-size: 16px; }
.info-card { padding: 22px 24px 12px; }
.info-columns { display: grid; grid-template-columns: 1fr 1fr; gap: 48px; margin-top: 10px; }
.form-column { display: flex; flex-direction: column; gap: 11px; }
.form-column > label { display: grid; grid-template-columns: 94px 1fr; align-items: center; min-height: 36px; font-size: 13px; }
.form-column label > span { color: var(--ink); font-weight: 700; } em { color: #f14343; font-style: normal; }
.field, .textarea { display: flex; align-items: center; justify-content: space-between; min-height: 34px; padding: 0 12px; border: 1px solid #dbe2f2; border-radius: 5px; background: #fff; }
.field small, .textarea small { color: var(--muted); font-size: 11px; }
.input-field input, .textarea textarea { min-width: 0; flex: 1; color: var(--text); font: inherit; border: 0; outline: 0; background: transparent; }
.textarea textarea { min-height: 58px; padding: 0; resize: none; }
.native-select { width: 100%; color: var(--text); font: inherit; outline: 0; cursor: pointer; }
.native-select:focus, .input-field:focus-within, .textarea:focus-within { border-color: var(--primary); box-shadow: 0 0 0 2px rgba(31,83,255,.08); }
.difficulty-buttons { display: flex; gap: 12px; }.difficulty-buttons button { width: 62px; height: 32px; color: var(--text); border: 1px solid var(--line); border-radius: 5px; background: #fff; }.difficulty-buttons button.active { color: var(--primary); border-color: var(--primary); background: #f5f8ff; }
.description { align-items: start !important; }.textarea { align-items: flex-start; min-height: 84px; padding-top: 12px; }.textarea small { align-self: flex-end; margin-left: auto; }
.compact > label { grid-template-columns: 92px 148px 40px; }
.counter, .mini-counter { display: flex; align-items: center; justify-content: space-between; height: 34px; border: 1px solid var(--line); border-radius: 5px; }.counter button, .mini-counter button { height: 100%; padding: 0 12px; color: var(--text); border: 0; background: transparent; }.counter b { margin-left: 12px; }
.readonly-score { display: flex; align-items: center; justify-content: center; height: 34px; color: var(--ink); background: #f7f9fd; border: 1px solid var(--line); border-radius: 5px; }
.readonly-score strong { font-size: 15px; }
.choice-group { display: flex; flex-direction: column; gap: 10px; margin: 2px 0; font-size: 13px; }.choice-group small { color: var(--muted); }.check-line { display: flex !important; flex-direction: column; align-items: start !important; gap: 8px; } input { accent-color: var(--primary); }
.type-card { overflow: hidden; }.card-title { display: flex; align-items: center; justify-content: space-between; padding: 16px 20px; }.card-title button, .choose-button { height: 32px; padding: 0 14px; color: var(--primary); border: 1px solid #9db4ff; border-radius: 5px; background: #fff; }
.type-head, .type-row { display: grid; grid-template-columns: 125px 100px 110px 90px minmax(170px, 1fr) 190px; align-items: center; column-gap: 12px; min-height: 54px; padding: 0 20px; }.type-head { color: var(--muted); font-size: 12px; background: #fafbfe; }.type-row { font-size: 13px; border-top: 1px solid var(--line); }
.scope-tags { display: flex; gap: 6px; overflow: hidden; }.scope-tags button { padding: 5px 8px; color: var(--primary); font-size: 11px; border: 0; background: var(--primary-soft); border-radius: 4px; white-space: nowrap; }.row-actions { display: flex; gap: 8px; color: var(--text); }.row-actions button { height: 30px; padding: 0 10px; font-size: 12px; border-radius: 5px; background: #fff; white-space: nowrap; }.row-actions .range-action { color: var(--primary); border: 1px solid #a7baff; }.row-actions .delete-action { color: #e55252; border: 1px solid #f2baba; }
.type-card footer { display: flex; align-items: center; gap: 150px; min-height: 52px; padding: 0 20px; border-top: 1px solid var(--line); }.type-card footer button { margin-left: auto; height: 32px; padding: 0 18px; color: var(--text); border: 1px solid var(--line); border-radius: 5px; background: #fff; }
.range-card { padding: 16px 20px 18px; }.range-grid { display: grid; grid-template-columns: repeat(6, 1fr); gap: 22px; margin-top: 12px; }.range-grid label { font-size: 12px; }.range-grid .field { min-width: 120px; margin-top: 8px; }.inline-options { display: flex; gap: 12px; margin-top: 15px; white-space: nowrap; }.inline-options label { cursor: pointer; }.choose-button { display: block; margin-top: 8px; }.range-card > p { margin: 18px 0 0; color: var(--muted); font-size: 12px; }
.column > .paper-card:not(.info-card):not(.type-card):not(.range-card):not(.summary-strip):not(.preview-tabs):not(.questions-table) { padding: 22px; }
.structure-top { display: flex; align-items: center; gap: 28px; margin-top: 20px; padding-bottom: 20px; border-bottom: 1px solid var(--line); }
.donut { display: grid; place-items: center; width: 120px; height: 120px; border-radius: 50%; background: conic-gradient(#2663f5 0 40%, #2cc498 40% 64%, #ff9d13 64% 83%, #a956bd 83%); }.donut-hole { display: flex; flex-direction: column; align-items: center; justify-content: center; width: 78px; height: 78px; background: #fff; border-radius: 50%; }.donut-hole strong { color: var(--ink); font-size: 28px; }.donut-hole span { font-size: 12px; }
.structure-stats p { margin: 10px 0; font-size: 13px; }.structure-stats strong { color: var(--ink); }.structure-list p { display: flex; align-items: center; margin: 17px 0; font-size: 13px; }.structure-list p span { flex: 1; }.dot { width: 11px; height: 11px; margin-right: 12px; border-radius: 50%; background: #2663f5; }.dot-1 { background: #2cc498; }.dot-2 { background: #ff9d13; }.dot-3 { background: #a956bd; }
.note-card p { margin: 14px 0 0; font-size: 12px; line-height: 1.7; }.warm h2 { color: #d88600; }
.question-setting-top { padding: 0 20px 18px; }
.paper-summary { display: flex; gap: 70px; min-height: 66px; align-items: center; border-bottom: 1px solid var(--line); font-size: 13px; }
.extract-tabs { display: flex; gap: 50px; height: 54px; align-items: stretch; }
.extract-tabs button { position: relative; padding: 0 4px; color: var(--text); font: inherit; font-size: 14px; border: 0; background: transparent; }
.extract-tabs button.active { color: var(--primary); font-weight: 700; }
.extract-tabs button.active::after { position: absolute; right: 0; bottom: 0; left: 0; height: 2px; content: ''; background: var(--primary); }
.filter-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 14px 24px; padding-top: 16px; }
.filter-grid label { display: grid; grid-template-columns: 54px 1fr; align-items: center; font-size: 13px; }
.filter-grid select, .available-panel select, .selected-panel select { height: 34px; padding: 0 10px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 5px; background: #fff; outline: 0; }
.filter-grid select:focus, .available-panel select:focus, .selected-panel select:focus { border-color: var(--primary); }
.filter-actions { display: flex; justify-content: flex-end; gap: 12px; grid-column: 3; }
.filter-actions button { width: 80px; height: 34px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 5px; background: #fff; }
.filter-actions .primary { color: #fff; border-color: var(--primary); background: var(--primary); }
.selection-workspace { display: grid; grid-template-columns: minmax(300px, .85fr) 42px minmax(420px, 1.25fr); gap: 16px; align-items: center; }
.available-panel, .selected-panel { min-height: 510px; overflow: hidden; }
.available-panel header, .selected-panel header { display: flex; align-items: center; justify-content: space-between; height: 52px; padding: 0 18px; border-bottom: 1px solid var(--line); }
.available-panel header strong, .selected-panel header strong { color: var(--ink); font-size: 14px; }
.available-panel header select, .selected-panel header select { height: 30px; font-size: 12px; }
.selected-panel header > div { display: flex; align-items: center; gap: 14px; }
.selected-panel header > div > button { color: var(--muted); border: 0; background: transparent; }
.question-search { height: 36px; margin: 10px 12px; padding: 9px 12px; color: #a1abc4; font-size: 12px; border: 1px solid var(--line); border-radius: 4px; }
.chapter-option { display: grid; grid-template-columns: 18px auto 1fr 18px; align-items: center; min-height: 43px; padding: 0 16px; font-size: 12px; border-top: 1px solid #f0f2f8; }
.chapter-option strong { color: var(--text); }.chapter-option small { margin-left: 6px; color: var(--muted); }
.transfer-buttons { display: flex; flex-direction: column; gap: 12px; }
.transfer-buttons button { width: 34px; height: 34px; color: var(--primary); border: 1px solid #b6c6fa; border-radius: 5px; background: #fff; }
.selected-group { padding: 12px 18px 16px; border-bottom: 1px solid var(--line); }
.group-title { display: flex; align-items: center; color: var(--text); font-size: 13px; }.group-title span { margin-left: 6px; color: var(--muted); }
.question-number-list { display: flex; align-items: center; gap: 10px; margin-top: 14px; }
.question-number-list button:not(.group-action) { width: 28px; height: 28px; color: var(--primary); border: 1px solid #b7c7f8; border-radius: 4px; background: #fff; }
.question-number-list .group-action { margin-left: auto; padding: 3px; color: var(--text); border: 0; background: transparent; }
.question-number-list .group-action + .group-action { margin-left: 0; }
.selected-panel footer { display: flex; align-items: center; justify-content: space-between; min-height: 55px; padding: 0 18px; font-size: 12px; }
.selected-panel footer button { height: 32px; padding: 0 14px; color: var(--primary); border: 1px solid #9eb5ff; border-radius: 5px; background: #fff; }
.summary-strip { display: flex; align-items: center; justify-content: space-between; min-height: 62px; padding: 0 20px; font-size: 13px; }
.preview-tabs { display: flex; align-items: center; gap: 36px; min-height: 54px; padding: 0 18px; }.preview-tabs button { height: 54px; padding: 0 4px; color: var(--text); font: inherit; border: 0; background: transparent; }.preview-tabs button.active { color: var(--primary); border-bottom: 2px solid var(--primary); }.preview-tabs .tab-action { height: 34px; padding: 0 12px; border: 1px solid var(--line); border-radius: 5px; }.preview-tabs .tab-action:first-of-type { margin-left: auto; }
.questions-table { overflow: hidden; }.question-head, .preview-question { display: grid; grid-template-columns: 55px 1fr 75px 75px 60px 65px; gap: 12px; }.question-head { padding: 14px 18px; color: var(--muted); font-size: 12px; background: #fafbfe; }.preview-question { align-items: center; min-height: 103px; padding: 12px 18px; border-bottom: 1px solid var(--line); font-size: 12px; }
.preview-empty { display: grid; place-items: center; min-height: 260px; color: var(--muted); font-size: 14px; border-bottom: 1px solid var(--line); background: #fcfdff; }
.question-id { display: grid; place-items: center; width: 24px; height: 24px; color: var(--primary); background: var(--primary-soft); border-radius: 4px; }.question-labels { display: flex; flex-wrap: wrap; gap: 8px; }.point-tag { padding: 4px 8px; color: var(--primary); background: var(--primary-soft); border-radius: 4px; }.source-tag { padding: 4px 8px; color: #7562b4; background: #f3efff; border-radius: 4px; }.preview-question p { margin: 10px 0 0; color: var(--ink); line-height: 1.75; }.soft-tag, .difficulty-tag { justify-self: start; padding: 4px 7px; background: #f1f3f8; border-radius: 4px; }.difficulty-tag.medium { color: #e68200; background: #fff2df; }.difficulty-tag.easy { color: #15945f; background: #e8f8ef; }.difficulty-tag.hard { color: #f23939; background: #ffe9e9; }
.preview-delete { justify-self: start; padding: 5px 10px; color: #e5484d; font: inherit; font-size: 12px; border: 1px solid #f3c2c4; border-radius: 5px; background: #fff7f7; }.preview-delete:hover { color: #fff; border-color: #e5484d; background: #e5484d; }
.questions-table footer { display: flex; align-items: center; justify-content: space-between; min-height: 54px; padding: 0 18px; font-size: 12px; }.pagination { display: flex; align-items: center; gap: 10px; }.pagination button { height: 30px; min-width: 30px; color: var(--text); border: 1px solid var(--line); border-radius: 4px; background: #fff; }.pagination button.active { color: #fff; background: var(--primary); }.pagination input { width: 38px; height: 30px; text-align: center; border: 1px solid var(--line); border-radius: 4px; }
.difficulty-card h2, .knowledge-card h2 { margin-bottom: 22px; }.difficulty-row { display: grid; grid-template-columns: 45px 1fr 84px; gap: 10px; align-items: center; margin: 18px 0; font-size: 12px; }.difficulty-row i { height: 8px; background: #edf0f7; border-radius: 5px; overflow: hidden; }.difficulty-row b { display: block; height: 100%; border-radius: 5px; }
.knowledge-head, .knowledge-card p { display: grid; grid-template-columns: 1fr 45px 45px; gap: 8px; font-size: 12px; }.knowledge-head { color: var(--muted); }.knowledge-card p { margin: 14px 0; }.knowledge-card.long p { margin: 13px 0; }
.complete-layout { grid-template-columns: minmax(0, 1fr) 365px; }.success-card { display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 260px; }.success-icon { display: grid; place-items: center; width: 72px; height: 72px; color: #fff; font-size: 44px; background: #2dc44f; border-radius: 50%; }.success-card h2 { margin-top: 18px; font-size: 24px; }.success-card p { margin: 14px 0 18px; font-size: 13px; }.success-card p strong { color: var(--primary); }.success-card > div:last-child { display: flex; gap: 38px; }
.complete-cards { display: grid; grid-template-columns: 1fr 1.1fr; gap: 18px; margin-top: 18px; }.complete-cards > .paper-card { min-height: 395px; padding: 28px; }.paper-info p { display: grid; grid-template-columns: 95px 1fr; margin: 22px 0; font-size: 13px; }.paper-info p span { color: var(--muted); }.complete-layout > aside .knowledge-card { min-height: 815px; padding: 24px; }
.custom-paper-page :deep(.structure-card h2),
.custom-paper-page :deep(.knowledge-card h2) { margin: 0; color: var(--ink); font-size: 16px; }
.custom-paper-page :deep(.structure-top) { display: flex; align-items: center; gap: 28px; margin-top: 20px; padding-bottom: 20px; border-bottom: 1px solid var(--line); }
.custom-paper-page :deep(.donut) { display: grid; place-items: center; flex: 0 0 120px; width: 120px; height: 120px; border-radius: 50%; background: conic-gradient(#2663f5 0 40%, #2cc498 40% 64%, #ff9d13 64% 83%, #a956bd 83%); }
.custom-paper-page :deep(.donut-hole) { display: flex; flex-direction: column; align-items: center; justify-content: center; width: 78px; height: 78px; background: #fff; border-radius: 50%; }
.custom-paper-page :deep(.donut-hole strong) { color: var(--ink); font-size: 28px; }
.custom-paper-page :deep(.donut-hole span) { font-size: 12px; }
.custom-paper-page :deep(.structure-stats p) { margin: 10px 0; font-size: 13px; }
.custom-paper-page :deep(.structure-stats strong) { color: var(--ink); }
.custom-paper-page :deep(.structure-list p) { display: flex; align-items: center; margin: 17px 0; font-size: 13px; }
.custom-paper-page :deep(.structure-list p span) { flex: 1; }
.custom-paper-page :deep(.dot) { width: 11px; height: 11px; margin-right: 12px; border-radius: 50%; background: #2663f5; }
.custom-paper-page :deep(.dot-1) { background: #2cc498; }
.custom-paper-page :deep(.dot-2) { background: #ff9d13; }
.custom-paper-page :deep(.dot-3) { background: #a956bd; }
.custom-paper-page :deep(.knowledge-card h2) { margin-bottom: 22px; }
.custom-paper-page :deep(.knowledge-head),
.custom-paper-page :deep(.knowledge-card p) { display: grid; grid-template-columns: 1fr 45px 45px; gap: 8px; font-size: 12px; }
.custom-paper-page :deep(.knowledge-head) { color: var(--muted); }
.custom-paper-page :deep(.knowledge-card p) { margin: 14px 0; }
.custom-paper-page :deep(.knowledge-card.long p) { margin: 13px 0; }
.dialog-mask { position: fixed; z-index: 3000; inset: 0; display: grid; place-items: center; padding: 24px; background: rgba(4, 17, 61, .38); backdrop-filter: blur(2px); }
.range-dialog { width: min(860px, 92vw); max-height: 88vh; overflow: hidden; background: #fff; border-radius: 10px; box-shadow: 0 24px 70px rgba(15, 32, 78, .22); }
.range-dialog > header { display: flex; align-items: flex-start; justify-content: space-between; padding: 22px 26px 18px; border-bottom: 1px solid var(--line); }
.range-dialog h2 { margin: 0; color: var(--ink); font-size: 19px; }.range-dialog header p { margin: 7px 0 0; color: var(--muted); font-size: 13px; }
.dialog-close { width: 32px; height: 32px; color: var(--muted); font-size: 24px; border: 0; background: transparent; }
.subject-picker { display: flex; align-items: center; gap: 24px; padding: 18px 26px; border-bottom: 1px solid var(--line); }
.subject-picker strong { margin-right: 8px; color: var(--ink); font-size: 13px; }
.subject-picker label { display: flex; align-items: center; gap: 7px; color: var(--text); font-size: 13px; cursor: pointer; }
.subject-config-list { max-height: 520px; padding: 18px 26px; overflow-y: auto; background: #fafbfe; }
.subject-config-card { margin-bottom: 16px; padding: 18px; background: #fff; border: 1px solid var(--line); border-radius: 7px; }
.subject-config-card:last-child { margin-bottom: 0; }
.subject-config-card h3 { margin: 0 0 15px; padding-bottom: 12px; color: var(--ink); font-size: 15px; border-bottom: 1px solid #eef1f7; }
.dialog-form { display: grid; grid-template-columns: 1fr 1fr; gap: 16px 22px; }
.subject-config-card .dialog-form label:last-child { grid-column: 1 / 2; }
.dialog-form label { display: flex; flex-direction: column; gap: 8px; color: var(--ink); font-size: 13px; font-weight: 700; }
.dialog-form select { height: 38px; padding: 0 11px; color: var(--text); font: inherit; font-weight: 400; border: 1px solid var(--line); border-radius: 5px; background: #fff; outline: 0; }.dialog-form select:focus { border-color: var(--primary); }
.range-dialog > footer { display: flex; justify-content: flex-end; gap: 12px; padding: 16px 26px; border-top: 1px solid var(--line); }
.range-dialog > footer > span { align-self: center; margin-right: auto; color: var(--muted); font-size: 13px; }
.range-dialog > footer button { height: 36px; padding: 0 22px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 5px; background: #fff; }.range-dialog > footer .primary { color: #fff; border-color: var(--primary); background: var(--primary); }
.range-dialog > footer .primary:disabled { cursor: not-allowed; border-color: #b6c3eb; background: #b6c3eb; }
.empty-subject-config { display: grid; place-items: center; min-height: 180px; color: var(--muted); font-size: 14px; border: 1px dashed #cbd4e8; border-radius: 7px; background: #fff; }
.range-dialog { width: min(1480px, 96vw); height: min(920px, 94vh); display: flex; flex-direction: column; }
.range-dialog > header { flex: 0 0 60px; align-items: center; padding: 0 32px; }
.range-dialog > header > div { display: flex; align-items: baseline; gap: 18px; }
.range-dialog > header h2 { font-size: 20px; }
.range-dialog > header p { margin: 0; }
.range-subject-tabs { display: flex; flex: 0 0 70px; align-items: center; gap: 16px; padding: 0 32px; border-bottom: 1px solid var(--line); }
.range-subject-tabs > strong { width: 105px; color: var(--ink); font-size: 15px; }
.range-subject-tabs button { display: flex; align-items: center; gap: 12px; min-width: 165px; height: 44px; padding: 0 18px; color: var(--text); font: inherit; font-weight: 700; border: 1px solid var(--line); border-radius: 5px; background: #fff; }
.range-subject-tabs button span { display: grid; place-items: center; width: 28px; height: 28px; color: #66749b; font-size: 11px; background: #f1f4fa; border-radius: 4px; }
.range-subject-tabs button.selected { color: var(--primary); border-color: var(--primary); background: #f7f9ff; }
.range-subject-tabs button.selected span { color: #fff; background: var(--primary); }
.range-subject-tabs button.active { box-shadow: 0 0 0 2px rgba(31,83,255,.08); }
.range-dialog-body { display: grid; grid-template-columns: 330px minmax(0, 1fr); flex: 1; min-height: 0; }
.range-side { overflow-y: auto; border-right: 1px solid var(--line); }
.range-side section { padding: 22px 32px; border-bottom: 1px solid var(--line); }
.range-side h3, .range-main > h3, .range-bottom-cards h3 { margin: 0 0 16px; color: var(--ink); font-size: 15px; }
.range-side label { display: grid; grid-template-columns: 18px 1fr auto; gap: 10px; align-items: start; margin: 14px 0; cursor: pointer; }
.range-side label > span { display: flex; flex-direction: column; gap: 4px; }
.range-side label strong { color: var(--text); font-size: 13px; }
.range-side label small { color: var(--muted); font-size: 11px; line-height: 1.45; }
.range-side label b { padding: 3px 7px; color: var(--primary); font-size: 10px; background: var(--primary-soft); border-radius: 3px; }
.range-side label em { margin-left: 5px; padding: 2px 5px; color: var(--primary); font-size: 9px; background: var(--primary-soft); border-radius: 3px; }
.range-main { min-width: 0; padding: 20px 26px; overflow-y: auto; }
.range-subject-picker { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; padding-bottom: 18px; border-bottom: 1px solid var(--line); }
.range-subject-picker > strong { margin-right: 8px; color: var(--ink); font-size: 14px; white-space: nowrap; }
.range-subject-picker button { position: relative; display: flex; align-items: center; gap: 9px; min-width: 145px; height: 40px; padding: 0 34px 0 12px; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 5px; background: #fff; }
.range-subject-picker button > span { display: grid; place-items: center; width: 25px; height: 25px; color: #69779d; font-size: 10px; background: #f1f4fa; border-radius: 4px; }
.range-subject-picker button > b { font-size: 12px; }.range-subject-picker button > i { position: absolute; right: 10px; color: var(--muted); font-style: normal; }
.range-subject-picker button.selected { color: var(--primary); border-color: #a9baff; background: #f7f9ff; }.range-subject-picker button.selected > span { color: #fff; background: var(--primary); }.range-subject-picker button.selected > i { color: var(--primary); }
.range-subject-picker button.active { border-color: var(--primary); box-shadow: 0 0 0 2px rgba(31,83,255,.08); }
.strategy-cards { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
.strategy-cards button { display: flex; flex-direction: column; gap: 6px; min-height: 64px; padding: 13px 16px; text-align: left; color: var(--text); font: inherit; border: 1px solid var(--line); border-radius: 5px; background: #fff; }
.strategy-cards button strong { color: var(--ink); font-size: 13px; }.strategy-cards button small { color: var(--muted); font-size: 11px; }
.strategy-cards button.active { border-color: var(--primary); background: #f7f9ff; }.strategy-cards button.active strong { color: var(--primary); }
.strategy-tip { margin: 10px 0; padding: 7px 10px; color: var(--primary); font-size: 11px; background: var(--primary-soft); border-radius: 4px; }
.chapter-allocation { overflow: hidden; border: 1px solid var(--line); border-radius: 6px; }
.allocation-head, .allocation-row { display: grid; grid-template-columns: minmax(200px,1.6fr) 150px 105px 130px 170px 85px; align-items: center; gap: 10px; min-height: 42px; padding: 0 16px; font-size: 12px; }
.allocation-head { color: var(--muted); background: #f7f8fb; }.allocation-row { border-top: 1px solid var(--line); }
.allocation-row > strong { color: var(--text); font-size: 12px; }.importance { color: #ff9c00; letter-spacing: 2px; }.importance i { color: #dfe4ef; font-style: normal; }
.draft-row { min-height: 50px; background: #fbfcff; }
.draft-selector { min-width: 0; }
.draft-selector :deep(.el-select), .draft-selector :deep(.el-date-editor) { width: 100%; }
.draft-selector :deep(.el-select__wrapper), .draft-selector :deep(.el-input__wrapper) { min-height: 32px; box-shadow: 0 0 0 1px var(--line) inset; }
.draft-actions { display: flex; gap: 5px; }
.draft-actions button { height: 28px; padding: 0 7px; color: var(--primary); font-size: 10px; border: 1px solid #afc0fa; border-radius: 4px; background: #fff; }
.draft-actions button:last-child { color: var(--muted); border-color: var(--line); }
.draft-actions button:disabled { cursor: not-allowed; color: #aeb7ca; border-color: var(--line); background: #f5f6f9; }
.allocation-counter { display: flex; align-items: center; justify-content: space-between; height: 30px; border: 1px solid var(--line); border-radius: 4px; }
.allocation-counter button { width: 30px; height: 100%; color: var(--text); border: 0; background: transparent; }.allocation-counter b { color: var(--ink); }
.allocation-rate { display: flex; align-items: center; gap: 12px; }.allocation-rate > span { width: 30px; }.allocation-rate i { display: block; width: 90px; height: 6px; overflow: hidden; background: #edf0f6; border-radius: 3px; }.allocation-rate i b { display: block; max-width: 90px; height: 100%; background: var(--primary); border-radius: 3px; }
.suggest-button { color: var(--primary); font-size: 11px; border: 0; background: transparent; }
.chapter-allocation > footer { display: flex; align-items: center; gap: 80px; min-height: 44px; padding: 0 16px; border-top: 1px solid var(--line); font-size: 12px; }.chapter-allocation > footer button { color: var(--primary); border: 0; background: transparent; }.chapter-allocation > footer span:first-of-type { margin-left: auto; }
.range-bottom-cards { display: grid; grid-template-columns: .75fr 1.35fr; gap: 18px; margin-top: 18px; }
.range-bottom-cards > section { min-height: 170px; padding: 18px; border: 1px solid var(--line); border-radius: 6px; }
.range-difficulty-row { display: grid; grid-template-columns: 42px 1fr 38px 84px; gap: 10px; align-items: center; margin: 13px 0; font-size: 12px; }
.range-difficulty-row > i { height: 7px; overflow: hidden; background: #edf0f6; border-radius: 4px; }.range-difficulty-row > i b { display: block; height: 100%; border-radius: 4px; }
.range-difficulty-row > div { display: flex; align-items: center; justify-content: space-between; height: 30px; border: 1px solid var(--line); border-radius: 4px; }.range-difficulty-row button { width: 26px; border: 0; background: transparent; }
.result-preview { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 12px; }.result-preview > h3 { grid-column: 1 / -1; margin-bottom: 2px; }
.result-block { min-width: 0; min-height: 116px; padding: 14px; border: 1px solid #e5eaf5; border-radius: 7px; background: #fafbfe; }
.metric-block { display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 7px; text-align: center; }
.metric-block > span, .metric-block > small { color: var(--muted); font-size: 10px; }.metric-block > strong { color: var(--ink); font-size: 24px; white-space: nowrap; }.metric-block > strong small { font-size: 10px; }
.difficulty-block > strong { display: block; margin-bottom: 9px; color: var(--ink); font-size: 12px; }
.difficulty-block ul { margin: 0; padding: 0; list-style: none; font-size: 10px; }.difficulty-block li { display: grid; grid-template-columns: 8px 1fr auto auto; gap: 7px; align-items: center; margin: 7px 0; }.difficulty-block li i { width: 8px; height: 8px; border-radius: 50%; }.difficulty-block li span { color: var(--text); }.difficulty-block li b { color: var(--ink); font-weight: 700; }.difficulty-block li em { color: var(--muted); font-style: normal; }
.range-dialog > footer { flex: 0 0 68px; align-items: center; }
.range-dialog > footer .footer-cancel { margin-right: auto; border-color: transparent; }
:global(.allocation-picker-popper) { z-index: 5200 !important; }
:global(.allocation-picker-popper.el-popper) { z-index: 5200 !important; }
:global(.danger-confirm-button) { border-color: #e5484d !important; background: #e5484d !important; }
@media (max-width: 1400px) { .settings-layout, .question-settings-layout, .preview-layout { grid-template-columns: minmax(0, 1fr) 310px; }.range-grid { gap: 10px; }.type-head, .type-row { grid-template-columns: 105px 82px 90px 72px minmax(125px,1fr) 176px; gap: 8px; }.preview-tabs { gap: 20px; }.selection-workspace { grid-template-columns: minmax(260px,.8fr) 38px minmax(380px,1.2fr); }.paper-summary { gap: 35px; } }
</style>
