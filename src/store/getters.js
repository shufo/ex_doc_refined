export default {
  searchText(state) {
    return state.searchText
  },
  modules(state) {
    return state.modules
  },
  docs(state) {
    return state.docs
  },
  socket(state) {
    return state.socket
  },
  projectName(state) {
    return state.projectName
  },
  filteredFunctions(state) {
    return state.docs.functions.filter(func => {
      let isStructCall =
        func.role === 'function' &&
        func.name === '__struct__' &&
        func.arity === 1
      let containsSearchWord = func.name
        .toLowerCase()
        .includes(state.searchText.toLowerCase())

      return !isStructCall && containsSearchWord
    })
  }
}
