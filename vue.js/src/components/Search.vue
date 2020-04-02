<template>
  <v-text-field
    v-model="keyword"
    label="검색하기"
    prepend-inner-icon="search"
    outlined
    dense
    clearable
    hide-details
    @change="onSearch"
    @click:clear="onClear"
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
}
</script>
