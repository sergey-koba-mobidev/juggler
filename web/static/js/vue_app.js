import Vue from 'vuejs'
import SSHKey from './components/ssh_key'
import Collaborator from './components/collaborator'
Vue.config.debug = process.env.NODE_ENV !== 'production';

if (window.projectId !== undefined && $('#ssh-keys-list').length > 0) {
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
  });

  new Vue({
    el: '#collaborators-list',
    components: {
      'collaborator': Collaborator
    },
    data: {
      collaborators: [],
      user_id: '',
      user_role: 'member',
      select: null
    },
    mounted () {
      var context =  this;
      $.get( "/api/projects/" + window.projectId + "/collaborators", function( data ) {
        context.collaborators = data.collaborators
      });
      $(function() {
        context.select = $("#user-email").selectize({
          valueField: 'id',
          labelField: 'name',
          searchField: 'email',
          maxItems: 1,
          create: false,
          render: {
            option: function(item, escape) {
              return '<div class="item">' +
                  '<div class="ui avatar image"><img src="' + escape(item.avatar_url) + '" alt=""></div>' +
                  '<span class="header"><b>' + escape(item.name) + '</b></span>' +
                  '<span class="meta"> (' + escape(item.email) + ')</span>' +
              '</div>';
            }
          },
          load: function(query, callback) {
            if (!query.length || (query.length && query.length < 3)) return callback();
            $.ajax({
                url: "/api/users",
                type: "GET",
                dataType: "json",
                data: {
                    q: query
                },
                error: function() {
                    callback();
                },
                success: function(res) {
                    callback(res.users);
                }
            });
          },
          onItemAdd: function(value, $item) {
            context.user_id = value
          }
        });
      });

    },
    methods: {
      addNewCollaborator: function (e) {
        e.preventDefault();
        var context = this;
        $.post( "/api/projects/" + window.projectId + "/collaborators", { collaborator: {user_id: this.user_id, role: this.user_role} }, function( data ) {
          context.collaborators.push(data.collaborator);
        }).fail(function() {
          alert( "Collaborator already exists or wrong role" );
        });
        this.user_id = ""
        this.user_role = "edit"
        this.select[0].selectize.clear();
      }
    }
  })
}
