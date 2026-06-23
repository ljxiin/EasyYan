<template>
  <section class="paper-import">
    <div class="panel steps">
      <div v-for="(item,index) in stepItems" :key="item.title" class="step" :class="{ active: step === index+1, done: step > index+1 }">
        <span><el-icon v-if="step > index+1"><Check /></el-icon><template v-else>{{ index+1 }}</template></span>
        <div><strong>{{ item.title }}</strong><p>{{ item.desc }}</p></div>
        <i v-if="index<3"></i>
      </div>
    </div>

    <template v-if="step === 1">
      <div class="panel upload-layout">
        <main>
          <h2>选择导入方式</h2><p class="subtitle">请选择导入试卷的方式，系统将自动识别试卷结构并导入题目</p>
          <div class="method-tabs"><button class="active"><el-icon><Promotion /></el-icon>推荐方式</button><button><el-icon><Document /></el-icon>粘贴文本</button></div>
          <div class="drop-zone" :class="{ selected: fileName }" @click="pickFile" @dragover.prevent @drop.prevent="onDrop">
            <input ref="fileInput" type="file" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png" @change="onFile" />
            <div class="folder-art"><el-icon><FolderAdd /></el-icon></div>
            <strong>{{ fileName || '点击上传或拖拽文件到此处' }}</strong>
            <p>{{ fileName ? '文件已准备就绪' : '支持 PDF、Word（.docx）、图片（JPG、PNG）格式' }}</p>
            <p v-if="!fileName">文件大小不超过 50MB</p>
            <el-button type="primary" plain :icon="Upload">选择文件</el-button>
          </div>
          <h3>其他方式</h3>
          <div class="other-methods">
            <button><el-icon><FullScreen /></el-icon><span><b>拍照/扫描导入</b><small>使用手机拍照或扫描试卷，支持多页自动识别</small></span><el-icon><ArrowRight /></el-icon></button>
            <button><el-icon><Link /></el-icon><span><b>从链接导入（试卷来源链接）</b><small>输入试卷的网页链接，系统自动抓取内容</small></span><el-icon><ArrowRight /></el-icon></button>
          </div>
        </main>
        <aside class="tips">
          <h2><el-icon><InfoFilled /></el-icon>温馨提示</h2>
          <div v-for="tip in tips" :key="tip.title"><span :class="tip.tone"><el-icon><component :is="tip.icon" /></el-icon></span><section><strong>{{ tip.title }}</strong><p>{{ tip.text }}</p></section></div>
          <div class="help"><span><el-icon><QuestionFilled /></el-icon></span><section><strong>遇到问题？</strong><p>查看帮助文档或联系客服，获取更多支持</p><el-button type="primary" plain>查看帮助文档</el-button></section></div>
        </aside>
      </div>
    </template>

    <template v-else-if="step === 2">
      <div class="parse-layout">
        <aside class="panel structure">
          <h3>试卷结构 <small>（可编辑）</small></h3>
          <div v-for="group in structure" :key="group.title" class="structure-group">
            <strong>{{ group.title }}</strong>
            <button v-for="q in group.questions" :key="q.no" type="button" :class="{ active: selectedQuestionNo === q.no }" @click="selectStructureQuestion(q.no)">
              <span>{{ q.no }}</span><i>{{ q.type }}</i><em>{{ q.tag }}</em><el-icon><Check /></el-icon>
            </button>
          </div>
        </aside>
        <main class="panel preview">
          <div class="preview-head">
            <h3>题目预览 <small>（当前 {{ filteredPreviewQuestions.length }} 题）</small></h3>
            <div class="status-filters">
              <button v-for="item in statusFilters" :key="item.value" type="button" :class="[item.value, { active: selectedStatus === item.value }]" @click="toggleStatusFilter(item.value)">
                <i></i>{{ item.label }} <b>{{ statusCount(item.value) }}</b>
              </button>
              <button v-if="selectedStatus || selectedQuestionNo" type="button" class="clear-filter" @click="clearQuestionFilters">显示全部</button>
            </div>
          </div>
          <article v-for="question in paginatedPreviewQuestions" :key="question.no" class="question-card">
            <header><b :class="question.status">{{ question.no }}</b><i>单选题</i><em>{{ question.tags[0] }}</em><el-button class="edit-question-button" size="small" :icon="EditPen" @click="openEditDialog(question)">编辑题目</el-button><small :class="question.status">{{ statusLabel(question.status) }}</small></header>
            <p v-html="renderLatex(question.text)"></p><div class="options" v-html="renderLatex(question.options)"></div>
            <section><strong>正确答案：<span v-html="renderLatex(question.answer)"></span></strong><b>题目解析：</b><p v-html="renderLatex(question.analysis)"></p></section>
            <footer>考点标签：<el-tag v-for="tag in question.tags" :key="tag" size="small" closable @close="removeQuestionTag(question.no, tag)">{{ tag }}</el-tag><el-button class="add-tag-button" size="small" :icon="Plus" @click="openTagDialog(question.no)">添加标签</el-button></footer>
          </article>
          <el-empty v-if="!filteredPreviewQuestions.length" description="暂无符合筛选条件的题目" />
          <div v-else class="question-pagination">
            <span>共 {{ filteredPreviewQuestions.length }} 道题</span>
            <el-select v-model="questionPageSize" class="question-page-size">
              <el-option label="3 条/页" :value="3" />
            </el-select>
            <el-pagination
              v-model:current-page="questionPage"
              layout="prev, pager, next"
              :page-size="questionPageSize"
              :total="filteredPreviewQuestions.length"
            />
          </div>
        </main>
        <aside class="parse-side">
          <section class="panel result">
            <h3>识别结果概览</h3>
            <div>
              <span><b class="result-icon total"><el-icon><Document /></el-icon></b><strong>22</strong><small>总题数</small></span>
              <span><b class="result-icon success"><el-icon><CircleCheckFilled /></el-icon></b><strong>20</strong><small>识别正确</small></span>
              <span><b class="result-icon warning"><el-icon><WarningFilled /></el-icon></b><strong>2</strong><small>疑似错误</small></span>
              <span><b class="result-icon unrecognized"><el-icon><CircleCloseFilled /></el-icon></b><strong>0</strong><small>未识别</small></span>
            </div>
          </section>
          <section class="panel detail"><h3>识别详情</h3><p><b>题型</b><b>题数</b><b>识别正确</b><b>疑似错误</b><b>未识别</b></p><p v-for="row in [['选择题',8,8,0,0],['填空题',6,6,0,0],['解答题',8,6,2,0],['总计',22,20,2,0]]" :key="row[0]"><span v-for="v in row" :key="v">{{ v }}</span></p></section>
          <section class="panel warm"><h3><el-icon><InfoFilled /></el-icon>温馨提示</h3><p>• 系统已自动识别试卷结构和题目内容</p><p>• 疑似错误的题目请仔细核对</p><p>• 为每道题选择或添加考点标签</p><p>• 如识别结果整体有误，可点击“重新识别”</p></section>
        </aside>
      </div>

      <el-dialog v-model="editDialogVisible" title="编辑题目" width="680px">
        <el-form label-position="top">
          <el-form-item label="题目内容（公式请使用 $...$ 包裹）"><el-input v-model="editForm.text" type="textarea" :rows="4" /></el-form-item>
          <el-form-item label="正确答案（支持 LaTeX）"><el-input v-model="editForm.answer" /></el-form-item>
          <el-form-item label="题目解析（公式请使用 $...$ 包裹）"><el-input v-model="editForm.analysis" type="textarea" :rows="5" /></el-form-item>
        </el-form>
        <template #footer><el-button @click="editDialogVisible=false">取消</el-button><el-button type="primary" @click="saveQuestionEdit">保存修改</el-button></template>
      </el-dialog>

      <el-dialog v-model="tagDialogVisible" title="新增考点标签" width="420px">
        <el-input v-model="newTagName" maxlength="20" show-word-limit placeholder="请输入标签名称" @keyup.enter="addQuestionTag" />
        <template #footer><el-button @click="tagDialogVisible=false">取消</el-button><el-button type="primary" @click="addQuestionTag">确认添加</el-button></template>
      </el-dialog>
    </template>

    <template v-else-if="step === 3">
      <div class="panel settings">
        <h2>分类与设置</h2>
        <p>设置试卷的基本属性，完成后即可确认导入</p>
        <div class="settings-form">
          <label>试卷名称<el-input v-model="form.name" /></label>
          <label>科目<el-select v-model="form.subject"><el-option v-for="subject in subjectOptions" :key="subject" :label="subject" :value="subject" /></el-select></label>
          <label>来源<el-input v-model="form.source" /></label>
          <label>年份
            <el-date-picker
              v-model="form.year"
              type="year"
              value-format="YYYY"
              format="YYYY 年"
              placeholder="请选择年份"
            />
          </label>
          <label>试卷类型<el-select v-model="form.type"><el-option label="真题" value="真题" /><el-option label="模拟卷" value="模拟卷" /></el-select></label>
          <label>所属教材<el-input v-model="form.book" /></label>
          <label class="wide">考点分类
            <el-select v-model="form.points" class="point-category-select" multiple placeholder="暂无识别到的考点">
              <el-option v-for="point in allPointTags" :key="point" :label="point" :value="point" />
            </el-select>
          </label>
          <label class="wide">标签<el-select v-model="form.tags" multiple><el-option label="考研真题" value="考研真题" /><el-option label="近五年" value="近五年" /></el-select></label>
        </div>
      </div>
    </template>

    <template v-else>
      <div class="confirm-layout">
        <main class="panel info">
          <header class="confirm-card-head"><h2>{{ isEditMode ? '确认保存' : '确认导入' }}</h2><p>请确认试卷信息无误，确认后将{{ isEditMode ? '保存本次修改' : '完成导入' }}</p></header>
          <section class="paper-info-section"><h3>试卷信息</h3><dl><template v-for="row in confirmRows" :key="row[0]"><dt>{{ row[0] }}</dt><dd>{{ row[1] }}</dd></template></dl></section>
          <div class="import-note"><h3><el-icon><InfoFilled /></el-icon>导入说明</h3><p>• 导入完成后，试卷将保存到「试卷库」中，您可以在试卷详情页查看和管理试题。</p><p>• 系统已自动识别试题内容、答案及解析，如有错误，您可在试卷详情页进行编辑。</p><p>• 试卷一旦导入成功，您可随时进行修改或重新分类。</p></div>
        </main>
        <aside class="panel overview"><header><h2>试卷内容概览</h2><span>共 22 题</span></header><h3>题型分布</h3><div class="chart-row"><div class="donut"><strong>22</strong><small>总题数</small></div><ul><li><i class="blue"></i>选择题 <b>8 题（36.4%）</b></li><li><i class="green"></i>填空题 <b>6 题（27.3%）</b></li><li><i class="orange"></i>解答题 <b>8 题（36.4%）</b></li></ul></div><h3>考点分布（TOP 5）</h3><div v-for="(p,i) in points" :key="p[0]" class="point-bar"><span>{{ p[0] }}</span><i><b :style="{width:p[1]+'%'}"></b></i><em>{{ [5,4,4,3,2,4][i] }} 题</em></div></aside>
      </div>
    </template>

    <div class="page-actions">
      <div class="secondary-actions">
        <el-button v-if="step>1 && !(isEditMode && step===2)" @click="go(step-1)">上一步{{ step===4 ? '：分类与设置' : '' }}</el-button>
        <el-button v-if="step===1" @click="router.push('/papers')">取消</el-button>
        <el-button v-if="step===2" @click="router.push('/papers')">{{ isEditMode ? '取消编辑' : '取消导入' }}</el-button>
      </div>
      <el-button class="next-step-button" type="primary" @click="next">{{ step===4 ? (isEditMode ? '✓　确认保存' : '✓　确认导入') : step===3 ? (isEditMode ? '下一步：确认保存' : '下一步：确认导入') : step===2 ? '下一步：分类与设置' : '下一步：预览与解析' }}</el-button>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, reactive, ref, toRef, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import katex from 'katex'
