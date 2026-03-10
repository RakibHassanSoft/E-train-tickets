import { prisma } from "../../config/prisma";
import { hashPassword, comparePassword } from "../../utils/hash";
import {
  generateAccessToken,
  generateRefreshToken
} from "../../utils/jwt";
import { LoginInput, RegisterInput } from "./auth.types";

export const registerUser = async (data: RegisterInput) => {
   
   const { first_name, last_name, email, password, phone } = data;
  const existing = await prisma.user.findUnique({
    where: { email: data.email }
  });

  if (existing) {
    throw new Error("Email already exists");
  }

  const hashed = await hashPassword(password);

  const user = await prisma.user.create({
  data: {
    full_name: `${first_name} ${last_name}`,
    email,
    phone:phone, 
    password: hashed,
   
  }
});

  return user;
};

export const loginUser = async (data: LoginInput) => {

  const user = await prisma.user.findUnique({
    where: { email: data.email }
  });

  if (!user) throw new Error("Invalid credentials");

  const match = await comparePassword(data.password, user.password);

  if (!match) throw new Error("Invalid credentials");

  const accessToken = generateAccessToken({
    userId: user.user_id,
    role: user.role
  });

  const refreshToken = generateRefreshToken({
    userId: user.user_id
  });

  await prisma.refreshToken.create({
    data: {
      user_id: user.user_id,
      refresh_token: refreshToken,
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
    }
  });

  return {
    accessToken,
    refreshToken,
    user
  };
};

export const refreshAccessToken = async (token: string) => {

  const stored = await prisma.refreshToken.findUnique({
    where: { refresh_token: token }
  });

  if (!stored || stored.is_revoked) {
    throw new Error("Invalid refresh token");
  }

  const accessToken = generateAccessToken({
    userId: stored.user_id
  });

  return { accessToken };
};

export const logoutUser = async (token: string) => {

  await prisma.refreshToken.update({
    where: { refresh_token: token },
    data: { is_revoked: true }
  });

  return true;
};