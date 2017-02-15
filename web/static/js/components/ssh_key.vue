<template>
  <div class="item">
    <div class="content">
      <span class="header">{{item.name}}</span>
      <button class="ui right floated negative button" v-on:click="deleteSSHKey">Delete</button>
    </div>
  </div>
</template>

<script>
export default {
  props: ['item'],
  methods: {
    deleteSSHKey: function (e) {
      e.preventDefault();
      var context = this;
      var r = confirm("Remove SSH Key?");
      if (r == true) {
        $.ajax({
            url: "/api/projects/" + window.projectId + "/ssh_keys/" + this.item.id,
            type: "DELETE",
            success: function(result) {
              context.$parent.ssh_keys.splice(context.$parent.ssh_keys.indexOf(context.item), 1);
            }
        });
      }
    }
  }
}
</script>
