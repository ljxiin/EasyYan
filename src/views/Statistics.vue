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
          <template #actions><PeriodSwitch /></template>
          <EChart :option="accuracyTrend" />
        </ChartPanel>
        <ChartPanel class="mastery-card" title="题目掌握情况">
          <div class="donut-layout">
            <div class="donut"><EChart :option="masteryDonut" /><DonutCenter value="856" label="总题数" /></div>
            <LegendList :items="masteryLegend" />
          </div>
        </ChartPanel>
        <DataPanel title="题型正确率" link="查看详情">
          <div class="mini-table type-mini">
            <div class="table-head"><span>题型</span><span>刷题数</span><span>正确率</span></div>
            <div v-for="row in typeRows" :key="row.name" class="table-row">
              <strong>{{ row.name }}</strong><span>{{ row.count }}</span>
              <span>{{ row.rate }}% <i class="bar"><i :style="{ width: `${row.rate}%` }"></i></i></span>
            </div>
          </div>
        </DataPanel>
        <DataPanel title="知识点正确率 TOP10" link="查看详情">
          <div class="ranking-list">
            <div v-for="(row, index) in knowledgeRows.slice(0, 10)" :key="row.name">
              <span>{{ index + 1 }}</span><strong>{{ row.name }}</strong>
              <i class="bar"><i :style="{ width: `${row.rate}%` }"></i></i><em>{{ row.rate }}%</em>
            </div>
          </div>
        </DataPanel>
        <ChartPanel title="每日刷题时长（小时）">
          <template #actions><PeriodSwitch short /></template>
          <EChart :option="durationBars" />
        </ChartPanel>
      </div>
    </template>

    <template v-else-if="activeTab === 'ability'">
      <div class="panel ability-summary">
        <div class="donut ability-donut">
          <EChart :option="abilityDonut" />
          <DonutCenter value="72.6" label="综合得分 /100" />
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
          <div class="donut-layout fill"><div class="donut"><EChart :option="typeDonut" /><DonutCenter value="856" label="总题数" /></div><LegendList :items="typeLegend" /></div>
        </ChartPanel>
      </div>
    </template>

    <template v-else-if="activeTab === 'knowledge'">
      <MetricCards :items="knowledgeMetrics" />
      <div class="knowledge-charts">
        <ChartPanel title="知识点掌握率分布"><template #actions><PeriodSwitch /></template><EChart :option="knowledgeBars" /></ChartPanel>
        <ChartPanel title="知识点掌握情况占比">
          <div class="donut-layout fill"><div class="donut"><EChart :option="knowledgeDonut" /><DonutCenter value="238" label="知识点总数" /></div><LegendList :items="knowledgeLegend" /></div>
        </ChartPanel>
      </div>
      <DataPanel title="知识点掌握详情">
        <template #actions><button class="select-btn">全部章节⌄</button><div class="table-search">搜索知识点　⌕</div></template>
        <StandardTable :columns="knowledgeColumns" :rows="knowledgeTable" />
        <Pagination total="共 238 条" pages="24" />
      </DataPanel>
    </template>

    <template v-else-if="activeTab === 'mistakes'">
      <MetricCards :items="mistakeMetrics" dense />
      <div class="mistake-charts">
        <ChartPanel title="错题数量趋势"><template #actions><PeriodSwitch /></template><EChart :option="mistakeTrend" /></ChartPanel>
        <ChartPanel title="错题来源分布"><div class="donut-layout fill"><div class="donut small"><EChart :option="mistakeSourceDonut" /><DonutCenter value="186" label="错题总数" /></div><LegendList :items="mistakeSourceLegend" /></div></ChartPanel>
        <ChartPanel title="错题掌握情况"><div class="donut-layout fill"><div class="donut small"><EChart :option="mistakeMasteryDonut" /><DonutCenter value="186" label="错题总数" /></div><LegendList :items="mistakeMasteryLegend" /></div></ChartPanel>
      </div>
      <div class="mistake-bottom">
        <DataPanel title="错题知识点 TOP10"><StandardTable :columns="mistakeColumns" :rows="mistakeKnowledge" /></DataPanel>
        <DataPanel title="需要重点关注的错题" link="查看全部错题"><StandardTable :columns="focusColumns" :rows="focusMistakes" /><Pagination total="共 70 条" pages="7" /></DataPanel>
      </div>
    </template>

    <template v-else>
      <MetricCards :items="recordMetrics" />
      <DataPanel class="records-panel">
        <template #title>
          <div class="record-filters"><button class="active">全部记录</button><button>按试卷刷题</button><button>按章节刷题</button></div>
        </template>
        <template #actions><div class="table-search wide">搜索试卷/章节/题目　⌕</div><button class="export-btn">⇩ 导出记录</button></template>
        <StandardTable :columns="recordColumns" :rows="recordTable" />
        <Pagination total="共 48 条记录" pages="5" />
      </DataPanel>
    </template>
  </section>
