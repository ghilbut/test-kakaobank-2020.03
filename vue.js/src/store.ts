import Vue from 'vue';
import Vuex from 'vuex';

const PageSize: number = 30;

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    keyword: "",
    count: 0,
    list: [],
    page_count: 0
  },
  mutations: {
    setKeyword(state, { keyword }) {
      state.keyword = keyword || '';
    },
    resetList(state, { count, results }) {
      state.count = count;
      state.list = results;
      state.page_count = Math.floor((count + PageSize - 1) / PageSize);
    }
  },
  actions: {
    async list({ commit, state }, { page }) {
      try {
        let uri = `${process.env.VUE_APP_DJANGO_URI}/parking_lots/?size=${PageSize}`;
        if (page > 1) {
          uri = `${uri}&page=${page}`;
        }
        if (state.keyword) {
          uri = `${uri}&q=${state.keyword}`;
        }

        const res = await fetch(uri);
        commit('resetList', await res.json());
      } catch (e) {
        alert('Vuex list failed');
      }
    },
    async setKeyword({ commit }, { keyword }) {
      commit('setKeyword', { keyword });
    },
  }
});
