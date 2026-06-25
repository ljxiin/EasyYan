<template>
  <section class="dashboard">
    <div class="stats">
      <article v-for="card in statCards" :key="card.label" class="stat panel">
        <span class="soft-icon" :style="{ color: card.color, backgroundColor: `${card.color}18` }">
          <component :is="icons[card.icon]" />
        </span>
        <div>
          <p>{{ card.label }}</p>
          <strong>{{ card.value }} <em>{{ card.unit }}</em></strong>
          <span>{{ card.delta }}</span>
        </div>
      </article>
    </div>

    <div class="grid top-grid">
      <article class="panel task-card">
        <div class="section-head">
          <h2>今日任务</h2>
          <span class="muted">目标：完成 50 题</span>
        </div>
        <div class="task-body">
          <div class="donut-wrap">
            <EChart :option="taskChartOption" />
            <div class="donut-center">
              <strong>70%</strong>
              <span>已完成</span>
            </div>
          </div>
          <div class="task-meta">
            <div class="task-row">
              <div><span>已完成</span><strong>35</strong><em>题</em></div>
              <div><span>剩余</span><strong>15</strong><em>题</em></div>
              <div><span>预计耗时</span><strong>40</strong><em>分钟</em></div>
            </div>
            <el-progress :percentage="70" :show-text="false" :stroke-width="10" />
          </div>
        </div>
        <div class="task-footer">
          <span>每日任务将在 23:59:59 后重置</span>
          <el-button type="primary">去刷题</el-button>
        </div>
      </article>

      <article class="panel weak-card">
        <div class="section-head">
          <h2>薄弱考点 TOP5</h2>
          <el-select model-value="高等数学" size="small" class="subject">
            <el-option label="高等数学" value="高等数学" />
          </el-select>
          <a class="link">全部考点</a>
        </div>
        <div class="weak-list">
          <div v-for="(item, index) in weakPoints" :key="item.name" class="weak-item">
            <span class="rank" :class="`rank-${index + 1}`">{{ index + 1 }}</span>
            <strong>{{ item.name }}</strong>
            <el-progress :percentage="item.percent" :show-text="false" />
            <em>{{ item.percent }}%</em>
          </div>
        </div>
      </article>

      <article class="panel calendar-card">
        <div class="section-head">
          <h2>学习日历</h2>
          <strong>2024年5月 〉</strong>
        </div>
        <div class="calendar">
          <span v-for="day in weekdays" :key="day" class="weekday">{{ day }}</span>
          <span
            v-for="(day, index) in days"
            :key="`${day}-${index}`"
            class="day"
            :class="{ active: day === '12' && index === 13, muted: index < 2 || index > 32 }"
          >
            {{ day }}
          </span>
        </div>
        <div class="legend">
          <span><i class="gray"></i>未学习</span>
          <span><i class="orange"></i>学习中</span>
          <span><i class="green"></i>已完成</span>
        </div>
      </article>
    </div>

    <div class="grid bottom-grid">
      <article class="panel records-card">
        <div class="section-head">
          <h2>最近刷题记录</h2>
          <a class="link">查看全部</a>
        </div>
        <el-table :data="recentRecords" class="record-table">
          <el-table-column prop="type" label="类型" width="110">
            <template #default="{ row }">
              <span class="record-type" :style="{ color: row.color, backgroundColor: `${row.color}16` }">{{ row.type }}</span>
            </template>
          </el-table-column>
          <el-table-column prop="content" label="内容" min-width="260" />
          <el-table-column prop="count" label="题量" width="90" />
          <el-table-column prop="rate" label="正确率" width="90" />
          <el-table-column prop="time" label="时间" width="120" />
          <el-table-column prop="action" label="操作" width="100">
            <template #default="{ row }"><a class="link">{{ row.action }}</a></template>
          </el-table-column>
        </el-table>
      </article>

      <div class="right-stack">
        <article class="panel mastery-card">
          <h2>知识掌握度分布</h2>
          <div class="mastery-body">
            <div class="mastery-chart">
              <EChart :option="masteryOption" />
              <div class="donut-center">
                <strong>256</strong>
                <span>总考点</span>
              </div>
            </div>
            <div class="mastery-list">
              <span><i class="green"></i>掌握牢固 88 个 (34%)</span>
              <span><i class="orange"></i>掌握一般 102 个 (40%)</span>
              <span><i class="red"></i>掌握薄弱 46 个 (18%)</span>
              <span><i class="gray"></i>未开始 20 个 (8%)</span>
            </div>
          </div>
        </article>

        <article class="panel suggestion-card">
          <span class="soft-icon bulb"><el-icon><Opportunity /></el-icon></span>
          <div>
            <h2>学习建议</h2>
            <h3>坚持真题训练，查漏补缺</h3>
            <p>根据你的学习数据分析，建议加强“多元函数微分学”的练习，巩固基础知识，提升整体正确率。</p>
          </div>
          <el-button>去练习薄弱考点</el-button>
        </article>
      </div>
    </div>
  </section>
</template>

