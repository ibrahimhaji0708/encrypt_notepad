use flutter_rust_bridge::frb;
use std::fs::{self, File};
use std::io::{self, Write};
use std::path::PathBuf;
use std::sync::Once;

static ENCRYPTION_KEY: &[u8] = b"NOTEPAD_SECRET_KEY_2025";
static INIT: Once = Once::new();

fn initialize() {
    let dir = notes_dir();
    if !dir.exists() {
        if let Err(e) = fs::create_dir_all(&dir) {
            eprintln!("Failed to create notes directory: {}", e);
        } else {
            println!("Notes directory created at: {:?}", dir);
        }
    }
}

fn notes_dir() -> PathBuf {
    let mut dir = std::env::current_dir().unwrap_or_default();
    dir.push("notes");
    dir
}

fn ensure_directory_exists() -> io::Result<PathBuf> {
    INIT.call_once(|| {
        initialize();
    });
    let dir = notes_dir();
    if !dir.exists() {
        fs::create_dir_all(&dir)?;
    }
    Ok(dir)
}

fn xor_encrypt_decrypt(data: &[u8]) -> Vec<u8> {
    data.iter()
        .zip(ENCRYPTION_KEY.iter().cycle())
        .map(|(&b, &k)| b ^ k)
        .collect()
}

// Another savenote func
#[frb]
pub fn save_note_to_disk(title: String, content: String) -> bool {
    let sanitized = title.replace(|c: char| !c.is_alphanumeric(), "_");
    let path = PathBuf::from(format!("/storage/emulated/0/Notes/{}.txt", sanitized));
    
    if let Some(parent) = path.parent() {
        if let Err(e) = fs::create_dir_all(parent) {
            eprintln!("[Rust] Failed to create folder: {}", e);
            return false;
        }
    }
    
    let encrypted = xor_encrypt_decrypt(content.as_bytes());
    match File::create(&path).and_then(|mut f| f.write_all(&encrypted)) {
        Ok(_) => {
            println!("[Rust] Saved note to {:?}", path);
            true
        }
        Err(e) => {
            eprintln!("[Rust] File write failed: {}", e);
            false
        }
    }
}

#[frb]
pub fn load_note_from_disk(title: String) -> String {
    let dir = match ensure_directory_exists() {
        Ok(dir) => dir,
        Err(_) => return String::new(),
    };
    
    let mut path = dir;
    path.push(format!("{}.txt", title));
    
    match fs::read(&path) {
        Ok(encrypted_bytes) => {
            let decrypted_bytes = xor_encrypt_decrypt(&encrypted_bytes);
            match String::from_utf8(decrypted_bytes) {
                Ok(content) => content,
                Err(_) => String::new(),
            }
        }
        Err(_) => String::new(),
    }
}

#[frb]
pub fn list_note_titles() -> String {
    let dir = match ensure_directory_exists() {
        Ok(dir) => dir,
        Err(_) => return String::new(),
    };
    
    let mut titles = Vec::new();
    if let Ok(entries) = fs::read_dir(dir) {
        for entry in entries.flatten() {
            if let Some(name) = entry.file_name().to_str() {
                if let Some(title) = name.strip_suffix(".txt") {
                    titles.push(title.to_string());
                }
            }
        }
    }
    
    titles.sort();
    titles.join(";")
}

#[frb]
pub fn delete_note_from_disk(title: String) {
    let title_str = title;
    
    let dir = match ensure_directory_exists() {
        Ok(dir) => dir,
        Err(e) => {
            eprintln!("Failed to access notes directory for deletion: {}", e);
            return;
        }
    };
    
    let mut path = dir;
    path.push(format!("{}.txt", title_str));
    
    if let Err(e) = fs::remove_file(&path) {
        eprintln!("Failed to delete note {}: {}", title_str, e);
    } else {
        println!("Note deleted successfully: {}", title_str);
    }
}

fn base64_encode(data: &[u8]) -> String {
    const ALPHABET: &[u8] = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    let mut result = String::with_capacity((data.len() + 2) / 3 * 4);
    
    for chunk in data.chunks(3) {
        let b0 = chunk[0] as u32;
        let b1 = if chunk.len() > 1 { chunk[1] as u32 } else { 0 };
        let b2 = if chunk.len() > 2 { chunk[2] as u32 } else { 0 };
        
        let triple = (b0 << 16) | (b1 << 8) | b2;
        
        result.push(ALPHABET[(triple >> 18) as usize] as char);
        result.push(ALPHABET[((triple >> 12) & 0x3F) as usize] as char);
        
        if chunk.len() > 1 {
            result.push(ALPHABET[((triple >> 6) & 0x3F) as usize] as char);
        } else {
            result.push('=');
        }
        
        if chunk.len() > 2 {
            result.push(ALPHABET[(triple & 0x3F) as usize] as char);
        } else {
            result.push('=');
        }
    }
    
    result
}

#[frb]
pub fn encrypt_text(text: String) -> String {
    let encrypted_bytes = xor_encrypt_decrypt(text.as_bytes());
    let encoded = base64_encode(&encrypted_bytes);
    format!("🔒 {}", encoded)
}