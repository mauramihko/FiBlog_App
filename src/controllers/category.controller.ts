import type { Request, Response, NextFunction } from 'express';
import connection from '../db/index.ts';
import { CreateCategorySchema } from '../schemas/blog.schema.ts';

// 1. READ (GET ALL CATEGORIES)
export const getCategories = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const [rows] = await connection.query('SELECT * FROM categories ORDER BY id DESC');
    return res.status(200).json({ success: true, data: rows });
  } catch (error) {
    next(error);
  }
};

// 2. CREATE CATEGORY
export const createCategory = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const validatedData = CreateCategorySchema.parse(req.body);
    
    const [result]: any = await connection.query(
      'INSERT INTO categories (name) VALUES (?)',
      [validatedData.name]
    );

    return res.status(201).json({
      success: true,
      message: 'Kategori berhasil dibuat',
      data: { id: result.insertId, ...validatedData },
    });
  } catch (error) {
    next(error);
  }
};

// 3. UPDATE CATEGORY
export const updateCategory = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;
    // Menggunakan schema yang sama untuk validasi nama baru
    const validatedData = CreateCategorySchema.parse(req.body);

    const [result]: any = await connection.query(
      'UPDATE categories SET name = ? WHERE id = ?',
      [validatedData.name, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kategori tidak ditemukan',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Kategori berhasil diperbarui',
      data: { id: Number(id), name: validatedData.name },
    });
  } catch (error) {
    next(error);
  }
};

// 4. DELETE CATEGORY
export const deleteCategory = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { id } = req.params;

    const [result]: any = await connection.query(
      'DELETE FROM categories WHERE id = ?',
      [id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: 'Kategori tidak ditemukan',
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Kategori berhasil dihapus',
    });
  } catch (error) {
    next(error);
  }
};