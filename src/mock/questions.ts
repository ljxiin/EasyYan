import type { EChartsOption } from 'echarts'

export const questionStats = [
  { label: '题目总数', value: '12,568', unit: '题', sub: '较昨日  +128' },
  { label: '知识点覆盖', value: '98', unit: '%', sub: '较昨日  +0.5%' },
  { label: '已做题数', value: '3,246', unit: '题', sub: '正确率  68%' },
  { label: '收藏题数', value: '256', unit: '题', sub: '较昨日  +11' },
  { label: '错题数', value: '128', unit: '题', sub: '待复习  96 题' }
]

export const chapters = [
  {
    id: 'chapter-1',
    title: '第 1 章  函数与极限',
    count: 1490,
    open: true,
    children: [
      { id: '1.1', name: '1.1  函数', count: 256, active: true },
      { id: '1.2', name: '1.2  极限的概念', count: 186 },
      { id: '1.3', name: '1.3  极限的运算法则', count: 324 },
      { id: '1.4', name: '1.4  无穷小与无穷大', count: 210 },
      { id: '1.5', name: '1.5  极限存在准则 两个重要极限', count: 198 },
      { id: '1.6', name: '1.6  函数的连续性', count: 276 }
    ]
  },
  { id: 'chapter-2', title: '第 2 章  函数与微分', count: 535 },
  { id: 'chapter-3', title: '第 3 章  微分中值定理与导数...', count: 423 },
  { id: 'chapter-4', title: '第 4 章  不定积分', count: 698 },
  { id: 'chapter-5', title: '第 5 章  定积分', count: 732 },
  { id: 'chapter-6', title: '第 6 章  定积分的应用', count: 634 }
]

export const questionRows = [
  {
    no: 1,
    chapterId: '1.1',
    tag: '单选题',
    stem: '设函数 f(x)= 1 / (1 + x²)，则 f′(0)=（ ）。',
    latexStem: '设函数 $f(x)=\\frac{1}{1+x^2}$，则 $f^{\\prime}(0)=\\left(\\quad\\right)$。',
    options: ['A. $0$', 'B. $1$', 'C. $-1$', 'D. $2$'],
    type: '单选题',
    difficulty: '易',
    difficultyType: 'success',
    rate: '82%',
    favored: false,
    pointTags: ['函数', '导数与微分', '基础求导公式']
  },
  {
    no: 2,
    chapterId: '1.1',
    tag: '填空题',
    stem: '函数 f(x)= √(x + 1) 在 x = 3 处的导数为 ________。',
    latexStem: '函数 $f(x)=\\sqrt{x+1}$ 在 $x=3$ 处的导数为 ________。',
    type: '填空题',
    difficulty: '中',
    difficultyType: 'warning',
    rate: '63%',
    favored: true,
    pointTags: ['导数的几何意义', '基本初等函数求导']
  },
  {
    no: 3,
    chapterId: '1.1',
    tag: '证明题',
    stem: '若函数 f(x) 在区间 (a, b) 内可导，则 f(x) 在该区间内一定连续。（ ）',
    latexStem: '证明：若函数 $f(x)$ 在区间 $(a,b)$ 内可导，则 $f(x)$ 在该区间内连续。',
    type: '证明题',
    difficulty: '易',
    difficultyType: 'success',
    rate: '91%',
    favored: false,
    pointTags: ['可导与连续', '导数的定义']
  },
  {
    no: 4,
    chapterId: 'chapter-2',
    tag: '计算题',
    stem: '求函数 f(x)= x³ - 3x² + 2x - 1 的导数。',
    latexStem: '求函数 $f(x)=x^3-3x^2+2x-1$ 的导数。',
    type: '计算题',
    difficulty: '中',
    difficultyType: 'warning',
    rate: '58%',
    favored: false,
    pointTags: ['多项式求导', '幂函数求导法则']
  },
  {
    no: 5,
    chapterId: 'chapter-2',
    tag: '单选题',
    stem: '设 y = lnx，则 y′ =（ ）。',
    latexStem: '设 $y=\\ln x$，则 $y^{\\prime}=\\left(\\quad\\right)$。',
    options: ['A. $\\frac{1}{x}$', 'B. $x$', 'C. $\\frac{1}{x^2}$', 'D. $e^x$'],
    type: '单选题',
    difficulty: '易',
    difficultyType: 'success',
    rate: '88%',
    favored: true,
    pointTags: ['对数函数', '基本初等函数求导']
  },
  {
    no: 6,
    chapterId: 'chapter-3',
    tag: '计算题',
    stem: '证明罗尔定理在闭区间上的适用条件，并说明端点连续性的必要性。',
    latexStem: '证明罗尔定理在闭区间 $[a,b]$ 上的适用条件，并说明端点连续性的必要性。',
    type: '证明题',
    difficulty: '中',
    difficultyType: 'warning',
    rate: '71%',
    favored: false,
    pointTags: ['罗尔定理', '中值定理']
  },
  {
    no: 7,
    chapterId: 'chapter-4',
    tag: '填空题',
    stem: '不定积分 ∫2x dx = ________。',
    latexStem: '不定积分 $\\int 2x\\,dx=$ ________。',
    type: '填空题',
    difficulty: '易',
    difficultyType: 'success',
    rate: '92%',
    favored: false,
    pointTags: ['不定积分', '基本积分公式']
  },
  {
    no: 8,
    chapterId: 'chapter-5',
    tag: '单选题',
    stem: '定积分的几何意义通常表示为曲线与坐标轴围成区域的（ ）。',
    latexStem: '定积分 $\\int_a^b f(x)\\,dx$ 的几何意义通常表示为曲线与坐标轴围成区域的（ ）。',
    options: ['A. 面积', 'B. 周长', 'C. 斜率', 'D. 曲率'],
    type: '单选题',
    difficulty: '易',
    difficultyType: 'success',
    rate: '86%',
    favored: true,
    pointTags: ['定积分', '几何意义']
  },
  {
    no: 9,
    chapterId: 'chapter-6',
    tag: '应用题',
    stem: '利用定积分计算旋转体体积，并写出对应积分表达式。',
    latexStem: '利用定积分计算旋转体体积，并写出对应积分表达式 $V=\\pi\\int_a^b [f(x)]^2\\,dx$。',
    type: '应用题',
    difficulty: '难',
    difficultyType: 'danger',
    rate: '54%',
    favored: false,
    pointTags: ['定积分应用', '旋转体体积']
  }
]

