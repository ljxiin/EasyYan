<template>
  <section class="question-import">
    <div class="panel wizard">
      <div v-for="(step, index) in steps" :key="step.no" class="step" :class="{ done: step.no < currentStep, active: step.no === currentStep }">
        <span>{{ step.no < currentStep ? '✓' : step.no }}</span>
        <div>
          <strong>{{ step.title }}</strong>
          <p>{{ step.desc }}</p>
        </div>
        <i v-if="index < steps.length - 1"></i>
      </div>
    </div>

    <template v-if="currentStep === 1">
      <div class="panel import-shell">
        <main class="import-main">
          <h2>选择导入方式</h2>
          <p class="import-subtitle">请选择导入题目的方式，系统将自动识别题目结构并导入题目</p>

          <div class="import-tabs">
            <button type="button" :class="{ active: importMode === 'file' }" @click="importMode = 'file'">
              <el-icon><Promotion /></el-icon>
              推荐方式
            </button>
            <button type="button" :class="{ active: importMode === 'text' }" @click="importMode = 'text'">
              <el-icon><Document /></el-icon>
              粘贴文本
            </button>
          </div>

          <div
            v-if="importMode === 'file'"
            class="upload-box"
            :class="{ dragging: isDragging, selected: selectedFile }"
            @click="openFilePicker"
            @dragenter.prevent="isDragging = true"
            @dragover.prevent="isDragging = true"
            @dragleave.prevent="isDragging = false"
            @drop.prevent="handleFileDrop"
          >
            <input
              ref="fileInput"
              class="file-input"
              type="file"
              accept=".doc,.docx,.xls,.xlsx,.txt,.pdf,.jpg,.jpeg,.png"
              @change="handleFileChange"
            />
            <el-icon class="upload-folder"><FolderAdd /></el-icon>
            <template v-if="selectedFile || existingFileName">
              <strong>{{ selectedFile?.name || existingFileName }}</strong>
              <p>{{ selectedFile ? formatFileSize(selectedFile.size) : '原习题库文件' }} · 文件已选择</p>
              <div class="file-actions">
                <el-button type="primary" @click.stop="openFilePicker">重新选择</el-button>
                <el-button @click.stop="clearSelectedFile">移除文件</el-button>
              </div>
            </template>
            <template v-else>
              <strong>点击上传或拖拽文件到此处</strong>
              <p>支持 PDF、Word（.docx）、图片（JPG、PNG）等格式</p>
              <p>文件大小不超过 50MB</p>
              <el-button type="primary" plain :icon="Upload" @click.stop="openFilePicker">选择文件</el-button>
            </template>
          </div>

          <div v-else class="paste-panel">
            <el-input
              v-model="pastedQuestionText"
              type="textarea"
              :rows="13"
              placeholder="请粘贴题目、选项、答案和解析内容..."
            />
          </div>

          <h2 class="other-title">其他方式</h2>
          <div class="other-methods">
            <button type="button" @click="ElMessage.info('拍照/扫描导入功能准备中')">
              <el-icon><Camera /></el-icon>
              <span><strong>拍照/扫描导入</strong><small>使用手机拍照或扫描题目，支持多页自动识别</small></span>
              <el-icon class="method-arrow"><ArrowRight /></el-icon>
            </button>
            <button type="button" @click="ElMessage.info('链接导入功能准备中')">
              <el-icon><Link /></el-icon>
              <span><strong>从链接导入（题目来源链接）</strong><small>输入题目的网页链接，系统自动抓取内容</small></span>
              <el-icon class="method-arrow"><ArrowRight /></el-icon>
            </button>
          </div>
        </main>

        <aside class="import-tips">
          <h2><el-icon><InfoFilled /></el-icon>温馨提示</h2>
          <div v-for="item in importTips" :key="item.title" class="tip-item">
            <el-icon :class="`tip-${item.tone}`"><component :is="item.icon" /></el-icon>
            <div>
              <strong>{{ item.title }}</strong>
              <p>{{ item.text }}</p>
            </div>
          </div>
          <div class="help-item">
            <el-icon><QuestionFilled /></el-icon>
            <div>
              <strong>遇到问题？</strong>
              <p>查看帮助文档或联系客服，获取更多支持</p>
              <el-button type="primary" plain>查看帮助文档</el-button>
            </div>
          </div>
        </aside>
      </div>
      <div class="footer-actions">
        <el-button @click="go(isLibraryFlow ? '/questions' : '/questions/detail')">
          {{ isEditingLibrary ? '取消编辑' : '取消' }}
        </el-button>
        <el-button
          type="primary"
          :disabled="importMode === 'file' ? !selectedFile && !existingFileName : !pastedQuestionText.trim()"
          @click="go(stepPaths.parse)"
        >
          下一步
        </el-button>
      </div>
    </template>

    <template v-else-if="currentStep === 2">
      <div class="parse-grid">
        <main class="panel parse-main">
          <h2>预览与解析</h2>
          <p>系统已自动解析题目内容，您可以校对解析和答案，确认无误后进入下一步。</p>
          <div class="parse-toolbar">
            <el-checkbox
              :model-value="allVisibleParseSelected"
              :indeterminate="partiallyVisibleParseSelected"
              :disabled="!filteredParseQuestions.length"
              @change="toggleAllVisibleParseQuestions"
            >
              全选（已勾选 {{ selectedParseQuestionNos.length }} 题）
            </el-checkbox>
            <button
              v-for="status in parseStatuses"
              :key="status.value"
              type="button"
              class="status-filter"
              :class="[status.className, { active: selectedParseStatus === status.value }]"
              @click="toggleParseStatus(status.value)"
            >
              {{ status.label }}
            </button>
            <el-button
              class="batch-delete-button"
              :icon="Delete"
              :disabled="!selectedParseQuestionNos.length"
              @click="confirmBatchDeleteParseQuestions"
            >
              批量删除
            </el-button>
            <el-input
              v-model="parseSearchInput"
              class="parse-search"
              clearable
              placeholder="搜索题目或题目内容，按回车搜索"
              :prefix-icon="Search"
              @keyup.enter="applyParseSearch"
              @clear="clearParseSearch"
            />
          </div>

          <article v-for="item in paginatedParseQuestions" :key="item.no" class="parse-item">
            <div class="parse-content">
              <div class="parse-head">
                <el-checkbox
                  :model-value="selectedParseQuestionNos.includes(item.no)"
                  :aria-label="`选择第 ${item.no} 题`"
                  @change="(checked: string | number | boolean) => toggleParseQuestion(item.no, Boolean(checked))"
                />
                <span class="question-sequence" :class="`sequence-${item.statusType}`">{{ item.no }}</span>
                <span class="tag-soft">{{ item.tag }}</span>
                <span v-if="item.tags[0]" class="knowledge-chip">{{ item.tags[0] }}</span>
                <div class="parse-head-spacer"></div>
                <el-button :icon="EditPen" type="primary" plain @click="openEditDialog(item)">编辑</el-button>
                <span class="parse-status-text" :class="`parse-status-${item.statusType}`">{{ item.status }}</span>
              </div>
              <div class="parse-stem">
                <strong v-html="renderLatex(item.latexStem || item.stem)"></strong>
              </div>
              <div v-if="item.options" class="parse-options">
                <span v-for="option in item.options" :key="option" v-html="renderLatex(option)"></span>
              </div>
              <div class="answer-box">
                <p><strong>正确答案：</strong><span v-html="renderLatex(item.answer)"></span></p>
                <p>
                  <strong>解析：</strong>
                  <span v-html="renderLatex(item.latexAnalysis || item.analysis)"></span>
                </p>
              </div>
              <div class="tag-row">
                <strong>考点标签：</strong>
                <el-tag v-for="tag in item.tags" :key="tag" closable @close="removeParseTag(item.no, tag)">
                  {{ tag }}
                </el-tag>
                <el-button size="small" @click="openTagDialog(item.no)">+ 新增标签</el-button>
                <button type="button" class="trash" title="删除题目" @click="confirmDeleteParseQuestion(item.no)">
                  <el-icon><Delete /></el-icon>
                </button>
              </div>
            </div>
          </article>
          <el-empty v-if="!filteredParseQuestions.length" description="没有符合条件的题目" />
          <div class="parse-pagination">
            <span class="parse-total">共 256 题</span>
            <div class="parse-pager">
              <el-select model-value="3 条/页" class="parse-page-size">
                <el-option label="3 条/页" value="3 条/页" />
              </el-select>
              <el-pagination
                v-model:current-page="parseCurrentPage"
                layout="prev, pager, next"
                :total="filteredParseQuestions.length"
                :page-size="parsePageSize"
              />
            </div>
          </div>
        </main>

        <el-dialog v-model="tagDialogVisible" title="新增考点标签" width="420px">
          <el-input
            v-model="newTagName"
            maxlength="30"
            show-word-limit
            placeholder="请输入标签名称"
            @keyup.enter="addParseTag"
          />
          <template #footer>
            <el-button @click="tagDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="addParseTag">确认新增</el-button>
          </template>
        </el-dialog>

        <el-dialog v-model="editDialogVisible" title="编辑题目" width="760px">
          <el-form label-position="top">
            <el-form-item label="题目内容（支持 LaTeX，使用 $...$ 包裹公式）">
              <el-input v-model="editForm.latexStem" type="textarea" :rows="4" />
              <div class="latex-preview" v-html="renderLatex(editForm.latexStem)"></div>
            </el-form-item>
            <el-form-item v-if="isEditingChoiceQuestion" label="选项（支持 LaTeX）">
              <div class="option-editor-list">
                <div v-for="(_, index) in editForm.options" :key="index" class="option-editor">
                  <span>{{ optionLabels[index] }}</span>
                  <div>
                    <el-input
                      v-model="editForm.options[index]"
                      :placeholder="`请输入选项 ${optionLabels[index]}，公式使用 $...$ 包裹`"
                    />
                    <div class="option-latex-preview" v-html="renderLatex(editForm.options[index] || '')"></div>
                  </div>
                  <el-button
                    v-if="editForm.options.length > 2"
                    :icon="Delete"
                    circle
                    plain
                    title="删除选项"
                    @click="removeEditOption(index)"
                  />
                </div>
                <el-button
                  v-if="editForm.options.length < optionLabels.length"
                  class="add-option-button"
                  plain
                  @click="addEditOption"
                >
                  + 新增选项
                </el-button>
              </div>
            </el-form-item>
            <el-form-item label="正确答案">
              <el-input v-model="editForm.answer" type="textarea" :rows="2" />
              <div class="latex-preview" v-html="renderLatex(editForm.answer)"></div>
            </el-form-item>
            <el-form-item label="解析（支持 LaTeX）">
              <el-input v-model="editForm.latexAnalysis" type="textarea" :rows="5" />
              <div class="latex-preview" v-html="renderLatex(editForm.latexAnalysis)"></div>
            </el-form-item>
          </el-form>
          <template #footer>
            <el-button @click="editDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="saveParseQuestion">保存修改</el-button>
          </template>
        </el-dialog>

        <aside class="panel parse-aside">
          <h2>解析结果概览</h2>
          <div class="big-donut">
            <EChart :option="parseDonut" />
            <div><strong>256</strong><span>总题数</span></div>
          </div>
          <div class="parse-legend">
            <span><i class="green"></i>解析成功 248（96.9%）</span>
            <span><i class="orange"></i>待检查 8（3.1%）</span>
            <span><i class="red"></i>解析失败 0（0%）</span>
          </div>
          <h2>解析结构</h2>
          <ul class="check-list">
            <li>题型识别 <strong>256/256</strong></li>
            <li>题目内容识别 <strong>248/248</strong></li>
            <li>答案识别（单选/多选） <strong>118/118</strong></li>
            <li>答案识别（填空/简答） <strong>118/118</strong></li>
            <li>解析识别 <strong>86/86</strong></li>
          </ul>
          <h2>待检查项（8题） <a>查看详情</a></h2>
          <ul class="todo-list">
            <li>题型识别不确定：2 题</li>
            <li>答案识别不完整：3 题</li>
            <li>解析内容貌似不完整：3 题</li>
          </ul>
        </aside>
      </div>
      <div class="footer-actions">
        <el-button @click="go(stepPaths.start)">上一步</el-button>
        <el-button type="primary" @click="go(stepPaths.settings)">下一步：分类与设置</el-button>
      </div>
    </template>

    <template v-else-if="currentStep === 3">
      <div class="panel settings-shell">
        <div class="settings-title">
          <h2>分类与设置</h2>
          <p>{{ isLibraryFlow ? '设置习题库基本信息、题目分类和使用范围，确认后进入最后一步。' : '设置本次导入题目的归属、知识点、标签和导入规则，确认后进入最后一步。' }}</p>
        </div>

        <div class="settings-grid">
          <section v-if="isLibraryFlow">
            <h3>习题库信息</h3>
            <div class="form-grid">
              <label class="form-field wide">
                <span>习题库名称</span>
                <el-input v-model="libraryForm.name" placeholder="请输入习题库名称" />
              </label>
              <label class="form-field">
                <span>科目</span>
                <el-select v-model="libraryForm.subject">
                  <el-option label="高等数学" value="高等数学" />
                  <el-option label="线性代数" value="线性代数" />
                  <el-option label="概率论与数理统计" value="概率论与数理统计" />
                </el-select>
              </label>
              <label class="form-field">
                <span>来源</span>
                <el-select v-model="libraryForm.source">
                  <el-option label="教材配套" value="教材配套" />
                  <el-option label="教辅资料" value="教辅资料" />
                  <el-option label="真题汇编" value="真题汇编" />
                  <el-option label="自建题库" value="自建题库" />
                </el-select>
              </label>
              <label class="form-field">
                <span>默认难度</span>
                <el-select v-model="libraryForm.difficulty">
                  <el-option label="简单" value="简单" />
                  <el-option label="中等" value="中等" />
                  <el-option label="困难" value="困难" />
                </el-select>
              </label>
              <label class="form-field">
                <span>公开范围</span>
                <el-select v-model="libraryForm.visibility">
                  <el-option label="私有（仅自己可见）" value="私有（仅自己可见）" />
                  <el-option label="团队可见" value="团队可见" />
                  <el-option label="公开" value="公开" />
                </el-select>
              </label>
              <label class="form-field wide">
                <span>标签</span>
                <el-select
                  v-model="libraryForm.tags"
                  multiple
                  filterable
                  allow-create
                  default-first-option
                  placeholder="选择或输入标签"
                >
                  <el-option v-for="tag in libraryTagOptions" :key="tag" :label="tag" :value="tag" />
                </el-select>
              </label>
              <label class="form-field wide">
                <span>习题库简介</span>
                <el-input
                  v-model="libraryForm.description"
                  type="textarea"
                  :rows="4"
                  placeholder="请输入习题库简介"
                />
              </label>
            </div>
          </section>
          <section v-else>
            <h3>题目分类与属性</h3>
            <div class="form-grid">
              <label class="form-field">
                <span>所属题库</span>
                <el-select v-model="questionImportForm.library">
                  <el-option label="考研数学（数学一）" value="考研数学（数学一）" />
                  <el-option label="高等数学习题全解" value="高等数学习题全解" />
                  <el-option label="历年考研数学真题分类汇编" value="历年考研数学真题分类汇编" />
                </el-select>
              </label>
              <label class="form-field">
                <span>刷题科目</span>
                <el-select v-model="questionImportForm.subject">
                  <el-option label="高等数学" value="高等数学" />
                  <el-option label="线性代数" value="线性代数" />
                  <el-option label="概率统计" value="概率统计" />
                </el-select>
              </label>
              <label class="form-field">
                <span>章节</span>
                <el-select v-model="questionImportForm.chapter">
                  <el-option label="第一章 函数、极限、连续" value="第一章 函数、极限、连续" />
                  <el-option label="第二章 一元函数微分学" value="第二章 一元函数微分学" />
                  <el-option label="第三章 一元函数积分学" value="第三章 一元函数积分学" />
                </el-select>
              </label>
              <label class="form-field">
                <span>知识点</span>
                <el-select v-model="questionImportForm.knowledge">
                  <el-option label="导数的定义与计算" value="导数的定义与计算" />
                  <el-option label="基本初等函数的导数" value="基本初等函数的导数" />
                  <el-option label="复合函数求导法则" value="复合函数求导法则" />
                  <el-option label="可导与连续的关系" value="可导与连续的关系" />
                </el-select>
              </label>
              <label class="form-field">
                <span>小节</span>
                <el-input v-model="questionImportForm.section" placeholder="可选，例如 1.1 函数" />
              </label>
              <label class="form-field">
                <span>题目难度</span>
                <el-select v-model="questionImportForm.difficulty">
                  <el-option label="不设置" value="不设置" />
                  <el-option label="简单" value="简单" />
                  <el-option label="中等" value="中等" />
                  <el-option label="困难" value="困难" />
                </el-select>
              </label>
              <label class="form-field">
                <span>题目来源</span>
                <el-select v-model="questionImportForm.source">
                  <el-option label="未设置" value="未设置" />
                  <el-option label="教材配套" value="教材配套" />
                  <el-option label="教辅资料" value="教辅资料" />
                  <el-option label="真题汇编" value="真题汇编" />
                  <el-option label="自建导入" value="自建导入" />
                </el-select>
              </label>
              <label class="form-field">
                <span>公开范围</span>
                <el-select v-model="questionImportForm.visibility">
                  <el-option label="私有（仅自己可见）" value="私有（仅自己可见）" />
                  <el-option label="团队可见" value="团队可见" />
                  <el-option label="公开" value="公开" />
                </el-select>
              </label>
              <label class="form-field wide">
                <span>标签</span>
                <el-select
                  v-model="questionImportForm.tags"
                  multiple
                  filterable
                  allow-create
                  default-first-option
                  placeholder="选择或输入标签"
                >
                  <el-option v-for="tag in questionTagOptions" :key="tag" :label="tag" :value="tag" />
                </el-select>
              </label>
            </div>
          </section>

          <aside class="setting-summary">
            <h3>导入设置</h3>
            <div class="summary-row"><span>识别题目</span><strong>256 题</strong></div>
            <div class="summary-row"><span>解析成功</span><strong class="success">248 题</strong></div>
            <div class="summary-row"><span>待检查</span><strong class="warning">8 题</strong></div>
            <template v-if="isLibraryFlow">
              <el-checkbox v-model="libraryForm.deduplicate">导入时自动去重</el-checkbox>
              <el-checkbox v-model="libraryForm.keepAnalysis">保留题目答案与解析</el-checkbox>
            </template>
            <template v-else>
              <el-checkbox v-model="questionImportForm.deduplicate">导入时自动去重</el-checkbox>
              <el-checkbox v-model="questionImportForm.keepAnalysis">保留题目答案与解析</el-checkbox>
            </template>
          </aside>
        </div>
      </div>
      <div class="footer-actions">
        <el-button @click="go(stepPaths.parse)">上一步：预览与解析</el-button>
        <el-button type="primary" @click="go(stepPaths.confirm)">
          {{ isLibraryFlow ? '下一步：确认创建' : '下一步：确认导入' }}
        </el-button>
      </div>
    </template>

    <template v-else>
      <div class="confirm-grid">
        <main class="panel confirm-main">
          <h2>{{ isLibraryFlow ? '确认创建习题库' : '确认导入' }}</h2>
          <p>请确认以下导入信息，确认无误后将{{ isLibraryFlow ? '创建习题库' : '导入题库' }}</p>
          <section class="overview panel">
            <h3>导入内容概览</h3>
            <div class="overview-stats">
              <div v-for="item in overviewStats" :key="item.label">
                <el-icon :style="{ color: item.color, backgroundColor: `${item.color}18` }"><component :is="item.icon" /></el-icon>
                <strong>{{ item.value }}</strong>
                <span>{{ item.label }}</span>
              </div>
            </div>
          </section>

          <section class="setting-list">
            <h3>分类与属性</h3>
            <div v-for="item in settingRows" :key="item.label" class="setting-row">
              <span>{{ item.label }}</span>
              <strong>{{ item.value }}</strong>
            </div>
          </section>

          <div class="tip-box">
            <strong>温馨提示</strong>
            <p>共 256 题，其中 248 题解析成功，8 题待检查，0 题解析失败。</p>
            <p>待检查的题目导入后将加入“待处理”列表，您可以在“错题集 - 待处理”中进行检查和完善。</p>
            <p>导入完成后，您可以在题库中进行查看和管理。</p>
          </div>
        </main>

        <aside class="confirm-aside">
          <section class="panel side-card">
            <h2>导入题型分布</h2>
            <div class="type-chart">
              <EChart :option="typePieOption" />
              <div class="type-chart-center">
                <span>总题数</span>
                <strong>256</strong>
              </div>
            </div>
            <div class="type-legend">
              <span><i class="blue"></i>单选题 118 题（46.1%）</span>
              <span><i class="green"></i>填空题 68 题（26.6%）</span>
              <span><i class="orange"></i>判断题 36 题（14.1%）</span>
              <span><i class="violet"></i>计算题 24 题（9.4%）</span>
              <span><i class="gray"></i>其他 10 题（3.8%）</span>
            </div>
          </section>
          <section class="panel side-card">
            <h2>考点分布（Top 5）</h2>
            <div v-for="item in pointRows" :key="item.name" class="point-row">
              <span>{{ item.name }}</span>
              <el-progress :percentage="item.percent" :show-text="false" />
              <em>{{ item.count }} 题（{{ item.percent }}%）</em>
            </div>
          </section>
          <section class="panel side-card">
            <h2>题目预览（前 3 题）</h2>
            <div v-for="item in previewRows" :key="item.no" class="preview-row">
              <span>{{ item.no }}</span>
              <p v-html="renderLatex(item.latexText)"></p>
              <el-tag class="preview-type-tag" effect="light">{{ item.type }}</el-tag>
            </div>
            <button type="button" class="all-link" @click="go(stepPaths.parse)">查看全部 256 题 〉</button>
          </section>
        </aside>
      </div>
      <div class="footer-actions">
        <el-button @click="go(stepPaths.settings)">上一步：分类与设置</el-button>
        <div></div>
        <el-button @click="go(isLibraryFlow ? '/questions' : '/questions/detail')">
          {{ isEditingLibrary ? '取消编辑' : isLibraryFlow ? '取消创建' : '取消导入' }}
        </el-button>
        <el-button type="primary" @click="finishFlow">
          {{ isEditingLibrary ? '保存修改' : isLibraryFlow ? '确认创建' : '确认导入' }}
        </el-button>
      </div>
    </template>
  </section>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useRoute, useRouter } from 'vue-router'
