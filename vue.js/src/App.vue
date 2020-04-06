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
      <HelloWorld />
      <!--<router-view />-->
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
import HelloWorld from '@/components/HelloWorld.vue'
import Paginator from '@/components/Paginator.vue'

@Component({
  name: 'App',
  components: {
    Settings,
    Search,
    HelloWorld,
    Paginator
  }
})
export default class App extends Vue {

  $refs: any = {
    settings: Settings,
    search:   Search,
    list:     HelloWorld,
    page:     Paginator
  };

  sort: string = 'price'
  sortPrice: number = 1;
  lat: number = 0;
  lng: number = 0;
  keyword: string  = '';
  page: number  = 1;

  reset() {
    const params = {
      sort: this.sort,
      sortPrice: this.sortPrice,
      lat: this.lat,
      lng: this.lng,
      keyword: this.keyword,
      page: this.page
    }
    this.$store.dispatch('reset', params);
  }

  async mounted() {
    const self = this;
    getPoint().then(({ lat, lng }) => {
      self.lat = lat;
      self.lng = lng;
      self.$refs.settings.lat = lat;
      self.$refs.settings.lng = lng;
      self.$refs.list.lat = lat;
      self.$refs.list.lng = lng;
      self.reset();
    });
  };

  onSettingsVisible() {
    this.$refs.settings.sort = this.sort;
    this.$refs.settings.sortPrice = this.sortPrice;
    this.$refs.settings.lat = this.lat;
    this.$refs.settings.lng = this.lng;
    this.$refs.settings.show();
  }

  onSettingsApply({ sort, sortPrice }:{ sort: string, sortPrice: number }) {
    this.page = 1;
    this.sort = sort;
    this.sortPrice = sortPrice;
    this.$refs.settings.hide();
    this.$refs.page.reset();
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

function getPoint(): Promise<{ lat: number, lng: number }> {
  return new Promise((resolve, reject) => {
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        resolve({
          lat: pos.coords.latitude,
          lng: pos.coords.longitude
        });
      },
      (err) => {
        console.log('getPoint Error', err);
      }
    );
  });
}
</script>
