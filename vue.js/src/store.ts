import Vue from "vue";
import Vuex from "vuex";

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    count: 0,
    prev: null,
    next: null,
    list: [],
    page: 1
  },
  mutations: {
    reset (state, { count, next, previous, results }) {
      console.log(count, next, previous, results);
      state.count = count;
      state.prev = previous;
      state.next = next;
      state.list = results;
    }
  },
  actions: {
    async reset ({ commit }) {
      try {
        const uri = `${process.env.VUE_APP_DJANGO_URI}/parking_lots/`;
        const res = await fetch(uri);
        commit('reset', await res.json());
      } catch (e) {
        alert('Vuex reset failed');
      }
    }
  }
});
