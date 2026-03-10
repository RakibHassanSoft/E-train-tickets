// src/tests/setup.ts
import { app, serverInstance } from "../server";
import request from "supertest";
import { prisma } from "../config/prisma";

export const testRequest = request(app);

// DB cleanup hooks
beforeAll(async () => {
  await prisma.user.deleteMany();
  await prisma.refreshToken.deleteMany();
});

afterEach(async () => {
  await prisma.refreshToken.deleteMany();
});

afterAll(async () => {
  await prisma.$disconnect();
  if (serverInstance) {
    serverInstance.close();
  }
});