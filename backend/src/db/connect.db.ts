import { prisma } from "../config/prisma";
import express from 'express';

const app = express();

export async function startServer() {
  try {
    await prisma.$connect();
    console.log("✅ Database connected successfully");

    app.listen(3000, () => {
      console.log("🚀 Server running on port 3000");
    });
  } catch (error) {
    console.error("❌ Database connection failed:", error);
  }
}

