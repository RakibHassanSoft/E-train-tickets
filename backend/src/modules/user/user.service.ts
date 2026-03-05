import { prisma } from "../../config/prisma";


export const getAllUsers = () => prisma.user.findMany();