import type { EChartsOption } from 'echarts'
import katex from 'katex'
import {
  ArrowRight,
  Camera,
  CircleCheck,
  CircleCheckFilled,
  Delete,
  Document,
  EditPen,
  Files,
  FolderAdd,
  InfoFilled,
  Link,
  List,
  Picture,
  Promotion,
  QuestionFilled,
  Search,
  Upload,
  View,
  Warning
} from '@element-plus/icons-vue'
import EChart from '@/components/EChart.vue'
import { parseQuestions, typePieOption } from '@/mock/questions'
import { useQuestionLibraryStore } from '@/stores/questionLibrary'

type ParseStatus = '' | '解析成功' | '待检查' | '解析失败'
type ParseQuestion = {
  no: number
  tag: string
  status: Exclude<ParseStatus, ''>
  statusType: string
  stem: string
  latexStem: string
  options: string[]
  answer: string
  analysis: string
  latexAnalysis: string
  tags: string[]
}

const route = useRoute()
const router = useRouter()
const libraryStore = useQuestionLibraryStore()
const requestedLibraryId = Number(route.query.libraryId)
if (route.query.mode === 'edit' && Number.isFinite(requestedLibraryId) && libraryStore.editingId !== requestedLibraryId) {
  const requestedLibrary = libraryStore.libraries.find((item) => item.id === requestedLibraryId)
  if (requestedLibrary) libraryStore.startEdit(requestedLibrary)
}
const currentStep = computed(() => Number(route.meta.step || 1))
const isLibraryFlow = computed(() => route.meta.flow === 'library')
const isEditingLibrary = computed(() => isLibraryFlow.value && libraryStore.mode === 'edit')
const existingFileName = computed(() => (isEditingLibrary.value ? libraryStore.fileName : ''))
const flowQuery = computed(() =>
  isEditingLibrary.value && libraryStore.editingId !== null
    ? { mode: 'edit', libraryId: String(libraryStore.editingId) }
    : {}
)
const stepPaths = computed(() => {
  const base = isLibraryFlow.value ? '/questions/create' : '/questions/import'
  return {
    start: base,
    parse: `${base}/parse`,
    settings: `${base}/settings`,
    confirm: `${base}/confirm`
  }
})

