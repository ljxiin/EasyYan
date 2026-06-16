<template>
  <section class="question-import">
    <div class="panel wizard">
      <div v-for="(step, index) in steps" :key="step.no" class="step" :class="{ done: step.no < currentStep, active: step.no === currentStep }">
        <span>{{ step.no < currentStep ? '✓' : step.no }}</span>
        <div>
          <strong>{{ step.title }}</strong>
          <p>{{ step.desc }}</p>
        </div>
        <i v-if="index < steps.length - 1"></i>
      </div>
    </div>

    <template v-if="currentStep === 1">
      <div class="panel import-shell">
        <main>
          <h2>选择导入方式</h2>
          <div class="method-card">
            <el-icon><Upload /></el-icon>
            <div>
              <strong>上传文件</strong>
              <p>支持 Word、Excel、TXT、PDF 格式</p>
              <p>单个文件不超过 50MB</p>
            </div>
            <el-icon class="checked"><CircleCheckFilled /></el-icon>
            <span>支持格式：.docx、.doc、.xlsx、.xls、.txt、.pdf</span>
          </div>

          <h2>上传文件</h2>
          <div class="upload-box">
            <el-icon><Document /></el-icon>
            <strong>点击选择文件或拖拽文件到此处上传</strong>
            <p>支持 .docx、.doc、.xlsx、.xls、.txt、.pdf 格式，单个文件不超过 50MB</p>
            <el-button type="primary">选择文件</el-button>
          </div>
        </main>

        <aside class="requirements">
          <h2>导入要求</h2>
          <div v-for="item in requirements" :key="item.title" class="requirement">
            <el-icon><component :is="item.icon" /></el-icon>
            <div>
              <strong>{{ item.title }}</strong>
              <p>{{ item.text }}</p>
            </div>
          </div>
        </aside>
      </div>
      <div class="footer-actions">
        <el-button disabled>取消</el-button>
        <el-button type="primary" @click="go('/questions/import/parse')">下一步</el-button>
      </div>
    </template>

    <template v-else-if="currentStep === 2">
      <div class="parse-grid">
        <main class="panel parse-main">
          <h2>预览与解析</h2>
          <p>系统已自动解析题目内容，您可以校对解析和答案，确认无误后进入下一步。</p>
          <div class="parse-toolbar">
            <el-checkbox model-value>全选（已选 256 题）</el-checkbox>
            <span class="pill success-dot">解析成功 248</span>
            <span class="pill muted-dot">待检查 8</span>
            <span class="pill warning-dot">解析失败 0</span>
            <el-input placeholder="搜索题目或题目内容" :prefix-icon="Search" />
            <el-button :icon="Filter">筛选</el-button>
          </div>

          <article v-for="item in parseQuestions" :key="item.no" class="parse-item">
            <div class="parse-side">
              <el-checkbox model-value />
              <span>{{ item.no }}</span>
              <el-icon><CircleCheckFilled /></el-icon>
            </div>
            <div class="parse-content">
              <div class="parse-head">
                <span class="tag-soft">{{ item.tag }}</span>
                <strong>{{ item.stem }}</strong>
                <el-button :icon="View">预览</el-button>
                <el-button :icon="EditPen" type="primary" plain>编辑</el-button>
                <el-button :icon="ArrowUp" />
              </div>
              <div v-if="item.options" class="parse-options">
                <span v-for="option in item.options" :key="option">{{ option }}</span>
              </div>
              <div class="answer-box">
                <p><strong>正确答案：</strong>{{ item.answer }}</p>
                <p><strong>解析：</strong>{{ item.analysis }}</p>
              </div>
              <div class="tag-row">
                <strong>考点标签：</strong>
                <el-tag v-for="tag in item.tags" :key="tag" closable>{{ tag }}</el-tag>
                <el-button size="small">+ 新增标签</el-button>
                <el-icon class="trash"><Delete /></el-icon>
              </div>
            </div>
          </article>
          <div class="parse-pagination">
            <span>共 256 题</span>
            <el-pagination layout="prev, pager, next" :total="256" :page-size="10" />
            <el-select model-value="10 条/页">
              <el-option label="10 条/页" value="10 条/页" />
            </el-select>
          </div>
        </main>

        <aside class="panel parse-aside">
          <h2>解析结果概览</h2>
          <div class="big-donut">
            <EChart :option="parseDonut" />
            <div><strong>256</strong><span>总题数</span></div>
          </div>
          <div class="parse-legend">
            <span><i class="green"></i>解析成功 248（96.9%）</span>
            <span><i class="orange"></i>待检查 8（3.1%）</span>
            <span><i class="red"></i>解析失败 0（0%）</span>
          </div>
          <h2>解析结构</h2>
          <ul class="check-list">
            <li>题型识别 <strong>256/256</strong></li>
            <li>题目内容识别 <strong>248/248</strong></li>
            <li>答案识别（单选/多选） <strong>118/118</strong></li>
            <li>答案识别（填空/简答） <strong>118/118</strong></li>
            <li>解析识别 <strong>86/86</strong></li>
          </ul>
          <h2>待检查项（8题） <a>查看详情</a></h2>
          <ul class="todo-list">
            <li>题型识别不确定：2 题</li>
            <li>答案识别不完整：3 题</li>
            <li>解析内容貌似不完整：3 题</li>
          </ul>
        </aside>
      </div>
      <div class="footer-actions">
        <el-button @click="go('/questions/import')">上一步</el-button>
        <el-button type="primary" @click="go('/questions/import/confirm')">下一步：分类与设置</el-button>
      </div>
    </template>

    <template v-else>
      <div class="confirm-grid">
        <main class="panel confirm-main">
          <h2>确认导入</h2>
          <p>请确认以下导入信息，确认无误后将导入题库</p>
          <section class="overview panel">
            <h3>导入内容概览</h3>
            <div class="overview-stats">
              <div v-for="item in overviewStats" :key="item.label">
                <el-icon :style="{ color: item.color, backgroundColor: `${item.color}18` }"><component :is="item.icon" /></el-icon>
                <strong>{{ item.value }}</strong>
                <span>{{ item.label }}</span>
              </div>
            </div>
          </section>

          <section class="setting-list">
            <h3>分类与属性</h3>
            <div v-for="item in settingRows" :key="item.label" class="setting-row">
              <span>{{ item.label }}</span>
              <strong>{{ item.value }}</strong>
              <a>查看详情 〉</a>
            </div>
          </section>

          <div class="tip-box">
            <strong>温馨提示</strong>
            <p>共 256 题，其中 248 题解析成功，8 题待检查，0 题解析失败。</p>
            <p>待检查的题目导入后将加入“待处理”列表，您可以在“错题集 - 待处理”中进行检查和完善。</p>
            <p>导入完成后，您可以在题库中进行查看和管理。</p>
          </div>
        </main>

        <aside class="confirm-aside">
          <section class="panel side-card">
            <h2>导入题型分布</h2>
            <div class="type-chart">
              <EChart :option="typePieOption" />
            </div>
            <div class="type-legend">
              <span><i class="blue"></i>单选题 118 题（46.1%）</span>
              <span><i class="green"></i>填空题 68 题（26.6%）</span>
              <span><i class="orange"></i>判断题 36 题（14.1%）</span>
              <span><i class="violet"></i>计算题 24 题（9.4%）</span>
              <span><i class="gray"></i>其他 10 题（3.8%）</span>
            </div>
          </section>
          <section class="panel side-card">
            <h2>考点分布（Top 5）</h2>
            <div v-for="item in pointRows" :key="item.name" class="point-row">
              <span>{{ item.name }}</span>
              <el-progress :percentage="item.percent" :show-text="false" />
              <em>{{ item.count }} 题（{{ item.percent }}%）</em>
            </div>
          </section>
          <section class="panel side-card">
            <h2>题目预览（前 3 题）</h2>
            <div v-for="item in previewRows" :key="item.no" class="preview-row">
              <span>{{ item.no }}</span>
              <p>{{ item.text }}</p>
              <el-tag>{{ item.type }}</el-tag>
            </div>
            <a class="all-link">查看全部 256 题 〉</a>
          </section>
        </aside>
      </div>
      <div class="footer-actions">
        <el-button @click="go('/questions/import/parse')">上一步：分类与设置</el-button>
        <div></div>
        <el-button>取消导入</el-button>
        <el-button type="primary" @click="go('/questions')">确认导入</el-button>
      </div>
    </template>
  </section>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import type { EChartsOption } from 'echarts'
