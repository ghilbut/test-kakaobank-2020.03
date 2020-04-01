<template>
  <v-container>
    <v-row class="text-center">

      <v-col class="mb-5" cols="12">
        <v-pagination
          v-model="page"
          :length="6"
        ></v-pagination>
      </v-col>

      <v-col class="mb-5" cols="12">
        <v-simple-table>
          <template v-slot:default>
            <thead>
              <tr>
                <th class="text-left" v-for="item in headers">{{ item.text }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in list" :key="item.name">
                <td v-for="target in headers">{{ item[target.value] }}</td>
              </tr>
            </tbody>
          </template>
        </v-simple-table>
      </v-col>

      <v-col class="mb-5" cols="12">
        <v-pagination
          v-model="page"
          :length="6"
        ></v-pagination>
      </v-col>

    </v-row>
  </v-container>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator';
import { mapState } from 'vuex'


@Component({
  computed: mapState([
    'count',
    'prev',
    'next',
    'list',
    'page',
  ])
})


//@Component
export default class HelloWorld extends Vue {

  headers: Array<any> = [
    { text: '주차장 이름', value: 'PARKING_NAME' },
    { text: '주소', value: 'ADDR' },
    { text: '전화번호', value: 'TEL' },
  ];


  mounted() {
    this.$store.dispatch('reset');
  }
}
</script>
