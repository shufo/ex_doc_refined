export default function({ store, params }) {
  store.dispatch('loadModuledoc', params.module_name)
}