import {
  ArrowUp,
  CircleCheckFilled,
  Delete,
  Document,
  EditPen,
  Files,
  Filter,
  List,
  Search,
  Upload,
  View,
  Warning
} from '@element-plus/icons-vue'
import EChart from '@/components/EChart.vue'
import { parseQuestions, typePieOption } from '@/mock/questions'

const route = useRoute()
const router = useRouter()
const currentStep = computed(() => Number(route.meta.step || 1))
function go(path: string) {
  router.push(path)
}

const steps = [
  { no: 1, title: '选择导入方式', desc: currentStep.value === 1 ? '选择文件或粘贴文本' : '高数习题集.docx' },
  { no: 2, title: '预览与解析', desc: currentStep.value > 2 ? '共识别 256 题' : '检查解析结果和题目' },
  { no: 3, title: '分类与设置', desc: currentStep.value > 3 ? '已设置分类和属性' : '设置题目分类和属性' },
  { no: 4, title: '确认导入', desc: '确认并完成导入' }
]

const requirements = [
  { title: '文件格式', text: '支持 Word、Excel,TXT、PDF 格式文件', icon: Upload },
  { title: '内容要求', text: '题目、选项、答案、解析等信息完整清晰', icon: Document },
  { title: '编码要求', text: '建议使用 UTF-8 编码，避免乱码问题', icon: Files },
  { title: '文件大小', text: '单个文件不超过 50MB', icon: Document },
  { title: '数量限制', text: '单次最多导入 10000 道题目', icon: List },
  { title: '其他说明', text: '复杂公式建议使用公式编辑器生成；图片内容请确保清晰可识别；如导入失败，请检查文件格式和内容', icon: Upload }
]

