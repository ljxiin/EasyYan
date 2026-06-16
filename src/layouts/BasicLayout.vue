<template>
  <div class="layout">
    <Sidebar />
    <div class="layout-main">
      <AppHeader />
      <main class="content">
        <RouterView />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import AppHeader from '@/components/AppHeader.vue'
import Sidebar from '@/components/Sidebar.vue'
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
</style>
