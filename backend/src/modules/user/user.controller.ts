import { sendResponse } from "../../utils/sendResponse";
import * as service from "./user.service";

export const profile = async (req: any, res: any) => {

  const user = await service.getProfile(req.user.userId);

   sendResponse({
    res,
    statusCode: 200,
    success: true,
    data: user,
    message: "User profile fetched successfully",
  });
};

export const updateProfile = async (req: any, res: any) => {

  const updated_user = await service.updateProfile(
    req.user.userId,
    req.body
  );

  sendResponse({
    res,
    statusCode: 200,
    success: true,
    data: updated_user,
    message: "User profile updated successfully",
  });

};