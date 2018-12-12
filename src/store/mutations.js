export default {
  CHANGE_SEARCH_TEXT(state, text) {
    state.searchText = text
  },
  ADD_MODULES(state, modules) {
    modules = modules.map(mod => {
      let module_name = mod.module_name.replace(/^Elixir./, '')

      return {
        module_name: module_name,
        path: mod.path
      }
    })
    state.modules = modules
  },
  SET_PROJECT_NAME(state, projectName) {
    state.projectName = projectName
  },
  SET_SOCKET(state, socket) {
    if (state.socket == null) {
      state.socket = socket
    }
  },
  LOAD_MODULEDOC(state, module_name) {
    let mod = state.modules.find(mod => {
      return mod.module_name === module_name
    })

    if (mod === undefined) {
      return
    }

    if (state.socket.readyState === state.socket.OPEN) {
      state.socket.send(JSON.stringify({ module_path: mod.path }))
    }
  },
  SET_CURRENT_MODULEDOC(state, docs) {
    state.docs = docs
  }
}