</template>

<script setup lang="ts">
import { computed, defineComponent, h } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import * as ElementIcons from '@element-plus/icons-vue'
import type { EChartsOption } from 'echarts'
import EChart from '@/components/EChart.vue'

type TabKey = 'overview' | 'ability' | 'type' | 'knowledge' | 'mistakes' | 'records'
type Metric = { label: string; value: string; unit?: string; delta: string; positive?: boolean; icon: string; color: string }
type Column = { key: string; label: string; width?: string; type?: string }

const route = useRoute()
const router = useRouter()
const icons = ElementIcons as Record<string, unknown>
const tabs: { key: TabKey; label: string }[] = [
  { key: 'overview', label: '整体概览' }, { key: 'ability', label: '能力分析' }, { key: 'type', label: '题型分析' },
  { key: 'knowledge', label: '知识点分析' }, { key: 'mistakes', label: '错题分析' }, { key: 'records', label: '刷题记录' }
]
const activeTab = computed<TabKey>(() => tabs.some(t => t.key === route.query.tab) ? route.query.tab as TabKey : 'overview')
function switchTab(tab: TabKey) { router.replace({ query: tab === 'overview' ? {} : { tab } }) }

const palette = ['#2f6bff', '#16ba78', '#ff9b21', '#8d59f6', '#ff6268']
const metric = (label: string, value: string, unit: string, delta: string, icon: string, color: string, positive = true): Metric => ({ label, value, unit, delta, icon, color, positive })
const overviewMetrics = [
  metric('刷题总数', '856', '题', '↑ 12.5%', 'Calendar', palette[0]), metric('正确题数', '617', '题', '↑ 8.3%', 'CircleCheckFilled', palette[1]),
  metric('正确率', '72.0', '%', '↓ 2.1%', 'Aim', palette[2], false), metric('刷题时长', '38.6', '小时', '↑ 5.6%', 'PieChart', palette[3]),
  metric('连续刷题天数', '16', '天', '↑ 3 天', 'Calendar', palette[0])
]
const typeMetrics = [
  metric('题型总数', '5', '种', '——', 'Document', palette[0]), metric('正确题数', '617', '题', '↑ 8.3%', 'CircleCheckFilled', palette[1]),
  metric('正确率', '72.0', '%', '↓ 2.1%', 'Aim', palette[2], false), metric('平均得分率', '72.0', '%', '↓ 2.1%', 'PieChart', palette[3], false),
  metric('平均用时', '1.28', '分钟', '↑ 5.4%', 'Timer', palette[0])
]
const knowledgeMetrics = [
  metric('知识点总数', '238', '个', '↑ 8 个', 'Tickets', palette[0]), metric('已掌握知识点', '86', '个', '↑ 6 个', 'CircleCheckFilled', palette[1]),
  metric('掌握率', '36.1', '%', '↑ 2.8%', 'PieChart', palette[2]), metric('薄弱知识点', '68', '个', '↓ 5 个', 'PieChart', palette[3], false),
  metric('平均用时', '1.42', '分钟', '↑ 0.18 分钟', 'Timer', palette[0])
]
const mistakeMetrics = [
  metric('错题总数', '186', '题', '↓ 28题', 'Histogram', '#ff6268', false), metric('错题率', '29.5', '%', '↓ 6.2%', 'Aim', palette[2], false),
  metric('错题重做率', '62.4', '%', '↑ 8.7%', 'Calendar', palette[3]), metric('已消灭错题', '116', '题', '↑ 21 题', 'Tickets', palette[1]),
  metric('仍未掌握错题', '70', '题', '↓ 7 题', 'CircleCheck', palette[0], false), metric('平均重做时长', '2.15', '分钟', '↑ 0.32 分钟', 'PieChart', '#5b8def')
]
const recordMetrics = [
  metric('刷题次数', '48', '次', '↑ 6 次', 'Document', palette[0]), metric('刷题题数', '856', '题', '↑ 128 题', 'CircleCheckFilled', palette[1]),
  metric('正确率', '72.0', '%', '↑ 3.2%', 'Aim', palette[2]), metric('累计用时', '38.6', '小时', '↑ 4.8 小时', 'PieChart', palette[3]),
  metric('连续刷题天数', '16', '天', '↑ 3 天', 'Calendar', '#20aeb0')
]

