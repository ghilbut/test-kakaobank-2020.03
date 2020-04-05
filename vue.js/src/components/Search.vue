<template>
  <v-text-field
    v-model="keyword"
    label="검색하기"
    prepend-inner-icon="search"
    append-outer-icon="settings"
    outlined
    dense
    clearable
    hide-details
    @change="onSearch"
    @click:clear="onClear"
    @click:append-outer="onSettings"
  ></v-text-field>
</template>

<script lang="ts">
import { Component, Vue, Watch } from 'vue-property-decorator';
import { mapState } from 'vuex';

@Component
export default class Search extends Vue {
  keyword: string = '';

  onSearch() {
    this.$emit('keyword-changed', this.keyword || '');
  }

  onClear() {
    this.$emit('keyword-changed', '');
  }

  onSettings() {
    this.$emit('settings-visible');
  }
}
</script>
