<template>
  <v-card>
    <v-divider />
    <v-card-text v-if="isDescribeBlockExists(func)">
      <p class="title"><strong v-html="func.signature[0]" /></p>
      <p>
        <template v-for="(spec, i) in func.specs">
          <span
            :key="i"
            class="makeup"
            v-html="spec"
          />

        </template>

        <span
          v-if="func.type_spec !== ''"
          class="makeup"
          v-html="func.type_spec"
        />
      </p>

      <span
        v-if="func.function_doc !== ''"
        class="night-mode"
        v-html="func.function_doc"
      />
    </v-card-text>
    <runner
      v-if="isRunnable(func.role)"
      :func="func"
    />
  </v-card>
</template>

<script>
import Runner from '~/components/Runner.vue'

export default {
  name: 'FunctionDoc',
  components: { Runner },
  props: {
    func: { type: Object, required: true }
  },
  data: () => ({
    show: false
  }),
  methods: {
    isRunnable(role) {
      switch (role) {
        case 'function':
          return true
          break
        case 'type':
          return false
          break
        case 'macro':
          return false
          break

        default:
          return false
          break
      }
    },
    isDescribeBlockExists(func) {
      if (func.function_doc !== '') {
        return true
      }

      if (func.specs.length > 0) {
        return true
      }

      if (func.type_spec !== '') {
        return true
      }

      return false
    }
  }
}
</script>