import { ArrowRight, Check, CircleCheckFilled, CircleCloseFilled, Document, EditPen, FolderAdd, FullScreen, InfoFilled, Link, Picture, Plus, Promotion, QuestionFilled, Upload, WarningFilled } from '@element-plus/icons-vue'
import { usePaperImportStore } from '@/stores/paperImport'
const route=useRoute(),router=useRouter()
const paperDraft=usePaperImportStore()
if(route.query.mode==='edit'){
  const routePaperId=Number(route.query.paperId)
  if(paperDraft.mode!=='edit'||paperDraft.paperId!==routePaperId){
    paperDraft.startEdit({
      id:routePaperId,
      name:String(route.query.name||'待修改试卷'),
      subject:String(route.query.subject||'高等数学'),
      source:String(route.query.source||'自建'),
      year:String(route.query.year||'2024'),
      type:String(route.query.type||'模拟卷')
    })
  }
}
const isEditMode=computed(()=>paperDraft.mode==='edit')
const step=computed(()=>Number(route.meta.step||1))
const stepItems=computed(()=>[{title:'选择导入方式',desc:isEditMode.value?'已选择当前试卷':'上传文件或粘贴内容'},{title:'预览与解析',desc:'识别试卷结构'},{title:'分类与设置',desc:'设置试卷属性'},{title:isEditMode.value?'确认保存':'确认导入',desc:isEditMode.value?'确认并保存修改':'确认并完成导入'}])
const subjectOptions=['数学（一）','高等数学','线性代数','概率论与数理统计']
const fileInput=ref<HTMLInputElement>(),fileName=toRef(paperDraft,'fileName')
const tips=[{title:'支持多种格式',text:'支持 PDF、Word（.docx）、图片（JPG、PNG）格式，文件大小不超过 50MB',icon:Document,tone:'blue'},{title:'保证图片清晰',text:'图片文件请确保清晰、无倾斜，建议分辨率不低于 300dpi',icon:FullScreen,tone:'green'},{title:'复杂排版识别',text:'试卷中请尽量避免使用特殊字体和复杂排版，建议使用常规字体和标准格式',icon:Picture,tone:'orange'},{title:'导入完成后',text:'您可以在试卷详情页进行编辑和完善，确认无误后再使用试卷',icon:Check,tone:'purple'}]
const structure=[{title:'一、选择题（共 8 题，每题 4 分，共 32 分）',questions:[1,2,3,4,5,6,7,8].map((no)=>({no,type:'[单选题]',tag:['极限与连续','导数与微分','积分学','一元函数微分学','常微分方程','级数','向量代数与空间解析几何','多元函数微积分'][no-1]}))},{title:'二、填空题（共 6 题，每题 4 分，共 24 分）',questions:[9,10,11,12,13,14].map(no=>({no,type:'[填空题]',tag:['极限与连续','导数与微分','积分学','级数','常微分方程','向量代数与空间解析几何'][no-9]}))},{title:'三、解答题（共 8 题，共 94 分）',questions:[15,16,17,18,19,20,21,22].map(no=>({no,type:'[解答题]',tag:['微分中值定理','不定积分','定积分','多元函数微分学','二重积分','常微分方程','无穷级数','空间解析几何'][no-15]}))}]
const structureQuestions=structure.flatMap(group=>group.questions)
const detailedQuestions=[
  {no:1,status:'success',text:'设函数 $f(x)=\\frac{1-x^2}{1+x^2}$，则 $f^{\\prime}(0)=\\left(\\quad\\right)$。',options:'A. $-1$　　　　 B. $-2$　　　　 C. $0$　　　　 D. $2$',answer:'$D$',analysis:'由商法则得 $f^{\\prime}(x)=\\frac{-4x}{(1+x^2)^2}$，代入 $x=0$，可得 $f^{\\prime}(0)=0$。'},
  {no:2,status:'success',text:'函数 $y=\\ln x$ 的定义域为 $\\left(\\quad\\right)$。',options:'A. $(-\\infty,+\\infty)$　 B. $(0,+\\infty)$　 C. $[0,+\\infty)$　 D. $(-\\infty,0)$',answer:'$B$',analysis:'对数函数 $y=\\ln x$ 要求 $x>0$，因此定义域为 $(0,+\\infty)$。'},
  {no:3,status:'warning',text:'若函数 $f(x)$ 在区间 $(a,b)$ 内可导，则 $f(x)$ 在该区间内 $\\left(\\quad\\right)$。',options:'A. 一定连续　　 B. 一定可积　　 C. 一定有界　　 D. 一定单调',answer:'$A$',analysis:'由可导与连续的关系可知：若 $f^{\\prime}(x)$ 存在，则 $f(x)$ 在对应点连续。'}
]
const defaultPreviewQuestions=structureQuestions.map((item)=>{
  const detail=detailedQuestions.find(question=>question.no===item.no)
  return detail
    ? {...detail,tags:[item.tag,'导数与微分']}
    : {no:item.no,status:item.no===16?'warning':'success',text:`设 $f_{${item.no}}(x)=x^{${item.no % 4 + 1}}+${item.no}$，请计算 $f_{${item.no}}^{\\prime}(x)$ 并选择正确答案。`,options:`A. $x^{${item.no % 4}}$　 B. $${item.no % 4 + 1}x^{${item.no % 4}}$　 C. $${item.no}x$　 D. $0$`,answer:'$B$',analysis:`根据幂函数求导公式 $\\frac{d}{dx}x^n=nx^{n-1}$，可得 $f_{${item.no}}^{\\prime}(x)=${item.no % 4 + 1}x^{${item.no % 4}}$。`,tags:[item.tag]}
})
if(!paperDraft.questions.length)paperDraft.questions=defaultPreviewQuestions
const previewQuestions=toRef(paperDraft,'questions')
const selectedStatus=ref('')
const selectedQuestionNo=ref<number|null>(null)
const questionPage=ref(1)
const questionPageSize=ref(3)
const statusFilters=[{label:'识别正确',value:'success'},{label:'疑似错误',value:'warning'},{label:'未识别',value:'unrecognized'}]
const filteredPreviewQuestions=computed(()=>previewQuestions.value.filter(question=>
  (!selectedStatus.value||question.status===selectedStatus.value)&&
  (!selectedQuestionNo.value||question.no===selectedQuestionNo.value)
))
const paginatedPreviewQuestions=computed(()=>{
  const start=(questionPage.value-1)*questionPageSize.value
  return filteredPreviewQuestions.value.slice(start,start+questionPageSize.value)
})
const editDialogVisible=ref(false)
const editingQuestionNo=ref<number|null>(null)
const editForm=reactive({text:'',answer:'',analysis:''})
const tagDialogVisible=ref(false)
const tagQuestionNo=ref<number|null>(null)
const newTagName=ref('')
const allPointTags=computed(()=>Array.from(new Set(previewQuestions.value.flatMap(question=>question.tags))))
const form=paperDraft.form
watch(allPointTags,(tags)=>{form.points=[...tags]},{immediate:true})
const confirmRows=computed(()=>[['试卷名称',form.name],['科目',form.subject],['来源',form.source],['年份',form.year ? `${form.year} 年` : '-'],['试卷类型',form.type],['所属教材',form.book],['考点分类',form.points.join('　')],['标签','考研真题　 近五年　等 1 个'],['试题总数','22 题（选择题 8 题，填空题 6 题，解答题 8 题）'],['导入文件','▣　2024考研数学（一）真题.docx　（2.45 MB）']])
const points=[['极限与连续',100],['导数与微分',80],['积分学',80],['常微分方程',60],['级数',40],['其他考点',80]]
function pickFile(){fileInput.value?.click()} function onFile(e:Event){fileName.value=(e.target as HTMLInputElement).files?.[0]?.name||''} function onDrop(e:DragEvent){fileName.value=e.dataTransfer?.files?.[0]?.name||''}
function go(n:number){
  const path=n===1?'/papers/import':`/papers/import/${['','parse','settings','confirm'][n-1]}`
  router.push({path,query:isEditMode.value?route.query:{}})
}
function next(){if(step.value===1&&!fileName.value) fileName.value='2024考研数学（一）真题.docx'; if(step.value<4) go(step.value+1); else {ElMessage.success(isEditMode.value?'试卷修改已保存':'试卷导入成功');router.push('/papers')}}
function renderLatex(text:string){
  return text.replace(/\$(.+?)\$/g,(_,formula:string)=>katex.renderToString(formula,{throwOnError:false,displayMode:false}))
}
function statusLabel(status:string){return status==='success'?'识别正确':status==='warning'?'疑似错误':'未识别'}
function statusCount(status:string){return previewQuestions.value.filter(question=>question.status===status).length}
function toggleStatusFilter(status:string){selectedStatus.value=selectedStatus.value===status?'':status;selectedQuestionNo.value=null;questionPage.value=1}
function selectStructureQuestion(no:number){selectedQuestionNo.value=selectedQuestionNo.value===no?null:no;selectedStatus.value='';questionPage.value=1}
function clearQuestionFilters(){selectedStatus.value='';selectedQuestionNo.value=null;questionPage.value=1}
function openEditDialog(question:any){editingQuestionNo.value=question.no;Object.assign(editForm,{text:question.text,answer:question.answer,analysis:question.analysis});editDialogVisible.value=true}
function saveQuestionEdit(){
  const question=previewQuestions.value.find(item=>item.no===editingQuestionNo.value)
  if(!question)return
  Object.assign(question,editForm)
  editDialogVisible.value=false
  ElMessage.success('题目修改已保存')
}
function openTagDialog(no:number){tagQuestionNo.value=no;newTagName.value='';tagDialogVisible.value=true}
function addQuestionTag(){
  const tag=newTagName.value.trim()
  const question=previewQuestions.value.find(item=>item.no===tagQuestionNo.value)
  if(!tag){ElMessage.warning('请输入标签名称');return}
  if(question&&!question.tags.includes(tag))question.tags.push(tag)
  tagDialogVisible.value=false
  ElMessage.success('标签添加成功')
}
function removeQuestionTag(no:number,tag:string){
  const question=previewQuestions.value.find(item=>item.no===no)
  if(question)question.tags=question.tags.filter(item=>item!==tag)
}
</script>

