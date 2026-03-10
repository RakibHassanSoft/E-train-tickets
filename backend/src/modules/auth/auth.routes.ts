import { Router } from "express";
import * as authController from "./auth.controller";
import catchAsync from "../../utils/catchAsync";
import { validateRequest } from "../../middlewares/validateRequest";

const authRouters = Router();
//validateRequest(registerSchema),

authRouters.post("/register",catchAsync(authController.register));
authRouters.post("/login", catchAsync(authController.login));
authRouters.post("/refresh",  catchAsync(authController.refresh));
authRouters.post("/logout",  catchAsync(authController.logout));

export default authRouters;