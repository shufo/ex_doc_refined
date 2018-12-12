<template>
  <v-card>
    <v-card-actions>
      <v-btn
        flat
        @click="show = !show"
      >
        <v-icon left>{{ show ? 'keyboard_arrow_up' : 'keyboard_arrow_down' }}</v-icon>
        RUNNER
      </v-btn>
    </v-card-actions>
    <v-slide-y-transition>
      <v-card-text v-show="show">
        <v-form
          ref="form"
          v-model="valid"
          lazy-validation
          @submit="run"
          @keyup.native.enter="valid && submit($event)"
        >
          <td
            v-for="(arg, i) in func.args"
            :key="arg"
          >
            <v-text-field
              :label="arg"
              v-model="form[i]"
              required="true"
            />
          </td>
          <v-btn
            :disabled="!valid"
            @click="run"
          >
            run
          </v-btn>
          <v-btn @click="clear">clear</v-btn>
        </v-form>
        <v-spacer />
        <v-slide-y-transition>
          <v-card
            v-show="result"
            class="night-mode"
            dark
          >
            <v-card-text
              class="makeup"
              v-html="result"
            />
          </v-card>
        </v-slide-y-transition>
      </v-card-text>
    </v-slide-y-transition>
  </v-card>

</template>
<script>
export default {
  name: 'Runner',
  props: {
    func: { type: Object, required: true }
  },
  data: () => ({
    show: false,
    inputs: [],
    name: '',
    form: {},
    result: null
  }),
  computed: {
    valid: {
      get: function() {
        if (this.func.args.length == 0) {
          return true
        }

        if (Object.keys(this.form).length == 0) {
          return false
        }

        return Object.keys(this.form).reduce((acc, current, index, array) => {
          return (
            acc && this.form[index] !== undefined && this.form[index] !== ''
          )
        }, true)
      },
      set: function() {
        return
      }
    }
  },
  mounted() {
    this.socketClient = this.$socketClient
  },
  methods: {
    clear() {
      this.result = null
    },
    run(e) {
      e.preventDefault()
      this.result = null

      if (this.valid) {
        const params = {
          module_name: this.func.module_name,
          function: this.func.name,
          args: Object.values(this.form)
        }

        this.socketClient.sendWithSync(params, result => {
          this.result = result
        })
      }
    },
    submit() {
      return false
    }
  }
}
</script>