<style scoped lang="scss">
.paper-import{display:flex;flex-direction:column;gap:18px}.steps{height:104px;padding:20px 30px;display:grid;grid-template-columns:repeat(4,1fr)}.step{display:flex;align-items:center;position:relative;gap:14px}.step>span{width:42px;height:42px;border:1px solid #dce2f2;border-radius:50%;display:grid;place-items:center;font-size:17px;color:#59658d;z-index:1;background:white}.step.active>span{color:white;background:var(--primary);border-color:var(--primary)}.step.done>span{color:var(--primary);border-color:var(--primary)}.step strong{display:block;color:var(--ink);font-size:15px}.step p{margin:6px 0 0;color:var(--muted);font-size:12px}.step>i{position:absolute;height:1px;background:#dce2f2;width:35%;right:8%;top:32px}.step.done>i{background:var(--primary)}h2,h3,p{color:var(--ink)}h2{font-size:18px;margin:0 0 10px}.subtitle{margin:0 0 24px;color:var(--muted);font-size:13px}.upload-layout{display:grid;grid-template-columns:minmax(0,2fr) 440px;min-height:690px;padding:20px}.upload-layout main{padding:0 20px 0 0}.method-tabs{display:flex;gap:10px;border-bottom:1px solid var(--line)}.method-tabs button{padding:12px 20px;color:#637099;background:white;border:0;border-bottom:2px solid transparent}.method-tabs button.active{color:var(--primary);border-color:var(--primary)}.drop-zone{height:340px;margin:18px 0;border:1px dashed #bdc9e8;border-radius:8px;display:flex;flex-direction:column;align-items:center;justify-content:center;background:#fbfcff}.drop-zone input{display:none}.drop-zone strong{margin:14px 0 8px;color:var(--ink)}.drop-zone p{margin:4px;color:var(--muted);font-size:13px}.drop-zone .el-button{margin-top:24px}.folder-art{font-size:80px;color:#3158f4}.other-methods{display:grid;grid-template-columns:1fr 1fr;gap:16px}.other-methods button{height:92px;padding:18px;display:flex;align-items:center;gap:18px;text-align:left;background:#fff;border:1px solid var(--line);border-radius:8px;color:#22b77b;font-size:28px}.other-methods span{flex:1}.other-methods b,.other-methods small{display:block;color:var(--ink);font-size:14px}.other-methods small{margin-top:8px;color:var(--muted);font-weight:400}.tips{padding:28px;border:1px solid #cfdbff;border-radius:9px;background:#fbfcff}.tips h2{display:flex;align-items:center;gap:10px}.tips>div{display:flex;gap:18px;padding:22px 0;border-bottom:1px solid var(--line)}.tips>div>span{width:44px;height:44px;flex:none;display:grid;place-items:center;border-radius:9px;font-size:25px}.tips span.blue{color:#2858ff;background:#e9efff}.tips span.green{color:#12b879;background:#e5f8ef}.tips span.orange{color:#ff8b13;background:#fff0df}.tips span.purple{color:#8b55ed;background:#f1ebff}.tips strong{color:var(--ink)}.tips p{color:var(--muted);font-size:13px;line-height:1.8;margin:8px 0}.parse-layout{display:grid;grid-template-columns:300px minmax(520px,1fr) 360px;gap:16px;min-height:740px}.structure,.preview,.parse-side>section{padding:20px}.structure h3,.preview h2{margin-top:0}.structure small,.preview small{color:var(--muted);font-weight:400}.structure-group>strong{display:block;margin:18px 0 8px;font-size:13px}.structure-group p{display:grid;grid-template-columns:24px 60px 1fr 18px;align-items:center;gap:3px;margin:0;padding:6px 8px;font-size:11px}.structure-group p i,.structure-group p em{font-style:normal}.structure-group p em{padding:3px;background:#eaf7fb;color:#2388a1;border-radius:3px}.structure-group p .el-icon{color:#14af72}.preview>p{color:var(--muted);font-size:12px}.notice{display:flex;align-items:center;gap:8px;padding:8px 10px;color:#44517a;background:#f6f8ff;border:1px solid #cbd8ff;border-radius:5px;font-size:12px}.notice .el-button{margin-left:auto}.preview-head{display:flex;align-items:center;justify-content:space-between;margin-top:18px}.preview-head span{font-size:11px;color:var(--muted)}.preview-head i{display:inline-block;width:7px;height:7px;border-radius:50%}.green{background:#13ae73}.orange{background:#ff8a13}.gray{background:#8a91ad}.question-card{border:1px solid var(--line);border-radius:8px;margin-top:12px;padding:14px}.question-card header{display:flex;align-items:center;gap:8px}.question-card header>b{width:24px;height:24px;display:grid;place-items:center;color:white;border-radius:50%;background:#13ae73}.question-card header>b.warning{background:#ff850d}.question-card header i,.question-card header em,.question-card footer i{padding:3px 8px;font-size:11px;font-style:normal;border-radius:4px;background:#edf2ff;color:#3159e7}.question-card header em{background:#e6f8ef;color:#159b68}.question-card header button{margin-left:auto}.question-card header small.success{color:#15a86f}.question-card header small.warning{color:#f28000}.question-card>p,.options{font-size:12px;line-height:1.8}.question-card section{padding:10px;background:#f2faf6;font-size:11px}.question-card section strong,.question-card section b{display:block;color:#11a46c;margin-bottom:5px}.question-card section p{margin:0}.question-card footer{height:auto;min-height:32px;padding:8px 0 0;display:flex;gap:7px;justify-content:flex-start}.question-card footer button{font-size:11px}.parse-side{display:flex;flex-direction:column;gap:16px}.result>div{display:grid;grid-template-columns:repeat(4,1fr);text-align:center}.result span>*{display:block}.result b{color:#2d55f5}.result strong{margin:12px 0;font-size:22px}.result small{font-size:11px;color:var(--muted)}.detail>p{display:grid;grid-template-columns:1.2fr repeat(4,1fr);font-size:11px;text-align:center;border-bottom:1px solid var(--line);padding:10px 0;margin:0}.detail p:last-child{font-weight:800}.warm{background:#fbfcff}.warm p{font-size:12px;color:#627096;line-height:1.8}.settings{padding:30px;min-height:600px}.settings>p{color:var(--muted)}.settings-form{max-width:900px;margin-top:28px;display:grid;grid-template-columns:1fr 1fr;gap:22px}.settings-form label{display:flex;flex-direction:column;gap:9px;color:var(--ink);font-size:13px;font-weight:700}.settings-form .wide{grid-column:1/-1}.confirm-layout{display:grid;grid-template-columns:1.05fr 1fr;gap:20px}.confirm-layout main>p{color:var(--muted)}.info{padding:22px}.info dl{display:grid;grid-template-columns:130px 1fr;gap:17px;font-size:13px}.info dt{color:#435078}.info dd{margin:0;color:var(--ink)}.import-note{margin-top:24px;padding:18px;background:#f4f7ff;border-radius:7px}.import-note h3{display:flex;gap:8px}.import-note p{font-size:12px;color:#59668d}.overview{padding:24px}.overview header{display:flex;justify-content:space-between;border-bottom:1px solid var(--line)}.chart-row{display:flex;align-items:center;justify-content:space-around;padding:24px}.donut{width:150px;height:150px;border-radius:50%;background:conic-gradient(#3159ed 0 36%,#46b986 36% 64%,#ff9b35 64%);position:relative;display:grid;place-content:center;text-align:center}.donut:before{content:'';position:absolute;inset:20px;border-radius:50%;background:white}.donut strong,.donut small{z-index:1}.donut strong{font-size:24px}.chart-row li{list-style:none;margin:22px 0;font-size:13px}.chart-row li i{display:inline-block;width:8px;height:8px;border-radius:50%;margin-right:16px}.chart-row li i.blue{background:#3159ed}.chart-row li i.orange{background:#ff9b35}.chart-row li b{margin-left:30px}.point-bar{display:grid;grid-template-columns:110px 1fr 90px;align-items:center;gap:15px;margin:22px 0;font-size:13px}.point-bar>i{height:6px;background:#ebedf4;border-radius:5px}.point-bar i b{display:block;height:100%;background:#3159ed;border-radius:5px}.point-bar em{font-style:normal;color:#59668d}.page-actions{display:grid;grid-template-columns:auto 1fr auto auto;gap:16px;align-items:center;padding:0 0 8px}.page-actions .el-button{min-width:150px;height:42px}@media(max-width:1500px){.upload-layout{grid-template-columns:minmax(0,2fr) 360px}.parse-layout{grid-template-columns:260px minmax(480px,1fr) 310px}}
</style>

<style scoped lang="scss">
.page-actions {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr);
  gap: 22px;
  align-items: center;
  padding: 16px 20px;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: 9px;
  box-shadow: 0 8px 24px rgba(42, 61, 110, 0.035);
}

