<template>
  <v-app>
    <v-app-bar app color="primary" dark>

      <v-spacer></v-spacer>
        <Search ref="search" @keyword-changed="onKeyword" />
      <v-spacer></v-spacer>

    </v-app-bar>

    <v-content>
      <router-view />
    </v-content>

    <v-footer class="font-weight-medium" app>
      <v-col class="text-center" cols="12">
        <Paginator ref="page" @page-changed="onPage" />
      </v-col>
    </v-footer>

  </v-app>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import Search from '@/components/Search.vue'
import Paginator from '@/components/Paginator.vue'

@Component({
  name: 'App',
  components: {
    Search,
    Paginator
  }
})
export default class App extends Vue {

  $refs: any = {
    search: Search,
    list:   undefined,
    page:   Paginator
  };

  keyword: string = '';
  page: number    = 1;

  onKeyword(keyword: string) {
    if (this.keyword === keyword) {
      return;
    }

    this.keyword = keyword;
    this.page = 1;
    this.$refs.page.reset();
    this.$store.dispatch('reset', { keyword , page: this.page });
  }

  onPage(page: number) {
    this.page = page;
    this.$store.dispatch('reset', { keyword: this.keyword, page });
  }
}
</script>