function go(path: string) {
  router.push({ path, query: path.startsWith('/questions/create') ? flowQuery.value : {} })
}

const fileInput = ref<HTMLInputElement | null>(null)
const selectedFile = ref<File | null>(null)
const isDragging = ref(false)
const importMode = ref<'file' | 'text'>('file')
const pastedQuestionText = ref('')
const allowedExtensions = new Set(['doc', 'docx', 'xls', 'xlsx', 'txt', 'pdf', 'jpg', 'jpeg', 'png'])
const maxFileSize = 50 * 1024 * 1024
const localParseQuestions = ref<ParseQuestion[]>(
  parseQuestions.map((item) => ({
    ...item,
    status: item.status as Exclude<ParseStatus, ''>,
    latexStem: item.latexStem ?? item.stem,
    options: item.options ? [...item.options] : [],
    latexAnalysis: item.latexAnalysis ?? item.analysis,
    tags: [...item.tags]
  }))
)
const selectedParseStatus = ref<ParseStatus>('')
const parseSearchInput = ref('')
const parseSearchKeyword = ref('')
const parseCurrentPage = ref(1)
const parsePageSize = 3
const selectedParseQuestionNos = ref<number[]>(localParseQuestions.value.map((item) => item.no))
const tagDialogVisible = ref(false)
const tagTargetNo = ref<number | null>(null)
const newTagName = ref('')
const editDialogVisible = ref(false)
const editForm = reactive({
  no: 0,
  tag: '',
  latexStem: '',
  options: [] as string[],
  answer: '',
  latexAnalysis: ''
})
const optionLabels = ['A', 'B', 'C', 'D', 'E', 'F']
const isEditingChoiceQuestion = computed(
  () => editForm.tag.includes('选择题') || editForm.tag === '单选题' || editForm.tag === '多选题'
)

