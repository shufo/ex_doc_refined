export default {
  changeSearchText({ commit }, text) {
    commit('CHANGE_SEARCH_TEXT', text)
  },
  addModules({ commit }, modules) {
    commit('ADD_MODULES', modules)
  },
  setProjectName({ commit }, projectName) {
    commit('SET_PROJECT_NAME', projectName)
  },
  setSocket({ commit }, socket) {
    commit('SET_SOCKET', socket)
  },
  loadModuledoc({ commit }, moduleName) {
    commit('LOAD_MODULEDOC', moduleName)
  },
  setCurrentModuledoc({ commit }, docs) {
    commit('SET_CURRENT_MODULEDOC', docs)
  }
}
