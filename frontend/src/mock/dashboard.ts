import type { EChartsOption } from 'echarts'

export const statCards = [
  { label: '刷题总量', value: '12,560', unit: '题', delta: '较昨日 +320', icon: 'DocumentChecked', color: '#1f53ff' },
  { label: '正确数量', value: '9,256', unit: '题', delta: '较昨日 +210', icon: 'Finished', color: '#18b979' },
  { label: '正确率', value: '73.7', unit: '%', delta: '较昨日 +2.1%', icon: 'SuccessFilled', color: '#ff9b21' },
  { label: '错题数量', value: '1,842', unit: '题', delta: '较昨日 +45', icon: 'CircleCloseFilled', color: '#ff5b63' },
  { label: '掌握考点', value: '128', unit: '个', delta: '总考点 256 个', icon: 'TrendCharts', color: '#8e5bff' }
]

export const weakPoints = [
  { name: '多元函数微分学', percent: 32 },
  { name: '特征值与特征向量', percent: 45 },
  { name: '二重积分', percent: 58 },
  { name: '微分方程求解', percent: 63 },
  { name: '曲线积分与曲面积分', percent: 68 }
]

export const recentRecords = [
  { type: '章节练习', content: '高等数学 · 第五章 一元函数积分学', count: '30 题', rate: '76%', time: '今天 10:24', action: '继续练习', color: '#1f53ff' },
  { type: '考点练习', content: '中值定理与导数的应用', count: '20 题', rate: '65%', time: '昨天 16:45', action: '继续练习', color: '#18b979' },
  { type: '试卷练习', content: '2023年考研数学一真题', count: '33 题', rate: '71%', time: '05-11 09:15', action: '查看报告', color: '#ff9b21' },
  { type: '错题重做', content: '错题集（共 128 题）', count: '15 题', rate: '80%', time: '05-10 14:30', action: '继续练习', color: '#ff5b63' }
]

export const taskChartOption: EChartsOption = {
  series: [
    {
      type: 'pie',
      radius: ['78%', '92%'],
      avoidLabelOverlap: false,
      label: { show: false },
      data: [
        { value: 70, itemStyle: { color: '#1f53ff' } },
        { value: 30, itemStyle: { color: '#eef1f7' } }
      ]
    }
  ]
}

export const masteryOption: EChartsOption = {
  series: [
    {
      type: 'pie',
      radius: ['62%', '82%'],
      label: { show: false },
      data: [
        { value: 88, name: '掌握牢固', itemStyle: { color: '#18b979' } },
        { value: 102, name: '掌握一般', itemStyle: { color: '#ffb536' } },
        { value: 46, name: '掌握薄弱', itemStyle: { color: '#ff5b63' } },
        { value: 20, name: '未开始', itemStyle: { color: '#c7cdda' } }
      ]
    }
  ]
}