const parseStatuses: Array<{ value: Exclude<ParseStatus, ''>; label: string; className: string }> = [
  { value: '解析成功', label: '解析成功 248', className: 'status-success' },
  { value: '待检查', label: '待检查 8', className: 'status-warning' },
  { value: '解析失败', label: '解析失败 0', className: 'status-danger' }
]

const filteredParseQuestions = computed(() => {
  const keyword = parseSearchKeyword.value.trim().toLowerCase()
  return localParseQuestions.value.filter((item) => {
    const matchesStatus = !selectedParseStatus.value || item.status === selectedParseStatus.value
    const searchable = [
      item.no,
      item.tag,
      item.stem,
      item.latexStem,
      item.answer,
      item.analysis,
      item.latexAnalysis,
      item.options.join(' '),
      item.tags.join(' ')
    ]
      .join(' ')
      .toLowerCase()
    return matchesStatus && (!keyword || searchable.includes(keyword))
  })
})
const paginatedParseQuestions = computed(() => {
  const start = (parseCurrentPage.value - 1) * parsePageSize
  return filteredParseQuestions.value.slice(start, start + parsePageSize)
})
const visibleParseQuestionNos = computed(() => paginatedParseQuestions.value.map((item) => item.no))
const selectedVisibleParseCount = computed(
  () => visibleParseQuestionNos.value.filter((no) => selectedParseQuestionNos.value.includes(no)).length
)
const allVisibleParseSelected = computed(
  () =>
    visibleParseQuestionNos.value.length > 0 &&
    selectedVisibleParseCount.value === visibleParseQuestionNos.value.length
)
const partiallyVisibleParseSelected = computed(
  () => selectedVisibleParseCount.value > 0 && selectedVisibleParseCount.value < visibleParseQuestionNos.value.length
)

