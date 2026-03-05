
import { prisma } from '../../config/prisma';
import { hashPassword, comparePassword, generateAccessToken, generateRefreshToken } from './auth.utils';

export const signup = async (name: string, email: string, password: string) => {
  const hashed = await hashPassword(password);

  // Get Passenger role
  const role = await prisma.role.findUnique({
    where: { role_name: "Passenger" },
  });

  if (!role) throw new Error("Default role not found");

  const user = await prisma.user.create({
    data: {
      name,
      email,
      password: hashed,
      role_id: role.role_id, 
    },
  });

  return user;
};

export const login = async (email: string, password: string) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw new Error('User not found');

  const valid = await comparePassword(password, user.password);
  if (!valid) throw new Error('Invalid credentials');

  const accessToken = generateAccessToken(user.u_id, user.role_id);
  const refreshToken = generateRefreshToken(user.u_id);

  await prisma.refreshToken.create({
    data: {
      user_id: user.u_id,
      token: refreshToken,
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    },
  });

  return { accessToken, refreshToken, user };
};