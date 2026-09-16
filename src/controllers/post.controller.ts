import type { Request, Response, NextFunction } from 'express';
import connection from '../db/index.ts';
import { CreatePostSchema, UpdatePostSchema, idParamSchema } from '../schemas/blog.schema.ts';

// GET ALL POSTS
export const getPosts = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = `
      SELECT posts.*, categories.name AS category_name 
      FROM posts 
      LEFT JOIN categories ON posts.category_id = categories.id
      ORDER BY posts.id DESC
    `;
    const [rows] = await connection.query(query);
    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    next(error);
  }
};

// GET POST BY ID
export const getPostById = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = idParamSchema.parse(req.params.id);

    const query = `
      SELECT posts.*, categories.name AS category_name 
      FROM posts 
      LEFT JOIN categories ON posts.category_id = categories.id
      WHERE posts.id = ?
    `;
    const [rows]: any = await connection.query(query, [id]);

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Artikel tidak ditemukan' });
    }

    return res.status(200).json({ success: true, data: rows[0] });
  } catch (error) {
    next(error);
  }
};

// CREATE POST
export const createPost = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const validatedData = CreatePostSchema.parse(req.body);

    // Cek ketersediaan kategori
    const [categoryRows]: any = await connection.query(
      'SELECT id FROM categories WHERE id = ?',
      [validatedData.categoryId]
    );

    if (categoryRows.length === 0) {
      return res.status(404).json({ success: false, message: 'Kategori tidak ditemukan' });
    }

    // Menggunakan category_id sesuai kolom di MySQL
    const [result]: any = await connection.query(
      'INSERT INTO posts (title, content, category_id) VALUES (?, ?, ?)',
      [validatedData.title, validatedData.content, validatedData.categoryId]
    );

    return res.status(201).json({
      success: true,
      message: 'Artikel berhasil dibuat',
      data: { id: result.insertId, ...validatedData },
    });
  } catch (error) {
    next(error);
  }
};

// UPDATE POST (PUT)
export const updatePost = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = idParamSchema.parse(req.params.id);
    const validatedData = UpdatePostSchema.parse(req.body);

    // Cek ketersediaan artikel
    const [existing]: any = await connection.query('SELECT * FROM posts WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Artikel tidak ditemukan' });
    }

    const title = validatedData.title ?? existing[0].title;
    const content = validatedData.content ?? existing[0].content;
    const categoryId = validatedData.categoryId ?? existing[0].category_id;

    await connection.query(
      'UPDATE posts SET title = ?, content = ?, category_id = ? WHERE id = ?',
      [title, content, categoryId, id]
    );

    return res.status(200).json({
      success: true,
      message: 'Artikel berhasil diupdate',
      data: { id, title, content, categoryId },
    });
  } catch (error) {
    next(error);
  }
};

// DELETE POST
export const deletePost = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const id = idParamSchema.parse(req.params.id);

    const [existing]: any = await connection.query('SELECT id FROM posts WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ success: false, message: 'Artikel tidak ditemukan' });
    }

    await connection.query('DELETE FROM posts WHERE id = ?', [id]);

    return res.status(200).json({ success: true, message: 'Artikel berhasil dihapus' });
  } catch (error) {
    next(error);
  }
};