import { defineStore } from 'pinia'

export type PaperQuestionDraft = {
  no: number
  status: string
  text: string
  options: string
  answer: string
  analysis: string
  tags: string[]
}

export const usePaperImportStore = defineStore('paperImport', {
  state: () => ({
    mode: 'import' as 'import' | 'edit',
    paperId: null as number | null,
    fileName: '',
    questions: [] as PaperQuestionDraft[],
    form: {
      name: '2024年考研数学（一）真题',
      subject: '数学（一）',
      source: '中国研究生招生信息网',
      year: '2024',
      type: '真题',
      book: '考研数学（一）',
      points: [] as string[],
      tags: ['考研真题', '近五年']
    }
  }),
  actions: {
    startImport() {
      this.$reset()
    },
    startEdit(paper: {
      id: number
      name: string
      subject: string
      source: string
      year: string
      type: string
    }) {
      this.$reset()
      this.mode = 'edit'
      this.paperId = paper.id
      this.fileName = `${paper.name}.docx`
      this.form.name = paper.name
      this.form.subject = paper.subject
      this.form.source = paper.source
      this.form.year = paper.year
      this.form.type = paper.type
      this.form.book = paper.subject
    }
  }
})
