<template>
  <v-app>
    <v-app-bar app color="primary" dark>

      <v-spacer></v-spacer>
        <Search />
      <v-spacer></v-spacer>

    </v-app-bar>

    <v-content>
      <router-view />
    </v-content>

    <v-footer class="font-weight-medium" app>
      <v-col class="text-center" cols="12">
        <Paginator />
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
    //
  }),

  components: {
    Search,
    Paginator
  }
});
</script>
