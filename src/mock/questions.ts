import type { EChartsOption } from 'echarts'

export const questionStats = [
  { label: '题目总数', value: '12,568', unit: '题', sub: '较昨日  +128' },
  { label: '知识点覆盖', value: '98', unit: '%', sub: '较昨日  +0.5%' },
  { label: '已做题数', value: '3,246', unit: '题', sub: '正确率  68%' },
  { label: '收藏题数', value: '256', unit: '题', sub: '' },
  { label: '错题数', value: '128', unit: '题', sub: '待复习  96 题' }
]

export const chapters = [
  {
    title: '第 1 章  函数与极限',
    open: true,
    children: [
      { name: '1.1  函数', count: 256, active: true },
      { name: '1.2  极限的概念', count: 186 },
      { name: '1.3  极限的运算法则', count: 324 },
      { name: '1.4  无穷小与无穷大', count: 210 },
      { name: '1.5  极限存在准则 两个重要极限', count: 198 },
      { name: '1.6  函数的连续性', count: 276 }
    ]
  },
  { title: '第 2 章  函数与微分', count: 535 },
  { title: '第 3 章  微分中值定理与导数...', count: 423 },
  { title: '第 4 章  不定积分', count: 698 },
  { title: '第 5 章  定积分', count: 732 },
  { title: '第 6 章  定积分的应用', count: 634 }
]

export const questionRows = [
  {
    no: 1,
    tag: '单选题',
    stem: '设函数 f(x)= 1 / (1 + x²)，则 f′(0)=（ ）。',
    options: ['A. 0', 'B. 1', 'C. -1', 'D. 2'],
    type: '选择题',
    difficulty: '易',
    difficultyType: 'success',
    rate: '82%',
    favored: false
  },
  {
    no: 2,
    tag: '填空题',
    stem: '函数 f(x)= √(x + 1) 在 x = 3 处的导数为 ________。',
    type: '填空题',
    difficulty: '中',
    difficultyType: 'warning',
    rate: '63%',
    favored: true
  },
  {
    no: 3,
    tag: '判断题',
    stem: '若函数 f(x) 在区间 (a, b) 内可导，则 f(x) 在该区间内一定连续。（ ）',
    type: '判断题',
    difficulty: '易',
    difficultyType: 'success',
    rate: '91%',
    favored: false
  },
  {
    no: 4,
    tag: '计算题',
    stem: '求函数 f(x)= x³ - 3x² + 2x - 1 的导数。',
    type: '计算题',
    difficulty: '中',
    difficultyType: 'warning',
    rate: '58%',
    favored: false
  },
  {
    no: 5,
    tag: '单选题',
    stem: '设 y = lnx，则 y′ =（ ）。',
    options: ['A. 1/x', 'B. x', 'C. 1/x²', 'D. eˣ'],
    type: '选择题',
    difficulty: '易',
    difficultyType: 'success',
    rate: '88%',
    favored: true
  }
]

export const parseQuestions = [
  {
    no: 1,
    tag: '单选题',
    status: '解析成功',
    statusType: 'success',
    stem: '设函数 f(x)= 1 / (1 + x²)，则 f′(0)=（ ）。',
    options: ['A. 0', 'B. 1', 'C. -1', 'D. 2'],
    answer: 'A',
    analysis: 'f′(x)= -2x / (1 + x²)²，则 f′(0)=0。',
    tags: ['导数与微分', '基础求导公式']
  },
  {
    no: 2,
    tag: '填空题',
    status: '解析成功',
    statusType: 'success',
    stem: '函数 f(x)= √(x + 1) 在 x = 3 处的导数为 ________。',
    answer: '1/4',
    analysis: 'f′(x)= 1 / (2√(x + 1))，当 x=3 时，f′(3)=1/4。',
    tags: ['导数的几何意义', '基本初等函数求导']
  },
  {
    no: 3,
    tag: '判断题',
    status: '解析成功',
    statusType: 'success',
    stem: '若函数 f(x) 在区间 (a, b) 内可导，则 f(x) 在该区间内一定连续。（ ）',
    answer: '√',
    analysis: '可导必连续，故该说法正确。',
    tags: ['导数的定义', '可导与连续的关系']
  },
  {
    no: 4,
    tag: '计算题',
    status: '解析成功',
    statusType: 'success',
    stem: '求函数 f(x)= x³ - 3x² + 2x - 1 的导数。',
    answer: 'f′(x)=3x²-6x+2',
    analysis: '对 f(x) 求导，f′(x)=3x²-6x+2。',
    tags: ['多项式求导', '幂函数求导法则']
  }
]

export const typePieOption: EChartsOption = {
  tooltip: { trigger: 'item' },
  series: [
    {
      type: 'pie',
      radius: ['52%', '78%'],
      label: { show: false },
      data: [
        { name: '单选题', value: 118, itemStyle: { color: '#1f53ff' } },
        { name: '填空题', value: 68, itemStyle: { color: '#18b979' } },
        { name: '判断题', value: 36, itemStyle: { color: '#ff9b21' } },
        { name: '计算题', value: 24, itemStyle: { color: '#8e5bff' } },
        { name: '其他', value: 10, itemStyle: { color: '#b9c0d2' } }
      ]
    }
  ]
}