const parseDonut: EChartsOption = {
  series: [
    {
      type: 'pie',
      radius: ['62%', '82%'],
      label: { show: false },
      data: [
        { value: 248, itemStyle: { color: '#18b979' } },
        { value: 8, itemStyle: { color: '#ff9b21' } },
        { value: 0, itemStyle: { color: '#ff5b63' } }
      ]
    }
  ]
}

const overviewStats = [
  { label: '总题数', value: 256, color: '#1f53ff', icon: Document },
  { label: '解析成功', value: 248, color: '#18b979', icon: CircleCheckFilled },
  { label: '待检查', value: 8, color: '#ff9b21', icon: Warning },
  { label: '解析失败', value: 0, color: '#ff5b63', icon: Warning }
]

const settingRows = [
  { label: '所属题库', value: '考研数学（数学一）' },
  { label: '章节', value: '第二章　极限与连续' },
  { label: '知识点', value: '2.1　数列极限' },
  { label: '小节', value: '未设置小节' },
  { label: '题目难度', value: '不设置' },
  { label: '题目来源', value: '未设置' },
  { label: '公开范围', value: '私有（仅自己可见）' },
  { label: '标签', value: '未设置' },
  { label: '导入后去重', value: '开启（自动去重，已存在的题目将被自动跳过）' }
]

const pointRows = [
  { name: '1. 导数的定义与计算', count: 128, percent: 50 },
  { name: '2. 基本初等函数的导数', count: 74, percent: 28.9 },
  { name: '3. 复合函数求导法则', count: 46, percent: 18 },
  { name: '4. 可导与连续的关系', count: 32, percent: 12.5 },
  { name: '5. 极限的运算法则', count: 28, percent: 10.9 }
]

