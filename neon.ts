import { defineConfig } from "@neon/config/v1";

export default defineConfig({
  // Rails handles authentication. Neon provides PostgreSQL.
  auth: false,
  branch: (branch) => {
    if (branch.isDefault || branch.name === "production") {
      return {};
    }
    if (!branch.exists) {
      // Temporary development branches expire automatically.
      return { ttl: "7d" };
    }
    return {};
  },
});
