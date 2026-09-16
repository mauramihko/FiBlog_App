import { Router } from 'express';
import {
  getPosts,
  getPostById,
  createPost,
  updatePost,
  deletePost,
} from '../controllers/post.controller.ts';

const router = Router();

router.get('/', getPosts);          // Get All
router.get('/:id', getPostById);    // Get Detail
router.post('/', createPost);       // Create
router.put('/:id', updatePost);     // Update (PUT)
router.delete('/:id', deletePost);  // Delete

export default router;