const dates = ['05-02','05-05','05-08','05-11','05-14','05-17','05-20','05-23','05-26','05-29','05-31']
const baseGrid = { left: 42, right: 18, top: 32, bottom: 32 }
const axis = { axisLine: { lineStyle: { color: '#e7ecf7' } }, axisTick: { show: false }, axisLabel: { color: '#536187', fontSize: 11 }, splitLine: { lineStyle: { color: '#edf1f8' } } }
const lineSeries = (name: string, data: number[], color: string) => ({ name, type: 'line' as const, smooth: true, symbol: 'circle', symbolSize: 6, data, lineStyle: { width: 2, color }, itemStyle: { color: '#fff', borderColor: color, borderWidth: 2 }, areaStyle: { color: color + '10' } })
const accuracyTrend: EChartsOption = { grid: baseGrid, tooltip: { trigger: 'axis' }, xAxis: { type: 'category', data: ['04-01','04-08','04-15','04-22','04-29','05-06','05-13','05-20','05-27','05-31'], ...axis }, yAxis: { ...axis, type: 'value', min: 0, max: 100, axisLabel: { color: '#536187', fontSize: 11, formatter: '{value}%' } }, series: [lineSeries('正确率', [64,58,56,66,54,57,55,61,66,69], palette[0])] }
const durationBars: EChartsOption = { grid: baseGrid, xAxis: { type: 'category', data: ['05-25','05-26','05-27','05-28','05-29','05-30','05-31'], ...axis }, yAxis: { ...axis, type: 'value', max: 4, axisLabel: { color: '#536187', fontSize: 11, formatter: '{value}h' } }, series: [{ type: 'bar', data: [2.1,1.8,2.6,3.2,2.3,1.9,2.7], barWidth: 30, itemStyle: { color: '#7da1f7', borderRadius: [4,4,0,0] }, label: { show: true, position: 'top', color: '#0d1b50' } }] }
function donut(data: { name: string; value: number; color: string }[]): EChartsOption { return { color: data.map(i => i.color), series: [{ type: 'pie', radius: ['57%','78%'], center: ['50%','50%'], avoidLabelOverlap: false, label: { show: false }, data }] } }
const masteryLegend = [{ color: palette[1], label: '完全掌握', value: '221题（25.8%）' },{ color: palette[0], label: '基本掌握', value: '396题（46.3%）' },{ color: palette[2], label: '未掌握', value: '152题（17.8%）' },{ color: palette[3], label: '不熟悉', value: '87题（10.1%）' }]
const masteryDonut = donut(masteryLegend.map((i, n) => ({ name: i.label, value: [221,396,152,87][n], color: i.color })))
const typeRows = [{name:'选择题',count:312,rate:78.5},{name:'填空题',count:216,rate:71.8},{name:'计算题',count:184,rate:68.5},{name:'证明题',count:94,rate:62.3},{name:'应用题',count:50,rate:70}]
const knowledgeRows = ['极限的四则运算','导数的概念','中值定理','一元函数积分学','不定积分','微分中值定理','函数的连续性','定积分的几何应用','偏导数与全微分','二元函数极值'].map((name, i) => ({ name, rate: [92,88.5,85.6,83.2,81.3,78.6,75.4,72.6,69.2,66.8][i] }))

