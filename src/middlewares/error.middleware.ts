import type { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Catch error khusus dari validasi Zod
  if (err instanceof ZodError) {
    return res.status(400).json({
      success: false,
      message: 'Validasi Input Gagal',
      errors: err.issues.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
      })),
    });
  }

  // Catch error server / database umum
  console.error('Unhandled Error:', err);
  return res.status(500).json({
    success: false,
    message: 'Terjadi kesalahan pada server',
  });
};