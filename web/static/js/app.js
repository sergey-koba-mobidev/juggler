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
import SSHKey from './components/ssh_key'
Vue.config.debug = process.env.NODE_ENV !== 'production';

import socket from "./socket"

new Vue({
  el: '#ssh-keys-list',
  components: {
    'ssh-key': SSHKey
  },
  data: {
    ssh_keys: [],
    key_name: '',
    key_data: ''
  },
  mounted () {
    var context =  this;
    $.get( "/api/projects/" + window.projectId + "/ssh_keys", function( data ) {
      context.ssh_keys = data.ssh_keys
    });
  },
  methods: {
    addNewSSHKey: function (e) {
      e.preventDefault();
      var context = this;
      $.post( "/api/projects/" + window.projectId + "/ssh_keys", { ssh_key: {name: this.key_name, data: this.key_data} }, function( data ) {
          context.ssh_keys.push(data.ssh_key);
      });
      this.key_name = ''
      this.key_data = ''
    }
  }
})

$(function() {
  $('.tabular.menu .item').tab();
})
