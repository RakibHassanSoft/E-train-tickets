import { Request, Response, NextFunction } from "express";
import { AppError } from "../utils/AppError";
import jwt from "jsonwebtoken";
import { Prisma } from "../generated/prisma/client";
import { sendResponse } from "../utils/sendResponse";

export const globalErrorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error(err);

  // 1️⃣ Custom AppError (operational errors)
  if (err instanceof AppError) {
    return sendResponse({
      res,
      statusCode: err.statusCode,
      success: false,
      message: err.message,
      errors: err.errors || null,
    });
  }

  // 2️⃣ Prisma Unique Constraint Error
  if (err instanceof Prisma.PrismaClientKnownRequestError && err.code === "P2002") {
    return sendResponse({
      res,
      statusCode: 409,
      success: false,
      message: "Duplicate field value",
    });
  }

  // 3️⃣ JWT Errors
  if (err instanceof jwt.JsonWebTokenError) {
    return sendResponse({
      res,
      statusCode: 401,
      success: false,
      message: "Invalid token",
    });
  }

  if (err instanceof jwt.TokenExpiredError) {
    return sendResponse({
      res,
      statusCode: 401,
      success: false,
      message: "Token expired",
    });
  }

  // 4️⃣ Unknown / Programming Errors
  return sendResponse({
    res,
    statusCode: 500,
    success: false,
    message: "Internal Server Error",
    errors: process.env.NODE_ENV === "development" ? err.stack : null,
  });
};