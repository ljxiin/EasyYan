import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import BasicLayout from '@/layouts/BasicLayout.vue'
import Dashboard from '@/views/Dashboard.vue'
import PlaceholderPage from '@/views/PlaceholderPage.vue'
import QuestionBank from '@/views/QuestionBank.vue'
import QuestionLibrary from '@/views/QuestionLibrary.vue'
import QuestionImport from '@/views/QuestionImport.vue'
import PaperLibrary from '@/views/PaperLibrary.vue'
import PaperImport from '@/views/PaperImport.vue'
import Practice from '@/views/Practice.vue'
import CustomPaper from '@/views/CustomPaper.vue'
import Statistics from '@/views/Statistics.vue'

export const menuRoutes = [
  { path: '/', name: 'home', title: '首页', icon: 'House' },
  { path: '/textbooks', name: 'textbooks', title: '教材库', icon: 'Reading' },
  { path: '/questions', name: 'questions', title: '习题库', icon: 'Document' },
  { path: '/papers', name: 'papers', title: '试卷库', icon: 'Tickets' },
  { path: '/practice', name: 'practice', title: '刷题', icon: 'Checked' },
  { path: '/statistics', name: 'statistics', title: '统计分析', icon: 'Histogram' },
  { path: '/knowledge', name: 'knowledge', title: '知识网络', icon: 'Share' },
  { path: '/plans', name: 'plans', title: '学习计划', icon: 'Calendar' },
  { path: '/notes', name: 'notes', title: '笔记管理', icon: 'EditPen' },
  { path: '/settings', name: 'settings', title: '设置', icon: 'Setting' }
] as const

const children: RouteRecordRaw[] = [
  { path: '', name: 'home', component: Dashboard, meta: { title: '首页 / 学习概览' } },
  { path: 'questions', name: 'questions', component: QuestionLibrary, meta: { title: '习题库' } },
  {
    path: 'questions/detail',
    name: 'questionDetail',
    component: QuestionBank,
    meta: { title: '习题库 / 题目详情' }
  },
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
    path: 'questions/import/settings',
    name: 'questionImportSettings',
    component: QuestionImport,
    meta: { title: '习题库 / 导入题目', step: 3 }
  },
  {
    path: 'questions/import/confirm',
    name: 'questionImportConfirm',
    component: QuestionImport,
    meta: { title: '习题库 / 导入题目', step: 4 }
  },
  {
    path: 'questions/create',
    name: 'questionLibraryCreate',
    component: QuestionImport,
    meta: { title: '习题库 / 新建或编辑习题库', step: 1, flow: 'library' }
  },
  {
    path: 'questions/create/parse',
    name: 'questionLibraryCreateParse',
    component: QuestionImport,
    meta: { title: '习题库 / 新建或编辑习题库', step: 2, flow: 'library' }
  },
  {
    path: 'questions/create/settings',
    name: 'questionLibraryCreateSettings',
    component: QuestionImport,
    meta: { title: '习题库 / 新建或编辑习题库', step: 3, flow: 'library' }
  },
  {
    path: 'questions/create/confirm',
    name: 'questionLibraryCreateConfirm',
    component: QuestionImport,
    meta: { title: '习题库 / 新建或编辑习题库', step: 4, flow: 'library' }
  },
  { path: 'papers', name: 'papers', component: PaperLibrary, meta: { title: '试卷库' } },
  { path: 'papers/import', name: 'paperImport', component: PaperImport, meta: { title: '试卷库　/　导入试卷', step: 1 } },
  { path: 'papers/import/parse', name: 'paperImportParse', component: PaperImport, meta: { title: '试卷库　/　导入试卷', step: 2 } },
  { path: 'papers/import/settings', name: 'paperImportSettings', component: PaperImport, meta: { title: '试卷库　/　导入试卷', step: 3 } },
  { path: 'papers/import/confirm', name: 'paperImportConfirm', component: PaperImport, meta: { title: '试卷库　/　导入试卷', step: 4 } },
  { path: 'practice', name: 'practice', component: Practice, meta: { title: '刷题' } },
  { path: 'statistics', name: 'statistics', component: Statistics, meta: { title: '统计分析' } },
  { path: 'practice/session', name: 'practiceSession', component: Practice, meta: { title: '刷题详情', practiceSession: true } },
  { path: 'practice/custom', name: 'customPaper', component: CustomPaper, meta: { title: '自定义组卷 / 新增组卷', customPaper: true, step: 1 } },
  { path: 'practice/custom/questions', redirect: { name: 'customPaperPreview' } },
  { path: 'practice/custom/preview', name: 'customPaperPreview', component: CustomPaper, meta: { title: '自定义组卷 / 新增组卷', customPaper: true, step: 2 } },
  { path: 'practice/custom/complete', name: 'customPaperComplete', component: CustomPaper, meta: { title: '自定义组卷 / 新增组卷', customPaper: true, step: 3 } },
  ...menuRoutes
    .filter((route) => route.path !== '/' && route.path !== '/questions' && route.path !== '/papers' && route.path !== '/practice' && route.path !== '/statistics')
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
