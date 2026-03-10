import { Router } from "express";
import authRouters from "./modules/auth/auth.routes";
import userRoutes from "./modules/user/user.routes";

const router = Router();

router.use("/auth", authRouters);
router.use("/users", userRoutes);

export default router;