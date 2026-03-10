// src/utils/sendResponse.ts
import { Response } from "express";

interface ResponseOptions<T> {
  res: Response;
  statusCode?: number;
  success?: boolean;
  message?: string;
  data?: T | null;
  errors?: any;
  meta?: any; // pagination or additional info
}

export const sendResponse = <T>({
  res,
  statusCode = 200,
  success = true,
  message = "",
  data = null,
  errors = null,
  meta = null,
}: ResponseOptions<T>) => {
  return res.status(statusCode).json({
    success,
    message,
    data,
    errors,
    meta,
  });
};