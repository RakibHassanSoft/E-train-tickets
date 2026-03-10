import { Request, Response, NextFunction } from "express";
import Joi from "joi";
import { AppError } from "../utils/AppError";

export const validateRequest = (schema: Joi.ObjectSchema) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const { error } = schema.validate(req.body, { abortEarly: false });

    if (error) {
      // Map Joi errors
      const errors = error.details.map((detail) => ({
        field: detail.path.join("."),
        message: detail.message,
      }));

      return next(
        new AppError("Validation failed", 400, errors)
      );
    }

    next();
  };
};