<script setup lang="ts">
import * as ElementIcons from '@element-plus/icons-vue'
import { Opportunity } from '@element-plus/icons-vue'
import EChart from '@/components/EChart.vue'
import { masteryOption, recentRecords, statCards, taskChartOption, weakPoints } from '@/mock/dashboard'

const icons = ElementIcons as Record<string, unknown>
const weekdays = ['一', '二', '三', '四', '五', '六', '日']
const days = ['29', '30', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '1', '2']
</script>

<style scoped lang="scss">
.dashboard {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.stats {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 14px;
}

.stat {
  display: flex;
  align-items: center;
  gap: 18px;
  height: 138px;
  padding: 22px;
}

.soft-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  border-radius: 12px;
  font-size: 26px;
}

.stat p,
.stat span {
  margin: 0;
  color: var(--muted);
  font-size: 14px;
}

.stat strong {
  display: block;
  margin: 8px 0;
  color: var(--ink);
  font-size: 28px;
  font-weight: 900;
}

.stat em {
  color: var(--text);
  font-size: 13px;
  font-style: normal;
}

.grid {
  display: grid;
  gap: 16px;
}

.top-grid {
  grid-template-columns: 1.08fr 1.02fr 1fr;
}

.bottom-grid {
  grid-template-columns: 1.35fr 1fr;
}

.task-card,
.weak-card,
.calendar-card,
.records-card,
.mastery-card,
.suggestion-card {
  padding: 22px;
}

.section-head {
  display: flex;
  align-items: center;
  gap: 14px;
  margin-bottom: 18px;
}

.section-head h2,
.mastery-card h2,
.suggestion-card h2 {
  flex: 1;
  margin: 0;
  color: var(--ink);
  font-size: 18px;
  font-weight: 800;
}

.task-body {
  display: flex;
  align-items: center;
  gap: 42px;
  min-height: 174px;
}

.donut-wrap,
.mastery-chart {
  position: relative;
  width: 142px;
  height: 142px;
  flex: none;
}

.donut-center {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}

.donut-center strong {
  color: var(--ink);
  font-size: 30px;
  font-weight: 900;
}

.donut-center span {
  color: var(--muted);
  font-size: 13px;
}

.task-meta {
  flex: 1;
}

.task-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  margin-bottom: 34px;
}

.task-row span {
  display: block;
  color: var(--muted);
  font-size: 13px;
}

.task-row strong {
  color: var(--ink);
  font-size: 22px;
}

.task-row em {
  margin-left: 4px;
  font-size: 12px;
  font-style: normal;
}

.task-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-top: 16px;
  color: var(--muted);
  border-top: 1px solid var(--line);
}

.weak-list {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.weak-item {
  display: grid;
  grid-template-columns: 24px 1fr 126px 44px;
  align-items: center;
  gap: 14px;
}

.weak-item strong {
  color: var(--ink);
  font-size: 15px;
}

.weak-item em {
  color: var(--ink);
  font-style: normal;
  text-align: right;
}

.rank {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 20px;
  height: 20px;
  color: #fff;
  font-size: 12px;
  font-weight: 800;
  background: #b9c0d2;
  border-radius: 5px;
}

.rank-1 {
  background: var(--red);
}

.rank-2,
.rank-3 {
  background: var(--orange);
}

.subject {
  width: 112px;
}

.calendar {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 8px 6px;
  text-align: center;
}

.weekday {
  color: var(--muted);
  font-size: 12px;
}

.day {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  margin: 0 auto;
  color: var(--ink);
  border-radius: 50%;
}

.day.active {
  color: #fff;
  background: var(--primary);
}

.day.muted {
  color: #a9b3cc;
}

.legend,
.mastery-list {
  display: flex;
  justify-content: center;
  gap: 22px;
  margin-top: 20px;
  color: var(--muted);
  font-size: 13px;
}

.legend i,
.mastery-list i {
  display: inline-block;
  width: 7px;
  height: 7px;
  margin-right: 8px;
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

.gray {
  background: #c7cdda;
}

.record-table {
  border: 1px solid var(--line);
  border-radius: 8px;
}

.record-type {
  display: inline-flex;
  align-items: center;
  height: 26px;
  padding: 0 10px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 800;
}

.right-stack {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.mastery-body {
  display: flex;
  align-items: center;
  gap: 28px;
}

.mastery-chart {
  width: 126px;
  height: 126px;
}

.mastery-chart .donut-center strong {
  font-size: 24px;
}

.mastery-list {
  flex-direction: column;
  align-items: flex-start;
  gap: 12px;
  margin: 0;
}

.suggestion-card {
  display: grid;
  grid-template-columns: 48px 1fr auto;
  gap: 16px;
  align-items: start;
}

.suggestion-card h3 {
  margin: 10px 0 8px;
  color: var(--ink);
  font-size: 16px;
}

.suggestion-card p {
  margin: 0;
  color: var(--muted);
  line-height: 1.6;
}

.bulb {
  color: var(--primary);
  background: var(--primary-soft);
}
</style>