const abilities = [
  { name:'计算能力',score:78.5,rate:78.2,delta:6.3,color:palette[0],icon:'DataAnalysis' },{ name:'逻辑推理能力',score:74.2,rate:74,delta:4.8,color:'#2fb886',icon:'Warning' },
  { name:'概念理解能力',score:68.7,rate:68.1,delta:-2.1,color:palette[2],icon:'Opportunity' },{ name:'综合应用能力',score:70.8,rate:70.3,delta:1.5,color:palette[3],icon:'Checked' },
  { name:'解题策略能力',score:69.6,rate:69.2,delta:-1.8,color:palette[4],icon:'Aim' }
]
const abilityDonut = donut(abilities.map(a => ({ name:a.name, value:a.score, color:a.color })))
const abilityTrend: EChartsOption = { color: palette, legend: { top: 0, textStyle:{fontSize:10} }, grid:{...baseGrid,top:45}, xAxis:{type:'category',data:dates,...axis}, yAxis:{type:'value',min:0,max:100,...axis}, series: abilities.map((a,i)=>lineSeries(a.name,[78,82,74,72,81,73,76,70,78,74,79],a.color)).map((s,i)=>({...s,data:(s.data as number[]).map(v=>v-i*7)})) }
const radarOption: EChartsOption = { radar:{ indicator:abilities.map(a=>({name:a.name,max:100})), radius:'66%', splitNumber:4, axisName:{color:'#17245c'} }, series:[{type:'radar',data:[{value:abilities.map(a=>a.score),areaStyle:{color:'#5790ff33'},lineStyle:{color:'#5790ff'},itemStyle:{color:'#5790ff'}}]}] }
const abilityColumns: Column[] = [{key:'name',label:'能力维度'},{key:'desc',label:'能力描述',width:'30%'},{key:'score',label:'得分 /100',type:'progress'},{key:'rate',label:'正确率'},{key:'count',label:'刷题量'},{key:'delta',label:'较上期变化',type:'delta'},{key:'level',label:'水平',type:'tag'}]
const abilityTable = abilities.map((a,i)=>({name:a.name,desc:['对数学运算、公式变形、求导积分等计算的掌握程度','分析条件、推导结论、证明等逻辑思维能力','对数学概念、定理、性质的理解和掌握程度','将知识综合运用解决综合性问题的能力','选择合适方法、优化解题步骤的策略能力'][i],score:a.score,rate:a.rate+'%',count:[312,286,245,198,173][i]+' 题',delta:(a.delta>0?'↑ ':'↓ ')+Math.abs(a.delta),level:i<2?'良好':'中等'}))

