<template>
  <v-layout
    column
    justify-space-between
  >
    <v-flex
      xs12
      sm12
      md12
      lg12
    >
      <v-card>
        <v-card-title
          primary-title
          class="display-1 primary--text"
          ellipsis
        >
          <p class="display-1 primary--text text-truncate">
            {{ docs.module_name }}
          </p>
        </v-card-title>
        <v-card-text
          v-if="docs.module_doc !== 'none'"
          class="moduledoc night-mode"
          v-html="docs.module_doc"
        />
      </v-card>
      <v-expansion-panel>
        <v-divider />
        <v-slide-y-transition
          class="py-0"
          group
          tag="v-expansion-panel"
        >
          <v-expansion-panel-content
            v-for="func in filteredFunctions"
            :key="func.name + func.signature.toString()"
            lazy
          >
            <v-layout
              v-scroll="onScroll"
              slot="header"
              align-center
              justify-space-between
              row
              spacer
            >
              <v-flex
                xs3
                sm3
                md3
              >
                <v-chip
                  :color="functionRoleColor(func)"
                  text-color="white"
                >
                  <span
                    v-if="func.name === '__struct__' && func.arity === 0"
                    v-html="'struct'"
                  />
                  <span
                    v-if="func.name !== '__struct__'"
                    v-html="func.role"
                  />
                </v-chip>
              </v-flex>

              <v-flex
                no-wrap
                xs5
                sm6
                ellipsis
              >
                <strong
                  v-if="func.role !== 'type'"
                  v-html="func.signature[0]"
                />
                <strong
                  v-if="func.role === 'type' || func.role === 'callback'"
                  v-html="func.name"
                />
                <br>
                <template v-for="(spec, i) in func.specs">
                  <v-sub-header
                    v-if="func.role !== 'type'"
                    :key="i"
                    class="makeup"
                    ellipsis
                    v-html="spec"
                  />
                </template>
                <v-sub-header
                  v-if="func.role === 'type'"
                  class="makeup"
                  v-html="func.type_spec"
                />

              </v-flex>
              <v-spacer />
              <v-flex
                no-wrap
                xs5
                sm8
                ellipsis
              >
                <span
                  class="grey--text ml-3"
                  v-html="func.heading"
                />
              </v-flex>
              <v-spacer />

            </v-layout>
            <function-doc :func="func" />
          </v-expansion-panel-content>
        </v-slide-y-transition>
      </v-expansion-panel>
      <v-card>
        <v-fab-transition>
          <v-btn
            v-if="offsetTop < 100"
            relative
            dark
            fab
            bottom
            right
            fixed
            color="pink"
            @click="goToBottom"
          >
            <v-icon>arrow_downward</v-icon>
          </v-btn>
        </v-fab-transition>
        <v-fab-transition>
          <v-btn
            v-if="offsetTop > 100"
            relative
            dark
            fab
            bottom
            right
            fixed
            color="pink"
            @click="goToTop"
          >
            <v-icon>arrow_upward</v-icon>
          </v-btn>
        </v-fab-transition>
        <v-card-text v-if="docs.functions.length == 0">
          <p>No functions defined</p>
        </v-card-text>
      </v-card>
    </v-flex>
  </v-layout>
</template>

<script>
import { mapGetters } from 'vuex'
import FunctionDoc from '~/components/FunctionDoc.vue'

export default {
  components: { FunctionDoc },
  data: () => ({
    offsetTop: 0
  }),
  computed: {
    ...mapGetters(['searchText', 'filteredFunctions', 'modules', 'docs'])
  },
  methods: {
    functionRoleColor(func) {
      if (func.name === '__struct__' && func.arity === 0) {
        return 'deep-purple'
      }

      switch (func.role) {
        case 'struct':
          return 'secondary'
          break
        case 'function':
          return 'primary'
          break
        case 'macro':
          return 'purple'
          break
        case 'callback':
          return 'deep-purple darken-3'
          break
        case 'type':
          return 'deep-purple accent-2'
          break
        default:
          return 'purple'
          break
      }
    },
    goToBottom() {
      this.$vuetify.goTo(999999, { duration: 300, easing: 'easeInOutCubic' })
    },
    goToTop() {
      this.$vuetify.goTo(0, { duration: 300, easing: 'easeInOutCubic' })
    },
    onScroll() {
      this.offsetTop = window.pageYOffset || document.documentElement.scrollTop
    }
  }
}
</script>
<style lang="scss">
.moduledoc li {
  margin-bottom: 16px;
}
</style>
