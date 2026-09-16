import { Router } from 'express';
import { getBookmarks, addBookmark, deleteBookmark } from '../controllers/bookmark.controller.ts';

const bookmarkRouter = Router();

bookmarkRouter.get('/', getBookmarks);
bookmarkRouter.post('/', addBookmark);
bookmarkRouter.delete('/:post_id', deleteBookmark);

export default bookmarkRouter;