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
  pageVisible: number = 7;

  @Watch('page')
  onSeleced() {
    this.$store.dispatch('reset', { page: this.page });
  }
}
</script>
