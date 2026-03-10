import { verifyAccessToken } from "../../utils/jwt";
import { Request, Response, NextFunction } from "express";
import { sendResponse } from "../../utils/sendResponse";

interface AuthRequest extends Request {
  user?: {
    userId: string;
    role: string;
  };
}

export const authMiddleware = (req: any, res: any, next: any) => {

  const auth = req.headers.authorization;

  if (!auth) {
    return res.status(401).json({ message: "Unauthorized" });
  }

  const token = auth.split(" ")[1];

  try {

    const decoded = verifyAccessToken(token);

    req.user = decoded;

    next();

  } catch {
    res.status(401).json({ message: "Invalid token" });
  }
};

export const authorizeRoles = (allowedRoles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    const auth = req.headers.authorization;
    if (!auth) return res.status(401).json({ message: "Unauthorized" });

    const token = auth.split(" ")[1];

    try {
      const decoded = verifyAccessToken(token);

      // Ensure decoded has userId and role
      if (typeof decoded === "string") {
        return sendResponse({
          res,
          statusCode: 401,
          success: false,
          message: "Invalid token payload",
        });
      }

      const { userId, role } = decoded as { userId: string; role: string };

      req.user = { userId, role };

      // Check role
      if (!allowedRoles.includes(role)) {
        return sendResponse({
          res,
          statusCode: 403,
          success: false,
          message: "Forbidden: Insufficient role",
        });
      }

      next();
    } catch (err) {
      return sendResponse({
        res,
        statusCode: 401, 
        success: false,
        message: "Invalid token",
      });
    }
  };
};