const previewRows = [
  { no: 1, text: '设函数 f(x)= 1 / (1 + x²)，则 f′(0)=（ ）。', type: '单选题' },
  { no: 2, text: '函数 f(x)= √(x + 1) 在 x = 3 处的导数为 ________。', type: '填空题' },
  { no: 3, text: '若函数 f(x) 在区间 (a,b) 内可导，则 f(x) 在该区间内...', type: '判断题' }
]
</script>

<style scoped lang="scss">
.question-import {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.wizard {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  padding: 24px 36px;
}

.step {
  position: relative;
  display: flex;
  align-items: center;
  gap: 14px;
}

.step span {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  color: var(--text);
  font-weight: 900;
  border: 1px solid #c9d2ea;
  border-radius: 50%;
}

.step.active span,
.step.done span {
  color: #fff;
  background: var(--primary);
  border-color: var(--primary);
}

.step strong {
  display: block;
  color: var(--ink);
  font-size: 16px;
}

.step p {
  margin: 6px 0 0;
  color: var(--muted);
}

.step i {
  position: absolute;
  right: 28px;
  width: 96px;
  height: 1px;
  background: #cbd5f4;
}

.import-shell {
  display: grid;
  grid-template-columns: 1fr 430px;
  min-height: 724px;
}

.import-shell main,
.requirements,
.parse-main,
.parse-aside,
.confirm-main,
.side-card {
  padding: 28px;
}

h2,
h3 {
  margin: 0;
  color: var(--ink);
}

h2 {
  font-size: 20px;
}

h3 {
  font-size: 16px;
}

.method-card {
  position: relative;
  display: grid;
  grid-template-columns: 64px 1fr;
  width: 420px;
  min-height: 176px;
  margin: 18px 0 34px;
  padding: 34px 22px;
  border: 1px solid var(--primary);
  border-radius: 8px;
}

.method-card > .el-icon {
  width: 58px;
  height: 58px;
  color: var(--primary);
  font-size: 32px;
  background: var(--primary-soft);
  border-radius: 8px;
}

.method-card .checked {
  position: absolute;
  top: 18px;
  right: 18px;
  width: auto;
  height: auto;
  background: transparent;
}

.method-card strong {
  display: block;
  margin-bottom: 10px;
  color: var(--ink);
  font-size: 18px;
}

.method-card p,
.method-card span {
  color: var(--muted);
}

.method-card span {
  grid-column: 1 / -1;
  align-self: end;
  margin-top: 28px;
}

.upload-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 248px;
  color: var(--muted);
  border: 1px dashed #aebcff;
  border-radius: 8px;
}

.upload-box .el-icon {
  color: var(--primary);
  font-size: 52px;
}

.upload-box strong {
  margin-top: 18px;
  color: var(--ink);
  font-size: 16px;
}

.requirements {
  border-left: 1px solid var(--line);
}

.requirement {
  display: flex;
  gap: 16px;
  padding: 24px 0;
  border-bottom: 1px solid var(--line);
}

.requirement .el-icon {
  width: 42px;
  height: 42px;
  color: var(--primary);
  background: var(--primary-soft);
  border-radius: 8px;
}

.requirement strong {
  color: var(--ink);
}

.requirement p {
  color: var(--muted);
  line-height: 1.7;
}

.footer-actions {
  display: grid;
  grid-template-columns: auto 1fr auto auto;
  gap: 16px;
  align-items: center;
  padding: 14px 16px;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: 8px;
}

.parse-grid,
.confirm-grid {
  display: grid;
  grid-template-columns: 1fr 390px;
  gap: 16px;
}

.parse-main > p,
.confirm-main > p {
  color: var(--muted);
}

.parse-toolbar {
  display: grid;
  grid-template-columns: auto auto auto auto 1fr auto;
  gap: 12px;
  align-items: center;
  margin: 16px 0;
}

.pill {
  height: 34px;
  padding: 0 14px;
  line-height: 34px;
  border: 1px solid var(--line);
  border-radius: 7px;
}

