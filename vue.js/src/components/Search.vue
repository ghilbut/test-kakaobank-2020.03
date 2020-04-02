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
    console.log('CHANGED: ', this.keyword);
    this.$store.dispatch('setKeyword', { keyword: this.keyword });
    this.$store.dispatch('list', { page: this.page });
  }

  onClear() {
    this.$store.dispatch('setKeyword', { keyword: '' });
    this.$store.dispatch('list', { page: this.page });
  }
}
</script>
