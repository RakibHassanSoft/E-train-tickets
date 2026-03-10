import { sendResponse } from "../../utils/sendResponse";
import * as authService from "./auth.service";

export const register = async (req: any, res: any) => {
  const user = await authService.registerUser(req.body);

  sendResponse({
    res,
    statusCode: 201,
    success: true,
    message: "User registered successfully",
    data: user,
  });
};

export const login = async (req: any, res: any) => {
  const data = await authService.loginUser(req.body);

  sendResponse({
    res,
    statusCode: 200,
    success: true,
    message: "User logged in successfully",
    data: data,
  });
};

export const refresh = async (req: any, res: any) => {
  const { refreshToken } = req.body;

  const token = await authService.refreshAccessToken(refreshToken);

  sendResponse({
    res,
    statusCode: 200,
    success: true,
    data: token,
    message: "Access token refreshed successfully",
  });
};

export const logout = async (req: any, res: any) => {
  const { refreshToken } = req.body;

  await authService.logoutUser(refreshToken);

  sendResponse({
    res,
    statusCode: 200,
    success: true,
    message: "User logged out successfully",
  });
};
