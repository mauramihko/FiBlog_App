import type { Request, Response, NextFunction } from 'express';
import connection from '../db/index.ts';

export const getBookmarks = async (req: Request, res: Response) => {
  try {
    const [rows] = await connection.query(`
      SELECT posts.*, categories.name AS category_name, bookmarks.id AS bookmark_id 
      FROM bookmarks 
      JOIN posts ON bookmarks.post_id = posts.id 
      LEFT JOIN categories ON posts.category_id = categories.id
    `);
    res.json(rows);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
};

export const addBookmark = async (req: Request, res: Response) => {
  const { post_id } = req.body;
  try {
    await connection.query('INSERT IGNORE INTO bookmarks (post_id) VALUES (?)', [post_id]);
    res.status(201).json({ message: 'Berhasil di-bookmark' });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
};

export const deleteBookmark = async (req: Request, res: Response) => {
  const { post_id } = req.params;
  try {
    await connection.query('DELETE FROM bookmarks WHERE post_id = ?', [post_id]);
    res.json({ message: 'Berhasil dihapus dari bookmark' });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
};