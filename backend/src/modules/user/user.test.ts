import request from "supertest";
import { app } from "../../server";

describe("User Module", () => {

  let accessToken: string;

  const userData = {
    full_name: "Test User2",
    email: "user2@example.com",
    phone: "9876543210",
    password: "password123"
  };

  beforeAll(async () => {
    // Register user
    const registerRes = await request(app)
      .post("/api/v1/auth/register")
      .send(userData);
    expect(registerRes.statusCode).toBe(201);

    // Login user
    const loginRes = await request(app)
      .post("/api/v1/auth/login")
      .send({ email: userData.email, password: userData.password });
    expect(loginRes.statusCode).toBe(200);

    accessToken = loginRes.body.data.accessToken;
  });

  it("should get user profile", async () => {
    const res = await request(app)
      .get("/api/v1/users/me")
      .set("Authorization", `Bearer ${accessToken}`);

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.email).toBe(userData.email);  // ✅ access via data
  });

  it("should update user profile", async () => {
    const res = await request(app)
      .put("/api/v1/users/me")
      .set("Authorization", `Bearer ${accessToken}`)
      .send({ full_name: "Updated User" });

    expect(res.statusCode).toBe(200);
    expect(res.body.success).toBe(true);
    expect(res.body.data.full_name).toBe("Updated User"); // ✅ access via data
  });

});