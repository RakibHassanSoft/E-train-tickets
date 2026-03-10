import { verifyAccessToken } from "../../utils/jwt";

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