const typeBars: EChartsOption = { grid:baseGrid,xAxis:{type:'category',data:typeRows.map(i=>i.name),...axis},yAxis:{...axis,type:'value',max:100,axisLabel:{color:'#536187',fontSize:11,formatter:'{value}%'}},series:[{type:'bar',data:typeRows.map(i=>i.rate),barWidth:28,itemStyle:{color:palette[0]},label:{show:true,position:'top',formatter:'{c}%'}}] }
const typeTrend: EChartsOption = { color:palette,legend:{top:0},grid:{...baseGrid,top:48},xAxis:{type:'category',data:dates,...axis},yAxis:{...axis,type:'value',max:100,axisLabel:{color:'#536187',fontSize:11,formatter:'{value}%'}},series:typeRows.map((r,i)=>lineSeries(r.name,[74,78,70,69,78,70,68,72,67,70,76],palette[i])).map((s,i)=>({...s,data:(s.data as number[]).map(v=>v-i*8)})) }
const typeLegend = typeRows.map((r,i)=>({color:palette[i],label:r.name,value:`${r.count}题（${[36.4,25.2,21.5,11,5.9][i]}%）`}))
const typeDonut = donut(typeRows.map((r,i)=>({name:r.name,value:r.count,color:palette[i]})))
const typeColumns: Column[] = [{key:'name',label:'题型'},{key:'count',label:'刷题量'},{key:'correct',label:'正确题数'},{key:'rate',label:'正确率'},{key:'score',label:'平均得分率'},{key:'time',label:'平均用时'},{key:'delta',label:'较上期变化',type:'delta'}]
const typeTable = typeRows.map((r,i)=>({name:r.name,count:r.count,correct:[254,155,126,59,35][i],rate:r.rate+'%',score:r.rate+'%',time:[1.02,1.18,1.56,2.35,1.81][i]+' 分钟',delta:(i<2||i===4?'↑ ':'↓ ')+[6.3,4.8,2.9,4.2,1.6][i]+'%'}))

const knowledgeLegend = [{color:palette[1],label:'完全掌握（80%~100%）',value:'38个（15.9%）'},{color:'#4f83ee',label:'较好掌握（60%~80%）',value:'70个（29.4%）'},{color:palette[2],label:'一般掌握（40%~60%）',value:'62个（26.1%）'},{color:palette[3],label:'较弱掌握（20%~40%）',value:'50个（21.0%）'},{color:'#6473ea',label:'非常薄弱（0~20%）',value:'18个（7.6%）'}]
const knowledgeDonut = donut(knowledgeLegend.map((r,i)=>({name:r.label,value:[38,70,62,50,18][i],color:r.color})))
const knowledgeBars: EChartsOption = { grid:baseGrid,xAxis:{type:'category',data:['0~20%','20%~40%','40%~60%','60%~80%','80%~100%'],...axis},yAxis:{...axis,type:'value',max:50,axisLabel:{color:'#536187',fontSize:11,formatter:'{value}%'}},series:[{type:'bar',barWidth:34,data:[18,50,62,70,38].map((v,i)=>({value:[7.6,21,26.1,29.4,15.9][i],label:{show:true,position:'top',formatter:`${v}个\\n(${[7.6,21,26.1,29.4,15.9][i]}%)`}})),itemStyle:{color:'#80a3f5',borderRadius:[4,4,0,0]}}] }
const knowledgeColumns: Column[] = [{key:'name',label:'知识点',width:'20%'},{key:'chapter',label:'所属章节',width:'20%'},{key:'count',label:'刷题量'},{key:'rate',label:'正确率'},{key:'mastery',label:'掌握率',type:'progress'},{key:'time',label:'平均用时'},{key:'delta',label:'较上期变化',type:'delta'},{key:'trend',label:'掌握趋势',type:'spark'},{key:'action',label:'操作',type:'link'}]
const knowledgeTable = ['极限的四则运算法则','导数的概念','中值定理（罗尔定理）','一元函数求导法则','不定积分的概念','定积分的定义','定积分的几何应用'].map((name,i)=>({name:'›　'+name,chapter:['第一章 函数、极限、连续','第二章 一元函数微分学','第二章 一元函数微分学','第二章 一元函数微分学','第三章 一元函数积分学','第三章 一元函数积分学','第三章 一元函数积分学'][i],count:[48,36,32,68,28,34,22][i],rate:[89.6,83.3,75,92.6,64.3,58.8,45.5][i]+'%',mastery:[90,83,75,93,64,59,46][i],time:[1.12,1.05,1.38,1.08,1.56,1.67,2.05][i]+' 分钟',delta:(i<2||i===3?'↑ ':'↓ ')+[8,5,3,10,6,7,9][i]+'%',trend:'⌁⌃⌁⌃',action:'查看详情'}))

