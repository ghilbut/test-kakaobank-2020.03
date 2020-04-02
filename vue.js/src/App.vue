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
import Vue from 'vue';
import Search from "@/components/Search.vue"
import Paginator from "@/components/Paginator.vue"

export default Vue.extend({
  name: 'App',

  data: () => ({
    keyword: "",
    page: 1
  }),

  components: {
    Search,
    Paginator
  },

  methods: {
    onKeyword(keyword: string) {
      if (this.keyword === keyword) {
        return;
      }

      this.keyword = keyword;
      this.page = 1;
      this.$refs.page.reset();
      this.$store.dispatch('reset', { keyword , page: this.page });
    },
    onPage(page: number) {
      this.page = page;
      this.$store.dispatch('reset', { keyword: this.keyword, page });
    }
  }
});
</script>
