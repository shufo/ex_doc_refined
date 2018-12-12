import Vue from 'vue'

export class WebSocketClient {
  constructor(endpoint, context) {
    this.endpoint = endpoint
    this.context = context
    this.handlers = []
    this.socketQueue = {}
    this.socketQueueId = 0
  }

  init() {
    this.ws = new WebSocket(this.endpoint)
    this.setWebsocketHandlers()
    this.startHeartbeat()
    this.context.store.dispatch('setSocket', this.ws)
  }

  setWebsocketHandlers() {
    this.ws.onopen = event => {
      this.clearHandlers()
    }

    this.ws.onclose = () => {
      this.ws.close()
      this.clearHandlers()
      let handle = setInterval(() => {
        this.ws = new WebSocket(this.endpoint)
        this.setWebsocketHandlers()
      }, 3000)
      this.handlers.push(handle)
    }

    this.ws.onmessage = event => {
      if (event.data == 'heartbeat') {
        return
      }

      let message = undefined

      try {
        message = JSON.parse(event.data)
      } catch (e) {
        console.log('socket response parse error: ' + e.data)
      }

      if (message.modules !== undefined) {
        this.context.store.dispatch('addModules', message.modules)
        this.context.store.dispatch('setProjectName', message.project_name)
        this.getModuledoc()
      }

      if (message.functions !== undefined) {
        this.context.store.dispatch('setCurrentModuledoc', message)
      }

      if (
        typeof message.cmd_id !== 'undefined' &&
        typeof this.socketQueue['i_' + message.cmd_id] === 'function'
      ) {
        let execFunc = this.socketQueue['i_' + message.cmd_id]
        execFunc(message.result)
        delete this.socketQueue['i_' + message.cmd_id]
        return
      }
    }
  }

  send(data) {
    this.ws.send(data)
  }

  sendWithSync(data, onReturnFunction) {
    this.socketQueueId++
    if (typeof onReturnFunction === 'function') {
      this.socketQueue['i_' + this.socketQueueId] = onReturnFunction
    }
    const jsonData = JSON.stringify({
      cmd_id: this.socketQueueId,
      json_data: data
    })
    try {
      this.ws.send(jsonData)
    } catch (e) {
      console.log('Sending failed ... .disconnected failed')
    }
  }

  clearHandlers() {
    this.handlers.forEach(element => {
      clearInterval(element)
    })
  }

  startHeartbeat() {
    setInterval(() => {
      if (this.ws.readyState === this.ws.OPEN) {
        this.ws.send('heartbeat')
      }
    }, 10000)
  }

  getModuledoc() {
    const moduleSpecified = this.context.store.getters.modules.find(module => {
      return module.module_name == this.context.params.module_name
    })

    if (moduleSpecified) {
      let moduleName = this.context.params.module_name.split('/').pop()
      this.context.store.dispatch('loadModuledoc', moduleName)
    } else {
      let moduleName = this.context.store.getters.projectName
      this.context.store.dispatch('loadModuledoc', moduleName)
    }
  }
}

export default function(context, inject) {
  context.app.router.onReady(() => {
    let path = window.location.pathname.endsWith('/')
      ? window.location.pathname.slice(0, -1)
      : window.location.pathname
    path = path
      .split('/')
      .filter(segment => {
        return segment !== ''
      })
      .shift()

    const transportPath = '/websocket'
    const host = context.isDev
      ? window.location.hostname + ':5600'
      : window.location.host
    const endpoint = 'ws://' + host + '/' + path + transportPath
    const client = new WebSocketClient(endpoint, context)

    client.init()

    Vue.prototype.$socketClient = client
  })
}