function openFilePicker() {
  fileInput.value?.click()
}

function handleFileChange(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (file) selectFile(file)
}

function handleFileDrop(event: DragEvent) {
  isDragging.value = false
  const file = event.dataTransfer?.files?.[0]
  if (file) selectFile(file)
}

function selectFile(file: File) {
  const extension = file.name.split('.').pop()?.toLowerCase() ?? ''
  if (!allowedExtensions.has(extension)) {
    ElMessage.error('文件格式不支持，请选择 PDF、Word、Excel、TXT 或图片文件')
    resetFileInput()
    return
  }
  if (file.size > maxFileSize) {
    ElMessage.error('文件大小不能超过 50MB')
    resetFileInput()
    return
  }
  selectedFile.value = file
  ElMessage.success(`已选择文件：${file.name}`)
}

function clearSelectedFile() {
  selectedFile.value = null
  if (isEditingLibrary.value) libraryStore.fileName = ''
  resetFileInput()
}

function resetFileInput() {
  if (fileInput.value) fileInput.value.value = ''
}

function formatFileSize(size: number) {
  if (size < 1024) return `${size} B`
  if (size < 1024 * 1024) return `${(size / 1024).toFixed(1)} KB`
  return `${(size / 1024 / 1024).toFixed(1)} MB`
}

function renderLatex(text: string) {
  return text.replace(/\$(.+?)\$/g, (_, formula: string) =>
    katex.renderToString(formula, {
      throwOnError: false,
      displayMode: false
    })
  )
}

function toggleParseStatus(status: Exclude<ParseStatus, ''>) {
  selectedParseStatus.value = selectedParseStatus.value === status ? '' : status
  parseCurrentPage.value = 1
}

function applyParseSearch() {
  parseSearchKeyword.value = parseSearchInput.value
  parseCurrentPage.value = 1
}

function clearParseSearch() {
  parseSearchInput.value = ''
  parseSearchKeyword.value = ''
  parseCurrentPage.value = 1
}

function toggleParseQuestion(no: number, checked: boolean) {
  if (checked) {
    selectedParseQuestionNos.value = Array.from(new Set([...selectedParseQuestionNos.value, no]))
    return
  }
  selectedParseQuestionNos.value = selectedParseQuestionNos.value.filter((item) => item !== no)
}

function toggleAllVisibleParseQuestions(checked: string | number | boolean) {
  const visibleNos = visibleParseQuestionNos.value
  if (Boolean(checked)) {
    selectedParseQuestionNos.value = Array.from(new Set([...selectedParseQuestionNos.value, ...visibleNos]))
    return
  }
  selectedParseQuestionNos.value = selectedParseQuestionNos.value.filter((no) => !visibleNos.includes(no))
}

async function confirmBatchDeleteParseQuestions() {
  const selectedNos = [...selectedParseQuestionNos.value]
  if (!selectedNos.length) {
    ElMessage.warning('请先勾选要删除的题目')
    return
  }
  try {
    await ElMessageBox.confirm(
      `确认删除已勾选的 ${selectedNos.length} 道题目及其答案和解析吗？删除后不可恢复。`,
      '批量删除题目',
      {
        confirmButtonText: '确认删除',
        cancelButtonText: '取消',
        type: 'warning',
        confirmButtonClass: 'el-button--danger'
      }
    )
    localParseQuestions.value = localParseQuestions.value.filter((item) => !selectedNos.includes(item.no))
    selectedParseQuestionNos.value = []
    parseCurrentPage.value = 1
    ElMessage.success(`已删除 ${selectedNos.length} 道题目`)
  } catch {
    ElMessage.info('已取消删除')
  }
}

function openTagDialog(no: number) {
  tagTargetNo.value = no
  newTagName.value = ''
  tagDialogVisible.value = true
}

function addParseTag() {
  const tag = newTagName.value.trim()
  const item = localParseQuestions.value.find((question) => question.no === tagTargetNo.value)
  if (!tag) {
    ElMessage.warning('请输入标签名称')
    return
  }
  if (!item) return
  if (item.tags.includes(tag)) {
    ElMessage.warning('该标签已存在')
    return
  }
  item.tags.push(tag)
  tagDialogVisible.value = false
  ElMessage.success('标签添加成功')
}

function removeParseTag(no: number, tag: string) {
  const item = localParseQuestions.value.find((question) => question.no === no)
  if (!item) return
  item.tags = item.tags.filter((itemTag) => itemTag !== tag)
}

function openEditDialog(item: ParseQuestion) {
  editForm.no = item.no
  editForm.tag = item.tag
  editForm.latexStem = item.latexStem
  editForm.options = item.options.map((option) => option.replace(/^[A-F][.、]\s*/i, ''))
  editForm.answer = item.answer
  editForm.latexAnalysis = item.latexAnalysis
  editDialogVisible.value = true
}

function addEditOption() {
  if (editForm.options.length >= optionLabels.length) return
  editForm.options.push('')
}

function removeEditOption(index: number) {
  editForm.options.splice(index, 1)
}

function saveParseQuestion() {
  const item = localParseQuestions.value.find((question) => question.no === editForm.no)
  if (!item) return
  if (!editForm.latexStem.trim() || !editForm.answer.trim() || !editForm.latexAnalysis.trim()) {
    ElMessage.warning('题目、正确答案和解析不能为空')
    return
  }
  if (isEditingChoiceQuestion.value && editForm.options.some((option) => !option.trim())) {
    ElMessage.warning('选择题的选项不能为空')
    return
  }
  item.latexStem = editForm.latexStem.trim()
  item.options = isEditingChoiceQuestion.value
    ? editForm.options.map((option, index) => `${optionLabels[index]}. ${option.trim()}`)
    : []
  item.answer = editForm.answer.trim()
  item.latexAnalysis = editForm.latexAnalysis.trim()
  editDialogVisible.value = false
  ElMessage.success('题目修改已保存')
}

async function confirmDeleteParseQuestion(no: number) {
  try {
    await ElMessageBox.confirm(`确认删除第 ${no} 题及其答案和解析吗？删除后不可恢复。`, '删除题目', {
      confirmButtonText: '确认删除',
      cancelButtonText: '取消',
      type: 'warning',
      confirmButtonClass: 'el-button--danger'
    })
    localParseQuestions.value = localParseQuestions.value.filter((item) => item.no !== no)
    selectedParseQuestionNos.value = selectedParseQuestionNos.value.filter((item) => item !== no)
    const lastPage = Math.max(1, Math.ceil(filteredParseQuestions.value.length / parsePageSize))
    parseCurrentPage.value = Math.min(parseCurrentPage.value, lastPage)
    ElMessage.success(`已删除第 ${no} 题`)
  } catch {
    ElMessage.info('已取消删除')
  }
}

