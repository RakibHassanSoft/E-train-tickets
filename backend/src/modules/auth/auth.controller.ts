import { Request, Response } from 'express';
import * as authService from './auth.service';

export const signup = async (req: Request, res: Response) => {
  const { name, email, password } = req.body;
  const user = await authService.signup(name, email, password);
  res.status(201).json({ message: 'User created', user });
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;
  const data = await authService.login(email, password);
  res.json(data);
};