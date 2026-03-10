// src/server.ts
import express from "express";
import dotenv from "dotenv";
import router from "./routes";
import { startServer } from "./db/connect.db";
import { globalErrorHandler } from "./middlewares/errorHandler";

dotenv.config();

export const app = express();

// Middleware
app.use(express.json());

// Routes
app.use("/api/v1", router);

// Global Error Handler
app.use(globalErrorHandler);

const PORT = process.env.PORT || 5000;

// Export server instance for tests
export let serverInstance: ReturnType<typeof app.listen> | null = null;

startServer().then(() => {
  serverInstance = app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/api/v1`);
  });
});