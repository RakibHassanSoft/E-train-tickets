import { Router } from "express";

import * as controller from "./user.controller";
import { authMiddleware, authorizeRoles } from "../auth/auth.middleware";
import catchAsync from "../../utils/catchAsync";


const userRoutes = Router();


userRoutes.get("/me", authMiddleware,authorizeRoles(["PASSENGER"]) ,catchAsync(controller.profile));

userRoutes.put("/me", authMiddleware, catchAsync(controller.updateProfile));

export default userRoutes;