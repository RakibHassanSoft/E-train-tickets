// src/types/express.d.ts
export {}; // <-- makes this file a module

declare global {
  namespace Express {
    interface Request {
      user?: {
        userId: number;
        role: 'ADMIN' | 'USER' | 'STAFF' | string;
      };
    }
  }
}