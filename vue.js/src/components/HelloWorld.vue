<template>
  <v-container>
    <v-row class="text-center">

      <v-col class="mb-5" cols="12">
        <v-simple-table>
          <template v-slot:default>
            <thead>
              <tr>
                <th class="text-center">-</th>
                <th class="text-center" v-for="item in headers">{{ item.text }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in list" :key="item.name">
                <td>{{ index }}</td>
                <td v-for="target in headers">{{ item[target.value] }}</td>
              </tr>
            </tbody>
          </template>
        </v-simple-table>
      </v-col>

      <v-col class="mb-5" cols="12">
        <v-pagination
          v-model="page"
          :length="page_count"
          :total-visible="page_visible"
        ></v-pagination>
      </v-col>

    </v-row>
  </v-container>
</template>

<script lang="ts">
import { Component, Vue, Watch } from 'vue-property-decorator';
import { mapState } from 'vuex'


@Component({
  computed: mapState([
    'count',
    'list',
    'page_count',
  ]),
})


export default class HelloWorld extends Vue {

  page: number = 1
  page_visible: number = 7

  headers: Array<any> = [
    { text: '주차장 이름', value: 'PARKING_NAME' },
    { text: '주소', value: 'ADDR' },
    { text: '전화번호', value: 'TEL' },
  ];


  mounted() {
    this.$store.dispatch('reset', { page: 1 });
  }


  @Watch('page')
  onLoad() {
    this.$store.dispatch('reset', { page: this.page });
  }
}
</script>