.parse-item {
  display: grid;
  grid-template-columns: 132px 1fr;
  border: 1px solid var(--line);
  border-radius: 8px;
  margin-bottom: 10px;
}

.parse-side {
  display: flex;
  gap: 16px;
  align-items: flex-start;
  padding: 18px;
  border-right: 1px solid var(--line);
}

.parse-side span {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 34px;
  height: 34px;
  color: var(--ink);
  font-weight: 800;
  border: 1px solid var(--line);
  border-radius: 7px;
}

.parse-side .el-icon {
  color: var(--green);
}

.parse-content {
  padding: 16px 18px;
}

.parse-head {
  display: flex;
  align-items: center;
  gap: 12px;
}

.parse-head strong {
  flex: 1;
  color: var(--ink);
}

.parse-options {
  display: flex;
  gap: 54px;
  margin: 16px 0;
  color: var(--ink);
  font-weight: 700;
}

.answer-box {
  padding: 12px 16px;
  color: var(--ink);
  background: #f2fbf7;
  border-radius: 7px;
}

.answer-box strong {
  color: var(--green);
}

.tag-row {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-top: 14px;
}

.trash {
  margin-left: auto;
  color: var(--muted);
}

.parse-aside h2,
.side-card h2 {
  margin-bottom: 18px;
  font-size: 18px;
}

.big-donut,
.type-chart {
  position: relative;
  width: 150px;
  height: 150px;
  margin: 0 auto 16px;
}

.big-donut > div:last-child {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}

.big-donut strong {
  color: var(--ink);
  font-size: 28px;
}

.parse-legend,
.type-legend {
  display: flex;
  flex-direction: column;
  gap: 14px;
  color: var(--text);
}

.parse-legend i,
.type-legend i {
  display: inline-block;
  width: 8px;
  height: 8px;
  margin-right: 10px;
  border-radius: 50%;
}

.green {
  background: var(--green);
}

.orange {
  background: var(--orange);
}

.red {
  background: var(--red);
}

.blue {
  background: var(--primary);
}

.violet {
  background: var(--violet);
}

.gray {
  background: #b9c0d2;
}

.check-list,
.todo-list {
  padding: 0;
  list-style: none;
}

.check-list li {
  display: flex;
  justify-content: space-between;
  margin: 22px 0;
  color: var(--text);
}

.todo-list li {
  margin: 14px 0;
  color: var(--text);
}

.parse-pagination {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

.confirm-main {
  min-height: 720px;
}

.overview {
  margin-top: 24px;
  padding: 22px;
}

.overview-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  margin-top: 22px;
}

.overview-stats div {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  border-right: 1px solid var(--line);
}

.overview-stats div:last-child {
  border-right: 0;
}

.overview-stats .el-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
}

.overview-stats strong {
  color: var(--ink);
  font-size: 28px;
}

.overview-stats span {
  color: var(--muted);
}

.setting-list {
  margin-top: 28px;
}

.setting-row {
  display: grid;
  grid-template-columns: 120px 1fr 100px;
  padding: 13px 0;
  border-bottom: 1px solid var(--line);
}

.setting-row span {
  color: var(--muted);
}

.setting-row strong {
  color: var(--text);
}

.setting-row a,
.parse-aside a,
.all-link {
  color: var(--primary);
  font-weight: 700;
}

.tip-box {
  margin-top: 18px;
  padding: 16px;
  color: var(--text);
  background: #f4f8ff;
  border: 1px solid #bcd0ff;
  border-radius: 7px;
}

.confirm-aside {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.point-row {
  display: grid;
  grid-template-columns: 140px 1fr 128px;
  gap: 14px;
  align-items: center;
  margin: 16px 0;
  color: var(--text);
}

.point-row em {
  color: var(--muted);
  font-style: normal;
}

.preview-row {
  display: grid;
  grid-template-columns: 26px 1fr 64px;
  gap: 10px;
  align-items: center;
  color: var(--text);
}

.preview-row span {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  background: #f0f3fb;
  border-radius: 5px;
}
</style>
