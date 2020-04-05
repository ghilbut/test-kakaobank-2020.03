<template>
  <v-container>
    <v-row class="text-center">

      <v-col class="mb-5" cols="12">
        <v-simple-table>
          <template v-slot:default>
            <thead>
              <tr>
                <th class="text-center"></th>
                <th class="text-center">주차가능</th>
                <th class="text-center" v-for="item in headers">
                  {{ item.text }}
                </th>
                <!-- <th class="text-center">거리</th> -->
            </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in list">
                <td>{{ index + 1}}</td>
                <td>{{ isParkable(item) ? 'Y' : 'N' }}</td>
                <td v-for="target in headers">{{ item[target.value] }}</td>
                <!-- <td>{{ distance(item) }}</td> -->
              </tr>
            </tbody>
          </template>
        </v-simple-table>
      </v-col>

    </v-row>
  </v-container>
</template>

<script lang="ts">
import { Component, Vue, Watch } from 'vue-property-decorator';
import { mapState } from 'vuex';


@Component({
  computed: mapState([
    'count',
    'list',
    'page_count'
  ])
})
export default class HelloWorld extends Vue {

  headers: Array<any> = [
    { text: '주차장 이름', value: 'PARKING_NAME' },
    { text: '주소', value: 'ADDR' },
    { text: '전화번호', value: 'TEL' },
  ];
  lat: number = 0;
  lng: number = 0;

  isParkable(item: any) {
    const now: Date = new Date();
    const isWeekend: boolean = [0, 6].includes(now.getDay());
    const isNightFree: boolean = item.NIGHT_FREE_OPEN === 'Y';

    // weekend
    if (isWeekend) {
      return isInTime(
        Number(item.WEEKEND_BEGIN_TIME),
        Number(item.WEEKEND_END_TIME),
        now
      ) || isNightFree;
    }

    // weekday
    return isInTime(
      Number(item.WEEKDAY_BEGIN_TIME),
      Number(item.WEEKDAY_END_TIME),
      now
    ) || isNightFree;
  }

  distance(item: any) {
    let lat1 = this.lat;
    let lat2 = item['LAT'];
    const lng1 = this.lng;
    const lng2 = item['LNG'];

    if (lat1 == lat2 && lng1 == lng2) {
      return 0;
    }

    const R = 6371.01;  // Radius of the earth in km
    const P = Math.PI / 180;
    const dlat = (lat2 - lat1) * P;
    const dlng = (lng2 - lng1) * P;
    lat1 = lat1 * P;
    lat2 = lat2 * P;
    const a = Math.sin(dlat/2) * Math.sin(dlat/2) +
              Math.sin(dlng/2) * Math.sin(dlng/2) * Math.cos(lat1) * Math.cos(lat2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    const m = R * c;
    return m;
  }
}

const isInTime = (begin: number, end: number, date: Date) => {
    // 아래와 같이 익일에 마감하는 주차장들이 존재한다.
    // 예시: [CODE: 1277144] 영등포구청역(시) - 05:00~01:00
    // 예시: [CODE: 1277145] 잠실(시)         - 05:00~01:00

    const bh = Math.floor(begin / 100);
    const bm = begin % 100;
    let eh = Math.floor(end / 100);
    if (bh == eh) {
      return true;
    }
    if (bh > eh) {
      eh += 24;
    }
    const em = end % 100;
    let th = date.getHours();
    if (bh > th) {
      th += 24;
    }
    const tm = date.getMinutes();
    const b = new Date(0, 0, 0, bh, bm, 0, 0);
    const t = new Date(0, 0, 0, th, tm, 0, 0);
    const e = new Date(0, 0, 0, eh, em, 0, 0);
    return b <= t && t <= e;

}
</script>
