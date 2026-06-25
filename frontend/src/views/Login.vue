<template>
  <main class="login-page">
    <header class="login-header">
      <RouterLink to="/login" class="brand">
        <span class="brand-mark">EY</span>
        <strong>EasyYan</strong>
      </RouterLink>
      <el-button class="help-button" :icon="Headset">帮助中心</el-button>
    </header>

    <section class="login-shell">
      <div class="hero-panel">
        <div class="hero-copy">
          <h1><span>智能学习</span> · 高效备研</h1>
          <p>EasyYan 助你科学规划、高效学习、精准提分</p>
        </div>

        <div class="feature-list">
          <article v-for="feature in features" :key="feature.title" class="feature-item">
            <span class="feature-icon" :style="{ color: feature.color, backgroundColor: feature.bg }">
              <component :is="feature.icon" />
            </span>
            <div>
              <strong>{{ feature.title }}</strong>
              <p>{{ feature.description }}</p>
            </div>
          </article>
        </div>

        <div class="learning-visual" aria-hidden="true">
          <div class="floating-card chart-card left-card">
            <span></span>
            <i></i>
            <b></b>
          </div>
          <div class="floating-card chart-card right-card">
            <span></span>
            <i></i>
            <b></b>
          </div>
          <div class="knowledge-board">
            <span v-for="dot in 11" :key="dot" class="node" :class="`node-${dot}`"></span>
            <i class="line line-1"></i>
            <i class="line line-2"></i>
            <i class="line line-3"></i>
            <i class="line line-4"></i>
          </div>
          <div class="platform">
            <span class="platform-top"></span>
            <span class="platform-mid"></span>
            <span class="platform-bottom"></span>
          </div>
        </div>
      </div>

      <section class="auth-card">
        <Transition name="fade" mode="out-in">
          <form v-if="mode === 'login'" key="login" class="auth-form" @submit.prevent="handleLogin">
            <div class="auth-heading">
              <h2>欢迎登录 <span>EasyYan</span></h2>
              <p>登录后开启您的高效学习之旅</p>
            </div>

            <label class="field">
              <el-icon><User /></el-icon>
              <input v-model.trim="loginForm.account" type="text" placeholder="请输入用户名 / 邮箱" autocomplete="username" />
            </label>
            <label class="field">
              <el-icon><Lock /></el-icon>
              <input
                v-model.trim="loginForm.password"
                :type="showPassword ? 'text' : 'password'"
                placeholder="请输入密码"
                autocomplete="current-password"
              />
              <button class="icon-button" type="button" :aria-label="showPassword ? '隐藏密码' : '显示密码'" @click="showPassword = !showPassword">
                <el-icon><View v-if="showPassword" /><Hide v-else /></el-icon>
              </button>
            </label>

            <div class="form-options">
              <el-checkbox v-model="rememberMe">记住我</el-checkbox>
              <button type="button" class="text-button" @click="startForgot">忘记密码?</button>
            </div>

            <el-button class="primary-action" type="primary" native-type="submit">登录</el-button>
          </form>

          <form v-else key="forgot" class="auth-form forgot-form" @submit.prevent="handleForgotNext">
            <button type="button" class="back-button" @click="returnToLogin">
              <el-icon><ArrowLeft /></el-icon>
              返回登录
            </button>
            <div class="auth-heading compact-heading">
              <h2>找回密码</h2>
              <p>{{ forgotSubtitle }}</p>
            </div>

            <el-steps class="reset-steps" :active="forgotStep" finish-status="success" align-center>
              <el-step title="账号" />
              <el-step title="验证" />
              <el-step title="重置" />
            </el-steps>

            <div v-if="forgotStep === 0" class="step-content">
              <label class="field">
                <el-icon><Message /></el-icon>
                <input v-model.trim="forgotForm.account" type="text" placeholder="请输入注册邮箱 / 手机号" autocomplete="username" />
              </label>
            </div>

            <div v-else-if="forgotStep === 1" class="step-content">
              <label class="field code-field">
                <el-icon><Key /></el-icon>
                <input v-model.trim="forgotForm.code" type="text" maxlength="6" placeholder="请输入验证码" />
                <button type="button" class="send-code" :disabled="countdown > 0" @click="sendCode">
                  {{ countdown > 0 ? `${countdown}s` : '获取验证码' }}
                </button>
              </label>
            </div>

            <div v-else class="step-content">
              <label class="field">
                <el-icon><Lock /></el-icon>
                <input v-model.trim="forgotForm.password" type="password" placeholder="请输入新密码" autocomplete="new-password" />
              </label>
              <label class="field">
                <el-icon><Lock /></el-icon>
                <input v-model.trim="forgotForm.confirmPassword" type="password" placeholder="请再次输入新密码" autocomplete="new-password" />
              </label>
            </div>

            <el-button class="primary-action" type="primary" native-type="submit">
              {{ forgotStep === 2 ? '完成重置' : '下一步' }}
            </el-button>
          </form>
        </Transition>
      </section>
    </section>

    <footer class="login-footer">
      <span>© 2024 EasyYan. All rights reserved.</span>
      <a>用户协议</a>
      <i></i>
      <a>隐私政策</a>
    </footer>
  </main>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import {
  ArrowLeft,
  Connection,
  Document,
  Headset,
  Hide,
  Key,
  Lock,
  Message,
  Promotion,
  TrendCharts,
  User,
  View
} from '@element-plus/icons-vue'

