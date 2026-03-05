import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'secret';

// 1. Define a custom interface that extends the Express Request
interface AuthenticatedRequest extends Request {
  user?: any; // Ideally, replace 'any' with a specific User interface
}

export const authMiddleware = (roles: string[] = []) => {
  // 2. Use AuthenticatedRequest here instead of Request
  return (req: AuthenticatedRequest, res: Response, next: NextFunction) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader?.split(' ')[1];
    
    if (!token) return res.status(401).json({ message: 'Unauthorized' });

    try {
      const payload: any = jwt.verify(token, JWT_SECRET);
      
      // 3. TypeScript now knows 'user' exists on this specific request object
      req.user = payload; 

      if (roles.length && !roles.includes(payload.role)) {
        return res.status(403).json({ message: 'Forbidden' });
      }
      next();
    } catch {
      return res.status(401).json({ message: 'Invalid token' });
    }
  };
};