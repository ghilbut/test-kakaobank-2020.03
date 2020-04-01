import Vue from "vue";
import Vuex from "vuex";


const PageSize: number = 10;
const PageVisible: number = 7;


Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    count: 0,
    list: [],
    page_count: 0,
    page_visible: PageVisible
  },
  mutations: {
    reset (state, { count, results }) {
      state.count = count;
      state.list = results;
      state.page_count = Math.floor((count + PageSize - 1) / PageSize);
    }
  },
  actions: {
    async reset ({ commit }, { page }) {
      try {
        let uri = `${process.env.VUE_APP_DJANGO_URI}/parking_lots/?size=${PageSize}`;
        if (page > 1) {
          uri = `${uri}&page=${page}`;
        }

        const res = await fetch(uri);
        commit('reset', await res.json());
      } catch (e) {
        alert('Vuex reset failed');
      }
    }
  }
});
