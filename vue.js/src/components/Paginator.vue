<template>
  <div>
    <v-pagination
      v-model="page"
      :length="page_count"
      :total-visible="pageVisible"
    ></v-pagination>
  </div>
</template>

<script lang="ts">
import { Component, Vue, Watch } from 'vue-property-decorator';
import { mapState } from 'vuex';

@Component({
  computed: mapState(['page_count'])
})
export default class Paginator extends Vue {
  page: number = 1
  pageVisible: number = 10;

  mounted() {
    this.$on('reset', this.reset);
  }

  reset() {
    this.page = 1;
  }

  @Watch('page')
  onSeleced() {
    this.$emit('page-changed', this.page);
  }
}
</script>
