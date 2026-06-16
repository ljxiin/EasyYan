import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import BasicLayout from '@/layouts/BasicLayout.vue'
import Dashboard from '@/views/Dashboard.vue'
import PlaceholderPage from '@/views/PlaceholderPage.vue'
import QuestionBank from '@/views/QuestionBank.vue'
import QuestionImport from '@/views/QuestionImport.vue'

export const menuRoutes = [
  { path: '/', name: 'home', title: '首页', icon: 'House' },
  { path: '/textbooks', name: 'textbooks', title: '教材库', icon: 'Reading' },
  { path: '/questions', name: 'questions', title: '习题库', icon: 'Document' },
  { path: '/papers', name: 'papers', title: '试卷库', icon: 'Tickets' },
  { path: '/practice', name: 'practice', title: '刷题', icon: 'Checked' },
  { path: '/mistakes', name: 'mistakes', title: '错题集', icon: 'Grid' },
  { path: '/favorites', name: 'favorites', title: '收藏夹', icon: 'Star' },
  { path: '/statistics', name: 'statistics', title: '统计分析', icon: 'Histogram' },
  { path: '/knowledge', name: 'knowledge', title: '知识网络', icon: 'Share' },
  { path: '/plans', name: 'plans', title: '学习计划', icon: 'Calendar' },
  { path: '/notes', name: 'notes', title: '笔记管理', icon: 'EditPen' },
  { path: '/settings', name: 'settings', title: '设置', icon: 'Setting' }
] as const

const children: RouteRecordRaw[] = [
  { path: '', name: 'home', component: Dashboard, meta: { title: '首页 / 学习概览' } },
  { path: 'questions', name: 'questions', component: QuestionBank, meta: { title: '习题库' } },
  {
    path: 'questions/import',
    name: 'questionImport',
    component: QuestionImport,
    meta: { title: '习题库 / 导入题目', step: 1 }
  },
  {
    path: 'questions/import/parse',
    name: 'questionImportParse',
    component: QuestionImport,
    meta: { title: '习题库 / 导入题目', step: 2 }
  },
  {
    path: 'questions/import/confirm',
    name: 'questionImportConfirm',
    component: QuestionImport,
    meta: { title: '习题库 / 导入题目', step: 4 }
  },
  ...menuRoutes
    .filter((route) => route.path !== '/' && route.path !== '/questions')
    .map((route) => ({
      path: route.path.slice(1),
      name: route.name,
      component: PlaceholderPage,
      meta: { title: route.title }
    }))
]

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: BasicLayout,
      children
    }
  ]
})

export default router