const steps = computed(() => [
  {
    no: 1,
    title: '选择导入方式',
    desc: currentStep.value === 1 ? '选择文件或粘贴文本' : selectedFile.value?.name || '高数习题集.docx'
  },
  { no: 2, title: '预览与解析', desc: currentStep.value > 2 ? '共识别 256 题' : '检查解析结果和题目' },
  { no: 3, title: '分类与设置', desc: currentStep.value > 3 ? '已设置分类和属性' : '设置题目分类和属性' },
  { no: 4, title: '确认导入', desc: isLibraryFlow.value ? '确认并创建习题库' : '确认并完成导入' }
])

const libraryTagOptions = ['考研', '基础题', '同步练习', '专题训练', '真题', '提高题']
const questionTagOptions = ['基础题', '同步练习', '考研真题', '易错题', '重点题', '导数与微分']
const libraryForm = libraryStore.form
const questionImportForm = reactive({
  library: '考研数学（数学一）',
  subject: '高等数学',
  chapter: '第一章 函数、极限、连续',
  knowledge: '导数的定义与计算',
  section: '1.1 函数',
  difficulty: '不设置',
  source: '未设置',
  visibility: '私有（仅自己可见）',
  tags: ['基础题', '同步练习'] as string[],
  deduplicate: true,
  keepAnalysis: true
})

function finishFlow() {
  if (isLibraryFlow.value) {
    libraryStore.save(selectedFile.value?.name)
  }
  ElMessage.success(isEditingLibrary.value ? '习题库修改已保存' : isLibraryFlow.value ? '习题库创建成功' : '题目导入成功')
  router.push(isLibraryFlow.value ? '/questions' : '/questions/detail')
}

const importTips = [
  {
    title: '支持多种格式',
    text: '支持 PDF、Word（.docx）、图片（JPG、PNG）格式，文件大小不超过 50MB',
    icon: Document,
    tone: 'blue'
  },
  {
    title: '保证图片清晰',
    text: '图片文件请确保清晰、无倾斜，建议分辨率不低于 300dpi',
    icon: Camera,
    tone: 'green'
  },
  {
    title: '复杂排版识别',
    text: '题目中请尽量避免使用特殊字体和复杂排版，建议使用常规字体和标准格式',
    icon: Picture,
    tone: 'orange'
  },
  {
    title: '导入完成后',
    text: '您可以在习题库详情页进行编辑和完善，确认无误后再使用题目',
    icon: CircleCheck,
    tone: 'purple'
  }
]

const parseDonut: EChartsOption = {
  series: [
    {
      type: 'pie',
      radius: ['62%', '82%'],
      label: { show: false },
      data: [
        { value: 248, itemStyle: { color: '#18b979' } },
        { value: 8, itemStyle: { color: '#ff9b21' } },
        { value: 0, itemStyle: { color: '#ff5b63' } }
      ]
    }
  ]
}

const overviewStats = [
  { label: '总题数', value: 256, color: '#1f53ff', icon: Document },
  { label: '解析成功', value: 248, color: '#18b979', icon: CircleCheckFilled },
  { label: '待检查', value: 8, color: '#ff9b21', icon: Warning },
  { label: '解析失败', value: 0, color: '#ff5b63', icon: Warning }
]

const settingRows = computed(() =>
  isLibraryFlow.value
    ? [
        { label: '习题库名称', value: libraryForm.name },
        { label: '科目', value: libraryForm.subject },
        { label: '来源', value: libraryForm.source },
        { label: '默认难度', value: libraryForm.difficulty },
        { label: '公开范围', value: libraryForm.visibility },
        { label: '标签', value: libraryForm.tags.join('、') || '未设置' },
        { label: '习题库简介', value: libraryForm.description || '未设置' },
        { label: '导入后去重', value: libraryForm.deduplicate ? '开启' : '关闭' },
        { label: '保留答案与解析', value: libraryForm.keepAnalysis ? '开启' : '关闭' }
      ]
    : [
        { label: '所属题库', value: questionImportForm.library },
        { label: '刷题科目', value: questionImportForm.subject },
        { label: '章节', value: questionImportForm.chapter },
        { label: '知识点', value: questionImportForm.knowledge },
        { label: '小节', value: questionImportForm.section || '未设置小节' },
        { label: '题目难度', value: questionImportForm.difficulty },
        { label: '题目来源', value: questionImportForm.source },
        { label: '公开范围', value: questionImportForm.visibility },
        { label: '标签', value: questionImportForm.tags.join('、') || '未设置' },
        {
          label: '导入后去重',
          value: questionImportForm.deduplicate ? '开启（自动去重，已存在的题目将被自动跳过）' : '关闭'
        },
        { label: '保留答案与解析', value: questionImportForm.keepAnalysis ? '开启' : '关闭' }
      ]
)

const pointRows = [
  { name: '1. 导数的定义与计算', count: 128, percent: 50 },
  { name: '2. 基本初等函数的导数', count: 74, percent: 28.9 },
  { name: '3. 复合函数求导法则', count: 46, percent: 18 },
  { name: '4. 可导与连续的关系', count: 32, percent: 12.5 },
  { name: '5. 极限的运算法则', count: 28, percent: 10.9 }
]

const previewRows = [
  {
    no: 1,
    latexText: '设函数 $f(x)=\\frac{1}{1+x^2}$，则 $f^{\\prime}(0)=\\left(\\quad\\right)$。',
    type: '单选题'
  },
  {
    no: 2,
    latexText: '函数 $f(x)=\\sqrt{x+1}$ 在 $x=3$ 处的导数为 ________。',
    type: '填空题'
  },
  {
    no: 3,
    latexText: '若函数 $f(x)$ 在区间 $(a,b)$ 内可导，则 $f(x)$ 在该区间内...',
    type: '判断题'
  }
]
</script>

<style scoped lang="scss">
.question-import {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.wizard {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  padding: 24px 36px;
}

.step {
  position: relative;
  display: flex;
  align-items: center;
  gap: 14px;
}

.step span {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  color: var(--text);
  font-weight: 900;
  border: 1px solid #c9d2ea;
  border-radius: 50%;
}

.step.active span,
.step.done span {
  color: #fff;
  background: var(--primary);
  border-color: var(--primary);
}

.step strong {
  display: block;
  color: var(--ink);
  font-size: 16px;
}

.step p {
  margin: 6px 0 0;
  color: var(--muted);
}

.step i {
  position: absolute;
  right: 28px;
  width: 96px;
  height: 1px;
  background: #cbd5f4;
}

.import-shell {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 360px;
  gap: 24px;
  min-height: 720px;
  padding: 26px;
}

.parse-main,
.parse-aside,
.confirm-main,
.side-card {
  padding: 28px;
}

.import-main {
  min-width: 0;
}

h2,
h3 {
  margin: 0;
  color: var(--ink);
}

h2 {
  font-size: 20px;
}

h3 {
  font-size: 16px;
}

.import-subtitle {
  margin: 10px 0 26px;
  color: var(--muted);
}

.import-tabs {
  display: flex;
  gap: 8px;
  height: 46px;
  margin-bottom: 20px;
  border-bottom: 1px solid var(--line);
}

.import-tabs button {
  position: relative;
  display: inline-flex;
  gap: 6px;
  align-items: center;
  height: 46px;
  padding: 0 16px;
  color: var(--muted);
  font: inherit;
  font-weight: 700;
  background: transparent;
  border: 0;
}

.import-tabs button.active {
  color: var(--primary);
}

.import-tabs button.active::after {
  position: absolute;
  right: 0;
  bottom: -1px;
  left: 0;
  height: 2px;
  content: '';
  background: var(--primary);
}

.upload-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 350px;
  padding: 32px;
  color: var(--muted);
  text-align: center;
  background: #fbfcff;
  border: 1px dashed #b8c6f2;
  border-radius: 8px;
  cursor: pointer;
  transition: 0.18s ease;
}

