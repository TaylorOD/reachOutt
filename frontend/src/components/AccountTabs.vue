<template>
  <nav class="account-tabs" aria-label="Account settings">
    <router-link to="/account">Profile</router-link>
    <router-link to="/account/password">Password</router-link>
  </nav>
</template>

<style scoped>
.account-tabs {
  display: flex;
  gap: 8px;
  margin: -8px 0 28px;
  border-bottom: 1px solid var(--line);
}
.account-tabs a {
  color: var(--muted);
  padding: 12px 18px;
  text-decoration: none;
  border-bottom: 3px solid transparent;
}
.account-tabs a:hover {
  color: var(--ink);
  background: #ecefe6;
}
.account-tabs .router-link-exact-active {
  color: var(--accent);
  border-bottom-color: var(--accent);
  font-weight: 650;
}
</style>