const mistakeTrend: EChartsOption = { grid:baseGrid,xAxis:{type:'category',data:dates,...axis},yAxis:{type:'value',max:40,...axis},series:[lineSeries('错题数',[22,18,20,16,15,20,13,17,23,20,25],'#ff6268')] }
const mistakeSourceLegend = [{color:palette[0],label:'按试卷刷题',value:'102题（54.8%）'},{color:'#ff7743',label:'按章节刷题',value:'64题（34.4%）'},{color:palette[2],label:'错题重做',value:'20题（10.8%）'}]
const mistakeSourceDonut = donut(mistakeSourceLegend.map((r,i)=>({name:r.label,value:[102,64,20][i],color:r.color})))
const mistakeMasteryLegend = [{color:palette[1],label:'已掌握',value:'116题（62.4%）'},{color:palette[4],label:'未掌握',value:'70题（37.6%）'}]
const mistakeMasteryDonut = donut(mistakeMasteryLegend.map((r,i)=>({name:r.label,value:[116,70][i],color:r.color})))
const mistakeColumns: Column[] = [{key:'rank',label:''},{key:'name',label:'知识点',width:'38%'},{key:'count',label:'错题数'},{key:'rate',label:'错题率',type:'progress'},{key:'delta',label:'较上期变化',type:'delta'}]
const mistakeKnowledge = knowledgeRows.map((r,i)=>({rank:i+1,name:r.name,count:[24,18,16,14,12,10,9,8,7,6][i],rate:[50,42.9,34,38.9,41.4,35.7,33.3,28.6,31.8,24][i],delta:(i%3===0?'↑ ':'↓ ')+[6.3,5.1,2.4,3.2,1.6,2.1,1.8,.9,1.2,1][i]+'%'}))
const focusColumns: Column[] = [{key:'question',label:'题目',width:'40%'},{key:'point',label:'所属知识点',type:'tag'},{key:'times',label:'错题次数'},{key:'date',label:'最近错题时间'},{key:'action',label:'操作',type:'link'}]
const focusMistakes = ['设函数 f(x)=sin x/x，求极限…','设 f(x)=x³-3x+1，求 f′(x).','若 f(x) 在 (a,b) 上可导…','计算 ∫ sin²x dx.','设 z=xy+x²y²，求偏导…','求曲线 y=x³ 在点处切线…'].map((q,i)=>({question:q,point:['极限的四则运算法则','一元函数求导法则','中值定理（罗尔定理）','定积分的几何应用','二元函数微分学','导数的几何意义'][i],times:i<3?'3次':'2次',date:['2024-05-29','2024-05-28','2024-05-25','2024-05-27','2024-05-24','2024-05-23'][i],action:'查看解析'}))

