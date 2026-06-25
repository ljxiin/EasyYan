import { defineStore } from 'pinia'

export type LibraryDifficulty = '简单' | '中等' | '困难'

export type QuestionLibrary = {
  id: number
  name: string
  author: string
  subject: string
  source: string
  questionCount: number
  pointCount: number
  difficulty: LibraryDifficulty
  difficultyType: 'success' | 'warning' | 'danger'
  tags: string[]
  createdAt: string
  mode: string
  tone: string
  coverTitle: string
  description: string
  visibility: string
  deduplicate: boolean
  keepAnalysis: boolean
  fileName: string
}

const initialLibraries: QuestionLibrary[] = [
  {
    id: 1,
    name: '高等数学习题全解（同济第七版）',
    author: '同济大学数学系 编',
    subject: '高等数学',
    source: '教材配套',
    questionCount: 2856,
    pointCount: 98,
    difficulty: '中等',
    difficultyType: 'warning',
    tags: ['同济版', '基础题', '同步练习', '考研'],
    createdAt: '2024-05-12 10:23',
    mode: '同步练习',
    tone: 'blue',
    coverTitle: '高等数学',
    description: '配合同济大学《高等数学》第七版使用，覆盖基础知识、典型例题与考研训练。',
    visibility: '私有（仅自己可见）',
    deduplicate: true,
    keepAnalysis: true,
    fileName: '高等数学习题全解（同济第七版）.docx'
  },
  {
    id: 2,
    name: '线性代数习题精选',
    author: '李永乐 编',
    subject: '线性代数',
    source: '教辅资料',
    questionCount: 1256,
    pointCount: 68,
    difficulty: '中等',
    difficultyType: 'warning',
    tags: ['考研', '真题', '专题训练'],
    createdAt: '2024-05-10 15:30',
    mode: '专题训练',
    tone: 'green',
    coverTitle: '线性代数',
    description: '精选线性代数常考题型，适合专题训练与考研复习。',
    visibility: '私有（仅自己可见）',
    deduplicate: true,
    keepAnalysis: true,
    fileName: '线性代数习题精选.docx'
  },
  {
    id: 3,
    name: '概率论与数理统计习题集',
    author: '盛骤 谢式千 潘承毅 编',
    subject: '概率论与数理统计',
    source: '教材配套',
    questionCount: 1852,
    pointCount: 72,
    difficulty: '中等',
    difficultyType: 'warning',
    tags: ['浙大版', '基础题', '同步练习', '概率'],
    createdAt: '2024-05-08 09:15',
    mode: '同步练习',
    tone: 'purple',
    coverTitle: '概率统计',
    description: '覆盖概率论与数理统计主要知识点及配套练习。',
    visibility: '团队可见',
    deduplicate: true,
    keepAnalysis: true,
    fileName: '概率论与数理统计习题集.docx'
  },
  {
    id: 4,
    name: '数学分析习题精讲精练',
    author: '华东师范大学数学系 编',
    subject: '数学分析',
    source: '教辅资料',
    questionCount: 2136,
    pointCount: 85,
    difficulty: '困难',
    difficultyType: 'danger',
    tags: ['考研', '提高题', '专题训练'],
    createdAt: '2024-04-28 11:20',
    mode: '专题训练',
    tone: 'orange',
    coverTitle: '数学分析',
    description: '数学分析提高训练，包含证明题、计算题与综合应用题。',
    visibility: '私有（仅自己可见）',
    deduplicate: true,
    keepAnalysis: true,
    fileName: '数学分析习题精讲精练.pdf'
  },
  {
    id: 5,
    name: '高等代数习题精解',
    author: '吴赣昌 编',
    subject: '高等代数',
    source: '教材配套',
    questionCount: 1048,
    pointCount: 45,
    difficulty: '简单',
    difficultyType: 'success',
    tags: ['北大版', '基础题'],
    createdAt: '2024-04-20 16:40',
    mode: '同步练习',
    tone: 'teal',
    coverTitle: '高等代数',
    description: '高等代数基础习题与例题解析。',
    visibility: '公开',
    deduplicate: true,
    keepAnalysis: true,
    fileName: '高等代数习题精解.docx'
  },
  {
    id: 6,
    name: '历年考研数学真题分类汇编（数学一）',
    author: '张宇 编',
    subject: '高等数学',
    source: '真题汇编',
    questionCount: 3420,
    pointCount: 120,
    difficulty: '困难',
    difficultyType: 'danger',
    tags: ['真题', '考研', '分类训练', '数学一'],
    createdAt: '2024-04-15 20:18',
    mode: '真题汇编',
    tone: 'blue',
    coverTitle: '真题汇编',
    description: '历年考研数学一真题按章节和知识点分类整理。',
    visibility: '私有（仅自己可见）',
    deduplicate: true,
    keepAnalysis: true,
    fileName: '历年考研数学真题分类汇编（数学一）.docx'
  }
]

const defaultForm = () => ({
  name: '高等数学习题集',
  subject: '高等数学',
  source: '自建题库',
  difficulty: '中等' as LibraryDifficulty,
  visibility: '私有（仅自己可见）',
  tags: ['考研', '同步练习'] as string[],
  description: '面向考研数学复习的高等数学习题库，包含题目、答案与详细解析。',
  deduplicate: true,
  keepAnalysis: true
})

export const useQuestionLibraryStore = defineStore('questionLibrary', {
  state: () => ({
    libraries: initialLibraries,
    mode: 'create' as 'create' | 'edit',
    editingId: null as number | null,
    fileName: '',
    form: defaultForm()
  }),
  actions: {
    startCreate() {
      this.mode = 'create'
      this.editingId = null
      this.fileName = ''
      this.form = defaultForm()
    },
    startEdit(library: QuestionLibrary) {
      this.mode = 'edit'
      this.editingId = library.id
      this.fileName = library.fileName
      this.form = {
        name: library.name,
        subject: library.subject,
        source: library.source,
        difficulty: library.difficulty,
        visibility: library.visibility,
        tags: [...library.tags],
        description: library.description,
        deduplicate: library.deduplicate,
        keepAnalysis: library.keepAnalysis
      }
    },
    save(fileName?: string) {
      const difficultyType =
        this.form.difficulty === '简单' ? 'success' : this.form.difficulty === '困难' ? 'danger' : 'warning'
      if (this.mode === 'edit' && this.editingId !== null) {
        const library = this.libraries.find((item) => item.id === this.editingId)
        if (!library) return
        Object.assign(library, {
          ...this.form,
          difficultyType,
          fileName: fileName || this.fileName,
          coverTitle: this.form.subject
        })
        return
      }
      const nextId = Math.max(0, ...this.libraries.map((item) => item.id)) + 1
      this.libraries.unshift({
        id: nextId,
        ...this.form,
        author: '当前用户',
        questionCount: 256,
        pointCount: 86,
        difficultyType,
        createdAt: new Date().toLocaleString('zh-CN', { hour12: false }).replace(/\//g, '-'),
        mode: this.form.tags[0] || '自建题库',
        tone: 'blue',
        coverTitle: this.form.subject,
        fileName: fileName || this.fileName || `${this.form.name}.docx`
      })
    },
    remove(id: number) {
      this.libraries = this.libraries.filter((item) => item.id !== id)
    }
  }
})
