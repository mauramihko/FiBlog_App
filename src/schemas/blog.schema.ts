import { z } from 'zod';

// Validasi Parameter ID (mengubah string dari URL ke number)
export const idParamSchema = z.string().transform((val, ctx) => {
  const parsed = parseInt(val, 10);
  if (isNaN(parsed) || parsed <= 0) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'ID harus berupa angka positif yang valid',
    });
    return z.NEVER;
  }
  return parsed;
});

// Schema Kategori
export const CreateCategorySchema = z.object({
  name: z.string({ message: 'Nama kategori wajib diisi' }).min(1, 'Nama kategori tidak boleh kosong'),
});

// Schema Post / Artikel (Create)
export const CreatePostSchema = z.object({
  title: z
    .string({ message: 'Judul wajib diisi' })
    .min(3, 'Judul minimal 3 karakter'),
  content: z
    .string({ message: 'Konten wajib diisi' })
    .min(10, 'Konten minimal 10 karakter'),
  categoryId: z
    .number({ message: 'Category ID wajib diisi' })
    .positive('Category ID tidak valid'),
});

// Schema Post / Artikel (Update - semua field opsional)
export const UpdatePostSchema = CreatePostSchema.partial();