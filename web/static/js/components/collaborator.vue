<template>
  <div class="item">
    <div class="content">
      <span class="header">{{item.name}}</span>
      <span class="meta">{{item.email}}</span>
      <b>
        <span class="meta" v-if="item.role == 'edit'"> - Build and Deploy</span>
        <span class="meta" v-if="item.role == 'admin'"> - Administrator</span>
      </b>
      <button class="ui right floated negative button" v-on:click="removeCollaborator">Remove</button>
    </div>
  </div>
</template>

<script>
export default {
  props: ['item'],
  methods: {
    removeCollaborator: function (e) {
      e.preventDefault();
      var context = this;
      var r = confirm("Remove " + this.item.name + " from Collaborators?");
      if (r == true) {
        $.ajax({
            url: "/api/projects/" + window.projectId + "/collaborators/" + this.item.id,
            type: "DELETE",
            success: function(result) {
              context.$parent.collaborators.splice(context.$parent.collaborators.indexOf(context.item), 1);
            }
        });
      }
    }
  }
}
</script>
