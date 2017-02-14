<template>
  <div class="item">
    <div class="content">
      <span class="header">{{item.name}}</span>
      <button class="ui right floated negative button" v-on:click='deleteSSHKey'>Delete</button>
    </div>
  </div>
</template>

<script>
export default {
  props: ['item'],
  methods: {
    deleteSSHKey: function () {
      console.log('delete');
    }
  }
}
</script>
