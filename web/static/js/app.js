// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
// import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import "semantic-ui/dist/semantic.min"

// Vue
import Vue from 'vuejs'
//import VueResource from 'vue-resource'
import SSHKey from './components/ssh_key'
//Vue.use(VueResource)
//Vue.http.options.root = '/api'
Vue.config.debug = process.env.NODE_ENV !== 'production';

import socket from "./socket"

new Vue({
  el: '#ssh-keys-list',
  components: {
    'ssh-key': SSHKey
  },
  data: {
    ssh_keys: [{name: 'dev ssh key', id:1},{name: 'prod ssh key', id:2}]
  },
  methods: {
    addNewSSHKey: function () {
      //add ssh key
    }
  }
})

$(function() {
  $('.tabular.menu .item').tab();
})
