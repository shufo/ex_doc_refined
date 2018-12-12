const pkg = require('./package')

module.exports = {
  mode: 'spa',

  dev: process.env.NODE_ENV !== 'production',
  server: {
    host: '0.0.0.0'
  },

  /*
  ** Headers of the page
  */
  head: {
    title: pkg.name,
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: pkg.description }
    ],
    link: [{ rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' }]
  },

  /*
  ** Customize the progress-bar color
  */
  loading: { color: '#fff' },

  /*
  ** Global CSS
  */
  css: ['@/assets/css/highlight.scss'],

  /*
  ** Plugins to load before mounting the App
  */
  plugins: [
    // '~/plugins/vue-highlight',
    { src: '~/plugins/websocket', ssr: false }
  ],

  /*
  ** Nuxt.js modules
  */
  modules: ['@nuxtjs/vuetify'],
  /*
  ** Build configuration
  */
  build: {
    /*
    ** You can extend webpack config here
    */
    extend(config, ctx) {
      // Run ESLint on save
      if (ctx.isDev && ctx.isClient) {
        config.module.rules.push({
          enforce: 'pre',
          test: /\.(js|vue)$/,
          loader: 'eslint-loader',
          exclude: /(node_modules)/
        })
      }
    }
  },
  generate: {
    dir: '../priv',
    fallback: true
  },
  router: {
    base: process.env.NODE_ENV === 'production' ? './' : undefined,
    extendRoutes(routes, resolve) {
      routes.push(
        {
          name: 'return_to_index',
          path: '/:module_name',
          component: resolve(__dirname, 'pages/index.vue')
        },
        {
          name: 'nested',
          path: '/*/:module_name',
          component: resolve(__dirname, 'pages/index.vue')
        }
      )
    }
  }
}
