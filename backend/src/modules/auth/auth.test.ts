import request from "supertest";
import { app } from "../../server";

describe("Auth Module", () => {
  const userData = {
    full_name: "Test User",
    email: "test@example.com",
    phone: "1234567890",
    password: "password123",
  };

  it("should register a user", async () => {
    const res = await request(app)
      .post("/api/v1/auth/register")
      .send(userData);


    expect(res.statusCode).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.email).toBe(userData.email);
    expect(res.body.message).toBeDefined();
  });

  it("should login a user", async () => {
    const res = await request(app)
      .post("/api/v1/auth/login")
      .send({ email: userData.email, password: userData.password });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.accessToken).toBeDefined();
    expect(res.body.data.refreshToken).toBeDefined();
    expect(res.body.message).toBeDefined();
  });

  it("should refresh access token", async () => {
    const loginRes = await request(app)
      .post("/api/v1/auth/login")
      .send({ email: userData.email, password: userData.password });

    const res = await request(app)
      .post("/api/v1/auth/refresh")
      .send({ refreshToken: loginRes.body.data.refreshToken });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.accessToken).toBeDefined();
    expect(res.body.message).toBeDefined();
  });

  it("should logout user", async () => {
    const loginRes = await request(app)
      .post("/api/v1/auth/login")
      .send({ email: userData.email, password: userData.password });

    const res = await request(app)
      .post("/api/v1/auth/logout")
      .send({ refreshToken: loginRes.body.data.refreshToken });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.message).toBeDefined();
  });
});