const router = useRouter()
const mode = ref<'login' | 'forgot'>('login')
const showPassword = ref(false)
const rememberMe = ref(true)
const forgotStep = ref(0)
const countdown = ref(0)
let countdownTimer: number | undefined

const loginForm = reactive({
  account: '',
  password: ''
})

const forgotForm = reactive({
  account: '',
  code: '',
  password: '',
  confirmPassword: ''
})

const features = [
  { title: '知识网络', description: '构建知识点关联网络，掌握学科脉络', icon: Connection, color: '#1f53ff', bg: '#e9f0ff' },
  { title: '智能组卷', description: '个性化组卷，精准匹配学习需求', icon: Document, color: '#8e5bff', bg: '#f0e8ff' },
  { title: '学习分析', description: '多维数据分析，学习情况一目了然', icon: TrendCharts, color: '#18b979', bg: '#e7f9f1' },
  { title: '错题管理', description: '自动归类错题，强化薄弱知识点', icon: Promotion, color: '#ff9b21', bg: '#fff2dc' }
]

const forgotSubtitle = computed(() => {
  if (forgotStep.value === 0) return '请输入注册账号，我们将向你发送验证信息'
  if (forgotStep.value === 1) return '请输入收到的验证码完成身份验证'
  return '设置一个新的登录密码'
})

function handleLogin() {
  if (!loginForm.account || !loginForm.password) {
    ElMessage.warning('请输入用户名和密码')
    return
  }
  ElMessage.success('登录成功')
  router.push('/')
}

function startForgot() {
  mode.value = 'forgot'
  forgotStep.value = 0
}

function returnToLogin() {
  mode.value = 'login'
  forgotStep.value = 0
}

function handleForgotNext() {
  if (forgotStep.value === 0) {
    if (!forgotForm.account) {
      ElMessage.warning('请输入注册邮箱或手机号')
      return
    }
    sendCode()
    forgotStep.value = 1
    return
  }

  if (forgotStep.value === 1) {
    if (!forgotForm.code || forgotForm.code.length < 4) {
      ElMessage.warning('请输入正确的验证码')
      return
    }
    forgotStep.value = 2
    return
  }

  if (!forgotForm.password || forgotForm.password.length < 6) {
    ElMessage.warning('新密码至少需要 6 位')
    return
  }
  if (forgotForm.password !== forgotForm.confirmPassword) {
    ElMessage.warning('两次输入的密码不一致')
    return
  }
  ElMessage.success('密码重置成功，请重新登录')
  returnToLogin()
}

function sendCode() {
  if (countdown.value > 0) return
  countdown.value = 60
  window.clearInterval(countdownTimer)
  countdownTimer = window.setInterval(() => {
    countdown.value -= 1
    if (countdown.value <= 0) {
      window.clearInterval(countdownTimer)
    }
  }, 1000)
}
</script>

