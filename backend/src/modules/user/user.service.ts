import { prisma } from "../../config/prisma";
import { UpdateProfileInput } from "./user.types";

export const getProfile = async (userId: string) => {

  return prisma.user.findUnique({
    where: { user_id: userId },
    select: {
      user_id: true,
      full_name: true,
      email: true,
      phone: true,
      role: true,
      created_at: true
    }
  });
};

export const updateProfile = async (userId: string, data: UpdateProfileInput) => {
  const allowedFields: (keyof UpdateProfileInput)[] = ["full_name", "phone", "email","password"];
  const filteredData: Partial<UpdateProfileInput> = {};

  for (const key of allowedFields) {
    if (data[key] !== undefined) {
      filteredData[key] = data[key];
    }
  }

  return prisma.user.update({
    where: { user_id: userId },
    data: filteredData
  });
};