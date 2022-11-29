use sqlx::{Connection, Executor, Row, SqliteConnection};
use std::env::consts::ARCH;

#[async_std::main]
async fn main() -> Result<(), sqlx::Error> {
    let mut conn = SqliteConnection::connect("sqlite::memory:").await?;
    conn.execute(
        "CREATE TABLE groups (
   gid INTEGER PRIMARY KEY,
   name TEXT NOT NULL
);",
    )
    .await?;
    conn.execute("INSERT INTO groups VALUES (1, 'John')")
        .await?;
    let name: String = sqlx::query("SELECT * FROM groups")
        .fetch_one(&mut conn)
        .await?
        .try_get("name")?;
    println!("Executing from arch {} with name {}!", ARCH, name);

    Ok(())
}