export const parseQuestions = [
  {
    no: 1,
    tag: '单选题',
    status: '解析成功',
    statusType: 'success',
    stem: '设函数 f(x)= 1 / (1 + x²)，则 f′(0)=（ ）。',
    latexStem: '设函数 $f(x)=\\frac{1}{1+x^2}$，则 $f^{\\prime}(0)=\\left(\\quad\\right)$。',
    options: ['A. $0$', 'B. $1$', 'C. $-1$', 'D. $2$'],
    answer: 'A',
    analysis: 'f′(x)= -2x / (1 + x²)²，则 f′(0)=0。',
    latexAnalysis: '$f^{\\prime}(x)=\\frac{-2x}{(1+x^2)^2}$，则 $f^{\\prime}(0)=0$。',
    tags: ['导数与微分', '基础求导公式']
  },
  {
    no: 2,
    tag: '填空题',
    status: '解析成功',
    statusType: 'success',
    stem: '函数 f(x)= √(x + 1) 在 x = 3 处的导数为 ________。',
    latexStem: '函数 $f(x)=\\sqrt{x+1}$ 在 $x=3$ 处的导数为 ________。',
    answer: '$\\frac{1}{4}$',
    analysis: 'f′(x)= 1 / (2√(x + 1))，当 x=3 时，f′(3)=1/4。',
    latexAnalysis: '$f^{\\prime}(x)=\\frac{1}{2\\sqrt{x+1}}$，当 $x=3$ 时，$f^{\\prime}(3)=\\frac{1}{4}$。',
    tags: ['导数的几何意义', '基本初等函数求导']
  },
  {
    no: 3,
    tag: '判断题',
    status: '待检查',
    statusType: 'warning',
    stem: '若函数 f(x) 在区间 (a, b) 内可导，则 f(x) 在该区间内一定连续。（ ）',
    latexStem: '若函数 $f(x)$ 在区间 $(a,b)$ 内可导，则 $f(x)$ 在该区间内一定连续。（ ）',
    answer: '√',
    analysis: '可导必连续，故该说法正确。',
    latexAnalysis: '由可导与连续的关系可知：$f(x)$ 可导 $\\Rightarrow f(x)$ 连续。',
    tags: ['导数的定义', '可导与连续的关系']
  },
  {
    no: 4,
    tag: '计算题',
    status: '解析成功',
    statusType: 'success',
    stem: '求函数 f(x)= x³ - 3x² + 2x - 1 的导数。',
    latexStem: '求函数 $f(x)=x^3-3x^2+2x-1$ 的导数。',
    answer: '$f^{\\prime}(x)=3x^2-6x+2$',
    analysis: '对 f(x) 求导，f′(x)=3x²-6x+2。',
    latexAnalysis: '对 $f(x)$ 逐项求导，得到 $f^{\\prime}(x)=3x^2-6x+2$。',
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
