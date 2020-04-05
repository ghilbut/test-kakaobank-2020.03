<template>
  <v-app>
    <v-app-bar app color="primary" dark>

      <v-spacer></v-spacer>
        <Search
          ref="search"
          @keyword-changed="onKeyword"
          @settings-visible="onSettingsVisible"
        />
      <v-spacer></v-spacer>

    </v-app-bar>

    <v-content>
      <Settings
        ref="settings"
        @apply="onSettingsApply"
        @cancel="onSettingsCancel"
      />

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
import Settings from '@/components/Settings.vue'
import Search from '@/components/Search.vue'
import Paginator from '@/components/Paginator.vue'

@Component({
  name: 'App',
  components: {
    Settings,
    Search,
    Paginator
  }
})
export default class App extends Vue {

  $refs: any = {
    settings: Settings,
    search:   Search,
    list:     undefined,
    page:     Paginator
  };

  sort: string = 'price'
  sortPrice: number = 1;
  keyword: string  = '';
  page: number  = 1;

  reset() {
    const params = {
      sort: this.sort,
      sortPrice: this.sortPrice,
      keyword: this.keyword,
      page: this.page,
    }
    this.$store.dispatch('reset', params);
  }

  onSettingsVisible() {
    this.$refs.settings.sort = this.sort;
    this.$refs.settings.sortPrice = this.sortPrice;
    this.$refs.settings.show();
  }

  onSettingsApply({ sort, sortPrice }:{ sort: string, sortPrice: number }) {
    console.log(sort, sortPrice);
    this.sort = sort;
    this.sortPrice = sortPrice;
    this.$refs.settings.hide();
    this.reset();
  }

  onSettingsCancel() {
    this.$refs.settings.hide();
  }

  onKeyword(keyword: string) {
    if (this.keyword === keyword) {
      return;
    }

    this.keyword = keyword;
    this.page = 1;
    this.$refs.page.reset();
    this.reset();
  }

  onPage(page: number) {
    this.page = page;
    this.reset();
  }
}
</script>
