export default {
  preset: "ts-jest",
  testEnvironment: "node",
  setupFilesAfterEnv: ["<rootDir>/tests/setup.ts"],
  modulePathIgnorePatterns: ["<rootDir>/dist/"]
};