.upload-box:hover,
.upload-box.dragging {
  background: var(--primary-soft);
  border-color: var(--primary);
}

.upload-box.selected {
  background: #f5fbf8;
  border-color: var(--green);
}

.file-input {
  display: none;
}

.upload-box .el-icon {
  color: var(--primary);
  font-size: 64px;
}

.upload-box strong {
  margin-top: 24px;
  color: var(--ink);
  font-size: 17px;
}

.upload-box p {
  margin: 10px 0 0;
  line-height: 1.5;
}

.upload-box .el-button {
  margin-top: 18px;
}

.file-actions {
  display: flex;
  gap: 12px;
  margin-top: 10px;
}

.paste-panel {
  min-height: 350px;
  padding: 20px;
  background: #fbfcff;
  border: 1px solid var(--line);
  border-radius: 8px;
}

.other-title {
  margin-top: 26px;
}

.other-methods {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 16px;
  margin-top: 16px;
}

.other-methods button {
  display: flex;
  gap: 16px;
  align-items: center;
  min-height: 88px;
  padding: 18px;
  color: var(--green);
  text-align: left;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: 8px;
  transition: 0.16s ease;
}

.other-methods button:hover {
  border-color: #a9ddc8;
  box-shadow: 0 8px 18px rgba(24, 185, 121, 0.08);
}

.other-methods button > .el-icon {
  flex: 0 0 30px;
  font-size: 28px;
}

.other-methods button span {
  display: flex;
  flex: 1;
  flex-direction: column;
  gap: 7px;
}

.other-methods strong {
  color: var(--ink);
}

.other-methods small {
  color: var(--muted);
  font-size: 13px;
  line-height: 1.5;
}

.other-methods .method-arrow {
  flex-basis: 20px;
  font-size: 20px;
}

.import-tips {
  align-self: stretch;
  padding: 24px;
  background: #fafbff;
  border: 1px solid #cbd7fa;
  border-radius: 8px;
}

.import-tips h2 {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-bottom: 10px;
}

.tip-item,
.help-item {
  display: flex;
  gap: 16px;
  padding: 24px 0;
  border-bottom: 1px solid var(--line);
}

.tip-item > .el-icon {
  display: inline-flex;
  flex: 0 0 42px;
  align-items: center;
  justify-content: center;
  width: 42px;
  height: 42px;
  font-size: 22px;
  border-radius: 8px;
}

.tip-blue {
  color: var(--primary);
  background: #eaf0ff;
}

.tip-green {
  color: var(--green);
  background: #e7f8f0;
}

.tip-orange {
  color: var(--orange);
  background: #fff0df;
}

.tip-purple {
  color: #8e5bff;
  background: #f1eaff;
}

.tip-item strong,
.help-item strong {
  color: var(--ink);
}

.tip-item p,
.help-item p {
  margin: 8px 0 0;
  color: var(--muted);
  line-height: 1.7;
}

.help-item {
  border-bottom: 0;
}

.help-item > .el-icon {
  flex: 0 0 28px;
  color: var(--ink);
  font-size: 26px;
}

.help-item .el-button {
  margin-top: 12px;
}

.footer-actions {
  display: grid;
  grid-template-columns: auto 1fr auto auto;
  gap: 16px;
  align-items: center;
  padding: 14px 16px;
  background: #fff;
  border: 1px solid var(--line);
  border-radius: 8px;
}

.settings-shell {
  min-height: 610px;
  padding: 28px;
}

.settings-title {
  padding-bottom: 22px;
  border-bottom: 1px solid var(--line);
}

.settings-title p {
  margin: 8px 0 0;
  color: var(--muted);
}

.settings-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 320px;
  gap: 28px;
  padding-top: 24px;
}

.settings-grid section,
.setting-summary {
  padding: 24px;
  border: 1px solid var(--line);
  border-radius: 8px;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 22px;
  margin-top: 22px;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 9px;
  color: var(--ink);
  font-size: 14px;
  font-weight: 700;
}

.form-field.wide {
  grid-column: 1 / -1;
}

.form-field :deep(.el-select) {
  width: 100%;
}

.setting-summary {
  align-self: start;
  background: #fbfcff;
}

.setting-summary h3 {
  margin-bottom: 18px;
}

.summary-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 48px;
  border-bottom: 1px solid var(--line);
}

.summary-row span {
  color: var(--muted);
}

.summary-row strong {
  color: var(--ink);
}

.setting-summary > .el-checkbox {
  display: flex;
  margin: 20px 0 0;
}

.parse-grid,
.confirm-grid {
  display: grid;
  grid-template-columns: 1fr 390px;
  gap: 16px;
}

.parse-main > p,
.confirm-main > p {
  color: var(--muted);
}

.parse-toolbar {
  display: grid;
  grid-template-columns: auto repeat(4, max-content);
  gap: 12px;
  align-items: center;
  margin: 16px 0;
}

.parse-toolbar > .el-checkbox,
.status-filter,
.batch-delete-button {
  white-space: nowrap;
}

.batch-delete-button:not(:disabled) {
  color: var(--red);
  border-color: rgba(255, 91, 99, 0.42);
}

.batch-delete-button:not(:disabled):hover {
  color: #fff;
  background: var(--red);
  border-color: var(--red);
}

.status-filter {
  height: 34px;
  padding: 0 14px;
  font: inherit;
  font-size: 13px;
  font-weight: 750;
  background: #fff;
  border: 1px solid;
  border-radius: 7px;
  transition: 0.16s ease;
}

.status-success {
  color: #079b61;
  border-color: #aee6cf;
  background: #effbf6;
}

.status-warning {
  color: #e57a00;
  border-color: #ffd19b;
  background: #fff7eb;
}

.status-danger {
  color: #e93f51;
  border-color: #ffc1c8;
  background: #fff1f3;
}

.status-filter:hover,
.status-filter.active {
  color: #fff;
}

.status-success:hover,
.status-success.active {
  background: #10ad72;
  border-color: #10ad72;
}

.status-warning:hover,
.status-warning.active {
  background: #f28a10;
  border-color: #f28a10;
}

.status-danger:hover,
.status-danger.active {
  background: #ef4b5d;
  border-color: #ef4b5d;
}

.parse-search {
  grid-column: 1 / -1;
  width: 100%;
}

