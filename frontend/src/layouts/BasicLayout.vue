<template>
  <div class="layout" :class="{ 'practice-layout': isPractice }">
    <Sidebar />
    <div class="layout-main">
      <AppHeader />
      <main class="content" :class="{ 'practice-content': isPractice, 'statistics-content': isStatistics }">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from '@/components/AppHeader.vue'
import Sidebar from '@/components/Sidebar.vue'

const route = useRoute()
const isPractice = computed(() => route.path.startsWith('/practice'))
const isStatistics = computed(() => route.path.startsWith('/statistics'))
</script>

<style scoped lang="scss">
.layout {
  display: flex;
  min-height: 100vh;
  background: var(--bg);
}

.layout-main {
  min-width: 0;
  flex: 1;
}

.content {
  width: 100%;
  max-width: 1560px;
  margin: 0 auto;
  padding: 22px 28px 30px;
}

.practice-content {
  max-width: none;
  padding: 14px 24px 26px;
}

.statistics-content {
  max-width: none;
  padding: 18px 28px 24px;
}
</style>
