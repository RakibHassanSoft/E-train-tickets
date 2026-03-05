import { Router } from 'express';
import * as userController from './user.controller';
import { authMiddleware } from '../auth/auth.middleware';

const router = Router();

router.get('/', authMiddleware(['ADMIN']), userController.getUsers);

export default router;