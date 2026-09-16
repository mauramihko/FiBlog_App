import mysql from "mysql2/promise";

const connection = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '', // sesuaikan password kamu jika ada
    database: 'db_blog_app'
});

export default connection;