.parse-item {
  border: 1px solid var(--line);
  border-radius: 8px;
  margin-bottom: 14px;
  background: #fff;
  transition: border-color 0.16s ease, box-shadow 0.16s ease;
}

.parse-item:hover {
  border-color: #c8d4f6;
  box-shadow: 0 8px 22px rgba(40, 68, 140, 0.06);
}

.parse-content {
  padding: 20px 22px;
}

.parse-head {
  display: flex;
  align-items: center;
  gap: 10px;
}

.parse-head-spacer {
  flex: 1;
}

.knowledge-chip {
  display: inline-flex;
  align-items: center;
  height: 26px;
  padding: 0 10px;
  color: #079b61;
  font-size: 13px;
  font-weight: 750;
  background: #e9f8f1;
  border-radius: 5px;
}

.question-sequence {
  display: inline-flex;
  flex: 0 0 38px;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  color: #fff;
  font-size: 18px;
  font-weight: 850;
  border-radius: 50%;
}

.sequence-success {
  background: #12ad72;
}

.sequence-warning {
  background: #f28a10;
}

.sequence-danger {
  background: #ef4b5d;
}

.parse-status-text {
  min-width: 68px;
  font-size: 14px;
  font-weight: 800;
  text-align: right;
}

.parse-status-success {
  color: #079b61;
}

.parse-status-warning {
  color: #e57a00;
}

.parse-status-danger {
  color: #e93f51;
}

.parse-stem {
  margin-top: 18px;
  color: var(--ink);
  font-size: 16px;
  line-height: 1.8;
}

.parse-options {
  display: flex;
  flex-wrap: wrap;
  gap: 20px 56px;
  margin: 18px 0 10px;
  color: var(--ink);
  font-weight: 700;
}

.answer-box {
  margin-top: 18px;
  padding: 14px 18px;
  color: var(--ink);
  background: #f2fbf7;
  border-radius: 0;
}

.answer-box p {
  margin: 4px 0;
  line-height: 1.8;
}

.answer-box strong {
  color: var(--green);
}

.tag-row {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  align-items: center;
  margin-top: 16px;
  color: var(--ink);
}

.tag-row > strong {
  font-size: 16px;
}

.tag-row :deep(.el-tag) {
  color: #2581dc;
  background: #eef6ff;
  border-color: #d4e8ff;
}

.trash {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 30px;
  height: 30px;
  margin-left: auto;
  padding: 0;
  color: var(--muted);
  background: transparent;
  border: 0;
  border-radius: 6px;
}

.trash:hover {
  color: var(--red);
  background: rgba(255, 91, 99, 0.1);
}

.latex-preview,
.option-latex-preview {
  width: 100%;
  margin-top: 8px;
  padding: 10px 12px;
  overflow-x: auto;
  color: var(--ink);
  line-height: 1.8;
  background: #f7f9fe;
  border: 1px solid var(--line);
  border-radius: 6px;
}

.latex-preview:empty,
.option-latex-preview:empty {
  display: none;
}

.option-editor-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
}

.option-editor {
  display: grid;
  grid-template-columns: 34px minmax(0, 1fr) 34px;
  gap: 10px;
  align-items: start;
}

.option-editor > span {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  color: var(--primary);
  font-weight: 850;
  background: var(--primary-soft);
  border-radius: 6px;
}

.option-latex-preview {
  min-height: 40px;
  margin-top: 6px;
}

.add-option-button {
  align-self: flex-start;
  margin-left: 44px;
}

.parse-aside h2,
.side-card h2 {
  margin-bottom: 18px;
  font-size: 18px;
}

.big-donut,
.type-chart {
  position: relative;
  width: 150px;
  height: 150px;
  margin: 0 auto 16px;
}

.type-chart-center {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}

.type-chart-center span {
  color: var(--muted);
  font-size: 12px;
}

.type-chart-center strong {
  margin-top: 4px;
  color: var(--ink);
  font-size: 26px;
}

.big-donut > div:last-child {
  position: absolute;
  inset: 0;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  pointer-events: none;
}

.big-donut strong {
  color: var(--ink);
  font-size: 28px;
}

.parse-legend,
.type-legend {
  display: flex;
  flex-direction: column;
  gap: 14px;
  color: var(--text);
}

.parse-legend i,
.type-legend i {
  display: inline-block;
  width: 8px;
  height: 8px;
  margin-right: 10px;
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

.blue {
  background: var(--primary);
}

.violet {
  background: var(--violet);
}

.gray {
  background: #b9c0d2;
}

.check-list,
.todo-list {
  padding: 0;
  list-style: none;
}

.check-list li {
  display: flex;
  justify-content: space-between;
  margin: 22px 0;
  color: var(--text);
}

.todo-list li {
  margin: 14px 0;
  color: var(--text);
}

.parse-pagination {
  display: flex;
  align-items: center;
  justify-content: space-between;
  min-height: 54px;
  padding-top: 10px;
}

.parse-total {
  white-space: nowrap;
}

.parse-pager {
  display: flex;
  align-items: center;
  gap: 12px;
}

.parse-page-size {
  width: 98px;
}

.confirm-main {
  min-height: 720px;
}

.overview {
  margin-top: 24px;
  padding: 22px;
}

.overview-stats {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  margin-top: 22px;
}

.overview-stats div {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  border-right: 1px solid var(--line);
}

.overview-stats div:last-child {
  border-right: 0;
}

.overview-stats .el-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
}

.overview-stats strong {
  color: var(--ink);
  font-size: 28px;
}

.overview-stats span {
  color: var(--muted);
}

.setting-list {
  margin-top: 28px;
}

.setting-row {
  display: grid;
  grid-template-columns: 120px 1fr 100px;
  padding: 13px 0;
  border-bottom: 1px solid var(--line);
}

.setting-row span {
  color: var(--muted);
}

.setting-row strong {
  color: var(--text);
}

.setting-row a,
.parse-aside a,
.all-link {
  display: block;
  margin-left: auto;
  padding: 0;
  color: var(--primary);
  font-weight: 700;
  background: transparent;
  border: 0;
}

.tip-box {
  margin-top: 18px;
  padding: 16px;
  color: var(--text);
  background: #f4f8ff;
  border: 1px solid #bcd0ff;
  border-radius: 7px;
}

.confirm-aside {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.point-row {
  display: grid;
  grid-template-columns: 140px 1fr 128px;
  gap: 14px;
  align-items: center;
  margin: 16px 0;
  color: var(--text);
}

.point-row em {
  color: var(--muted);
  font-style: normal;
}

.preview-row {
  display: grid;
  grid-template-columns: 26px 1fr 64px;
  gap: 10px;
  align-items: center;
  color: var(--text);
}

.preview-row span {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px;
  height: 24px;
  background: #f0f3fb;
  border-radius: 5px;
}

.preview-row :deep(.preview-type-tag) {
  justify-self: end;
  height: 30px;
  padding: 0 12px;
  color: #155bff;
  font-size: 14px;
  font-weight: 750;
  background: #edf3ff;
  border-color: transparent;
  border-radius: 6px;
}
</style>
