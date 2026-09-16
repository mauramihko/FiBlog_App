import express from 'express';
import cors from 'cors';
import categoryRouter from './routes/category.router.ts';
import postRouter from './routes/post.router.ts';
import bookmarkRouter from './routes/bookmark.router.ts'; 
import { errorHandler } from './middlewares/error.middleware.ts';

const app = express();
const PORT = 5000; 

// Middleware
app.use(cors());
app.use(express.json());

// Inisialisasi Endpoints API
app.use('/api/categories', categoryRouter);
app.use('/api/posts', postRouter);
app.use('/api/bookmarks', bookmarkRouter); // 2. Lengkapi baris ini

// Central Error Handling Middleware
app.use(errorHandler);

// Listen Server
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});