const recordColumns: Column[] = [{key:'date',label:'刷题时间',width:'13%'},{key:'mode',label:'刷题方式',type:'mode'},{key:'content',label:'内容',width:'29%'},{key:'count',label:'题数'},{key:'rate',label:'正确率',type:'rate'},{key:'time',label:'用时'},{key:'source',label:'来源'},{key:'action',label:'操作',type:'actions'}]
const recordTable = [
 ['2024-05-31 20:15','按试卷','2024年全国硕士研究生招生考试数学（一）试题',33,'78.8%','1.28 小时','真题试卷'],
 ['2024-05-31 09:30','按章节','一元函数微分学 / 导数的概念',20,'85.0%','32 分钟','章节练习'],
 ['2024-05-30 21:10','按章节','线性代数 / 矩阵 / 矩阵的运算',25,'68.0%','45 分钟','章节练习'],
 ['2024-05-30 14:20','按试卷','数学（一）模拟试卷（五）',35,'71.4%','1.15 小时','模拟试卷'],
 ['2024-05-29 19:45','按章节','不定积分 / 积分的换元法',18,'77.8%','28 分钟','章节练习'],
 ['2024-05-29 10:05','按章节','概率论与数理统计 / 随机事件与概率',22,'63.6%','35 分钟','章节练习'],
 ['2024-05-28 22:30','按试卷','数学（一）模拟试卷（四）',34,'64.7%','1.02 小时','模拟试卷'],
 ['2024-05-28 16:40','按章节','多元函数微分学 / 偏导数与全微分',20,'80.0%','30 分钟','章节练习'],
 ['2024-05-27 20:00','按章节','空间解析几何 / 平面与直线',15,'86.7%','22 分钟','章节练习'],
 ['2024-05-27 09:15','按试卷','2023年全国硕士研究生招生考试数学（一）试题',33,'69.7%','1.20 小时','真题试卷']
].map(r=>({date:r[0],mode:r[1],content:r[2],count:r[3],rate:r[4],time:r[5],source:r[6],action:'查看详情　↻ 再次练习'}))

