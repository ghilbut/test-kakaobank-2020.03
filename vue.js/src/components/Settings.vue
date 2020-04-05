<template>
  <v-overlay :value="visible">

    <v-card
      class="mx-auto"
      min-width="640"
      max-width="1024"
      elevation="0"
      outlined
    >
      <v-card-title>설정</v-card-title>

      <v-divider></v-divider>
      <v-card-subtitle>정렬</v-card-subtitle>

      <v-card-text>
        <v-radio-group v-model="sort" :mandatory="false">
          <v-radio label="가격" value="price"></v-radio>
          <v-radio label="거리" value="distance"></v-radio>
        </v-radio-group>

        <v-radio-group
          row
          v-model="sortPrice"
          :mandatory="true"
          :disabled="sort=='distance'"
        >
          <span><b>기준시간: &nbsp&nbsp&nbsp</b></span>
          <v-radio label="1시간" value="1"></v-radio>
          <v-radio label="2시간" value="2"></v-radio>
          <v-radio label="3시간" value="3"></v-radio>
          <v-radio label="4시간" value="4"></v-radio>
          <v-radio label="하루" value="0"></v-radio>
          <v-radio label="월정액" value="-1"></v-radio>
        </v-radio-group>

        <div>
          <span><b>기준위치: &nbsp&nbsp&nbsp</b></span>
          Latitude: {{ lat }} /
          Longitude: {{ lng }}
        </div>
      </v-card-text>

      <v-divider></v-divider>
      <v-card-actions>
        <v-btn text @click="onApply">Apply</v-btn>
        <v-btn text @click="onCancel">Cancel</v-btn>
      </v-card-actions>
    </v-card>

  </v-overlay>
</template>


<script lang="ts">
import { Component, Vue, Watch } from 'vue-property-decorator';
import { mapState } from 'vuex';

@Component
export default class Settings extends Vue {
  visible: boolean = false;
  sort: string = 'price';
  sortPrice: number = 1;
  lat: string = 'Unknown';
  lng: string = 'Unknown';

  show() {
    this.visible = true;
  }

  hide() {
    this.visible = false;
  }

  onApply() {
    const params = {
      sort: this.sort,
      sortPrice: this.sortPrice,
      lat: this.lat,
      lng: this.lng
    };
    this.$emit('apply', params);
  }

  onCancel() {
    this.$emit('cancel', '');
  }

  @Watch('sort')
  async onSortChanged(val: string, oldVal: string) {
    this.lat = this.lng = 'Unkown';
    if (val == 'distance') {
      const { lat, lng }:any = await this.getPoint();
      this.lat = lat.toFixed(8);
      this.lng = lng.toFixed(8);
    }
  }

  getPoint() {
    return new Promise((resolve, reject) => {
      navigator.geolocation.getCurrentPosition((pos) => {
        resolve({
          'lat': pos.coords.latitude,
          'lng': pos.coords.longitude
        });
      });
    });
  }
}
</script>
