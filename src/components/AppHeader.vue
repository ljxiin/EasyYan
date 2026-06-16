<template>
  <header class="header">
    <h1>{{ title }}</h1>
    <div class="header-actions">
      <div class="search">
        <el-icon><Search /></el-icon>
        <span>搜索题目、考点、教材等...</span>
        <kbd>⌘ K</kbd>
      </div>
      <el-badge :value="12" class="notice">
        <el-icon><Bell /></el-icon>
      </el-badge>
      <el-icon class="mail"><Message /></el-icon>
      <div class="user">
        <el-avatar :size="32" src="" />
        <strong>奔跑的数学人</strong>
        <span>Lv.5</span>
      </div>
    </div>
  </header>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { Bell, Message, Search } from '@element-plus/icons-vue'

const route = useRoute()
const title = computed(() => route.meta.title || '首页 / 学习概览')
</script>

<style scoped lang="scss">
.header {
  display: flex;
  align-items: center;
  height: 70px;
  padding: 0 28px;
  background: var(--surface);
  border-bottom: 1px solid var(--line);
}

h1 {
  flex: 1;
  margin: 0;
  color: var(--ink);
  font-size: 20px;
  font-weight: 800;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 18px;
}

.search {
  display: flex;
  align-items: center;
  gap: 8px;
  width: 360px;
  height: 38px;
  padding: 0 12px;
  color: var(--muted);
  font-size: 14px;
  border: 1px solid var(--line);
  border-radius: 20px;
}

.search span {
  flex: 1;
}

kbd {
  padding: 2px 7px;
  color: var(--muted);
  font-family: inherit;
  font-size: 12px;
  background: #f1f4fb;
  border-radius: 6px;
}

.notice,
.mail {
  color: var(--text);
  font-size: 22px;
}

.user {
  display: flex;
  align-items: center;
  gap: 10px;
  color: var(--ink);
  font-size: 13px;
}

.user span {
  padding: 2px 7px;
  color: #fff;
  font-size: 11px;
  background: var(--primary);
  border-radius: 10px;
}
</style>