const ChartPanel = defineComponent({ props:{title:String}, setup(props,{slots}) { return()=>h('article',{class:'panel chart-panel'},[h('div',{class:'panel-head'},[h('h2',props.title),slots.actions?.()]),h('div',{class:'chart-body'},slots.default?.())]) } })
const DataPanel = defineComponent({ props:{title:String,link:String}, setup(props,{slots}) { return()=>h('article',{class:'panel data-panel'},[h('div',{class:'panel-head'},[slots.title?.()||h('h2',props.title),h('div',{class:'head-actions'},[slots.actions?.(),props.link?h('a',{class:'link'},props.link+' ›'):null])]),slots.default?.()]) } })
const DonutCenter = defineComponent({ props:{value:String,label:String}, setup:p=>()=>h('div',{class:'donut-center'},[h('strong',p.value),h('span',p.label)]) })
const LegendList = defineComponent({ props:{items:{type:Array,required:true}}, setup:p=>()=>h('div',{class:'legend-list'},(p.items as any[]).map(i=>h('div',[h('i',{style:{background:i.color}}),h('span',i.label),h('strong',i.value)]))) })
const PeriodSwitch = defineComponent({ props:{short:Boolean}, setup:p=>()=>h('div',{class:'period-switch'},[h('button',p.short?'近7天':'近7天'),h('button',{class:'active'},p.short?'近30天':'近30天'),p.short?null:h('button','自定义')]) })
const MetricCards = defineComponent({ props:{items:{type:Array,required:true},dense:Boolean}, setup:p=>()=>h('div',{class:['metric-grid',p.dense?'dense':'']},(p.items as Metric[]).map(item=>h('article',{class:'panel metric-card'},[h('span',{class:'metric-icon',style:{color:item.color,background:item.color+'18'}},[h(icons[item.icon] as any)]),h('div',[h('small',item.label),h('strong',[item.value,h('em',item.unit)]),h('p',['较上期　',h('b',{class:item.positive?'up':'down'},item.delta)])])])) ) })
const StandardTable = defineComponent({
  props: { columns: { type: Array, required: true }, rows: { type: Array, required: true } },
  setup: p => () => h('div', { class: 'standard-table' }, [
    h('div', { class: 'standard-head' }, (p.columns as Column[]).map(c =>
      h('span', { style: { width: c.width } }, c.label)
    )),
    ...(p.rows as any[]).map(row =>
      h('div', { class: 'standard-row' }, (p.columns as Column[]).map(c =>
        h('span', { style: { width: c.width }, class: `cell-${c.type || 'text'}` }, renderCell(row[c.key], c.type))
      ))
    )
  ])
})
function renderCell(value:any,type?:string) {
  if(type==='progress') return [h('i',{class:'bar'},[h('i',{style:{width:`${parseFloat(value)}%`}})]),h('em',typeof value==='number'?value+'%':value)]
  if(type==='delta') return h('b',{class:String(value).includes('↑')?'up':'down'},value)
  if(type==='tag'||type==='mode') return h('i',{class:['table-tag',type==='mode'&&value==='按章节'?'green':'']},value)
  if(type==='link') return h('a',{class:'link'},value)
  if(type==='rate') return h('b',{class:parseFloat(value)>=75?'up':'warning'},value)
  if(type==='actions') return h('span',{class:'table-actions'},value)
  if(type==='spark') return h('i',{class:'spark'},value)
  return String(value)
}
const Pagination = defineComponent({ props:{total:String,pages:String}, setup:p=>()=>h('div',{class:'pagination'},[h('span',p.total),h('div',[h('button','‹'),h('button',{class:'active'},'1'),h('button','2'),h('button','3'),h('button','4'),h('button','5'),h('span','…'),h('button',p.pages),h('button','›'),h('button',{class:'page-size'},'10 条/页　⌄')])]) })
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
.table-tag { display:inline-flex; width:max-content; max-width:100%; height:24px; align-items:center; padding:0 8px; color:#ff5260; font-style:normal; background:#fff0f2; border-radius:4px; }
.table-tag.green { color:#0bac67; background:#eaf9f1; }.spark { color:#16ba78; font-size:18px; font-style:normal; letter-spacing:1px; }
.table-actions { color:#33458b; font-size:11px; }.type-charts { grid-template-columns:.9fr 1.1fr; height:295px; }
.type-bottom { display:grid; grid-template-columns:1.45fr .9fr; gap:14px; height:305px; }
.knowledge-charts { display:grid; grid-template-columns:1.25fr 1fr; gap:14px; height:275px; margin-bottom:14px; }
.table-search { width:180px; height:30px; padding:7px 10px; color:var(--muted); font-size:12px; border:1px solid var(--line); border-radius:5px; }
.table-search.wide { width:270px; }.select-btn { border-radius:5px; }
.pagination { display:flex; align-items:center; justify-content:space-between; padding-top:16px; color:#425187; font-size:12px; }
.pagination > div { display:flex; align-items:center; gap:8px; }.pagination button { min-width:34px; height:32px; color:var(--ink); border:1px solid var(--line); border-radius:5px; background:#fff; }
.pagination button.active { color:var(--primary); border-color:#6d94ff; }.pagination .page-size { width:92px; margin-left:14px; }
.mistake-charts { display:grid; grid-template-columns:1.2fr .8fr .9fr; gap:14px; height:235px; margin-bottom:14px; }
.mistake-bottom { display:grid; grid-template-columns:.95fr 1.25fr; gap:14px; height:410px; }
.record-filters { display:flex; gap:8px; }.record-filters button,.export-btn { height:34px; padding:0 16px; color:var(--text); font:inherit; font-size:12px; border:1px solid var(--line); border-radius:5px; background:#fff; }
.record-filters button.active { color:var(--primary); border-color:#7ba0ff; }.export-btn { color:var(--primary); }
.records-panel .standard-row,.records-panel .standard-head { min-height:51px; }
.records-panel { padding:12px; }
@media (max-width:1400px) {
  .metric-card { padding:12px; gap:9px; }.metric-icon { width:40px;height:40px }.metric-card strong { font-size:20px; }
  .ability-summary { grid-template-columns:180px repeat(5,1fr);gap:10px }.ability-card { padding:12px; }
}
</style>