.secondary-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.page-actions .el-button {
  min-width: 112px;
  height: 44px;
  margin: 0;
  font-size: 15px;
  border-radius: 5px;
}

.page-actions .next-step-button {
  width: 100%;
  min-width: 0;
  font-weight: 600;
  box-shadow: 0 6px 14px rgba(31, 83, 255, 0.16);
}

.settings-form label > :deep(.el-date-editor) {
  width: 100%;
}

.confirm-layout {
  align-items: stretch;
}

.confirm-layout > .info,
.confirm-layout > .overview {
  height: 100%;
  min-height: 730px;
}

.confirm-layout > .info {
  display: flex;
  flex-direction: column;
  padding: 0;
  overflow: hidden;
}

.confirm-card-head {
  padding: 24px 26px 20px;
  background: linear-gradient(135deg, #f8faff, #fff);
  border-bottom: 1px solid var(--line);
}

.confirm-card-head h2 {
  margin: 0 0 8px;
}

.confirm-card-head p {
  margin: 0;
  color: var(--muted);
  font-size: 13px;
}

.paper-info-section {
  padding: 22px 26px 0;
}

.paper-info-section h3 {
  margin-top: 0;
}

.paper-info-section dl {
  display: grid;
  grid-template-columns: 130px 1fr;
  gap: 17px;
  font-size: 13px;
}

.paper-info-section dt {
  color: #435078;
}

.paper-info-section dd {
  margin: 0;
  color: var(--ink);
}

.confirm-layout .import-note {
  margin: auto 26px 24px;
}

.confirm-layout > .overview {
  padding: 24px 26px;
}

.confirm-layout > .overview > header {
  min-height: 45px;
  align-items: flex-start;
}

.point-category-select :deep(.el-select__wrapper) {
  min-height: 42px;
  height: auto;
  padding-top: 5px;
  padding-bottom: 5px;
}

.structure-group button {
  display: grid;
  width: 100%;
  grid-template-columns: 24px 60px 1fr 18px;
  align-items: center;
  gap: 3px;
  margin: 2px 0;
  padding: 6px 8px;
  color: var(--text);
  font-size: 11px;
  text-align: left;
  background: transparent;
  border: 1px solid transparent;
  border-radius: 5px;
}

.structure-group button:hover,
.structure-group button.active {
  color: var(--primary);
  background: var(--primary-soft);
  border-color: #cbd8ff;
}

.structure-group button i,
.structure-group button em {
  font-style: normal;
}

.structure-group button em {
  padding: 3px;
  color: #2388a1;
  background: #eaf7fb;
  border-radius: 3px;
}

.structure-group button .el-icon {
  color: #14af72;
}

.status-filters {
  display: flex;
  align-items: center;
  gap: 7px;
}

.status-filters button {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  height: 28px;
  padding: 0 9px;
  color: #637099;
  font-size: 11px;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: 14px;
}

.status-filters button i {
  width: 7px;
  height: 7px;
  border-radius: 50%;
}

.status-filters button.success i {
  background: #13ae73;
}

.status-filters button.warning i {
  background: #ff8a13;
}

.status-filters button.unrecognized i {
  background: #f05252;
}

.status-filters button.success.active {
  color: #0c9360;
  background: #eaf8f2;
  border-color: #a8e2ca;
}

.status-filters button.warning.active {
  color: #d66a00;
  background: #fff5e9;
  border-color: #ffd2a1;
}

.status-filters button.unrecognized.active {
  color: #d83c45;
  background: #fff0f1;
  border-color: #ffc2c6;
}

.status-filters .clear-filter {
  color: var(--primary);
  border-color: #cbd8ff;
}

.edit-question-button {
  margin-left: auto;
  color: var(--primary);
  background: #f5f8ff;
  border-color: #cbd8ff;
}

.edit-question-button:hover {
  color: #fff;
  background: var(--primary);
  border-color: var(--primary);
}

.question-card header > b.unrecognized {
  background: #f05252;
}

.question-card header small.unrecognized {
  color: #e0444d;
}

.question-card footer {
  align-items: center;
}

.add-tag-button {
  color: var(--primary);
  background: #f7f9ff;
  border-style: dashed;
  border-color: #b9c7ef;
}

.question-pagination {
  display: grid;
  grid-template-columns: 1fr 110px auto;
  align-items: center;
  gap: 14px;
  min-height: 58px;
  margin-top: 14px;
  padding: 0 4px;
  color: var(--muted);
  font-size: 12px;
  border-top: 1px solid var(--line);
}

.question-page-size {
  width: 110px;
}

.result-icon {
  display: grid !important;
  width: 38px;
  height: 38px;
  margin: 0 auto;
  place-items: center;
  font-size: 21px;
  border-radius: 10px;
}

.result-icon.total {
  color: #3159ed;
  background: #edf2ff;
}

.result-icon.success {
  color: #12a96d;
  background: #e7f8f0;
}

.result-icon.warning {
  color: #f1840b;
  background: #fff1df;
}

.result-icon.unrecognized {
  color: #e24b54;
  background: #ffedef;
}

/* 题目预览卡片：按高保真原型强化信息层级 */
.preview-head {
  min-height: 54px;
  margin-top: 20px;
}

.preview-head h3 {
  margin: 0;
  color: var(--ink);
  font-size: 20px;
  font-weight: 800;
}

.preview-head h3 small {
  margin-left: 8px;
  color: #7482a8;
  font-size: 16px;
}

.status-filters button {
  height: 36px;
  padding: 0 13px;
  font-size: 13px;
  border-radius: 19px;
}

.question-card {
  margin-top: 14px;
  padding: 22px 22px 18px;
  border-color: #dce4f5;
  border-radius: 11px;
  box-shadow: 0 5px 18px rgba(35, 63, 130, 0.025);
}

.question-card header {
  min-height: 36px;
  gap: 11px;
}

.question-card header > b {
  width: 36px;
  height: 36px;
  flex: 0 0 36px;
  font-size: 17px;
}

.question-card header > i,
.question-card header > em {
  padding: 6px 11px;
  font-size: 13px;
  border-radius: 5px;
}

.question-card header > small {
  font-size: 16px;
  font-weight: 500;
}

.edit-question-button {
  height: 36px;
  padding: 0 14px;
  font-size: 14px;
}

.question-card > p {
  margin: 22px 0 20px;
  color: #0d2057;
  font-size: 17px;
  line-height: 1.9;
}

.question-card > p :deep(.katex),
.question-card .options :deep(.katex),
.question-card section :deep(.katex) {
  font-size: 1.08em;
}

.question-card .options {
  margin-bottom: 8px;
  color: #0d2057;
  font-size: 16px;
  line-height: 2;
  word-spacing: 22px;
}

.question-card section {
  margin-top: 2px;
  padding: 14px 16px 15px;
  color: #193466;
  font-size: 14px;
  line-height: 1.8;
  background: #f1faf6;
  border-radius: 0;
}

.question-card section strong,
.question-card section b {
  margin-bottom: 5px;
  color: #0aad6c;
  font-size: 14px;
  font-weight: 700;
}

.question-card section strong span {
  margin-left: 5px;
}

.question-card section p {
  color: #193466;
  font-size: 14px;
}

.question-card footer {
  min-height: 48px;
  padding-top: 14px;
  color: #213969;
  font-size: 16px;
}

.question-card footer :deep(.el-tag) {
  height: 32px;
  padding: 0 11px;
  color: #2789ed;
  font-size: 13px;
  background: #eef6ff;
  border-color: #d4e7ff;
}

.add-tag-button {
  height: 32px;
  padding: 0 12px;
  font-size: 13px;
  background: #fff;
}

.question-pagination {
  margin-top: 18px;
}
</style>