<style scoped lang="scss">
.login-page {
  position: relative;
  min-height: 100vh;
  overflow: hidden;
  color: #18275d;
  background:
    radial-gradient(circle at 17% 75%, rgba(31, 83, 255, 0.13), transparent 23%),
    radial-gradient(circle at 88% 13%, rgba(108, 156, 255, 0.16), transparent 26%),
    linear-gradient(132deg, #f9fbff 0%, #f1f6ff 46%, #ffffff 100%);
}

.login-page::before,
.login-page::after {
  position: absolute;
  border-radius: 999px;
  content: '';
  filter: blur(3px);
}

.login-page::before {
  top: 118px;
  left: 214px;
  width: 26px;
  height: 26px;
  background: rgba(31, 83, 255, 0.16);
}

.login-page::after {
  right: 360px;
  bottom: 190px;
  width: 42px;
  height: 42px;
  background: rgba(31, 83, 255, 0.18);
}

.login-header {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 96px;
  padding: 0 64px;
}

.brand {
  display: inline-flex;
  align-items: center;
  gap: 14px;
  color: #07164a;
}

.brand-mark {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  color: #fff;
  font-size: 20px;
  font-weight: 850;
  background: linear-gradient(135deg, #2d73ff 0%, #0751eb 100%);
  border-radius: 8px;
  box-shadow: 0 12px 22px rgba(31, 83, 255, 0.25);
}

.brand strong {
  font-size: 27px;
  font-weight: 900;
}

.help-button {
  height: 42px;
  padding: 0 18px;
  color: #18275d;
  font-weight: 750;
  background: rgba(255, 255, 255, 0.74);
  border-color: #dfe6f6;
  border-radius: 10px;
}

.login-shell {
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-columns: minmax(540px, 650px) minmax(540px, 1fr);
  align-items: center;
  gap: 92px;
  min-height: calc(100vh - 184px);
  padding: 18px 13.6vw 70px 11vw;
}

.hero-panel {
  min-height: 690px;
}

.hero-copy h1 {
  margin: 0;
  color: #07164a;
  font-size: 42px;
  font-weight: 900;
  letter-spacing: 0;
}

.hero-copy h1 span,
.auth-heading h2 span {
  color: #0b62ff;
}

.hero-copy p {
  margin: 16px 0 44px;
  color: #6675a2;
  font-size: 20px;
  font-weight: 650;
}

.feature-list {
  width: 430px;
  padding: 16px 18px;
  background: linear-gradient(90deg, rgba(255, 255, 255, 0.92), rgba(255, 255, 255, 0.34));
  border-radius: 8px;
  box-shadow: 0 24px 70px rgba(55, 73, 125, 0.08);
}

.feature-item {
  display: flex;
  align-items: center;
  gap: 18px;
  min-height: 82px;
}

.feature-icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 58px;
  height: 58px;
  flex: none;
  border-radius: 11px;
  font-size: 30px;
}

.feature-item strong {
  color: #07164a;
  font-size: 17px;
  font-weight: 850;
}

.feature-item p {
  margin: 8px 0 0;
  color: #6675a2;
  font-size: 14px;
  font-weight: 650;
}

.learning-visual {
  position: relative;
  width: 620px;
  height: 330px;
  margin: -4px 0 0 -58px;
}

.platform {
  position: absolute;
  left: 205px;
  bottom: 24px;
  width: 300px;
  height: 110px;
  transform: perspective(640px) rotateX(58deg) rotateZ(-1deg);
}

.platform span {
  position: absolute;
  left: 0;
  width: 100%;
  height: 62px;
  border-radius: 24px;
  box-shadow: 0 22px 36px rgba(31, 83, 255, 0.24);
}

.platform-top {
  bottom: 56px;
  background: linear-gradient(145deg, #ffffff, #d7e6ff);
}

.platform-mid {
  bottom: 24px;
  background: linear-gradient(145deg, #9dc2ff, #2d73ff);
}

.platform-bottom {
  bottom: 0;
  background: linear-gradient(145deg, #6ca2ff, #0751eb);
}

.knowledge-board {
  position: absolute;
  left: 226px;
  bottom: 116px;
  width: 260px;
  height: 170px;
  background: rgba(255, 255, 255, 0.34);
  border: 1px solid rgba(140, 170, 235, 0.42);
  border-radius: 14px;
  box-shadow: 0 22px 58px rgba(31, 83, 255, 0.14);
  backdrop-filter: blur(12px);
}

.node,
.line {
  position: absolute;
  background: #1f64ff;
  box-shadow: 0 0 14px rgba(31, 100, 255, 0.56);
}

.node {
  width: 12px;
  height: 12px;
  border: 3px solid #a8c4ff;
  border-radius: 50%;
}

.node-1 { left: 118px; top: 22px; }
.node-2 { left: 72px; top: 72px; }
.node-3 { left: 126px; top: 88px; }
.node-4 { left: 182px; top: 64px; }
.node-5 { left: 212px; top: 112px; }
.node-6 { left: 96px; top: 130px; }
.node-7 { left: 152px; top: 134px; }
.node-8 { left: 42px; top: 112px; }
.node-9 { left: 204px; top: 28px; }
.node-10 { left: 18px; top: 58px; }
.node-11 {
  left: 121px;
  top: 77px;
  width: 28px;
  height: 28px;
  border-width: 6px;
  background: #c5d9ff;
}

.line {
  height: 2px;
  opacity: 0.45;
  transform-origin: left center;
}

.line-1 { left: 84px; top: 82px; width: 132px; transform: rotate(-19deg); }
.line-2 { left: 52px; top: 120px; width: 162px; transform: rotate(1deg); }
.line-3 { left: 132px; top: 38px; width: 82px; transform: rotate(30deg); }
.line-4 { left: 132px; top: 101px; width: 74px; transform: rotate(47deg); }

.floating-card {
  position: absolute;
  width: 142px;
  height: 104px;
  background: rgba(255, 255, 255, 0.48);
  border: 1px solid rgba(143, 173, 236, 0.38);
  border-radius: 14px;
  box-shadow: 0 18px 46px rgba(31, 83, 255, 0.13);
  backdrop-filter: blur(10px);
}

.left-card {
  left: 116px;
  bottom: 118px;
  transform: rotate(-7deg);
}

.right-card {
  right: 8px;
  bottom: 98px;
  transform: rotate(7deg);
}

.chart-card span,
.chart-card i,
.chart-card b {
  position: absolute;
  bottom: 18px;
  width: 12px;
  border-radius: 8px 8px 0 0;
  background: #2d73ff;
}

.chart-card span { left: 36px; height: 36px; }
.chart-card i { left: 58px; height: 54px; }
.chart-card b { left: 80px; height: 28px; }

.auth-card {
  width: 100%;
  max-width: 760px;
  min-height: 680px;
  padding: 74px 56px;
  background: rgba(255, 255, 255, 0.84);
  border: 1px solid rgba(255, 255, 255, 0.92);
  border-radius: 18px;
  box-shadow: 0 34px 92px rgba(44, 61, 105, 0.12);
  backdrop-filter: blur(18px);
}

.auth-form {
  display: flex;
  flex-direction: column;
  gap: 28px;
  max-width: 646px;
  margin: 0 auto;
}

.auth-heading {
  margin-bottom: 28px;
}

.compact-heading {
  margin-bottom: 4px;
}

.auth-heading h2 {
  margin: 0;
  color: #07164a;
  font-size: 31px;
  font-weight: 900;
}

.auth-heading p {
  margin: 14px 0 0;
  color: #6675a2;
  font-size: 18px;
  font-weight: 650;
}

.field {
  display: flex;
  align-items: center;
  gap: 16px;
  height: 70px;
  padding: 0 22px;
  color: #7280a6;
  background: rgba(255, 255, 255, 0.72);
  border: 1px solid #dce4f5;
  border-radius: 8px;
  transition: 0.18s ease;
}

.field:focus-within {
  border-color: #1f64ff;
  box-shadow: 0 0 0 4px rgba(31, 100, 255, 0.08);
}

.field .el-icon {
  flex: none;
  font-size: 24px;
}

.field input {
  width: 100%;
  min-width: 0;
  color: #07164a;
  font: inherit;
  font-size: 17px;
  font-weight: 650;
  background: transparent;
  border: 0;
  outline: 0;
}

.field input::placeholder {
  color: #8b97bc;
}

.icon-button,
.text-button,
.back-button,
.send-code {
  padding: 0;
  font: inherit;
  background: transparent;
  border: 0;
}

.icon-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: #64719d;
  font-size: 22px;
}

.form-options {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 2px;
}

.text-button {
  color: #0b62ff;
  font-size: 16px;
  font-weight: 800;
}

.primary-action {
  width: 100%;
  height: 66px;
  margin-top: 8px;
  font-size: 18px;
  font-weight: 850;
  border: 0;
  border-radius: 8px;
  background: linear-gradient(180deg, #176dff 0%, #0751eb 100%);
  box-shadow: 0 12px 26px rgba(20, 91, 244, 0.26);
}

.forgot-form {
  gap: 24px;
}

.back-button {
  align-self: flex-start;
  display: inline-flex;
  align-items: center;
  gap: 7px;
  color: #6675a2;
  font-size: 15px;
  font-weight: 760;
}

.reset-steps {
  margin: 2px 0 12px;
}

.step-content {
  display: flex;
  flex-direction: column;
  gap: 18px;
  min-height: 158px;
}

.code-field {
  padding-right: 16px;
}

.send-code {
  flex: none;
  min-width: 94px;
  height: 38px;
  color: #0b62ff;
  font-size: 15px;
  font-weight: 800;
}

.send-code:disabled {
  color: #9aa6c7;
}

.login-footer {
  position: absolute;
  right: 0;
  bottom: 30px;
  left: 0;
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 24px;
  color: #7480a6;
  font-size: 15px;
  font-weight: 650;
}

.login-footer a {
  color: #0b62ff;
  font-weight: 760;
}

.login-footer i {
  width: 1px;
  height: 14px;
  background: #cfd7ea;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.18s ease, transform 0.18s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: translateY(8px);
}

:deep(.el-checkbox__label) {
  color: #4f5d88;
  font-size: 16px;
  font-weight: 650;
}

:deep(.el-step__title) {
  font-size: 14px;
  font-weight: 760;
}

@media (max-width: 1360px) {
  .login-shell {
    gap: 48px;
    padding-right: 6vw;
    padding-left: 6vw;
  }

  .learning-visual {
    transform: scale(0.88);
    transform-origin: left top;
  }
}
</style>
